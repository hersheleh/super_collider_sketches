(
"Sampling DOT WAV".postln;
)

b = Buffer.read(s, "/home/grish/hub/recording_bujo/sounds/aaah.wav")

(
SynthDef.new(\play, {
	var sig;
	sig = PlayBuf.ar(
		numChannels: 1,
		bufnum: \buf.kr(0),
		rate: BufRateScale.kr(\buf.kr()) * \rate.kr(1),
		startPos: \spos.kr(0),
		loop: 0,
		doneAction: 2
	);
	sig = Pan2.ar(sig, \pan.kr(0));
	sig = * amp.kr(1);

	Out.ar(bus: \out.kr(0), channelsArray: sig)
}).add;
)

Synth.new(\play, [buf: b.bufnum, rate: 5.midiratio])