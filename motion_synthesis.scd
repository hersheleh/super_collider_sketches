
s.boot;
s.quit
s.volume.gui;
s.plotTree;
s.scope;

(/*
	*/
SynthDef(\motion, {
	var sig, sig2, env, lfo, freq;
	freq = \freq.kr(400);
	env = XLine.kr(1, 0.01, \sustain.ir(1), doneAction: 2);
	sig = Pulse.ar(freq: freq) ;
	sig2 = Pulse.ar(freq: freq*2);
	sig = (sig + sig2) * env * \amp.ir(0.2);
	// lfo = LFTri.ar(0.02) * 0.2;
	// sig = sig * lfo;
	sig = Pan2.ar(sig, \pan.kr(0));
	Out.ar(bus: \out.kr(0), channelsArray: sig);
}).add;
)
(
a = Synth(\motion, [freq: 50]);
)
(
SystemClock.sched(5, {"hello".postln});
)

(
r = Routine({
	var delta;
	loop {
		delta = rrand(1,3) * 0.5;
		Synth(\motion, [
			freq: exprand(200, 800),
			amp: rrand(0.1, 0.5),
			sustain: delta * 0.8
		]);
		delta.yield;
	}
});
)
r.play;
r.reset;
r.stop;

TempoClock.default.sched(0, r);


(
t = Task({
	loop {
		[60, 62, 64, 65, 67, 69, 71, 72].do({
			arg midi;
			Synth(\motion, [freq: midi.midicps, amp: 0.2, sustain: 0.1]);
			0.125.wait;
		});
	}
}).play;
)

t.stop;

t.play;

t.stop