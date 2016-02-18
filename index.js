#!/usr/bin/env node

var irc = require('irc'),
    settings = require('./settings.js'),
    child_process = require('child_process');

function evalcmd(trigger, command, target, nick) {
    var prefix = "";
    if (nick) 
        prefix = nick+": ";

    // sanitize input
    command = command.replace(/\1/g,"");

    var proc = child_process.spawn('./evalcmd', [ trigger, command ]);
    var prev = "";
    var lines = [];
    proc.stdout.on('data', function(chunk) {
        lines = (prev + chunk).split('\n');
        prev = lines.pop();
        lines.forEach(function(line) {
            client.say(target, prefix + line);
        });
    });
    proc.stdout.on('end', function() {
        if (prev)
            client.say(target, prefix + prev);
    });
    proc.on('close', function(code) {
        console.log(trigger+"# "+command + " # exit code "+ code);
    });
}

var client = new irc.Client(settings.server, settings.nick, settings.irc);

client.addListener('error', function(err) {
    console.log("error: ", err);
});
client.addListener('message', function(from, to, message) {
    console.log("message: ", from, to, message);
});

client.addListener("raw", function(message) {
    switch (message.command) {
        case "900": // You are now logged in as <userName>
            console.log(message.args[3]);
            break;
        case "MODE":
            if (message.args[0] === "shbot" && message.args[1] === "+i")
                client.say("geirha", "I am alive");
            break;
    }
});

client.addListener('message#', function(nick, channel, text, message) {
    if (nick === client.nick)
        return;

    var m;
    if (text === "# botsnack")
        client.say(channel, "Core dumped");
    else if (text === "# botsmack")
        client.say(channel, "Segmentation fault");
    else if (m = text.match(/^([^ #]*)# (.*)/))
        evalcmd(m[1], m[2], channel, nick);
});


client.addListener('pm', function(nick, text, message) {
    if (nick === client.nick)
        return;

    var m;
    if (text === "# botsnack")
        client.say(nick, "Core dumped");
    else if (text === "# botsmack")
        client.say(nick, "Segmentation fault");
    else if (m = text.match(/^([^ #]*)# (.*)/))
        evalcmd(m[1], m[2], nick);
    else 
        evalcmd("", text, nick);
});
