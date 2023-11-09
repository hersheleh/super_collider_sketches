// SuperCollider CheetSheet
// use shift-ctrl-D to search the help documentation

// execute a statement with shift-Enter

/* var declares a variable
run multiple statements by encapsulating in ()
and type ctrl-enter to run */
(
var num = 3;
num+1;
)

//define a function with {}
// provide arguments with 'arg'
(
~func = {
	arg num;
	num = num*4;
	num = num -1;
}
)



// func is the reciever value is the message
// SuperCollider is made of objects passing messages to each other
~func.value(2);

// Use class method to print an objects class type
14.01.class;
\helloworld.class;

// use a ~ for global variables
(
var c;
c=30;
c=c+1;
)
// A UGen function is a signal function
// shift-ctrl-spc to bring up function tooltip
s.boot;
s.quit;

(
~mysound = {
	arg f1, f2;
	var sig;
	sig = SinOsc.ar(f1, 0, 0.1, 0);//+SinOsc.ar(f2, 0, 0.1, 0);
    
	sig = sig!2;
    SinOsc.ar(f1)
}
)

~mysound.isKindOf(AbstractFunction);
(
x = ~mysound.play(args:[\f1, 500, \f2, 200]);
)


(
x.set(\f1, 220);
x.set(\f2, 680);

)


// use plot to make a graph of a UGen
~mysound.plot(0.01);

// ctrl-M shows the server meters

// This is the master volume fader
s.volume.gui

x.set(\freq, 15000);
x.free;

//
(
{
	arg sig;
	sig = PinkNoise.ar(0.2!2);
	//sig = sig!2;
}.play
)

// randomness
rrand(10,30);
exprand(1,100); // logarithmic rand
