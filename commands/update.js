var fs = require("fs"),
    cp = require('child_process'),
    Promise = require('node-promise').Promise,
    all = require("node-promise").all,
    strftime = require("strftime"),
    batteryLevel = require('battery-level');

var getActiveWindow = function(){
    var awPromise = new Promise();
    var script = "~/Library/Application\\ Support/Übersicht/widgets/bar/scripts/screens";

    cp.exec(script, function(err, stdout, stderr){
        awPromise.resolve(stdout.replace("\n", "") || stderr);
    });

    return awPromise;
};

var iTunesPlaying = function(){
    var promise = new Promise();
    var state = {
        track: "",
        playing: false,
        source: "iTunes"
    };

    var playingCmd = "osascript -e 'tell application \"iTunes\"' -e 'set whatshappening to (get player state as string)' -e 'end tell'";
    var songCmd = "osascript -e 'tell application \"iTunes\"' -e '(get name of current track) & \"\n\" & (get artist of current track)' -e 'end tell'";

    cp.exec(playingCmd, function(err, stdout, stderr) {
        if (err || stderr) {
            return promise;
        }

        if (stdout == "playing\n") {
            state.playing = true;

            cp.exec(songCmd, function(err, stdout, stderr) {
                var a = stdout.split('\n');

                state.track = a[1].replace('\n', '') + ' - ' + a[0].replace('\n', '');

                promise.resolve(state);
            });
        } else {
            promise.resolve(state);
        }
    });

    return promise;
};

// fill in static things without promises
var playing = {
    date: strftime("%a %d %b"),
    time: strftime("%l:%M"),
    active: "⌘"
};

var promises = [
    batteryLevel(),
    iTunesPlaying(),
    getActiveWindow()
];

// gather all info as all the functions have returned data
var p = all(promises);

p.then(function(data) {
    playing.battery = data[0] * 100;
    playing.music = data[1];
    playing.active = data[2];

    console.log(JSON.stringify(playing));
});

