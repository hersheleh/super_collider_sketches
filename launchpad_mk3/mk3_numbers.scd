
(// Initialize the MIDIClient and setup connections to Launchpad
// SETUP ------------------------------------------------------------------
//Import functions for communicating with Launchpad MK3
load("mk3_functions.scd".resolveRelative);
// Initialize midi and connect the launchpad (Jack server must be running)
~mk3_setup_midi.();
MIDIFunc.trace(false);
// --------------------------------------------------------------------------
)
(
// functions for displaying Numbers on Launchpad ----------------------------
~fg_indices = Set[];
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
	arg number, index, fg, bg;
	var display_number = ~number_arrays[number];
	var display_index = 0;

	forBy(index, index - 40, -10) {
		arg i;
		for (0, 2) {
			arg j;
			var pixel = i+j;
			~fg_indices.add(pixel);
			if (display_number[display_index] == 1) {
				~mk3_light_led.(
					~mk3_colorspec.(\rgb, pixel, rgb: fg),
					~mk3_daw);
			}{
				~mk3_light_led.(
					~mk3_colorspec.(\rgb, pixel, rgb:bg),
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
	~fg_indices.add(index);
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

	on = MIDIdef.noteOn(name_on, {
		arg val, num, chan, src;
		("Note On: "+[val, num, chan, src]).postln;
		btn_press.();
		on_func.();
	}, noteNum: index);

	off = MIDIdef.noteOff(name_off, {
		arg val, num, chan, src;
		btn_unpress.();
		off_func.();
	}, noteNum: index);

	cc = MIDIdef.cc(name_cc, {
		arg val, num, chan, src;
		[val, num, chan, src].postln;
		if (val == 127) {
			btn_press.();
			on_func.();
		};
		if (val == 0) {
			btn_unpress.();
			off_func.();
		}
	}, ccNum: index);

	MIDIdef(name_on).enable;
	MIDIdef(name_off).enable;
	MIDIdef(name_cc).enable;
};
// ---------------------------------------------------------------------------------
// Clear all pixels on the Launchpad
~mk3_clear = {(0..128).do({arg n; ~mk3_midi.noteOff(0, n, 0)})};
// --------------------------------------------------------------------------------
~white = [90, 40,   0]*0.1;
~green = [  0,  50,   0]*0.1;
~red   = [ 50,   0,   0]*0.1;
~black = [ 30,   0, 127]*0.1;
~blue  = [  0,   0,  90]*0.2;
~life_total_color =	[50,50,50]*0.7;



// ~white = [127, 90,   0];
// ~green = [  0, 127,   0];
// ~red   = [ 100,  0,   0];
// ~black = [ 30,  0, 127];
// ~blue  = [  0,  0,  127];

~press_color = [127, 127, 127];

// Display MTG life total as 2 digit number	on Launchhpad
~display_life_total = {
	// display and increment two digit number
	arg index = 72, life = 40, color, bg_color;
	var most_significant, least_significant;
	most_significant = (life / 10).asInteger;
	least_significant = (life % 10);
	~display_digit.(most_significant, index, color, bg_color);
	~display_digit.(least_significant, index+4, color, bg_color);
};
// ----------------------------------------------------------------------------------

~mk3_set_background_color = {
	arg rgb;
	forBy (80, 10, -10) {
		arg i;
		for (1, 8) {
			arg j;
			var index = i+j;
			if (not(~fg_indices.includes(index)))
			{
			~mk3_light_led.(
				~mk3_colorspec.(\rgb, index, rgb: rgb),
				~mk3_midi
			);
			}
		}
 	}
};

~life_total = 40;
// ~life_total_color =	[20, 20, 20];
// ~bg_color = [20, 10, 20];
~bg_color = ~white;
~magic_life_counter = {

	// Display Starting Life
	var starting_life = 40;

	~display_life_total.(life: ~life_total, color: ~life_total_color, bg_color: ~bg_color);
	~mk3_make_button.(\inc_life, 16, [0, 127, 0], [127, 127, 127],
		{
			if (~life_total <= 98)
			{
				~life_total = ~life_total + 1;
				~life_total.postln;
				~display_life_total.(life: ~life_total, color: ~life_total_color,
					bg_color: ~bg_color);
			}
		});
	~mk3_make_button.(\dec_life, 14, [127, 0, 0], [127, 127, 127],
		{
			if (~life_total > 0)
			{
				~life_total = ~life_total - 1;
				~life_total.postln;
				~display_life_total.(life: ~life_total, color: ~life_total_color,
					bg_color: ~bg_color);
			}
		});

	// Choose the color of mana
	~mk3_bg_color_button = {
		arg symbol, index, bg_color;
		~mk3_make_button.(symbol, index, bg_color, ~press_color, {
			~bg_color = bg_color;
			~mk3_set_background_color.(rgb: bg_color);
			~display_life_total.(life: ~life_total, color: ~life_total_color, bg_color: bg_color);
		});
	};

	~mk3_bg_color_button.(\white, 79, ~white);
	~mk3_bg_color_button.(\green, 69, ~green);
	~mk3_bg_color_button.(\red,   59, ~red);
	~mk3_bg_color_button.(\black, 49, ~black);
	~mk3_bg_color_button.(\blue,  39, ~blue);

	~mk3_set_background_color.(rgb: ~bg_color);
}
)
MIDIdef.freeAll;
~mk3_clear.();
~magic_life_counter.();




// MIDIClient.disposeClient();
// MIDIdef.all()

(
// ~mk3_set_layout.(\session, ~mk3_midi);
// ~mk3_set_mode.(\standalone, ~mk3_daw);
~mk3_set_layout.(\prog, ~mk3_midi);

)
