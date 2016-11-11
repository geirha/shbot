var util = require('util'),
    EventEmitter = require('events').EventEmitter,
    blessed = require('blessed');

function UserInterface() {
    if (!(this instanceof UserInterface))
        return new UserInterface();
    var self = this;
    this.screen = blessed.screen({smartCSR: true});

    this.log = blessed.Log({
        top: 0,
        left: 'center',
        width: '100%',
        height: '100%-3',
        border: { type: 'line' },
    });

    this.input = blessed.Textbox({
        bottom: 0,
        left: 'center',
        width: '100%',
        height: 3,
        border: { type: 'line' },
    });

    this.input.on('focus', function() {
        self.input.readInput(onInput);
    });
    this.input.key(['escape', 'C-c'], function(ch, key) { process.exit(0); });

    function onInput(err, value) {
        if (err) {
            self.log.pushLine("-> Error: " + JSON.stringify(error));
        }
        self.log.pushLine('-> ' + value);
        self.emit('line', value);
        self.input.clearValue();
        self.screen.render();
        self.input.readInput(onInput);
    }
        
    this.screen.append(this.log);
    this.screen.append(this.input);

    this.input.focus();
    this.screen.render();
}
util.inherits(UserInterface, EventEmitter);

module.exports = UserInterface;
