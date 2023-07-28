// Initialize the MIDIClient and setup connections to Launchpad
(
//Import functions for communicating with Launchpad MK3
load("mk3_functions.scd".resolveRelative);

)
(
MIDIClient.disposeClient;
~mk3_setup_midi.();
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
}
)

(
~mk3_set_mode.(\prog, ~mk3_midi);
)

(
~mk3_set_mode.(\prog, ~mk3_midi);
)