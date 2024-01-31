(
    s.waitForBoot({
        var s = Server.default;
        var notesOn = Dictionary.new();
        var bufs = Dictionary.new();
        bufs.put("sine", Buffer.alloc(s, 512, 1));
        bufs.at("sine").sine2([2], [0.5], false); // https://ableton-production.imgix.net/manual/en/Saturator.png?auto=compress%2Cformat&w=716
        bufs.at("sine").plot;

        SynthDef("supersaw0", {
            arg note;
		var input, mix, shift1, shift2, shift3, shift4, shift5, comp1, comp2, comp3, comp4, comp5, output;
        var snd;
        var freq = [note - LFNoise2.kr(1 / 3).range(0, 0.02), note + LFNoise2.kr(1 / 3).range(0, 0.02)].midicps;
        input = LFSaw.ar(freq);
        snd = {
            var shift = LFSaw.ar(Rand(2.1, 7) * rrand(1, 5) / 10);
            var comp = input > shift;
			(input - comp) * LinLin.kr(note, 36, 90, 0.5, 1.1);
    }!2;
snd = Mix.new(snd);
snd = snd - input;
snd = LeakDC.ar(snd * 0.5) / 10;
snd = RLPF.ar(snd, Clip.kr(MouseY.kr(1, 30) * freq, 100, 20000), 0.707);
snd = Pan2.ar(snd, LFNoise2.kr(1 / 3, 0.5));
snd = snd * EnvGen.ar(Env.adsr(Rand(1, 4), Rand(0.5, 2), Rand(0.7, 1), Rand(1, 3)), EnvGen.kr(Env.new([1, 1, 0], [Rand(7, 9), 0.1])), doneAction: 2);
Out.ar(0, snd * 10.neg.dbamp);

	}).add;

SynthDef("supersaw1", {
    arg note=60;
    var freq = (note + Rand(-0.01, 0.01)).midicps;
    var mix = MouseX.kr();
    var detune = MouseY.kr();
    var detuneCurve = { | x |
        (10028.7312891634 * x.pow(11)) -
        (50818.8652045924 * x.pow(10)) +
        (111363.4808729368 * x.pow(9)) -
        (138150.6761080548 * x.pow(8)) +
        (106649.6679158292 * x.pow(7)) -
        (53046.9642751875 * x.pow(6)) +
        (17019.9518580080 * x.pow(5)) -
        (3425.0836591318 * x.pow(4)) +
        (404.2703938388 * x.pow(3)) -
        (24.1878824391 * x.pow(2)) +
        (0.6717417634 * x) +
        0.0030115596
};
var centerGain = { | x | (-0.55366 * x) + 0.99785 };
var sideGain = { | x | (-0.73764 * x.pow(2)) + (1.2841 * x) + 0.044372 };

var center = LFSaw.ar(freq, Rand());
var freqs = [
    (freq - (freq * (detuneCurve.(detune)) * 0.11002313)),
    (freq - (freq * (detuneCurve.(detune)) * 0.06288439)),
    (freq - (freq * (detuneCurve.(detune)) * 0.01952356)),
    //(freq + (freq*(detuneCurve.(detune))*0)),
    (freq + (freq * (detuneCurve.(detune)) * 0.01991221)),
    (freq + (freq * (detuneCurve.(detune)) * 0.06216538)),
    (freq + (freq * (detuneCurve.(detune)) * 0.10745242))
];
var side = Mix.fill(6, { | n |
    LFSaw.ar([freqs[n] * 0.99, freqs[n] * 1.005], Rand(0, 2)) / 6.0
		});

var sig = (center * centerGain.(mix)) + (side * sideGain.(mix));

sig = HPF.ar(sig, freq);
sig = RLPF.ar(sig, MouseY.kr(10, 18000, 1), 0.707);
sig = Pan2.ar(sig, LFNoise2.kr(1 / 3, 0.4));
sig = sig * EnvGen.ar(Env.adsr(Rand(1, 4), Rand(0.5, 2), Rand(0.7, 1), Rand(1, 3)), EnvGen.kr(Env.new([1, 1, 0], [Rand(7, 9), 0.1])), doneAction: 2);
Out.ar(0, sig * 28.neg.dbamp);
	}).add;

SynthDef("supersaw2", {
    arg note=60;
    var snd;
    var freq = (note + Rand(-0.02, 0.02)).midicps;
    snd = SawDPW.ar(freq * ((-3..2) * 0.05).midiratio * [1, 2, 1, 4, 1, 2]);
snd = RLPF.ar(snd, LFNoise2.kr(0.3! snd.size).linexp(-1, 1, 100, 8000), 0.3);
snd = Splay.ar(snd);
snd = Pan2.ar(snd, LFNoise2.kr(1 / 3, 0.4));
snd = snd * EnvGen.ar(Env.adsr(Rand(1, 4), Rand(0.5, 1), Rand(0.7, 1), Rand(1, 3)), EnvGen.kr(Env.new([1, 1, 0], [Rand(7, 9), 0.1])), doneAction: 2);
Out.ar(0, snd * 24.neg.dbamp);
	}).add;

SynthDef("out", {
    arg sine_buf;
    var snd = In.ar(0, 2);
    var snd2, sndD;
    var shimmer = LFNoise2.kr(1 / 5).range(0, 0.5);
    snd=SelectX.ar(LFNoise2.kr(1 / 3).range(0, 0.5), [snd, Shaper.ar(sine_buf, snd)]);
    snd = AnalogTape.ar(snd / 4, 0.7, 0.7, 0.7, 1);
    sndD = (snd * 30.dbamp).tanh * -10.dbamp;
sndD = BHiShelf.ar(BLowShelf.ar(sndD, 200, 1, -10), 3000, 1, -10);
sndD = (sndD * 10.dbamp).tanh * -10.dbamp;
sndD = BHiShelf.ar(BLowShelf.ar(sndD, 300, 1, 10), 3000, 1, 10);
sndD = sndD * -10.dbamp;
snd = SelectX.ar(LFNoise2.kr(1 / 3).range(0, 0.5), [snd, sndD]);
snd2 = DelayN.ar(snd, 0.03, 0.03);
snd2 = snd2 + PitchShift.ar(snd, 0.13, 2, 0, 1, 1 * shimmer / 2);
snd2 = snd2 + PitchShift.ar(snd, 0.1, 4, 0, 1, 0.5 * shimmer / 2);
snd2 = snd2 + PitchShift.ar(snd, 0.1, 8, 0, 1, 0.125 * shimmer / 2);
snd = SelectX.ar(LFNoise2.kr(1 / 3).range(0, 1), [snd, snd2]);
snd = SelectX.ar(LFNoise2.kr(1 / 3).range(0.7, 0.9), [
    snd,
    Fverb.ar(snd2[0], snd2[1],
        predelay: 200,
        tail_density: LFNoise2.kr(1 / 3).range(70, 90),
        decay: LFNoise2.kr(1 / 3).range(70, 90))
]);
ReplaceOut.ar(0, snd);
	}).add;

	Routine {
    s.sync;
    o.free;
    Synth.tail(s, "out", [\sine_buf, bufs.at("sine")]);
    o = OSCFunc({
        arg msg, time, addr, recvPort;
        var note_on = msg[1].asInteger;
        var note_off = msg[2].asInteger;
        [note_on].postln;
        Synth.head(s, "supersaw"++(3.rand), [\note, msg[1].asInteger + 12]);
    Synth.head(s, "supersaw"++(2.rand), [\note, msg[1].asInteger + 0]);
    Synth.head(s, "supersaw"++(2.rand), [\note, msg[1].asInteger - 12]);
}, '/play_note');
	}.play;

});

)
