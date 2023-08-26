
(// Initialize the MIDIClient and setup connections to Launchpad
// SETUP ------------------------------------------------------------------
//Import functions for communicating with Launchpad MK3
load("mk3_functions.scd".resolveRelative);
// Initialize midi and connect the launchpad (Jack server must be running)
~mk3_setup_midi.();
MIDIFunc.trace(true);
// --------------------------------------------------------------------------
)
(
// functions for displaying Numbers on Launchpad ----------------------------

// 3x5 display represented as a 16 bit binary digit
// 1 stands for pixel on, 0 is pixel off
~numbers_binary_str_rep = [
	"111101101101111", // zero    Binary representation of 3x5 display
	"001001001001001", // one	  e.g. the number 3
	"111001111100111", // two	  is represented as:    111
	"111001111001111", // three	  	                    001
	"101101111001001", // four	  	   					111
	"111100111001111", // five	  	   					001
	"111100111101111", // six	  	   					111
	"111001001001001", // seven
	"111101111101111", // eight
	"111101111001001"  // nine
];
// Convert string rep of display to binary array
~number_arrays = Array.new(10);
~numbers_binary_str_rep.do({
	arg n;
	var binary_array;
	binary_array = n.as(Array).collect(_.digit);
	~number_arrays.add(binary_array);
});
// --------------------------------------------------------------------------
// Display a single digit on the Launchpad at index with color
~display_digit = {
	arg number, index, rgb;
	var display_number = ~number_arrays[number];
	var display_index = 0;

	forBy(index, index - 50, -10) {
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
// ----------------------------------------------------------------------------
// Create a button on the launchpad and register it with MIDIdef -------------
~mk3_make_button = {
	arg name, index, color, press_color, on_func = "", off_func = "";
	var name_on, name_off, name_cc, on, off, cc, btn_unpress, btn_press;
	name_on = (name++\_on).asSymbol;
	name_off = (name++\_off).asSymbol;
	name_cc = (name++\_cc).asSymbol;
	// [name_on, name_off].postln;
	btn_press = {
		~mk3_light_led.(
			~mk3_colorspec.(\rgb, index, rgb: press_color),
			~mk3_midi;
		);
	};
	btn_unpress = {
		~mk3_light_led.(
		~mk3_colorspec.(\rgb, index, rgb: color),
		~mk3_midi
		);
	};

	btn_unpress.();

	// on = MIDIdef.noteOn(name_on, {
	// 	var val, num, chan, src;
	// 	btn_press.();
	// 	on_func.();
	// }, noteNum: index);
	// off = MIDIdef.noteOff(name_off, {
	// 	var val, num, chan, src;
	// 	btn_unpress.();
	// 	// off_func.();
	// }, noteNum: index);

	cc = MIDIdef.cc(name_cc, {
		var val, num, chan, src;
		[val, num, chan, src].postln;
		if (val == 127) {
			("CC VAL: "+val).postln;
			btn_press.();
		};
		if (val == 0) {
			("CC VAL: "+val).postln;
			btn_unpress.();
		}
	});

	// MIDIdef(name_on).enable;
	// MIDIdef(name_off).enable;
	MIDIdef(name_cc).enable;
};
// ---------------------------------------------------------------------------------
// Clear all pixels on the Launchpad
~mk3_clear = {(0..128).do({arg n; ~mk3_midi.noteOff(0, n, 0)})};
)

(
~mk3_set_layout.(\session, ~mk3_midi);
~mk3_set_mode.(\daw, ~mk3_daw);

)

(
~white = [127, 90,   0];
~green = [  0, 50,   0];
~red   = [ 50,  0,   0];
~black = [ 30,  0, 127];
~blue  = [  0,  0,  90];
~press_color = [127, 127, 127];


~display_life_total = {
	// display and increment two digit number
	arg index = 72, life = 40, color;
	var most_significant, least_significant;
	most_significant = (life / 10).asInteger;
	least_significant = (life % 10);
	~display_digit.(most_significant, index, color);
	~display_digit.(least_significant, index+4, color);
};
)
// ~display_life_total.(life: 50, color: [127, 0, 0]);
(
~life_total = 40;
~magic_life_counter = {

	// arg index, life;
	var starting_life = 40;
	// Display Starting Life
	// ~mk3_clear.();
	~display_life_total.(life: ~life_total, color: [127, 0, 127]);
	~mk3_make_button.(\inc_life, 16, [0, 127, 0], [127, 127, 127],
		{
			if (~life_total <= 98)
			{
				~life_total = ~life_total + 1;
				~life_total.postln;
				~display_life_total.(life: ~life_total, color: [127, 0, 127]);
			}
		});
	// ~mk3_make_button.(\dec_life, 14, [127, 0, 0], [127, 127, 127],
	// 	{
	// 		if (~life_total > 0)
	// 		{
	// 			~life_total = ~life_total - 1;
	// 			~life_total.postln;
	// 			~display_life_total.(life: ~life_total, color: [127, 0, 127]);
	// 		}
	// 	});

	// Choose the color of mana
	// ~mk3_make_button.(\white, 79, ~white, ~press_color);
	// ~mk3_make_button.(\green, 69, ~green, ~press_color);
	// ~mk3_make_button.(\red,   59, ~red  , ~press_color);
	// ~mk3_make_button.(\black, 49, ~black, ~press_color);
	// ~mk3_make_button.(\blue,  39, ~blue , ~press_color);

	// ~mk3_make_button.(\white, 84, ~white, ~press_color);
	// ~mk3_make_button.(\green, 85, ~green, ~press_color);
	// ~mk3_make_button.(\red,   86, ~red  , ~press_color);
	// ~mk3_make_button.(\black, 87, ~black, ~press_color);
	// ~mk3_make_button.(\blue,  88, ~blue , ~press_color);


	// ~mk3_make_button.(\white, 68, ~white, ~press_color);
	// ~mk3_make_button.(\green, 58, ~green, ~press_color);
	// ~mk3_make_button.(\red,   48, ~red  , ~press_color);
	// ~mk3_make_button.(\black, 38, ~black, ~press_color);
	// ~mk3_make_button.(\blue,  28, ~blue , ~press_color);

}
)
~mk3_clear.();
~magic_life_counter.();
MIDIClient.disposeClient();
MIDIdef.freeAll;
MIDIdef.all()
