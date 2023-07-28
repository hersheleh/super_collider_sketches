// Recreate the sound of a lap steal guitar
"Hello".postln;
(// A Basic Subtractive synth ----------------------------------------------
SynthDef.new(\sub_synth, {
	var sig, env;
	sig = Saw.ar(Lag.kr(\freq.kr(440), 2));
	env = EnvGen.kr(
		Env(
			levels: [20, 20000, 20],
			// times: [\atk.kr(0.5), \rel.kr(2)],
			times: [1, 0.5],
			curve: [6, -6]
		),
		// doneAction: 2
	);
	// sig = LPF.ar(sig, env.clip(20, 20000));
	sig = Pan2.ar(sig, \pan.kr(0), \amp.kr(0.3));
	sig = sig * \amp.kr(0.3);
	Out.ar(bus: \out.kr(0), channelsArray: sig);
}).add;
)
(

)
~so.set(\freq, 300)
(
rrand(5.0, 0);
)
(
r = Routine.new({
	~sound = Synth.new(\sub_synth, [freq: 440, cut: 1000, amp: 0.2]);
	inf.do({
		arg n;
		n = [0, 2, 3, 5, 7, 8, 11, 12].choose;
		~sound.set(\sub_synth, [\freq, 440 * n.midiratio]);
		(440 * n.midiratio).postln;
		0.5.yield;
	});
});
)

(
r.next;
)

s.quit;
~a_sub.set(\cut, 20000);
// -----------------------------------------------------------------------------


//	Play AAAH from Audio Buffer ------------------------------------------------
~aaah = Buffer.read(s, "/home/grish/hub/recording_bujo/sounds/aaah.wav")
(
SynthDef.new(\play, {
	var sig, env;
	sig = PlayBuf.ar(
		numChannels: 1,
		bufnum: \buf.kr(0),
		rate: BufRateScale.kr(\buf.kr()) * \rate.kr(1),
		startPos: \spos.kr(0),
		loop: 0,
	);
	env = EnvGen.kr(
		Env(
			levels: [0, 1, 0],
			times: [\atk.ir(0), \rel.ir(2.5)],
			curve: [-2, -4]
		),
		doneAction: 2
	);
	sig = Pan2.ar(sig, \pan.kr(0));
	// sig = sig * env;
	sig = sig * \amp.ir(1);
	Out.ar(bus: \out.kr(0), channelsArray: sig);
}).add;
)
(
[-3, 0, 4].do({
	arg n;
	n = n +	[12, 0, -12].choose();
	Synth.new(
	\play,
	[
		buf: ~aaah,
		rate: n.midiratio,
		pan: rrand(-0.9, 0.9),
		spos: 0,
		amp: 6

	]
	);
});
) // -------------------------------------------------------------------------------------
(
p =	Pseq(
	list: [
		20000,
		10000,
		800,
		600,
		300,
		200]);
q = p.asStream;
)

(
"Hello".postln;
)

~a_sub.set(\cut, q.next);
q.reset;
