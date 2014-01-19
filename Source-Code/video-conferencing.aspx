﻿<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="video-conferencing.aspx.cs" Inherits="SignalingServer.video_conferencing" %>

<!--
    > 2013, Muaz Khan - wwww.MuazKhan.com
    > MIT License     - www.WebRTC-Experiment.com/licence
    > Documentation   - github.com/muaz-khan/WebRTC-Experiment/tree/master/video-conferencing
-->
<!DOCTYPE html>
<html lang="en">
    <head>
        <title>WebRTC » video-conferencing & WebSync as Signaling GateWay!</title>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=no">
        <link rel="author" type="text/html" href="https://plus.google.com/+MuazKhan">
        <meta name="author" content="Muaz Khan">
        <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
        <link rel="stylesheet" href="//www.webrtc-experiment.com/style.css">
        
        <style>
            audio, video {
                -moz-transition: all 1s ease;
                -ms-transition: all 1s ease;
                
                -o-transition: all 1s ease;
                -webkit-transition: all 1s ease;
                transition: all 1s ease;
                vertical-align: top;
            }

            input {
                border: 1px solid #d9d9d9;
                border-radius: 1px;
                font-size: 2em;
                margin: .2em;
                width: 30%;
            }

            .setup {
                border-bottom-left-radius: 0;
                border-top-left-radius: 0;
                font-size: 102%;
                height: 47px;
                margin-left: -9px;
                margin-top: 8px;
                position: absolute;
            }

            p { padding: 1em; }

            li {
                border-bottom: 1px solid rgb(189, 189, 189);
                border-left: 1px solid rgb(189, 189, 189);
                padding: .5em;
            }
        </style>
        <script>
            document.createElement('article');
            document.createElement('footer');
        </script>
        
        <!-- WebSync -->
        <script src="/Scripts/fm.js"> </script>
        <script src="/Scripts/fm.websync.js"> </script>
        <script src="/Scripts/fm.websync.subscribers.js"> </script>
        <script src="/Scripts/fm.websync.chat.js"> </script>
        
        <!-- www.webrtc-experiment.com/getMediaElement -->
        <script src="//www.webrtc-experiment.com/getMediaElement.min.js"> </script>

        <!-- scripts used for video-conferencing -->
        <script src="//www.webrtc-experiment.com/RTCPeerConnection-v1.5.js"> </script>
        <script src="//www.webrtc-experiment.com/video-conferencing/conference.js"> </script>
    </head>

    <body>
        <article>
            <header style="text-align: center;">
                <h1>
                    <a href="https://www.webrtc-experiment.com/">WebRTC</a> 
                    » 
                    <a href="https://github.com/muaz-khan/WebRTC-Experiment/tree/master/video-conferencing" target="_blank">video-conferencing</a>
                    & WebSync as Signaling GateWay!
                </h1>            
                <p>
                    <span>Copyright © 2013</span>
                    <a href="https://github.com/muaz-khan" target="_blank">Muaz Khan</a><span>&lt;</span><a href="http://twitter.com/muazkh" target="_blank">@muazkh</a><span>&gt;</span>
                    »
                    <a href="http://twitter.com/WebRTCWeb" target="_blank" title="Twitter profile for WebRTC Experiments">@WebRTC Experiments</a>
                    »
                    <a href="https://plus.google.com/106306286430656356034/posts" target="_blank" title="Google+ page for WebRTC Experiments">Google+</a>
                    »
                    <a href="https://github.com/muaz-khan/WebRTC-Experiment/issues" target="_blank">What's New?</a>
                </p>
            </header>

            <div class="github-stargazers"></div>
        
            <!-- just copy this <section> and next script -->
            <section class="experiment">                
                <section>
                    <span>
                        Private ?? <a href="/video-conferencing/" target="_blank" title="Open this link in new tab. Then your conference room will be private!"><code><strong id="unique-token">#123456789</strong></code></a>
                    </span>
                    
                    <input type="text" id="conference-name">
                    <button id="setup-new-room" class="setup">Setup New Conference</button>
                </section>
                
                <!-- list of all available conferencing rooms -->
                <table style="width: 100%;" id="rooms-list"></table>
                
                <!-- local/remote videos container -->
                <div id="videos-container"></div>
            </section>
        
            <script>
                // Muaz Khan     - https://github.com/muaz-khan
                // MIT License   - https://www.webrtc-experiment.com/licence/
                // Documentation - https://github.com/muaz-khan/WebRTC-Experiment/tree/master/video-conferencing

                // ------------------------------------------------------------------
                // <using WebSync for signaling>
                var channels = { };
                var username = Math.round(Math.random() * 60535) + 5000;

                var client = new fm.websync.client('websync.ashx');

                client.setAutoDisconnect({
                    synchronous: true
                });

                client.connect({
                    onSuccess: function() {
                        client.join({
                            channel: '/chat',
                            userId: username,
                            userNickname: username,
                            onReceive: function(event) {
                                var message = JSON.parse(event.getData().text);
                                if (channels[message.channel] && channels[message.channel].onmessage) {
                                    channels[message.channel].onmessage(message.message);
                                }
                            }
                        });
                    }
                });

                function openSocket(config) {
                    var channel = config.channel || 'video-conferencing';
                    channels[channel] = config;

                    if (config.onopen) setTimeout(config.onopen, 1000);
                    return {
                        send: function(message) {
                            client.publish({
                                channel: '/chat',
                                data: {
                                    username: username,
                                    text: JSON.stringify({
                                        message: message,
                                        channel: channel
                                    })
                                }
                            });
                        }
                    };
                }

