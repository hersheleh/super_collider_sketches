// Initialize the MIDIClient and setup connections to Launchpad
(
//Import functions for communicating with Launchpad MK3
load("mk3_functions.scd".resolveRelative);

)
(
~mk3_setup_midi.();
MIDIFunc.trace(false);
)
(
// 3x5 display represented as a 16 bit binary digit
// 1 stands for pixel on, 0 is pixel off
~numbers_binary_str_rep = [
	"111101101101111", // zero
	"001001001001001", // one
	"111001111100111", // two
	"111001111001111", // three
	"101101111001001", // four
	"111100111001111", // five
	"111100111101111", // six
	"111001001001001", // seven
	"111101111101111", // eight
	"111101111001001" // nine
];

~number_arrays = Array.new(10);

~numbers_binary_str_rep.do({
	arg n;
	var binary_array;
	binary_array = n.as(Array).collect(_.digit);
	~number_arrays.add(binary_array);
});

~display_number = {
	arg number, index, rgb;
	var display_number = ~number_arrays[number];
	var display_index = 0;
	forBy(index, 10, -10) {
		arg i;
		for (0, 2) {
			arg j;
			var pixel = i+j;
			if (display_number[display_index] == 1) {
				~mk3_light_led.(
					~mk3_colorspec.(\rgb, pixel, rgb: rgb),
					~mk3_daw);
			}{
				~mk3_light_led.(
					~mk3_colorspec.(\static, pixel, 0),
					~mk3_daw);
			};
			display_index = display_index + 1;
		}
	}
};

~mk3_make_button = {
	arg name, index, color, press_color;
	var name_on, name_off, on, off;
	name_on = (name++\_on).asSymbol;
	name_off = (name++\off).asSymbol;
	[name_on, name_off].postln;
	// MIDIdef(name_on).free;
	// MIDIdef(name_off).free;
	~mk3_light_led.(
		~mk3_colorspec.(\rgb, index, rgb: color),
		~mk3_midi
	);
	on = MIDIdef.noteOn(name_on, {
		var val, num, chan, src;
		[val, num, chan, src].postln;
		~mk3_light_led.(
			~mk3_colorspec.(\rgb, index, rgb: press_color),
			~mk3_midi;
		);
		~increment_number.(index: index);
	}, noteNum: index);
	off = MIDIdef.noteOff(name_off, {
		var val, num, chan, src;
		[val, num, chan, src].postln;
		~mk3_light_led.(
			~mk3_colorspec.(\rgb, index, rgb: color),
			~mk3_midi;
		);
	});
	MIDIdef(name_on).enable;
	MIDIdef(name_off).enable;
	[on, off];
};

~mk3_clear = {(0..128).do({arg n; ~mk3_midi.noteOff(0, n, 0)})};
)


(
~mk3_set_layout.(\prog, ~mk3_midi);

~mk3_make_button.(\inc, 67, [127,0,0], [0,0,127]);

)

(
~white = [127, 90,   0];
~green = [  0, 50,   0];
~red   = [ 50,  0,   0];
~black = [ 30,  0, 127];
~blue  = [  0,  0,  90];
~press_color = [127, 127, 127];

~magic_life_counter = {
	arg index, start_life;
	var starting_life = 40;
	// Display Starting Life
	~mk3_clear.();
	~display_number.(4, 71, ~red);
	~display_number.(0, 76, ~red);
	// Choose the color of mana
	~mk3_make_button.(\white, 69, ~white, ~press_color);
	~mk3_make_button.(\green, 59, ~green, ~press_color);
	~mk3_make_button.(\red,   49, ~red  , ~press_color);
	~mk3_make_button.(\black, 39, ~black, ~press_color);
	~mk3_make_button.(\blue,  29, ~blue , ~press_color);

	~mk3_make_button.(\white, 68, ~white, ~press_color);
	~mk3_make_button.(\green, 58, ~green, ~press_color);
	~mk3_make_button.(\red,   48, ~red  , ~press_color);
	~mk3_make_button.(\black, 38, ~black, ~press_color);
	~mk3_make_button.(\blue,  28, ~blue , ~press_color);

}

)

(
~display_number.(4, 65, [127, 0, 0]);
~display_number.(3, 62, [0, 0, 0]);
~display_number.(3, 65, [0, 0, 0]);
~display_number.(1, 65, [0, 50, 0]);
~display_number.(0, 65, [0, 0, 127]);
~display_number.(0, 65, [50, 0, 50]);
~display_number.(9, 67, [127, 0, 127]);
~display_number.(9, 67, [0, 0, 0]);
~display_number.(0, 67, [0, 0, 0]);
~display_number.(3, 61, [0, 127, 127]);
~display_number.(3, 65, [0, 127, 127]);
~display_number.(3, 65, [0, 127, 127]);
)