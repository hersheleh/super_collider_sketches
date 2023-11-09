(
"Sampling DOT WAV".postln;
)

~aaah = Buffer.read(s, "/home/grish/hub/recording_bujo/sounds/aaah.wav")

(
SynthDef.new(\play, {
	var sig, env;
	sig = PlayBuf.ar(
		numChannels: 1,
		bufnum: \buf.kr(0),
		rate: BufRateScale.kr(\buf.kr()) * \rate.kr(1),
		startPos: \spos.kr(0),
		loop: 1,
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
	sig = sig * env;


	Out.ar(bus: \out.kr(0), channelsArray: sig)
}).add;
)
(

[ 0].do( { |n|
	//n =	n +	[12, 0, -12].choose;
	Synth.new(
		\play,
		[
			buf: ~aaah,
			rate: n.midiratio * [1, -1].choose,
			pan: rrand(-0.9, 0.9),
			spos: 0
		]
	);
});
)
(
r =	Routine.new({
	inf.do({
		[-7, -5, 2].do({ |n|
			Synth.new(\play, [buf: ~aaah, rate: n.midiratio]);
			0.5.yield;
		});
	});
});

)

(
r.next;
)
r.stop;
s.plotTree;
s.meter;