// </using WebSync for signaling>
// ------------------------------------------------------------------

                var config = {
                    openSocket: openSocket,
                    onRemoteStream: function(media) {
                        var mediaElement = getMediaElement(media.video, {
                            width: (videosContainer.clientWidth / 2) - 50,
                            buttons: ['mute-audio', 'mute-video', 'full-screen', 'volume-slider']
                        });
                        mediaElement.id = media.streamid;
                        videosContainer.insertBefore(mediaElement, videosContainer.firstChild);
                    },
                    onRemoteStreamEnded: function(stream, video) {
                        if (video.parentNode && video.parentNode.parentNode && video.parentNode.parentNode.parentNode) {
                            video.parentNode.parentNode.parentNode.removeChild(video.parentNode.parentNode);
                        }
                    },
                    onRoomFound: function(room) {
                        var alreadyExist = document.querySelector('button[data-broadcaster="' + room.broadcaster + '"]');
                        if (alreadyExist) return;

                        if (typeof roomsList === 'undefined') roomsList = document.body;

                        var tr = document.createElement('tr');
                        tr.innerHTML = '<td><strong>' + room.roomName + '</strong> shared a conferencing room with you!</td>' +
                            '<td><button class="join">Join</button></td>';
                        roomsList.insertBefore(tr, roomsList.firstChild);

                        var joinRoomButton = tr.querySelector('.join');
                        joinRoomButton.setAttribute('data-broadcaster', room.broadcaster);
                        joinRoomButton.setAttribute('data-roomToken', room.roomToken);
                        joinRoomButton.onclick = function() {
                            this.disabled = true;

                            var broadcaster = this.getAttribute('data-broadcaster');
                            var roomToken = this.getAttribute('data-roomToken');
                            captureUserMedia(function() {
                                conferenceUI.joinRoom({
                                    roomToken: roomToken,
                                    joinUser: broadcaster
                                });
                            });
                        };
                    },
                    onRoomClosed: function(room) {
                        var joinButton = document.querySelector('button[data-roomToken="' + room.roomToken + '"]');
                        if (joinButton) {
                            // joinButton.parentNode === <li>
                            // joinButton.parentNode.parentNode === <td>
                            // joinButton.parentNode.parentNode.parentNode === <tr>
                            // joinButton.parentNode.parentNode.parentNode.parentNode === <table>
                            joinButton.parentNode.parentNode.parentNode.parentNode.removeChild(joinButton.parentNode.parentNode.parentNode);
                        }
                    }
                };

                function setupNewRoomButtonClickHandler() {
                    btnSetupNewRoom.disabled = true;
                    document.getElementById('conference-name').disabled = true;
                    captureUserMedia(function() {
                        conferenceUI.createRoom({
                            roomName: (document.getElementById('conference-name') || { }).value || 'Anonymous'
                        });
                    });
                }

                function captureUserMedia(callback) {
                    var video = document.createElement('video');

                    getUserMedia({
                        video: video,
                        onsuccess: function(stream) {
                            config.attachStream = stream;
                            callback && callback();

                            video.setAttribute('muted', true);

                            var mediaElement = getMediaElement(video, {
                                width: (videosContainer.clientWidth / 2) - 50,
                                buttons: ['mute-audio', 'mute-video', 'full-screen', 'volume-slider']
                            });
                            mediaElement.toggle('mute-audio');
                            videosContainer.insertBefore(mediaElement, videosContainer.firstChild);
                        },
                        onerror: function() {
                            alert('unable to get access to your webcam');
                            callback && callback();
                        }
                    });
                }

                var conferenceUI = conference(config);

                /* UI specific */
                var videosContainer = document.getElementById('videos-container') || document.body;
                var btnSetupNewRoom = document.getElementById('setup-new-room');
                var roomsList = document.getElementById('rooms-list');

                if (btnSetupNewRoom) btnSetupNewRoom.onclick = setupNewRoomButtonClickHandler;

                function rotateVideo(video) {
                    video.style[navigator.mozGetUserMedia ? 'transform' : '-webkit-transform'] = 'rotate(0deg)';
                    setTimeout(function() {
                        video.style[navigator.mozGetUserMedia ? 'transform' : '-webkit-transform'] = 'rotate(360deg)';
                    }, 1000);
                }

                (function() {
                    var uniqueToken = document.getElementById('unique-token');
                    if (uniqueToken)
                        if (location.hash.length > 2) uniqueToken.parentNode.parentNode.parentNode.innerHTML = '<h2 style="text-align:center;"><a href="' + location.href + '" target="_blank">Share this link</a></h2>';
                        else uniqueToken.innerHTML = uniqueToken.parentNode.parentNode.href = '#' + (Math.random() * new Date().getTime()).toString(36).toUpperCase().replace( /\./g , '-');
                })();

                function scaleVideos() {
                    var videos = document.querySelectorAll('video'),
                        length = videos.length, video;

                    var minus = 130;
                    var windowHeight = 700;
                    var windowWidth = 600;
                    var windowAspectRatio = windowWidth / windowHeight;
                    var videoAspectRatio = 4 / 3;
                    var blockAspectRatio;
                    var tempVideoWidth = 0;
                    var maxVideoWidth = 0;

                    for (var i = length; i > 0; i--) {
                        blockAspectRatio = i * videoAspectRatio / Math.ceil(length / i);
                        if (blockAspectRatio <= windowAspectRatio) {
                            tempVideoWidth = videoAspectRatio * windowHeight / Math.ceil(length / i);
                        } else {
                            tempVideoWidth = windowWidth / i;
                        }
                        if (tempVideoWidth > maxVideoWidth)
                            maxVideoWidth = tempVideoWidth;
                    }
                    for (var i = 0; i < length; i++) {
                        video = videos[i];
                        if (video)
                            video.width = maxVideoWidth - minus;
                    }
                }

                window.onresize = scaleVideos;

            </script>
            
            <section class="experiment">
                <h2 class="header">How to use WebSync for Signaling?</h2>
                <pre>
