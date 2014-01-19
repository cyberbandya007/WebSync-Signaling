﻿<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="file-hangout.aspx.cs" Inherits="SignalingServer.file_hangout" %>

<!--
    > Muaz Khan     - https://github.com/muaz-khan 
    > MIT License   - https://www.webrtc-experiment.com/licence/
    > Experiments   - https://github.com/muaz-khan/WebRTC-Experiment/tree/master/file-hangout
-->
<!DOCTYPE html>
<html lang="en">
    <head>
        <title>WebRTC Group File Sharing using RTCDataChannel APIs! & WebSync as Signaling GateWay!</title>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=no">
        <link rel="author" type="text/html" href="https://plus.google.com/+MuazKhan">
        <meta name="author" content="Muaz Khan">
        <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
        <link href="//fonts.googleapis.com/css?family=Inconsolata" rel="stylesheet" type="text/css" />
        <link rel="stylesheet" href="//www.webrtc-experiment.com/style.css">
        
        <style>
            p { padding: .8em; }

            input {
                border: 1px solid #d9d9d9;
                border-radius: 1px;
                font-size: 2em;
                margin: .2em;
            }

            li {
                border-bottom: 1px solid rgb(189, 189, 189);
                border-left: 1px solid rgb(189, 189, 189);
                padding: .5em;
            }

            code {
                color: red;
                font-family: inherit;
            }
        </style>
        <script>
            document.createElement('article');
            document.createElement('footer');
        </script>
    </head>

    <body>
        <article>
            <header style="text-align: center;">
                <h1>
                    <a href="https://github.com/muaz-khan/WebRTC-Experiment/tree/master/file-hangout" target="_blank">WebRTC Group File Sharing</a> using RTCDataChannel APIs!
                    & WebSync as Signaling GateWay!
                </h1>            
                <p>
                    <span>© 2013</span>
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
			
            <section class="experiment">
                <p>
                    A file-hangout experiment where all participants can share files in a group!
                </p>
                <table style="width: 100%;">
                    <tr>
                        <td>
                            <input type="button" value="Start sharing files in Group!" id="start-conferencing">
                            <input type="file" id="file" disabled>

                            <div id="status" style="color: red; font-size: 1em;"></div>
                            <table id="participants"></table>
                            <table id="rooms-list" class="visible"></table>
                        </td>
                        <td>
                            <table id="output-panel"></table>
                        </td>
                    </tr>
                </table>
			
                <table class="visible">
                    <tr>
                        <td style="text-align: center;">
                            <strong>Private file-hangout</strong> ?? <a href="https://www.webrtc-experiment.com/file-hangout/" target="_blank" title="Open this link in new tab. Then your file-hangout will be private!"><code>/file-hangout/<strong id="unique-token">#123456789</strong></code></a>
                        </td>
                    </tr>
                </table>
            </section>
            
            <section class="experiment">
                <p style="margin-top: 0;">
                    You can try <a href="https://www.webrtc-experiment.com/WebRTC-File-Sharing/">SCTP based WebRTC File Sharing Demo</a>!
                </p>
            </section>
             
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
                <h2 class="header">How <a href="https://github.com/muaz-khan/WebRTC-Experiment/tree/master/file-hangout" target="_blank">file-sharing</a> experiment works?</h2>
                <ol>
                    <li>Multi-peers for group data connectivity</li>
                    <li>Multip-sockets for group offer/answer exchange</li>
                    <li>Multi SCTP/RTP data ports on single chrome/firefox instance</li>
                    <li>Custom file sharing implementation for chrome</li>
                    <li>In reality, it is peer-to-peer-to-peers....</li>
                </ol>

                <p>Interested to learn <a href="https://www.webrtc-experiment.com/docs/how-file-broadcast-works.html"
                                          target="_blank">how to share files using RTCDataChannel APIs?</a></p>
            </section>
            
            <section class="experiment">
                <h2 class="header">Suggestions</h2>
                <ol>
                    <li>
                        If you're newcomer, newbie or beginner; you're suggested to try <a href="https://github.com/muaz-khan/WebRTC-Experiment/tree/master/RTCMultiConnection" target="_blank">RTCMultiConnection.js</a> or <a href="https://github.com/muaz-khan/WebRTC-Experiment/tree/master/DataChannel" target="_blank">DataChannel.js</a> libraries.
                    </li>
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
		
        <!-- WebSync -->
        <script src="/Scripts/fm.js"> </script>
        <script src="/Scripts/fm.websync.js"> </script>
        <script src="/Scripts/fm.websync.subscribers.js"> </script>
        <script src="/Scripts/fm.websync.chat.js"> </script>
        
        <!-- script used for file-sharing -->
        <script src="/Scripts/file-hangout.js" async> </script>
    
        <!-- commits.js is useless for you! -->
        <script src="//www.webrtc-experiment.com/commits.js" async> </script>
        
        <!-- somee.com hack! -->
        <style>center, .last-div, .last-div ~ * { display: none !important }</style>
        <div class="last-div"></div>
    </body>
</html>