﻿<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="RTCMultiConnection.aspx.cs" Inherits="SignalingServer.RTCMultiConnection" %>

<!--
    // Muaz Khan     - www.MuazKhan.com
    // MIT License   - www.WebRTC-Experiment.com/licence
    // Documentation - www.RTCMultiConnection.org
-->
<!DOCTYPE html>
<html lang="en">
    <head>
        <title>RTCMultiConnection & WebSync as Signaling GateWay!</title>
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
                width: 20%;
            }

            select {
                border: 1px solid #d9d9d9;
                border-radius: 1px;
                height: 50px;
                margin-left: 1em;
                margin-right: -12px;
                padding: 1.1em;
                vertical-align: 6px;
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

            #chat-output div, #file-progress div {
                border: 1px solid black;
                border-bottom: 0;
                padding: .1em .4em;
            }

            #chat-output, #file-progress {
                margin: 0 0 0 .4em;
                max-height: 12em;
                overflow: auto;
            }

            .data-box input {
                border: 1px solid black;
                font-family: inherit;
                font-size: 1em;
                margin: .1em .3em;
                outline: none;
                padding: .1em .2em;
                width: 97%;
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

        <!-- www.RTCMultiConnection.org -->
        <script src="//www.webrtc-experiment.com/RTCMultiConnection-v1.5.min.js"> </script>
    </head>

    <body>
        <article>
            <header style="text-align: center;">
                <h1>
                    <a href="http://www.RTCMultiConnection.org/">RTCMultiConnection</a> & WebSync as Signaling GateWay!
                    ® 
                    <a href="https://github.com/muaz-khan" target="_blank">Muaz Khan</a>
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
                    <select id="session" title="Session">
                        <option>audio+video+data+screen</option>
                        <option>audio+video+data</option>						
                        <option>audio+data+screen</option>
                        <option>audio+video+screen</option>
                        <option selected>audio+video</option>
                        <option>audio+screen</option>
                        <option>video+screen</option>
                        <option>data+screen</option>
                        <option>audio+data</option>
                        <option>video+data</option>
                        <option>audio</option>
                        <option>video</option>
                        <option>data</option>
                        <option>screen</option>
                    </select>
                    <select id="direction" title="Direction">
                        <option>many-to-many</option>
                        <option>one-to-one</option>
                        <option>one-to-many</option>
                        <option>one-way</option>
                    </select>
                    <input type="text" id="session-name">
                    <button id="setup-new-session" class="setup">New Session</button>
                </section>
                
                <!-- list of all available broadcasting rooms -->
                <table style="width: 100%;" id="rooms-list"></table>
                
                <!-- local/remote videos container -->
                <div id="videos-container"></div>
            </section>
			
            <section class="experiment data-box">
                <h2 class="header" style="border-bottom: 0;">WebRTC DataChannel</h2>
                <table style="width: 100%;">
                    <tr>
                        <td>
                            <h2 style="display: block; font-size: 1em; text-align: center;">Text Chat</h2>

                            <div id="chat-output"></div>
                            <input type="text" id="chat-input" style="font-size: 1.2em;" placeholder="chat message" disabled>
                        </td>
                        <td style="background: white;">
                            <h2 style="display: block; font-size: 1em; text-align: center;">Share Files</h2>
                            <input type="file" id="file" disabled>

                            <div id="file-progress"></div>
                        </td>
                    </tr>
                </table>
            </section>
        
            <script>
                // Muaz Khan     - www.MuazKhan.com
                // MIT License   - www.WebRTC-Experiment.com/licence
                // Documentation - www.RTCMultiConnection.org

                var connection = new RTCMultiConnection();

                connection.session = {
                    audio: true,
                    video: true
                };

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

                connection.openSignalingChannel = function(config) {
                    var channel = config.channel || this.channel;
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
                };
                // </using WebSync for signaling>
                // ------------------------------------------------------------------

                var roomsList = document.getElementById('rooms-list'), sessions = { };
                connection.onNewSession = function(session) {
                    if (sessions[session.sessionid]) return;
                    sessions[session.sessionid] = session;

                    var tr = document.createElement('tr');
                    tr.innerHTML = '<td><strong>' + session.extra['session-name'] + '</strong> is an active session.</td>' +
                        '<td><button class="join">Join</button></td>';
                    roomsList.insertBefore(tr, roomsList.firstChild);

                    tr.querySelector('.join').setAttribute('data-sessionid', session.sessionid);
                    tr.querySelector('.join').onclick = function() {
                        this.disabled = true;

                        session = sessions[this.getAttribute('data-sessionid')];
                        if (!session) alert('No room to join.');

                        connection.join(session);
                    };
                };


                var videosContainer = document.getElementById('videos-container') || document.body;
                connection.onstream = function(e) {
                    var buttons = ['mute-audio', 'mute-video', 'record-audio', 'record-video', 'full-screen', 'volume-slider', 'stop'];

                    if (connection.session.audio && !connection.session.video) {
                        buttons = ['mute-audio', 'record-audio', 'full-screen', 'stop'];
                    }

                    var mediaElement = getMediaElement(e.mediaElement, {
                        width: (videosContainer.clientWidth / 2) - 50,
                        buttons: buttons,
                        onMuted: function(type) {
                            connection.streams[e.streamid].mute({
                                audio: type == 'audio',
                                video: type == 'video'
                            });
                        },
                        onUnMuted: function(type) {
                            connection.streams[e.streamid].unmute({
                                audio: type == 'audio',
                                video: type == 'video'
                            });
                        },
                        onRecordingStarted: function(type) {
                            connection.streams[e.streamid].startRecording({
                                audio: type == 'audio',
                                video: type == 'video'
                            });
                        },
                        onRecordingStopped: function(type) {
                            connection.streams[e.streamid].stopRecording(function(blob) {
                                var _mediaElement = document.createElement(type);

                                _mediaElement.src = URL.createObjectURL(blob);
                                _mediaElement = getMediaElement(_mediaElement, {
                                    buttons: ['mute-audio', 'mute-video', 'stop']
                                });

                                _mediaElement.toggle(['mute-audio', 'mute-video']);

                                videosContainer.insertBefore(_mediaElement, videosContainer.firstChild);
                            }, type);
                        },
                        onZoomin: function() {
                            console.log('onZoomin');
                        },
                        onZoomout: function() {
                            console.log('onZoomout');
                        },
                        onStopped: function() {
                            connection.drop();
                        }
                    });

                    if (e.type == 'local') {
                        // mediaElement.toggle(['mute-audio']);
                    }
                    videosContainer.insertBefore(mediaElement, videosContainer.firstChild);
                };

                connection.onstreamended = function(e) {
                    if (e.mediaElement.parentNode && e.mediaElement.parentNode.parentNode && e.mediaElement.parentNode.parentNode.parentNode) {
                        e.mediaElement.parentNode.parentNode.parentNode.removeChild(e.mediaElement.parentNode.parentNode);
                    }
                };

                var setupNewSession = document.getElementById('setup-new-session');

                setupNewSession.onclick = function() {
                    setupNewSession.disabled = true;

                    var direction = document.getElementById('direction').value;
                    var _session = document.getElementById('session').value;
                    var splittedSession = _session.split('+');

                    var session = { };
                    for (var i = 0; i < splittedSession.length; i++) {
                        session[splittedSession[i]] = true;
                    }

                    var maxParticipantsAllowed = 256;

                    if (direction == 'one-to-one') maxParticipantsAllowed = 1;
                    if (direction == 'one-to-many') session.broadcast = true;
                    if (direction == 'one-way') session.oneway = true;

                    var sessionName = document.getElementById('session-name').value;
                    connection.extra = {
                        'session-name': sessionName || 'Anonymous'
                    };

                    connection.session = session;
                    connection.maxParticipantsAllowed = maxParticipantsAllowed;
                    connection.open();
                };

                function rotateInCircle(video) {
                    video.style[navigator.mozGetUserMedia ? 'transform' : '-webkit-transform'] = 'rotate(0deg)';
                    setTimeout(function() {
                        video.style[navigator.mozGetUserMedia ? 'transform' : '-webkit-transform'] = 'rotate(360deg)';
                    }, 1000);
                    scaleVideos();
                }

                function scaleVideos() {
                    var videos = document.querySelectorAll('.media-container'),
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

                connection.onmessage = function(e) {
                    appendDIV(e.data);

                    console.debug(e.userid, 'posted', e.data);
                    console.log('latency:', e.latency, 'ms');
                };

                // on data connection gets open
                connection.onopen = function() {
                    if (document.getElementById('chat-input')) document.getElementById('chat-input').disabled = false;
                    if (document.getElementById('file')) document.getElementById('file').disabled = false;
                    if (document.getElementById('open-new-session')) document.getElementById('open-new-session').disabled = true;
                };

                var progressHelper = { };

                connection.autoSaveToDisk = false;

                connection.onFileProgress = function(chunk) {
                    var helper = progressHelper[chunk.uuid];
                    helper.progress.value = chunk.currentPosition || chunk.maxChunks || helper.progress.max;
                    updateLabel(helper.progress, helper.label);
                };
                connection.onFileStart = function(file) {
                    var div = document.createElement('div');
                    div.title = file.name;
                    div.innerHTML = '<label>0%</label> <progress></progress>';
                    appendDIV(div, fileProgress);
                    progressHelper[file.uuid] = {
                        div: div,
                        progress: div.querySelector('progress'),
                        label: div.querySelector('label')
                    };
                    progressHelper[file.uuid].progress.max = file.maxChunks;
                };

                connection.onFileEnd = function(file) {
                    progressHelper[file.uuid].div.innerHTML = '<a href="' + file.url + '" target="_blank" download="' + file.name + '">' + file.name + '</a>';
                };

                function updateLabel(progress, label) {
                    if (progress.position == -1) return;
                    var position = +progress.position.toFixed(2).split('.')[1] || 100;
                    label.innerHTML = position + '%';
                }

                function appendDIV(div, parent) {
                    if (typeof div === 'string') {
                        var content = div;
                        div = document.createElement('div');
                        div.innerHTML = content;
                    }

                    if (!parent) chatOutput.insertBefore(div, chatOutput.firstChild);
                    else fileProgress.insertBefore(div, fileProgress.firstChild);

                    div.tabIndex = 0;
                    div.focus();

                    chatInput.focus();
                }

                document.getElementById('file').onchange = function() {
                    connection.send(this.files[0]);
                };

                var chatOutput = document.getElementById('chat-output'),
                    fileProgress = document.getElementById('file-progress');

                var chatInput = document.getElementById('chat-input');
                chatInput.onkeypress = function(e) {
                    if (e.keyCode !== 13 || !this.value) return;
                    appendDIV(this.value);

                    // sending text message
                    connection.send(this.value);

                    this.value = '';
                    this.focus();
                };

                connection.connect();
            </script>
            
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
                <h2 class="header">How to use WebSync for Signaling?</h2>
                
                <pre>
// www.RTCMultiConnection.org/latest.js

var connection = new RTCMultiConnection();

// easiest way to customize what you need!
connection.session = {
    audio: true,
    video: true
};

// on getting local or remote media stream
connection.onstream = function(e) {
    document.body.appendChild(e.mediaElement);
};

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

connection.openSignalingChannel = function (config) {
    var channel = config.channel || this.channel;
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
};
// end-using WebSync for signaling
// ------------------------------------------------------------------

// check existing sessions
connection.connect();

// open new session
document.getElementById('open-new-session').onclick = function() {
    connection.open();
};
</pre>
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