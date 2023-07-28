(
SynthDef(\saw, {
	var sig, env;
	sig = Saw.ar(\freq.kr(440) * { Rand(-0.2, 0.2).midiratio}.dup(4));
	sig = Splay.ar(sig);
	sig = RLPF.ar(sig, \cf.kr(2000), \rq.kr(0.4));
	env = Env.adsr().kr(doneAction: 2, gate: \gate.kr(1));
	sig = sig * env * \amp.kr(0.25);
	Out.ar(\out.kr(0), sig);
}).add;
)
e = (guppy: 5)

s.boot
s.plotTree;
x = Synth(\saw, [freq: 50]);

x.set(\gate, 0);


MIDIClient.init;
MIDIClient.sources.do({arg n; n.postln});
MIDIClient.sources[7]
MIDIIn.connectAll();
MIDIIn.disconnectAll();
MIDIIn.connect(7, 7);
MIDIIn.connect(5, 5);
MIDIIn.connect(6, 6);

MIDIFunc.trace(true);

(
MIDIdef.noteOn(\on, {
	arg val, num, chann, src;
	[val, num].postln;

});
)

MIDIdef(\on).enable;
MIDIdef(\off).enable;

(
~ar = nil ! 128;
(
MIDIdef.noteOn(\on, {
	arg val, num, chan, src;
	~ar.put(num, Synth(\saw, [
		freq: midicps(num),
		amp: val.linexp(0, 127, 0.05, 0.2);

	]));
});
)
s.plotTree;

(
MIDIdef.noteOff(\off, {
	arg val, num, chan, src;
	~ar.at(num).set(\gate, 0);
});
)
)
MIDIClient.destinations.do({arg n; n.postln});

(
~midi_out_index = {
MIDIClient.destinations.size.do({
	arg n;
	(n + " " + MIDIClient.destinations.at(n)).postln;
});
}
)

~midi_out_index.value

d = MIDIOut(3);
d.connect(3);
m = MIDIOut(4);
m.disconnect(3);

(
MIDIdef.sysex(\mk3, {
	arg data, src;
	data.postln;
});
)

MIDIdef(\mk3).enable;

(
MIDIdef.noteOn(\mk3_note, {
	arg val, num, chan, src;
	[val, num, chan, src].postln;
	d.noteOn(chan, num, 60);
});
)
MIDIdef(\mk3_note).disable;


Int8Array[0xF0, 0x7e, 0x7f, 0x06, 0x01, 0xf7]
m.sysex(Int8Array[0xF0, 0x7e, 0x7f, 0x06, 0x01, 0xf7]);
n.sysex(Int8Array[0xF0, 0x7e, 0x7f, 0x06, 0x01, 0xf7]);

n.sysex(Int8Array[240, 126, 127, 6, 1, 247]);


~mk3_header = [0xf0, 0x00, 0x20, 0x29, 0x02, 0x0d];


(
~select_layout_packet =	{
	arg layout;
	var layouts = (
		ses: 0x00,
		drum: 0x04,
		keys: 0x05,
		usr: 0x06,
		fader: 0x0d,
		prog: 0x7f

	);
	var packet = Int8Array[];
	var header = ~mk3_header;
	if (layout == \read)
	{packet.addAll(header).addAll([0x00, 0xf7]);}
	{packet.addAll(header).addAll([0x00, layouts.at(layout), 0xf7]);}
}
)

m.sysex(Int8Array[].addAll(~mk3_header).addAll([0x03, 0xf7]));

(
~select_mode = {
	arg mode;
	var modes = (
		live: 0x00,
		prog: 0x01
	);
	var packet = Int8Array[];
	var header = ~mk3_header;
	packet.addAll(~mk3_header).addAll([0x0e, modes.at(mode), 0xf7]);
}
)

m.sysex(~select_mode.value(\live))
m.sysex(~select_layout_packet.value(\ses));
m.sysex(~select_layout_packet.value(\drum));
m.sysex(~select_layout_packet.value(\keys));
m.sysex(~select_layout_packet.value(\usr));
m.sysex(~select_layout_packet.value(\read));
m.sysex(~select_mode.value(\prog));

~daw_mode.value(\read);
m.sysex(~daw_mode.value(\daw));
m.sysex(~daw_mode.value(\standalone));
m.sysex(~daw_mode.value(\read));

m.noteOn(0, 12, 56);


m.noteOn(0, 11, 5);
m.noteOn(0, 81, 19);
m.noteOff(2, 16, 56);
m.noteOff(0, 19, 0);
m.noteOff(0, 18, 0);

m.control(0, 11)

d.noteOn(0, 12, 20)
d.control(0, 174, 20)
d.noteOn(16, 14, 20)
