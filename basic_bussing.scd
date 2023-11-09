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
(
SynthDef(\reverb, {
	var sig;
	sig = In.ar(bus: \in.ir(0), numChannels: 2);
	sig = FreeVerb2.ar(sig[0], sig[1], mix: 0.3, room: 0.99);
	Out.ar(\out.ir(0), sig);
}).add;
)
(
SynthDef(\mic,{
	var sig;
	sig = In.ar(bus: \in.ir(0), numChannels: 2);
	Out.ar(\out.ir(0), sig);
}).add;
)

Synth(\mic, [in: 2, out: ~reverbBus]);

Synth(\reverb, [in: ~reverbBus, out: 0]);
Synth(\slide_synth, [out: ~reverbBus]);

(~reverbBus = Bus.audio(s, 2);)