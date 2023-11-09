// Library of Functions to send sysex MIDI messages to Launchpad Mini MK3
(
~mk3_setup_midi = {
	// Launchpad MK3 device and port names
	var mk3_device_name, mk3_daw_port_name, mk3_midi_port_name;
	var mk3_daw_port, mk3_midi_port, mk3_midi_in_port;

	mk3_device_name = "Launchpad Mini MK3";
	mk3_daw_port_name = "Launchpad Mini MK3 LPMiniMK3 DA";
	mk3_midi_port_name = "Launchpad Mini MK3 LPMiniMK3 MI";

	MIDIClient.init;

	mk3_midi_in_port = MIDIIn.findPort(mk3_device_name, mk3_midi_port_name);

	MIDIIn.connect(0,  mk3_midi_in_port);

	mk3_daw_port = MIDIOut.findPort(mk3_device_name, mk3_daw_port_name);
	mk3_midi_port = MIDIOut.findPort(mk3_device_name, mk3_midi_port_name);
	// [mk3_daw_port ,	mk3_midi_port];
	// Connect SC to Launchpad MK3s midi and daw ports
	~mk3_daw = MIDIOut(0);
	~mk3_midi = MIDIOut(1);
	~mk3_daw.connect(mk3_daw_port);
	~mk3_midi.connect(mk3_midi_port);
};

~build_mk3_sysex = {
	// Build mk3 sysex array using header + payload + suffix
	arg payload = [];
	// Header preceding all mk3 sysex messages
	var header = [0xf0, 0x00, 0x20, 0x29, 0x02, 0x0d];
	var suffix = [0xf7];
	Int8Array.newFrom(header ++ payload ++ suffix);
};


~mk3_cmd = {
	arg command;
	var commands = (
		layout: 0x00,
		daw_fader: 0x01,
		led_light: 0x03,
		text_scroll: 0x07,
		brightness: 0x08,
		led_sleep: 0x09,
		led_feedbk: 0x0a,
		prog_live: 0x0e,
		daw_stl: 0x10,
		daw_clr: 0x12,
		ses_color: 0x14
	);
	[commands.at(command)];
};

~mk3_set_mode = {
	arg mode, midi_dev;
	var modes =	(
		live: [0x0e, 0x00],
		prog: [0x0e, 0x01],
		standalone: [0x10, 0x00],
		daw: [0x10, 0x01],
	);
	var payload = ~build_mk3_sysex.(modes.at(mode));
	// payload.postln;
	midi_dev.sysex(payload);
};

~mk3_set_layout = {
	arg layout, midi_dev;
	var layouts = (
		session: 0x00,
		drums: 0x04,
		keys: 0x05,
		user: 0x06,
		faders: 0x0d,
		prog: 0x7f
	);
	var command = 0x00;
	var	payload = ~build_mk3_sysex.([command, layouts.at(layout)]);
	// payload.postln;
	midi_dev.sysex(payload);
};

~mk3_fader = {
	arg index, type, cc, color;
	var types = (
		unipolar: 0x00,
		bipolar: 0x01
	);
	[index, types.at(type), cc, color];
};

~mk3_setup_faders = {
	arg orientation, faders, midi_dev;
	var orientations = (
		vertical: 0x00,
		horizontal: 0x01,
	);
	var payload, all_faders = [], command = [0x01, 0x00];
	faders.do({ arg n; all_faders = all_faders ++ n});
	payload = ~build_mk3_sysex.(
		command ++ [orientations.at(orientation)] ++ all_faders);
	midi_dev.sysex(payload);
};

~mk3_colorspec = {
	arg type, index, palette = 0, palette_2 = 0, rgb = [];
	var types = (
		static: 0x00,
		flashing: 0x01,
		pulsing: 0x02,
		rgb: 0x03
	);
	var out;
	if ((type == \static) || (type == \pulsing)) {
		out = [types.at(type), index, palette];
	};
	if (type == \flashing) {
		out = [types.at(type), index, palette, palette_2];
	};
	if (type == \rgb) {
		out = [types.at(type), index] ++ rgb;
	};
	out;
};

~mk3_light_led = {
	arg colorspec, midi_dev;
	var payload, command = 0x03;
	// colorspec.postln;
	payload = ~build_mk3_sysex.(
		[command] ++ colorspec;
	);
	// payload.postln;
	midi_dev.sysex(payload);
};

~mk3_display_color_palette = {
	var color = 0;
	var chan = 0;
	forBy (80, 10, -10) {
		arg i;
		for (1, 8) {
			arg j;
			var note = i+j;
			// note.postln;
			d.noteOff(chan, note, color);
			color = color + 1;
		}
	}
}
)