// ------------------------------------------------------------------
// start-using WebSync for signaling
var channels = {};
var username = Math.round(Math.random() * 60535) + 5000;

var client = new fm.websync.client('websync.ashx');

client.setAutoDisconnect({
    synchronous: true
});

client.connect({
    onSuccess: function () {
        client.join({
            channel: '/chat',
            userId: username,
            userNickname: username,
            onReceive: function (event) {
                var message = JSON.parse(event.getData().text);
                if (channels[message.channel] && channels[message.channel].onmessage) {
                    channels[message.channel].onmessage(message.message);
                }
            }
        });
    }
});

function openSocket(config) {
    var channel = config.channel || 'video-conferencing';
    channels[channel] = config;

    if (config.onopen) setTimeout(config.onopen, 1000);
    return {
        send: function (message) {
            client.publish({
                channel: '/chat',
                data: {
                    username: username,
                    text: JSON.stringify({
                        message: message,
                        channel: channel
                    })
                }
            });
        }
    };
}
// end-using WebSync for signaling
// ------------------------------------------------------------------

var config = {
     openSocket: openSocket,
     onRemoteStream: function() {},
     onRoomFound: function() {}
};
</pre>
            </section>
            
            <section class="experiment">
                <ol>
                    <li>Mesh networking model is implemented to open multiple interconnected peer connections</li>
                    <li>Maximum peer connections limit is <strong>256</strong> (on chrome)</li>
                </ol>
            </section>
        
            <section class="experiment own-widgets latest-commits">
                <h2 class="header" id="updates" style="color: red; padding-bottom: .1em;"><a href="https://github.com/muaz-khan/WebRTC-Experiment/commits/master" target="_blank">Latest Updates</a></h2>
                <div id="github-commits"></div>
            </section>
        
            <section class="experiment">
                <h2 class="header" id="feedback">Feedback</h2>
                <div>
                    <textarea id="message" style="border: 1px solid rgb(189, 189, 189); height: 8em; margin: .2em; outline: none; resize: vertical; width: 98%;" placeholder="Have any message? Suggestions or something went wrong?"></textarea>
                </div>
                <button id="send-message" style="font-size: 1em;">Send Message</button><small style="margin-left: 1em;">Enter your email too; if you want "direct" reply!</small>
            </section>
            
            <section class="experiment">
                <h2 class="header">How it works?</h2>
                <p><strong>
                       Huge bandwidth and CPU-usage out of multiple peers interconnection:
                   </strong>
                </p>
                <p>
                    To understand it better; assume that 10 users are sharing video in a group.
                    <strong>40</strong> RTP-ports (i.e. streams) will be created for each user. All streams are expected
                    to be flowing concurrently; which causes blur video experience and audio lose/noise (echo)
                    issues.</p>
                <p>
                    For each user:</p>
                <ol>
                    <li>10 RTP ports are opened to send video upward i.e. for outgoing video streams</li>
                    <li>10 RTP ports are opened to send audio upward i.e. for outgoing audio streams</li>
                    <li>10 RTP ports are opened to receive video i.e. for incoming video streams</li>
                    <li>10 RTP ports are opened to receive audio i.e. for incoming audio streams</li>
                </ol>
                <p>
                    Maximum bandwidth used by each video RTP port (media-track) is about 1MB; which can be controlled using "b=AS" session description parameter values. In two-way video-only session; 2MB bandwidth is used by each peer; otherwise; a low-quality blurred video will be delivered.
                </p>
                <pre>
