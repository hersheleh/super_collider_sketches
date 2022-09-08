

(
~sound = {
	arg freq = 240, t_gate = 0, mul=0.4, sum=0;

	var sig = SinOsc.ar(freq, mul: mul);
	/*var env = Linen.kr(m
		gate: t_gate,
		attackTime: 0.01,
		susLevel: 1.0,
		releaseTime: 1.0,
		doneAction: 0
	);*/
	sig!2;
}
)
~sound.play;
~sound.free
(
var rel_list;
var tonic = 240;
var scnd = (9/8);
var third = (5/4);
var fourth = (4/3);
var fifth = (3/2);
~scale = [tonic, tonic*scnd, tonic*third,
	tonic*fourth, tonic*fifth];
)

i = 0;
~tones = [];
(
var freq = ~scale[0];
var part = 3;
freq = ~scale[2];//(100*part);
{SinOsc.ar(freq, mul:0.4) * [1, 1]}.play;
~tones = ~tones.add(freq);
i = i+1;
~tones.poll;
)


~sound.get(\freq, {arg value; value.postln});
(
~sound.set(\freq, ~scale[i], \t_gate,1);

)
