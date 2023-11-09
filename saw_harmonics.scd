(
~hrmncs = {
	arg num = 1, freq=100;
	var sig = SinOsc.ar(200,mul:0);
	for(1,8,
		{
			arg value;
			value.postln;
			sig = sig + SinOsc.ar(
				freq: freq*value,
				mul: 0.5/value;
			);
		}
	);
	sig!2;
}.play;
)
//Saw.ar(100)*

{Saw.ar(100)*[1,1];}.play



(
SynthDef.new(\harmonic, {
	var sig, mul = 1;
	sig = SinOsc.ar(
		freq: \freq.kr(100)*\part.kr(1),
		mul: 0.1*1/\part.kr(1)
	)!2;

	Out.ar(0, sig);
}).add;)

 s.volume.gui;


(
(1..20).do(
{
	arg value;
	Synth.new(
		\harmonic,
		[\freq, 400, \part, value]
	);
});
)

s.plotTree;
s.meter;
s.freqscope;
s.scope;