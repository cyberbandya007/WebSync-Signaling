﻿<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="DataChannel.aspx.cs" Inherits="SignalingServer.DataChannel" %>

<!--
    > Muaz Khan     - https://github.com/muaz-khan 
    > MIT License   - https://www.webrtc-experiment.com/licence/
    > Documentation - https://github.com/muaz-khan/WebRTC-Experiment/tree/master/DataChannel
-->

<!DOCTYPE html>
<html lang="en">
    <head>
        <title>DataChannel.js » A WebRTC Library for Data Sharing & WebSync as Signaling GateWay!</title>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=no">
        <link rel="author" type="text/html" href="https://plus.google.com/+MuazKhan">
        <meta name="author" content="Muaz Khan">
        <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
        <link href="https://fonts.googleapis.com/css?family=Inconsolata" rel="stylesheet" type="text/css" />
        <link rel="stylesheet" href="//www.webrtc-experiment.com/style.css">
        <style>
            #chat-output div, #file-progress div {
                border: 1px solid black;
                border-bottom: 0;
                padding: .1em .4em;
            }

            input {
                border: 1px solid black;
                font-family: inherit;
                font-size: 1em;
                margin: .1em .3em;
                outline: none;
                padding: .1em .2em;
                width: 97%;
            }

            #chat-output, #file-progress {
                margin: 0 0 0 .4em;
                max-height: 12em;
                overflow: auto;
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
		
        <!-- DataChannel.js library -->
        <script src="//www.webrtc-experiment.com/DataChannel.js"> </script>
    </head>

    <body>
        <article>
            <header style="text-align: center;">
                <h1>
                    <a href="https://github.com/muaz-khan/WebRTC-Experiment/tree/master/DataChannel" target="_blank">DataChannel.js</a>
                    » A WebRTC Library for Data Sharing
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
                    <h2 style="border: 0; padding-left: .5em;">Open New DataChannel Connection</h2>
                    <button id="open-channel">Open</button>
                </section>

                <table style="width: 100%;" id="channels-list"></table>
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
                var channel = new DataChannel();
                // DataChannel.js

                // "ondatachannel" is fired for each new data channel
                channel.ondatachannel = function(channel00) {
                    var alreadyExist = document.getElementById(channel00.id);
                    if (alreadyExist) return;

                    var tr = document.createElement('tr');
                    tr.setAttribute('id', channel00.owner);
                    tr.innerHTML = '<td>' + channel00.id + '</td>' +
                        '<td><button class="join" id="' + channel00.id + '">Join</button></td>';

                    channelsList.insertBefore(tr, channelsList.firstChild);

                    // when someone clicks table-row; joining the relevant data channel
                    tr.onclick = function() {

                        // manually joining a data channel
                        channel.join({
                            id: this.querySelector('.join').id,
                            owner: this.id
                        });

                        channelsList.style.display = 'none';
                    };
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

                channel.openSignalingChannel = function(config) {
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

                // a text message or data
                channel.onmessage = function(data, userid, latency) {
                    appendDIV(data);

                    console.debug(userid, 'posted', data);
                    console.log('latency:', latency, 'ms');
                };

                // on data connection gets open
                channel.onopen = function() {
                    if (document.getElementById('chat-input')) document.getElementById('chat-input').disabled = false;
                    if (document.getElementById('file')) document.getElementById('file').disabled = false;
                    if (document.getElementById('open-channel')) document.getElementById('open-channel').disabled = true;
                };

                // sending/receiving file(s)
                // channel.autoSaveToDisk = false;
                channel.onFileProgress = function(packets, uuid) {
                    appendDIV(uuid + ': ' + packets.remaining + '..', 'file', fileProgress);
                };

                channel.onFileSent = function(file) {
                    appendDIV(file.name + ' sent.', fileProgress);
                };

                channel.onFileReceived = function(fileName) {
                    appendDIV(fileName + ' received.', fileProgress);
                };

                document.getElementById('file').onchange = function() {
                    channel.send(this.files[0]);
                };

                var chatOutput = document.getElementById('chat-output'),
                    fileProgress = document.getElementById('file-progress');

                function appendDIV(data, parent) {
                    var div = document.createElement('div');
                    div.innerHTML = data;

                    if (!parent) chatOutput.insertBefore(div, chatOutput.firstChild);
                    else fileProgress.insertBefore(div, fileProgress.firstChild);

                    div.tabIndex = 0;
                    div.focus();

                    chatInput.focus();
                }

                var chatInput = document.getElementById('chat-input');
                chatInput.onkeypress = function(e) {
                    if (e.keyCode !== 13 || !this.value) return;
                    appendDIV(this.value);

                    // sending text message
                    channel.send(this.value);

                    this.value = '';
                    this.focus();
                };

                // users presence detection
                channel.onleave = function(userid) {
                    var message = 'A user whose id is ' + userid + ' left you!';
                    appendDIV(message);
                    console.warn(message);
                };

                var channelsList = document.getElementById('channels-list');

                // data-channel name to uniquely identify your connection
                var channel_name = location.hash.substr(1) || 'data-channel';

                document.getElementById('open-channel').onclick = function() {
                    this.disabled = true;

                    // opening new data channel
                    channel.open(channel_name);
                };

                // searching for existing channels
                channel.connect(channel_name);
            </script>
		
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
var channel = new DataChannel();

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

channel.openSignalingChannel = function (config) {
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
channel.connect('channel-name');

// open new session
document.getElementById('open-new-session').onclick = function() {
    channel.open('channel-name');
};
</pre>
            </section>
			
            <section class="experiment">
                <h2 class="header">DataChannel.js Features:</h2>
                <ol>
                    <li>Direct messages — to any user using his `user-id`</li>
                    <li>Eject/Reject any user — using his `user-id`</li>
                    <li>Leave any room (i.e. data session) or close entire session using `leave` method</li>
                    <li>File size is limitless!</li>
                    <li>Text message length is limitless!</li>
                    <li>Size of data is also limitless!</li>
                    <li>Fallback to firebase/socket.io/websockets/etc.</li>
                    <li>Users' presence detection using `onleave`</li>
                    <li>Latency detection</li>
                    <li>Multi-longest strings/files concurrent transmission</li>
                </ol>
            </section>
			
            <section class="experiment">
                <h2 class="header">How to use DataChannel.js?</h2>
                <pre>
&lt;script src="https://www.webrtc-experiment.com/DataChannel.js"&gt; &lt;/script&gt;

&lt;input type="text" id="chat-input" disabled 
       style="font-size: 2em; width: 98%;"&gt;&lt;br /&gt;
&lt;div id="chat-output"&gt;&lt;/div&gt;

&lt;script&gt;
    var chatOutput = document.getElementById('chat-output');
    var chatInput = document.getElementById('chat-input');
    chatInput.onkeypress = function(e) {
        if (e.keyCode != 13) return;
        channel.send(this.value);
        chatOutput.innerHTML = 'Me: ' + this.value + '&lt;hr /&gt;' 
                             + chatOutput.innerHTML;
        this.value = '';
    };
&lt;/script&gt;

&lt;script&gt;
    var channel = new DataChannel('Session Unique Identifier');

    channel.onopen = function(userid) {
        chatInput.disabled = false;
        chatInput.value = 'Hi, ' + userid;
        chatInput.focus();
    };

    channel.onmessage = function(message, userid) {
        chatOutput.innerHTML = userid + ': ' + message + '&lt;hr /&gt;' 
                             + chatOutput.innerHTML;
    };

    channel.onleave = function(userid) {
        chatOutput.innerHTML = userid + ' Left.&lt;hr /&gt;' 
                             + chatOutput.innerHTML;
    };
&lt;/script&gt;
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
    </body>
</html>