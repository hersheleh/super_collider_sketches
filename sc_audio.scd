s.boot;
s.quit;
b.free;

Buffer.freeAll;

(
~path = PathName(thisProcess.nowExecutingPath).parentPath ++"audio/";
~em_hammer = ~path ++ "Em_hammer.wav";

~b = Buffer.read(s, ~em_hammer);
)


(
SynthDef.new(\play, {
	arg buf=0, rate=1, t_trig=0, spos;
	var sig;
	sig = PlayBuf.ar(1, buf, rate, t_trig, spos)!2;
	Out.ar(0, sig);
}).add;
)

x = Synth.new(\play, [\buf, ~b]);
x.set(\t_trig, 1);





