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
}.play
)

{Saw.ar(100)*[1,1];}.play


(
SynthDef.new(\harmonic, {
	arg freq, part;
	var sig, mul = 1;
	sig = SinOsc.ar(100*part, mul: 1/part)!2;
	Out.ar(0, sig);
}
).add;
)

(
(1..5).do( {
	arg value;
	SynthDef.new(
		\harmonic,
		[\freq, 100, \part, value.postln]
	)
});
)