s.boot;
s.quit;


(
SynthDef.new(\saw, {
	arg freq=200, gate=1, offset=2, lpf=1500, amp=0.3, out=0;
	var sig, env;
	env = EnvGen.ar(
		Env.new(
			[0, 1,0.75 ,0.5, 0],
			[1, 1, 1 ,1],
			[-5, 5, -5, 4],
			3
		),
		gate,
		doneAction: 2
	);
	sig = Saw.ar(freq + [0, offset]);
	sig = LPF.ar(sig,lpf);
	sig = sig * amp;
	sig = sig * env;
 	Out.ar(out,sig);
}).add;
)

Window.closeAll;

x = Synth.new(\saw, [\freq, 100, \lpf,3000, \out, 0]);
x.set(\gate, 0);




(
e = Env.new(
	[0, 1,0.75 ,0.5, 0.5, 0a],
	[1, 1, 1, 2,1],
	[-5, 5, -5, -4, 4]
);

e.plot;
)

{SinOsc.ar(LFNoise0.kr(12, mul:600,add:1000), 0.1)}.play;

(
{
	RLPF.ar(Dust.ar([10,10]), LFNoise1.ar(1/[3,4], 1500, 1600), 0.02)
}.play;
)


3+4*3
3+(4*3)