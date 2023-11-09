Env([440, 440, 440], [0, 1], 2).plot
(
SynthDef.new(\slide_synth, {
	arg freq = 440, old_freq = 440, t_freq_gate = 0,
	env_done = Done.kr(freq_env);
	var sig, amp_env, freq_env, dir = 1;
	var diff = freq - old_freq;
	dir = Select.kr(diff < 0, [1, -1]);

	freq_env =  EnvGen.kr(
		envelope: Env(
			levels: [
				old_freq,
				freq * (dir * \slide.kr(0)).midiratio,
				freq
			],
			times: [\slide_atk.kr(0), \slide_rel.kr(0)],
			curve: [2]
		),
		gate: t_freq_gate,
	);

	amp_env = EnvGen.kr(
		envelope: Env(
			levels:	[0, 1, 0],
			times: [\atk.kr(0.5), \rel.kr(0.7)],
			curve: [2, -2],
			// releaseNode: 1
		),
		gate: \t_gate.kr(1),
		// doneAction: 2
	);
	sig = Saw.ar(freq: freq_env); // osc
	sig = sig + Saw.ar(freq: freq_env + 5); // offset osc
	// sig = sig + Saw.ar(freq: freq_env / 4); // sub-osc
	sig = LPF.ar(sig, 600.clip(20, 20000)); // Filter
	sig = sig * amp_env; //	Amp Envelope
	sig = sig * \amp.kr(0.3); // Amplitude
	sig = Pan2.ar(sig, \pan.kr(0)); // Panning
	Out.ar(bus: \out.kr(0), channelsArray: sig);
}).add;
)
s.options.numInputBusChannels_(4);
s.reboot;
s.meter;
s.scope;
s.plotTree;
a = Synth(\slide_synth, [\freq, 440, \old_freq, 220]);
a.set(\freq, 660, \old_freq, 440, \t_freq_gate, 1, \t_gate, 1);
// (Env.shapeNumber(\))

a.get(\freq, {arg value; value.postln});



(
~old_freq =	440;
~slide = {
	arg freq, synth;
	synth.set(\old_freq, ~old_freq, \freq, freq, \t_freq_gate, 1);
	~old_freq.postln;
	freq.postln;
	~old_freq = freq;
	// SystemClock.sched(1, {synth.set(\t_freq_gate, 0)});
}
)
a = Synth(\slide_synth);
~slide.value(\old_freq, ~old_freq, \freq, 660);
s.plotTree;
a.free
a.get(\env_done, {arg value; value.postln});
a.free;

/*

*/

(
~ro = Routine.new({
	arg tonic;
	[-2, 0, 3].do({ arg n;
		r = ~slide.value(tonic*n.midiratio, a);
		(tonic * n.midiratio).yield;
	});
});
)

s.freqscope;

(
var tonic = midicps(55);
a = Synth(\slide_synth,
[
	\slide, 0.5,
	\slide_atk, 0.2,
	\slide_rel, 0.4,
	\old_freq, tonic * (-0.5.midiratio),
	\freq, tonic * (-0.5.midiratio),
	\atk, 0.4,
	\rel, 2,
	\t_freq_gate, 1
]);
)
[[1, 2], [3]].do({arg n; n[0].postln});

(
~blue_notes = Routine.new({
	arg tonic;
	[[0, 0], [3, 0.5], [0, 0]].do({
		arg n;
		Synth(\slide_synth,
			[
				\slide, 0,
				\slide_atk, 0,
				\slide_rel, 0.4,
				\old_freq, tonic * (n[0] - n[1]).midiratio,
				\freq, tonic * (n[0] + n[1]).midiratio,
				\atk, 0.4,
				\rel, 3,
				\t_freq_gate, 1
			]);
		2.yield;
	});
});
)
(~blue_notes.value(midicps(55)))
~blue_notes.reset;

(r = ~slide.value(440*(10).midiratio, a);)
b.free
~ro.value(440);
a.get(\freq, {|n| n.postln});
~ro.reset;

r = ~slide.value(800, a);
r = ~slide.value(1000, a);

~port.reset;

a.get(\freq, {arg value; value.postln});
a.get(\t_freq_gate, {arg value; value.postln});

s.scope;
s.freqscope;