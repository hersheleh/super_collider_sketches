
(
SynthDef(\saw, {
	var sig, env, cf;
	cf = In.kr(\cfb.kr(0), 1);
	sig = Saw.ar(\freq.kr(440) * { Rand(-0.2, 0.2).midiratio}.dup(4));
	sig = Splay.ar(sig);
	sig = RLPF.ar(sig, cf, \rq.kr(0.4));
	env = Env.adsr().kr(doneAction: 2, gate: \gate.kr(1));
	sig = sig * env * \amp.kr(0.25);
	Out.ar(\out.kr(0), sig);
}).add;
)
(
x = Synth(\saw, [freq: 50]);
x.set(\gate, 0);
)

(
load("launchpad_mk3/mk3_functions.scd".resolveRelative);
~mk3_midi_id = MIDIIn.findPort("Launchpad Mini MK3", "Launchpad Mini MK3 LPMiniMK3 MI").uid;
)
(
~ar = nil ! 128;
MIDIdef.noteOn(\on, {
	arg val, num, chan, src;
	~ar.put(num, Synth(\saw, [
		freq: midicps(num),
		amp: val.linexp(0, 127, 0.05, 0.2);

	]));
}, srcID: ~mk3_midi_id);

MIDIdef.noteOff(\off, {
	arg val, num, chan, src;
	[num, val].postln;
	~ar.at(num).set(\gate, 0);
}, srcID: ~mk3_midi_id);

MIDIdef.cc(\s7, {
	arg val, num, chan, src;
	~cfb.value_(val.linexp(0, 127, 300, 5000));
}, ccNum: 7, srcID: ~mk3_midi_id);


MIDIdef(\on).enable;
MIDIdef(\off).enable;
MIDIdef(\s7).enable;

)

(

~cfb = Bus.control (s, 1);
~cfb.value_(0.5);
)
(
~mk3_setup_midi.();
)



(
~midi_out_index = {
MIDIClient.destinations.size.do({
	arg n;
	(n + " " + MIDIClient.destinations.at(n)).postln;
});
}
)

~midi_out_index.value
