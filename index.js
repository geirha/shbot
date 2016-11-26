#!/usr/bin/env node

var irc = require('irc'),
    settings = require('./settings.js'),
    child_process = require('child_process'),
    bless = require('./bless'),
    util = require('util');

var ui = bless();
console.log = function() {
    ui.log.pushLine(util.format.apply(util, arguments));
};

console.error = function() {
    ui.log.pushLine(util.format.apply(util, arguments));
};


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

function timestamp() {
    var d = new Date();
    return [
        ('0'+d.getHours()).slice(-2),
        ('0'+d.getMinutes()).slice(-2),
        ('0'+d.getSeconds()).slice(-2)
    ].join(':');
}

var client = new irc.Client(settings.server, settings.nick, settings.irc);

client.addListener('error', function(err) {
    console.log("error: ", err);
});
function pad(s, n) {
    if ( s.length < n )
        s = (new Buffer(n).fill(' ').toString() + s).slice(-n)
    return s;
}
client.addListener('message', function(from, to, message) {
    console.log(timestamp() + " %s <%s> %s", pad(to, 10), pad(from, 10), message);
});
client.addListener('kill', function(nick, reason, channels, message) {
    console.log("kill", nick, reason, channels, message);
});
client.addListener('registered', function(message) {
    console.log("registered", message);
});

client.addListener("raw", function(message) {
    switch (message.command) {
        case "900": // You are now logged in as <userName>
            console.log(message.args[3]);
            break;
    }
});

client.addListener("ping", function(server) {
    console.log(server,"ping");
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


ui.on('line', function(value) {
    var match;
    if ( match = value.match(/^say\s+([^\s]+)\s(.*)/) ) {
        client.say(match[1], match[2]);
    }
    else if ( match = value.match(/^nick\s+(.+)/) ) {
        client.send('NICK', match[1]);
    }
    else if ( match = value.match(/^(join|part)\s+(.+)/) ) {
        if ( match[1] === 'join')
            client.join(match[2]);
        else if ( match[1] === 'part')
            client.part(match[2]);
    }
    else if ( match = value.match(/^(re|dis)?connect$/) ) {
        if (match[0] === 'disconnect')
            client.disconnect();
        else
            client.connect(0);
    }
    else {
        console.log("Unknown command");
    }
});