// removing existing bandwidth lines
sdp = sdp.replace( /b=AS([^\r\n]+\r\n)/g , '');

// setting "outgoing" audio RTP port's bandwidth to "50kbit/s"
sdp = sdp.replace( /a=mid:audio\r\n/g , 'a=mid:audio\r\nb=AS:50\r\n');

// setting "outgoing" video RTP port's bandwidth to "256kbit/s"
sdp = sdp.replace( /a=mid:video\r\n/g , 'a=mid:video\r\nb=AS:256\r\n');
</pre>
                <p>
                    Possible issues:</p>
                <ol>
                    <li>Blurry video experience</li>
                    <li>Unclear voice and audio lost</li>
                    <li>Bandwidth issues / slow streaming / CPU overwhelming</li>
                </ol>
                <p>Solution? Obviously a media server!</p>
            </section>
        </article>
        <footer>
            <p>
                <a href="https://www.webrtc-experiment.com/">WebRTC Experiments</a>
                ©
                <a href="https://plus.google.com/100325991024054712503" rel="author" target="_blank">Muaz Khan</a>, <span>2013 </span>»
                <a href="mailto:muazkh@gmail.com" target="_blank">Email</a>»
                <a href="http://twitter.com/muazkh" target="_blank">@muazkh</a>»
                <a href="https://github.com/muaz-khan" target="_blank">Github</a>
            </p>
        </footer>
    
        <!-- commits.js is useless for you! -->
        <script src="//www.webrtc-experiment.com/commits.js" async> </script>
        
        <!-- somee.com hack! -->
        <style>center, .last-div, .last-div ~ * { display: none !important }</style>
        <div class="last-div"></div>
    </body>
</html>