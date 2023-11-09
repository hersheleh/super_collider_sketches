// Notes on looping from Eli Fieldsteel tutorial
s.boot;
S.Quit;



b = Buffer.alloc(s, s.sampleRate * 5);

b.plot;

(
x = {
	var sig;
	sig = SoundIn.ar(0);
	RecordBuf.ar(
		inputArray: sig,
		bufNum: b,
		offset: 0,
		recLevel: 1,
		preLevel: 0,
		run: 1,
		loop: 0,
		doneAction: 2
	);
}
)
