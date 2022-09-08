// Mixing mouse test

(
{
	var sig, pos, vol, raw_mouseX, raw_mouseY;
	raw_mouseY = MouseY.kr(0, 20000, 0);
	raw_mouseX = MouseX.kr(0, 20000, 0);
	vol = (-1*(raw_mouseY/20000)+1).poll;
	pos = ((raw_mouseX/10000) - 1);
	sig = SinOsc.ar(140, mul:0.06);
	//sig = BrownNoise.ar(0.08);
	sig = Pan2.ar(sig, pos, vol);

}.play
)

