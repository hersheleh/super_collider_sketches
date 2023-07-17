(
"Hi" ! 100;
)

(
~fn = {
	arg amp = 0.2;
	var sig, mod;
	mod = SinOsc.kr(freq: 1/4, phase: 3pi/2, mul: 0.5, add: 0.5);
	sig = PinkNoise.ar(amp ! 2);
	sig = sig * mod;
};

~pinkSin = {
	var sig0, sig1, sig;
	sig1 = SinOsc.ar(900, mul: 0.1 ! 2);
	sig0 = PinkNoise.ar(0.2 ! 2);
	sig = sig0 + sig1;
};

)

~pinkSin.play;


(
SynthDef.new(\tone, {
	arg gate = 1;
	var sig, env;
	sig = SinOsc.ar(400) ! 2;
	env = EnvGen.kr(
		Env(
			[0, 1, 0.3, 0],
			[0.02, 0.3, 1],
			[-2, -4, -4],
			2
		),
	gate,
		doneAction: 2
	);
	sig = sig * env;
	Out.ar(0, sig);
}).add;
)

x = Synth.new(\tone, [gate: 1, freq: 60.midicps, amp: -12.dbamp]);

s.plotTree;

x.set(\gate, 0);

b = Buffer.read(s, "/home/grish/hub/recording_bujo/sounds/what.wav");
b.query;
b.sampleRate;
s.sampleRate;
b.play;
b.query;
b.plot;

(
SynthDef.new(\play, {
	var sig, env;

	sig = PlayBuf.ar(
		numChannels: 1,
		bufnum: \buf.kr(0),
		rate: BufRateScale.kr(\buf.kr()) * \rate.kr(1),
		startPos: \spos.kr(0),
		loop: 1,
		doneAction: 2
	);

	env = EnvGen.kr(
		Env(
			[0 , 1, 0, 1],
			[0, 1, 2]
		),
		doneAction: 0
	);
	sig = sig * env;
	Out.ar(\out.kr(0), sig)
}).add
)
(
Synth.new(\play,
	[
		buf: b.bufnum,
		amp: 3.0,
		spos: s.sampleRate * 1
	]);
)
s.scope;
b.bufnum;
s.plotTree;
s.boot;
s.quit;
s.meter;
s.makeGui;

