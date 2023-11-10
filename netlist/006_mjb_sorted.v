********************************************************************************************************

Oric ULA/CDI HCS 10017 

4th September 2018

For supporting images/schematic diagrams: http://oric.signal11.org.uk/html/ula-dieshot.htm

Original verilog file: by Mike Connors at DATEL

Post processed/organised/commented by: Mike Brown (oric@signal11.org.uk)

********************************************************************************************************

Every transistor has been hand checked, clean and polished, and assigned to a gate
in order from left-right, top-down as per diagrams of gate structure examples,
to start to establish a hierarchy, and identify "unused/spare" transistors,
spot any errors, and find any other structures.

Completed: Transistors accounted for, grouped to gates.
Completed: Fixed off-grid wires/combined net-names for cell-cell wiring
Completed: Commented all external signals, mapping to net-names in verilog.
Completed: Gates to logic blocks
Completed: Logic blocks to functional blocks
Completed: Finally sorted out what is a LATCH and what is "2 latches as a FLIPFLOP"
Completed: Verifying sense of logic signals (active low, high)
Completed: Verifying active of edge of clock into all single latches and all flip flops (as pair)

           Rule: In latch/first stage of FF - Follow D: Input to a transmission gate (one of two in mux)
           If clock goes to that TG's GN, it's a *falling* edge clock
           If clock goes to that TG's GP, it's a *rising* edge clock.

Completed: Marked operating "sense" of 2:1 muxes used outside of latches/flipflops (and on schematic) for A/B input.
Completed: Updating page number references to latest schematic pictures

ULA Cells:
16x25 array of ULA cells = 400 cells
Not all cells are used for logic, some are used only to pass signals across the chip. 

Transistors:
Each ULA cell has 10 FETs (3+2 P-type, 3+2 N-type). 
Not all transistors in a cell are used.
Total: 4000 transistors to account for.

This does not include I/O pin drivers: Manually drawn out as Eagle examples (see website).

Normal Gates: 
NAND Gates: 2/3/4 input: 271 gates (1180 transistors)
NAND Gates: 2 input (manually rebuilt) 2 gate (8 transistors)
NAND Gates: 4 input (manually rebuilt) 1 gate (8 transistors)
NOR Gates:  2/3 input:   27 gates (114 transistors)
NOT Gates:  Various (P:N) ratios (1:1/2:2/3:3/4:4/2:1): 399 gates (998 transistors)
NOT Gates: (1:1) (manually rebuilt) 2 gates (4 transistors)

Complex Gates:
2-1 And-Or-Invert: 1 gate (6 transistors)
2-1 Or-And-Invert: 3 gates (18 transistors)

Transmission Gates: 289 gates (578 transistors)

Tri-State inverting buffers: 7 gates (14 transistors)

Other non-logic-gate/support transistors: (12 transistors)

Capacitors: A P-FET across the supply rails (VDD to VSS): 1 (1 transistor)
	    An N-FET (on manual-1 NAND output) (1 transistor)

Unused cells: Appear in the verilog, but are isolated from everything but themselves.
  Totally unused:     45 cells (450 transistors)
  Half unused (3-in empty): 29 cells (174 transistors)
  Half unused (2-in empty): 21 cells (84 transistors)

Unused transistors: Appear in the verilog, left over within a cell that has other logic in.
  3-in, left-middle: 14 pairs (28 transistors)
  3-in, right-middle: 6 pairs (12 transistors)
  3-in, right-side: 27 pairs (54 transistors)
  3-in, left-side:  27 pairs (54 transistors)

  2-in, upper-left/lower right crossed : 38 pairs (76 transistors) and 12 singles (12 transistors)
  2-in, lower-left/upper right lone: 19 pairs (38 transistors) and 2 singles (2 transistors)

Ghost capacitor-pair: 
  A P-FET with drain and source connected to VDD coupled with 
  an N-FET with drain and source to VSS: 37 (74 transistors)

Total transistors accounted for above: 4000

// **************************** Annotated VERILOG-into-hierarchy begins here *****************************************

// **NOTE** Not all wires are captured in the original verilog. 

// Signals that leave the array and travel around the edge, re-entering the array, have become 
// disconnected, leaving some logic gates with outputs driving nothing, or logic inputs floating.
//
// Hand tracing of the image was required to get them back and combine the net-names.
// List of amendments preserved here for reference.
//
// Format:
// Orig 1 = Orig 2 [ = Orig 3 ]-> NEW NAME 	// Orig-1 nodes | Orig-2 nodes |  ....

// I_3884_D = I_3331_G -> I_3884_D		// NAND m1 out/Cap 3884 | NOT 738 in
// I_3971_S = I_3977_G -> I_3971_S		// NOT 897 in/NOT 898 out | NAND 850 in/NAND 888 in/NAND m1 in
// I_1025_D = I_3_G -> I_3_G			// NOT 297 out | NAND 290 in/NOT 675 in
// I_1025_G = I_1409_G = I_1889_D -> I_1889_D	// NOT 297 in | NAND 368 in | NAND 465 out
// I_1153_G = I_2371_S -> I_2371_S		// NAND 304 in/NAND 324 in | NOR 569 out
// I_1185_G = I_1729_S = I_2275_D -> I_2275_D	// NAND 324 in | CMOS 74/p2 | NAND 541 out
// I_1185_D = I_493_G -> I_493_G		// NAND 324 out | NOR 914 in
// I_1262_G = I_3585_D -> I_3585_D		// NOT 338 in | NAND 802 out
// I_1507_D = I_1888_G = I_2535_G -> I_2535_G	// NOT 375 in/NOT 358 out | NAND 465 in | NOT 592 in/CMOS 118/gp 119/gn 123/gn 124/gp
// I_261_D = I_3649_G -> I_3649_G		// NAND 420 out/CMOS 128/p1 | NOT 811 in

// I_1730_G = I_1761_G = I_1258_G 		// CMOS 70/gn 71/gp 74/gp 75/gn | NOT 440 in 
//          = I_245_D -> I_245_D		// | NOT 309 in/CMOS 15/gn 16/gp 26/gp 27/gn | NOT 455 out

// I_1825_D = I_1921_G = I_2113_G = I_2241_G = // NOT 452 out | NANDs 475|508|540|571|599|624|651|681|713|748 ins
//            I_2433_G = I_2561_G = I_2753_G = 
//            I_2881_G = I_3073_G = I_3201_G = 
//            I_3393_G -> I_3393_G				

// I_1671_S = I_3830_G	-> I_3830_G		// NAND 408 in/NOT 372 in/NOT 324 out/CMOS 55/gn 56/gp 62/gp 64/gn 78/gp 79/gn 82/gn 83/gp | NAND 852 in
// I_2050_G = I_3075_D	-> I_3075_D		// NAND 500 in | NAND 671 out
// I_2657_D = I_2849_S	-> I_2849_S		// NAND 599 out/CMOS 108/gp 112/gn 117/gn 122/gp 130/p1 | CMOS 152/p2
// I_2471_S = I_3911_G	-> I_3911_G		// NAND 306 in/NAND 573 in/NOT 587 out/CMOS 131/gp 132/gn 138/gn 139/gp | NAND 873 in
// I_3363_D = I_2083_G	-> I_2083_G		// NOT 749 out | NAND 509 in
// I_3555_G =  I_2370_G = I_3657_D -> I_3657_D	// NAND 788 in/NOT 787 in/CMOS 190/gn 197/gp 205/gp 209/gn | NOR 569 in | NAND 685 in/NOR 793 in/NOT 813 out
// I_2489_D = I_1415_S	-> I_1415_S		// NAND 584 in/NOT 583 out/CMOS 116/p2 | CMOS 244/p2 263/p1 284/p2 45/p2
// I_247_D = I_1250_G	-> I_1250_G		// NOT 458 in/NOT 524 out | NAND 336 in
// I_1283_D = I_1311_G	-> I_1311_G		// NAND 707 in/NOT 342 out | NAND 354 in
// I_3999_G = I_3353_D	-> I_3353_D		// NOT 896 in | NAND 742 out
// I_1511_S = I_3836_G	-> I_3836_G		// NAND 377 in/NOT 394 out/CMOS 72/gp 73/gn 76/gn 77/gp | NAND 855 in
// I_3036_G = I_3829_S	-> I_3829_S		// NAND 661 in/NOT 677 in | CMOS 233/p2
// I_3933_G = I_3973_D	-> I_3973_D		// NAND 879 in | NAND 886 out
// I_3735_G = I_1755_D	-> I_1755_D		// NANDs 755/841 in/NOTs 773/833 in | NANDs 517/555/584/638/666/879 in/NOT 422 out/NOTs 531/548/578/631/659/869 in
// I_3915_G = I_3133_D	-> I_3133_D		// NAND 826 in/NOT 880 in | NAND 649 in/NAND 694 out
// I_1821_D = I_3980_G = I_3974_G -> I_3974_G	// NOTs 434/537/621/710/778/779/853/856 in/NOT 450 out | NAND 890 in | NAND 887 in
// I_3990_S = I_3851 G	-> I_3851_G		// NAND 834 in/NOT 893 out | NAND 851 in
// I_2231_D = I_1991_S	-> I_1991_S		// NOT 515 in/CMOS 106/p1 91/gn 97/gp | NAND 478 in/NOT 476 in/NOT 498 out/CMOS 100/gp 101/gn 104/gn 105/gp
// I_3904_D = I_3767_G	-> I_3767_G		// NAND 859 out | NAND 841 in
// I_3667_S = I_3663_D	-> I_3663_D		// NOT 846 in/CMOS 224/p2 232/gn | CMOS 218/p2 223/p1
// I_3819_G = I_3861_D	-> I_3861_D		// NAND 851 in | NOT 865 out
// I_3453_D = I_3847_G	-> I_3847_G		// NAND 709 in/NAND 759 out | NAND 826 in/NOT 862 in
// I_3381_G = I_3906_D	-> I_3906_D		// NAND 755 in | NAND 860 out
// I_3195_S = I_1631_G	-> I_1631_G		// NOT 711 out/NOT 865 IN | NAND 414 in

// Total of 36 Nets were broken into 88 pieces!

// Also the following internal nets are visibly connected, yet are considered separate in the verilog, (detected
// by finding an orphaned output or input during re-organisation). Repaired by merging nets

// I_1139_D = I_1235_D	-> I_1235_D		// In cell [7.9] 1138D-1139D (NOT 318 out) | 1235D-1234D (CMOS 19)
// I_1257_D = I_1193_G  -> I_1193_G		// In cell [7,4] 1224S/1225S/1257D/1256D (CMOS 15/26) | 1160G/1161G/1192G/1193G (NOT 326 in)
// I_2379_S = I_3019_G	-> I_3019_G		// In cell [14,5] 2379S/2346S/2378D (NOR 570 out) | [18,5] 3019G/2986G (NOT 679 in)
D
// I_2534_G = I_2530_S -> I_2534_G		// In cell [15,3] to [15,1] 2503G/2534G/2533G | 2500G/2530S
// I_471_S = I_631_D -> I_471_S			// In cell [2,11] to [3,11] 470S/471S | 631D/630D/599S/598S
// I_2133_G = I_2151_S -> I_2151_S		// In cell [12,10] 2037G/2068G [13,10] 2133G/2132G & [10,9] 1747G/1714G | [13,3] 2087G/2151S + others
// I_2062_G = I_2971_S -> I_2791_S		// In cell [12,7] 2031G/2062G | [17,3] 2727G/2726G/2790S/2791S
//
// Total of 7 Nets were broken into 14 pieces! (If there are more, they have not been detected!)

// Also: Signals to and from the outside world were not captured.
//
// Fortunately most are a simple input or output, so were hand traced. 
//
// Oddities are pin 7 (CLOCK) (produces 3 input signals) and 19 (Red Video) (2 output drive signals, 1 input(!))
// 
// Note: Pin 21A is a metallised pad next to Pin 21 -- not brought out on a bond wire, it is an input used for resetting counters.
//
// 
// Ext Pin/Pad	Dir	Func			Wire Name
//
// 6		Power	GND			VSS
// 24		Power	+5v			VCC

// 32	*	IN	A8 	6502 		I_3988_G	NOT 892 in
// 33	*	IN	A9	Address 	I_3990_G	NOT 893 in
// 31	*	IN	A10	Bus		I_3987_G	NOT 899 in
// 15	*	IN	A11	High		I_3195_G	NOT 711 in
// 35	*	IN	A12	Byte		I_3923_G	NOT 884 in
// 22	*	IN	A13			I_3593_G	NOT 806 in
// 29	*	IN	A14			I_3659_G	NOT 819 in
// 30	*	IN	A15			I_3982_G	NOT 891 in

// 38	*	OUT	RC0	DRAM		I_3519_D	NOT 781 out  Strength 2
// 36	*	OUT	RC1	Row		I_3675_D	NOT 816 out  Strength 2
// 37	*	OUT	RC2	And		I_3999_D	NOT 896 out  Strength 2
// 4	*	OUT	RC3	Column		I_1919_D	NOT 471 out  Strength 2
// 3	*	OUT	RC4			I_2399_D	NOT 568 out  Strength 2
// 2	*	OUT	RC5	Address		I_2879_D	NOT 650 out  Strength 2
// 40	*	OUT	RC6			I_3359_D	NOT 745 out  Strength 2
// 39	*	OUT	RC7			I_3423_D	NOT 760 out  Strength 2

// 8	*	IN	D0	6502		I_91_G 		NOT 980 in
// 17	*	IN	D1	Data		I_507_G		NOT 917 in
// 11	*	IN	D2	Bus		I_87_G		NOT 975 in
// 12	*	IN	D3			I_23_G		NOT 556 in
// 13	*	IN	D4			I_85_G		NOT 972 in
// 5	*	IN	D5			I_571_G		NOT 927 in
// 34	*	IN	D6			I_3993_G	NOT 900 in
// 18	*	IN	D7			I_1260_G	NOT 337 in

// 9	**	OUT	CAS	DRAM		I_59_D		NOT 622 out  Strength 2
// 10	**!	OUT	RAS	DRAM		I_821_D		NAND 961 out 
// 1	*	OUT	DRAM Mux Sel		I_1757_D	NOT 433 out  Strength 2
// 28	**	OUT	WREN	DRAM		I_3979_D	NOT 889 out  Strength 2

// 27	*	IN	R/~W	6502 R/~W	I_3529_G	NOT 791 in

// 25	**	OUT	~IO	6522 ~CS	I_3651_D	NOT 812 out  Strength 2
// 23	*	OUT	~ROMSEL ROM ~CS		I_3331_D	NOT 738 out  Strength 2 
// 26	*	IN	~MAP	Ext peripherals I_3971_G	NOT 898 in

// 7	--	IN	CLKIN (Raw)		I_151_G		NOT 331 in  2P:1N (!)
// 	@		CLKIN (Invx1)		I_95_G		NOT 698 in   Strength 3
// 	@		CLKIN (Invx2)		I_503_G		NOTs 657/915 in Strength 3,1
// 14	*	OUT	PHI 			I_245_D		NOT 455 out  And many more ins

// NOTE: The official Oric Circuit diagram has the next pins shown as 21=R,20=G,19=B and
// has SK2 (video) mislabelled. Swap over "R" and "B" in these two places to correct it!
// It has proved to be incorrect (from tracing back these signals to the registers that
// drive them, AND the Oric Manual's pinout for the video connector.

// 19	*	OUT 	R (P drive)		I_131_S		NOT 353 out  Strength 1
// 	*	 	R (N drive)		I_321_D		NOT 717 out  Strength 1
//  	-	IN	Reset 2			I_1408_G	NAND 368 input
// 20	*	OUT	G			I_385_D		NOT 792 out  Strength 2
// 21	*	OUT	B	Video		I_705_D		NOT 944 out  Strength 2
// 16	**	OUT	~COMPSYNC		I_3_G		NOT 297 out  Strength 2

// Oddities
// 21A	--	IN	Reset 1			I_1313_G	NAND 355 input

// Comparing ULA signals to outside world :-
//
// *   Has inverter (boundary buffer) on chip - is also inverted once in pin driver - straight logic
// **  Has inverter (boundary buffer) on chip - is also inverted twice in pin driver - inverted logic
// **! Has no inverter (boundary buffer) on chip - is inverted twice in pin driver - straight logic
// -   Has no inverter (boundary buffer), -- is inverted once in pin driver - inverted logic
// --  Has no inverter (boundary buffer), -- is not inverted in pin driver - straight logic.
// @   Special case: Clock pin -- drawn in full on schematic. TBD if some of these nots are "boundary buffer" after all?

// ********************************************************************************************************

// Power Rails

// P-FET as bypass capacitor across supply
    generic_pmos I_3885(.D(VDD), .G(VSS), .S(VDD));

// ********************************************************************************************************

// Boundary inverters on signals entering chip (See Page 5)

// External signals are inverted FIRST by pin-driver circuit (IN-DRV1/2/3), then AGAIN by 
// these devices, so internal logic is consistent with external!

// Octal inverting buffer for incoming address bus pins from 6502 [A8..A15] in order
// Internal address bus [A8..A15] is I_3988_S,I_3851_G,I_3987_S,I_1631_G,I_3923_S,I_3593_S,I_3659_S,I_3983_D
  not auto_892(I_3988_S, I_3988_G);
    generic_pmos I_3957(.D(I_3988_S), .G(I_3988_G), .S(VDD));
    generic_nmos I_3988(.D(VSS), .G(I_3988_G), .S(I_3988_S));
  not auto_893(I_3851_G, I_3990_G);
    generic_pmos I_3959(.D(I_3851_G), .G(I_3990_G), .S(VDD));
    generic_nmos I_3990(.D(VSS), .G(I_3990_G), .S(I_3851_G));
  not auto_899(I_3987_S, I_3987_G);
    generic_pmos I_3987(.D(VDD), .G(I_3987_G), .S(I_3987_S));
    generic_nmos I_3954(.D(I_3987_S), .G(I_3987_G), .S(VSS));
  not auto_711(I_1631_G, I_3195_G);
    generic_pmos I_3195(.D(VDD), .G(I_3195_G), .S(I_1631_G));
    generic_nmos I_3162(.D(I_1631_G), .G(I_3195_G), .S(VSS));
  not auto_884(I_3923_S, I_3923_G);
    generic_pmos I_3923(.D(VDD), .G(I_3923_G), .S(I_3923_S));
    generic_nmos I_3922(.D(VSS), .G(I_3923_G), .S(I_3923_S));
  not auto_806(I_3593_S, I_3593_G);
    generic_pmos I_3593(.D(VDD), .G(I_3593_G), .S(I_3593_S));
    generic_nmos I_3592(.D(VSS), .G(I_3593_G), .S(I_3593_S));
  not auto_819(I_3659_S, I_3659_G);
    generic_pmos I_3659(.D(VDD), .G(I_3659_G), .S(I_3659_S));
    generic_nmos I_3626(.D(I_3659_S), .G(I_3659_G), .S(VSS));
  not auto_891(I_3983_D, I_3982_G);
    generic_pmos I_3951(.D(VDD), .G(I_3982_G), .S(I_3983_D));
    generic_nmos I_3982(.D(VSS), .G(I_3982_G), .S(I_3983_D));

// Octal inverting buffer for incoming data bus pins from 6502 [D0..D7] in order
// Internal data bus [D0..D7] buffered is I_2041_D,I_2201_D,I_2361_D,I_2521_D,I_2681_D,I_2841_D,I_3993_S,I_1417_S in order.
  not auto_980(I_2041_D, I_91_G);
    generic_pmos I_91(.D(VDD), .G(I_91_G), .S(I_2041_D));
    generic_nmos I_90(.D(VSS), .G(I_91_G), .S(I_2041_D))
  not auto_917(I_2201_D, I_507_G);  
    generic_pmos I_507(.D(I_2201_D), .G(I_507_G), .S(VDD));
    generic_nmos I_506(.D(I_2201_D), .G(I_507_G), .S(VSS));
  not auto_975(I_2361_D, I_87_G);
    generic_pmos I_87(.D(VDD), .G(I_87_G), .S(I_2361_D));
    generic_nmos I_86(.D(VSS), .G(I_87_G), .S(I_2361_D));
  not auto_556(I_2521_D, I_23_G);
    generic_pmos I_23(.D(I_2521_D), .G(I_23_G), .S(VDD));
    generic_nmos I_22(.D(I_2521_D), .G(I_23_G), .S(VSS));
  not auto_972(I_2681_D, I_85_G);
    generic_pmos I_85(.D(VDD), .G(I_85_G), .S(I_2681_D));
    generic_nmos I_84(.D(VSS), .G(I_85_G), .S(I_2681_D));
  not auto_927(I_2841_D, I_571_G);
    generic_pmos I_571(.D(VDD), .G(I_571_G), .S(I_2841_D));
    generic_nmos I_570(.D(VSS), .G(I_571_G), .S(I_2841_D));
  not auto_900(I_3993_S, I_3993_G);
    generic_pmos I_3993(.D(VDD), .G(I_3993_G), .S(I_3993_S));
    generic_nmos I_3960(.D(I_3993_S), .G(I_3993_G), .S(VSS));
  not auto_337(I_1417_S, I_1260_G);
    generic_pmos I_1229(.D(I_1417_S), .G(I_1260_G), .S(VDD));
    generic_nmos I_1260(.D(VSS), .G(I_1260_G), .S(I_1417_S));

// Other incoming signals buffered here
// Buffers Incoming ~R/W (Pin 27) I_3529_G into I_3529_D (internal version)
  not auto_791(I_3529_D, I_3529_G);
    generic_pmos I_3529(.D(I_3529_D), .G(I_3529_G), .S(VDD));
    generic_nmos I_3528(.D(I_3529_D), .G(I_3529_G), .S(VSS));
// Buffers Incoming MAP (Pin 26) I_3971_G into I_3971_S (internal version)
  not auto_898(I_3971_S, I_3971_G);
    generic_pmos I_3971(.D(VDD), .G(I_3971_G), .S(I_3971_S));
    generic_nmos I_3938(.D(I_3971_S), .G(I_3971_G), .S(VSS));
// Buffers raw pin 7 (151_G) input.
  not auto_331(I_151_D, I_151_G);
    // Warning: 2 PMOS to 1 NMOS: Confirmed on die shot, no gate link to 2nd n-fet
    generic_pmos I_119(.D(VDD), .G(I_151_G), .S(I_151_D));
    generic_pmos I_151(.D(I_151_D), .G(I_151_G), .S(VDD));
    generic_nmos I_150(.D(I_151_D), .G(I_151_G), .S(VSS));
// Further splitting of 12 MHZ clock for main divider/delayed/derived timings
// Into flipflop chains "S" "T" "U" "V", Reset with "CC2" and 4 pole switch
// Also FF "CC1" (DRAM mux timings)
// I_95_D is a 12 MHz Clock (complement I_93_S)
// I_1623_D is a 12 MHz Clock (complement I_1753_S)
// I_503_D is a 12 MHz clock
  not auto_698(I_95_D, I_95_G); // NMOS strength = 3
    generic_pmos I_31(.D(I_95_D), .G(I_95_G), .S(VDD));
    generic_pmos I_63(.D(VDD), .G(I_95_G), .S(I_95_D));
    generic_pmos I_95(.D(I_95_D), .G(I_95_G), .S(VDD));
    generic_nmos I_30(.D(I_95_D), .G(I_95_G), .S(VSS));
    generic_nmos I_62(.D(VSS), .G(I_95_G), .S(I_95_D));
    generic_nmos I_94(.D(I_95_D), .G(I_95_G), .S(VSS));
  not auto_657(I_93_S, I_503_G); // NMOS strength = 3
    generic_pmos I_29(.D(VDD), .G(I_503_G), .S(I_93_S));
    generic_pmos I_61(.D(I_93_S), .G(I_503_G), .S(VDD));
    generic_pmos I_93(.D(VDD), .G(I_503_G), .S(I_93_S));
    generic_nmos I_28(.D(VSS), .G(I_503_G), .S(I_93_S));
    generic_nmos I_60(.D(I_93_S), .G(I_503_G), .S(VSS));
    generic_nmos I_92(.D(VSS), .G(I_503_G), .S(I_93_S));
  not auto_915(I_503_D, I_503_G);
    generic_pmos I_503(.D(I_503_D), .G(I_503_G), .S(VDD));
    generic_nmos I_502(.D(I_503_D), .G(I_503_G), .S(VSS));

// ********************************************************************************************************

// Boundary inverters on signals leaving chip (See Page 6)

// Octal inverting buffer, strength 2, for outgoing DRAM row/col address pins [RC0..RC7] in order 
// (Matched to order of A8-A15 at the external mux, not DRAM address pins which are scrambled!)
// Internal DRAM row/col bus [RC0..RC7] is I_3677_D,I_3995_D,I_3353_D,I_2077_D,I_2397_D,I_2717_D,I_2972_D,I_3357_D
  not auto_781(I_3519_D, I_3677_D); // NMOS strength = 2
    generic_pmos I_3487(.D(VDD), .G(I_3677_D), .S(I_3519_D));
    generic_pmos I_3519(.D(I_3519_D), .G(I_3677_D), .S(VDD));
    generic_nmos I_3486(.D(VSS), .G(I_3677_D), .S(I_3519_D));
    generic_nmos I_3518(.D(I_3519_D), .G(I_3677_D), .S(VSS));
  not auto_816(I_3675_D, I_3995_D); // NMOS strength = 2
    generic_pmos I_3643(.D(VDD), .G(I_3995_D), .S(I_3675_D));
    generic_pmos I_3675(.D(I_3675_D), .G(I_3995_D), .S(VDD));
    generic_nmos I_3642(.D(VSS), .G(I_3995_D), .S(I_3675_D));
    generic_nmos I_3674(.D(I_3675_D), .G(I_3995_D), .S(VSS));
  not auto_896(I_3999_D, I_3353_D); // NMOS strength = 2
    generic_pmos I_3967(.D(VDD), .G(I_3353_D), .S(I_3999_D));
    generic_pmos I_3999(.D(I_3999_D), .G(I_3353_D), .S(VDD));
    generic_nmos I_3966(.D(VSS), .G(I_3353_D), .S(I_3999_D));
    generic_nmos I_3998(.D(I_3999_D), .G(I_3353_D), .S(VSS));
  not auto_471(I_1919_D, I_2077_D); // NMOS strength = 2
    generic_pmos I_1887(.D(VDD), .G(I_2077_D), .S(I_1919_D));
    generic_pmos I_1919(.D(I_1919_D), .G(I_2077_D), .S(VDD));
    generic_nmos I_1886(.D(VSS), .G(I_2077_D), .S(I_1919_D));
    generic_nmos I_1918(.D(I_1919_D), .G(I_2077_D), .S(VSS));
  not auto_568(I_2399_D, I_2397_D); // NMOS strength = 2
    generic_pmos I_2367(.D(VDD), .G(I_2397_D), .S(I_2399_D));
    generic_pmos I_2399(.D(I_2399_D), .G(I_2397_D), .S(VDD));
    generic_nmos I_2366(.D(VSS), .G(I_2397_D), .S(I_2399_D));
    generic_nmos I_2398(.D(I_2399_D), .G(I_2397_D), .S(VSS));
  not auto_650(I_2879_D, I_2717_D); // NMOS strength = 2
    generic_pmos I_2847(.D(VDD), .G(I_2717_D), .S(I_2879_D));
    generic_pmos I_2879(.D(I_2879_D), .G(I_2717_D), .S(VDD));
    generic_nmos I_2846(.D(VSS), .G(I_2717_D), .S(I_2879_D));
    generic_nmos I_2878(.D(I_2879_D), .G(I_2717_D), .S(VSS));
  not auto_745(I_3359_D, I_2972_D); // NMOS strength = 2
    generic_pmos I_3327(.D(VDD), .G(I_2972_D), .S(I_3359_D));
    generic_pmos I_3359(.D(I_3359_D), .G(I_2972_D), .S(VDD));
    generic_nmos I_3326(.D(VSS), .G(I_2972_D), .S(I_3359_D));
    generic_nmos I_3358(.D(I_3359_D), .G(I_2972_D), .S(VSS));
  not auto_760(I_3423_D, I_3357_D); // NMOS strength = 2
    generic_pmos I_3391(.D(VDD), .G(I_3357_D), .S(I_3423_D));
    generic_pmos I_3423(.D(I_3423_D), .G(I_3357_D), .S(VDD));
    generic_nmos I_3390(.D(VSS), .G(I_3357_D), .S(I_3423_D));
    generic_nmos I_3422(.D(I_3423_D), .G(I_3357_D), .S(VSS));

// Outgoing signals buffered here
// Buffers Outgoing ~PHI I_277_D (internal version) into I_245_D (Pin 14)
  not auto_455(I_245_D, I_277_D); // NMOS strength = 3
    generic_pmos I_181(.D(I_245_D), .G(I_277_D), .S(VDD));
    generic_pmos I_213(.D(VDD), .G(I_277_D), .S(I_245_D));
    generic_pmos I_245(.D(I_245_D), .G(I_277_D), .S(VDD));
    generic_nmos I_180(.D(I_245_D), .G(I_277_D), .S(VSS));
    generic_nmos I_212(.D(VSS), .G(I_277_D), .S(I_245_D));
    generic_nmos I_244(.D(I_245_D), .G(I_277_D), .S(VSS));
// Buffers Outgoing DRAM Mux Sel I_1915_S (internal version) into I_1757_D (Pin 1)
  not auto_433(I_1757_D, I_1915_S); // NMOS strength = 2
    generic_pmos I_1725(.D(VDD), .G(I_1915_S), .S(I_1757_D));
    generic_pmos I_1757(.D(I_1757_D), .G(I_1915_S), .S(VDD));
    generic_nmos I_1724(.D(VSS), .G(I_1915_S), .S(I_1757_D));
    generic_nmos I_1756(.D(I_1757_D), .G(I_1915_S), .S(VSS));
// Buffers Outgoing ~ROMSEL I_3884_D (internal version) into I_3331_D (Pin 23)
  not auto_738(I_3331_D, I_3884_D); // NMOS strength = 2
    generic_pmos I_3299(.D(VDD), .G(I_3884_D), .S(I_3331_D));
    generic_pmos I_3331(.D(I_3331_D), .G(I_3884_D), .S(VDD));
    generic_nmos I_3298(.D(VSS), .G(I_3884_D), .S(I_3331_D));
    generic_nmos I_3330(.D(I_3331_D), .G(I_3884_D), .S(VSS));
// Buffers Outgoing IO I_3755_S (internal version) into I_3651_D (Pin 25)
  not auto_812(I_3651_D, I_3755_S); // NMOS strength = 2
    generic_pmos I_3619(.D(VDD), .G(I_3755_S), .S(I_3651_D));
    generic_pmos I_3651(.D(I_3651_D), .G(I_3755_S), .S(VDD));
    generic_nmos I_3618(.D(VSS), .G(I_3755_S), .S(I_3651_D));
    generic_nmos I_3650(.D(I_3651_D), .G(I_3755_S), .S(VSS));
// Buffers ~CAS I_1115_D (internal version) into I_59_D (Pin 9)
  not auto_622(I_59_D, I_1115_D); // NMOS strength = 2
    generic_pmos I_27(.D(VDD), .G(I_1115_D), .S(I_59_D));
    generic_pmos I_59(.D(I_59_D), .G(I_1115_D), .S(VDD));
    generic_nmos I_26(.D(VSS), .G(I_1115_D), .S(I_59_D));
    generic_nmos I_58(.D(I_59_D), .G(I_1115_D), .S(VSS));
// Buffers ~DRAM WREN (Dram R/W) I_3981_D (internal version) into I_3979_D (Pin 28)
  not auto_889(I_3979_D, I_3981_D); // NMOS strength = 2
    generic_pmos I_3947(.D(VDD), .G(I_3981_D), .S(I_3979_D));
    generic_pmos I_3979(.D(I_3979_D), .G(I_3981_D), .S(VDD));
    generic_nmos I_3946(.D(VSS), .G(I_3981_D), .S(I_3979_D));
    generic_nmos I_3978(.D(I_3979_D), .G(I_3981_D), .S(VSS));
// Buffers BLUE Video I_768_D (internal version) into I_705_D (Pin 21)
  not auto_944(I_705_D, I_768_D); // NMOS strength = 2
    generic_pmos I_673(.D(VDD), .G(I_768_D), .S(I_705_D));
    generic_pmos I_705(.D(I_705_D), .G(I_768_D), .S(VDD));
    generic_nmos I_672(.D(VSS), .G(I_768_D), .S(I_705_D));
    generic_nmos I_704(.D(I_705_D), .G(I_768_D), .S(VSS));
// Buffers GREEN Video I_448_D (internal version) into I_385_D (Pin 20)
  not auto_792(I_385_D, I_448_D); // NMOS strength = 2
    generic_pmos I_353(.D(VDD), .G(I_448_D), .S(I_385_D));
    generic_pmos I_385(.D(I_385_D), .G(I_448_D), .S(VDD));
    generic_nmos I_352(.D(VSS), .G(I_448_D), .S(I_385_D));
    generic_nmos I_384(.D(I_385_D), .G(I_448_D), .S(VSS));
// Buffers RED Video I_67_S/I_33_D (internal p,n version) into I_131_S,I_321_D (Pin 19)
  not auto_353(I_131_S, I_67_S);
    generic_pmos I_131(.D(VDD), .G(I_67_S), .S(I_131_S));
    generic_nmos I_98(.D(I_131_S), .G(I_67_S), .S(VSS));
  not auto_717(I_321_D, I_33_D);
    generic_pmos I_321(.D(I_321_D), .G(I_33_D), .S(VDD));
    generic_nmos I_320(.D(I_321_D), .G(I_33_D), .S(VSS));
// Buffers ~SYNC Video I_1889_D (internal version) into I_3_G (Pin 16)
  not auto_297(I_3_G, I_1889_D); // NMOS strength = 2
    generic_pmos I_1025(.D(I_3_G), .G(I_1889_D), .S(VDD));
    generic_pmos I_993(.D(VDD), .G(I_1889_D), .S(I_3_G));
    generic_nmos I_1024(.D(I_3_G), .G(I_1889_D), .S(VSS));
    generic_nmos I_992(.D(VSS), .G(I_1889_D), .S(I_3_G));

// ********************************************************************************************************

// Main Counter Divider (See Page 7)

// Set of 8 D-Type latches (common control clocks) (some with Asynchronous RESET) separate 639_S/159_S/637_D/1117_D/1311_G
// In 4 chains of 2 series devices to make flip-flops (S T U V) 
// Divides 12MHz clock down to 6MHz dot clock, 2 different 1 MHZ asymmetric clock (66% low, 33% high) and other 3MHz timing signals
// I_1279_S and I_1247_D are complementary 1MHz clocks
// Re-ordered as U V T S in increasing division of clock (b0..b3 of counter)

// Unlike every other flipflop, where the first latch's Q~ is only used to drive next's D, and Q unused,
// the mid-point's Q is taken as an external signal on these (U V S only) to detect "11" a beat *before* it is
// presented at the real Q outputs.

// Also these have RESET only in the FIRST part of the flipflop. Not connected in inverse to the second part to reset
// both (by setting one, resetting other!). This is important to the reset mechanism for this counter, otherwise it
// goes off half a beat early.

// Chain U
// D-Type Flip Flop D: I_575_S Q: I_511_D ~Q: I_575_S with Asynchronous RESET I_639_S Falling Clock: I_93_S, Rising: I_95_D
// WITH MID POINT: Q: I_415_S
// D-Type latch D: I_575_S ~Q: I_447_D Q: I_415_S with Asynchronous RESET I_639_S Clock: I_93_S, I_95_D
// 2:1 Mux with two controls: Inputs: I_575_S, I_415_S Output: I_319_D Controls: I_93_S, I_95_D
  generic_cmos pass_157(.gn(I_93_S), .gp(I_95_D), .p1(I_575_S), .p2(I_319_D));
    generic_pmos I_287(.D(I_575_S), .G(I_95_D), .S(I_319_D));
    generic_nmos I_286(.D(I_575_S), .G(I_93_S), .S(I_319_D));
  generic_cmos pass_188(.gn(I_95_D), .gp(I_93_S), .p1(I_319_D), .p2(I_415_S));
    generic_pmos I_319(.D(I_319_D), .G(I_93_S), .S(I_415_S));
    generic_nmos I_318(.D(I_319_D), .G(I_95_D), .S(I_415_S));
  nand auto_784(I_447_D, I_639_S, I_319_D);
    generic_pmos I_351(.D(VDD), .G(I_319_D), .S(I_447_D));
    generic_pmos I_383(.D(I_447_D), .G(I_639_S), .S(VDD));
    generic_nmos I_350(.D(I_447_D), .G(I_319_D), .S(I_382_D));
    generic_nmos I_382(.D(I_382_D), .G(I_639_S), .S(VSS));
  not auto_904(I_415_S, I_447_D);
    generic_pmos I_415(.D(VDD), .G(I_447_D), .S(I_415_S));
    generic_nmos I_414(.D(VSS), .G(I_447_D), .S(I_415_S));
// D-Type latch D: I_447_D ~Q: I_511_D Q: I_575_S Clock: I_93_S, I_95_D
// 2:1 Mux with two controls: Inputs: I_447_D, I_575_S Output: I_479_D Controls: I_95_D, I_93_S
  generic_cmos pass_242(.gn(I_95_D), .gp(I_93_S), .p1(I_447_D), .p2(I_479_D));
    generic_pmos I_447(.D(I_447_D), .G(I_93_S), .S(I_479_D));
    generic_nmos I_446(.D(I_447_D), .G(I_95_D), .S(I_479_D));
  generic_cmos pass_249(.gn(I_93_S), .gp(I_95_D), .p1(I_479_D), .p2(I_575_S));
    generic_pmos I_479(.D(I_479_D), .G(I_95_D), .S(I_575_S));
    generic_nmos I_478(.D(I_479_D), .G(I_93_S), .S(I_575_S));
  not auto_928(I_575_S, I_511_D);
    generic_pmos I_575(.D(VDD), .G(I_511_D), .S(I_575_S));
    generic_nmos I_574(.D(VSS), .G(I_511_D), .S(I_575_S));
  not auto_919(I_511_D, I_479_D);
    generic_pmos I_511(.D(I_511_D), .G(I_479_D), .S(VDD));
    generic_nmos I_510(.D(I_511_D), .G(I_479_D), .S(VSS));

// Chain V
// D-Type Flip Flop D: I_957_D Q: I_957_S ~Q: I_925_D with Asynchronous RESET I_799_S Falling Clock: I_93_S, Rising: I_95_D
// WITH MID POINT Q: I_733_S
// D-Type latch D: I_957_D ~Q: I_765_D Q: I_733_S with Asynchronous RESET I_799_S Clock: I_93_S, I_95_D
// 2:1 Mux with two controls: Inputs: I_957_D, I_733_S Output: I_637_D Controls: I_93_S, I_95_D
  generic_cmos pass_254(.gn(I_93_S), .gp(I_95_D), .p1(I_957_D), .p2(I_637_D));
    generic_pmos I_605(.D(I_957_D), .G(I_95_D), .S(I_637_D));
    generic_nmos I_604(.D(I_957_D), .G(I_93_S), .S(I_637_D));
  generic_cmos pass_259(.gn(I_95_D), .gp(I_93_S), .p1(I_637_D), .p2(I_733_S));
    generic_pmos I_637(.D(I_637_D), .G(I_93_S), .S(I_733_S));
    generic_nmos I_636(.D(I_637_D), .G(I_95_D), .S(I_733_S));
  nand auto_942(I_765_D, I_637_D, I_799_S);
    generic_pmos I_669(.D(VDD), .G(I_637_D), .S(I_765_D));
    generic_pmos I_701(.D(I_765_D), .G(I_799_S), .S(VDD));
    generic_nmos I_668(.D(I_765_D), .G(I_637_D), .S(I_700_D));
    generic_nmos I_700(.D(I_700_D), .G(I_799_S), .S(VSS));
  not auto_955(I_733_S, I_765_D);  
    generic_pmos I_733(.D(VDD), .G(I_765_D), .S(I_733_S));
    generic_nmos I_732(.D(VSS), .G(I_765_D), .S(I_733_S));
// D-Type latch D: I_765_D ~Q: I_957_S Q: I_925_D Clock: I_93_S, I_95_D
// 2:1 Mux with two controls: Inputs: I_765_D, I_925_D Output: I_797_D Controls: I_95_D, I_93_S
  generic_cmos pass_267(.gn(I_95_D), .gp(I_93_S), .p1(I_765_D), .p2(I_797_D));
    generic_pmos I_765(.D(I_765_D), .G(I_93_S), .S(I_797_D));
    generic_nmos I_764(.D(I_765_D), .G(I_95_D), .S(I_797_D));
  generic_cmos pass_274(.gn(I_93_S), .gp(I_95_D), .p1(I_797_D), .p2(I_925_D));
    generic_pmos I_797(.D(I_797_D), .G(I_95_D), .S(I_925_D));
    generic_nmos I_796(.D(I_797_D), .G(I_93_S), .S(I_925_D));
  not auto_977(I_925_D, I_957_S);
    generic_pmos I_893(.D(VDD), .G(I_957_S), .S(I_925_D));
    generic_nmos I_892(.D(VSS), .G(I_957_S), .S(I_925_D));
  not auto_965(I_957_S, I_797_D);
    generic_pmos I_829(.D(I_957_S), .G(I_797_D), .S(VDD));
    generic_nmos I_828(.D(I_957_S), .G(I_797_D), .S(VSS));

// Chain T
// D-Type Flip Flop D: I_477_D Q: I_477_S ~Q: I_445_D with Asynchronous RESET I_159_S Falling Clock: I_93_S, Rising: I_95_D
// D-Type latch D: I_477_D ~Q: I_285_D Q: I_253_S with Asynchronous RESET I_159_S Clock: I_93_S, I_95_D
// 2:1 Mux with two controls: Inputs: I_477_D, I_253_S Output: I_157_D Controls: I_93_S, I_95_D
  generic_cmos pass_23(.gn(I_93_S), .gp(I_95_D), .p1(I_477_D), .p2(I_157_D));
    generic_pmos I_125(.D(I_477_D), .G(I_95_D), .S(I_157_D));
    generic_nmos I_124(.D(I_477_D), .G(I_93_S), .S(I_157_D));
  generic_cmos pass_63(.gn(I_95_D), .gp(I_93_S), .p1(I_157_D), .p2(I_253_S));
    generic_pmos I_157(.D(I_157_D), .G(I_93_S), .S(I_253_S));
    generic_nmos I_156(.D(I_157_D), .G(I_95_D), .S(I_253_S));
  nand auto_472(I_285_D, I_159_S, I_157_D);
    generic_pmos I_189(.D(VDD), .G(I_157_D), .S(I_285_D));
    generic_pmos I_221(.D(I_285_D), .G(I_159_S), .S(VDD));
    generic_nmos I_188(.D(I_285_D), .G(I_157_D), .S(I_220_D));
    generic_nmos I_220(.D(I_220_D), .G(I_159_S), .S(VSS));
  not auto_596(I_253_S, I_285_D);
    generic_pmos I_253(.D(VDD), .G(I_285_D), .S(I_253_S));
    generic_nmos I_252(.D(VSS), .G(I_285_D), .S(I_253_S));
// D-Type latch D: I_285_D ~Q: I_477_S Q: I_445_D Clock: I_93_S, I_95_D
// 2:1 Mux with two controls: Inputs: I_285_D, I_445_D Output: I_317_D Controls: I_95_D, I_93_S
  generic_cmos pass_153(.gn(I_95_D), .gp(I_93_S), .p1(I_285_D), .p2(I_317_D));
    generic_pmos I_285(.D(I_285_D), .G(I_93_S), .S(I_317_D));
    generic_nmos I_284(.D(I_285_D), .G(I_95_D), .S(I_317_D));
  generic_cmos pass_182(.gn(I_93_S), .gp(I_95_D), .p1(I_317_D), .p2(I_445_D));
    generic_pmos I_317(.D(I_317_D), .G(I_95_D), .S(I_445_D));
    generic_nmos I_316(.D(I_317_D), .G(I_93_S), .S(I_445_D));
  not auto_903(I_445_D, I_477_S);  
    generic_pmos I_413(.D(VDD), .G(I_477_S), .S(I_445_D));
    generic_nmos I_412(.D(VSS), .G(I_477_S), .S(I_445_D));
  not auto_782(I_477_S, I_317_D);
    generic_pmos I_349(.D(I_477_S), .G(I_317_D), .S(VDD));
    generic_nmos I_348(.D(I_477_S), .G(I_317_D), .S(VSS));

// Chain S
// D-Type Flip Flop D: I_1279_D Q: I_1279_S ~Q: I_1247_D with Asynchronous RESET I_1117_D Falling Clock: I_93_S, Rising: I_95_D
// WITH MID POINT Q I_1055_S
// D-Type latch D: I_1279_D ~Q: I_1087_D Q: I_1055_S with Asynchronous RESET I_1117_D Clock: I_93_S, I_95_D
// 2:1 Mux with two controls: Inputs: I_1279_D, I_1055_S Output: I_959_D Controls: I_93_S, I_95_D
  generic_cmos pass_282(.gn(I_93_S), .gp(I_95_D), .p1(I_1279_D), .p2(I_959_D));
    generic_pmos I_927(.D(I_1279_D), .G(I_95_D), .S(I_959_D));
    generic_nmos I_926(.D(I_1279_D), .G(I_93_S), .S(I_959_D));
  generic_cmos pass_289(.gn(I_95_D), .gp(I_93_S), .p1(I_959_D), .p2(I_1055_S));
    generic_pmos I_959(.D(I_959_D), .G(I_93_S), .S(I_1055_S));
    generic_nmos I_958(.D(I_959_D), .G(I_95_D), .S(I_1055_S));
  nand auto_296(I_1087_D, I_1117_D, I_959_D);
    generic_pmos I_1023(.D(I_1087_D), .G(I_1117_D), .S(VDD));
    generic_pmos I_991(.D(VDD), .G(I_959_D), .S(I_1087_D));
    generic_nmos I_990(.D(I_1087_D), .G(I_959_D), .S(I_1022_D));
    generic_nmos I_1022(.D(I_1022_D), .G(I_1117_D), .S(VSS));
  not auto_303(I_1055_S, I_1087_D);
    generic_pmos I_1055(.D(VDD), .G(I_1087_D), .S(I_1055_S));
    generic_nmos I_1054(.D(VSS), .G(I_1087_D), .S(I_1055_S));
// D-Type latch D: I_1087_D ~Q: I_1279_S Q: I_1247_D Clock: I_93_S, I_95_D
// 2:1 Mux with two controls: Inputs: I_1247_D, I_1087_D Output: I_1119_D Controls: I_93_S, I_95_D
  generic_cmos pass_11(.gn(I_93_S), .gp(I_95_D), .p1(I_1119_D), .p2(I_1247_D));
    generic_pmos I_1119(.D(I_1119_D), .G(I_95_D), .S(I_1247_D));
    generic_nmos I_1118(.D(I_1119_D), .G(I_93_S), .S(I_1247_D));
  generic_cmos pass_6(.gn(I_95_D), .gp(I_93_S), .p1(I_1087_D), .p2(I_1119_D));
    generic_pmos I_1087(.D(I_1087_D), .G(I_93_S), .S(I_1119_D));
    generic_nmos I_1086(.D(I_1087_D), .G(I_95_D), .S(I_1119_D));
  not auto_334(I_1247_D, I_1279_S);
    generic_pmos I_1215(.D(VDD), .G(I_1279_S), .S(I_1247_D));
    generic_nmos I_1214(.D(VSS), .G(I_1279_S), .S(I_1247_D));
  not auto_323(I_1279_S, I_1119_D);
    generic_pmos I_1151(.D(I_1279_S), .G(I_1119_D), .S(VDD));
    generic_nmos I_1150(.D(I_1279_S), .G(I_1119_D), .S(VSS));

// These gates pass on the overflowing count stages via multiplexers
// to make it a synchronous counter

  nand auto_925(I_573_D, I_511_D, I_957_S);
    generic_pmos I_541(.D(VDD), .G(I_511_D), .S(I_573_D));
    generic_pmos I_573(.D(I_573_D), .G(I_957_S), .S(VDD));
    generic_nmos I_572(.D(I_572_D), .G(I_957_S), .S(I_573_D));
    generic_nmos I_540(.D(VSS), .G(I_511_D), .S(I_572_D));
  nand auto_322(I_1213_D, I_957_S, I_511_D, I_477_S);
    generic_pmos I_1149(.D(I_1213_D), .G(I_957_S), .S(VDD));
    generic_pmos I_1181(.D(VDD), .G(I_511_D), .S(I_1213_D));
    generic_pmos I_1213(.D(I_1213_D), .G(I_477_S), .S(VDD));
    generic_nmos I_1148(.D(I_1213_D), .G(I_957_S), .S(I_1180_D));
    generic_nmos I_1180(.D(I_1180_D), .G(I_511_D), .S(I_1212_D));
    generic_nmos I_1212(.D(I_1212_D), .G(I_477_S), .S(VSS));

// Single Muxes -- used with chain V, T, S to control when overflow/clock is passed to next stage

// Use with chain V
// Which sense?: When 735_D is high/989_D low: 281 on, 288 off, so output = I_925_D (~Q of FF)
// Which sense?: When 989_D is high/735_D low: 288 on, 281 off, so output = I_957_S (Q of FF)
// 
// 2:1 Mux with two controls: Inputs: I_925_D, I_957_S Output: I_957_D Controls: I_735_D, I_989_D
  generic_cmos pass_281(.gn(I_735_D), .gp(I_989_D), .p1(I_925_D), .p2(I_957_D));
    generic_pmos I_925(.D(I_925_D), .G(I_989_D), .S(I_957_D));
    generic_nmos I_924(.D(I_925_D), .G(I_735_D), .S(I_957_D));
  generic_cmos pass_288(.gn(I_989_D), .gp(I_735_D), .p1(I_957_D), .p2(I_957_S));
    generic_pmos I_957(.D(I_957_D), .G(I_735_D), .S(I_957_S));
    generic_nmos I_956(.D(I_957_D), .G(I_989_D), .S(I_957_S));

// Use with chain T
// Which sense?: When 573_D is high: 248 on output = I_477_S (Q of FF)
// 2:1 Mux with single control: Inputs: I_445_D, I_477_S Output: I_477_D Control: I_573_D
  generic_cmos pass_241(.gn(I_509_D), .gp(I_573_D), .p1(I_445_D), .p2(I_477_D));
    generic_pmos I_445(.D(I_445_D), .G(I_573_D), .S(I_477_D));
    generic_nmos I_444(.D(I_445_D), .G(I_509_D), .S(I_477_D));
  generic_cmos pass_248(.gn(I_573_D), .gp(I_509_D), .p1(I_477_D), .p2(I_477_S));
    generic_pmos I_477(.D(I_477_D), .G(I_509_D), .S(I_477_S));
    generic_nmos I_476(.D(I_477_D), .G(I_573_D), .S(I_477_S));
// Driver
  not auto_918(I_509_D, I_573_D);
    generic_pmos I_509(.D(I_509_D), .G(I_573_D), .S(VDD));
    generic_nmos I_508(.D(I_509_D), .G(I_573_D), .S(VSS));

// Use with chain S
// Which sense?: When 1213_D is high: 32 on output = I_1279_S (Q of FF)
// 2:1 Mux with single control: Inputs: I_1247_D, I_1279_S Output: I_1279_D Control: I_1213_D
  generic_cmos pass_22(.gn(I_1469_D), .gp(I_1213_D), .p1(I_1247_D), .p2(I_1279_D));
    generic_pmos I_1247(.D(I_1247_D), .G(I_1213_D), .S(I_1279_D));
    generic_nmos I_1246(.D(I_1247_D), .G(I_1469_D), .S(I_1279_D));
  generic_cmos pass_32(.gn(I_1213_D), .gp(I_1469_D), .p1(I_1279_D), .p2(I_1279_S));
    generic_pmos I_1279(.D(I_1279_D), .G(I_1469_D), .S(I_1279_S));
    generic_nmos I_1278(.D(I_1279_D), .G(I_1213_D), .S(I_1279_S));
// Driver
  not auto_385(I_1469_D, I_1213_D);
    generic_pmos I_1469(.D(I_1469_D), .G(I_1213_D), .S(VDD));
    generic_nmos I_1468(.D(I_1469_D), .G(I_1213_D), .S(VSS));

// ********************************************************************************************************

// This section resets the main clock divider/counter (around count 11)
  nand auto_966(I_1439_S, I_415_S, I_733_S, I_1055_S);
    generic_pmos I_831(.D(I_1439_S), .G(I_415_S), .S(VDD));
    generic_pmos I_863(.D(VDD), .G(I_733_S), .S(I_1439_S));
    generic_pmos I_895(.D(I_1439_S), .G(I_1055_S), .S(VDD));
    generic_nmos I_830(.D(I_1439_S), .G(I_415_S), .S(I_862_D));
    generic_nmos I_862(.D(I_862_D), .G(I_733_S), .S(I_894_D));
    generic_nmos I_894(.D(I_894_D), .G(I_1055_S), .S(VSS));

// Single d-latch to delay/synch resetting
// For counter reset circuit (was CC2 "clock circuit 2")
// I_1311_G is external reset
// D-Type latch D: I_1439_S ~Q: I_1343_D Q: I_1407_D  with Asynchronous RESET I_1311_G Falling Clock: I_95_D, Rising: I_93_S
// 2:1 Mux with two controls: Inputs: I_1407_D, I_1439_S Output: I_1439_D Controls: I_93_S, I_95_D
  generic_cmos pass_43(.gn(I_93_S), .gp(I_95_D), .p1(I_1407_D), .p2(I_1439_D));
    generic_pmos I_1407(.D(I_1407_D), .G(I_95_D), .S(I_1439_D));
    generic_nmos I_1406(.D(I_1407_D), .G(I_93_S), .S(I_1439_D));
  generic_cmos pass_53(.gn(I_95_D), .gp(I_93_S), .p1(I_1439_D), .p2(I_1439_S));
    generic_pmos I_1439(.D(I_1439_D), .G(I_93_S), .S(I_1439_S));
    generic_nmos I_1438(.D(I_1439_D), .G(I_95_D), .S(I_1439_S));
  nand auto_354(I_1343_D, I_1311_G, I_1439_D);
    generic_pmos I_1311(.D(VDD), .G(I_1311_G), .S(I_1343_D));
    generic_pmos I_1343(.D(I_1343_D), .G(I_1439_D), .S(VDD));
    generic_nmos I_1310(.D(I_1343_D), .G(I_1311_G), .S(I_1342_D));
    generic_nmos I_1342(.D(I_1342_D), .G(I_1439_D), .S(VSS));
  not auto_340(I_1407_D, I_1343_D);
    // Warning: 2 PMOS to 1 NMOS: 1244 is actually NC on die!
    generic_pmos I_1245(.D(I_1407_D), .G(I_1343_D), .S(VDD));
    generic_pmos I_1277(.D(VDD), .G(I_1343_D), .S(I_1407_D));
    generic_nmos I_1276(.D(VSS), .G(I_1343_D), .S(I_1407_D));

// 4 pole switch joining 4 signals I_1117_D,I_639_S,I_799_S,I_159_S to 1 I_1407_D
// Closes on clock: I_93_S high side/I_95_D low side
// Clocked with Flipflop chains S/T/U/V and others
// Part of reset circuit for main divider counter
  generic_cmos pass_10(.gn(I_93_S), .gp(I_95_D), .p1(I_1117_D), .p2(I_1407_D));
    generic_pmos I_1117(.D(I_1117_D), .G(I_95_D), .S(I_1407_D));
    generic_nmos I_1084(.D(I_1117_D), .G(I_93_S), .S(I_1407_D));
  generic_cmos pass_260(.gn(I_93_S), .gp(I_95_D), .p1(I_1407_D), .p2(I_639_S));
    generic_pmos I_639(.D(I_1407_D), .G(I_95_D), .S(I_639_S));
    generic_nmos I_606(.D(I_1407_D), .G(I_93_S), .S(I_639_S));
  generic_cmos pass_275(.gn(I_93_S), .gp(I_95_D), .p1(I_1407_D), .p2(I_799_S));
    generic_pmos I_799(.D(I_1407_D), .G(I_95_D), .S(I_799_S));
    generic_nmos I_766(.D(I_1407_D), .G(I_93_S), .S(I_799_S));
  generic_cmos pass_67(.gn(I_93_S), .gp(I_95_D), .p1(I_1407_D), .p2(I_159_S));
    generic_pmos I_159(.D(I_1407_D), .G(I_95_D), .S(I_159_S));
    generic_nmos I_126(.D(I_1407_D), .G(I_93_S), .S(I_159_S));

// An additional reset circuit resets this counter AND all the video counters.
// Pin 19 (Red video) and Pad 21A feed in here with the video sync output to reset flip/flop CC2
// This does external reset from Pad 21A (at any time) and Pin 19 (only during sync)
// Possible genlock input secret feature on red video? Or factory-test reset for analysing ULA behaviour on scope?
// I_1311_G, I_1345_D are reset lines out of this to elsewhere (all other video counters)
// I_1889_D drives the inverter that makes composite SYNC out.
  not auto_342(I_1311_G, I_1345_D);
    generic_pmos I_1283(.D(I_1311_G), .G(I_1345_D), .S(VDD));
    generic_nmos I_1282(.D(I_1311_G), .G(I_1345_D), .S(VSS));
  nand auto_355(I_1345_D, I_1313_G, I_1409_D);
    generic_pmos I_1313(.D(VDD), .G(I_1313_G), .S(I_1345_D));
    generic_pmos I_1345(.D(I_1345_D), .G(I_1409_D), .S(VDD));
    generic_nmos I_1344(.D(I_1344_D), .G(I_1409_D), .S(I_1345_D));
    generic_nmos I_1312(.D(VSS), .G(I_1313_G), .S(I_1344_D));
  nand auto_368(I_1409_D, I_1889_D, I_1408_G);
    generic_pmos I_1377(.D(VDD), .G(I_1408_G), .S(I_1409_D));
    generic_pmos I_1409(.D(I_1409_D), .G(I_1889_D), .S(VDD));
    generic_nmos I_1376(.D(I_1409_D), .G(I_1889_D), .S(I_1408_D));
    generic_nmos I_1408(.D(I_1408_D), .G(I_1408_G), .S(VSS));

// ********************************************************************************************************

// These gates combine and buffer the count bits to create master timing signals

  // 6MHZ clock here (CAS related)
  not auto_949(I_735_D, I_575_S); // NMOS strength = 2
    generic_pmos I_703(.D(VDD), .G(I_575_S), .S(I_735_D));
    generic_pmos I_735(.D(I_735_D), .G(I_575_S), .S(VDD));
    generic_nmos I_702(.D(VSS), .G(I_575_S), .S(I_735_D));
    generic_nmos I_734(.D(I_735_D), .G(I_575_S), .S(VSS));
  // 6MHZ clock here (dot clock)
  not auto_990(I_989_D, I_511_D);
    generic_pmos I_989(.D(I_989_D), .G(I_511_D), .S(VDD));
    generic_nmos I_988(.D(I_989_D), .G(I_511_D), .S(VSS));
  // CAS related timing
  nand auto_339(I_1275_D, I_1307_D, I_735_D);
    generic_pmos I_1243(.D(VDD), .G(I_735_D), .S(I_1275_D));
    generic_pmos I_1275(.D(I_1275_D), .G(I_1307_D), .S(VDD));
    generic_nmos I_1242(.D(I_1275_D), .G(I_1307_D), .S(I_1274_D));
    generic_nmos I_1274(.D(I_1274_D), .G(I_735_D), .S(VSS));
  // DRAM Hi-low address muxing
  nor auto_373(I_1913_S, I_1397_D, I_735_D);
    generic_pmos I_1405(.D(VDD), .G(I_735_D), .S(I_1437_D));
    generic_pmos I_1437(.D(I_1437_D), .G(I_1397_D), .S(I_1913_S));
    generic_nmos I_1404(.D(VSS), .G(I_1397_D), .S(I_1913_S));
    generic_nmos I_1436(.D(I_1913_S), .G(I_735_D), .S(VSS));
  not auto_351(I_1307_D, I_957_S);
    generic_pmos I_1307(.D(I_1307_D), .G(I_957_S), .S(VDD));
    generic_nmos I_1306(.D(I_1307_D), .G(I_957_S), .S(VSS));
  // Load Video SR/RAS related
  not auto_295(I_1397_D, I_925_D); // NMOS strength = 2
    generic_pmos I_1021(.D(VDD), .G(I_925_D), .S(I_1397_D));
    generic_pmos I_1053(.D(I_1397_D), .G(I_925_D), .S(VDD));
    generic_nmos I_1020(.D(VSS), .G(I_925_D), .S(I_1397_D));
    generic_nmos I_1052(.D(I_1397_D), .G(I_925_D), .S(VSS));
  // Load attribute registers
  nand auto_321(I_1211_D, I_1051_S, I_735_D, I_1397_D);
    generic_pmos I_1147(.D(I_1211_D), .G(I_735_D), .S(VDD));
    generic_pmos I_1179(.D(VDD), .G(I_1051_S), .S(I_1211_D));
    generic_pmos I_1211(.D(I_1211_D), .G(I_1397_D), .S(VDD));
    generic_nmos I_1146(.D(I_1211_D), .G(I_735_D), .S(I_1178_D));
    generic_nmos I_1178(.D(I_1178_D), .G(I_1051_S), .S(I_1210_D));
    generic_nmos I_1210(.D(I_1210_D), .G(I_1397_D), .S(VSS));
  // 1MHZ clock (Active when ULA in phase 2)
  not auto_302(I_1051_S, I_445_D); // NMOS strength = 2
    generic_pmos I_1051(.D(VDD), .G(I_445_D), .S(I_1051_S));
    generic_pmos I_987(.D(I_1051_S), .G(I_445_D), .S(VDD));
    generic_nmos I_1050(.D(VSS), .G(I_445_D), .S(I_1051_S));
    generic_nmos I_986(.D(I_1051_S), .G(I_445_D), .S(VSS));
  // Loads 8 bit latch from databus
  nor auto_371(I_1435_D, I_1307_D, I_1373_S, I_1051_S);
    generic_pmos I_1339(.D(VDD), .G(I_1307_D), .S(I_1371_D));
    generic_pmos I_1371(.D(I_1371_D), .G(I_1051_S), .S(I_1403_D));
    generic_pmos I_1403(.D(I_1403_D), .G(I_1373_S), .S(I_1435_D));
    generic_nmos I_1338(.D(VSS), .G(I_1307_D), .S(I_1435_D));
    generic_nmos I_1370(.D(I_1435_D), .G(I_1051_S), .S(VSS));
    generic_nmos I_1434(.D(VSS), .G(I_1373_S), .S(I_1435_D));
  // 1MHz clock (Phi, inverted)
  not auto_464(I_1853_S, I_1279_S); // NMOS strength = 2
    generic_pmos I_1851(.D(VDD), .G(I_1279_S), .S(I_1853_S));
    generic_pmos I_1853(.D(VDD), .G(I_1279_S), .S(I_1853_S));
    generic_nmos I_1850(.D(VSS), .G(I_1279_S), .S(I_1853_S));
    generic_nmos I_1852(.D(VSS), .G(I_1279_S), .S(I_1853_S));
  // 1MHz clock (Phi, matches external clock to 6502)
  not auto_367(I_1373_S, I_1247_D);
    generic_pmos I_1373(.D(VDD), .G(I_1247_D), .S(I_1373_S));
    generic_nmos I_1372(.D(VSS), .G(I_1247_D), .S(I_1373_S));

// ********************************************************************************************************

// Delayed and derived timings (See Page 8)

// Tree of 4-5 deep NOT gates eventually providing a (delayed) 12 MHZ clock for flipflop chains "W" and "X"
// I_1589_S is a 12 MHz Clock (complement I_1749_S)
// I_1623_D is a 12 MHz Clock (complement I_1753_S)
//
  not auto_421(I_1685_D, I_151_D);
    generic_pmos I_1653(.D(VDD), .G(I_151_D), .S(I_1685_D));
    generic_nmos I_1652(.D(VSS), .G(I_151_D), .S(I_1685_D));
  not auto_400(I_1588_S, I_1685_D);
    generic_pmos I_1557(.D(I_1588_S), .G(I_1685_D), .S(VDD));
    generic_nmos I_1588(.D(VSS), .G(I_1685_D), .S(I_1588_S));
  not auto_403(I_1589_S, I_1588_S);  
    generic_pmos I_1589(.D(VDD), .G(I_1588_S), .S(I_1589_S));
    generic_nmos I_1556(.D(I_1589_S), .G(I_1588_S), .S(VSS));
  not auto_426(I_1687_S, I_1685_D);
    generic_pmos I_1687(.D(VDD), .G(I_1685_D), .S(I_1687_S));
    generic_nmos I_1686(.D(VSS), .G(I_1685_D), .S(I_1687_S));
  not auto_411(I_1623_D, I_1687_S);
    generic_pmos I_1623(.D(I_1623_D), .G(I_1687_S), .S(VDD));
    generic_nmos I_1622(.D(I_1623_D), .G(I_1687_S), .S(VSS));
  not auto_431(I_1750_S, I_151_D);
    generic_pmos I_1719(.D(I_1750_S), .G(I_151_D), .S(VDD));
    generic_nmos I_1750(.D(VSS), .G(I_151_D), .S(I_1750_S));
  not auto_437(I_1751_S, I_1750_S);
    generic_pmos I_1751(.D(VDD), .G(I_1750_S), .S(I_1751_S));
    generic_nmos I_1718(.D(I_1751_S), .G(I_1750_S), .S(VSS));
  not auto_430(I_1748_S, I_1751_S);
    generic_pmos I_1717(.D(I_1748_S), .G(I_1751_S), .S(VDD));
    generic_nmos I_1748(.D(VSS), .G(I_1751_S), .S(I_1748_S));
  not auto_436(I_1749_S, I_1748_S);
    generic_pmos I_1749(.D(VDD), .G(I_1748_S), .S(I_1749_S));
    generic_nmos I_1716(.D(I_1749_S), .G(I_1748_S), .S(VSS));
  not auto_432(I_1752_S, I_1751_S);
    generic_pmos I_1721(.D(I_1752_S), .G(I_1751_S), .S(VDD));
    generic_nmos I_1752(.D(VSS), .G(I_1751_S), .S(I_1752_S));
  not auto_438(I_1753_S, I_1752_S);
    generic_pmos I_1753(.D(VDD), .G(I_1752_S), .S(I_1753_S));
    generic_nmos I_1720(.D(I_1753_S), .G(I_1752_S), .S(VSS));

// 2 Ganged D-Type latches (common control clock)
// In 1 chain of 2 series devices (W)
// Chain (W) - RAS related
// D-Type Flip Flop D: I_1397_D Q: I_1491_D ~Q: I_1523_S Falling Clock: I_1749_S, Rising: I_1589_S
// D-Type latch D: I_1397_D ~Q: I_1525_D Q: I_1461_D Clock: I_1589_S, I_1749_S
// 2:1 Mux with two controls: Inputs: I_1397_D, I_1461_D Output: I_1429_D Controls: I_1589_S, I_1749_S
  generic_cmos pass_40(.gn(I_1749_S), .gp(I_1589_S), .p1(I_1397_D), .p2(I_1429_D));
    generic_pmos I_1397(.D(I_1397_D), .G(I_1589_S), .S(I_1429_D));
    generic_nmos I_1396(.D(I_1397_D), .G(I_1749_S), .S(I_1429_D));
  generic_cmos pass_50(.gn(I_1589_S), .gp(I_1749_S), .p1(I_1429_D), .p2(I_1461_D));
    generic_pmos I_1429(.D(I_1429_D), .G(I_1749_S), .S(I_1461_D));
    generic_nmos I_1428(.D(I_1429_D), .G(I_1589_S), .S(I_1461_D));
  not auto_381(I_1461_D, I_1525_D);
    generic_pmos I_1461(.D(I_1461_D), .G(I_1525_D), .S(VDD));
    generic_nmos I_1460(.D(I_1461_D), .G(I_1525_D), .S(VSS));
  not auto_390(I_1525_D, I_1429_D); // NMOS strength = 2
    generic_pmos I_1493(.D(VDD), .G(I_1429_D), .S(I_1525_D));
    generic_pmos I_1525(.D(I_1525_D), .G(I_1429_D), .S(VDD));
    generic_nmos I_1492(.D(VSS), .G(I_1429_D), .S(I_1525_D));
    generic_nmos I_1524(.D(I_1525_D), .G(I_1429_D), .S(VSS));
// D-Type latch D: I_1525_D ~Q: I_1491_D Q: I_1523_S Clock: I_1589_S, I_1749_S
// 2:1 Mux with two controls: Inputs: I_1525_D, I_1523_S Output: I_1427_D Controls: I_1589_S, I_1749_S
  generic_cmos pass_39(.gn(I_1589_S), .gp(I_1749_S), .p1(I_1525_D), .p2(I_1427_D));
    generic_pmos I_1395(.D(I_1525_D), .G(I_1749_S), .S(I_1427_D));
    generic_nmos I_1394(.D(I_1525_D), .G(I_1589_S), .S(I_1427_D));
  generic_cmos pass_49(.gn(I_1749_S), .gp(I_1589_S), .p1(I_1427_D), .p2(I_1523_S));
    generic_pmos I_1427(.D(I_1427_D), .G(I_1589_S), .S(I_1523_S));
    generic_nmos I_1426(.D(I_1427_D), .G(I_1749_S), .S(I_1523_S));
  not auto_396(I_1523_S, I_1491_D);
    generic_pmos I_1523(.D(VDD), .G(I_1491_D), .S(I_1523_S));
    generic_nmos I_1522(.D(VSS), .G(I_1491_D), .S(I_1523_S));
  not auto_380(I_1491_D, I_1427_D); // NMOS strength = 2
    generic_pmos I_1459(.D(VDD), .G(I_1427_D), .S(I_1491_D));
    generic_pmos I_1491(.D(I_1491_D), .G(I_1427_D), .S(VDD));
    generic_nmos I_1458(.D(VSS), .G(I_1427_D), .S(I_1491_D));
    generic_nmos I_1490(.D(I_1491_D), .G(I_1427_D), .S(VSS));

// Chain W then drives through 4 NAND gates as inverters (delay) to drive the RAS pin
  nand auto_364(I_1365_S, I_1523_S, I_1523_S);
    // Warning: Actually INVERTER with P's in series
    generic_pmos I_1333(.D(VDD), .G(I_1523_S), .S(I_1365_D));
    generic_pmos I_1365(.D(I_1365_D), .G(I_1523_S), .S(I_1365_S));
    generic_nmos I_1364(.D(I_1364_D), .G(I_1523_S), .S(I_1365_S));
    generic_nmos I_1332(.D(VSS), .G(I_1523_S), .S(I_1364_D));
  nand auto_361(I_1331_D, I_1365_S, I_1365_S);
    // Warning: Actually INVERTER with P's in series
    generic_pmos I_1363(.D(I_1363_D), .G(I_1365_S), .S(VDD));
    generic_pmos I_1331(.D(I_1331_D), .G(I_1365_S), .S(I_1363_D));
    generic_nmos I_1330(.D(I_1331_D), .G(I_1365_S), .S(I_1362_D));
    generic_nmos I_1362(.D(I_1362_D), .G(I_1365_S), .S(VSS));
  nand auto_981(I_917_D, I_1331_D, I_1331_D);
    // Warning: Actually INVERTER with P's in series
    generic_pmos I_949(.D(I_949_D), .G(I_1331_D), .S(VDD));
    generic_pmos I_917(.D(I_917_D), .G(I_1331_D), .S(I_949_D));
    generic_nmos I_916(.D(I_917_D), .G(I_1331_D), .S(I_948_D));
    generic_nmos I_948(.D(I_948_D), .G(I_1331_D), .S(VSS));
  nand auto_961(I_821_D, I_917_D, I_917_D);
    // Warning: Actually INVERTER with P's in series
    generic_pmos I_853(.D(I_853_D), .G(I_917_D), .S(VDD));
    generic_pmos I_821(.D(I_821_D), .G(I_917_D), .S(I_853_D));
    generic_nmos I_820(.D(I_821_D), .G(I_917_D), .S(I_852_D));
    generic_nmos I_852(.D(I_852_D), .G(I_917_D), .S(VSS));

// Controls reloading of video shift register when time is right and latched data is NOT an attribute (i.e. video data)
  nand auto_447(I_1845_D, I_1051_S, I_1397_D, I_457_D);
    generic_pmos I_1781(.D(I_1845_D), .G(I_1051_S), .S(VDD));
    generic_pmos I_1813(.D(VDD), .G(I_1397_D), .S(I_1845_D));
    generic_pmos I_1845(.D(I_1845_D), .G(I_457_D), .S(VDD));
    generic_nmos I_1780(.D(I_1845_D), .G(I_1051_S), .S(I_1812_D));
    generic_nmos I_1812(.D(I_1812_D), .G(I_1397_D), .S(I_1844_D));
    generic_nmos I_1844(.D(I_1844_D), .G(I_457_D), .S(VSS));

// 2 Ganged D-Type latches (common control clock)
// In 1 chain of 2 series devices (X)
// Chain (X) (Video Shift Reg Reload)
// 2 Ganged D-Type latches
// D-Type Flip Flop D: I_1845_D Q: I_1529_D ~Q: I_1561_D Falling Clock: I_1753_S, Rising: I_1623_D
// D-Type latch D: I_1845_D ~Q: I_1593_S Q: I_1559_D Clock: I_1623_D, I_1753_S
// 2:1 Mux with two controls: Inputs: I_1559_D, I_1845_D Output: I_1591_D Controls: I_1623_D, I_1753_S
  generic_cmos pass_60(.gn(I_1623_D), .gp(I_1753_S), .p1(I_1559_D), .p2(I_1591_D));
    generic_pmos I_1559(.D(I_1559_D), .G(I_1753_S), .S(I_1591_D));
    generic_nmos I_1558(.D(I_1559_D), .G(I_1623_D), .S(I_1591_D));
  generic_cmos pass_68(.gn(I_1753_S), .gp(I_1623_D), .p1(I_1591_D), .p2(I_1845_D));
    generic_pmos I_1591(.D(I_1591_D), .G(I_1623_D), .S(I_1845_D));
    generic_nmos I_1590(.D(I_1591_D), .G(I_1753_S), .S(I_1845_D));
  not auto_382(I_1559_D, I_1593_S);
    generic_pmos I_1463(.D(I_1559_D), .G(I_1593_S), .S(VDD));
    generic_nmos I_1462(.D(I_1559_D), .G(I_1593_S), .S(VSS));
  not auto_391(I_1593_S, I_1591_D); // NMOS strength = 2
    generic_pmos I_1495(.D(VDD), .G(I_1591_D), .S(I_1593_S));
    generic_pmos I_1527(.D(I_1593_S), .G(I_1591_D), .S(VDD));
    generic_nmos I_1494(.D(VSS), .G(I_1591_D), .S(I_1593_S));
    generic_nmos I_1526(.D(I_1593_S), .G(I_1591_D), .S(VSS));
// D-Type latch D: I_1593_S ~Q: I_1529_D Q: I_1561_D Clock: I_1623_D, I_1753_S
// 2:1 Mux with two controls: Inputs: I_1561_D, I_1593_S Output: I_1593_D Controls: I_1623_D, I_1753_S
  generic_cmos pass_61(.gn(I_1753_S), .gp(I_1623_D), .p1(I_1561_D), .p2(I_1593_D));
    generic_pmos I_1561(.D(I_1561_D), .G(I_1623_D), .S(I_1593_D));
    generic_nmos I_1560(.D(I_1561_D), .G(I_1753_S), .S(I_1593_D));
  generic_cmos pass_69(.gn(I_1623_D), .gp(I_1753_S), .p1(I_1593_D), .p2(I_1593_S));
    generic_pmos I_1593(.D(I_1593_D), .G(I_1753_S), .S(I_1593_S));
    generic_nmos I_1592(.D(I_1593_D), .G(I_1623_D), .S(I_1593_S));
  not auto_383(I_1561_D, I_1529_D);
    generic_pmos I_1465(.D(I_1561_D), .G(I_1529_D), .S(VDD));
    generic_nmos I_1464(.D(I_1561_D), .G(I_1529_D), .S(VSS));
  not auto_392(I_1529_D, I_1593_D); // NMOS strength = 2
    generic_pmos I_1497(.D(VDD), .G(I_1593_D), .S(I_1529_D));
    generic_pmos I_1529(.D(I_1529_D), .G(I_1593_D), .S(VDD));
    generic_nmos I_1496(.D(VSS), .G(I_1593_D), .S(I_1529_D));
    generic_nmos I_1528(.D(I_1529_D), .G(I_1593_D), .S(VSS));

// Chain X then drives through 2 NAND gates and NOT (delay) to clock the video shift register
  nand auto_311(I_1113_S, I_1529_D, I_1529_D);
    // Warning: Actually INVERTER with P's in series
    generic_pmos I_1081(.D(VDD), .G(I_1529_D), .S(I_1113_D));
    generic_pmos I_1113(.D(I_1113_D), .G(I_1529_D), .S(I_1113_S));
    generic_nmos I_1112(.D(I_1112_D), .G(I_1529_D), .S(I_1113_S));
    generic_nmos I_1080(.D(VSS), .G(I_1529_D), .S(I_1112_D));
  nand auto_989(I_983_D, I_1113_S, I_1113_S);
    // Warning: Actually INVERTER with P's in series
    generic_pmos I_1015(.D(I_1015_D), .G(I_1113_S), .S(VDD));
    generic_pmos I_983(.D(I_983_D), .G(I_1113_S), .S(I_1015_D));
    generic_nmos I_982(.D(I_983_D), .G(I_1113_S), .S(I_1014_D));
    generic_nmos I_1014(.D(I_1014_D), .G(I_1113_S), .S(VSS));
  not auto_293(I_1045_D, I_983_D); // NMOS strength = 3
    generic_pmos I_1013(.D(VDD), .G(I_983_D), .S(I_1045_D));
    generic_pmos I_1045(.D(I_1045_D), .G(I_983_D), .S(VDD));
    generic_pmos I_981(.D(I_1045_D), .G(I_983_D), .S(VDD));
    generic_nmos I_1012(.D(VSS), .G(I_983_D), .S(I_1045_D));
    generic_nmos I_1044(.D(I_1045_D), .G(I_983_D), .S(VSS));
    generic_nmos I_980(.D(I_1045_D), .G(I_983_D), .S(VSS));

// Timing for CAS generation

// 2 Ganged D-Type latches (common control clock)
// In 1 chain of 2 series devices (Q)
// Chain (Q) CAS related
// D-Type Flip Flop D: I_1267_S Q: I_1205_D ~Q: I_1237_D Rising Clock: I_735_D
// D-Type latch D: I_1267_S ~Q: I_1269_S Q: I_1235_D Clock: I_735_D
// 2:1 Mux with single control: Inputs: I_1235_D, I_1267_S Output: I_1267_D Control: I_735_D
  generic_cmos pass_19(.gn(I_735_D), .gp(I_1301_D), .p1(I_1235_D), .p2(I_1267_D));
    generic_pmos I_1235(.D(I_1235_D), .G(I_1301_D), .S(I_1267_D));
    generic_nmos I_1234(.D(I_1235_D), .G(I_735_D), .S(I_1267_D));
  generic_cmos pass_29(.gn(I_1301_D), .gp(I_735_D), .p1(I_1267_D), .p2(I_1267_S));
    generic_pmos I_1267(.D(I_1267_D), .G(I_735_D), .S(I_1267_S));
    generic_nmos I_1266(.D(I_1267_D), .G(I_1301_D), .S(I_1267_S));
  not auto_328(I_1269_S, I_1267_D); // NMOS strength = 2
    generic_pmos I_1171(.D(VDD), .G(I_1267_D), .S(I_1269_S));
    generic_pmos I_1203(.D(I_1269_S), .G(I_1267_D), .S(VDD));
    generic_nmos I_1170(.D(VSS), .G(I_1267_D), .S(I_1269_S));
    generic_nmos I_1202(.D(I_1269_S), .G(I_1267_D), .S(VSS));
  not auto_318(I_1235_D, I_1269_S);
    generic_pmos I_1139(.D(I_1235_D), .G(I_1269_S), .S(VDD));
    generic_nmos I_1138(.D(I_1235_D), .G(I_1269_S), .S(VSS));
// D-Type latch D: I_1269_S ~Q: I_1205_D Q: I_1237_D Clock: I_735_D
// 2:1 Mux with single control: Inputs: I_1237_D, I_1269_S Output: I_1269_D Control: I_735_D
  generic_cmos pass_20(.gn(I_1301_D), .gp(I_735_D), .p1(I_1237_D), .p2(I_1269_D));
    generic_pmos I_1237(.D(I_1237_D), .G(I_735_D), .S(I_1269_D));
    generic_nmos I_1236(.D(I_1237_D), .G(I_1301_D), .S(I_1269_D));
  generic_cmos pass_30(.gn(I_735_D), .gp(I_1301_D), .p1(I_1269_D), .p2(I_1269_S));
    generic_pmos I_1269(.D(I_1269_D), .G(I_1301_D), .S(I_1269_S));
    generic_nmos I_1268(.D(I_1269_D), .G(I_735_D), .S(I_1269_S));
  not auto_319(I_1237_D, I_1205_D);
    generic_pmos I_1141(.D(I_1237_D), .G(I_1205_D), .S(VDD));
    generic_nmos I_1140(.D(I_1237_D), .G(I_1205_D), .S(VSS));
  not auto_329(I_1205_D, I_1269_D); // NMOS strength = 2
    generic_pmos I_1173(.D(VDD), .G(I_1269_D), .S(I_1205_D));
    generic_pmos I_1205(.D(I_1205_D), .G(I_1269_D), .S(VDD));
    generic_nmos I_1172(.D(VSS), .G(I_1269_D), .S(I_1205_D));
    generic_nmos I_1204(.D(I_1205_D), .G(I_1269_D), .S(VSS));
// Shared Driver
  not auto_349(I_1301_D, I_735_D);
    generic_pmos I_1301(.D(I_1301_D), .G(I_735_D), .S(VDD));
    generic_nmos I_1300(.D(I_1301_D), .G(I_735_D), .S(VSS));

// Output from Q combined with timing signal
  nand auto_307(I_1115_D, I_1275_D, I_1205_D);
    generic_pmos I_1083(.D(VDD), .G(I_1205_D), .S(I_1115_D));
    generic_pmos I_1115(.D(I_1115_D), .G(I_1275_D), .S(VDD));
    generic_nmos I_1082(.D(I_1115_D), .G(I_1275_D), .S(I_1114_D));
    generic_nmos I_1114(.D(I_1114_D), .G(I_1205_D), .S(VSS));

// Timing for hi-lo address/external mux/CPU vs ULA/Addr1 vs 2
// memory multiplexer and derived signals

// 2 Ganged D-Type latches
// Further part of clock circuit (flipflop CC1) (High-low aka col/row selection)
// D-Type Flip Flop D: I_1913_S Q: I_1847_D ~Q: I_1879_D Rising Clock: I_503_D
// D-Type latch D: I_1913_S ~Q: I_1911_S Q: I_1881_D Clock: I_503_D
// 2:1 Mux with single control: Inputs: I_1881_D, I_1913_S Output: I_1913_D Control: I_503_D
  generic_cmos pass_81(.gn(I_503_D), .gp(I_1908_S), .p1(I_1881_D), .p2(I_1913_D));
    generic_pmos I_1881(.D(I_1881_D), .G(I_1908_S), .S(I_1913_D));
    generic_nmos I_1880(.D(I_1881_D), .G(I_503_D), .S(I_1913_D));
  generic_cmos pass_86(.gn(I_1908_S), .gp(I_503_D), .p1(I_1913_D), .p2(I_1913_S));
    generic_pmos I_1913(.D(I_1913_D), .G(I_503_D), .S(I_1913_S));
    generic_nmos I_1912(.D(I_1913_D), .G(I_1908_S), .S(I_1913_S));
  not auto_449(I_1881_D, I_1911_S);  
    generic_pmos I_1785(.D(I_1881_D), .G(I_1911_S), .S(VDD));
    generic_nmos I_1784(.D(I_1881_D), .G(I_1911_S), .S(VSS));
  not auto_457(I_1911_S, I_1913_D); // NMOS strength = 2
    generic_pmos I_1817(.D(VDD), .G(I_1913_D), .S(I_1911_S));
    generic_pmos I_1849(.D(I_1911_S), .G(I_1913_D), .S(VDD));
    generic_nmos I_1816(.D(VSS), .G(I_1913_D), .S(I_1911_S));
    generic_nmos I_1848(.D(I_1911_S), .G(I_1913_D), .S(VSS));
// D-Type latch D: I_1911_S ~Q: I_1847_D Q: I_1879_D Clock: I_503_D
// 2:1 Mux with single control: Inputs: I_1879_D, I_1911_S Output: I_1911_D Control: I_503_D
  generic_cmos pass_80(.gn(I_1908_S), .gp(I_503_D), .p1(I_1879_D), .p2(I_1911_D));
    generic_pmos I_1879(.D(I_1879_D), .G(I_503_D), .S(I_1911_D));
    generic_nmos I_1878(.D(I_1879_D), .G(I_1908_S), .S(I_1911_D));
  generic_cmos pass_85(.gn(I_503_D), .gp(I_1908_S), .p1(I_1911_D), .p2(I_1911_S));
    generic_pmos I_1911(.D(I_1911_D), .G(I_1908_S), .S(I_1911_S));
    generic_nmos I_1910(.D(I_1911_D), .G(I_503_D), .S(I_1911_S));
  not auto_448(I_1879_D, I_1847_D);
    generic_pmos I_1783(.D(I_1879_D), .G(I_1847_D), .S(VDD));
    generic_nmos I_1782(.D(I_1879_D), .G(I_1847_D), .S(VSS));
  not auto_456(I_1847_D, I_1911_D); // NMOS strength = 2
    generic_pmos I_1815(.D(VDD), .G(I_1911_D), .S(I_1847_D));
    generic_pmos I_1847(.D(I_1847_D), .G(I_1911_D), .S(VDD));
    generic_nmos I_1814(.D(VSS), .G(I_1911_D), .S(I_1847_D));
    generic_nmos I_1846(.D(I_1847_D), .G(I_1911_D), .S(VSS));
// Shared Driver
  not auto_469(I_1908_S, I_503_D);
    generic_pmos I_1877(.D(I_1908_S), .G(I_503_D), .S(VDD));
    generic_nmos I_1908(.D(VSS), .G(I_503_D), .S(I_1908_S));

  // External DRAM mux select
  nor auto_474(I_1915_S, I_1879_D, I_1853_S);
    generic_pmos I_1883(.D(VDD), .G(I_1879_D), .S(I_1915_D));
    generic_pmos I_1915(.D(I_1915_D), .G(I_1853_S), .S(I_1915_S));
    generic_nmos I_1882(.D(VSS), .G(I_1853_S), .S(I_1915_S));
    generic_nmos I_1914(.D(I_1915_S), .G(I_1879_D), .S(VSS));
  // CPU vs ULA access mux
  not auto_450(I_3974_G, I_1853_S); // NMOS strength = 4
    generic_pmos I_1787(.D(VDD), .G(I_1853_S), .S(I_3974_G));
    generic_pmos I_1789(.D(VDD), .G(I_1853_S), .S(I_3974_G));
    generic_pmos I_1819(.D(I_3974_G), .G(I_1853_S), .S(VDD));
    generic_pmos I_1821(.D(I_3974_G), .G(I_1853_S), .S(VDD));
    generic_nmos I_1786(.D(VSS), .G(I_1853_S), .S(I_3974_G));
    generic_nmos I_1788(.D(VSS), .G(I_1853_S), .S(I_3974_G));
    generic_nmos I_1818(.D(I_3974_G), .G(I_1853_S), .S(VSS));
    generic_nmos I_1820(.D(I_3974_G), .G(I_1853_S), .S(VSS));

// Signal to gates T, also helps create the DRAM "R/W" line from the 6502's R/W line on system phase of clock.
// So DRAM's R/W line is under control of 6502 during system phase, and READ at *all* times for ULA.
  not auto_881(I_3917_S, I_3529_D);
    generic_pmos I_3917(.D(VDD), .G(I_3529_D), .S(I_3917_S));
    generic_nmos I_3916(.D(VSS), .G(I_3529_D), .S(I_3917_S));
  nand auto_890(I_3981_D, I_3917_S, I_3974_G);
    generic_pmos I_3949(.D(VDD), .G(I_3974_G), .S(I_3981_D));
    generic_pmos I_3981(.D(I_3981_D), .G(I_3917_S), .S(VDD));
    generic_nmos I_3948(.D(I_3981_D), .G(I_3917_S), .S(I_3980_D));
    generic_nmos I_3980(.D(I_3980_D), .G(I_3974_G), .S(VSS));

// This little block is creating drive signals for the DRAM mux to drive gate sets "G" "S" and "L"
// Possibly only creates 2nd phase lookup in TEXT mode due to 1997_D
  nand auto_384(I_1499_D, I_1997_D, I_1051_S);
    generic_pmos I_1467(.D(VDD), .G(I_1051_S), .S(I_1499_D));
    generic_pmos I_1499(.D(I_1499_D), .G(I_1997_D), .S(VDD));
    generic_nmos I_1466(.D(I_1499_D), .G(I_1051_S), .S(I_1498_D));
    generic_nmos I_1498(.D(I_1498_D), .G(I_1997_D), .S(VSS));
  // Delay?
  not auto_397(I_1531_S, I_1499_D);
    generic_pmos I_1531(.D(VDD), .G(I_1499_D), .S(I_1531_S));
    generic_nmos I_1530(.D(VSS), .G(I_1499_D), .S(I_1531_S));
  // Delay?
  not auto_401(I_1627_D, I_1531_S); // NMOS strength = 3
    generic_pmos I_1563(.D(VDD), .G(I_1531_S), .S(I_1627_D));
    generic_pmos I_1595(.D(I_1627_D), .G(I_1531_S), .S(VDD));
    generic_pmos I_1627(.D(I_1627_D), .G(I_1531_S), .S(VDD));
    generic_nmos I_1562(.D(VSS), .G(I_1531_S), .S(I_1627_D));
    generic_nmos I_1594(.D(I_1627_D), .G(I_1531_S), .S(VSS));
    generic_nmos I_1626(.D(I_1627_D), .G(I_1531_S), .S(VSS));

// These gates delay signals create in main timing block

// (Delayed) output PHI signal for 6502, also other internal use
  nand auto_908(I_437_D, I_1373_S, I_1373_S);
    // Warning: Actually INVERTER with P's in series
    generic_pmos I_469(.D(I_469_D), .G(I_1373_S), .S(VDD));
    generic_pmos I_437(.D(I_437_D), .G(I_1373_S), .S(I_469_D));
    generic_nmos I_436(.D(I_437_D), .G(I_1373_S), .S(I_468_D));
    generic_nmos I_468(.D(I_468_D), .G(I_1373_S), .S(VSS));
  nand auto_765(I_341_D, I_437_D, I_437_D);
    // Warning: Actually INVERTER with P's in series
    generic_pmos I_373(.D(I_373_D), .G(I_437_D), .S(VDD));
    generic_pmos I_341(.D(I_341_D), .G(I_437_D), .S(I_373_D));
    generic_nmos I_340(.D(I_341_D), .G(I_437_D), .S(I_372_D));
    generic_nmos I_372(.D(I_372_D), .G(I_437_D), .S(VSS));
  nand auto_635(I_277_D, I_341_D, I_341_D);
    // Warning: Actually INVERTER with P's in series
    generic_pmos I_309(.D(I_309_D), .G(I_341_D), .S(VDD));
    generic_pmos I_277(.D(I_277_D), .G(I_341_D), .S(I_309_D));
    generic_nmos I_276(.D(I_277_D), .G(I_341_D), .S(I_308_D));
    generic_nmos I_308(.D(I_308_D), .G(I_341_D), .S(VSS));

// Delayed timing signal for loading DB latch
  nand auto_333(I_1209_S, I_1435_D, I_1435_D);
    // Warning: Actually INVERTER with P's in series
    generic_pmos I_1177(.D(VDD), .G(I_1435_D), .S(I_1209_D));
    generic_pmos I_1209(.D(I_1209_D), .G(I_1435_D), .S(I_1209_S));
    generic_nmos I_1208(.D(I_1208_D), .G(I_1435_D), .S(I_1209_S));
    generic_nmos I_1176(.D(VSS), .G(I_1435_D), .S(I_1208_D));
  nand auto_341(I_1273_S, I_1209_S, I_1209_S);
    // Warning: Actually INVERTER with P's in series
    generic_pmos I_1241(.D(VDD), .G(I_1209_S), .S(I_1273_D));
    generic_pmos I_1273(.D(I_1273_D), .G(I_1209_S), .S(I_1273_S));
    generic_nmos I_1272(.D(I_1272_D), .G(I_1209_S), .S(I_1273_S));
    generic_nmos I_1240(.D(VSS), .G(I_1209_S), .S(I_1272_D));
  nand auto_366(I_1369_S, I_1273_S, I_1273_S);
    // Warning: Actually INVERTER with P's in series
    generic_pmos I_1337(.D(VDD), .G(I_1273_S), .S(I_1369_D));
    generic_pmos I_1369(.D(I_1369_D), .G(I_1273_S), .S(I_1369_S));
    generic_nmos I_1368(.D(I_1368_D), .G(I_1273_S), .S(I_1369_S));
    generic_nmos I_1336(.D(VSS), .G(I_1273_S), .S(I_1368_D));
  nand auto_352(I_1309_D, I_1369_S, I_1369_S);
    // Warning: Actually INVERTER with P's in series
    generic_pmos I_1341(.D(I_1341_D), .G(I_1369_S), .S(VDD));
    generic_pmos I_1309(.D(I_1309_D), .G(I_1369_S), .S(I_1341_D));
    generic_nmos I_1308(.D(I_1309_D), .G(I_1369_S), .S(I_1340_D));
    generic_nmos I_1340(.D(I_1340_D), .G(I_1369_S), .S(VSS));
  not auto_485(I_1943_D, I_1309_D);
    generic_pmos I_1943(.D(I_1943_D), .G(I_1309_D), .S(VDD));
    generic_nmos I_1942(.D(I_1943_D), .G(I_1309_D), .S(VSS));
  not auto_484(I_1973_D, I_1943_D); // NMOS strength = 2
    generic_pmos I_1941(.D(VDD), .G(I_1943_D), .S(I_1973_D));
    generic_pmos I_1973(.D(I_1973_D), .G(I_1943_D), .S(VDD));
    generic_nmos I_1940(.D(VSS), .G(I_1943_D), .S(I_1973_D));
    generic_nmos I_1972(.D(I_1973_D), .G(I_1943_D), .S(VSS));

// Delay for 6MHZ dot clock (shift register clock)

// Delayed clock signal
  nand auto_982(I_923_D, I_989_D, I_989_D);
    // Warning: Actually INVERTER with P's in series
    generic_pmos I_955(.D(I_955_D), .G(I_989_D), .S(VDD));
    generic_pmos I_923(.D(I_923_D), .G(I_989_D), .S(I_955_D));
    generic_nmos I_922(.D(I_923_D), .G(I_989_D), .S(I_954_D));
    generic_nmos I_954(.D(I_954_D), .G(I_989_D), .S(VSS));
  nand auto_964(I_827_D, I_923_D, I_923_D);
    // Warning: Actually INVERTER with P's in series
    generic_pmos I_859(.D(I_859_D), .G(I_923_D), .S(VDD));
    generic_pmos I_827(.D(I_827_D), .G(I_923_D), .S(I_859_D));
    generic_nmos I_826(.D(I_827_D), .G(I_923_D), .S(I_858_D));
    generic_nmos I_858(.D(I_858_D), .G(I_923_D), .S(VSS));
  nand auto_941(I_667_D, I_827_D, I_827_D);
    // Warning: Actually INVERTER with P's in series
    generic_pmos I_699(.D(I_699_D), .G(I_827_D), .S(VDD));
    generic_pmos I_667(.D(I_667_D), .G(I_827_D), .S(I_699_D));
    generic_nmos I_666(.D(I_667_D), .G(I_827_D), .S(I_698_D));
    generic_nmos I_698(.D(I_698_D), .G(I_827_D), .S(VSS));
  nand auto_933(I_603_D, I_667_D, I_667_D);
    // Warning: Actually INVERTER with P's in series
    generic_pmos I_635(.D(I_635_D), .G(I_667_D), .S(VDD));
    generic_pmos I_603(.D(I_603_D), .G(I_667_D), .S(I_635_D));
    generic_nmos I_602(.D(I_603_D), .G(I_667_D), .S(I_634_D));
    generic_nmos I_634(.D(I_634_D), .G(I_667_D), .S(VSS));
  not auto_776(I_347_D, I_603_D);
    generic_pmos I_347(.D(I_347_D), .G(I_603_D), .S(VDD));
    generic_nmos I_346(.D(I_347_D), .G(I_603_D), .S(VSS));
  not auto_467(I_251_S, I_347_D); // NMOS strength = 3
    generic_pmos I_187(.D(VDD), .G(I_347_D), .S(I_251_S));
    generic_pmos I_219(.D(I_251_S), .G(I_347_D), .S(VDD));
    generic_pmos I_251(.D(VDD), .G(I_347_D), .S(I_251_S));
    generic_nmos I_186(.D(VSS), .G(I_347_D), .S(I_251_S));
    generic_nmos I_218(.D(I_251_S), .G(I_347_D), .S(VSS));
    generic_nmos I_250(.D(VSS), .G(I_347_D), .S(I_251_S));

// ********************************************************************************************************

// Horizontal video counter and combinatorial logic (See Page 9)
// This chain of d-latches (paired as flip flops, some have an inverter to 
// create clock and ~clock from one incoming clock, others have 2 external clocks ... ) makes up the 
// divider/counter chain for video counters.
//
// Some bits in the counter have [straight bit/inverted bit] available.
//
// Incoming clock is I_1051_S from the main clock divider
//
// Starting at pairs B1/B4/B5/B6/B2/B3 (end of chain, 6 bits, horizontal counter)
//   Horizontal count b0 .. b5 is I_3836_G, I_3830_G, I_1831_S, [I_1991_S/I_2053_S], [I_2151_S/I_2213_S], I_2311_S

// Drives the reset line for horizontal counter (B1-B6)
  not auto_356(I_1347_D, I_1345_D); // NMOS strength = 2
    generic_pmos I_1315(.D(VDD), .G(I_1345_D), .S(I_1347_D));
    generic_pmos I_1347(.D(I_1347_D), .G(I_1345_D), .S(VDD));
    generic_nmos I_1314(.D(VSS), .G(I_1345_D), .S(I_1347_D));
    generic_nmos I_1346(.D(I_1347_D), .G(I_1345_D), .S(VSS));

// Set of 12 D-Type latches with Asynchronous SET/RESETs I_1347_D
// In 6 looped pairs (B1 to B6) to make edge-triggered flip-flops, 6 bit counter
// Logically re-ordered B1/B4/B5/B6/B2/B3 -- with Q/Q~ driving next one's clock inputs

// Pair B1
// D-Type Flip Flop D: I_1573_S Q: I_3836_G ~Q: I_1573_S Asynchronous RESET I_1347_D Falling Clock: I_1051_S
// 2 Ganged D-Type latch with Asynchronous SET/RESETs I_1347_D
// D-Type latch D: I_1573_S ~Q: I_1575_S Q: I_1541_D with Asynchronous RESET I_1347_D I_1051_S
// 2:1 Mux with single control: Inputs: I_1541_D, I_1573_S Output: I_1573_D Control: I_1051_S
  generic_cmos pass_57(.gn(I_1576_S), .gp(I_1051_S), .p1(I_1541_D), .p2(I_1573_D));
    generic_pmos I_1541(.D(I_1541_D), .G(I_1051_S), .S(I_1573_D));
    generic_nmos I_1540(.D(I_1541_D), .G(I_1576_S), .S(I_1573_D));
  generic_cmos pass_65(.gn(I_1051_S), .gp(I_1576_S), .p1(I_1573_D), .p2(I_1573_S));
    generic_pmos I_1573(.D(I_1573_D), .G(I_1576_S), .S(I_1573_S));
    generic_nmos I_1572(.D(I_1573_D), .G(I_1051_S), .S(I_1573_S));
  nand auto_389(I_1575_S, I_1347_D, I_1573_D);
    generic_pmos I_1477(.D(VDD), .G(I_1347_D), .S(I_1575_S));
    generic_pmos I_1509(.D(I_1575_S), .G(I_1573_D), .S(VDD));
    generic_nmos I_1508(.D(I_1508_D), .G(I_1573_D), .S(I_1575_S));
    generic_nmos I_1476(.D(VSS), .G(I_1347_D), .S(I_1508_D));
  not auto_376(I_1541_D, I_1575_S);
    generic_pmos I_1445(.D(I_1541_D), .G(I_1575_S), .S(VDD));
    generic_nmos I_1444(.D(I_1541_D), .G(I_1575_S), .S(VSS));
// D-Type latch D: I_1575_S ~Q: I_3836_G Q: I_1573_S with Asynchronous SET I_1347_D Clock: I_1051_S
// 2:1 Mux with single control: Inputs: I_1573_S, I_1575_S Output: I_1575_D Control: I_1051_S
  generic_cmos pass_58(.gn(I_1051_S), .gp(I_1576_S), .p1(I_1573_S), .p2(I_1575_D));
    generic_pmos I_1543(.D(I_1573_S), .G(I_1576_S), .S(I_1575_D));
    generic_nmos I_1542(.D(I_1573_S), .G(I_1051_S), .S(I_1575_D));
  generic_cmos pass_66(.gn(I_1576_S), .gp(I_1051_S), .p1(I_1575_D), .p2(I_1575_S));
    generic_pmos I_1575(.D(I_1575_D), .G(I_1051_S), .S(I_1575_S));
    generic_nmos I_1574(.D(I_1575_D), .G(I_1576_S), .S(I_1575_S));
  not auto_394(I_3836_G, I_1575_D);
    generic_pmos I_1511(.D(VDD), .G(I_1575_D), .S(I_3836_G));
    generic_nmos I_1510(.D(VSS), .G(I_1575_D), .S(I_3836_G));
  nand auto_377(I_1573_S, I_3836_G, I_1347_D);
    generic_pmos I_1447(.D(VDD), .G(I_3836_G), .S(I_1573_S));
    generic_pmos I_1479(.D(I_1573_S), .G(I_1347_D), .S(VDD));
    generic_nmos I_1446(.D(I_1573_S), .G(I_3836_G), .S(I_1478_D));
    generic_nmos I_1478(.D(I_1478_D), .G(I_1347_D), .S(VSS));
// Shared Driver
  not auto_398(I_1576_S, I_1051_S);
    generic_pmos I_1545(.D(I_1576_S), .G(I_1051_S), .S(VDD));
    generic_nmos I_1576(.D(VSS), .G(I_1051_S), .S(I_1576_S));

// Pair B4
// D-Type Flip Flop D: I_1733_S Q: I_3830_G ~Q: I_1733_S with Asynchronous RESET I_1347_D Falling Clock: I_3836_G, Rising: I_1573_S
// 2 Ganged D-Type latch with Asynchronous SET/RESETs I_1347_D
// D-Type latch D: I_1733_S ~Q: I_1735_S Q: I_1701_D with Asynchronous RESET I_1347_D Clock: I_1573_S, I_3836_G
// 2:1 Mux with two controls: Inputs: I_1701_D, I_1733_S Output: I_1733_D Controls: I_1573_S, I_3836_G
  generic_cmos pass_72(.gn(I_1573_S), .gp(I_3836_G), .p1(I_1701_D), .p2(I_1733_D));
    generic_pmos I_1701(.D(I_1701_D), .G(I_3836_G), .S(I_1733_D));
    generic_nmos I_1700(.D(I_1701_D), .G(I_1573_S), .S(I_1733_D));
  generic_cmos pass_76(.gn(I_3836_G), .gp(I_1573_S), .p1(I_1733_D), .p2(I_1733_S));
    generic_pmos I_1733(.D(I_1733_D), .G(I_1573_S), .S(I_1733_S));
    generic_nmos I_1732(.D(I_1733_D), .G(I_3836_G), .S(I_1733_S));
  nand auto_417(I_1735_S, I_1347_D, I_1733_D);
    generic_pmos I_1637(.D(VDD), .G(I_1347_D), .S(I_1735_S));
    generic_pmos I_1669(.D(I_1735_S), .G(I_1733_D), .S(VDD));
    generic_nmos I_1668(.D(I_1668_D), .G(I_1733_D), .S(I_1735_S));
    generic_nmos I_1636(.D(VSS), .G(I_1347_D), .S(I_1668_D));
  not auto_407(I_1701_D, I_1735_S);
    generic_pmos I_1605(.D(I_1701_D), .G(I_1735_S), .S(VDD));
    generic_nmos I_1604(.D(I_1701_D), .G(I_1735_S), .S(VSS));
// D-Type latch D: I_1735_S ~Q: I_3830_G Q: I_1733_S with Asynchronous SET I_1347_D Clock: I_1573_S, I_3836_G
// 2:1 Mux with two controls: Inputs: I_1733_S, I_1735_S Output: I_1735_D Controls: I_1573_S, I_3836_G
  generic_cmos pass_73(.gn(I_3836_G), .gp(I_1573_S), .p1(I_1733_S), .p2(I_1735_D));
    generic_pmos I_1703(.D(I_1733_S), .G(I_1573_S), .S(I_1735_D));
    generic_nmos I_1702(.D(I_1733_S), .G(I_3836_G), .S(I_1735_D));
  generic_cmos pass_77(.gn(I_1573_S), .gp(I_3836_G), .p1(I_1735_D), .p2(I_1735_S));
    generic_pmos I_1735(.D(I_1735_D), .G(I_3836_G), .S(I_1735_S));
    generic_nmos I_1734(.D(I_1735_D), .G(I_1573_S), .S(I_1735_S));
  not auto_424(I_3830_G, I_1735_D);
    generic_pmos I_1671(.D(VDD), .G(I_1735_D), .S(I_3830_G));
    generic_nmos I_1670(.D(VSS), .G(I_1735_D), .S(I_3830_G));
  nand auto_408(I_1733_S, I_1347_D, I_3830_G);
    generic_pmos I_1607(.D(VDD), .G(I_3830_G), .S(I_1733_S));
    generic_pmos I_1639(.D(I_1733_S), .G(I_1347_D), .S(VDD));
    generic_nmos I_1606(.D(I_1733_S), .G(I_3830_G), .S(I_1638_D));
    generic_nmos I_1638(.D(I_1638_D), .G(I_1347_D), .S(VSS));

// Pair B5
// D-Type Flip Flop D: I_1893_S Q: I_1831_S ~Q: I_1893_S with Asynchronous RESET I_1347_D Falling Clock: I_3830_G, Rising: I_1733_S
// 2 Ganged D-Type latch with Asynchronous SET/RESETs I_1347_D
// D-Type latch D: I_1893_S ~Q: I_1895_S Q: I_1861_D with Asynchronous RESET I_1347_D Clock: I_1733_S, I_3830_G
// 2:1 Mux with two controls: Inputs: I_1861_D, I_1893_S Output: I_1893_D Controls: I_1733_S, I_3830_G
  generic_cmos pass_78(.gn(I_1733_S), .gp(I_3830_G), .p1(I_1861_D), .p2(I_1893_D));
    generic_pmos I_1861(.D(I_1861_D), .G(I_3830_G), .S(I_1893_D));
    generic_nmos I_1860(.D(I_1861_D), .G(I_1733_S), .S(I_1893_D));
  generic_cmos pass_82(.gn(I_3830_G), .gp(I_1733_S), .p1(I_1893_D), .p2(I_1893_S));
    generic_pmos I_1893(.D(I_1893_D), .G(I_1733_S), .S(I_1893_S));
    generic_nmos I_1892(.D(I_1893_D), .G(I_3830_G), .S(I_1893_S));
  nand auto_454(I_1895_S, I_1347_D, I_1893_D);
    generic_pmos I_1797(.D(VDD), .G(I_1347_D), .S(I_1895_S));
    generic_pmos I_1829(.D(I_1895_S), .G(I_1893_D), .S(VDD));
    generic_nmos I_1828(.D(I_1828_D), .G(I_1893_D), .S(I_1895_S));
    generic_nmos I_1796(.D(VSS), .G(I_1347_D), .S(I_1828_D));
  not auto_442(I_1861_D, I_1895_S);
    generic_pmos I_1765(.D(I_1861_D), .G(I_1895_S), .S(VDD));
    generic_nmos I_1764(.D(I_1861_D), .G(I_1895_S), .S(VSS));
// D-Type latch D: I_1895_S ~Q: I_1831_S Q: I_1893_S with Asynchronous SET I_1347_D Clock: I_1733_S, I_3830_G
// 2:1 Mux with two controls: Inputs: I_1893_S, I_1895_S Output: I_1895_D Controls: I_1733_S, I_3830_G
  generic_cmos pass_79(.gn(I_3830_G), .gp(I_1733_S), .p1(I_1893_S), .p2(I_1895_D));
    generic_pmos I_1863(.D(I_1893_S), .G(I_1733_S), .S(I_1895_D));
    generic_nmos I_1862(.D(I_1893_S), .G(I_3830_G), .S(I_1895_D));
  generic_cmos pass_83(.gn(I_1733_S), .gp(I_3830_G), .p1(I_1895_D), .p2(I_1895_S));
    generic_pmos I_1895(.D(I_1895_D), .G(I_3830_G), .S(I_1895_S));
    generic_nmos I_1894(.D(I_1895_D), .G(I_1733_S), .S(I_1895_S));
  not auto_459(I_1831_S, I_1895_D);
    generic_pmos I_1831(.D(VDD), .G(I_1895_D), .S(I_1831_S));
    generic_nmos I_1830(.D(VSS), .G(I_1895_D), .S(I_1831_S));
  nand auto_443(I_1893_S, I_1347_D, I_1831_S);
    generic_pmos I_1767(.D(VDD), .G(I_1831_S), .S(I_1893_S));
    generic_pmos I_1799(.D(I_1893_S), .G(I_1347_D), .S(VDD));
    generic_nmos I_1766(.D(I_1893_S), .G(I_1831_S), .S(I_1798_D));
    generic_nmos I_1798(.D(I_1798_D), .G(I_1347_D), .S(VSS));

// Pair B6
// D-Type Flip Flop D: I_2053_S Q: I_1991_S ~Q: I_2053_S with Asynchronous RESET I_1347_D Falling Clock: I_1831_S, Rising I_1893_S
// 2 Ganged D-Type latch with Asynchronous SET/RESETs I_1347_D
// D-Type latch D: I_2053_S ~Q: I_2055_S Q: I_2021_D with Asynchronous RESET I_1347_D Clock: I_1831_S, I_1893_S
// 2:1 Mux with two controls: Inputs: I_2053_S, I_2021_D Output: I_2053_D Controls: I_1831_S, I_1893_S
  generic_cmos pass_94(.gn(I_1831_S), .gp(I_1893_S), .p1(I_2053_D), .p2(I_2053_S));
    generic_pmos I_2053(.D(I_2053_D), .G(I_1893_S), .S(I_2053_S));
    generic_nmos I_2052(.D(I_2053_D), .G(I_1831_S), .S(I_2053_S));
  generic_cmos pass_88(.gn(I_1893_S), .gp(I_1831_S), .p1(I_2021_D), .p2(I_2053_D));
    generic_pmos I_2021(.D(I_2021_D), .G(I_1831_S), .S(I_2053_D));
    generic_nmos I_2020(.D(I_2021_D), .G(I_1893_S), .S(I_2053_D));
  nand auto_491(I_2055_S, I_1347_D, I_2053_D);
    generic_pmos I_1957(.D(VDD), .G(I_1347_D), .S(I_2055_S));
    generic_pmos I_1989(.D(I_2055_S), .G(I_2053_D), .S(VDD));
    generic_nmos I_1988(.D(I_1988_D), .G(I_2053_D), .S(I_2055_S));
    generic_nmos I_1956(.D(VSS), .G(I_1347_D), .S(I_1988_D));
  not auto_477(I_2021_D, I_2055_S);
    generic_pmos I_1925(.D(I_2021_D), .G(I_2055_S), .S(VDD));
    generic_nmos I_1924(.D(I_2021_D), .G(I_2055_S), .S(VSS));
// D-Type latch D: I_2055_S ~Q: I_1991_S Q: I_2053_S with Asynchronous SET I_1347_D Clock: I_1831_S, I_1893_S
// 2:1 Mux with two controls: Inputs: I_2053_S, I_2055_S Output: I_2055_D Controls: I_1831_S, I_1893_S
  generic_cmos pass_89(.gn(I_1831_S), .gp(I_1893_S), .p1(I_2053_S), .p2(I_2055_D));
    generic_pmos I_2023(.D(I_2053_S), .G(I_1893_S), .S(I_2055_D));
    generic_nmos I_2022(.D(I_2053_S), .G(I_1831_S), .S(I_2055_D));
  generic_cmos pass_95(.gn(I_1893_S), .gp(I_1831_S), .p1(I_2055_D), .p2(I_2055_S));
    generic_pmos I_2055(.D(I_2055_D), .G(I_1831_S), .S(I_2055_S));
    generic_nmos I_2054(.D(I_2055_D), .G(I_1893_S), .S(I_2055_S));
  not auto_498(I_1991_S, I_2055_D);
    generic_pmos I_1991(.D(VDD), .G(I_2055_D), .S(I_1991_S));
    generic_nmos I_1990(.D(VSS), .G(I_2055_D), .S(I_1991_S));
  nand auto_478(I_2053_S, I_1347_D, I_1991_S);
    generic_pmos I_1927(.D(VDD), .G(I_1991_S), .S(I_2053_S));
    generic_pmos I_1959(.D(I_2053_S), .G(I_1347_D), .S(VDD));
    generic_nmos I_1926(.D(I_2053_S), .G(I_1991_S), .S(I_1958_D));
    generic_nmos I_1958(.D(I_1958_D), .G(I_1347_D), .S(VSS));

// Pair B2
// D-Type Flip Flop D: I_2213_S Q: I_2151_S ~Q: I_2213_S with Asynchronous RESET I_1347_D Falling Clock: I_1991_S, Rising: I_2053_S
// 2 Ganged D-Type latch with Asynchronous SET/RESETs I_1347_D
// D-Type latch D: I_2213_S ~Q: I_2215_S Q: I_2181_D with Asynchronous RESET I_1347_D Clock: I_1991_S, I_2053_S
// 2:1 Mux with two controls: Inputs: I_2181_D, I_2213_S Output: I_2213_D Controls: I_1991_S, I_2053_S
  generic_cmos pass_100(.gn(I_2053_S), .gp(I_1991_S), .p1(I_2181_D), .p2(I_2213_D));
    generic_pmos I_2181(.D(I_2181_D), .G(I_1991_S), .S(I_2213_D));
    generic_nmos I_2180(.D(I_2181_D), .G(I_2053_S), .S(I_2213_D));
  generic_cmos pass_104(.gn(I_1991_S), .gp(I_2053_S), .p1(I_2213_D), .p2(I_2213_S));
    generic_pmos I_2213(.D(I_2213_D), .G(I_2053_S), .S(I_2213_S));
    generic_nmos I_2212(.D(I_2213_D), .G(I_1991_S), .S(I_2213_S));
  nand auto_520(I_2215_S, I_2213_D, I_1347_D);
    generic_pmos I_2117(.D(VDD), .G(I_1347_D), .S(I_2215_S));
    generic_pmos I_2149(.D(I_2215_S), .G(I_2213_D), .S(VDD));
    generic_nmos I_2148(.D(I_2148_D), .G(I_2213_D), .S(I_2215_S));
    generic_nmos I_2116(.D(VSS), .G(I_1347_D), .S(I_2148_D));
  not auto_510(I_2181_D, I_2215_S);
    generic_pmos I_2085(.D(I_2181_D), .G(I_2215_S), .S(VDD));
    generic_nmos I_2084(.D(I_2181_D), .G(I_2215_S), .S(VSS));
// D-Type latch D: I_2215_S ~Q: I_2151_S Q: I_2213_S with Asynchronous SET I_1347_D Clock: I_1991_S, I_2053_S
// 2:1 Mux with two controls: Inputs: I_2213_S, I_2215_S Output: I_2215_D Controls: I_1991_S, I_2053_S
  generic_cmos pass_101(.gn(I_1991_S), .gp(I_2053_S), .p1(I_2213_S), .p2(I_2215_D));
    generic_pmos I_2183(.D(I_2213_S), .G(I_2053_S), .S(I_2215_D));
    generic_nmos I_2182(.D(I_2213_S), .G(I_1991_S), .S(I_2215_D));
  generic_cmos pass_105(.gn(I_2053_S), .gp(I_1991_S), .p1(I_2215_D), .p2(I_2215_S));
    generic_pmos I_2215(.D(I_2215_D), .G(I_1991_S), .S(I_2215_S));
    generic_nmos I_2214(.D(I_2215_D), .G(I_2053_S), .S(I_2215_S));
  not auto_525(I_2151_S, I_2215_D);
    generic_pmos I_2151(.D(VDD), .G(I_2215_D), .S(I_2151_S));
    generic_nmos I_2150(.D(VSS), .G(I_2215_D), .S(I_2151_S));
  nand auto_511(I_2213_S, I_2151_S, I_1347_D);
    generic_pmos I_2087(.D(VDD), .G(I_2151_S), .S(I_2213_S));
    generic_pmos I_2119(.D(I_2213_S), .G(I_1347_D), .S(VDD));
    generic_nmos I_2086(.D(I_2213_S), .G(I_2151_S), .S(I_2118_D));
    generic_nmos I_2118(.D(I_2118_D), .G(I_1347_D), .S(VSS));

// Pair B3
// D-Type Flip Flop D: I_2373_S Q: I_2311_S ~Q: I_2373_S with Asynchronous RESET I_1347_D Falling Clock: I_2151_S, Rising: I_2213_S
// 2 Ganged D-Type latch with Asynchronous SET/RESETs I_1347_D
// D-Type latch D: I_2373_S ~Q: I_2375_S Q: I_2341_D with Asynchronous RESET I_1347_D Clock: I_2213_S, I_2151_S
// 2:1 Mux with two controls: Inputs: I_2341_D, I_2373_S Output: I_2373_D Controls: I_2213_S, I_2151_S
  generic_cmos pass_109(.gn(I_2213_S), .gp(I_2151_S), .p1(I_2341_D), .p2(I_2373_D));
    generic_pmos I_2341(.D(I_2341_D), .G(I_2151_S), .S(I_2373_D));
    generic_nmos I_2340(.D(I_2341_D), .G(I_2213_S), .S(I_2373_D));
  generic_cmos pass_113(.gn(I_2151_S), .gp(I_2213_S), .p1(I_2373_D), .p2(I_2373_S));
    generic_pmos I_2373(.D(I_2373_D), .G(I_2213_S), .S(I_2373_S));
    generic_nmos I_2372(.D(I_2373_D), .G(I_2151_S), .S(I_2373_S));
  nand auto_551(I_2375_S, I_1347_D, I_2373_D);
    generic_pmos I_2277(.D(VDD), .G(I_1347_D), .S(I_2375_S));
    generic_pmos I_2309(.D(I_2375_S), .G(I_2373_D), .S(VDD));
    generic_nmos I_2308(.D(I_2308_D), .G(I_2373_D), .S(I_2375_S));
    generic_nmos I_2276(.D(VSS), .G(I_1347_D), .S(I_2308_D));
  not auto_542(I_2341_D, I_2375_S);
    generic_pmos I_2245(.D(I_2341_D), .G(I_2375_S), .S(VDD));
    generic_nmos I_2244(.D(I_2341_D), .G(I_2375_S), .S(VSS))
// D-Type latch D: I_2375_S ~Q: I_2311_S Q: I_2373_S with Asynchronous SET I_1347_D Clock: I_2213_S, I_2151_S
// 2:1 Mux with two controls: Inputs: I_2373_S, I_2375_S Output: I_2375_D Controls: I_2151_S, I_2213_S
  generic_cmos pass_110(.gn(I_2151_S), .gp(I_2213_S), .p1(I_2373_S), .p2(I_2375_D));
    generic_pmos I_2343(.D(I_2373_S), .G(I_2213_S), .S(I_2375_D));
    generic_nmos I_2342(.D(I_2373_S), .G(I_2151_S), .S(I_2375_D));
  generic_cmos pass_114(.gn(I_2213_S), .gp(I_2151_S), .p1(I_2375_D), .p2(I_2375_S));
    generic_pmos I_2375(.D(I_2375_D), .G(I_2151_S), .S(I_2375_S));
    generic_nmos I_2374(.D(I_2375_D), .G(I_2213_S), .S(I_2375_S));
  not auto_559(I_2311_S, I_2375_D);
    generic_pmos I_2311(.D(VDD), .G(I_2375_D), .S(I_2311_S));
    generic_nmos I_2310(.D(VSS), .G(I_2375_D), .S(I_2311_S));
  nand auto_543(I_2373_S, I_2311_S, I_1347_D);
    generic_pmos I_2247(.D(VDD), .G(I_2311_S), .S(I_2373_S));
    generic_pmos I_2279(.D(I_2373_S), .G(I_1347_D), .S(VDD));
    generic_nmos I_2246(.D(I_2373_S), .G(I_2311_S), .S(I_2278_D));
    generic_nmos I_2278(.D(I_2278_D), .G(I_1347_D), .S(VSS));

// ********************************************************************************************************

// Horizontal Combinatorial Logic

// Calculates HSYNC1 in counts 48-51
  nand auto_453(I_1891_S, I_1763_D, I_2311_S, I_1923_D, I_2151_S);
    generic_pmos I_1859(.D(I_1891_S), .G(I_2151_S), .S(VDD));
    generic_pmos I_1795(.D(VDD), .G(I_1763_D), .S(I_1891_S));
    generic_pmos I_1827(.D(I_1891_S), .G(I_2311_S), .S(VDD));
    generic_pmos I_1891(.D(VDD), .G(I_1923_D), .S(I_1891_S));
    generic_nmos I_1890(.D(I_1890_D), .G(I_2151_S), .S(I_1891_S));
    generic_nmos I_1858(.D(I_1858_D), .G(I_1923_D), .S(I_1890_D));
    generic_nmos I_1826(.D(I_1826_D), .G(I_2311_S), .S(I_1858_D));
    generic_nmos I_1794(.D(VSS), .G(I_1763_D), .S(I_1826_D));
  not auto_441(I_1763_D, I_1831_S);
    generic_pmos I_1763(.D(I_1763_D), .G(I_1831_S), .S(VDD));
    generic_nmos I_1762(.D(I_1763_D), .G(I_1831_S), .S(VSS));
  not auto_476(I_1923_D, I_1991_S);
    generic_pmos I_1923(.D(I_1923_D), .G(I_1991_S), .S(VDD));
    generic_nmos I_1922(.D(I_1923_D), .G(I_1991_S), .S(VSS));

// Pair Ra
// This flipflop delays HSYNC1 (48-51) from combinatorial to be visible in 50-54
// (clocked on rising edge of HC bit 1)
// D-Type Flip Flop D: I_1891_S Q: I_2535_G ~Q: I_1539_D Rising Clock: I_3830_G
// 2 Ganged D-Type latch (common control clock)
// In 1 chain of 2 series devices (Ra)
// Chain (Ra2)
// D-Type latch D: I_1891_S ~Q: I_1571_S Q: I_1537_D Clock: I_3830_G
// 2:1 Mux with single control: Inputs: I_1537_D, I_1891_S Output: I_1569_D Control: I_3830_G
  generic_cmos pass_55(.gn(I_3830_G), .gp(I_1411_S), .p1(I_1537_D), .p2(I_1569_D));
    generic_pmos I_1537(.D(I_1537_D), .G(I_1411_S), .S(I_1569_D));
    generic_nmos I_1536(.D(I_1537_D), .G(I_3830_G), .S(I_1569_D));
  generic_cmos pass_62(.gn(I_1411_S), .gp(I_3830_G), .p1(I_1569_D), .p2(I_1891_S));
    generic_pmos I_1569(.D(I_1569_D), .G(I_3830_G), .S(I_1891_S));
    generic_nmos I_1568(.D(I_1569_D), .G(I_1411_S), .S(I_1891_S));
  not auto_374(I_1537_D, I_1571_S);
    generic_pmos I_1441(.D(I_1537_D), .G(I_1571_S), .S(VDD));
    generic_nmos I_1440(.D(I_1537_D), .G(I_1571_S), .S(VSS));
  not auto_387(I_1571_S, I_1569_D); // NMOS strength = 2
    generic_pmos I_1473(.D(VDD), .G(I_1569_D), .S(I_1571_S));
    generic_pmos I_1505(.D(I_1571_S), .G(I_1569_D), .S(VDD));
    generic_nmos I_1472(.D(VSS), .G(I_1569_D), .S(I_1571_S));
    generic_nmos I_1504(.D(I_1571_S), .G(I_1569_D), .S(VSS));
// Chain (Ra1)
// D-Type latch D: I_1571_S ~Q: I_2535_G Q: I_1539_D Clock: I_3830_G
// 2:1 Mux with single control: Inputs: I_1539_D, I_1571_S Output: I_1571_D Control: I_3830_G
  generic_cmos pass_56(.gn(I_1411_S), .gp(I_3830_G), .p1(I_1539_D), .p2(I_1571_D));
    generic_pmos I_1539(.D(I_1539_D), .G(I_3830_G), .S(I_1571_D));
    generic_nmos I_1538(.D(I_1539_D), .G(I_1411_S), .S(I_1571_D));
  generic_cmos pass_64(.gn(I_3830_G), .gp(I_1411_S), .p1(I_1571_D), .p2(I_1571_S));
    generic_pmos I_1571(.D(I_1571_D), .G(I_1411_S), .S(I_1571_S));
    generic_nmos I_1570(.D(I_1571_D), .G(I_3830_G), .S(I_1571_S));
  not auto_375(I_1539_D, I_2535_G);
    generic_pmos I_1443(.D(I_1539_D), .G(I_2535_G), .S(VDD));
    generic_nmos I_1442(.D(I_1539_D), .G(I_2535_G), .S(VSS));
  not auto_388(I_2535_G, I_1571_D); // NMOS strength = 2
    generic_pmos I_1475(.D(VDD), .G(I_1571_D), .S(I_2535_G));
    generic_pmos I_1507(.D(I_2535_G), .G(I_1571_D), .S(VDD));
    generic_nmos I_1474(.D(VSS), .G(I_1571_D), .S(I_2535_G));
    generic_nmos I_1506(.D(I_2535_G), .G(I_1571_D), .S(VSS));
// Shared Driver
  not auto_372(I_1411_S, I_3830_G);
    generic_pmos I_1411(.D(VDD), .G(I_3830_G), .S(I_1411_S));
    generic_nmos I_1378(.D(I_1411_S), .G(I_3830_G), .S(VSS));

// Output of Ra is ~HSYNC2 (and is the clock in to vertical count)
// Also creates a "per-line" reset for flipflop chains H I J Ka Kb L M N and others (attribute registers). on I_1187_S
// This not drives that line
  not auto_312(I_1187_S, I_1539_D); // NMOS strength = 3
    generic_pmos I_1123(.D(VDD), .G(I_1539_D), .S(I_1187_S));
    generic_pmos I_1155(.D(I_1187_S), .G(I_1539_D), .S(VDD));
    generic_pmos I_1187(.D(VDD), .G(I_1539_D), .S(I_1187_S));
    generic_nmos I_1122(.D(VSS), .G(I_1539_D), .S(I_1187_S));
    generic_nmos I_1154(.D(I_1187_S), .G(I_1539_D), .S(VSS));
    generic_nmos I_1186(.D(VSS), .G(I_1539_D), .S(I_1187_S));

// Horizontal - Create HBLANK when HCount >=40 (blackens left and right edge of video)
  nand auto_532(I_2211_D, I_2213_S, I_2053_S);
    generic_pmos I_2179(.D(VDD), .G(I_2053_S), .S(I_2211_D));
    generic_pmos I_2211(.D(I_2211_D), .G(I_2213_S), .S(VDD));
    generic_nmos I_2178(.D(I_2211_D), .G(I_2213_S), .S(I_2210_D));
    generic_nmos I_2210(.D(I_2210_D), .G(I_2053_S), .S(VSS));
  nand auto_541(I_2275_D, I_2311_S, I_2211_D);
    generic_pmos I_2243(.D(VDD), .G(I_2311_S), .S(I_2275_D));
    generic_pmos I_2275(.D(I_2275_D), .G(I_2211_D), .S(VDD));
    generic_nmos I_2242(.D(I_2275_D), .G(I_2311_S), .S(I_2274_D));
    generic_nmos I_2274(.D(I_2274_D), .G(I_2211_D), .S(VSS));

// ********************************************************************************************************

// Vertical video counter and combinatorial logic (See Page 10)

// HSYNC2 from horizontal counter Rb/C1/C2/C3/C4/C5/C6/C7/C8 (9 bits, vertical counter)
//   Vertical count b0 .. b4 is I_3911_G, I_2631_S, [I_2791_S/I_2853_S], [I_2951_S/I_3013_S], [I_3111_S/I_3173_S]
//   Vertical count b5 .. b8 is [I_3271_S/I_3333_S], [I_3431_S/I_3493_S], [I_3591_S/I_3653_S], [I_3751_S/I_3813_S]
//   NOT 813 provides another VC bit 8 (copy)
//   NOT 435 provides another VC bit 3 (copy)

// Drives the reset line for Rb/C1-C8 pairs/counter
  not auto_716(I_3241_D, I_3177_D); // NMOS strength = 2
    generic_pmos I_3209(.D(VDD), .G(I_3177_D), .S(I_3241_D));
    generic_pmos I_3241(.D(I_3241_D), .G(I_3177_D), .S(VDD));
    generic_nmos I_3208(.D(VSS), .G(I_3177_D), .S(I_3241_D));
    generic_nmos I_3240(.D(I_3241_D), .G(I_3177_D), .S(VSS));

// First of vertical counter flipflops ...

// Pair Rb
// D-Type Flip Flop D: I_2533_S Q: I_3911_G ~Q: I_2533_S with Asynchronous RESET I_3241_D Falling Clock: I_2535_G
// 2 Ganged D-Type latch with Asynchronous SET/RESETs I_3241_D
// D-Type latch D: I_2533_S ~Q: I_2535_S Q: I_2501_D with Asynchronous RESET I_3241_D Clock: I_2535_G
// 2:1 Mux with single control: Inputs: I_2533_S, I_2501_D Output: I_2533_D Control: I_2535_G
  generic_cmos pass_123(.gn(I_2535_G), .gp(I_2534_G), .p1(I_2533_D), .p2(I_2533_S));
    generic_pmos I_2533(.D(I_2533_D), .G(I_2534_G), .S(I_2533_S));
    generic_nmos I_2532(.D(I_2533_D), .G(I_2535_G), .S(I_2533_S));
  generic_cmos pass_118(.gn(I_2534_G), .gp(I_2535_G), .p1(I_2501_D), .p2(I_2533_D));
    generic_pmos I_2501(.D(I_2501_D), .G(I_2535_G), .S(I_2533_D));
    generic_nmos I_2500(.D(I_2501_D), .G(I_2534_G), .S(I_2533_D));
  nand auto_581(I_2535_S, I_3241_D, I_2533_D);
    generic_pmos I_2437(.D(VDD), .G(I_3241_D), .S(I_2535_S));
    generic_pmos I_2469(.D(I_2535_S), .G(I_2533_D), .S(VDD));
    generic_nmos I_2468(.D(I_2468_D), .G(I_2533_D), .S(I_2535_S));
    generic_nmos I_2436(.D(VSS), .G(I_3241_D), .S(I_2468_D));
  not auto_572(I_2501_D, I_2535_S);
    generic_pmos I_2405(.D(I_2501_D), .G(I_2535_S), .S(VDD));
    generic_nmos I_2404(.D(I_2501_D), .G(I_2535_S), .S(VSS));
// D-Type latch D: I_2535_S ~Q: I_3911_G Q: I_2533_S with Asynchronous SET I_3241_D Clock: I_2535_G
// 2:1 Mux with two controls: Inputs: I_2533_S, I_2535_S Output: I_2535_D Controls: I_2535_G, I_2534_G
  generic_cmos pass_119(.gn(I_2535_G), .gp(I_2534_G), .p1(I_2533_S), .p2(I_2535_D));
    generic_pmos I_2503(.D(I_2533_S), .G(I_2534_G), .S(I_2535_D));
    generic_nmos I_2502(.D(I_2533_S), .G(I_2535_G), .S(I_2535_D));
  generic_cmos pass_124(.gn(I_2534_G), .gp(I_2535_G), .p1(I_2535_D), .p2(I_2535_S));
    generic_pmos I_2535(.D(I_2535_D), .G(I_2535_G), .S(I_2535_S));
    generic_nmos I_2534(.D(I_2535_D), .G(I_2534_G), .S(I_2535_S));
  not auto_587(I_3911_G, I_2535_D);
    generic_pmos I_2471(.D(VDD), .G(I_2535_D), .S(I_3911_G));
    generic_nmos I_2470(.D(VSS), .G(I_2535_D), .S(I_3911_G));
  nand auto_573(I_2533_S, I_3241_D, I_3911_G);
    generic_pmos I_2407(.D(VDD), .G(I_3911_G), .S(I_2533_S));
    generic_pmos I_2439(.D(I_2533_S), .G(I_3241_D), .S(VDD));
    generic_nmos I_2406(.D(I_2533_S), .G(I_3911_G), .S(I_2438_D));
    generic_nmos I_2438(.D(I_2438_D), .G(I_3241_D), .S(VSS));
// Shared Driver
  not auto_592(I_2534_G, I_2535_G);
    generic_pmos I_2499(.D(I_2534_G), .G(I_2535_G), .S(VDD));
    generic_nmos I_2530(.D(VSS), .G(I_2535_G), .S(I_2534_G));

// Set of 16 D-Type latches with Asynchronous SET/RESETs I_3241_D
// In 8 looped pairs (C1 to C8) to make edge-triggered flip-flops, 8 bit counter
// Q/Q~ driving next one's clock inputs

// Pair C1
// D-Type Flip Flop D: I_2693_S Q: I_2631_S ~Q: I_2693_S with Asynchronous RESET I_3241_D Falling Clock: I_3911_G, I_2533_S
// 2 Ganged D-Type latch with Asynchronous SET/RESETs I_3241_D
// D-Type latch D: I_2693_S ~Q: I_2695_S Q: I_2661_D with Asynchronous RESET I_3241_D Clock: I_2533_S, I_3911_G
// 2:1 Mux with two controls: Inputs: I_2661_D, I_2693_S Output: I_2693_D Controls: I_2533_S, I_3911_G
  generic_cmos pass_131(.gn(I_2533_S), .gp(I_3911_G), .p1(I_2661_D), .p2(I_2693_D));
    generic_pmos I_2661(.D(I_2661_D), .G(I_3911_G), .S(I_2693_D));
    generic_nmos I_2660(.D(I_2661_D), .G(I_2533_S), .S(I_2693_D));
  generic_cmos pass_138(.gn(I_3911_G), .gp(I_2533_S), .p1(I_2693_D), .p2(I_2693_S));
    generic_pmos I_2693(.D(I_2693_D), .G(I_2533_S), .S(I_2693_S));
    generic_nmos I_2692(.D(I_2693_D), .G(I_3911_G), .S(I_2693_S));
  nand auto_611(I_2695_S, I_3241_D, I_2693_D);
    generic_pmos I_2597(.D(VDD), .G(I_3241_D), .S(I_2695_S));
    generic_pmos I_2629(.D(I_2695_S), .G(I_2693_D), .S(VDD));
    generic_nmos I_2628(.D(I_2628_D), .G(I_2693_D), .S(I_2695_S));
    generic_nmos I_2596(.D(VSS), .G(I_3241_D), .S(I_2628_D));
  not auto_600(I_2661_D, I_2695_S);
    generic_pmos I_2565(.D(I_2661_D), .G(I_2695_S), .S(VDD));
    generic_nmos I_2564(.D(I_2661_D), .G(I_2695_S), .S(VSS));
// D-Type latch D: I_2695_S ~Q: I_2631_S Q: I_2693_S with Asynchronous SET I_3241_D Clock: I_2533_S, I_3911_G
// 2:1 Mux with two controls: Inputs: I_2693_S, I_2695_S Output: I_2695_D Controls: I_2533_S, I_3911_G
  generic_cmos pass_132(.gn(I_3911_G), .gp(I_2533_S), .p1(I_2693_S), .p2(I_2695_D));
    generic_pmos I_2663(.D(I_2693_S), .G(I_2533_S), .S(I_2695_D));
    generic_nmos I_2662(.D(I_2693_S), .G(I_3911_G), .S(I_2695_D));
  generic_cmos pass_139(.gn(I_2533_S), .gp(I_3911_G), .p1(I_2695_D), .p2(I_2695_S));
    generic_pmos I_2695(.D(I_2695_D), .G(I_3911_G), .S(I_2695_S));
    generic_nmos I_2694(.D(I_2695_D), .G(I_2533_S), .S(I_2695_S));
  not auto_615(I_2631_S, I_2695_D);
    generic_pmos I_2631(.D(VDD), .G(I_2695_D), .S(I_2631_S));
    generic_nmos I_2630(.D(VSS), .G(I_2695_D), .S(I_2631_S));
  nand auto_601(I_2693_S, I_3241_D, I_2631_S);
    generic_pmos I_2567(.D(VDD), .G(I_2631_S), .S(I_2693_S));
    generic_pmos I_2599(.D(I_2693_S), .G(I_3241_D), .S(VDD));
    generic_nmos I_2566(.D(I_2693_S), .G(I_2631_S), .S(I_2598_D));
    generic_nmos I_2598(.D(I_2598_D), .G(I_3241_D), .S(VSS));

// Pair C2
// D-Type Flip Flop D: I_2853_S Q: I_2791_S ~Q: I_2853_S with Asynchronous RESET I_3241_D Falling Clock: I_2631_S, Rising: I_2693_S
// 2 Ganged D-Type latch with Asynchronous SET/RESETs I_3241_D
// D-Type latch D: I_2853_S ~Q: I_2855_S Q: I_2821_D with Asynchronous RESET I_3241_D Clock: I_2693_S, I_2631_S
// 2:1 Mux with two controls: Inputs: I_2821_D, I_2853_S Output: I_2853_D Controls: I_2693_S, I_2631_S
  generic_cmos pass_148(.gn(I_2693_S), .gp(I_2631_S), .p1(I_2821_D), .p2(I_2853_D));
    generic_pmos I_2821(.D(I_2821_D), .G(I_2631_S), .S(I_2853_D));
    generic_nmos I_2820(.D(I_2821_D), .G(I_2693_S), .S(I_2853_D));
  generic_cmos pass_154(.gn(I_2631_S), .gp(I_2693_S), .p1(I_2853_D), .p2(I_2853_S));
    generic_pmos I_2853(.D(I_2853_D), .G(I_2693_S), .S(I_2853_S));
    generic_nmos I_2852(.D(I_2853_D), .G(I_2631_S), .S(I_2853_S));
  nand auto_634(I_2855_S, I_2853_D, I_3241_D);
    generic_pmos I_2757(.D(VDD), .G(I_3241_D), .S(I_2855_S));
    generic_pmos I_2789(.D(I_2855_S), .G(I_2853_D), .S(VDD));
    generic_nmos I_2788(.D(I_2788_D), .G(I_2853_D), .S(I_2855_S));
    generic_nmos I_2756(.D(VSS), .G(I_3241_D), .S(I_2788_D));
  not auto_625(I_2821_D, I_2855_S);
    generic_pmos I_2725(.D(I_2821_D), .G(I_2855_S), .S(VDD));
    generic_nmos I_2724(.D(I_2821_D), .G(I_2855_S), .S(VSS));
// D-Type latch D: I_2855_S ~Q: I_2791_S Q: I_2853_S with Asynchronous SET I_3241_D Clock: I_2693_S, I_2631_S
// 2:1 Mux with two controls: Inputs: I_2853_S, I_2855_S Output: I_2855_D Controls: I_2631_S, I_2693_S
  generic_cmos pass_149(.gn(I_2631_S), .gp(I_2693_S), .p1(I_2853_S), .p2(I_2855_D));
    generic_pmos I_2823(.D(I_2853_S), .G(I_2693_S), .S(I_2855_D));
    generic_nmos I_2822(.D(I_2853_S), .G(I_2631_S), .S(I_2855_D));
  generic_cmos pass_155(.gn(I_2693_S), .gp(I_2631_S), .p1(I_2855_D), .p2(I_2855_S));
    generic_pmos I_2855(.D(I_2855_D), .G(I_2631_S), .S(I_2855_S));
    generic_nmos I_2854(.D(I_2855_D), .G(I_2693_S), .S(I_2855_S));
  not auto_641(I_2791_S, I_2855_D);
    generic_pmos I_2791(.D(VDD), .G(I_2855_D), .S(I_2791_S));
    generic_nmos I_2790(.D(VSS), .G(I_2855_D), .S(I_2791_S));
  nand auto_626(I_2853_S, I_2791_S, I_3241_D);
    generic_pmos I_2727(.D(VDD), .G(I_2791_S), .S(I_2853_S));
    generic_pmos I_2759(.D(I_2853_S), .G(I_3241_D), .S(VDD));
    generic_nmos I_2726(.D(I_2853_S), .G(I_2791_S), .S(I_2758_D));
    generic_nmos I_2758(.D(I_2758_D), .G(I_3241_D), .S(VSS));

// Pair C3
// D-Type Flip Flop D: I_3013_S Q: I_2951_S ~Q: I_3013_S  with Asynchronous RESET I_3241_D Falling Clock: I_2791_S, I_2853_S
// 2 Ganged D-Type latch with Asynchronous SET/RESETs I_3241_D
// D-Type latch D: I_3013_S ~Q: I_3015_S Q: I_2981_D  with Asynchronous RESET I_3241_D Clock: I_2853_S, I_2791_S
// 2:1 Mux with two controls: Inputs: I_2981_D, I_3013_S Output: I_3013_D Controls: I_2853_S, I_2791_S
  generic_cmos pass_163(.gn(I_2853_S), .gp(I_2791_S), .p1(I_2981_D), .p2(I_3013_D));
    generic_pmos I_2981(.D(I_2981_D), .G(I_2791_S), .S(I_3013_D));
    generic_nmos I_2980(.D(I_2981_D), .G(I_2853_S), .S(I_3013_D));
  generic_cmos pass_170(.gn(I_2791_S), .gp(I_2853_S), .p1(I_3013_D), .p2(I_3013_S));
    generic_pmos I_3013(.D(I_3013_D), .G(I_2853_S), .S(I_3013_S));
    generic_nmos I_3012(.D(I_3013_D), .G(I_2791_S), .S(I_3013_S));
  nand auto_662(I_3015_S, I_3241_D, I_3013_D);
    generic_pmos I_2917(.D(VDD), .G(I_3241_D), .S(I_3015_S));
    generic_pmos I_2949(.D(I_3015_S), .G(I_3013_D), .S(VDD));
    generic_nmos I_2948(.D(I_2948_D), .G(I_3013_D), .S(I_3015_S));
    generic_nmos I_2916(.D(VSS), .G(I_3241_D), .S(I_2948_D));
  not auto_652(I_2981_D, I_3015_S);
    generic_pmos I_2885(.D(I_2981_D), .G(I_3015_S), .S(VDD));
    generic_nmos I_2884(.D(I_2981_D), .G(I_3015_S), .S(VSS));
// D-Type latch D: I_3015_S ~Q: I_2951_S Q: I_3013_S with Asynchronous SET I_3241_D Clock: I_2853_S, I_2791_S
// 2:1 Mux with two controls: Inputs: I_3013_S, I_3015_S Output: I_3015_D Controls: I_2791_S, I_2853_S
  generic_cmos pass_164(.gn(I_2791_S), .gp(I_2853_S), .p1(I_3013_S), .p2(I_3015_D));
    generic_pmos I_2983(.D(I_3013_S), .G(I_2853_S), .S(I_3015_D));
    generic_nmos I_2982(.D(I_3013_S), .G(I_2791_S), .S(I_3015_D));
  generic_cmos pass_171(.gn(I_2853_S), .gp(I_2791_S), .p1(I_3015_D), .p2(I_3015_S));
    generic_pmos I_3015(.D(I_3015_D), .G(I_2791_S), .S(I_3015_S));
    generic_nmos I_3014(.D(I_3015_D), .G(I_2853_S), .S(I_3015_S));
  not auto_668(I_2951_S, I_3015_D);
    generic_pmos I_2951(.D(VDD), .G(I_3015_D), .S(I_2951_S));
    generic_nmos I_2950(.D(VSS), .G(I_3015_D), .S(I_2951_S));
  nand auto_653(I_3013_S, I_3241_D, I_2951_S);
    generic_pmos I_2887(.D(VDD), .G(I_2951_S), .S(I_3013_S));
    generic_pmos I_2919(.D(I_3013_S), .G(I_3241_D), .S(VDD));
    generic_nmos I_2886(.D(I_3013_S), .G(I_2951_S), .S(I_2918_D));
    generic_nmos I_2918(.D(I_2918_D), .G(I_3241_D), .S(VSS));

// Pair C4
// D-Type Flip Flop D: I_3173_S Q: I_3111_S ~Q: I_3173_S with Asynchronous RESET I_3241_D Falling Clock: I_2951_S, Rising: I_3013_S
// 2 Ganged D-Type latch with Asynchronous SET/RESETs I_3241_D
// D-Type latch D: I_3173_S ~Q: I_3175_S Q: I_3141_D with Asynchronous RESET I_3241_D Clock: I_3013_S, I_2951_S
// 2:1 Mux with two controls: Inputs: I_3141_D, I_3173_S Output: I_3173_D Controls: I_3013_S, I_2951_S
  generic_cmos pass_179(.gn(I_3013_S), .gp(I_2951_S), .p1(I_3141_D), .p2(I_3173_D));
    generic_pmos I_3141(.D(I_3141_D), .G(I_2951_S), .S(I_3173_D));
    generic_nmos I_3140(.D(I_3141_D), .G(I_3013_S), .S(I_3173_D));
  generic_cmos pass_183(.gn(I_2951_S), .gp(I_3013_S), .p1(I_3173_D), .p2(I_3173_S));
    generic_pmos I_3173(.D(I_3173_D), .G(I_3013_S), .S(I_3173_S));
    generic_nmos I_3172(.D(I_3173_D), .G(I_2951_S), .S(I_3173_S));
  nand auto_696(I_3175_S, I_3241_D, I_3173_D);
    generic_pmos I_3077(.D(VDD), .G(I_3241_D), .S(I_3175_S));
    generic_pmos I_3109(.D(I_3175_S), .G(I_3173_D), .S(VDD));
    generic_nmos I_3108(.D(I_3108_D), .G(I_3173_D), .S(I_3175_S));
    generic_nmos I_3076(.D(VSS), .G(I_3241_D), .S(I_3108_D));
  not auto_682(I_3141_D, I_3175_S);
    generic_pmos I_3045(.D(I_3141_D), .G(I_3175_S), .S(VDD));
    generic_nmos I_3044(.D(I_3141_D), .G(I_3175_S), .S(VSS));
// D-Type latch D: I_3175_S ~Q: I_3111_S Q: I_3173_S with Asynchronous SET I_3241_D Clock: I_3013_S, I_2951_S
// 2:1 Mux with two controls: Inputs: I_3173_S, I_3175_S Output: I_3175_D Controls: I_2951_S, I_3013_S
  generic_cmos pass_180(.gn(I_2951_S), .gp(I_3013_S), .p1(I_3173_S), .p2(I_3175_D));
    generic_pmos I_3143(.D(I_3173_S), .G(I_3013_S), .S(I_3175_D));
    generic_nmos I_3142(.D(I_3173_S), .G(I_2951_S), .S(I_3175_D));
  generic_cmos pass_184(.gn(I_3013_S), .gp(I_2951_S), .p1(I_3175_D), .p2(I_3175_S));
    generic_pmos I_3175(.D(I_3175_D), .G(I_2951_S), .S(I_3175_S));
    generic_nmos I_3174(.D(I_3175_D), .G(I_3013_S), .S(I_3175_S));
  not auto_700(I_3111_S, I_3175_D);
    generic_pmos I_3111(.D(VDD), .G(I_3175_D), .S(I_3111_S));
    generic_nmos I_3110(.D(VSS), .G(I_3175_D), .S(I_3111_S));
  nand auto_683(I_3173_S, I_3111_S, I_3241_D);
    generic_pmos I_3047(.D(VDD), .G(I_3111_S), .S(I_3173_S));
    generic_pmos I_3079(.D(I_3173_S), .G(I_3241_D), .S(VDD));
    generic_nmos I_3046(.D(I_3173_S), .G(I_3111_S), .S(I_3078_D));
    generic_nmos I_3078(.D(I_3078_D), .G(I_3241_D), .S(VSS));

// Pair C5
// D-Type Flip Flop D: I_3333_S Q: I_3271_S ~Q: I_3333_S with Asynchronous RESET I_3241_D Falling Clock: I_3111_S, Rising: I_3173_S
// 2 Ganged D-Type latch with Asynchronous SET/RESETs I_3241_D
// D-Type latch D: I_3333_S ~Q: I_3335_S Q: I_3301_D with Asynchronous RESET I_3241_D Clock: I_3173_S, I_3111_S
// 2:1 Mux with two controls: Inputs: I_3301_D, I_3333_S Output: I_3333_D Controls: I_3173_S, I_3111_S
  generic_cmos pass_191(.gn(I_3173_S), .gp(I_3111_S), .p1(I_3301_D), .p2(I_3333_D));
    generic_pmos I_3301(.D(I_3301_D), .G(I_3111_S), .S(I_3333_D));
    generic_nmos I_3300(.D(I_3301_D), .G(I_3173_S), .S(I_3333_D));
  generic_cmos pass_198(.gn(I_3111_S), .gp(I_3173_S), .p1(I_3333_D), .p2(I_3333_S));
    generic_pmos I_3333(.D(I_3333_D), .G(I_3173_S), .S(I_3333_S));
    generic_nmos I_3332(.D(I_3333_D), .G(I_3111_S), .S(I_3333_S));
  nand auto_725(I_3335_S, I_3333_D, I_3241_D);
    generic_pmos I_3237(.D(VDD), .G(I_3241_D), .S(I_3335_S));
    generic_pmos I_3269(.D(I_3335_S), .G(I_3333_D), .S(VDD));
    generic_nmos I_3268(.D(I_3268_D), .G(I_3333_D), .S(I_3335_S));
    generic_nmos I_3236(.D(VSS), .G(I_3241_D), .S(I_3268_D));
  not auto_714(I_3301_D, I_3335_S);
    generic_pmos I_3205(.D(I_3301_D), .G(I_3335_S), .S(VDD));
    generic_nmos I_3204(.D(I_3301_D), .G(I_3335_S), .S(VSS));
// D-Type latch D: I_3335_S ~Q: I_3271_S Q: I_3333_S with Asynchronous SET I_3241_D Clock: I_3173_S, I_3111_S
// 2:1 Mux with two controls: Inputs: I_3333_S, I_3335_S Output: I_3335_D Controls: I_3111_S, I_3173_S
  generic_cmos pass_192(.gn(I_3111_S), .gp(I_3173_S), .p1(I_3333_S), .p2(I_3335_D));
    generic_pmos I_3303(.D(I_3333_S), .G(I_3173_S), .S(I_3335_D));
    generic_nmos I_3302(.D(I_3333_S), .G(I_3111_S), .S(I_3335_D));
  generic_cmos pass_199(.gn(I_3173_S), .gp(I_3111_S), .p1(I_3335_D), .p2(I_3335_S));
    generic_pmos I_3335(.D(I_3335_D), .G(I_3111_S), .S(I_3335_S));
    generic_nmos I_3334(.D(I_3335_D), .G(I_3173_S), .S(I_3335_S));
  not auto_733(I_3271_S, I_3335_D);
    generic_pmos I_3271(.D(VDD), .G(I_3335_D), .S(I_3271_S));
    generic_nmos I_3270(.D(VSS), .G(I_3335_D), .S(I_3271_S));
  nand auto_715(I_3333_S, I_3271_S, I_3241_D);
    generic_pmos I_3207(.D(VDD), .G(I_3271_S), .S(I_3333_S));
    generic_pmos I_3239(.D(I_3333_S), .G(I_3241_D), .S(VDD));
    generic_nmos I_3206(.D(I_3333_S), .G(I_3271_S), .S(I_3238_D));
    generic_nmos I_3238(.D(I_3238_D), .G(I_3241_D), .S(VSS));

// Pair C6
// D-Type Flip Flop D: I_3493_S Q: I_3431_S ~Q: I_3493_S with Asynchronous RESET I_3241_D Falling Clock: I_3271_S, I_3333_S
// 2 Ganged D-Type latch with Asynchronous SET/RESETs I_3241_D
// D-Type latch D: I_3493_S ~Q: I_3495_S Q: I_3461_D with Asynchronous RESET I_3241_D Clock: I_3333_S, I_3271_S
// 2:1 Mux with two controls: Inputs: I_3461_D, I_3493_S3431_S Output: I_3493_D Controls: I_3333_S, I_3271_S
  generic_cmos pass_206(.gn(I_3333_S), .gp(I_3271_S), .p1(I_3461_D), .p2(I_3493_D));
    generic_pmos I_3461(.D(I_3461_D), .G(I_3271_S), .S(I_3493_D));
    generic_nmos I_3460(.D(I_3461_D), .G(I_3333_S), .S(I_3493_D));
  generic_cmos pass_210(.gn(I_3271_S), .gp(I_3333_S), .p1(I_3493_D), .p2(I_3493_S));
    generic_pmos I_3493(.D(I_3493_D), .G(I_3333_S), .S(I_3493_S));
    generic_nmos I_3492(.D(I_3493_D), .G(I_3271_S), .S(I_3493_S));
  nand auto_762(I_3495_S, I_3241_D, I_3493_D);
    generic_pmos I_3397(.D(VDD), .G(I_3241_D), .S(I_3495_S));
    generic_pmos I_3429(.D(I_3495_S), .G(I_3493_D), .S(VDD));
    generic_nmos I_3428(.D(I_3428_D), .G(I_3493_D), .S(I_3495_S));
    generic_nmos I_3396(.D(VSS), .G(I_3241_D), .S(I_3428_D));
  not auto_750(I_3461_D, I_3495_S);
    generic_pmos I_3365(.D(I_3461_D), .G(I_3495_S), .S(VDD));
    generic_nmos I_3364(.D(I_3461_D), .G(I_3495_S), .S(VSS));
// D-Type latch D: I_3495_S ~Q: I_3431_S Q: I_3493_S  with Asynchronous SET I_3241_D Clock: I_3333_S, I_3271_S
// 2:1 Mux with two controls: Inputs: I_3493_S, I_3495_S Output: I_3495_D Controls: I_3271_S, I_3333_S
  generic_cmos pass_207(.gn(I_3271_S), .gp(I_3333_S), .p1(I_3493_S), .p2(I_3495_D));
    generic_pmos I_3463(.D(I_3493_S), .G(I_3333_S), .S(I_3495_D));
    generic_nmos I_3462(.D(I_3493_S), .G(I_3271_S), .S(I_3495_D));
  generic_cmos pass_211(.gn(I_3333_S), .gp(I_3271_S), .p1(I_3495_D), .p2(I_3495_S));
    generic_pmos I_3495(.D(I_3495_D), .G(I_3271_S), .S(I_3495_S));
    generic_nmos I_3494(.D(I_3495_D), .G(I_3333_S), .S(I_3495_S));
  not auto_768(I_3431_S, I_3495_D);
    generic_pmos I_3431(.D(VDD), .G(I_3495_D), .S(I_3431_S));
    generic_nmos I_3430(.D(VSS), .G(I_3495_D), .S(I_3431_S));
  nand auto_751(I_3493_S, I_3431_S, I_3241_D);
    generic_pmos I_3367(.D(VDD), .G(I_3431_S), .S(I_3493_S));
    generic_pmos I_3399(.D(I_3493_S), .G(I_3241_D), .S(VDD));
    generic_nmos I_3366(.D(I_3493_S), .G(I_3431_S), .S(I_3398_D));
    generic_nmos I_3398(.D(I_3398_D), .G(I_3241_D), .S(VSS));

// Pair C7
// D-Type Flip Flop D: I_3653_S Q: I_3591_S ~Q: I_3653_S with Asynchronous RESET I_3241_D Falling Clock: I_3431_S, Rising: I_3493_S 
// 2 Ganged D-Type latch with Asynchronous SET/RESETs I_3241_D
// D-Type latch D: I_3653_S ~Q: I_3655_S Q: I_3621_D with Asynchronous RESET I_3241_D Clock: I_3493_S, I_3431_S
// 2:1 Mux with two controls: Inputs: I_3621_D, I_3653_S Output: I_3653_D Controls: I_3493_S, I_3431_S
  generic_cmos pass_216(.gn(I_3493_S), .gp(I_3431_S), .p1(I_3621_D), .p2(I_3653_D));
    generic_pmos I_3621(.D(I_3621_D), .G(I_3431_S), .S(I_3653_D));
    generic_nmos I_3620(.D(I_3621_D), .G(I_3493_S), .S(I_3653_D));
  generic_cmos pass_221(.gn(I_3431_S), .gp(I_3493_S), .p1(I_3653_D), .p2(I_3653_S));
    generic_pmos I_3653(.D(I_3653_D), .G(I_3493_S), .S(I_3653_S));
    generic_nmos I_3652(.D(I_3653_D), .G(I_3431_S), .S(I_3653_S));
  nand auto_803(I_3655_S, I_3241_D, I_3653_D);
    generic_pmos I_3557(.D(VDD), .G(I_3241_D), .S(I_3655_S));
    generic_pmos I_3589(.D(I_3655_S), .G(I_3653_D), .S(VDD));
    generic_nmos I_3588(.D(I_3588_D), .G(I_3653_D), .S(I_3655_S));
    generic_nmos I_3556(.D(VSS), .G(I_3241_D), .S(I_3588_D));
  not auto_789(I_3621_D, I_3655_S);
    generic_pmos I_3525(.D(I_3621_D), .G(I_3655_S), .S(VDD));
    generic_nmos I_3524(.D(I_3621_D), .G(I_3655_S), .S(VSS));
// D-Type latch D: I_3655_S ~Q: I_3591_S Q: I_3653_S with Asynchronous SET I_3241_D Clock: I_3493_S, I_3431_S
// 2:1 Mux with two controls: Inputs: I_3653_S, I_3655_S Output: I_3655_D Controls: I_3431_S, I_3493_S
  generic_cmos pass_217(.gn(I_3431_S), .gp(I_3493_S), .p1(I_3653_S), .p2(I_3655_D));
    generic_pmos I_3623(.D(I_3653_S), .G(I_3493_S), .S(I_3655_D));
    generic_nmos I_3622(.D(I_3653_S), .G(I_3431_S), .S(I_3655_D));
  generic_cmos pass_222(.gn(I_3493_S), .gp(I_3431_S), .p1(I_3655_D), .p2(I_3655_S));
    generic_pmos I_3655(.D(I_3655_D), .G(I_3431_S), .S(I_3655_S));
    generic_nmos I_3654(.D(I_3655_D), .G(I_3493_S), .S(I_3655_S));
  // This inverter/NOT gate not identified in original verilog
  not manual_3(I_3591_S, I_3655_D)
    generic_pmos I_3591(.D(VDD), .G(I_3655_D), .S(I_3591_S));
    generic_nmos I_3590(.D(VSS), .G(I_3655_D), .S(I_3591_S));
  nand auto_790(I_3653_S, I_3241_D, I_3591_S);
    generic_pmos I_3527(.D(VDD), .G(I_3591_S), .S(I_3653_S));
    generic_pmos I_3559(.D(I_3653_S), .G(I_3241_D), .S(VDD));
    generic_nmos I_3526(.D(I_3653_S), .G(I_3591_S), .S(I_3558_D));
    generic_nmos I_3558(.D(I_3558_D), .G(I_3241_D), .S(VSS));

// Pair C8
// D-Type Flip Flop D: I_3813_S Q: I_3751_S ~Q: I_3813_S with Asynchronous RESET I_3241_D Falling Clock: I_3591_S, Rising: I_3653_S
// 2 Ganged D-Type latch with Asynchronous SET/RESETs I_3241_D
// D-Type latch D: I_3813_S ~Q: I_3815_S Q: I_3781_D with Asynchronous RESET I_3241_D Clock: I_3653_S, I_3591_S
// 2:1 Mux with two controls: Inputs: I_3781_D, I_3813_S Output: I_3813_D Controls: I_3653_S, I_3591_S
  generic_cmos pass_226(.gn(I_3653_S), .gp(I_3591_S), .p1(I_3781_D), .p2(I_3813_D));
    generic_pmos I_3781(.D(I_3781_D), .G(I_3591_S), .S(I_3813_D));
    generic_nmos I_3780(.D(I_3781_D), .G(I_3653_S), .S(I_3813_D));
  generic_cmos pass_228(.gn(I_3591_S), .gp(I_3653_S), .p1(I_3813_D), .p2(I_3813_S));
    generic_pmos I_3813(.D(I_3813_D), .G(I_3653_S), .S(I_3813_S));
    generic_nmos I_3812(.D(I_3813_D), .G(I_3591_S), .S(I_3813_S));
  nand auto_840(I_3815_S, I_3241_D, I_3813_D);
    generic_pmos I_3717(.D(VDD), .G(I_3241_D), .S(I_3815_S));
    generic_pmos I_3749(.D(I_3815_S), .G(I_3813_D), .S(VDD));
    generic_nmos I_3748(.D(I_3748_D), .G(I_3813_D), .S(I_3815_S));
    generic_nmos I_3716(.D(VSS), .G(I_3241_D), .S(I_3748_D));
  not auto_824(I_3781_D, I_3815_S);
    generic_pmos I_3685(.D(I_3781_D), .G(I_3815_S), .S(VDD));
    generic_nmos I_3684(.D(I_3781_D), .G(I_3815_S), .S(VSS));
// D-Type latch D: I_3815_S ~Q: I_3751_S Q: I_3813_S with Asynchronous SET I_3241_D Clock: I_3653_S, I_3591_S
// 2:1 Mux with two controls: Inputs: I_3813_S, I_3815_S Output: I_3815_D Controls: I_3591_S, I_3653_S
  generic_cmos pass_227(.gn(I_3591_S), .gp(I_3653_S), .p1(I_3813_S), .p2(I_3815_D));
    generic_pmos I_3783(.D(I_3813_S), .G(I_3653_S), .S(I_3815_D));
    generic_nmos I_3782(.D(I_3813_S), .G(I_3591_S), .S(I_3815_D));
  generic_cmos pass_229(.gn(I_3653_S), .gp(I_3591_S), .p1(I_3815_D), .p2(I_3815_S));
    generic_pmos I_3815(.D(I_3815_D), .G(I_3591_S), .S(I_3815_S));
    generic_nmos I_3814(.D(I_3815_D), .G(I_3653_S), .S(I_3815_S));
  not auto_842(I_3751_S, I_3815_D);
    generic_pmos I_3751(.D(VDD), .G(I_3815_D), .S(I_3751_S));
    generic_nmos I_3750(.D(VSS), .G(I_3815_D), .S(I_3751_S));
  nand auto_825(I_3813_S, I_3241_D, I_3751_S);
    generic_pmos I_3687(.D(VDD), .G(I_3751_S), .S(I_3813_S));
    generic_pmos I_3719(.D(I_3813_S), .G(I_3241_D), .S(VDD));
    generic_nmos I_3686(.D(I_3813_S), .G(I_3751_S), .S(I_3718_D));
    generic_nmos I_3718(.D(I_3718_D), .G(I_3241_D), .S(VSS));

// Produces copy of VC3
  not auto_435(I_1741_S, I_3013_S);
    generic_pmos I_1741(.D(VDD), .G(I_3013_S), .S(I_1741_S));
    generic_nmos I_1708(.D(I_1741_S), .G(I_3013_S), .S(VSS));
// Produces copy of VC8, also clocks into next section (frame count)
  not auto_813(I_3657_D, I_3813_S); // NMOS strength = 2
    generic_pmos I_3625(.D(VDD), .G(I_3813_S), .S(I_3657_D));
    generic_pmos I_3657(.D(I_3657_D), .G(I_3813_S), .S(VDD));
    generic_nmos I_3624(.D(VSS), .G(I_3813_S), .S(I_3657_D));
    generic_nmos I_3656(.D(I_3657_D), .G(I_3813_S), .S(VSS));

// ********************************************************************************************************

// Video Counter Combinatorial Logic - signals derived from counters

// Vertical - Create ~VSYNC50 when VCount = 256-259 (4 scanlines = 256us sync)
  nand auto_788(I_3587_D, I_3657_D, I_3333_S, I_3173_S);
    generic_pmos I_3523(.D(I_3587_D), .G(I_3333_S), .S(VDD));
    generic_pmos I_3555(.D(VDD), .G(I_3657_D), .S(I_3587_D));
    generic_pmos I_3587(.D(I_3587_D), .G(I_3173_S), .S(VDD));
    generic_nmos I_3522(.D(I_3587_D), .G(I_3333_S), .S(I_3554_D));
    generic_nmos I_3554(.D(I_3554_D), .G(I_3657_D), .S(I_3586_D));
    generic_nmos I_3586(.D(I_3586_D), .G(I_3173_S), .S(VSS));
  nand auto_761(I_3427_D, I_2853_S, I_3013_S);
    generic_pmos I_3395(.D(VDD), .G(I_2853_S), .S(I_3427_D));
    generic_pmos I_3427(.D(I_3427_D), .G(I_3013_S), .S(VDD));
    generic_nmos I_3426(.D(I_3426_D), .G(I_3013_S), .S(I_3427_D));
    generic_nmos I_3394(.D(VSS), .G(I_2853_S), .S(I_3426_D));
  nor auto_783(I_3491_S, I_3587_D, I_3427_D);
    generic_pmos I_3459(.D(VDD), .G(I_3587_D), .S(I_3491_D));
    generic_pmos I_3491(.D(I_3491_D), .G(I_3427_D), .S(I_3491_S));
    generic_nmos I_3458(.D(VSS), .G(I_3427_D), .S(I_3491_S));
    generic_nmos I_3490(.D(I_3491_S), .G(I_3587_D), .S(VSS));
  not auto_749(I_2083_G, I_3491_S);
    generic_pmos I_3363(.D(I_2083_G), .G(I_3491_S), .S(VDD));
    generic_nmos I_3362(.D(I_2083_G), .G(I_3491_S), .S(VSS));

// Vertical - Create ~VSYNC60 when VCount = 236-239 (4 scanlines = 256us sync)
  nor auto_602(I_2632_D, I_3653_S, I_3493_S, I_3333_S);
    generic_pmos I_2633(.D(I_2633_D), .G(I_3653_S), .S(VDD));
    generic_pmos I_2601(.D(I_2601_D), .G(I_3333_S), .S(I_2633_D));
    generic_pmos I_2569(.D(I_2632_D), .G(I_3493_S), .S(I_2601_D));
    generic_nmos I_2568(.D(I_2632_D), .G(I_3493_S), .S(VSS));
    generic_nmos I_2600(.D(VSS), .G(I_3333_S), .S(I_2632_D));
    generic_nmos I_2632(.D(I_2632_D), .G(I_3653_S), .S(VSS));
  nand auto_706(I_3171_D, I_3173_S, I_3013_S);
    generic_pmos I_3139(.D(VDD), .G(I_3013_S), .S(I_3171_D));
    generic_pmos I_3171(.D(I_3171_D), .G(I_3173_S), .S(VDD));
    generic_nmos I_3138(.D(I_3171_D), .G(I_3173_S), .S(I_3170_D));
    generic_nmos I_3170(.D(I_3170_D), .G(I_3013_S), .S(VSS));
  nand auto_671(I_3075_D, I_2632_D, I_2791_S, I_3173_S, I_3171_D);
    generic_pmos I_2979(.D(VDD), .G(I_2791_S), .S(I_3075_D));
    generic_pmos I_3011(.D(I_3075_D), .G(I_2632_D), .S(VDD));
    generic_pmos I_3043(.D(VDD), .G(I_3173_S), .S(I_3075_D));
    generic_pmos I_3075(.D(I_3075_D), .G(I_3171_D), .S(VDD));
    generic_nmos I_2978(.D(I_3075_D), .G(I_2632_D), .S(I_3010_D));
    generic_nmos I_3010(.D(I_3010_D), .G(I_2791_S), .S(I_3042_D));
    generic_nmos I_3042(.D(I_3042_D), .G(I_3173_S), .S(I_3074_D));
    generic_nmos I_3074(.D(I_3074_D), .G(I_3171_D), .S(VSS));

// Pick between ~VSYNC50/~VSYNC60 into ~VSYNC (on attribute selection)
  nand auto_509(I_2115_D, I_2083_G, I_1033_D);
    generic_pmos I_2083(.D(VDD), .G(I_2083_G), .S(I_2115_D));
    generic_pmos I_2115(.D(I_2115_D), .G(I_1033_D), .S(VDD));
    generic_nmos I_2082(.D(I_2115_D), .G(I_2083_G), .S(I_2114_D));
    generic_nmos I_2114(.D(I_2114_D), .G(I_1033_D), .S(VSS));
  nand auto_500(I_2051_D, I_3075_D, I_2147_S);
    generic_pmos I_2019(.D(VDD), .G(I_3075_D), .S(I_2051_D));
    generic_pmos I_2051(.D(I_2051_D), .G(I_2147_S), .S(VDD));
    generic_nmos I_2018(.D(I_2051_D), .G(I_2147_S), .S(I_2050_D));
    generic_nmos I_2050(.D(I_2050_D), .G(I_3075_D), .S(VSS));
  not auto_523(I_2147_S, I_1033_D);
    generic_pmos I_2147(.D(VDD), .G(I_1033_D), .S(I_2147_S));
    generic_nmos I_2146(.D(VSS), .G(I_1033_D), .S(I_2147_S));
  nand auto_490(I_1987_D, I_2115_D, I_2051_D);
    generic_pmos I_1955(.D(VDD), .G(I_2051_D), .S(I_1987_D));
    generic_pmos I_1987(.D(I_1987_D), .G(I_2115_D), .S(VDD));
    generic_nmos I_1986(.D(I_1986_D), .G(I_2115_D), .S(I_1987_D));
    generic_nmos I_1954(.D(VSS), .G(I_2051_D), .S(I_1986_D));

// Vertical - Create VBLANK when VCount >= 224 (blackens top and bottom edge of video)
  nor auto_569(I_2371_S, I_2632_D, I_3657_D);
    generic_pmos I_2339(.D(VDD), .G(I_3657_D), .S(I_2371_D));
    generic_pmos I_2371(.D(I_2371_D), .G(I_2632_D), .S(I_2371_S));
    generic_nmos I_2338(.D(VSS), .G(I_2632_D), .S(I_2371_S));
    generic_nmos I_2370(.D(I_2371_S), .G(I_3657_D), .S(VSS));

// Vertical - Create FORCETXT when VCount = 200 or higher (last 3 lines must be text).
// Takes existing attribute mode (requested) in I_873_D (0=text,1=hires)
// and produces 1=Text, 0=Hires in I_3499_D, where attribute is overridden at line 200
  nor auto_604(I_2634_D, I_3493_S, I_3751_S, I_3653_S);
    generic_pmos I_2635(.D(I_2635_D), .G(I_3653_S), .S(VDD));
    generic_pmos I_2603(.D(I_2603_D), .G(I_3493_S), .S(I_2635_D));
    generic_pmos I_2571(.D(I_2634_D), .G(I_3751_S), .S(I_2603_D));
    generic_nmos I_2570(.D(I_2634_D), .G(I_3751_S), .S(VSS));
    generic_nmos I_2602(.D(VSS), .G(I_3493_S), .S(I_2634_D));
    generic_nmos I_2634(.D(I_2634_D), .G(I_3653_S), .S(VSS));
  nor auto_627(I_2794_D, I_3271_S, I_2951_S, I_3111_S);
    generic_pmos I_2795(.D(I_2795_D), .G(I_3271_S), .S(VDD));
    generic_pmos I_2763(.D(I_2763_D), .G(I_3111_S), .S(I_2795_D));
    generic_pmos I_2731(.D(I_2794_D), .G(I_2951_S), .S(I_2763_D));
    generic_nmos I_2730(.D(I_2794_D), .G(I_2951_S), .S(VSS));
    generic_nmos I_2762(.D(VSS), .G(I_3111_S), .S(I_2794_D));
    generic_nmos I_2794(.D(I_2794_D), .G(I_3271_S), .S(VSS));
  nand auto_618(I_2699_D, I_2634_D, I_2794_D);
    generic_pmos I_2667(.D(VDD), .G(I_2794_D), .S(I_2699_D));
    generic_pmos I_2699(.D(I_2699_D), .G(I_2634_D), .S(VDD));
    generic_nmos I_2666(.D(I_2699_D), .G(I_2634_D), .S(I_2698_D));
    generic_nmos I_2698(.D(I_2698_D), .G(I_2794_D), .S(VSS));
  not auto_501(I_2058_S, I_2699_D);
    generic_pmos I_2027(.D(I_2058_S), .G(I_2699_D), .S(VDD));
    generic_nmos I_2058(.D(VSS), .G(I_2699_D), .S(I_2058_S));
  nor auto_597(I_2539_S, I_3751_S, I_3591_S);
    generic_pmos I_2507(.D(VDD), .G(I_3591_S), .S(I_2539_D));
    generic_pmos I_2539(.D(I_2539_D), .G(I_3751_S), .S(I_2539_S));
    generic_nmos I_2506(.D(VSS), .G(I_3751_S), .S(I_2539_S));
    generic_nmos I_2538(.D(I_2539_S), .G(I_3591_S), .S(VSS));
  nor auto_793(I_3562_D, I_3657_D, I_3431_S);
    generic_pmos I_3563(.D(I_3563_D), .G(I_3657_D), .S(VDD));
    generic_pmos I_3531(.D(I_3562_D), .G(I_3431_S), .S(I_3563_D));
    generic_nmos I_3530(.D(VSS), .G(I_3431_S), .S(I_3562_D));
    generic_nmos I_3562(.D(I_3562_D), .G(I_3657_D), .S(VSS));
  nor auto_512(I_2154_D, I_3562_D, I_2539_S, I_2058_S);
    generic_pmos I_2155(.D(I_2155_D), .G(I_2539_S), .S(VDD));
    generic_pmos I_2123(.D(I_2123_D), .G(I_3562_D), .S(I_2155_D));
    generic_pmos I_2091(.D(I_2154_D), .G(I_2058_S), .S(I_2123_D));
    generic_nmos I_2090(.D(I_2154_D), .G(I_2058_S), .S(VSS));
    generic_nmos I_2122(.D(VSS), .G(I_3562_D), .S(I_2154_D));
    generic_nmos I_2154(.D(I_2154_D), .G(I_2539_S), .S(VSS));
  not auto_538(I_2219_S, I_2154_D);
    generic_pmos I_2219(.D(VDD), .G(I_2154_D), .S(I_2219_S));
    generic_nmos I_2186(.D(I_2219_S), .G(I_2154_D), .S(VSS));

// Vertical - Create VFRAME reset when VCount = 312 (50 Hz) or 264 (60Hz) (reset vertical counter)
// 50Hz: 
  nand auto_645(I_2955_D, I_3751_S, I_3271_S, I_2951_S, I_3111_S);
    generic_pmos I_2827(.D(I_2955_D), .G(I_3751_S), .S(VDD));
    generic_pmos I_2891(.D(I_2955_D), .G(I_3271_S), .S(VDD));
    generic_pmos I_2923(.D(VDD), .G(I_2951_S), .S(I_2955_D));
    generic_pmos I_2955(.D(I_2955_D), .G(I_3111_S), .S(VDD));
    generic_nmos I_2954(.D(I_2954_D), .G(I_3111_S), .S(I_2955_D));
    generic_nmos I_2922(.D(I_2922_D), .G(I_2951_S), .S(I_2954_D));
    generic_nmos I_2890(.D(I_2890_D), .G(I_3271_S), .S(I_2922_D));
    generic_nmos I_2858(.D(VSS), .G(I_3751_S), .S(I_2890_D));
// 60Hz:
  nand auto_685(I_3083_D, I_3657_D, I_2951_S);
    generic_pmos I_3051(.D(VDD), .G(I_2951_S), .S(I_3083_D));
    generic_pmos I_3083(.D(I_3083_D), .G(I_3657_D), .S(VDD));
    generic_nmos I_3050(.D(I_3083_D), .G(I_2951_S), .S(I_3082_D));
    generic_nmos I_3082(.D(I_3082_D), .G(I_3657_D), .S(VSS));
// 2:1 Mux select between these on attribute
  nand auto_663(I_2953_D, I_2955_D, I_1033_D);
    generic_pmos I_2921(.D(VDD), .G(I_1033_D), .S(I_2953_D));
    generic_pmos I_2953(.D(I_2953_D), .G(I_2955_D), .S(VDD));
    generic_nmos I_2952(.D(I_2952_D), .G(I_2955_D), .S(I_2953_D));
    generic_nmos I_2920(.D(VSS), .G(I_1033_D), .S(I_2952_D));
  nand auto_672(I_3017_D, I_2889_D, I_3083_D);
    generic_pmos I_2985(.D(VDD), .G(I_3083_D), .S(I_3017_D));
    generic_pmos I_3017(.D(I_3017_D), .G(I_2889_D), .S(VDD));
    generic_nmos I_3016(.D(I_3016_D), .G(I_3083_D), .S(I_3017_D));
    generic_nmos I_2984(.D(VSS), .G(I_2889_D), .S(I_3016_D));
  not auto_654(I_2889_D, I_1033_D);
    generic_pmos I_2889(.D(I_2889_D), .G(I_1033_D), .S(VDD));
    generic_nmos I_2888(.D(I_2889_D), .G(I_1033_D), .S(VSS));
  nand auto_684(I_3112_D, I_2953_D, I_3017_D);
    generic_pmos I_3049(.D(VDD), .G(I_2953_D), .S(I_3112_D));
    generic_pmos I_3081(.D(I_3112_D), .G(I_3017_D), .S(VDD));
    generic_nmos I_3080(.D(I_3080_D), .G(I_3017_D), .S(I_3112_D));
    generic_nmos I_3048(.D(VSS), .G(I_2953_D), .S(I_3080_D));
// Include external video reset too!
  nand auto_707(I_3177_D, I_1311_G, I_3112_D);
    generic_pmos I_3145(.D(VDD), .G(I_1311_G), .S(I_3177_D));
    generic_pmos I_3177(.D(I_3177_D), .G(I_3112_D), .S(VDD));
    generic_nmos I_3176(.D(I_3176_D), .G(I_1311_G), .S(I_3177_D));
    generic_nmos I_3144(.D(VSS), .G(I_3112_D), .S(I_3176_D));

// ********************************************************************************************************

// Frame video counter (divider) (See Page 9)

// Drives the reset line for A1-A5 pairs/counter
  not auto_452(I_3393_G, I_1345_D); // NMOS strength = 2
    generic_pmos I_1793(.D(VDD), .G(I_1345_D), .S(I_3393_G));
    generic_pmos I_1825(.D(I_3393_G), .G(I_1345_D), .S(VDD));
    generic_nmos I_1792(.D(VSS), .G(I_1345_D), .S(I_3393_G));
    generic_nmos I_1824(.D(I_3393_G), .G(I_1345_D), .S(VSS));

// 5 bit counter, (Field/frame counter for flashing effects)
// Set of 10 D-Type latches with Asynchronous SET/RESETs I_3393_G
// In 5 looped pairs (A1 to A5) to make 5 edge-triggered flip flops, 5 bit counter
// Logically re-ordered A1/A5/A4/A3/A2 -- with Q/Q~ driving next one's clock inputs
// Flash clock is I_1985_S

// Pair A1
// D-Type Flip Flop D: I_3489_S Q: I_3265_S ~Q: I_3489_S with Asynchronous RESET I_3393_G Falling Clock: I_3657_D
// D-Type latch D: I_3489_S ~Q: I_3393_D Q: I_3457_D with Asynchronous RESET I_3393_G Clock: I_3657_D
// 2:1 Mux with single control: Inputs: I_3457_D, I_3489_S Output: I_3489_D Control: I_3657_D
  generic_cmos pass_205(.gn(I_3521_D), .gp(I_3657_D), .p1(I_3457_D), .p2(I_3489_D));
    generic_pmos I_3457(.D(I_3457_D), .G(I_3657_D), .S(I_3489_D));
    generic_nmos I_3456(.D(I_3457_D), .G(I_3521_D), .S(I_3489_D));
  generic_cmos pass_209(.gn(I_3657_D), .gp(I_3521_D), .p1(I_3489_D), .p2(I_3489_S));
    generic_pmos I_3489(.D(I_3489_D), .G(I_3521_D), .S(I_3489_S));
    generic_nmos I_3488(.D(I_3489_D), .G(I_3657_D), .S(I_3489_S));
  nand auto_748(I_3393_D, I_3489_D, I_3393_G);
    generic_pmos I_3361(.D(VDD), .G(I_3489_D), .S(I_3393_D));
    generic_pmos I_3393(.D(I_3393_D), .G(I_3393_G), .S(VDD));
    generic_nmos I_3360(.D(I_3393_D), .G(I_3489_D), .S(I_3392_D));
    generic_nmos I_3392(.D(I_3392_D), .G(I_3393_G), .S(VSS));
  not auto_766(I_3457_D, I_3393_D);
    generic_pmos I_3425(.D(VDD), .G(I_3393_D), .S(I_3457_D));
    generic_nmos I_3424(.D(VSS), .G(I_3393_D), .S(I_3457_D));
// D-Type latch D: I_3393_D ~Q: I_3265_S Q: I_3489_S with Asynchronous SET I_3393_G Clock: I_3657_D
// 2:1 Mux with single control: Inputs: I_3489_S, I_3393_D Output: I_3329_D Control: I_3657_D
  generic_cmos pass_190(.gn(I_3657_D), .gp(I_3521_D), .p1(I_3489_S), .p2(I_3329_D));
    generic_pmos I_3297(.D(I_3489_S), .G(I_3521_D), .S(I_3329_D));
    generic_nmos I_3296(.D(I_3489_S), .G(I_3657_D), .S(I_3329_D));
  generic_cmos pass_197(.gn(I_3521_D), .gp(I_3657_D), .p1(I_3329_D), .p2(I_3393_D));
    generic_pmos I_3329(.D(I_3329_D), .G(I_3657_D), .S(I_3393_D));
    generic_nmos I_3328(.D(I_3329_D), .G(I_3521_D), .S(I_3393_D));
  not auto_731(I_3265_S, I_3329_D);
    generic_pmos I_3265(.D(VDD), .G(I_3329_D), .S(I_3265_S));
    generic_nmos I_3264(.D(VSS), .G(I_3329_D), .S(I_3265_S));
  nand auto_713(I_3489_S, I_3393_G, I_3265_S);
    generic_pmos I_3201(.D(VDD), .G(I_3393_G), .S(I_3489_S));
    generic_pmos I_3233(.D(I_3489_S), .G(I_3265_S), .S(VDD));
    generic_nmos I_3200(.D(I_3489_S), .G(I_3393_G), .S(I_3232_D));
    generic_nmos I_3232(.D(I_3232_D), .G(I_3265_S), .S(VSS));
// Shared Driver
  not auto_787(I_3521_D, I_3657_D);
    generic_pmos I_3521(.D(I_3521_D), .G(I_3657_D), .S(VDD));
    generic_nmos I_3520(.D(I_3521_D), .G(I_3657_D), .S(VSS));

// Pair A5
// D-Type Flip Flop D: I_3169_S Q: I_2945_S ~Q: I_3169_S with Asynchronous RESET I_3393_G Falling Clock: I_3265_S, Rising: I_3489_S 
// 2 Ganged D-Type latch with Asynchronous SET/RESETs I_3393_G
// D-Type latch D: I_3169_S ~Q: I_3073_D Q: I_3137_D  with Asynchronous RESET I_3393_G Clock: I_3265_S, I_3489_S 
// 2:1 Mux with two controls: Inputs: I_3137_D, I_3169_S Output: I_3169_D Controls: I_3489_S. I_3265_S
  generic_cmos pass_178(.gn(I_3489_S), .gp(I_3265_S), .p1(I_3137_D), .p2(I_3169_D));
    generic_pmos I_3137(.D(I_3137_D), .G(I_3265_S), .S(I_3169_D));
    generic_nmos I_3136(.D(I_3137_D), .G(I_3489_S), .S(I_3169_D));
  generic_cmos pass_181(.gn(I_3265_S), .gp(I_3489_S), .p1(I_3169_D), .p2(I_3169_S));
    generic_pmos I_3169(.D(I_3169_D), .G(I_3489_S), .S(I_3169_S));
    generic_nmos I_3168(.D(I_3169_D), .G(I_3265_S), .S(I_3169_S));
  nand auto_681(I_3073_D, I_3393_G, I_3169_D);
    generic_pmos I_3041(.D(VDD), .G(I_3169_D), .S(I_3073_D));
    generic_pmos I_3073(.D(I_3073_D), .G(I_3393_G), .S(VDD));
    generic_nmos I_3040(.D(I_3073_D), .G(I_3169_D), .S(I_3072_D));
    generic_nmos I_3072(.D(I_3072_D), .G(I_3393_G), .S(VSS));
  not auto_699(I_3137_D, I_3073_D);
    generic_pmos I_3105(.D(VDD), .G(I_3073_D), .S(I_3137_D));
    generic_nmos I_3104(.D(VSS), .G(I_3073_D), .S(I_3137_D));
// D-Type latch D: I_3073_D ~Q: I_2945_S Q: I_3169_S  with Asynchronous SET I_3393_G Clock: I_3265_S, I_3489_S
// 2:1 Mux with two controls: Inputs: I_3169_S, I_3073_D Output: I_3009_D Controls: I_3265_S, I_3489_S
  generic_cmos pass_162(.gn(I_3265_S), .gp(I_3489_S), .p1(I_3169_S), .p2(I_3009_D));
    generic_pmos I_2977(.D(I_3169_S), .G(I_3489_S), .S(I_3009_D));
    generic_nmos I_2976(.D(I_3169_S), .G(I_3265_S), .S(I_3009_D));
  generic_cmos pass_169(.gn(I_3489_S), .gp(I_3265_S), .p1(I_3009_D), .p2(I_3073_D));
    generic_pmos I_3009(.D(I_3009_D), .G(I_3265_S), .S(I_3073_D));
    generic_nmos I_3008(.D(I_3009_D), .G(I_3489_S), .S(I_3073_D));
  not auto_667(I_2945_S, I_3009_D);
    generic_pmos I_2945(.D(VDD), .G(I_3009_D), .S(I_2945_S));
    generic_nmos I_2944(.D(VSS), .G(I_3009_D), .S(I_2945_S));
  nand auto_651(I_3169_S, I_3393_G, I_2945_S);
    generic_pmos I_2881(.D(VDD), .G(I_3393_G), .S(I_3169_S));
    generic_pmos I_2913(.D(I_3169_S), .G(I_2945_S), .S(VDD));
    generic_nmos I_2880(.D(I_3169_S), .G(I_3393_G), .S(I_2912_D));
    generic_nmos I_2912(.D(I_2912_D), .G(I_2945_S), .S(VSS));

// Pair A4
// D-Type Flip Flop D: I_2849_S Q: I_2625_S ~Q: I_2849_S with Asynchronous RESET I_3393_G Falling Clock: I_2945_S, Rising: I_3169_S 
// 2 Ganged D-Type latch with Asynchronous SET/RESETs I_3393_G
// D-Type latch D: I_2849_S ~Q: I_2753_D Q: I_2817_D with Asynchronous RESET I_3393_G Clock: I_2945_S, I_3169_S 
// 2:1 Mux with two controls: Inputs: I_2817_D, I_2849_S Output: I_2849_D Controls: I_3169_S, I_2945_S
  generic_cmos pass_147(.gn(I_3169_S), .gp(I_2945_S), .p1(I_2817_D), .p2(I_2849_D));
    generic_pmos I_2817(.D(I_2817_D), .G(I_2945_S), .S(I_2849_D));
    generic_nmos I_2816(.D(I_2817_D), .G(I_3169_S), .S(I_2849_D));
  generic_cmos pass_152(.gn(I_2945_S), .gp(I_3169_S), .p1(I_2849_D), .p2(I_2849_S));
    generic_pmos I_2849(.D(I_2849_D), .G(I_3169_S), .S(I_2849_S));
    generic_nmos I_2848(.D(I_2849_D), .G(I_2945_S), .S(I_2849_S));
  nand auto_624(I_2753_D, I_2849_D, I_3393_G);
    generic_pmos I_2721(.D(VDD), .G(I_2849_D), .S(I_2753_D));
    generic_pmos I_2753(.D(I_2753_D), .G(I_3393_G), .S(VDD));
    generic_nmos I_2720(.D(I_2753_D), .G(I_2849_D), .S(I_2752_D));
    generic_nmos I_2752(.D(I_2752_D), .G(I_3393_G), .S(VSS));
  not auto_640(I_2817_D, I_2753_D);
    generic_pmos I_2785(.D(VDD), .G(I_2753_D), .S(I_2817_D));
    generic_nmos I_2784(.D(VSS), .G(I_2753_D), .S(I_2817_D));
// D-Type latch D: I_2753_D ~Q: I_2625_S Q: I_2849_S with Asynchronous SET I_3393_G Clock: I_2945_S, I_3169_S
// 2:1 Mux with two controls: Inputs: I_2849_S, I_2753_D Output: I_2689_D Controls: I_2945_S, I_3169_S
  generic_cmos pass_130(.gn(I_2945_S), .gp(I_3169_S), .p1(I_2849_S), .p2(I_2689_D));
    generic_pmos I_2657(.D(I_2849_S), .G(I_3169_S), .S(I_2689_D));
    generic_nmos I_2656(.D(I_2849_S), .G(I_2945_S), .S(I_2689_D));
  generic_cmos pass_137(.gn(I_3169_S), .gp(I_2945_S), .p1(I_2689_D), .p2(I_2753_D));
    generic_pmos I_2689(.D(I_2689_D), .G(I_2945_S), .S(I_2753_D));
    generic_nmos I_2688(.D(I_2689_D), .G(I_3169_S), .S(I_2753_D));
  not auto_614(I_2625_S, I_2689_D);
    generic_pmos I_2625(.D(VDD), .G(I_2689_D), .S(I_2625_S));
    generic_nmos I_2624(.D(VSS), .G(I_2689_D), .S(I_2625_S));
  nand auto_599(I_2849_S, I_3393_G, I_2625_S);
    generic_pmos I_2561(.D(VDD), .G(I_3393_G), .S(I_2849_S));
    generic_pmos I_2593(.D(I_2849_S), .G(I_2625_S), .S(VDD));
    generic_nmos I_2560(.D(I_2849_S), .G(I_3393_G), .S(I_2592_D));
    generic_nmos I_2592(.D(I_2592_D), .G(I_2625_S), .S(VSS));

// Pair A3
// D-Type Flip Flop D: I_2529_S Q: I_2305_S ~Q: I_2529_S with Asynchronous RESET I_3393_G Falling Clock: I_2625_S, Rising: I_2849_S
// 2 Ganged D-Type latch with Asynchronous SET/RESETs I_3393_G
// D-Type latch D: I_2529_S ~Q: I_2433_D Q: I_2497_D with Asynchronous RESET I_3393_G Clock: I_2625_S, I_2849_S
// 2:1 Mux with two controls: Inputs: I_2497_D, I_2529_S Output: I_2529_D Controls: I_2849_S, I_2625_S
  generic_cmos pass_117(.gn(I_2849_S), .gp(I_2625_S), .p1(I_2497_D), .p2(I_2529_D));
    generic_pmos I_2497(.D(I_2497_D), .G(I_2625_S), .S(I_2529_D));
    generic_nmos I_2496(.D(I_2497_D), .G(I_2849_S), .S(I_2529_D));
  generic_cmos pass_122(.gn(I_2625_S), .gp(I_2849_S), .p1(I_2529_D), .p2(I_2529_S));
    generic_pmos I_2529(.D(I_2529_D), .G(I_2849_S), .S(I_2529_S));
    generic_nmos I_2528(.D(I_2529_D), .G(I_2625_S), .S(I_2529_S));
  nand auto_571(I_2433_D, I_2529_D, I_3393_G);
    generic_pmos I_2401(.D(VDD), .G(I_2529_D), .S(I_2433_D));
    generic_pmos I_2433(.D(I_2433_D), .G(I_3393_G), .S(VDD));
    generic_nmos I_2400(.D(I_2433_D), .G(I_2529_D), .S(I_2432_D));
    generic_nmos I_2432(.D(I_2432_D), .G(I_3393_G), .S(VSS));
  not auto_586(I_2497_D, I_2433_D);
    generic_pmos I_2465(.D(VDD), .G(I_2433_D), .S(I_2497_D));
    generic_nmos I_2464(.D(VSS), .G(I_2433_D), .S(I_2497_D));
// D-Type latch D: I_2433_D ~Q: I_2305_S Q: I_2529_S with Asynchronous SET I_3393_G Clock: I_2625_S, I_2849_S
// 2:1 Mux with two controls: Inputs: I_2529_S, I_2433_D Output: I_2369_D Controls: I_2625_S, I_2849_S
  generic_cmos pass_108(.gn(I_2625_S), .gp(I_2849_S), .p1(I_2529_S), .p2(I_2369_D));
    generic_pmos I_2337(.D(I_2529_S), .G(I_2849_S), .S(I_2369_D));
    generic_nmos I_2336(.D(I_2529_S), .G(I_2625_S), .S(I_2369_D));
  generic_cmos pass_112(.gn(I_2849_S), .gp(I_2625_S), .p1(I_2369_D), .p2(I_2433_D));
    generic_pmos I_2369(.D(I_2369_D), .G(I_2625_S), .S(I_2433_D));
    generic_nmos I_2368(.D(I_2369_D), .G(I_2849_S), .S(I_2433_D));
  not auto_558(I_2305_S, I_2369_D);
    generic_pmos I_2305(.D(VDD), .G(I_2369_D), .S(I_2305_S));
    generic_nmos I_2304(.D(VSS), .G(I_2369_D), .S(I_2305_S));
  nand auto_540(I_2529_S, I_2305_S, I_3393_G);
    generic_pmos I_2241(.D(VDD), .G(I_3393_G), .S(I_2529_S));
    generic_pmos I_2273(.D(I_2529_S), .G(I_2305_S), .S(VDD));
    generic_nmos I_2240(.D(I_2529_S), .G(I_3393_G), .S(I_2272_D));
    generic_nmos I_2272(.D(I_2272_D), .G(I_2305_S), .S(VSS));

// Pair A2
// D-Type Flip Flop D: I_2209_S Q: I_1985_S ~Q: I_2209_S with Asynchronous RESET I_3393_G Falling Clock: I_2305_S, Rising: I_2529_S 
// 2 Ganged D-Type latch with Asynchronous SET/RESETs I_3393_G
// D-Type latch D: I_2209_S ~Q: I_2113_D Q: I_2177_D with Asynchronous RESET I_3393_G Clock: I_2305_S, I_2529_S 
// 2:1 Mux with two controls: Inputs: I_2209_S, I_2177_D Output: I_2209_D Controls: I_2305_S, I_2529_S
  generic_cmos pass_103(.gn(I_2305_S), .gp(I_2529_S), .p1(I_2209_D), .p2(I_2209_S));
    generic_pmos I_2209(.D(I_2209_D), .G(I_2529_S), .S(I_2209_S));
    generic_nmos I_2208(.D(I_2209_D), .G(I_2305_S), .S(I_2209_S));
  generic_cmos pass_99(.gn(I_2529_S), .gp(I_2305_S), .p1(I_2177_D), .p2(I_2209_D));
    generic_pmos I_2177(.D(I_2177_D), .G(I_2305_S), .S(I_2209_D));
    generic_nmos I_2176(.D(I_2177_D), .G(I_2529_S), .S(I_2209_D));
  nand auto_508(I_2113_D, I_2209_D, I_3393_G);
    generic_pmos I_2081(.D(VDD), .G(I_2209_D), .S(I_2113_D));
    generic_pmos I_2113(.D(I_2113_D), .G(I_3393_G), .S(VDD));
    generic_nmos I_2080(.D(I_2113_D), .G(I_2209_D), .S(I_2112_D));
    generic_nmos I_2112(.D(I_2112_D), .G(I_3393_G), .S(VSS));
  not auto_522(I_2177_D, I_2113_D);
    generic_pmos I_2145(.D(VDD), .G(I_2113_D), .S(I_2177_D));
    generic_nmos I_2144(.D(VSS), .G(I_2113_D), .S(I_2177_D));
// D-Type latch D: I_2113_D ~Q: I_1985_S Q: I_2209_S with Asynchronous SET I_3393_G Clock: I_2305_S, I_2529_S
// 2:1 Mux with two controls: Inputs: I_2209_S, I_2113_D Output: I_2049_D Controls: I_2305_S, I_2529_S
  generic_cmos pass_87(.gn(I_2305_S), .gp(I_2529_S), .p1(I_2209_S), .p2(I_2049_D));
    generic_pmos I_2017(.D(I_2209_S), .G(I_2529_S), .S(I_2049_D));
    generic_nmos I_2016(.D(I_2209_S), .G(I_2305_S), .S(I_2049_D));
  generic_cmos pass_93(.gn(I_2529_S), .gp(I_2305_S), .p1(I_2049_D), .p2(I_2113_D));
    generic_pmos I_2049(.D(I_2049_D), .G(I_2305_S), .S(I_2113_D));
    generic_nmos I_2048(.D(I_2049_D), .G(I_2529_S), .S(I_2113_D));
  not auto_496(I_1985_S, I_2049_D);
    generic_pmos I_1985(.D(VDD), .G(I_2049_D), .S(I_1985_S));
    generic_nmos I_1984(.D(VSS), .G(I_2049_D), .S(I_1985_S));
  nand auto_475(I_2209_S, I_1985_S, I_3393_G);
    generic_pmos I_1921(.D(VDD), .G(I_3393_G), .S(I_2209_S));
    generic_pmos I_1953(.D(I_2209_S), .G(I_1985_S), .S(VDD));
    generic_nmos I_1920(.D(I_2209_S), .G(I_3393_G), .S(I_1952_D));
    generic_nmos I_1952(.D(I_1952_D), .G(I_1985_S), .S(VSS));

// ********************************************************************************************************

// Memory address calculation for video Address Phase 1 (See Page 11)
// ... in which we turn horizontal and vertical counters into 16 bit memory addresses
//
// Need to see ULA V2 documentation for full explanation and justification ...
//
// 6 bits of VADDR1 address are either fixed, or taken from horizontal counter, 
// leading to only 10 bits of actual work to do.
//
// VADDR1-L goes to DRAM multiplexer gates "H"
// Horizontal counter HC0..2 provides lowest address bits (A0..A2)
// Lower 5 bits of adder "result" go to (A3..A7)

// VADDR1-H goes to DRAM multiplexer gates "P"
// One input is always high (A15)
// Next bits are always [0,1] but is fed by end of counter chain (seems redundant?) (A13,A14)
//
// In text mode: Always [1,1] (8 bit result only 01110000 to 11110111) (A12/A11)
//      Note: Half Adder HA12/HA13 adds an offset so vertical counter (partial) running from 0-135 
//      starts at 01110000, running (112-247/#70-#F7)
//
// In hires mode, Top 2 bits of 10 bit "result" 000000000 to 1111100111. (A12/A11)
//
// 3 bits of 8/10 bit answer (A8..A10)

// Override hires-text mode to text, if scanline 200+
// Missed in verilog - manually reconstructed
  nand manual_2(I_3499_D, I_873_D, I_2219_S);
    generic_pmos I_2251(.D(VDD), .G(I_873_D), .S(I_3499_D));
    generic_pmos I_2283(.D(I_3499_D), .G(I_2219_S), .S(VDD));
    generic_nmos I_2250(.D(I_3499_D), .G(I_873_D), .S(I_2282_D));
    generic_nmos I_2282(.D(I_2282_D), .G(I_2219_S), .S(VSS));

// These gates take the hires-text flag and buffer them
  not auto_560(I_2317_S, I_3499_D);
    generic_pmos I_2317(.D(VDD), .G(I_3499_D), .S(I_2317_S));
    generic_nmos I_2316(.D(VSS), .G(I_3499_D), .S(I_2317_S));
  not auto_483(I_1997_D, I_2317_S); // NMOS strength = 3
    generic_pmos I_1933(.D(I_1997_D), .G(I_2317_S), .S(VDD));
    generic_pmos I_1965(.D(VDD), .G(I_2317_S), .S(I_1997_D));
    generic_pmos I_1997(.D(I_1997_D), .G(I_2317_S), .S(VDD));
    generic_nmos I_1932(.D(I_1997_D), .G(I_2317_S), .S(VSS));
    generic_nmos I_1964(.D(VSS), .G(I_2317_S), .S(I_1997_D));
    generic_nmos I_1996(.D(I_1997_D), .G(I_2317_S), .S(VSS));
  not auto_533(I_2253_D, I_2317_S); // NMOS strength = 3
    generic_pmos I_2189(.D(VDD), .G(I_2317_S), .S(I_2253_D));
    generic_pmos I_2221(.D(I_2253_D), .G(I_2317_S), .S(VDD));
    generic_pmos I_2253(.D(I_2253_D), .G(I_2317_S), .S(VDD));
    generic_nmos I_2188(.D(VSS), .G(I_2317_S), .S(I_2253_D));
    generic_nmos I_2220(.D(I_2253_D), .G(I_2317_S), .S(VSS));
    generic_nmos I_2252(.D(I_2253_D), .G(I_2317_S), .S(VSS));

// Series of 2:1 Muxes for text mode: To divide VC by 8

// VC0 vs VC3
  nand auto_306(I_1103_D, I_975_D, I_3911_G);
    generic_pmos I_1071(.D(VDD), .G(I_3911_G), .S(I_1103_D));
    generic_pmos I_1103(.D(I_1103_D), .G(I_975_D), .S(VDD));
    generic_nmos I_1102(.D(I_1102_D), .G(I_3911_G), .S(I_1103_D));
    generic_nmos I_1070(.D(VSS), .G(I_975_D), .S(I_1102_D));
  nand auto_292(I_1039_D, I_1741_S, I_1997_D);
    generic_pmos I_1007(.D(VDD), .G(I_1997_D), .S(I_1039_D));
    generic_pmos I_1039(.D(I_1039_D), .G(I_1741_S), .S(VDD));
    generic_nmos I_1038(.D(I_1038_D), .G(I_1741_S), .S(I_1039_D));
    generic_nmos I_1006(.D(VSS), .G(I_1997_D), .S(I_1038_D));
  not auto_988(I_975_D, I_1997_D);
    generic_pmos I_975(.D(I_975_D), .G(I_1997_D), .S(VDD));
    generic_nmos I_974(.D(I_975_D), .G(I_1997_D), .S(VSS));
  nand auto_317(I_2071_S, I_1103_D, I_1039_D);
    generic_pmos I_1135(.D(VDD), .G(I_1039_D), .S(I_2071_S));
    generic_pmos I_1167(.D(I_2071_S), .G(I_1103_D), .S(VDD));
    generic_nmos I_1166(.D(I_1166_D), .G(I_1103_D), .S(I_2071_S));
    generic_nmos I_1134(.D(VSS), .G(I_1039_D), .S(I_1166_D));

// VC1 vs VC4
  nand auto_360(I_1359_D, I_3111_S, I_1997_D);
    generic_pmos I_1327(.D(VDD), .G(I_1997_D), .S(I_1359_D));
    generic_pmos I_1359(.D(I_1359_D), .G(I_3111_S), .S(VDD));
    generic_nmos I_1358(.D(I_1358_D), .G(I_3111_S), .S(I_1359_D));
    generic_nmos I_1326(.D(VSS), .G(I_1997_D), .S(I_1358_D));
  nand auto_370(I_1423_D, I_1295_D, I_2631_S);
    generic_pmos I_1391(.D(VDD), .G(I_2631_S), .S(I_1423_D));
    generic_pmos I_1423(.D(I_1423_D), .G(I_1295_D), .S(VDD));
    generic_nmos I_1422(.D(I_1422_D), .G(I_2631_S), .S(I_1423_D));
    generic_nmos I_1390(.D(VSS), .G(I_1295_D), .S(I_1422_D));
  not auto_347(I_1295_D, I_1997_D);
    generic_pmos I_1295(.D(I_1295_D), .G(I_1997_D), .S(VDD));
    generic_nmos I_1294(.D(I_1295_D), .G(I_1997_D), .S(VSS));
  nand auto_379(I_1518_D, I_1359_D, I_1423_D);
    generic_pmos I_1455(.D(VDD), .G(I_1359_D), .S(I_1518_D));
    generic_pmos I_1487(.D(I_1518_D), .G(I_1423_D), .S(VDD));
    generic_nmos I_1486(.D(I_1486_D), .G(I_1423_D), .S(I_1518_D));
    generic_nmos I_1454(.D(VSS), .G(I_1359_D), .S(I_1486_D));

// VC0 vs VC5
  nand auto_513(I_2127_D, I_3271_S, I_1997_D);
    generic_pmos I_2095(.D(VDD), .G(I_3271_S), .S(I_2127_D));
    generic_pmos I_2127(.D(I_2127_D), .G(I_1997_D), .S(VDD));
    generic_nmos I_2094(.D(I_2127_D), .G(I_3271_S), .S(I_2126_D));
    generic_nmos I_2126(.D(I_2126_D), .G(I_1997_D), .S(VSS));
  nand auto_502(I_2063_D, I_2159_S, I_2791_S);
    generic_pmos I_2031(.D(VDD), .G(I_2791_S), .S(I_2063_D));
    generic_pmos I_2063(.D(I_2063_D), .G(I_2159_S), .S(VDD));
    generic_nmos I_2030(.D(I_2063_D), .G(I_2159_S), .S(I_2062_D));
    generic_nmos I_2062(.D(I_2062_D), .G(I_2791_S), .S(VSS));
  not auto_527(I_2159_S, I_1997_D);
    generic_pmos I_2159(.D(VDD), .G(I_1997_D), .S(I_2159_S));
    generic_nmos I_2158(.D(VSS), .G(I_1997_D), .S(I_2159_S));
  // Also missed in verilog - manually reconstructed
  nand manual_3(I_1999_D, I_2127_D, I_2063_D);
    generic_pmos I_1999(.D(I_1999_D), .G(I_2127_D), .S(VDD));
    generic_pmos I_1967(.D(VDD), .G(I_2063_D), .S(I_1999_D));
    generic_nmos I_1998(.D(I_1998_D), .G(I_2127_D), .S(I_1999_D));
    generic_nmos I_1966(.D(VSS), .G(I_2063_D), .S(I_1998_D));

// VC3 vs VC6
  nand auto_445(I_1807_D, I_3431_S, I_2253_D);
    generic_pmos I_1775(.D(VDD), .G(I_3431_S), .S(I_1807_D));
    generic_pmos I_1807(.D(I_1807_D), .G(I_2253_D), .S(VDD));
    generic_nmos I_1774(.D(I_1807_D), .G(I_3431_S), .S(I_1806_D));
    generic_nmos I_1806(.D(I_1806_D), .G(I_2253_D), .S(VSS));
  nand auto_429(I_1743_D, I_1839_S, I_1741_S);
    generic_pmos I_1711(.D(VDD), .G(I_1741_S), .S(I_1743_D));
    generic_pmos I_1743(.D(I_1743_D), .G(I_1839_S), .S(VDD));
    generic_nmos I_1710(.D(I_1743_D), .G(I_1839_S), .S(I_1742_D));
    generic_nmos I_1742(.D(I_1742_D), .G(I_1741_S), .S(VSS));
  not auto_460(I_1839_S, I_2253_D);
    generic_pmos I_1839(.D(VDD), .G(I_2253_D), .S(I_1839_S));
    generic_nmos I_1838(.D(VSS), .G(I_2253_D), .S(I_1839_S));
  nand auto_419(I_1679_D, I_1807_D, I_1743_D);
    generic_pmos I_1647(.D(VDD), .G(I_1743_D), .S(I_1679_D));
    generic_pmos I_1679(.D(I_1679_D), .G(I_1807_D), .S(VDD));
    generic_nmos I_1678(.D(I_1678_D), .G(I_1807_D), .S(I_1679_D));
    generic_nmos I_1646(.D(VSS), .G(I_1743_D), .S(I_1678_D));

// VC4 vs VC7/HA12 sum stuffing
  nand auto_574(I_2447_D, I_3337_D, I_2253_D);
    generic_pmos I_2415(.D(VDD), .G(I_3337_D), .S(I_2447_D));
    generic_pmos I_2447(.D(I_2447_D), .G(I_2253_D), .S(VDD));
    generic_nmos I_2414(.D(I_2447_D), .G(I_3337_D), .S(I_2446_D));
    generic_nmos I_2446(.D(I_2446_D), .G(I_2253_D), .S(VSS));
  nand auto_564(I_2383_D, I_3111_S, I_2479_S);
    generic_pmos I_2351(.D(VDD), .G(I_3111_S), .S(I_2383_D));
    generic_pmos I_2383(.D(I_2383_D), .G(I_2479_S), .S(VDD));
    generic_nmos I_2350(.D(I_2383_D), .G(I_2479_S), .S(I_2382_D));
    generic_nmos I_2382(.D(I_2382_D), .G(I_3111_S), .S(VSS));
  not auto_588(I_2479_S, I_2253_D);
    generic_pmos I_2479(.D(VDD), .G(I_2253_D), .S(I_2479_S));
    generic_nmos I_2478(.D(VSS), .G(I_2253_D), .S(I_2479_S));
  nand auto_552(I_2319_D, I_2383_D, I_2447_D);
    generic_pmos I_2287(.D(VDD), .G(I_2383_D), .S(I_2319_D));
    generic_pmos I_2319(.D(I_2319_D), .G(I_2447_D), .S(VDD));
    generic_nmos I_2318(.D(I_2318_D), .G(I_2447_D), .S(I_2319_D));
    generic_nmos I_2286(.D(VSS), .G(I_2383_D), .S(I_2318_D));

// VC5 vs VC7/HA13 Sum stuffing
  nand auto_664(I_2957_D, I_3339_D, I_2253_D);
    generic_pmos I_2925(.D(VDD), .G(I_2253_D), .S(I_2957_D));
    generic_pmos I_2957(.D(I_2957_D), .G(I_3339_D), .S(VDD));
    generic_nmos I_2956(.D(I_2956_D), .G(I_3339_D), .S(I_2957_D));
    generic_nmos I_2924(.D(VSS), .G(I_2253_D), .S(I_2956_D));
  nand auto_673(I_3021_D, I_3271_S, I_2893_D);
    generic_pmos I_2989(.D(VDD), .G(I_3271_S), .S(I_3021_D));
    generic_pmos I_3021(.D(I_3021_D), .G(I_2893_D), .S(VDD));
    generic_nmos I_3020(.D(I_3020_D), .G(I_3271_S), .S(I_3021_D));
    generic_nmos I_2988(.D(VSS), .G(I_2893_D), .S(I_3020_D));
  not auto_655(I_2893_D, I_2253_D);
    generic_pmos I_2893(.D(I_2893_D), .G(I_2253_D), .S(VDD));
    generic_nmos I_2892(.D(I_2893_D), .G(I_2253_D), .S(VSS));
  nand auto_686(I_3116_D, I_2957_D, I_3021_D);
    generic_pmos I_3053(.D(VDD), .G(I_2957_D), .S(I_3116_D));
    generic_pmos I_3085(.D(I_3116_D), .G(I_3021_D), .S(VDD));
    generic_nmos I_3084(.D(I_3084_D), .G(I_3021_D), .S(I_3116_D));
    generic_nmos I_3052(.D(VSS), .G(I_2957_D), .S(I_3084_D));

// VC6 vs VC7/HA13 Carry stuffing
  nand auto_794(I_3565_D, I_2253_D, I_3499_S);
    generic_pmos I_3533(.D(VDD), .G(I_3499_S), .S(I_3565_D));
    generic_pmos I_3565(.D(I_3565_D), .G(I_2253_D), .S(VDD));
    generic_nmos I_3532(.D(I_3565_D), .G(I_3499_S), .S(I_3564_D));
    generic_nmos I_3564(.D(I_3564_D), .G(I_2253_D), .S(VSS));
  nand auto_775(I_3501_D, I_3431_S, I_3597_S);
    generic_pmos I_3469(.D(VDD), .G(I_3431_S), .S(I_3501_D));
    generic_pmos I_3501(.D(I_3501_D), .G(I_3597_S), .S(VDD));
    generic_nmos I_3468(.D(I_3501_D), .G(I_3597_S), .S(I_3500_D));
    generic_nmos I_3500(.D(I_3500_D), .G(I_3431_S), .S(VSS));
  not auto_808(I_3597_S, I_2253_D);
    generic_pmos I_3597(.D(VDD), .G(I_2253_D), .S(I_3597_S));
    generic_nmos I_3596(.D(VSS), .G(I_2253_D), .S(I_3597_S));
  nand auto_763(I_3663_S, I_3501_D, I_3565_D);
    generic_pmos I_3405(.D(VDD), .G(I_3501_D), .S(I_3663_S));
    generic_pmos I_3437(.D(I_3663_S), .G(I_3565_D), .S(VDD));
    generic_nmos I_3436(.D(I_3436_D), .G(I_3565_D), .S(I_3663_S));
    generic_nmos I_3404(.D(VSS), .G(I_3501_D), .S(I_3436_D));

// In text mode -- stuffs a "1" as last bit of counter
// Also see below adders
// In hires mode -- is the last bit of counter (VC7)
  nor auto_570(I_3019_G, I_3499_D, I_3337_D);
    generic_pmos I_2347(.D(VDD), .G(I_3337_D), .S(I_2379_D));
    generic_pmos I_2379(.D(I_2379_D), .G(I_3499_D), .S(I_3019_G));
    generic_nmos I_2346(.D(VSS), .G(I_3499_D), .S(I_3019_G));
    generic_nmos I_2378(.D(I_3019_G), .G(I_3337_D), .S(VSS));
  not auto_679(I_3019_S, I_3019_G);
    generic_pmos I_3019(.D(VDD), .G(I_3019_G), .S(I_3019_S));
    generic_nmos I_2986(.D(I_3019_S), .G(I_3019_G), .S(VSS));

// Used with above logic gates to handle extra base address offset in text mode 
// Total offset of 112 (#70) needed here.

// HalfAdder 12 Inputs: I_3499_D, I_3591_S (VC7) Sum: I_3337_D (Logic) Carry:I_3497_S
// 2:1 Mux with single control: Inputs: I_3433_S, I_3499_D Output: I_3337_D Control: I_3591_S
  generic_cmos pass_193(.gn(I_3591_S), .gp(I_3369_D), .p1(I_3433_S), .p2(I_3337_D));
    generic_pmos I_3305(.D(I_3433_S), .G(I_3369_D), .S(I_3337_D));
    generic_nmos I_3304(.D(I_3433_S), .G(I_3591_S), .S(I_3337_D));
  generic_cmos pass_200(.gn(I_3369_D), .gp(I_3591_S), .p1(I_3337_D), .p2(I_3499_D));
    generic_pmos I_3337(.D(I_3337_D), .G(I_3591_S), .S(I_3499_D));
    generic_nmos I_3336(.D(I_3337_D), .G(I_3369_D), .S(I_3499_D));
// Driver
  not auto_752(I_3369_D, I_3591_S);
    generic_pmos I_3369(.D(I_3369_D), .G(I_3591_S), .S(VDD));
    generic_nmos I_3368(.D(I_3369_D), .G(I_3591_S), .S(VSS));
// Transmission Gate (CMOS Pass) Input: I_3591_S Output: I_3497_S Control: I_3499_D
  generic_cmos pass_212(.gn(I_3499_D), .gp(I_3433_S), .p1(I_3591_S), .p2(I_3497_S));
    generic_pmos I_3497(.D(I_3591_S), .G(I_3433_S), .S(I_3497_S));
    generic_nmos I_3464(.D(I_3591_S), .G(I_3499_D), .S(I_3497_S));
// Driver
  not auto_769(I_3433_S, I_3499_D);
    generic_pmos I_3433(.D(VDD), .G(I_3499_D), .S(I_3433_S));
    generic_nmos I_3432(.D(VSS), .G(I_3499_D), .S(I_3433_S));
// Connects with CMOS pass 193/201/212/213
    generic_nmos I_3496(.D(I_3497_S), .G(I_3433_S), .S(VSS));

// HalfAdder 13 Inputs: I_3497_S, I_3499_D Sum: I_3339_D (Logic) Carry: I_3499_S
// 2:1 Mux with single control: Inputs: I_3435_S, I_3497_S Output: I_3339_D Control: I_3499_D
  generic_cmos pass_194(.gn(I_3499_D), .gp(I_3371_D), .p1(I_3435_S), .p2(I_3339_D));
    generic_pmos I_3307(.D(I_3435_S), .G(I_3371_D), .S(I_3339_D));
    generic_nmos I_3306(.D(I_3435_S), .G(I_3499_D), .S(I_3339_D));
  generic_cmos pass_201(.gn(I_3371_D), .gp(I_3499_D), .p1(I_3339_D), .p2(I_3497_S));
    generic_pmos I_3339(.D(I_3339_D), .G(I_3499_D), .S(I_3497_S));
    generic_nmos I_3338(.D(I_3339_D), .G(I_3371_D), .S(I_3497_S));
// Driver
  not auto_753(I_3371_D, I_3499_D);
    generic_pmos I_3371(.D(I_3371_D), .G(I_3499_D), .S(VDD));
    generic_nmos I_3370(.D(I_3371_D), .G(I_3499_D), .S(VSS));
// Transmission Gate (CMOS Pass) Input: I_3499_D Output: I_3499_S Control: I_3497_S
  generic_cmos pass_213(.gn(I_3497_S), .gp(I_3435_S), .p1(I_3499_D), .p2(I_3499_S));
    generic_pmos I_3499(.D(I_3499_D), .G(I_3435_S), .S(I_3499_S));
    generic_nmos I_3466(.D(I_3499_D), .G(I_3497_S), .S(I_3499_S));
// Driver
  not auto_770(I_3435_S, I_3497_S);
    generic_pmos I_3435(.D(VDD), .G(I_3497_S), .S(I_3435_S));
    generic_nmos I_3434(.D(VSS), .G(I_3497_S), .S(I_3435_S));
// Connects with CMOS pass 194/213
    generic_nmos I_3498(.D(I_3499_S), .G(I_3435_S), .S(VSS));

// ********************************************************************************************************

// Second part of adders for VADDR1

// Now that VC has been manipulated, this section adds VC to VC*4, to get VC*5
// Then multiplies by 8 (both multiplies by mis-wired bit-shifting)
// And adds HC bits [3..5] to get final 10 bit answer (plus 3 fixed bits at top).
// Three bottom bits of 16 bit address just passed straight by all this from HC0..2
// to the multiplexer.

// NOTE: Two half adders have carry out to next input via a double inverter. Delay?

// In address line bit order, top down ...

// A3

// HalfAdder 01 Inputs: I_2071_S, I_1991_S (HC3) Sum: I_2071_D (Gates H-A3) Carry: I_2389_S
// 2:1 Mux with single control: Inputs: I_2167_S, I_2071_S Output: I_2071_D Control: I_1991_S
  generic_cmos pass_91(.gn(I_1991_S), .gp(I_2103_D), .p1(I_2167_S), .p2(I_2071_D));
    generic_pmos I_2039(.D(I_2167_S), .G(I_2103_D), .S(I_2071_D));
    generic_nmos I_2038(.D(I_2167_S), .G(I_1991_S), .S(I_2071_D));
  generic_cmos pass_97(.gn(I_2103_D), .gp(I_1991_S), .p1(I_2071_D), .p2(I_2071_S));
    generic_pmos I_2071(.D(I_2071_D), .G(I_1991_S), .S(I_2071_S));
    generic_nmos I_2070(.D(I_2071_D), .G(I_2103_D), .S(I_2071_S));
// Driver
  not auto_515(I_2103_D, I_1991_S);
    generic_pmos I_2103(.D(I_2103_D), .G(I_1991_S), .S(VDD));
    generic_nmos I_2102(.D(I_2103_D), .G(I_1991_S), .S(VSS));
// Transmission Gate (CMOS Pass) Input: I_1991_S Output: I_2231_S Control: I_2071_S
  generic_cmos pass_106(.gn(I_2071_S), .gp(I_2167_S), .p1(I_1991_S), .p2(I_2231_S));
    generic_pmos I_2231(.D(I_1991_S), .G(I_2167_S), .S(I_2231_S));
    generic_nmos I_2198(.D(I_1991_S), .G(I_2071_S), .S(I_2231_S));
// Driver
  not auto_529(I_2167_S, I_2071_S);
    generic_pmos I_2167(.D(VDD), .G(I_2071_S), .S(I_2167_S));
    generic_nmos I_2166(.D(VSS), .G(I_2071_S), .S(I_2167_S));
// Connects with CMOS pass 91/106
    generic_nmos I_2230(.D(I_2231_S), .G(I_2167_S), .S(VSS));
// ~Carry
  not auto_546(I_2263_D, I_2231_S);
    generic_pmos I_2263(.D(I_2263_D), .G(I_2231_S), .S(VDD));
    generic_nmos I_2262(.D(I_2263_D), .G(I_2231_S), .S(VSS));
// Carry
  not auto_563(I_2389_S, I_2263_D);
    generic_pmos I_2327(.D(VDD), .G(I_2263_D), .S(I_2389_S));
    generic_nmos I_2326(.D(VSS), .G(I_2263_D), .S(I_2389_S));

// A4

// FullAdder 03 Inputs: I_2549_S (PartialSum), I_2389_S Sum: I_2549_D (Gates H-A5) Carry: 2711_S
// FullAdder 03 Extra Inputs: I_2151_S, I_1518_D
// Inverted input
  not auto_582(I_2453_D, I_2389_S);
    generic_pmos I_2453(.D(I_2453_D), .G(I_2389_S), .S(VDD));
    generic_nmos I_2452(.D(I_2453_D), .G(I_2389_S), .S(VSS));
// 2:1 Mux with single control: Inputs: I_2517_D, I_2549_S Output: I_2549_D Control: I_2453_D
  generic_cmos pass_120(.gn(I_2453_D), .gp(I_2485_S), .p1(I_2517_D), .p2(I_2549_D));
    generic_pmos I_2517(.D(I_2517_D), .G(I_2485_S), .S(I_2549_D));
    generic_nmos I_2516(.D(I_2517_D), .G(I_2453_D), .S(I_2549_D));
  generic_cmos pass_126(.gn(I_2485_S), .gp(I_2453_D), .p1(I_2549_D), .p2(I_2549_S));
    generic_pmos I_2549(.D(I_2549_D), .G(I_2453_D), .S(I_2549_S));
    generic_nmos I_2548(.D(I_2549_D), .G(I_2485_S), .S(I_2549_S));
// Driver
  not auto_590(I_2485_S, I_2453_D);
    generic_pmos I_2485(.D(VDD), .G(I_2453_D), .S(I_2485_S));
    generic_nmos I_2484(.D(VSS), .G(I_2453_D), .S(I_2485_S));
// Transmission Gate (CMOS Pass) Input: I_2711_S Output: I_2389_S Control: I_2549_S
  generic_cmos pass_115(.gn(I_2517_D), .gp(I_2549_S), .p1(I_2711_S), .p2(I_2389_S));
    generic_pmos I_2389(.D(I_2711_S), .G(I_2549_S), .S(I_2389_S));
    generic_nmos I_2356(.D(I_2711_S), .G(I_2517_D), .S(I_2389_S));
// Driver
  not auto_562(I_2517_D, I_2549_S);
    generic_pmos I_2325(.D(VDD), .G(I_2549_S), .S(I_2517_D));
    generic_nmos I_2324(.D(VSS), .G(I_2549_S), .S(I_2517_D));
// Part of Adder 03
  nand auto_503(I_2069_D, I_2151_S, I_1518_D);
    generic_pmos I_2037(.D(VDD), .G(I_2151_S), .S(I_2069_D));
    generic_pmos I_2069(.D(I_2069_D), .G(I_1518_D), .S(VDD));
    generic_nmos I_2036(.D(I_2069_D), .G(I_1518_D), .S(I_2068_D));
    generic_nmos I_2068(.D(I_2068_D), .G(I_2151_S), .S(VSS));
  nor auto_514(I_2132_D, I_1518_D, I_2151_S);
    generic_pmos I_2133(.D(I_2133_D), .G(I_2151_S), .S(VDD));
    generic_pmos I_2101(.D(I_2132_D), .G(I_1518_D), .S(I_2133_D));
    generic_nmos I_2100(.D(VSS), .G(I_1518_D), .S(I_2132_D));
    generic_nmos I_2132(.D(I_2132_D), .G(I_2151_S), .S(VSS));
  not auto_528(I_2165_S, I_2132_D);
    generic_pmos I_2165(.D(VDD), .G(I_2132_D), .S(I_2165_S));
    generic_nmos I_2164(.D(VSS), .G(I_2132_D), .S(I_2165_S));
  nand auto_545(I_2549_S, I_2165_S, I_2069_D);
    generic_pmos I_2261(.D(VDD), .G(I_2165_S), .S(I_2549_S));
    generic_pmos I_2293(.D(I_2549_S), .G(I_2069_D), .S(VDD));
    generic_nmos I_2260(.D(I_2549_S), .G(I_2165_S), .S(I_2292_D));
    generic_nmos I_2292(.D(I_2292_D), .G(I_2069_D), .S(VSS));
// Modifier transistor pair
// Forces Carry (I_2711_S): I_2069_D = 0 (force high) I_2132_ = 1 (force low)
    generic_pmos I_2229(.D(I_2711_S), .G(I_2069_D), .S(VDD));
    generic_nmos I_2196(.D(VSS), .G(I_2132_D), .S(I_2711_S));

// A5

// HalfAdder 11 Inputs: I_2071_S, I_1999_D (Logic) Sum: I_1265_D (Logic) Carry: I_1425_S
// 2:1 Mux with single control: Inputs: I_1361_S, I_2071_S Output: I_1265_D Control: I_1999_D
  generic_cmos pass_18(.gn(I_1999_D), .gp(I_1297_D), .p1(I_1361_S), .p2(I_1265_D));
    generic_pmos I_1233(.D(I_1361_S), .G(I_1297_D), .S(I_1265_D));
    generic_nmos I_1232(.D(I_1361_S), .G(I_1999_D), .S(I_1265_D));
  generic_cmos pass_28(.gn(I_1297_D), .gp(I_1999_D), .p1(I_1265_D), .p2(I_2071_S));
    generic_pmos I_1265(.D(I_1265_D), .G(I_1999_D), .S(I_2071_S));
    generic_nmos I_1264(.D(I_1265_D), .G(I_1297_D), .S(I_2071_S));
// Driver
  not auto_348(I_1297_D, I_1999_D);
    generic_pmos I_1297(.D(I_1297_D), .G(I_1999_D), .S(VDD));
    generic_nmos I_1296(.D(I_1297_D), .G(I_1999_D), .S(VSS));
// Transmission Gate (CMOS Pass) Input: I_1999_D Output: I_1425_S Control: I_2071_S
  generic_cmos pass_48(.gn(I_2071_S), .gp(I_1361_S), .p1(I_1999_D), .p2(I_1425_S));
    generic_pmos I_1425(.D(I_1999_D), .G(I_1361_S), .S(I_1425_S));
    generic_nmos I_1392(.D(I_1999_D), .G(I_2071_S), .S(I_1425_S));
// Driver
  not auto_363(I_1361_S, I_2071_S);
    generic_pmos I_1361(.D(VDD), .G(I_2071_S), .S(I_1361_S));
    generic_nmos I_1360(.D(VSS), .G(I_2071_S), .S(I_1361_S));
// Connects with CMOS pass 18/48
    generic_nmos I_1424(.D(I_1425_S), .G(I_1361_S), .S(VSS));

// Chained carry nots
  not auto_462(I_1843_S, I_1425_S);
    generic_pmos I_1843(.D(VDD), .G(I_1425_S), .S(I_1843_S));
    generic_nmos I_1842(.D(VSS), .G(I_1425_S), .S(I_1843_S));
  not auto_468(I_1906_S, I_1843_S);
    generic_pmos I_1875(.D(I_1906_S), .G(I_1843_S), .S(VDD));
    generic_nmos I_1906(.D(VSS), .G(I_1843_S), .S(I_1906_S));

// FullAdder 02 Inputs: I_2871_S (PartialSum), I_2711_S Sum: I_2871_D (Gates H-A4) Carry: 2869_D
// FullAdder 02 Extra Inputs: I_2311_S, I_1265_D
// Inverted input
  not auto_636(I_2775_D, I_2711_S);
    generic_pmos I_2775(.D(I_2775_D), .G(I_2711_S), .S(VDD));
    generic_nmos I_2774(.D(I_2775_D), .G(I_2711_S), .S(VSS));
// 2:1 Mux with single control: Inputs: I_2839_D, I_2871_S Output: I_2871_D Control: I_2775_D
  generic_cmos pass_150(.gn(I_2775_D), .gp(I_2807_S), .p1(I_2839_D), .p2(I_2871_D));
    generic_pmos I_2839(.D(I_2839_D), .G(I_2807_S), .S(I_2871_D));
    generic_nmos I_2838(.D(I_2839_D), .G(I_2775_D), .S(I_2871_D));
  generic_cmos pass_158(.gn(I_2807_S), .gp(I_2775_D), .p1(I_2871_D), .p2(I_2871_S));
    generic_pmos I_2871(.D(I_2871_D), .G(I_2775_D), .S(I_2871_S));
    generic_nmos I_2870(.D(I_2871_D), .G(I_2807_S), .S(I_2871_S));
// Driver
  not auto_644(I_2807_S, I_2775_D);
    generic_pmos I_2807(.D(VDD), .G(I_2775_D), .S(I_2807_S));
    generic_nmos I_2806(.D(VSS), .G(I_2775_D), .S(I_2807_S));
// Transmission Gate (CMOS Pass) Input: I_2869_D Output: I_2711_S Control: I_2871_S
  generic_cmos pass_143(.gn(I_2839_D), .gp(I_2871_S), .p1(I_2869_D), .p2(I_2711_S));
    generic_pmos I_2711(.D(I_2869_D), .G(I_2871_S), .S(I_2711_S));
    generic_nmos I_2678(.D(I_2869_D), .G(I_2839_D), .S(I_2711_S));
// Driver
  not auto_617(I_2839_D, I_2871_S);
    generic_pmos I_2647(.D(VDD), .G(I_2871_S), .S(I_2839_D));
    generic_nmos I_2646(.D(VSS), .G(I_2871_S), .S(I_2839_D));
// Part of Adder 02
  nand auto_565(I_2391_D, I_1265_D, I_2311_S);
    generic_pmos I_2359(.D(VDD), .G(I_2311_S), .S(I_2391_D));
    generic_pmos I_2391(.D(I_2391_D), .G(I_1265_D), .S(VDD));
    generic_nmos I_2358(.D(I_2391_D), .G(I_1265_D), .S(I_2390_D));
    generic_nmos I_2390(.D(I_2390_D), .G(I_2311_S), .S(VSS));
  nor auto_576(I_2454_D, I_2311_S, I_1265_D);
    generic_pmos I_2455(.D(I_2455_D), .G(I_2311_S), .S(VDD));
    generic_pmos I_2423(.D(I_2454_D), .G(I_1265_D), .S(I_2455_D));
    generic_nmos I_2422(.D(VSS), .G(I_1265_D), .S(I_2454_D));
    generic_nmos I_2454(.D(I_2454_D), .G(I_2311_S), .S(VSS));
  not auto_591(I_2487_S, I_2454_D);
    generic_pmos I_2487(.D(VDD), .G(I_2454_D), .S(I_2487_S));
    generic_nmos I_2486(.D(VSS), .G(I_2454_D), .S(I_2487_S));
  nand auto_605(I_2871_S, I_2487_S, I_2391_D);
    generic_pmos I_2583(.D(VDD), .G(I_2487_S), .S(I_2871_S));
    generic_pmos I_2615(.D(I_2871_S), .G(I_2391_D), .S(VDD));
    generic_nmos I_2582(.D(I_2871_S), .G(I_2487_S), .S(I_2614_D));
    generic_nmos I_2614(.D(I_2614_D), .G(I_2391_D), .S(VSS));
// Modifier transistor pair
// Forces Carry (I_2869_D): I_2391_D = 0 (force high) I_2454_D = 1 (force low)
    generic_pmos I_2551(.D(I_2869_D), .G(I_2391_D), .S(VDD));
    generic_nmos I_2518(.D(VSS), .G(I_2454_D), .S(I_2869_D));

// A6

// FullAdder 17 Inputs: I_2065_S (PartialSum), I_1906_S (logic) Sum: I_2709_S Carry: I_2545_S
// FullAdder 17 Extra Inputs: I_1679_D, 1518_D
// Inverted input
  not auto_492(I_1969_D, I_1906_S);
    generic_pmos I_1969(.D(I_1969_D), .G(I_1906_S), .S(VDD));
    generic_nmos I_1968(.D(I_1969_D), .G(I_1906_S), .S(VSS));
// 2:1 Mux with single control: Inputs: I_2033_D, I_2065_S Output: I_2709_S Control: I_1969_D
  generic_cmos pass_90(.gn(I_1969_D), .gp(I_2001_S), .p1(I_2033_D), .p2(I_2709_S));
    generic_pmos I_2033(.D(I_2033_D), .G(I_2001_S), .S(I_2709_S));
    generic_nmos I_2032(.D(I_2033_D), .G(I_1969_D), .S(I_2709_S));
  generic_cmos pass_96(.gn(I_2001_S), .gp(I_1969_D), .p1(I_2709_S), .p2(I_2065_S));
    generic_pmos I_2065(.D(I_2709_S), .G(I_1969_D), .S(I_2065_S));
    generic_nmos I_2064(.D(I_2709_S), .G(I_2001_S), .S(I_2065_S));
// Driver
  not auto_499(I_2001_S, I_1969_D);
    generic_pmos I_2001(.D(VDD), .G(I_1969_D), .S(I_2001_S));
    generic_nmos I_2000(.D(VSS), .G(I_1969_D), .S(I_2001_S));
// Transmission Gate (CMOS Pass) Input: I_2545_S Output: I_1906_S Control: I_2065_S
  generic_cmos pass_84(.gn(I_2033_D), .gp(I_2065_S), .p1(I_2545_S), .p2(I_1906_S));
    generic_pmos I_1905(.D(I_2545_S), .G(I_2065_S), .S(I_1906_S));
    generic_nmos I_1872(.D(I_2545_S), .G(I_2033_D), .S(I_1906_S));
// Driver
  not auto_461(I_2033_D, I_2065_S);
    generic_pmos I_1841(.D(VDD), .G(I_2065_S), .S(I_2033_D));
    generic_nmos I_1840(.D(VSS), .G(I_2065_S), .S(I_2033_D));
// Part of Adder 17
  nand auto_399(I_1585_D, I_1679_D, I_1518_D);
    generic_pmos I_1553(.D(VDD), .G(I_1679_D), .S(I_1585_D));
    generic_pmos I_1585(.D(I_1585_D), .G(I_1518_D), .S(VDD));
    generic_nmos I_1552(.D(I_1585_D), .G(I_1518_D), .S(I_1584_D));
    generic_nmos I_1584(.D(I_1584_D), .G(I_1679_D), .S(VSS));
  nor auto_410(I_1648_D, I_1518_D, I_1679_D);
    generic_pmos I_1649(.D(I_1649_D), .G(I_1679_D), .S(VDD));
    generic_pmos I_1617(.D(I_1648_D), .G(I_1518_D), .S(I_1649_D));
    generic_nmos I_1616(.D(VSS), .G(I_1518_D), .S(I_1648_D));
    generic_nmos I_1648(.D(I_1648_D), .G(I_1679_D), .S(VSS));
  not auto_425(I_1681_S, I_1648_D);
    generic_pmos I_1681(.D(VDD), .G(I_1648_D), .S(I_1681_S));
    generic_nmos I_1680(.D(VSS), .G(I_1648_D), .S(I_1681_S));
  nand auto_446(I_2065_S, I_1585_D, I_1681_S);
    generic_pmos I_1777(.D(VDD), .G(I_1681_S), .S(I_2065_S));
    generic_pmos I_1809(.D(I_2065_S), .G(I_1585_D), .S(VDD));
    generic_nmos I_1776(.D(I_2065_S), .G(I_1681_S), .S(I_1808_D));
    generic_nmos I_1808(.D(I_1808_D), .G(I_1585_D), .S(VSS));
// Modifier transistor pair
    generic_pmos I_1745(.D(I_2545_S), .G(I_1585_D), .S(VDD));
    generic_nmos I_1712(.D(VSS), .G(I_1648_D), .S(I_2545_S));

// HalfAdder 04 Inputs: I_2709_S, I_2869_D Sum: I_2709_D (Gates H-A6) Carry: I_3191_D
// 2:1 Mux with single control: Inputs: I_2805_S, I_2709_S Output: I_2709_D Control: I_2869_D
  generic_cmos pass_135(.gn(I_2869_D), .gp(I_2741_D), .p1(I_2805_S), .p2(I_2709_D));
    generic_pmos I_2677(.D(I_2805_S), .G(I_2741_D), .S(I_2709_D));
    generic_nmos I_2676(.D(I_2805_S), .G(I_2869_D), .S(I_2709_D));
  generic_cmos pass_142(.gn(I_2741_D), .gp(I_2869_D), .p1(I_2709_D), .p2(I_2709_S));
    generic_pmos I_2709(.D(I_2709_D), .G(I_2869_D), .S(I_2709_S));
    generic_nmos I_2708(.D(I_2709_D), .G(I_2741_D), .S(I_2709_S));
// Driver
  not auto_629(I_2741_D, I_2869_D);
    generic_pmos I_2741(.D(I_2741_D), .G(I_2869_D), .S(VDD));
    generic_nmos I_2740(.D(I_2741_D), .G(I_2869_D), .S(VSS));
// Transmission Gate (CMOS Pass) Input: I_2869_D Output: I_3191_D Control: I_2709_S
  generic_cmos pass_156(.gn(I_2709_S), .gp(I_2805_S), .p1(I_2869_D), .p2(I_3191_D));
    generic_pmos I_2869(.D(I_2869_D), .G(I_2805_S), .S(I_3191_D));
    generic_nmos I_2836(.D(I_2869_D), .G(I_2709_S), .S(I_3191_D));
// Driver
  not auto_643(I_2805_S, I_2709_S);
    generic_pmos I_2805(.D(VDD), .G(I_2709_S), .S(I_2805_S));
    generic_nmos I_2804(.D(VSS), .G(I_2709_S), .S(I_2805_S));
// Connects with CMOS pass 135/156/167/174/189
    generic_nmos I_2868(.D(I_3191_D), .G(I_2805_S), .S(VSS));

// A7

// FullAdder 18 Inputs: I_2705_S (PartialSum), I_2545_S (Logic) Sum: I_3031_S  Carry: I_3185_S
// FullAdder 18 Extra Inputs I_1999_D, I_2319_D
// Inverted input
  not auto_612(I_2609_D, I_2545_S);
    generic_pmos I_2609(.D(I_2609_D), .G(I_2545_S), .S(VDD));
    generic_nmos I_2608(.D(I_2609_D), .G(I_2545_S), .S(VSS));
// 2:1 Mux with single control: Inputs: I_2673_D, I_2705_S Output: I_3031_S Controls: I_2609_D
  generic_cmos pass_134(.gn(I_2609_D), .gp(I_2641_S), .p1(I_2673_D), .p2(I_3031_S));
    generic_pmos I_2673(.D(I_2673_D), .G(I_2641_S), .S(I_3031_S));
    generic_nmos I_2672(.D(I_2673_D), .G(I_2609_D), .S(I_3031_S));
  generic_cmos pass_141(.gn(I_2641_S), .gp(I_2609_D), .p1(I_3031_S), .p2(I_2705_S));
    generic_pmos I_2705(.D(I_3031_S), .G(I_2609_D), .S(I_2705_S));
    generic_nmos I_2704(.D(I_3031_S), .G(I_2641_S), .S(I_2705_S));
// Driver
  not auto_616(I_2641_S, I_2609_D);
    generic_pmos I_2641(.D(VDD), .G(I_2609_D), .S(I_2641_S));
    generic_nmos I_2640(.D(VSS), .G(I_2609_D), .S(I_2641_S));
// Transmission Gate (CMOS Pass) Input: I_3185_S Output: I_2545_S Control: I_2705_S
  generic_cmos pass_125(.gn(I_2673_D), .gp(I_2705_S), .p1(I_3185_S), .p2(I_2545_S));
    generic_pmos I_2545(.D(I_3185_S), .G(I_2705_S), .S(I_2545_S));
    generic_nmos I_2512(.D(I_3185_S), .G(I_2673_D), .S(I_2545_S));
// Driver
  not auto_589(I_2673_D, I_2705_S);
    generic_pmos I_2481(.D(VDD), .G(I_2705_S), .S(I_2673_D));
    generic_nmos I_2480(.D(VSS), .G(I_2705_S), .S(I_2673_D));
// Part of Adder 18
  nand auto_534(I_2225_D, I_1999_D, I_2319_D);
    generic_pmos I_2193(.D(VDD), .G(I_2319_D), .S(I_2225_D));
    generic_pmos I_2225(.D(I_2225_D), .G(I_1999_D), .S(VDD));
    generic_nmos I_2192(.D(I_2225_D), .G(I_1999_D), .S(I_2224_D));
    generic_nmos I_2224(.D(I_2224_D), .G(I_2319_D), .S(VSS));
  nor auto_544(I_2288_D, I_1999_D, I_2319_D);
    generic_pmos I_2289(.D(I_2289_D), .G(I_2319_D), .S(VDD));
    generic_pmos I_2257(.D(I_2288_D), .G(I_1999_D), .S(I_2289_D));
    generic_nmos I_2256(.D(VSS), .G(I_1999_D), .S(I_2288_D));
    generic_nmos I_2288(.D(I_2288_D), .G(I_2319_D), .S(VSS));
  not auto_561(I_2321_S, I_2288_D);
    generic_pmos I_2321(.D(VDD), .G(I_2288_D), .S(I_2321_S));
    generic_nmos I_2320(.D(VSS), .G(I_2288_D), .S(I_2321_S));
  nand auto_575(I_2705_S, I_2225_D, I_2321_S);
    generic_pmos I_2417(.D(VDD), .G(I_2321_S), .S(I_2705_S));
    generic_pmos I_2449(.D(I_2705_S), .G(I_2225_D), .S(VDD));
    generic_nmos I_2416(.D(I_2705_S), .G(I_2321_S), .S(I_2448_D));
    generic_nmos I_2448(.D(I_2448_D), .G(I_2225_D), .S(VSS));
// Modifier transistor pair
    generic_pmos I_2385(.D(I_3185_S), .G(I_2225_D), .S(VDD));
    generic_nmos I_2352(.D(VSS), .G(I_2288_D), .S(I_3185_S));

// HalfAdder 05 Inputs: I_3031_S, I_3191_D Sum: I_3031_D (Gates H-A7) Carry: I_3191_S
// 2:1 Mux with single control: Inputs: I_3127_S, I_3031_S Output: I_3031_D Control: I_3191_D
  generic_cmos pass_167(.gn(I_3191_D), .gp(I_3063_D), .p1(I_3127_S), .p2(I_3031_D));
    generic_pmos I_2999(.D(I_3127_S), .G(I_3063_D), .S(I_3031_D));
    generic_nmos I_2998(.D(I_3127_S), .G(I_3191_D), .S(I_3031_D));
  generic_cmos pass_174(.gn(I_3063_D), .gp(I_3191_D), .p1(I_3031_D), .p2(I_3031_S));
    generic_pmos I_3031(.D(I_3031_D), .G(I_3191_D), .S(I_3031_S));
    generic_nmos I_3030(.D(I_3031_D), .G(I_3063_D), .S(I_3031_S));
// Driver
  not auto_691(I_3063_D, I_3191_D);
    generic_pmos I_3063(.D(I_3063_D), .G(I_3191_D), .S(VDD));
    generic_nmos I_3062(.D(I_3063_D), .G(I_3191_D), .S(VSS));
// Transmission Gate (CMOS Pass) Input: I_3191_D Output: I_3191_S Control: I_3031_S
  generic_cmos pass_189(.gn(I_3031_S), .gp(I_3127_S), .p1(I_3191_D), .p2(I_3191_S));
    generic_pmos I_3191(.D(I_3191_D), .G(I_3127_S), .S(I_3191_S));
    generic_nmos I_3158(.D(I_3191_D), .G(I_3031_S), .S(I_3191_S));
// Driver
  not auto_705(I_3127_S, I_3031_S);
    generic_pmos I_3127(.D(VDD), .G(I_3031_S), .S(I_3127_S));
    generic_nmos I_3126(.D(VSS), .G(I_3031_S), .S(I_3127_S));
// Connects with CMOS pass 166/167/173/187/189
    generic_nmos I_3190(.D(I_3191_S), .G(I_3127_S), .S(VSS));

// A8

// FullAdder 14 Inputs: I_3345_S (PartialSum), I_3185_S (Logic) Sum: I_3345_D Carry: I_3825_S
// FullAdder 14 Extra Inputs: I_1679_D, I_3116_D
// Inverted input
  not auto_726(I_3249_D, I_3185_S);
    generic_pmos I_3249(.D(I_3249_D), .G(I_3185_S), .S(VDD));
    generic_nmos I_3248(.D(I_3249_D), .G(I_3185_S), .S(VSS));
// 2:1 Mux with single control: Inputs: I_3313_D, I_3345_S Output: I_3345_D Control: I_3249_D
  generic_cmos pass_195(.gn(I_3249_D), .gp(I_3281_S), .p1(I_3313_D), .p2(I_3345_D));
    generic_pmos I_3313(.D(I_3313_D), .G(I_3281_S), .S(I_3345_D));
    generic_nmos I_3312(.D(I_3313_D), .G(I_3249_D), .S(I_3345_D));
  generic_cmos pass_203(.gn(I_3281_S), .gp(I_3249_D), .p1(I_3345_D), .p2(I_3345_S));
    generic_pmos I_3345(.D(I_3345_D), .G(I_3249_D), .S(I_3345_S));
    generic_nmos I_3344(.D(I_3345_D), .G(I_3281_S), .S(I_3345_S));
// Driver
  not auto_735(I_3281_S, I_3249_D);
    generic_pmos I_3281(.D(VDD), .G(I_3249_D), .S(I_3281_S));
    generic_nmos I_3280(.D(VSS), .G(I_3249_D), .S(I_3281_S));
// Transmission Gate (CMOS Pass) Input: I_3825_S Output: I_3185_S Control: I_3345_S
  generic_cmos pass_185(.gn(I_3313_D), .gp(I_3345_S), .p1(I_3825_S), .p2(I_3185_S));
    generic_pmos I_3185(.D(I_3825_S), .G(I_3345_S), .S(I_3185_S));
    generic_nmos I_3152(.D(I_3825_S), .G(I_3313_D), .S(I_3185_S));
// Driver
  not auto_702(I_3313_D, I_3345_S);
    generic_pmos I_3121(.D(VDD), .G(I_3345_S), .S(I_3313_D));
    generic_nmos I_3120(.D(VSS), .G(I_3345_S), .S(I_3313_D));
// Part of Adder 14
  nand auto_647(I_2865_D, I_1679_D, I_3116_D);
    generic_pmos I_2833(.D(VDD), .G(I_3116_D), .S(I_2865_D));
    generic_pmos I_2865(.D(I_2865_D), .G(I_1679_D), .S(VDD));
    generic_nmos I_2832(.D(I_2865_D), .G(I_1679_D), .S(I_2864_D));
    generic_nmos I_2864(.D(I_2864_D), .G(I_3116_D), .S(VSS));
  nor auto_656(I_2928_D, I_1679_D, I_3116_D);
    generic_pmos I_2929(.D(I_2929_D), .G(I_3116_D), .S(VDD));
    generic_pmos I_2897(.D(I_2928_D), .G(I_1679_D), .S(I_2929_D));
    generic_nmos I_2896(.D(VSS), .G(I_1679_D), .S(I_2928_D));
    generic_nmos I_2928(.D(I_2928_D), .G(I_3116_D), .S(VSS));
  not auto_669(I_2961_S, I_2928_D);
    generic_pmos I_2961(.D(VDD), .G(I_2928_D), .S(I_2961_S));
    generic_nmos I_2960(.D(VSS), .G(I_2928_D), .S(I_2961_S));
  nand auto_688(I_3345_S, I_2961_S, I_2865_D);
    generic_pmos I_3057(.D(VDD), .G(I_2961_S), .S(I_3345_S));
    generic_pmos I_3089(.D(I_3345_S), .G(I_2865_D), .S(VDD));
    generic_nmos I_3056(.D(I_3345_S), .G(I_2961_S), .S(I_3088_D));
    generic_nmos I_3088(.D(I_3088_D), .G(I_2865_D), .S(VSS));
// Modifier transistor pair
    generic_pmos I_3025(.D(I_3825_S), .G(I_2865_D), .S(VDD));
    generic_nmos I_2992(.D(VSS), .G(I_2928_D), .S(I_3825_S));

// HalfAdder 06 Inputs: I_3345_D, I_3191_S Sum: I_3029_D (Gates P-A8) Carry: I_3219_D
// 2:1 Mux with single control: Inputs: I_3125_S, I_3345_D Output: I_3029_D Control: I_3191_S
  generic_cmos pass_166(.gn(I_3191_S), .gp(I_3061_D), .p1(I_3125_S), .p2(I_3029_D));
    generic_pmos I_2997(.D(I_3125_S), .G(I_3061_D), .S(I_3029_D));
    generic_nmos I_2996(.D(I_3125_S), .G(I_3191_S), .S(I_3029_D));
  generic_cmos pass_173(.gn(I_3061_D), .gp(I_3191_S), .p1(I_3029_D), .p2(I_3345_D));
    generic_pmos I_3029(.D(I_3029_D), .G(I_3191_S), .S(I_3345_D));
    generic_nmos I_3028(.D(I_3029_D), .G(I_3061_D), .S(I_3345_D));
// Driver
  not auto_690(I_3061_D, I_3191_S);
    generic_pmos I_3061(.D(I_3061_D), .G(I_3191_S), .S(VDD));
    generic_nmos I_3060(.D(I_3061_D), .G(I_3191_S), .S(VSS));
// Transmission Gate (CMOS Pass) Input: I_3191_S Output: I_3189_S Control: I_3345_D
// Goes near CMOS SW 166 and 173
  generic_cmos pass_187(.gn(I_3345_D), .gp(I_3125_S), .p1(I_3191_S), .p2(I_3189_S));
    generic_pmos I_3189(.D(I_3191_S), .G(I_3125_S), .S(I_3189_S));
    generic_nmos I_3156(.D(I_3191_S), .G(I_3345_D), .S(I_3189_S));
// Driver
  not auto_704(I_3125_S, I_3345_D);
    generic_pmos I_3125(.D(VDD), .G(I_3345_D), .S(I_3125_S));
    generic_nmos I_3124(.D(VSS), .G(I_3345_D), .S(I_3125_S));
// Connects with CMOS pass 166/187
    generic_nmos I_3188(.D(I_3189_S), .G(I_3125_S), .S(VSS));
// ~Carry
  not auto_736(I_3283_S, I_3189_S);
    generic_pmos I_3283(.D(VDD), .G(I_3189_S), .S(I_3283_S));
    generic_nmos I_3282(.D(VSS), .G(I_3189_S), .S(I_3283_S));
// Carry
// This inverter/NOT gates not identified in original verilog, manually constructed.
  not manual_2(I_3219_D, I_3283_S);
    generic_pmos I_3219(.D(I_3219_D), .G(I_3283_S), .S(VDD));
    generic_nmos I_3218(.D(I_3219_D), .G(I_3283_S), .S(VSS));

// A9

// FullAdder 16 Inputs: I_3985_S (PartialSum), I_3825_S Sum: I_3985_D Carry: I_3825_D
// FullAdder 16 Extra Inputs: I_2319_D, I_3663_S
// Inverted input
  not auto_875(I_3889_D, I_3825_S);
    generic_pmos I_3889(.D(I_3889_D), .G(I_3825_S), .S(VDD));
    generic_nmos I_3888(.D(I_3889_D), .G(I_3825_S), .S(VSS));
// 2:1 Mux with single control: Inputs: I_3953_D, I_3985_S Output: I_3985_D Control: I_3889_D
  generic_cmos pass_234(.gn(I_3889_D), .gp(I_3921_S), .p1(I_3953_D), .p2(I_3985_D));
    generic_pmos I_3953(.D(I_3953_D), .G(I_3921_S), .S(I_3985_D));
    generic_nmos I_3952(.D(I_3953_D), .G(I_3889_D), .S(I_3985_D));
  generic_cmos pass_235(.gn(I_3921_S), .gp(I_3889_D), .p1(I_3985_D), .p2(I_3985_S));
    generic_pmos I_3985(.D(I_3985_D), .G(I_3889_D), .S(I_3985_S));
    generic_nmos I_3984(.D(I_3985_D), .G(I_3921_S), .S(I_3985_S));
// Driver
  not auto_883(I_3921_S, I_3889_D);
    generic_pmos I_3921(.D(VDD), .G(I_3889_D), .S(I_3921_S));
    generic_nmos I_3920(.D(VSS), .G(I_3889_D), .S(I_3921_S));
// Transmission Gate (CMOS Pass) Input: I_3825_D Output: I_3825_S Control: I_3985_S
  generic_cmos pass_231(.gn(I_3953_D), .gp(I_3985_S), .p1(I_3825_D), .p2(I_3825_S));
    generic_pmos I_3825(.D(I_3825_D), .G(I_3985_S), .S(I_3825_S));
    generic_nmos I_3792(.D(I_3825_D), .G(I_3953_D), .S(I_3825_S));
// Driver
  not auto_845(I_3953_D, I_3985_S);
    generic_pmos I_3761(.D(VDD), .G(I_3985_S), .S(I_3953_D));
    generic_nmos I_3760(.D(VSS), .G(I_3985_S), .S(I_3953_D));
// Part of Adder 16
  nand auto_777(I_3505_D, I_2319_D, I_3663_S);
    generic_pmos I_3473(.D(VDD), .G(I_3663_S), .S(I_3505_D));
    generic_pmos I_3505(.D(I_3505_D), .G(I_2319_D), .S(VDD));
    generic_nmos I_3472(.D(I_3505_D), .G(I_2319_D), .S(I_3504_D));
    generic_nmos I_3504(.D(I_3504_D), .G(I_3663_S), .S(VSS));
  nor auto_796(I_3568_D, I_3663_S, I_2319_D);
    generic_pmos I_3569(.D(I_3569_D), .G(I_3663_S), .S(VDD));
    generic_pmos I_3537(.D(I_3568_D), .G(I_2319_D), .S(I_3569_D));
    generic_nmos I_3536(.D(VSS), .G(I_2319_D), .S(I_3568_D));
    generic_nmos I_3568(.D(I_3568_D), .G(I_3663_S), .S(VSS));
  not auto_810(I_3601_S, I_3568_D);
    generic_pmos I_3601(.D(VDD), .G(I_3568_D), .S(I_3601_S));
    generic_nmos I_3600(.D(VSS), .G(I_3568_D), .S(I_3601_S));
  nand auto_829(I_3985_S, I_3601_S, I_3505_D);
    generic_pmos I_3697(.D(VDD), .G(I_3601_S), .S(I_3985_S));
    generic_pmos I_3729(.D(I_3985_S), .G(I_3505_D), .S(VDD));
    generic_nmos I_3696(.D(I_3985_S), .G(I_3601_S), .S(I_3728_D));
    generic_nmos I_3728(.D(I_3728_D), .G(I_3505_D), .S(VSS));
// Modifier Transistor Pair
    generic_pmos I_3665(.D(I_3825_D), .G(I_3505_D), .S(VDD));
    generic_nmos I_3632(.D(VSS), .G(I_3568_D), .S(I_3825_D));

// Chained carry nots

  not auto_809(I_3599_S, I_3825_D);
    generic_pmos I_3599(.D(VDD), .G(I_3825_D), .S(I_3599_S));
    generic_nmos I_3598(.D(VSS), .G(I_3825_D), .S(I_3599_S));
  not auto_795(I_3535_D, I_3599_S);
    generic_pmos I_3535(.D(I_3535_D), .G(I_3599_S), .S(VDD));
    generic_nmos I_3534(.D(I_3535_D), .G(I_3599_S), .S(VSS));

// HalfAdder 07 Inputs: I_3985_D, I_3219_D  Sum: I_3027_D (Gates P-A9) Carry: I_3507_D
// 2:1 Mux with single control: Inputs: I_3123_S, I_3985_D Output: I_3027_D Control: I_3219_D
  generic_cmos pass_165(.gn(I_3219_D), .gp(I_3059_D), .p1(I_3123_S), .p2(I_3027_D));
    generic_pmos I_2995(.D(I_3123_S), .G(I_3059_D), .S(I_3027_D));
    generic_nmos I_2994(.D(I_3123_S), .G(I_3219_D), .S(I_3027_D));
  generic_cmos pass_172(.gn(I_3059_D), .gp(I_3219_D), .p1(I_3027_D), .p2(I_3985_D));
    generic_pmos I_3027(.D(I_3027_D), .G(I_3219_D), .S(I_3985_D));
    generic_nmos I_3026(.D(I_3027_D), .G(I_3059_D), .S(I_3985_D));
// Driver
  not auto_689(I_3059_D, I_3219_D);
    generic_pmos I_3059(.D(I_3059_D), .G(I_3219_D), .S(VDD));
    generic_nmos I_3058(.D(I_3059_D), .G(I_3219_D), .S(VSS));
// Transmission Gate (CMOS Pass) Input: I_3219_D Output: I_3507_D Control: I_3985_D
  generic_cmos pass_186(.gn(I_3985_D), .gp(I_3123_S), .p1(I_3219_D), .p2(I_3507_D));
    generic_pmos I_3187(.D(I_3219_D), .G(I_3123_S), .S(I_3507_D));
    generic_nmos I_3154(.D(I_3219_D), .G(I_3985_D), .S(I_3507_D));
// Driver
  not auto_703(I_3123_S, I_3985_D);
    generic_pmos I_3123(.D(VDD), .G(I_3985_D), .S(I_3123_S));
    generic_nmos I_3122(.D(VSS), .G(I_3985_D), .S(I_3123_S));
// Connects with CMOS pass 165/186/196/204/215
    generic_nmos I_3186(.D(I_3507_D), .G(I_3123_S), .S(VSS));

// A10

// FullAdder 19 Inputs: I_3503_S (PartialSum), I_3535_D (Logic) Sum: I_3503_D Carry: I_3823_D
// FullAdder 19 Extra Inputs: I_3116_D, I_3019_S
// Inverted input
  not auto_764(I_3407_D, I_3535_D);
    generic_pmos I_3407(.D(I_3407_D), .G(I_3535_D), .S(VDD));
    generic_nmos I_3406(.D(I_3407_D), .G(I_3535_D), .S(VSS));
// 2:1 Mux with single control: Inputs: I_3471_D, I_3503_S Output: I_3503_D Controls: I_3407_D
  generic_cmos pass_208(.gn(I_3407_D), .gp(I_3439_S), .p1(I_3471_D), .p2(I_3503_D));
    generic_pmos I_3471(.D(I_3471_D), .G(I_3439_S), .S(I_3503_D));
    generic_nmos I_3470(.D(I_3471_D), .G(I_3407_D), .S(I_3503_D));
  generic_cmos pass_214(.gn(I_3439_S), .gp(I_3407_D), .p1(I_3503_D), .p2(I_3503_S));
    generic_pmos I_3503(.D(I_3503_D), .G(I_3407_D), .S(I_3503_S));
    generic_nmos I_3502(.D(I_3503_D), .G(I_3439_S), .S(I_3503_S));
// Driver
  not auto_771(I_3439_S, I_3407_D);
    generic_pmos I_3439(.D(VDD), .G(I_3407_D), .S(I_3439_S));
    generic_nmos I_3438(.D(VSS), .G(I_3407_D), .S(I_3439_S));
// Transmission Gate (CMOS Pass) Input: I_3823_D Output: I_3535_D Control: I_3503_S
  generic_cmos pass_202(.gn(I_3471_D), .gp(I_3503_S), .p1(I_3823_D), .p2(I_3535_D));
    generic_pmos I_3343(.D(I_3823_D), .G(I_3503_S), .S(I_3535_D));
    generic_nmos I_3310(.D(I_3823_D), .G(I_3471_D), .S(I_3535_D));
// Driver
  not auto_734(I_3471_D, I_3503_S);
    generic_pmos I_3279(.D(VDD), .G(I_3503_S), .S(I_3471_D));
    generic_nmos I_3278(.D(VSS), .G(I_3503_S), .S(I_3471_D));
// Part of Adder 19
  nand auto_674(I_3023_D, I_3116_D, I_3019_S);
    generic_pmos I_2991(.D(VDD), .G(I_3019_S), .S(I_3023_D));
    generic_pmos I_3023(.D(I_3023_D), .G(I_3116_D), .S(VDD));
    generic_nmos I_2990(.D(I_3023_D), .G(I_3116_D), .S(I_3022_D));
    generic_nmos I_3022(.D(I_3022_D), .G(I_3019_S), .S(VSS));
  nor auto_687(I_3086_D, I_3116_D, I_3019_S);
    generic_pmos I_3087(.D(I_3087_D), .G(I_3019_S), .S(VDD));
    generic_pmos I_3055(.D(I_3086_D), .G(I_3116_D), .S(I_3087_D));
    generic_nmos I_3054(.D(VSS), .G(I_3116_D), .S(I_3086_D));
    generic_nmos I_3086(.D(I_3086_D), .G(I_3019_S), .S(VSS));
  not auto_701(I_3119_S, I_3086_D);
    generic_pmos I_3119(.D(VDD), .G(I_3086_D), .S(I_3119_S));
    generic_nmos I_3118(.D(VSS), .G(I_3086_D), .S(I_3119_S));
  nand auto_718(I_3503_S, I_3119_S, I_3023_D);
    generic_pmos I_3215(.D(VDD), .G(I_3119_S), .S(I_3503_S));
    generic_pmos I_3247(.D(I_3503_S), .G(I_3023_D), .S(VDD));
    generic_nmos I_3214(.D(I_3503_S), .G(I_3119_S), .S(I_3246_D));
    generic_nmos I_3246(.D(I_3246_D), .G(I_3023_D), .S(VSS));
// Modifier transistor pair
    generic_pmos I_3183(.D(I_3823_D), .G(I_3023_D), .S(VDD));
    generic_nmos I_3150(.D(VSS), .G(I_3086_D), .S(I_3823_D));

// HalfAdder 08 Inputs: I_3503_D, I_3507_D Sum: I_3347_D (Gates P-A10) Carry: I_3827_D
// 2:1 Mux with single control: Inputs: I_3443_S, I_3503_D Output: I_3347_D Control: I_3507_D
  generic_cmos pass_196(.gn(I_3507_D), .gp(I_3379_D), .p1(I_3443_S), .p2(I_3347_D));
    generic_pmos I_3315(.D(I_3443_S), .G(I_3379_D), .S(I_3347_D));
    generic_nmos I_3314(.D(I_3443_S), .G(I_3507_D), .S(I_3347_D));
  generic_cmos pass_204(.gn(I_3379_D), .gp(I_3507_D), .p1(I_3347_D), .p2(I_3503_D));
    generic_pmos I_3347(.D(I_3347_D), .G(I_3507_D), .S(I_3503_D));
    generic_nmos I_3346(.D(I_3347_D), .G(I_3379_D), .S(I_3503_D));
// Driver
  not auto_754(I_3379_D, I_3507_D);
    generic_pmos I_3379(.D(I_3379_D), .G(I_3507_D), .S(VDD));
    generic_nmos I_3378(.D(I_3379_D), .G(I_3507_D), .S(VSS));
// Transmission Gate (CMOS Pass) Input: I_3507_D Output: I_3827_D Control: I_3503_D
  generic_cmos pass_215(.gn(I_3503_D), .gp(I_3443_S), .p1(I_3507_D), .p2(I_3827_D));
    generic_pmos I_3507(.D(I_3507_D), .G(I_3443_S), .S(I_3827_D));
    generic_nmos I_3474(.D(I_3507_D), .G(I_3503_D), .S(I_3827_D));
// Driver
  not auto_772(I_3443_S, I_3503_D);
    generic_pmos I_3443(.D(VDD), .G(I_3503_D), .S(I_3443_S));
    generic_nmos I_3442(.D(VSS), .G(I_3503_D), .S(I_3443_S));
// Connects with CMOS pass 196/215/219/224/232
    generic_nmos I_3506(.D(I_3827_D), .G(I_3443_S), .S(VSS));

// A11

// HalfAdder 15 Inputs: I_3663_S (Logic), I_3823_D Sum: I_3663_D Carry: I_3823_S
// 2:1 Mux with single control: Inputs: I_3759_S, I_3663_S Output: I_3663_D Control: I_3823_D
  generic_cmos pass_218(.gn(I_3823_D), .gp(I_3695_D), .p1(I_3759_S), .p2(I_3663_D));
    generic_pmos I_3631(.D(I_3759_S), .G(I_3695_D), .S(I_3663_D));
    generic_nmos I_3630(.D(I_3759_S), .G(I_3823_D), .S(I_3663_D));
  generic_cmos pass_223(.gn(I_3695_D), .gp(I_3823_D), .p1(I_3663_D), .p2(I_3663_S));
    generic_pmos I_3663(.D(I_3663_D), .G(I_3823_D), .S(I_3663_S));
    generic_nmos I_3662(.D(I_3663_D), .G(I_3695_D), .S(I_3663_S));
// Driver
  not auto_828(I_3695_D, I_3823_D);
    generic_pmos I_3695(.D(I_3695_D), .G(I_3823_D), .S(VDD));
    generic_nmos I_3694(.D(I_3695_D), .G(I_3823_D), .S(VSS));
// Transmission Gate (CMOS Pass) Input: I_3823_D Output: I_3823_S Control: I_3663_S
  generic_cmos pass_230(.gn(I_3663_S), .gp(I_3759_S), .p1(I_3823_D), .p2(I_3823_S));
    generic_pmos I_3823(.D(I_3823_D), .G(I_3759_S), .S(I_3823_S));
    generic_nmos I_3790(.D(I_3823_D), .G(I_3663_S), .S(I_3823_S));
// Driver
  not auto_844(I_3759_S, I_3663_S);
    generic_pmos I_3759(.D(VDD), .G(I_3663_S), .S(I_3759_S));
    generic_nmos I_3758(.D(VSS), .G(I_3663_S), .S(I_3759_S));
// Connects with CMOS pass 133/140/218/230
    generic_nmos I_3822(.D(I_3823_S), .G(I_3759_S), .S(VSS));

// HalfAdder 09 Inputs: I_3663_D, I_3827_D Sum: I_3667_D (Gates P-A11) Carry: I_3829_D
// 2:1 Mux with single control: Inputs: I_3763_S, I_3663_D Output: I_3667_D Control: I_3827_D
// Note: Output is through series of NAND gates toward Internal DRAM row-col bus b3
  generic_cmos pass_219(.gn(I_3827_D), .gp(I_3699_D), .p1(I_3763_S), .p2(I_3667_D));
    generic_pmos I_3635(.D(I_3763_S), .G(I_3699_D), .S(I_3667_D));
    generic_nmos I_3634(.D(I_3763_S), .G(I_3827_D), .S(I_3667_D));
  generic_cmos pass_224(.gn(I_3699_D), .gp(I_3827_D), .p1(I_3667_D), .p2(I_3663_D));
    generic_pmos I_3667(.D(I_3667_D), .G(I_3827_D), .S(I_3663_D));
    generic_nmos I_3666(.D(I_3667_D), .G(I_3699_D), .S(I_3663_D));
// Driver
  not auto_830(I_3699_D, I_3827_D);
    generic_pmos I_3699(.D(I_3699_D), .G(I_3827_D), .S(VDD));
    generic_nmos I_3698(.D(I_3699_D), .G(I_3827_D), .S(VSS));
// Transmission Gate (CMOS Pass) Input: I_3827_D Output: I_3829_D Control: I_3663_D
  generic_cmos pass_232(.gn(I_3663_D), .gp(I_3763_S), .p1(I_3827_D), .p2(I_3829_D));
    generic_pmos I_3827(.D(I_3827_D), .G(I_3763_S), .S(I_3829_D));
    generic_nmos I_3794(.D(I_3827_D), .G(I_3663_D), .S(I_3829_D));
// Driver
  not auto_846(I_3763_S, I_3663_D);
    generic_pmos I_3763(.D(VDD), .G(I_3663_D), .S(I_3763_S));
    generic_nmos I_3762(.D(VSS), .G(I_3663_D), .S(I_3763_S));
// Connects with CMOS pass 219/220/225/232/233
    generic_nmos I_3826(.D(I_3829_D), .G(I_3763_S), .S(VSS));

// A12, (and A13,A14)

// HalfAdder 20 Inputs: I_3019_S, I_3823_S Sum: I_3669_S Carry: NONE
// 2:1 Mux with single control: Inputs: I_3019_S, I_2735_D Output: I_3669_S Controls: I_3823_S
  generic_cmos pass_133(.gn(I_2799_S), .gp(I_3823_S), .p1(I_3019_S), .p2(I_3669_S));
    generic_pmos I_2671(.D(I_3019_S), .G(I_3823_S), .S(I_3669_S));
    generic_nmos I_2670(.D(I_3019_S), .G(I_2799_S), .S(I_3669_S));
  generic_cmos pass_140(.gn(I_3823_S), .gp(I_2799_S), .p1(I_3669_S), .p2(I_2735_D));
    generic_pmos I_2703(.D(I_3669_S), .G(I_2799_S), .S(I_2735_D));
    generic_nmos I_2702(.D(I_3669_S), .G(I_3823_S), .S(I_2735_D));
// Driver
  not auto_642(I_2799_S, I_3823_S);
    generic_pmos I_2799(.D(VDD), .G(I_3823_S), .S(I_2799_S));
    generic_nmos I_2798(.D(VSS), .G(I_3823_S), .S(I_2799_S));
// "MISSING TRANSMISSION GATE" (gp/gn to I_2735_D/I_3019_S, and p1/p2 to? -- Adder is end of line, not needed.
// Driver
  not auto_628(I_2735_D, I_3019_S);
    generic_pmos I_2735(.D(I_2735_D), .G(I_3019_S), .S(VDD));
    generic_nmos I_2734(.D(I_2735_D), .G(I_3019_S), .S(VSS));
// MISSING FET HERE -- see above

// HalfAdder 10 Inputs: I_3669_S, I_3829_D Sum: I_3669_D (Gates P-A12) ~Carry: I_3036_S (Gates P-A13) Carry: I_3829_S (Gates P-A14)
// 2:1 Mux with single control: Inputs: I_3765_S, I_3669_S Output: I_3669_D Control: I_3829_D
// Note: Output is through series of NAND gates toward Internal DRAM row-col bus b5 (b5 = A8+4=A12, order is odd!)
  generic_cmos pass_220(.gn(I_3829_D), .gp(I_3701_D), .p1(I_3765_S), .p2(I_3669_D));
    generic_pmos I_3637(.D(I_3765_S), .G(I_3701_D), .S(I_3669_D));
    generic_nmos I_3636(.D(I_3765_S), .G(I_3829_D), .S(I_3669_D));
  generic_cmos pass_225(.gn(I_3701_D), .gp(I_3829_D), .p1(I_3669_D), .p2(I_3669_S));
    generic_pmos I_3669(.D(I_3669_D), .G(I_3829_D), .S(I_3669_S));
    generic_nmos I_3668(.D(I_3669_D), .G(I_3701_D), .S(I_3669_S));
// Driver
  not auto_832(I_3701_D, I_3829_D);
    generic_pmos I_3701(.D(I_3701_D), .G(I_3829_D), .S(VDD));
    generic_nmos I_3700(.D(I_3701_D), .G(I_3829_D), .S(VSS));
// Transmission Gate (CMOS Pass) Input: I_3829_D Output: I_3829_S Control: I_3669_S
  generic_cmos pass_233(.gn(I_3669_S), .gp(I_3765_S), .p1(I_3829_D), .p2(I_3829_S));
    generic_pmos I_3829(.D(I_3829_D), .G(I_3765_S), .S(I_3829_S));
    generic_nmos I_3796(.D(I_3829_D), .G(I_3669_S), .S(I_3829_S));
// Driver
  not auto_847(I_3765_S, I_3669_S);
    generic_pmos I_3765(.D(VDD), .G(I_3669_S), .S(I_3765_S));
    generic_nmos I_3764(.D(VSS), .G(I_3669_S), .S(I_3765_S));
// Connects with CMOS pass 220/233
    generic_nmos I_3828(.D(I_3829_S), .G(I_3765_S), .S(VSS));
// ~Carry
  not auto_677(I_3036_S, I_3829_S);
    generic_pmos I_3005(.D(I_3036_S), .G(I_3829_S), .S(VDD));
    generic_nmos I_3036(.D(VSS), .G(I_3829_S), .S(I_3036_S));

// ********************************************************************************************************

// Attribute storage and decoding (See Page 12)

// This latch loads from internal data bus [D0..D6] only (D7 follows, separate clock -- only used for inverse bit!) (gates19.png)
// Holds ASCII code/attribute loaded in 1st phase lookup of text mode
// Internal data bus [D0..D6,D7] is I_2041_D,I_2201_D,I_2361_D,I_2521_D,I_2681_D,I_2841_D,I_3993_S and I_1417_S in order.
// Latched data bus [D0..D6,D7] becomes I_2169_D, I_2329_D, I_1415_S, I_2649_D, I_2809_D, [!I_2905_D/I_2969_D], [!I_3065_D/I_3129_D] and I_1355_D in order.

// Extra inverter for b7's clock
  not auto_310(I_1101_S, I_1973_D);
    generic_pmos I_1101(.D(VDD), .G(I_1973_D), .S(I_1101_S));
    generic_nmos I_1068(.D(I_1101_S), .G(I_1973_D), .S(VSS));

// Set of 7 D-Type latches with Asynchronous SET/RESETs (common clock)
// In 7 singles
// D-Type Latch D: I_2041_D ~Q: I_2105_D Q: I_2169_D Falling Clock: I_1973_D: On Data Bus D0
// 2:1 Mux with single control: Inputs: I_2041_D, I_2169_D Output: I_2073_D Control: I_1973_D
  generic_cmos pass_92(.gn(I_1973_D), .gp(I_2007_D), .p1(I_2041_D), .p2(I_2073_D));
    generic_pmos I_2041(.D(I_2041_D), .G(I_2007_D), .S(I_2073_D));
    generic_nmos I_2040(.D(I_2041_D), .G(I_1973_D), .S(I_2073_D));
  generic_cmos pass_98(.gn(I_2007_D), .gp(I_1973_D), .p1(I_2073_D), .p2(I_2169_D));
    generic_pmos I_2073(.D(I_2073_D), .G(I_1973_D), .S(I_2169_D));
    generic_nmos I_2072(.D(I_2073_D), .G(I_2007_D), .S(I_2169_D));
  not auto_516(I_2105_D, I_2073_D);
    generic_pmos I_2105(.D(I_2105_D), .G(I_2073_D), .S(VDD));
    generic_nmos I_2104(.D(I_2105_D), .G(I_2073_D), .S(VSS));
  not auto_521(I_2169_D, I_2105_D); // NMOS strength = 2
    generic_pmos I_2137(.D(VDD), .G(I_2105_D), .S(I_2169_D));
    generic_pmos I_2169(.D(I_2169_D), .G(I_2105_D), .S(VDD));
    generic_nmos I_2136(.D(VSS), .G(I_2105_D), .S(I_2169_D));
    generic_nmos I_2168(.D(I_2169_D), .G(I_2105_D), .S(VSS));
// D-Type Latch D: I_2201_D ~Q: I_2265_D Q: I_2329_D Falling Clock: I_1973_D On Data Bus D1
// 2:1 Mux with single control: Inputs: I_2201_D, I_2329_D Output: I_2233_D Control: I_1973_D
  generic_cmos pass_102(.gn(I_1973_D), .gp(I_2007_D), .p1(I_2201_D), .p2(I_2233_D));
    generic_pmos I_2201(.D(I_2201_D), .G(I_2007_D), .S(I_2233_D));
    generic_nmos I_2200(.D(I_2201_D), .G(I_1973_D), .S(I_2233_D));
  generic_cmos pass_107(.gn(I_2007_D), .gp(I_1973_D), .p1(I_2233_D), .p2(I_2329_D));
    generic_pmos I_2233(.D(I_2233_D), .G(I_1973_D), .S(I_2329_D));
    generic_nmos I_2232(.D(I_2233_D), .G(I_2007_D), .S(I_2329_D));
  not auto_547(I_2265_D, I_2233_D);
    generic_pmos I_2265(.D(I_2265_D), .G(I_2233_D), .S(VDD));
    generic_nmos I_2264(.D(I_2265_D), .G(I_2233_D), .S(VSS));
  not auto_554(I_2329_D, I_2265_D); // NMOS strength = 2
    generic_pmos I_2297(.D(VDD), .G(I_2265_D), .S(I_2329_D));
    generic_pmos I_2329(.D(I_2329_D), .G(I_2265_D), .S(VDD));
    generic_nmos I_2296(.D(VSS), .G(I_2265_D), .S(I_2329_D));
    generic_nmos I_2328(.D(I_2329_D), .G(I_2265_D), .S(VSS));
// D-Type Latch D: I_2361_D ~Q: I_2425_D Q: I_1415_S Falling Clock: I_1973_D On Data Bus D2
// 2:1 Mux with single control: Inputs: I_2361_D, I_1415_S Output: I_2393_D Control: I_1973_D
  generic_cmos pass_111(.gn(I_1973_D), .gp(I_2007_D), .p1(I_2361_D), .p2(I_2393_D));
    generic_pmos I_2361(.D(I_2361_D), .G(I_2007_D), .S(I_2393_D));
    generic_nmos I_2360(.D(I_2361_D), .G(I_1973_D), .S(I_2393_D));
  generic_cmos pass_116(.gn(I_2007_D), .gp(I_1973_D), .p1(I_2393_D), .p2(I_1415_S));
    generic_pmos I_2393(.D(I_2393_D), .G(I_1973_D), .S(I_1415_S));
    generic_nmos I_2392(.D(I_2393_D), .G(I_2007_D), .S(I_1415_S));  
  not auto_577(I_2425_D, I_2393_D);
    generic_pmos I_2425(.D(I_2425_D), .G(I_2393_D), .S(VDD));
    generic_nmos I_2424(.D(I_2425_D), .G(I_2393_D), .S(VSS));
  not auto_583(I_1415_S, I_2425_D); // NMOS strength = 2
    generic_pmos I_2457(.D(VDD), .G(I_2425_D), .S(I_1415_S));
    generic_pmos I_2489(.D(I_1415_S), .G(I_2425_D), .S(VDD));
    generic_nmos I_2456(.D(VSS), .G(I_2425_D), .S(I_1415_S));
    generic_nmos I_2488(.D(I_1415_S), .G(I_2425_D), .S(VSS));
// D-Type Latch D: I_2521_D ~Q: I_2585_D Q: I_2649_D Falling Clock: I_1973_D On Data Bus D3
// 2:1 Mux with single control: Inputs: I_2521_D, I_2649_D Output: I_2553_D Control: I_1973_D
  generic_cmos pass_121(.gn(I_1973_D), .gp(I_2007_D), .p1(I_2521_D), .p2(I_2553_D));
    generic_pmos I_2521(.D(I_2521_D), .G(I_2007_D), .S(I_2553_D));
    generic_nmos I_2520(.D(I_2521_D), .G(I_1973_D), .S(I_2553_D));
  generic_cmos pass_127(.gn(I_2007_D), .gp(I_1973_D), .p1(I_2553_D), .p2(I_2649_D));
    generic_pmos I_2553(.D(I_2553_D), .G(I_1973_D), .S(I_2649_D));
    generic_nmos I_2552(.D(I_2553_D), .G(I_2007_D), .S(I_2649_D));
  not auto_606(I_2585_D, I_2553_D);
    generic_pmos I_2585(.D(I_2585_D), .G(I_2553_D), .S(VDD));
    generic_nmos I_2584(.D(I_2585_D), .G(I_2553_D), .S(VSS));
  not auto_613(I_2649_D, I_2585_D); // NMOS strength = 2
    generic_pmos I_2617(.D(VDD), .G(I_2585_D), .S(I_2649_D));
    generic_pmos I_2649(.D(I_2649_D), .G(I_2585_D), .S(VDD));
    generic_nmos I_2616(.D(VSS), .G(I_2585_D), .S(I_2649_D));
    generic_nmos I_2648(.D(I_2649_D), .G(I_2585_D), .S(VSS));
// D-Type Latch D: I_2681_D ~Q: I_2745_D Q: I_2809_D Falling Clock: I_1973_D On Data Bus D4
// 2:1 Mux with single control: Inputs: I_2681_D, I_2809_D Output: I_2713_D Control: I_1973_D
  generic_cmos pass_136(.gn(I_1973_D), .gp(I_2007_D), .p1(I_2681_D), .p2(I_2713_D));
    generic_pmos I_2681(.D(I_2681_D), .G(I_2007_D), .S(I_2713_D));
    generic_nmos I_2680(.D(I_2681_D), .G(I_1973_D), .S(I_2713_D));
  generic_cmos pass_144(.gn(I_2007_D), .gp(I_1973_D), .p1(I_2713_D), .p2(I_2809_D));
    generic_pmos I_2713(.D(I_2713_D), .G(I_1973_D), .S(I_2809_D));
    generic_nmos I_2712(.D(I_2713_D), .G(I_2007_D), .S(I_2809_D));
  not auto_630(I_2745_D, I_2713_D);
    generic_pmos I_2745(.D(I_2745_D), .G(I_2713_D), .S(VDD));
    generic_nmos I_2744(.D(I_2745_D), .G(I_2713_D), .S(VSS));
  not auto_637(I_2809_D, I_2745_D); // NMOS strength = 2
    generic_pmos I_2777(.D(VDD), .G(I_2745_D), .S(I_2809_D));
    generic_pmos I_2809(.D(I_2809_D), .G(I_2745_D), .S(VDD));
    generic_nmos I_2776(.D(VSS), .G(I_2745_D), .S(I_2809_D));
    generic_nmos I_2808(.D(I_2809_D), .G(I_2745_D), .S(VSS));
// D-Type Latch D: I_2841_D ~Q: I_2905_D Q: I_2969_D Falling Clock: I_1973_D On Data Bus D5
// 2:1 Mux with single control: Inputs: I_2841_D, I_2969_D Output: I_2873_D Control: I_1973_D
  generic_cmos pass_151(.gn(I_1973_D), .gp(I_2007_D), .p1(I_2841_D), .p2(I_2873_D));
    generic_pmos I_2841(.D(I_2841_D), .G(I_2007_D), .S(I_2873_D));
    generic_nmos I_2840(.D(I_2841_D), .G(I_1973_D), .S(I_2873_D));
  generic_cmos pass_159(.gn(I_2007_D), .gp(I_1973_D), .p1(I_2873_D), .p2(I_2969_D));
    generic_pmos I_2873(.D(I_2873_D), .G(I_1973_D), .S(I_2969_D));
    generic_nmos I_2872(.D(I_2873_D), .G(I_2007_D), .S(I_2969_D));
  not auto_658(I_2905_D, I_2873_D);
    generic_pmos I_2905(.D(I_2905_D), .G(I_2873_D), .S(VDD));
    generic_nmos I_2904(.D(I_2905_D), .G(I_2873_D), .S(VSS));
  not auto_665(I_2969_D, I_2905_D); // NMOS strength = 2
    generic_pmos I_2937(.D(VDD), .G(I_2905_D), .S(I_2969_D));
    generic_pmos I_2969(.D(I_2969_D), .G(I_2905_D), .S(VDD));
    generic_nmos I_2936(.D(VSS), .G(I_2905_D), .S(I_2969_D));
    generic_nmos I_2968(.D(I_2969_D), .G(I_2905_D), .S(VSS));
// D-Type Latch D: I_3993_S ~Q: I_3065_D Q: I_3129_D Falling Clock: I_1973_D On Data Bus D6
// 2:1 Mux with single control: Inputs: I_3993_S, I_3129_D Output: I_3033_D Control: I_1973_D
  generic_cmos pass_168(.gn(I_1973_D), .gp(I_2007_D), .p1(I_3993_S), .p2(I_3033_D));
    generic_pmos I_3001(.D(I_3993_S), .G(I_2007_D), .S(I_3033_D));
    generic_nmos I_3000(.D(I_3993_S), .G(I_1973_D), .S(I_3033_D));
  generic_cmos pass_175(.gn(I_2007_D), .gp(I_1973_D), .p1(I_3033_D), .p2(I_3129_D));
    generic_pmos I_3033(.D(I_3033_D), .G(I_1973_D), .S(I_3129_D));
    generic_nmos I_3032(.D(I_3033_D), .G(I_2007_D), .S(I_3129_D));
  not auto_692(I_3065_D, I_3033_D);
    generic_pmos I_3065(.D(I_3065_D), .G(I_3033_D), .S(VDD));
    generic_nmos I_3064(.D(I_3065_D), .G(I_3033_D), .S(VSS));
  not auto_697(I_3129_D, I_3065_D); // NMOS strength = 2
    generic_pmos I_3097(.D(VDD), .G(I_3065_D), .S(I_3129_D));
    generic_pmos I_3129(.D(I_3129_D), .G(I_3065_D), .S(VDD));
    generic_nmos I_3096(.D(VSS), .G(I_3065_D), .S(I_3129_D));
    generic_nmos I_3128(.D(I_3129_D), .G(I_3065_D), .S(VSS));
// Shared Driver
  not auto_493(I_2007_D, I_1973_D); // NMOS strength = 2
    generic_pmos I_1975(.D(VDD), .G(I_1973_D), .S(I_2007_D));
    generic_pmos I_2007(.D(I_2007_D), .G(I_1973_D), .S(VDD));
    generic_nmos I_1974(.D(VSS), .G(I_1973_D), .S(I_2007_D));
    generic_nmos I_2006(.D(I_2007_D), .G(I_1973_D), .S(VSS));
// And for D7
// D-Type Flip Flop D: I_1417_S Q: I_1355_D ~Q: I_1387_D Rising Clock: I_1101_S On Data Bus D7
// Chain (Oa1)
// D-Type Latch D: I_1417_S ~Q: I_1419_S Q: I_1385_D Clock: I_1101_S On Data Bus D7
// 2:1 Mux with single control: Inputs: I_1385_D, I_1417_S Output: I_1417_D Control: I_1101_S
  generic_cmos pass_37(.gn(I_1101_S), .gp(I_1420_S), .p1(I_1385_D), .p2(I_1417_D));
    generic_pmos I_1385(.D(I_1385_D), .G(I_1420_S), .S(I_1417_D));
    generic_nmos I_1384(.D(I_1385_D), .G(I_1101_S), .S(I_1417_D));
  generic_cmos pass_46(.gn(I_1420_S), .gp(I_1101_S), .p1(I_1417_D), .p2(I_1417_S));
    generic_pmos I_1417(.D(I_1417_D), .G(I_1101_S), .S(I_1417_S));
    generic_nmos I_1416(.D(I_1417_D), .G(I_1420_S), .S(I_1417_S));
  not auto_345(I_1385_D, I_1419_S);
    generic_pmos I_1289(.D(I_1385_D), .G(I_1419_S), .S(VDD));
    generic_nmos I_1288(.D(I_1385_D), .G(I_1419_S), .S(VSS));
  not auto_358(I_1419_S, I_1417_D); // NMOS strength = 2
    generic_pmos I_1321(.D(VDD), .G(I_1417_D), .S(I_1419_S));
    generic_pmos I_1353(.D(I_1419_S), .G(I_1417_D), .S(VDD));
    generic_nmos I_1320(.D(VSS), .G(I_1417_D), .S(I_1419_S));
    generic_nmos I_1352(.D(I_1419_S), .G(I_1417_D), .S(VSS));
// Chain (Oa2)
// D-Type Latch D: I_1419_S ~Q: I_1355_D Q: I_1387_D Clock: I_1101_S
// 2:1 Mux with single control: Inputs: I_1387_D, I_1419_S Output: I_1419_D Control: I_1101_S
  generic_cmos pass_38(.gn(I_1420_S), .gp(I_1101_S), .p1(I_1387_D), .p2(I_1419_D));
    generic_pmos I_1387(.D(I_1387_D), .G(I_1101_S), .S(I_1419_D));
    generic_nmos I_1386(.D(I_1387_D), .G(I_1420_S), .S(I_1419_D));
  generic_cmos pass_47(.gn(I_1101_S), .gp(I_1420_S), .p1(I_1419_D), .p2(I_1419_S));
    generic_pmos I_1419(.D(I_1419_D), .G(I_1420_S), .S(I_1419_S));
    generic_nmos I_1418(.D(I_1419_D), .G(I_1101_S), .S(I_1419_S));
  not auto_346(I_1387_D, I_1355_D);
    generic_pmos I_1291(.D(I_1387_D), .G(I_1355_D), .S(VDD));
    generic_nmos I_1290(.D(I_1387_D), .G(I_1355_D), .S(VSS));
  not auto_359(I_1355_D, I_1419_D); // NMOS strength = 2
    generic_pmos I_1323(.D(VDD), .G(I_1419_D), .S(I_1355_D));
    generic_pmos I_1355(.D(I_1355_D), .G(I_1419_D), .S(VDD));
    generic_nmos I_1322(.D(VSS), .G(I_1419_D), .S(I_1355_D));
    generic_nmos I_1354(.D(I_1355_D), .G(I_1419_D), .S(VSS));
// Shared Driver
  not auto_369(I_1420_S, I_1101_S);
    generic_pmos I_1389(.D(I_1420_S), .G(I_1101_S), .S(VDD));
    generic_nmos I_1420(.D(VSS), .G(I_1101_S), .S(I_1420_S));

// Video: Attribute decoding logic
// Decodes bits b6-b3 of byte just read into latch, to work out which register to load (ink, style, paper, mode) 
// with value in b2-b0.
// b6,b5 must be 0,0 and b4,b3 set a register number (0=ink,1=style,2=paper,3=mode)
// Also: only allows attribs to change during active screen (excludes HBLANK and VBLANK periods)

// Controls reloading of video shift register when latched data is NOT an attribute (i.e. video data)
  nand auto_906(I_457_D, I_3065_D, I_2905_D);
    generic_pmos I_425(.D(VDD), .G(I_3065_D), .S(I_457_D));
    generic_pmos I_457(.D(I_457_D), .G(I_2905_D), .S(VDD));
    generic_nmos I_424(.D(I_457_D), .G(I_2905_D), .S(I_456_D));
    generic_nmos I_456(.D(I_456_D), .G(I_3065_D), .S(VSS));

  nand auto_324(I_493_G, I_2371_S, I_2275_D);
    generic_pmos I_1153(.D(VDD), .G(I_2371_S), .S(I_493_G));
    generic_pmos I_1185(.D(I_493_G), .G(I_2275_D), .S(VDD));
    generic_nmos I_1184(.D(I_1184_D), .G(I_2275_D), .S(I_493_G));
    generic_nmos I_1152(.D(VSS), .G(I_2371_S), .S(I_1184_D));
  nor auto_914(I_524_D, I_493_G, I_1211_D);
    generic_pmos I_525(.D(I_525_D), .G(I_1211_D), .S(VDD));
    generic_pmos I_493(.D(I_524_D), .G(I_493_G), .S(I_525_D));
    generic_nmos I_492(.D(VSS), .G(I_493_G), .S(I_524_D));
    generic_nmos I_524(.D(I_524_D), .G(I_1211_D), .S(VSS));
  not auto_931(I_616_S, I_2649_D);
    generic_pmos I_585(.D(I_616_S), .G(I_2649_D), .S(VDD));
    generic_nmos I_616(.D(VSS), .G(I_2649_D), .S(I_616_S));
  not auto_909(I_461_S, I_2809_D);
    generic_pmos I_461(.D(VDD), .G(I_2809_D), .S(I_461_S));
    generic_nmos I_428(.D(I_461_S), .G(I_2809_D), .S(VSS));
  nand auto_912(I_553_D, I_524_D, I_3065_D, I_2905_D);
    generic_pmos I_489(.D(I_553_D), .G(I_524_D), .S(VDD));
    generic_pmos I_521(.D(VDD), .G(I_3065_D), .S(I_553_D));
    generic_pmos I_553(.D(I_553_D), .G(I_2905_D), .S(VDD));
    generic_nmos I_488(.D(I_553_D), .G(I_524_D), .S(I_520_D));
    generic_nmos I_520(.D(I_520_D), .G(I_3065_D), .S(I_552_D));
    generic_nmos I_552(.D(I_552_D), .G(I_2905_D), .S(VSS));
  not auto_932(I_618_S, I_553_D);
    generic_pmos I_587(.D(I_618_S), .G(I_553_D), .S(VDD));
    generic_nmos I_618(.D(VSS), .G(I_553_D), .S(I_618_S));
  nand auto_428(I_235_D, I_458_S, I_297_S, I_618_S);
    generic_pmos I_171(.D(I_235_D), .G(I_458_S), .S(VDD));
    generic_pmos I_203(.D(VDD), .G(I_297_S), .S(I_235_D));
    generic_pmos I_235(.D(I_235_D), .G(I_618_S), .S(VDD));
    generic_nmos I_170(.D(I_235_D), .G(I_458_S), .S(I_202_D));
    generic_nmos I_202(.D(I_202_D), .G(I_297_S), .S(I_234_D));
    generic_nmos I_234(.D(I_234_D), .G(I_618_S), .S(VSS));
  nand auto_739(I_395_D, I_297_S, I_618_S, I_461_S);
    generic_pmos I_331(.D(I_395_D), .G(I_618_S), .S(VDD));
    generic_pmos I_363(.D(VDD), .G(I_297_S), .S(I_395_D));
    generic_pmos I_395(.D(I_395_D), .G(I_461_S), .S(VDD));
    generic_nmos I_330(.D(I_395_D), .G(I_618_S), .S(I_362_D));
    generic_nmos I_362(.D(I_362_D), .G(I_297_S), .S(I_394_D));
    generic_nmos I_394(.D(I_394_D), .G(I_461_S), .S(VSS));
  nand auto_913(I_555_D, I_458_S, I_616_S, I_618_S);
    generic_pmos I_491(.D(I_555_D), .G(I_458_S), .S(VDD));
    generic_pmos I_523(.D(VDD), .G(I_616_S), .S(I_555_D));
    generic_pmos I_555(.D(I_555_D), .G(I_618_S), .S(VDD));
    generic_nmos I_490(.D(I_555_D), .G(I_458_S), .S(I_522_D));
    generic_nmos I_522(.D(I_522_D), .G(I_616_S), .S(I_554_D));
    generic_nmos I_554(.D(I_554_D), .G(I_618_S), .S(VSS));
  nand auto_938(I_715_D, I_616_S, I_461_S, I_618_S);
    generic_pmos I_651(.D(I_715_D), .G(I_461_S), .S(VDD));
    generic_pmos I_683(.D(VDD), .G(I_616_S), .S(I_715_D));
    generic_pmos I_715(.D(I_715_D), .G(I_618_S), .S(VDD));
    generic_nmos I_650(.D(I_715_D), .G(I_461_S), .S(I_682_D));
    generic_nmos I_682(.D(I_682_D), .G(I_616_S), .S(I_714_D));
    generic_nmos I_714(.D(I_714_D), .G(I_618_S), .S(VSS));
  not auto_907(I_458_S, I_461_S);
    generic_pmos I_427(.D(I_458_S), .G(I_461_S), .S(VDD));
    generic_nmos I_458(.D(VSS), .G(I_461_S), .S(I_458_S));
  not auto_670(I_297_S, I_616_S);
    generic_pmos I_297(.D(VDD), .G(I_616_S), .S(I_297_S));
    generic_nmos I_264(.D(I_297_S), .G(I_616_S), .S(VSS));
  not auto_952(I_713_S, I_235_D);
    generic_pmos I_713(.D(VDD), .G(I_235_D), .S(I_713_S));
    generic_nmos I_712(.D(VSS), .G(I_235_D), .S(I_713_S));

// ********************************************************************************************************

// Video attributes: 3 bit x 4 registers
// (Reg 0=ink,1=style,2=paper,3=mode)

// Reg 0 INK

// Bit 0 Red
// Chain Ka - on bit 0 of data bus
// D-Type Flip Flop D: I_2169_D Q: I_1029_D ~Q: I_1061_D with Asynchronous SET I_1187_S Rising Clock: I_715_D
// D-Type latch D: I_2169_D ~Q: I_1093_S Q: I_1063_D with Asynchronous SET I_1187_S Clock: I_715_D
// 2:1 Mux with single control: Inputs: I_1063_D, I_2169_D Output: I_1095_D Control: I_715_D
  generic_cmos pass_4(.gn(I_715_D), .gp(I_1097_S), .p1(I_1063_D), .p2(I_1095_D));
    generic_pmos I_1063(.D(I_1063_D), .G(I_1097_S), .S(I_1095_D));
    generic_nmos I_1062(.D(I_1063_D), .G(I_715_D), .S(I_1095_D));
  generic_cmos pass_8(.gn(I_1097_S), .gp(I_715_D), .p1(I_1095_D), .p2(I_2169_D));
    generic_pmos I_1095(.D(I_1095_D), .G(I_715_D), .S(I_2169_D));
    generic_nmos I_1094(.D(I_1095_D), .G(I_1097_S), .S(I_2169_D));
  not auto_300(I_1093_S, I_1095_D);
    generic_pmos I_1031(.D(VDD), .G(I_1095_D), .S(I_1093_S));
    generic_nmos I_1030(.D(VSS), .G(I_1095_D), .S(I_1093_S));
  nand auto_985(I_1063_D, I_1093_S, I_1187_S);
    generic_pmos I_967(.D(VDD), .G(I_1187_S), .S(I_1063_D));
    generic_pmos I_999(.D(I_1063_D), .G(I_1093_S), .S(VDD));
    generic_nmos I_966(.D(I_1063_D), .G(I_1187_S), .S(I_998_D));
    generic_nmos I_998(.D(I_998_D), .G(I_1093_S), .S(VSS));
// D-Type latch D: I_1093_S ~Q: I_1029_D Q: I_1061_D with Asynchronous RESET I_1187_S Clock: I_715_D
// 2:1 Mux with single control: Inputs: I_1061_D, I_1093_S Output: I_1093_D Control: I_715_D
  generic_cmos pass_3(.gn(I_1097_S), .gp(I_715_D), .p1(I_1061_D), .p2(I_1093_D));
    generic_pmos I_1061(.D(I_1061_D), .G(I_715_D), .S(I_1093_D));
    generic_nmos I_1060(.D(I_1061_D), .G(I_1097_S), .S(I_1093_D));
  generic_cmos pass_7(.gn(I_715_D), .gp(I_1097_S), .p1(I_1093_D), .p2(I_1093_S));
    generic_pmos I_1093(.D(I_1093_D), .G(I_1097_S), .S(I_1093_S));
    generic_nmos I_1092(.D(I_1093_D), .G(I_715_D), .S(I_1093_S));
  nand auto_299(I_1029_D, I_1093_D, I_1187_S);
    generic_pmos I_1029(.D(I_1029_D), .G(I_1093_D), .S(VDD));
    generic_pmos I_997(.D(VDD), .G(I_1187_S), .S(I_1029_D));
    generic_nmos I_1028(.D(I_1028_D), .G(I_1093_D), .S(I_1029_D));
    generic_nmos I_996(.D(VSS), .G(I_1187_S), .S(I_1028_D));
  not auto_984(I_1061_D, I_1029_D);
    generic_pmos I_965(.D(I_1061_D), .G(I_1029_D), .S(VDD));
    generic_nmos I_964(.D(I_1061_D), .G(I_1029_D), .S(VSS));

// Bit 1 Green
// Chain J - on bit 1 of data bus
// D-Type Flip Flop D: I_2329_D Q: I_1189_D ~Q: I_1221_D with Asynchronous SET I_1187_S Rising Clock: I_715_D
// D-Type latch D: I_2329_D ~Q: I_1253_S Q: I_1223_D with Asynchronous SET I_1187_S Clock: I_715_D
// 2:1 Mux with single control: Inputs: I_1223_D, I_2329_D Output: I_1255_D Control: I_715_D
  generic_cmos pass_14(.gn(I_715_D), .gp(I_1097_S), .p1(I_1223_D), .p2(I_1255_D));
    generic_pmos I_1223(.D(I_1223_D), .G(I_1097_S), .S(I_1255_D));
    generic_nmos I_1222(.D(I_1223_D), .G(I_715_D), .S(I_1255_D));
  generic_cmos pass_25(.gn(I_1097_S), .gp(I_715_D), .p1(I_1255_D), .p2(I_2329_D));
    generic_pmos I_1255(.D(I_1255_D), .G(I_715_D), .S(I_2329_D));
    generic_nmos I_1254(.D(I_1255_D), .G(I_1097_S), .S(I_2329_D));
  not auto_332(I_1253_S, I_1255_D);
    generic_pmos I_1191(.D(VDD), .G(I_1255_D), .S(I_1253_S));
    generic_nmos I_1190(.D(VSS), .G(I_1255_D), .S(I_1253_S));
  nand auto_314(I_1223_D, I_1187_S, I_1253_S);
    generic_pmos I_1127(.D(VDD), .G(I_1187_S), .S(I_1223_D));
    generic_pmos I_1159(.D(I_1223_D), .G(I_1253_S), .S(VDD));
    generic_nmos I_1126(.D(I_1223_D), .G(I_1187_S), .S(I_1158_D));
    generic_nmos I_1158(.D(I_1158_D), .G(I_1253_S), .S(VSS));
// D-Type latch D: I_1253_S ~Q: I_1189_D Q: I_1221_D with Asynchronous RESET I_1187_S Clock: I_715_D
// 2:1 Mux with single control: Inputs: I_1221_D, I_1253_S Output: I_1253_D Control: I_715_D
  generic_cmos pass_13(.gn(I_1097_S), .gp(I_715_D), .p1(I_1221_D), .p2(I_1253_D));
    generic_pmos I_1221(.D(I_1221_D), .G(I_715_D), .S(I_1253_D));
    generic_nmos I_1220(.D(I_1221_D), .G(I_1097_S), .S(I_1253_D));
  generic_cmos pass_24(.gn(I_715_D), .gp(I_1097_S), .p1(I_1253_D), .p2(I_1253_S));
    generic_pmos I_1253(.D(I_1253_D), .G(I_1097_S), .S(I_1253_S));
    generic_nmos I_1252(.D(I_1253_D), .G(I_715_D), .S(I_1253_S));
  nand auto_325(I_1189_D, I_1187_S, I_1253_D);
    generic_pmos I_1157(.D(VDD), .G(I_1187_S), .S(I_1189_D));
    generic_pmos I_1189(.D(I_1189_D), .G(I_1253_D), .S(VDD));
    generic_nmos I_1188(.D(I_1188_D), .G(I_1253_D), .S(I_1189_D));
    generic_nmos I_1156(.D(VSS), .G(I_1187_S), .S(I_1188_D));
  not auto_313(I_1221_D, I_1189_D);
    generic_pmos I_1125(.D(I_1221_D), .G(I_1189_D), .S(VDD));
    generic_nmos I_1124(.D(I_1221_D), .G(I_1189_D), .S(VSS));

// Bit 2 Blue
// Chain L - on Bit 2 of data bus
// D-Type Flip Flop D: I_1415_S Q: I_1349_D ~Q: I_1381_D with Asynchronous SET I_1187_S Rising Clock: I_715_D
// D-Type latch D: I_1415_S ~Q: I_1413_S Q: I_1383_D with Asynchronous SET I_1187_S Clock: I_715_D
// 2:1 Mux with single control: Inputs: I_1383_D, I_1415_S Output: I_1415_D Control: I_715_D
  generic_cmos pass_36(.gn(I_715_D), .gp(I_1097_S), .p1(I_1383_D), .p2(I_1415_D));
    generic_pmos I_1383(.D(I_1383_D), .G(I_1097_S), .S(I_1415_D));
    generic_nmos I_1382(.D(I_1383_D), .G(I_715_D), .S(I_1415_D));
  generic_cmos pass_45(.gn(I_1097_S), .gp(I_715_D), .p1(I_1415_D), .p2(I_1415_S));
    generic_pmos I_1415(.D(I_1415_D), .G(I_715_D), .S(I_1415_S));
    generic_nmos I_1414(.D(I_1415_D), .G(I_1097_S), .S(I_1415_S));
  not auto_362(I_1413_S, I_1415_D);
    generic_pmos I_1351(.D(VDD), .G(I_1415_D), .S(I_1413_S));
    generic_nmos I_1350(.D(VSS), .G(I_1415_D), .S(I_1413_S));
  nand auto_344(I_1383_D, I_1187_S, I_1413_S);
    generic_pmos I_1287(.D(VDD), .G(I_1187_S), .S(I_1383_D));
    generic_pmos I_1319(.D(I_1383_D), .G(I_1413_S), .S(VDD));
    generic_nmos I_1286(.D(I_1383_D), .G(I_1187_S), .S(I_1318_D));
    generic_nmos I_1318(.D(I_1318_D), .G(I_1413_S), .S(VSS));
// D-Type latch D: I_1413_S ~Q: I_1349_D Q: I_1381_D with Asynchronous RESET I_1187_S Clock: I_715_D
// 2:1 Mux with single control: Inputs: I_1381_D, I_1413_S Output: I_1413_D Control: I_715_D
  generic_cmos pass_35(.gn(I_1097_S), .gp(I_715_D), .p1(I_1381_D), .p2(I_1413_D));
    generic_pmos I_1381(.D(I_1381_D), .G(I_715_D), .S(I_1413_D));
    generic_nmos I_1380(.D(I_1381_D), .G(I_1097_S), .S(I_1413_D));
  generic_cmos pass_44(.gn(I_715_D), .gp(I_1097_S), .p1(I_1413_D), .p2(I_1413_S));
    generic_pmos I_1413(.D(I_1413_D), .G(I_1097_S), .S(I_1413_S));
    generic_nmos I_1412(.D(I_1413_D), .G(I_715_D), .S(I_1413_S));
  nand auto_357(I_1349_D, I_1187_S, I_1413_D);
    generic_pmos I_1317(.D(VDD), .G(I_1187_S), .S(I_1349_D));
    generic_pmos I_1349(.D(I_1349_D), .G(I_1413_D), .S(VDD));
    generic_nmos I_1348(.D(I_1348_D), .G(I_1413_D), .S(I_1349_D));
    generic_nmos I_1316(.D(VSS), .G(I_1187_S), .S(I_1348_D));
  not auto_343(I_1381_D, I_1349_D);
    generic_pmos I_1285(.D(I_1381_D), .G(I_1349_D), .S(VDD));
    generic_nmos I_1284(.D(I_1381_D), .G(I_1349_D), .S(VSS));

// Shared Driver
  not auto_308(I_1097_S, I_715_D);
    generic_pmos I_1097(.D(VDD), .G(I_715_D), .S(I_1097_S));
    generic_nmos I_1064(.D(I_1097_S), .G(I_715_D), .S(VSS));

// Reg 2 PAPER

// Bit 0 Red
// Chain Kb - on bit 0 of data bus
// D-Type Flip Flop D: I_2169_D Q: I_549_S ~Q: I_581_D with Asynchronous RESET I_1187_S Rising Clock: I_555_D
// D-Type latch D: I_2169_D ~Q: I_613_S Q: I_583_D with Asynchronous RESET I_1187_S Clock: I_555_D
// 2:1 Mux with single control: Inputs: I_583_D, I_2169_D Output: I_615_D Control: I_555_D
  generic_cmos pass_251(.gn(I_555_D), .gp(I_393_S), .p1(I_583_D), .p2(I_615_D));
    generic_pmos I_583(.D(I_583_D), .G(I_393_S), .S(I_615_D));
    generic_nmos I_582(.D(I_583_D), .G(I_555_D), .S(I_615_D));
  generic_cmos pass_256(.gn(I_393_S), .gp(I_555_D), .p1(I_615_D), .p2(I_2169_D));
    generic_pmos I_615(.D(I_615_D), .G(I_555_D), .S(I_2169_D));
    generic_nmos I_614(.D(I_615_D), .G(I_393_S), .S(I_2169_D));
  nand auto_923(I_613_S, I_1187_S, I_615_D);
    generic_pmos I_519(.D(VDD), .G(I_1187_S), .S(I_613_S));
    generic_pmos I_551(.D(I_613_S), .G(I_615_D), .S(VDD));
    generic_nmos I_550(.D(I_550_D), .G(I_615_D), .S(I_613_S));
    generic_nmos I_518(.D(VSS), .G(I_1187_S), .S(I_550_D));
  not auto_911(I_583_D, I_613_S);
    generic_pmos I_487(.D(I_583_D), .G(I_613_S), .S(VDD));
    generic_nmos I_486(.D(I_583_D), .G(I_613_S), .S(VSS));
// D-Type latch D: I_613_S ~Q: I_549_S Q: I_581_D with Asynchronous SET I_1187_S Clock: I_555_D
// 2:1 Mux with single control: Inputs: I_581_D, I_613_S Output: I_613_D Control: I_555_D
  generic_cmos pass_250(.gn(I_393_S), .gp(I_555_D), .p1(I_581_D), .p2(I_613_D));
    generic_pmos I_581(.D(I_581_D), .G(I_555_D), .S(I_613_D));
    generic_nmos I_580(.D(I_581_D), .G(I_393_S), .S(I_613_D));
  generic_cmos pass_255(.gn(I_555_D), .gp(I_393_S), .p1(I_613_D), .p2(I_613_S));
    generic_pmos I_613(.D(I_613_D), .G(I_393_S), .S(I_613_S));
    generic_nmos I_612(.D(I_613_D), .G(I_555_D), .S(I_613_S));
  not auto_926(I_549_S, I_613_D);
    generic_pmos I_549(.D(VDD), .G(I_613_D), .S(I_549_S));
    generic_nmos I_548(.D(VSS), .G(I_613_D), .S(I_549_S));
  nand auto_910(I_581_D, I_549_S, I_1187_S);
    generic_pmos I_485(.D(VDD), .G(I_1187_S), .S(I_581_D));
    generic_pmos I_517(.D(I_581_D), .G(I_549_S), .S(VDD));
    generic_nmos I_484(.D(I_581_D), .G(I_1187_S), .S(I_516_D));
    generic_nmos I_516(.D(I_516_D), .G(I_549_S), .S(VSS));

// Bit 1 Green
// Chain M on bit 1 of data bus
// D-Type Flip Flop D: I_2329_D Q: I_709_S ~Q: I_741_D with Asynchronous RESET I_1187_S Rising Clock: I_555_D
// D-Type latch D: I_2329_D ~Q: I_773_S Q: I_743_D with Asynchronous RESET I_1187_S Clock: I_555_D
// 2:1 Mux with single control: Inputs: I_743_D, I_2329_D Output: I_775_D Control: I_555_D
  generic_cmos pass_262(.gn(I_555_D), .gp(I_393_S), .p1(I_743_D), .p2(I_775_D));
    generic_pmos I_743(.D(I_743_D), .G(I_393_S), .S(I_775_D));
    generic_nmos I_742(.D(I_743_D), .G(I_555_D), .S(I_775_D));
  generic_cmos pass_269(.gn(I_393_S), .gp(I_555_D), .p1(I_775_D), .p2(I_2329_D));
    generic_pmos I_775(.D(I_775_D), .G(I_555_D), .S(I_2329_D));
    generic_nmos I_774(.D(I_775_D), .G(I_393_S), .S(I_2329_D));
  nand auto_945(I_773_S, I_1187_S, I_775_D);
    generic_pmos I_679(.D(VDD), .G(I_1187_S), .S(I_773_S));
    generic_pmos I_711(.D(I_773_S), .G(I_775_D), .S(VDD));
    generic_nmos I_710(.D(I_710_D), .G(I_775_D), .S(I_773_S));
    generic_nmos I_678(.D(VSS), .G(I_1187_S), .S(I_710_D));
  not auto_936(I_743_D, I_773_S);
    generic_pmos I_647(.D(I_743_D), .G(I_773_S), .S(VDD));
    generic_nmos I_646(.D(I_743_D), .G(I_773_S), .S(VSS));
// D-Type latch D: I_773_S ~Q: I_709_S Q: I_741_D with Asynchronous SET I_1187_S Clock: I_555_D
// 2:1 Mux with single control: Inputs: I_741_D, I_773_S Output: I_773_D Control: I_555_D
  generic_cmos pass_261(.gn(I_393_S), .gp(I_555_D), .p1(I_741_D), .p2(I_773_D));
    generic_pmos I_741(.D(I_741_D), .G(I_555_D), .S(I_773_D));
    generic_nmos I_740(.D(I_741_D), .G(I_393_S), .S(I_773_D));
  generic_cmos pass_268(.gn(I_555_D), .gp(I_393_S), .p1(I_773_D), .p2(I_773_S));
    generic_pmos I_773(.D(I_773_D), .G(I_393_S), .S(I_773_S));
    generic_nmos I_772(.D(I_773_D), .G(I_555_D), .S(I_773_S));
  not auto_951(I_709_S, I_773_D);
    generic_pmos I_709(.D(VDD), .G(I_773_D), .S(I_709_S));
    generic_nmos I_708(.D(VSS), .G(I_773_D), .S(I_709_S));
  nand auto_935(I_741_D, I_1187_S, I_709_S);
    generic_pmos I_645(.D(VDD), .G(I_1187_S), .S(I_741_D));
    generic_pmos I_677(.D(I_741_D), .G(I_709_S), .S(VDD));
    generic_nmos I_644(.D(I_741_D), .G(I_1187_S), .S(I_676_D));
    generic_nmos I_676(.D(I_676_D), .G(I_709_S), .S(VSS));

// Bit 2 Blue
// Chain N on bit 2 of data bus
// D-Type Flip Flop D: I_1415_S Q: I_869_S ~Q: I_901_D with Asynchronous RESET I_1187_S Rising Clock: I_555_D
// D-Type latch D: I_1415_S ~Q: I_933_S Q: I_903_D with Asynchronous RESET I_1187_S Clock: I_555_D
// 2:1 Mux with single control: Inputs: I_903_D, I_1415_S Output: I_935_D Control: I_555_D
  generic_cmos pass_277(.gn(I_555_D), .gp(I_393_S), .p1(I_903_D), .p2(I_935_D));
    generic_pmos I_903(.D(I_903_D), .G(I_393_S), .S(I_935_D));
    generic_nmos I_902(.D(I_903_D), .G(I_555_D), .S(I_935_D));
  generic_cmos pass_284(.gn(I_393_S), .gp(I_555_D), .p1(I_935_D), .p2(I_1415_S));
    generic_pmos I_935(.D(I_935_D), .G(I_555_D), .S(I_1415_S));
    generic_nmos I_934(.D(I_935_D), .G(I_393_S), .S(I_1415_S));
  nand auto_970(I_933_S, I_935_D, I_1187_S);
    generic_pmos I_839(.D(VDD), .G(I_1187_S), .S(I_933_S));
    generic_pmos I_871(.D(I_933_S), .G(I_935_D), .S(VDD));
    generic_nmos I_870(.D(I_870_D), .G(I_935_D), .S(I_933_S));
    generic_nmos I_838(.D(VSS), .G(I_1187_S), .S(I_870_D));
  not auto_959(I_903_D, I_933_S);
    generic_pmos I_807(.D(I_903_D), .G(I_933_S), .S(VDD));
    generic_nmos I_806(.D(I_903_D), .G(I_933_S), .S(VSS));
// D-Type latch D: I_933_S ~Q: I_869_S Q: I_901_D with Asynchronous SET I_1187_S Clock: I_555_D
// 2:1 Mux with single control: Inputs: I_901_D, I_933_S Output: I_933_D Control: I_555_D
  generic_cmos pass_276(.gn(I_393_S), .gp(I_555_D), .p1(I_901_D), .p2(I_933_D));
    generic_pmos I_901(.D(I_901_D), .G(I_555_D), .S(I_933_D));
    generic_nmos I_900(.D(I_901_D), .G(I_393_S), .S(I_933_D));
  generic_cmos pass_283(.gn(I_555_D), .gp(I_393_S), .p1(I_933_D), .p2(I_933_S));
    generic_pmos I_933(.D(I_933_D), .G(I_393_S), .S(I_933_S));
    generic_nmos I_932(.D(I_933_D), .G(I_555_D), .S(I_933_S));
  not auto_974(I_869_S, I_933_D);
    generic_pmos I_869(.D(VDD), .G(I_933_D), .S(I_869_S));
    generic_nmos I_868(.D(VSS), .G(I_933_D), .S(I_869_S));
  nand auto_958(I_901_D, I_869_S, I_1187_S);
    generic_pmos I_805(.D(VDD), .G(I_1187_S), .S(I_901_D));
    generic_pmos I_837(.D(I_901_D), .G(I_869_S), .S(VDD));
    generic_nmos I_804(.D(I_901_D), .G(I_1187_S), .S(I_836_D));
    generic_nmos I_836(.D(I_836_D), .G(I_869_S), .S(VSS));

// Shared Driver
  not auto_885(I_393_S, I_555_D);
    generic_pmos I_393(.D(VDD), .G(I_555_D), .S(I_393_S));
    generic_nmos I_392(.D(VSS), .G(I_555_D), .S(I_393_S));

// Reg 1 STYLE

// Bit 0 Alt or Std Charset?

// Note: Output is taken from "!Q" output so logic is reversed here. (0=std 1=alt from user -> 1=std 0=alt here)

// Chain I - on Bit 0 of data bus 

// D-Type Flip Flop D: I_2169_D Q: I_69_S ~Q: I_101_D with Asynchronous RESET I_1187_S Rising Clock: I_395_D
// D-Type latch D: I_2169_D ~Q: I_133_S Q: I_103_D with Asynchronous RESET I_1187_S Clock: I_395_D
// 2:1 Mux with single control: Inputs: I_103_D, I_2169_D Output: I_135_D Control: I_395_D
  generic_cmos pass_2(.gn(I_395_D), .gp(I_329_D), .p1(I_103_D), .p2(I_135_D));
    generic_pmos I_103(.D(I_103_D), .G(I_329_D), .S(I_135_D));
    generic_nmos I_102(.D(I_103_D), .G(I_395_D), .S(I_135_D));
  generic_cmos pass_34(.gn(I_329_D), .gp(I_395_D), .p1(I_135_D), .p2(I_2169_D));
    generic_pmos I_135(.D(I_135_D), .G(I_395_D), .S(I_2169_D));
    generic_nmos I_134(.D(I_135_D), .G(I_329_D), .S(I_2169_D));
  nand auto_878(I_133_S, I_1187_S, I_135_D);
    generic_pmos I_39(.D(VDD), .G(I_1187_S), .S(I_133_S));
    generic_pmos I_71(.D(I_133_S), .G(I_135_D), .S(VDD));
    generic_nmos I_70(.D(I_70_D), .G(I_135_D), .S(I_133_S));
    generic_nmos I_38(.D(VSS), .G(I_1187_S), .S(I_70_D));
  not auto_948(I_103_D, I_133_S);
    generic_pmos I_7(.D(I_103_D), .G(I_133_S), .S(VDD));
    generic_nmos I_6(.D(I_103_D), .G(I_133_S), .S(VSS));
// chain I part 2
// D-Type latch D: I_133_S ~Q: I_69_S Q: I_101_D with Asynchronous SET I_1187_S Clock: I_395_D
// 2:1 Mux with single control: Inputs: I_101_D, I_133_S Output: I_133_D Control: I_395_D
  generic_cmos pass_1(.gn(I_329_D), .gp(I_395_D), .p1(I_101_D), .p2(I_133_D));
    generic_pmos I_101(.D(I_101_D), .G(I_395_D), .S(I_133_D));
    generic_nmos I_100(.D(I_101_D), .G(I_329_D), .S(I_133_D));
  generic_cmos pass_33(.gn(I_395_D), .gp(I_329_D), .p1(I_133_D), .p2(I_133_S));
    generic_pmos I_133(.D(I_133_D), .G(I_329_D), .S(I_133_S));
    generic_nmos I_132(.D(I_133_D), .G(I_395_D), .S(I_133_S));
  not auto_946(I_69_S, I_133_D);
    generic_pmos I_69(.D(VDD), .G(I_133_D), .S(I_69_S));
    generic_nmos I_68(.D(VSS), .G(I_133_D), .S(I_69_S));
  nand auto_831(I_101_D, I_69_S, I_1187_S);
    generic_pmos I_37(.D(I_101_D), .G(I_69_S), .S(VDD));
    generic_pmos I_5(.D(VDD), .G(I_1187_S), .S(I_101_D));
    generic_nmos I_4(.D(I_101_D), .G(I_1187_S), .S(I_36_D));
    generic_nmos I_36(.D(I_36_D), .G(I_69_S), .S(VSS));

// Bit 1 Double or Standard height text?

// Note: Output is taken from "!Q" output so logic is reversed here. (0=std 1=dbl from user -> 1=std 0=dbl here)

// Chain H - on Bit 1 of data bus
// D-Type Flip Flop D: I_2329_D Q: I_229_S ~Q: I_3649_G with Asynchronous RESET I_1187_S Rising Clock: I_395_D
// D-Type latch D: I_2329_D ~Q: I_293_S Q: I_263_D with Asynchronous RESET I_1187_S Clock: I_395_D
// 2:1 Mux with single control: Inputs: I_263_D, I_2329_D Output: I_295_D Control: I_395_D
  generic_cmos pass_129(.gn(I_395_D), .gp(I_329_D), .p1(I_263_D), .p2(I_295_D));
    generic_pmos I_263(.D(I_263_D), .G(I_329_D), .S(I_295_D));
    generic_nmos I_262(.D(I_263_D), .G(I_395_D), .S(I_295_D));
  generic_cmos pass_161(.gn(I_329_D), .gp(I_395_D), .p1(I_295_D), .p2(I_2329_D));
    generic_pmos I_295(.D(I_295_D), .G(I_395_D), .S(I_2329_D));
    generic_nmos I_294(.D(I_295_D), .G(I_329_D), .S(I_2329_D));
  nand auto_497(I_293_S, I_1187_S, I_295_D);
    generic_pmos I_199(.D(VDD), .G(I_1187_S), .S(I_293_S));
    generic_pmos I_231(.D(I_293_S), .G(I_295_D), .S(VDD));
    generic_nmos I_230(.D(I_230_D), .G(I_295_D), .S(I_293_S));
    generic_nmos I_198(.D(VSS), .G(I_1187_S), .S(I_230_D));
  not auto_423(I_263_D, I_293_S);
    generic_pmos I_167(.D(I_263_D), .G(I_293_S), .S(VDD));
    generic_nmos I_166(.D(I_263_D), .G(I_293_S), .S(VSS));
// D-Type latch D: I_293_S ~Q: I_229_S Q: I_3649_G with Asynchronous SET I_1187_S Clock: I_395_D
// 2:1 Mux with single control: Inputs: I_3649_G, I_293_S Output: I_293_D Control: I_395_D
  generic_cmos pass_128(.gn(I_329_D), .gp(I_395_D), .p1(I_3649_G), .p2(I_293_D));
    generic_pmos I_261(.D(I_3649_G), .G(I_395_D), .S(I_293_D));
    generic_nmos I_260(.D(I_3649_G), .G(I_329_D), .S(I_293_D));
  generic_cmos pass_160(.gn(I_395_D), .gp(I_329_D), .p1(I_293_D), .p2(I_293_S));
    generic_pmos I_293(.D(I_293_D), .G(I_329_D), .S(I_293_S));
    generic_nmos I_292(.D(I_293_D), .G(I_395_D), .S(I_293_S));
  not auto_553(I_229_S, I_293_D);
    generic_pmos I_229(.D(VDD), .G(I_293_D), .S(I_229_S));
    generic_nmos I_228(.D(VSS), .G(I_293_D), .S(I_229_S));
  nand auto_420(I_3649_G, I_1187_S, I_229_S);
    generic_pmos I_165(.D(VDD), .G(I_1187_S), .S(I_3649_G));
    generic_pmos I_197(.D(I_3649_G), .G(I_229_S), .S(VDD));
    generic_nmos I_164(.D(I_3649_G), .G(I_1187_S), .S(I_196_D));
    generic_nmos I_196(.D(I_196_D), .G(I_229_S), .S(VSS));

// Bit 2 Flashing enable?

// Flashing mode selector
// Chain Z - On bit 2 of data bus
// D-Type Flip Flop D: I_1415_S Q: I_389_S ~Q: I_421_D with Asynchronous RESET I_1187_S Rising Clock: I_395_D
// D-Type latch D: I_1415_S ~Q: I_453_S Q: I_423_D with Asynchronous RESET I_1187_S Clock: I_395_D
// 2:1 Mux with single control: Inputs: I_423_D, I_1415_S Output: I_455_D Control: I_395_D
  generic_cmos pass_237(.gn(I_395_D), .gp(I_329_D), .p1(I_423_D), .p2(I_455_D));
    generic_pmos I_423(.D(I_423_D), .G(I_329_D), .S(I_455_D));
    generic_nmos I_422(.D(I_423_D), .G(I_395_D), .S(I_455_D));
  generic_cmos pass_244(.gn(I_329_D), .gp(I_395_D), .p1(I_455_D), .p2(I_1415_S));
    generic_pmos I_455(.D(I_455_D), .G(I_395_D), .S(I_1415_S));
    generic_nmos I_454(.D(I_455_D), .G(I_329_D), .S(I_1415_S));
  nand auto_805(I_453_S, I_1187_S, I_455_D);
    generic_pmos I_359(.D(VDD), .G(I_1187_S), .S(I_453_S));
    generic_pmos I_391(.D(I_453_S), .G(I_455_D), .S(VDD));
    generic_nmos I_390(.D(I_390_D), .G(I_455_D), .S(I_453_S));
    generic_nmos I_358(.D(VSS), .G(I_1187_S), .S(I_390_D));
  not auto_732(I_423_D, I_453_S);
    generic_pmos I_327(.D(I_423_D), .G(I_453_S), .S(VDD));
    generic_nmos I_326(.D(I_423_D), .G(I_453_S), .S(VSS));
// D-Type latch D: I_453_S ~Q: I_389_S Q: I_421_D with Asynchronous SET I_1187_S Clock: I_395_D
// 2:1 Mux with single control: Inputs: I_421_D, I_453_S Output: I_453_D Control: I_395_D
  generic_cmos pass_236(.gn(I_329_D), .gp(I_395_D), .p1(I_421_D), .p2(I_453_D));
    generic_pmos I_421(.D(I_421_D), .G(I_395_D), .S(I_453_D));
    generic_nmos I_420(.D(I_421_D), .G(I_329_D), .S(I_453_D));
  generic_cmos pass_243(.gn(I_395_D), .gp(I_329_D), .p1(I_453_D), .p2(I_453_S));
    generic_pmos I_453(.D(I_453_D), .G(I_329_D), .S(I_453_S));
    generic_nmos I_452(.D(I_453_D), .G(I_395_D), .S(I_453_S));
  not auto_876(I_389_S, I_453_D);
    generic_pmos I_389(.D(VDD), .G(I_453_D), .S(I_389_S));
    generic_nmos I_388(.D(VSS), .G(I_453_D), .S(I_389_S));
  nand auto_727(I_421_D, I_1187_S, I_389_S);
    generic_pmos I_325(.D(VDD), .G(I_1187_S), .S(I_421_D));
    generic_pmos I_357(.D(I_421_D), .G(I_389_S), .S(VDD));
    generic_nmos I_324(.D(I_421_D), .G(I_1187_S), .S(I_356_D));
    generic_nmos I_356(.D(I_356_D), .G(I_389_S), .S(VSS));
// Shared Driver
  not auto_737(I_329_D, I_395_D);
    generic_pmos I_329(.D(I_329_D), .G(I_395_D), .S(VDD));
    generic_nmos I_328(.D(I_329_D), .G(I_395_D), .S(VSS));

// Reg 3 MODE

// Bit 0 Known unused (and no latch/flip flop found)

// Bit 1 50Hz/60Hz selector
// Latch Unnamed 2 - On bit 1 of data bus: Single latch only! No set/reset.
// D-Type latch D: I_2329_D ~Q: I_969_D Q: I_1033_D Falling Clock: I_713_S
// 2:1 Mux with single control: Inputs: I_2329_D, I_1033_D Output: I_937_D Control: I_713_S
  generic_cmos pass_278(.gn(I_713_S), .gp(I_779_S), .p1(I_2329_D), .p2(I_937_D));
    generic_pmos I_905(.D(I_2329_D), .G(I_779_S), .S(I_937_D));
    generic_nmos I_904(.D(I_2329_D), .G(I_713_S), .S(I_937_D));
  generic_cmos pass_285(.gn(I_779_S), .gp(I_713_S), .p1(I_937_D), .p2(I_1033_D));
    generic_pmos I_937(.D(I_937_D), .G(I_713_S), .S(I_1033_D));
    generic_nmos I_936(.D(I_937_D), .G(I_779_S), .S(I_1033_D));
  not auto_986(I_969_D, I_937_D);
    generic_pmos I_969(.D(I_969_D), .G(I_937_D), .S(VDD));
    generic_nmos I_968(.D(I_969_D), .G(I_937_D), .S(VSS));
  not auto_291(I_1033_D, I_969_D); // NMOS strength = 2
    generic_pmos I_1001(.D(VDD), .G(I_969_D), .S(I_1033_D));
    generic_pmos I_1033(.D(I_1033_D), .G(I_969_D), .S(VDD));
    generic_nmos I_1000(.D(VSS), .G(I_969_D), .S(I_1033_D));
    generic_nmos I_1032(.D(I_1033_D), .G(I_969_D), .S(VSS));

// Bit 2 Text/Graphics mode
// Latch Unnamed 1 - On bit 2 of data bus: Single latch only! No set/reset.
// D-Type latch D: I_1415_S ~Q: I_809_D Q: I_873_D Falling Clock: I_713_S 
// 2:1 Mux with single control: Inputs: I_1415_S, I_873_D Output: I_777_D Control: I_713_S
  generic_cmos pass_263(.gn(I_713_S), .gp(I_779_S), .p1(I_1415_S), .p2(I_777_D));
    generic_pmos I_745(.D(I_1415_S), .G(I_779_S), .S(I_777_D));
    generic_nmos I_744(.D(I_1415_S), .G(I_713_S), .S(I_777_D));
  generic_cmos pass_270(.gn(I_779_S), .gp(I_713_S), .p1(I_777_D), .p2(I_873_D));
    generic_pmos I_777(.D(I_777_D), .G(I_713_S), .S(I_873_D));
    generic_nmos I_776(.D(I_777_D), .G(I_779_S), .S(I_873_D));
  not auto_960(I_809_D, I_777_D);
    generic_pmos I_809(.D(I_809_D), .G(I_777_D), .S(VDD));
    generic_nmos I_808(.D(I_809_D), .G(I_777_D), .S(VSS));
  not auto_971(I_873_D, I_809_D); // NMOS strength = 2
    generic_pmos I_841(.D(VDD), .G(I_809_D), .S(I_873_D));
    generic_pmos I_873(.D(I_873_D), .G(I_809_D), .S(VDD));
    generic_nmos I_840(.D(VSS), .G(I_809_D), .S(I_873_D));
    generic_nmos I_872(.D(I_873_D), .G(I_809_D), .S(VSS));

// Shared Driver
  not auto_957(I_779_S, I_713_S);  
    generic_pmos I_779(.D(VDD), .G(I_713_S), .S(I_779_S));
    generic_nmos I_746(.D(I_779_S), .G(I_713_S), .S(VSS));

// ********************************************************************************************************

// Memory address calculation for video Address Phase 2 (See Page 13)
// ... in which we look up the charset bit pattern for row 0..7 of the text character we acquired in Phase 1
//
// Need to see ULA V2 documentation for full explanation and justification ...
//
// VADDR2-L goes to DRAM multiplexer gates "G"
// is derived from 3 bits of vertical counter (maybe divided by 2 for dbl height by a 2:1 mux) in (A0..A2)
// and 5 bits from the data bus latch (lower 5 bits of ASCII code) in (A3..A7)

// VADDR2-H goes to DRAM multiplexer gates "Q"
// is derived from three fixed bits in (A15,A14,A12=1,0,1)
// from 3 bits relating to state of text/hires and alt/std attributes (logic block) in (A13,A11,A10)
// and 2 remaining bits of the data bus latch (upper 2 bits of ASCII code) in (A8..A9)

// This gate creates drive signals for the DRAM mux to drive gate sets "K" and "M" (Double height /2 circuit)
  not auto_811(I_3649_D, I_3649_G); // NMOS strength = 2
    generic_pmos I_3617(.D(VDD), .G(I_3649_G), .S(I_3649_D));
    generic_pmos I_3649(.D(I_3649_D), .G(I_3649_G), .S(VDD));
    generic_nmos I_3616(.D(VSS), .G(I_3649_G), .S(I_3649_D));
    generic_nmos I_3648(.D(I_3649_D), .G(I_3649_G), .S(VSS));

// Was: Gate Set M,K,J,I: -- 3 x 2:1 Mux to divide the vertical counter by 2 (shift 1 bit right) on I_3649_D (double height text)

// Set of 3 NAND gates (I) in order RC0..RC2]
  nand auto_886(I_3973_D, I_3911_D, I_3909_D);
    generic_pmos I_3941(.D(VDD), .G(I_3911_D), .S(I_3973_D));
    generic_pmos I_3973(.D(I_3973_D), .G(I_3909_D), .S(VDD));
    generic_nmos I_3940(.D(I_3973_D), .G(I_3909_D), .S(I_3972_D));
    generic_nmos I_3972(.D(I_3972_D), .G(I_3911_D), .S(VSS));
  nand auto_859(I_3767_G, I_3745_D, I_3809_D);
    generic_pmos I_3841(.D(VDD), .G(I_3745_D), .S(I_3767_G));
    generic_pmos I_3873(.D(I_3767_G), .G(I_3809_D), .S(VDD));
    generic_nmos I_3872(.D(I_3872_D), .G(I_3809_D), .S(I_3767_G));
    generic_nmos I_3840(.D(VSS), .G(I_3745_D), .S(I_3872_D));
  nand auto_860(I_3906_D, I_3747_D, I_3811_D);
    generic_pmos I_3843(.D(VDD), .G(I_3747_D), .S(I_3906_D));
    generic_pmos I_3875(.D(I_3906_D), .G(I_3811_D), .S(VDD));
    generic_nmos I_3874(.D(I_3874_D), .G(I_3811_D), .S(I_3906_D));
    generic_nmos I_3842(.D(VSS), .G(I_3747_D), .S(I_3874_D));
// Set of 3 NOT gates (M) that drive (J) in order RC0..RC2
  not auto_861(I_3845_D, I_3649_D);
    generic_pmos I_3845(.D(I_3845_D), .G(I_3649_D), .S(VDD));
    generic_nmos I_3844(.D(I_3845_D), .G(I_3649_D), .S(VSS));
  not auto_822(I_3681_D, I_3649_D);
    generic_pmos I_3681(.D(I_3681_D), .G(I_3649_D), .S(VDD));
    generic_nmos I_3680(.D(I_3681_D), .G(I_3649_D), .S(VSS));
  not auto_823(I_3683_D, I_3649_D);
    generic_pmos I_3683(.D(I_3683_D), .G(I_3649_D), .S(VDD));
    generic_nmos I_3682(.D(I_3683_D), .G(I_3649_D), .S(VSS));
// Set of 3 NAND gates (J) that drive (I) in order RC0..RC2]
  // VC0
  nand auto_873(I_3911_D, I_3845_D, I_3911_G);
    generic_pmos I_3879(.D(VDD), .G(I_3845_D), .S(I_3911_D));
    generic_pmos I_3911(.D(I_3911_D), .G(I_3911_G), .S(VDD));
    generic_nmos I_3910(.D(I_3910_D), .G(I_3911_G), .S(I_3911_D));
    generic_nmos I_3878(.D(VSS), .G(I_3845_D), .S(I_3910_D));
  // VC1
  nand auto_848(I_3809_D, I_3681_D, I_2631_S);
    generic_pmos I_3777(.D(VDD), .G(I_2631_S), .S(I_3809_D));
    generic_pmos I_3809(.D(I_3809_D), .G(I_3681_D), .S(VDD));
    generic_nmos I_3808(.D(I_3808_D), .G(I_2631_S), .S(I_3809_D));
    generic_nmos I_3776(.D(VSS), .G(I_3681_D), .S(I_3808_D));
  // VC2
  nand auto_849(I_3811_D, I_3683_D, I_2791_S);
    generic_pmos I_3779(.D(VDD), .G(I_2791_S), .S(I_3811_D));
    generic_pmos I_3811(.D(I_3811_D), .G(I_3683_D), .S(VDD));
    generic_nmos I_3810(.D(I_3810_D), .G(I_2791_S), .S(I_3811_D));
    generic_nmos I_3778(.D(VSS), .G(I_3683_D), .S(I_3810_D));
// Set of 3 NAND gates (K) that drive (I) in order RC0..RC2]
  // VC1  
  nand auto_872(I_3909_D, I_3649_D, I_2631_S);
    generic_pmos I_3877(.D(VDD), .G(I_3649_D), .S(I_3909_D));
    generic_pmos I_3909(.D(I_3909_D), .G(I_2631_S), .S(VDD));
    generic_nmos I_3908(.D(I_3908_D), .G(I_2631_S), .S(I_3909_D));
    generic_nmos I_3876(.D(VSS), .G(I_3649_D), .S(I_3908_D));
  // VC2
  nand auto_838(I_3745_D, I_3649_D, I_2791_S);
    generic_pmos I_3713(.D(VDD), .G(I_3649_D), .S(I_3745_D));
    generic_pmos I_3745(.D(I_3745_D), .G(I_2791_S), .S(VDD));
    generic_nmos I_3744(.D(I_3744_D), .G(I_2791_S), .S(I_3745_D));
    generic_nmos I_3712(.D(VSS), .G(I_3649_D), .S(I_3744_D));
  // NOT of !VC3 = VC3
  nand auto_839(I_3747_D, I_1741_S, I_3649_D);
    generic_pmos I_3715(.D(VDD), .G(I_3649_D), .S(I_3747_D));
    generic_pmos I_3747(.D(I_3747_D), .G(I_1741_S), .S(VDD));
    generic_nmos I_3746(.D(I_3746_D), .G(I_1741_S), .S(I_3747_D));
    generic_nmos I_3714(.D(VSS), .G(I_3649_D), .S(I_3746_D));

// Logic for the 3-bits above ... "A10" here.
// AND-OR-Invert: Verilog called this "and + nor" conjoined. See diagram. First 4 transistors are a NAND
  and auto_482(auto_net_2, I_101_D, I_873_D);
    generic_pmos I_1963(.D(I_1995_S), .G(I_101_D), .S(VDD));
    generic_pmos I_1995(.D(VDD), .G(I_873_D), .S(I_1995_S));
    generic_nmos I_1962(.D(I_1962_D), .G(I_101_D), .S(I_1994_D));
    generic_nmos I_1994(.D(I_1994_D), .G(I_873_D), .S(VSS));
// These two transistors adjust the NAND output -- half a NOR?
  nor auto_481(I_1962_D, I_1899_S, auto_net_2);
    generic_pmos I_1931(.D(I_1962_D), .G(I_1899_S), .S(I_1995_S));
    generic_nmos I_1930(.D(VSS), .G(I_1899_S), .S(I_1962_D));
//
  nor auto_473(I_1899_S, I_873_D, I_101_D);
    generic_pmos I_1867(.D(VDD), .G(I_101_D), .S(I_1899_D));
    generic_pmos I_1899(.D(I_1899_D), .G(I_873_D), .S(I_1899_S));
    generic_nmos I_1866(.D(VSS), .G(I_873_D), .S(I_1899_S));
    generic_nmos I_1898(.D(I_1899_S), .G(I_101_D), .S(VSS));

// Logic for the 3-bits above ... "A11" here
  nand auto_466(I_1901_D, I_2157_S, I_101_D);
    generic_pmos I_1869(.D(VDD), .G(I_101_D), .S(I_1901_D));
    generic_pmos I_1901(.D(I_1901_D), .G(I_2157_S), .S(VDD));
    generic_nmos I_1868(.D(I_1901_D), .G(I_2157_S), .S(I_1900_D));
    generic_nmos I_1900(.D(I_1900_D), .G(I_101_D), .S(VSS));

// Logic for the 3-bits above ... "A13" here
  not auto_526(I_2157_S, I_873_D);
    generic_pmos I_2157(.D(VDD), .G(I_873_D), .S(I_2157_S));
    generic_nmos I_2156(.D(VSS), .G(I_873_D), .S(I_2157_S));

// DRAM row-column address multiplexing gates (See Page 14)
// Gate Set F,Q,O,P,U,R,S,T: 8 x 3:1 Mux to select between VADDR1H, VADDR2H and System ADDRH

// VADDR1/2 Mux select (high)
  not auto_393(I_1597_D, I_1627_D); // NMOS strength = 4
    generic_pmos I_1501(.D(VDD), .G(I_1627_D), .S(I_1597_D));
    generic_pmos I_1533(.D(I_1597_D), .G(I_1627_D), .S(VDD));
    generic_pmos I_1565(.D(VDD), .G(I_1627_D), .S(I_1597_D));
    generic_pmos I_1597(.D(I_1597_D), .G(I_1627_D), .S(VDD));
    generic_nmos I_1500(.D(VSS), .G(I_1627_D), .S(I_1597_D));
    generic_nmos I_1532(.D(I_1597_D), .G(I_1627_D), .S(VSS));
    generic_nmos I_1564(.D(VSS), .G(I_1627_D), .S(I_1597_D));
    generic_nmos I_1596(.D(I_1597_D), .G(I_1627_D), .S(VSS));

// Set of 8 NAND gates (F) that drive (B) in order RC0..RC7
  nand auto_836(I_3773_D, I_3775_D, I_3615_D, I_3935_D);
    generic_pmos I_3709(.D(I_3773_D), .G(I_3615_D), .S(VDD));
    generic_pmos I_3741(.D(VDD), .G(I_3775_D), .S(I_3773_D));
    generic_pmos I_3773(.D(I_3773_D), .G(I_3935_D), .S(VDD));
    generic_nmos I_3708(.D(I_3773_D), .G(I_3615_D), .S(I_3740_D));
    generic_nmos I_3740(.D(I_3740_D), .G(I_3775_D), .S(I_3772_D));
    generic_nmos I_3772(.D(I_3772_D), .G(I_3935_D), .S(VSS));
  nand auto_835(I_3771_D, I_3609_D, I_3769_D, I_3929_D);
    generic_pmos I_3707(.D(I_3771_D), .G(I_3609_D), .S(VDD));
    generic_pmos I_3739(.D(VDD), .G(I_3769_D), .S(I_3771_D));
    generic_pmos I_3771(.D(I_3771_D), .G(I_3929_D), .S(VDD));
    generic_nmos I_3706(.D(I_3771_D), .G(I_3609_D), .S(I_3738_D));
    generic_nmos I_3738(.D(I_3738_D), .G(I_3769_D), .S(I_3770_D));
    generic_nmos I_3770(.D(I_3770_D), .G(I_3929_D), .S(VSS));
  nand auto_757(I_3449_D, I_3447_D, I_3287_D, I_3607_D);
    generic_pmos I_3385(.D(I_3449_D), .G(I_3287_D), .S(VDD));
    generic_pmos I_3417(.D(VDD), .G(I_3447_D), .S(I_3449_D));
    generic_pmos I_3449(.D(I_3449_D), .G(I_3607_D), .S(VDD));
    generic_nmos I_3384(.D(I_3449_D), .G(I_3287_D), .S(I_3416_D));
    generic_nmos I_3416(.D(I_3416_D), .G(I_3447_D), .S(I_3448_D));
    generic_nmos I_3448(.D(I_3448_D), .G(I_3607_D), .S(VSS));
  nand auto_413(I_1693_D, I_1535_D, I_1695_D, I_1855_D);
    generic_pmos I_1629(.D(I_1693_D), .G(I_1535_D), .S(VDD));
    generic_pmos I_1661(.D(VDD), .G(I_1695_D), .S(I_1693_D));
    generic_pmos I_1693(.D(I_1693_D), .G(I_1855_D), .S(VDD));
    generic_nmos I_1628(.D(I_1693_D), .G(I_1535_D), .S(I_1660_D));
    generic_nmos I_1660(.D(I_1660_D), .G(I_1695_D), .S(I_1692_D));
    generic_nmos I_1692(.D(I_1692_D), .G(I_1855_D), .S(VSS));
  nand auto_518(I_2173_D, I_2015_D, I_2175_D, I_2335_D);
    generic_pmos I_2109(.D(I_2173_D), .G(I_2015_D), .S(VDD));
    generic_pmos I_2141(.D(VDD), .G(I_2175_D), .S(I_2173_D));
    generic_pmos I_2173(.D(I_2173_D), .G(I_2335_D), .S(VDD));
    generic_nmos I_2108(.D(I_2173_D), .G(I_2015_D), .S(I_2140_D));
    generic_nmos I_2140(.D(I_2140_D), .G(I_2175_D), .S(I_2172_D));
    generic_nmos I_2172(.D(I_2172_D), .G(I_2335_D), .S(VSS));
  nand auto_608(I_2653_D, I_2495_D, I_2655_D, I_2815_D);
    generic_pmos I_2589(.D(I_2653_D), .G(I_2495_D), .S(VDD));
    generic_pmos I_2621(.D(VDD), .G(I_2655_D), .S(I_2653_D));
    generic_pmos I_2653(.D(I_2653_D), .G(I_2815_D), .S(VDD));
    generic_nmos I_2588(.D(I_2653_D), .G(I_2495_D), .S(I_2620_D));
    generic_nmos I_2620(.D(I_2620_D), .G(I_2655_D), .S(I_2652_D));
    generic_nmos I_2652(.D(I_2652_D), .G(I_2815_D), .S(VSS));
  nand auto_694(I_3133_D, I_3135_D, I_2975_D, I_3295_D);
    generic_pmos I_3069(.D(I_3133_D), .G(I_2975_D), .S(VDD));
    generic_pmos I_3101(.D(VDD), .G(I_3135_D), .S(I_3133_D));
    generic_pmos I_3133(.D(I_3133_D), .G(I_3295_D), .S(VDD));
    generic_nmos I_3068(.D(I_3133_D), .G(I_2975_D), .S(I_3100_D));
    generic_nmos I_3100(.D(I_3100_D), .G(I_3135_D), .S(I_3132_D));
    generic_nmos I_3132(.D(I_3132_D), .G(I_3295_D), .S(VSS));
  nand auto_759(I_3847_G, I_3291_D, I_3451_D, I_3611_D);
    generic_pmos I_3389(.D(I_3847_G), .G(I_3291_D), .S(VDD));
    generic_pmos I_3421(.D(VDD), .G(I_3451_D), .S(I_3847_G));
    generic_pmos I_3453(.D(I_3847_G), .G(I_3611_D), .S(VDD));
    generic_nmos I_3388(.D(I_3847_G), .G(I_3291_D), .S(I_3420_D));
    generic_nmos I_3420(.D(I_3420_D), .G(I_3451_D), .S(I_3452_D));
    generic_nmos I_3452(.D(I_3452_D), .G(I_3611_D), .S(VSS));

// Receives Ext Address Bus (6502)
// Set of 8 NAND gates (O) that drive above (F) in order RC0..RC7 (A8..A15)
  nand auto_837(I_3775_D, I_3988_S, I_3678_S, I_3839_S);
    generic_pmos I_3711(.D(I_3775_D), .G(I_3988_S), .S(VDD));
    generic_pmos I_3743(.D(VDD), .G(I_3678_S), .S(I_3775_D));
    generic_pmos I_3775(.D(I_3775_D), .G(I_3839_S), .S(VDD));
    generic_nmos I_3710(.D(I_3775_D), .G(I_3988_S), .S(I_3742_D));
    generic_nmos I_3742(.D(I_3742_D), .G(I_3678_S), .S(I_3774_D));
    generic_nmos I_3774(.D(I_3774_D), .G(I_3839_S), .S(VSS));
  nand auto_834(I_3769_D, I_3851_G, I_3672_S, I_3833_S);
    generic_pmos I_3705(.D(I_3769_D), .G(I_3851_G), .S(VDD));
    generic_pmos I_3737(.D(VDD), .G(I_3672_S), .S(I_3769_D));
    generic_pmos I_3769(.D(I_3769_D), .G(I_3833_S), .S(VDD));
    generic_nmos I_3704(.D(I_3769_D), .G(I_3851_G), .S(I_3736_D));
    generic_nmos I_3736(.D(I_3736_D), .G(I_3672_S), .S(I_3768_D));
    generic_nmos I_3768(.D(I_3768_D), .G(I_3833_S), .S(VSS));
  nand auto_756(I_3447_D, I_3987_S, I_3350_S, I_3511_S);
    generic_pmos I_3383(.D(I_3447_D), .G(I_3987_S), .S(VDD));
    generic_pmos I_3415(.D(VDD), .G(I_3350_S), .S(I_3447_D));
    generic_pmos I_3447(.D(I_3447_D), .G(I_3511_S), .S(VDD));
    generic_nmos I_3382(.D(I_3447_D), .G(I_3987_S), .S(I_3414_D));
    generic_nmos I_3414(.D(I_3414_D), .G(I_3350_S), .S(I_3446_D));
    generic_nmos I_3446(.D(I_3446_D), .G(I_3511_S), .S(VSS));
  nand auto_414(I_1695_D, I_1598_S, I_1631_G, I_1759_S);
    generic_pmos I_1631(.D(I_1695_D), .G(I_1631_G), .S(VDD));
    generic_pmos I_1663(.D(VDD), .G(I_1598_S), .S(I_1695_D));
    generic_pmos I_1695(.D(I_1695_D), .G(I_1759_S), .S(VDD));
    generic_nmos I_1630(.D(I_1695_D), .G(I_1631_G), .S(I_1662_D));
    generic_nmos I_1662(.D(I_1662_D), .G(I_1598_S), .S(I_1694_D));
    generic_nmos I_1694(.D(I_1694_D), .G(I_1759_S), .S(VSS));
  nand auto_519(I_2175_D, I_2078_S, I_3923_S, I_2239_S);
    generic_pmos I_2111(.D(I_2175_D), .G(I_3923_S), .S(VDD));
    generic_pmos I_2143(.D(VDD), .G(I_2078_S), .S(I_2175_D));
    generic_pmos I_2175(.D(I_2175_D), .G(I_2239_S), .S(VDD));
    generic_nmos I_2110(.D(I_2175_D), .G(I_3923_S), .S(I_2142_D));
    generic_nmos I_2142(.D(I_2142_D), .G(I_2078_S), .S(I_2174_D));
    generic_nmos I_2174(.D(I_2174_D), .G(I_2239_S), .S(VSS));
  nand auto_610(I_2655_D, I_3593_S, I_2558_S, I_2719_S);
    generic_pmos I_2591(.D(I_2655_D), .G(I_3593_S), .S(VDD));
    generic_pmos I_2623(.D(VDD), .G(I_2558_S), .S(I_2655_D));
    generic_pmos I_2655(.D(I_2655_D), .G(I_2719_S), .S(VDD));
    generic_nmos I_2590(.D(I_2655_D), .G(I_3593_S), .S(I_2622_D));
    generic_nmos I_2622(.D(I_2622_D), .G(I_2558_S), .S(I_2654_D));
    generic_nmos I_2654(.D(I_2654_D), .G(I_2719_S), .S(VSS));
  nand auto_695(I_3135_D, I_3659_S, I_3038_S, I_3199_S);
    generic_pmos I_3071(.D(I_3135_D), .G(I_3659_S), .S(VDD));
    generic_pmos I_3103(.D(VDD), .G(I_3038_S), .S(I_3135_D));
    generic_pmos I_3135(.D(I_3135_D), .G(I_3199_S), .S(VDD));
    generic_nmos I_3070(.D(I_3135_D), .G(I_3659_S), .S(I_3102_D));
    generic_nmos I_3102(.D(I_3102_D), .G(I_3038_S), .S(I_3134_D));
    generic_nmos I_3134(.D(I_3134_D), .G(I_3199_S), .S(VSS));
  nand auto_758(I_3451_D, I_3354_S, I_3983_D, I_3515_S);
    generic_pmos I_3387(.D(I_3451_D), .G(I_3983_D), .S(VDD));
    generic_pmos I_3419(.D(VDD), .G(I_3354_S), .S(I_3451_D));
    generic_pmos I_3451(.D(I_3451_D), .G(I_3515_S), .S(VDD));
    generic_nmos I_3386(.D(I_3451_D), .G(I_3983_D), .S(I_3418_D));
    generic_nmos I_3418(.D(I_3418_D), .G(I_3354_S), .S(I_3450_D));
    generic_nmos I_3450(.D(I_3450_D), .G(I_3515_S), .S(VSS));

// Receives VADDR1 H
// Set of 8 NAND gates (P) that drive above (F) in order RC0..RC7
// From video adders VADDR1H
  nand auto_801(I_3615_D, I_3029_D, I_3838_S, I_3678_S);
    generic_pmos I_3551(.D(I_3615_D), .G(I_3029_D), .S(VDD));
    generic_pmos I_3583(.D(VDD), .G(I_3838_S), .S(I_3615_D));
    generic_pmos I_3615(.D(I_3615_D), .G(I_3678_S), .S(VDD));
    generic_nmos I_3550(.D(I_3615_D), .G(I_3029_D), .S(I_3582_D));
    generic_nmos I_3582(.D(I_3582_D), .G(I_3838_S), .S(I_3614_D));
    generic_nmos I_3614(.D(I_3614_D), .G(I_3678_S), .S(VSS));
  nand auto_798(I_3609_D, I_3027_D, I_3832_S, I_3672_S);
    generic_pmos I_3545(.D(I_3609_D), .G(I_3027_D), .S(VDD));
    generic_pmos I_3577(.D(VDD), .G(I_3832_S), .S(I_3609_D));
    generic_pmos I_3609(.D(I_3609_D), .G(I_3672_S), .S(VDD));
    generic_nmos I_3544(.D(I_3609_D), .G(I_3027_D), .S(I_3576_D));
    generic_nmos I_3576(.D(I_3576_D), .G(I_3832_S), .S(I_3608_D));
    generic_nmos I_3608(.D(I_3608_D), .G(I_3672_S), .S(VSS));
  nand auto_719(I_3287_D, I_3510_S, I_3347_D, I_3350_S);
    generic_pmos I_3223(.D(I_3287_D), .G(I_3347_D), .S(VDD));
    generic_pmos I_3255(.D(VDD), .G(I_3510_S), .S(I_3287_D));
    generic_pmos I_3287(.D(I_3287_D), .G(I_3350_S), .S(VDD));
    generic_nmos I_3222(.D(I_3287_D), .G(I_3347_D), .S(I_3254_D));
    generic_nmos I_3254(.D(I_3254_D), .G(I_3510_S), .S(I_3286_D));
    generic_nmos I_3286(.D(I_3286_D), .G(I_3350_S), .S(VSS));
  nand auto_386(I_1535_D, I_3667_D, I_1758_S, I_1598_S);
    generic_pmos I_1471(.D(I_1535_D), .G(I_3667_D), .S(VDD));
    generic_pmos I_1503(.D(VDD), .G(I_1758_S), .S(I_1535_D));
    generic_pmos I_1535(.D(I_1535_D), .G(I_1598_S), .S(VDD));
    generic_nmos I_1470(.D(I_1535_D), .G(I_3667_D), .S(I_1502_D));
    generic_nmos I_1502(.D(I_1502_D), .G(I_1758_S), .S(I_1534_D));
    generic_nmos I_1534(.D(I_1534_D), .G(I_1598_S), .S(VSS));
  // Must be A12  (result of sum)
  nand auto_489(I_2015_D, I_2238_S, I_3669_D, I_2078_S);
    generic_pmos I_1951(.D(I_2015_D), .G(I_3669_D), .S(VDD));
    generic_pmos I_1983(.D(VDD), .G(I_2238_S), .S(I_2015_D));
    generic_pmos I_2015(.D(I_2015_D), .G(I_2078_S), .S(VDD));
    generic_nmos I_1950(.D(I_2015_D), .G(I_3669_D), .S(I_1982_D));
    generic_nmos I_1982(.D(I_1982_D), .G(I_2238_S), .S(I_2014_D));
    generic_nmos I_2014(.D(I_2014_D), .G(I_2078_S), .S(VSS));
  // Must be A13 (~carry - always 1)
  nand auto_580(I_2495_D, I_3036_S, I_2718_S, I_2558_S);
    generic_pmos I_2431(.D(I_2495_D), .G(I_3036_S), .S(VDD));
    generic_pmos I_2463(.D(VDD), .G(I_2718_S), .S(I_2495_D));
    generic_pmos I_2495(.D(I_2495_D), .G(I_2558_S), .S(VDD));
    generic_nmos I_2430(.D(I_2495_D), .G(I_3036_S), .S(I_2462_D));
    generic_nmos I_2462(.D(I_2462_D), .G(I_2718_S), .S(I_2494_D));
    generic_nmos I_2494(.D(I_2494_D), .G(I_2558_S), .S(VSS));
  // Must be A14 (carry - always 0)
  nand auto_661(I_2975_D, I_3198_S, I_3829_S, I_3038_S);
    generic_pmos I_2911(.D(I_2975_D), .G(I_3829_S), .S(VDD));
    generic_pmos I_2943(.D(VDD), .G(I_3198_S), .S(I_2975_D));
    generic_pmos I_2975(.D(I_2975_D), .G(I_3038_S), .S(VDD));
    generic_nmos I_2910(.D(I_2975_D), .G(I_3829_S), .S(I_2942_D));
    generic_nmos I_2942(.D(I_2942_D), .G(I_3198_S), .S(I_2974_D));
    generic_nmos I_2974(.D(I_2974_D), .G(I_3038_S), .S(VSS));
  // A15 = 1 (VDD)
  nand auto_721(I_3291_D, VDD, I_3514_S, I_3354_S);
    // Warning: Actually 2 Input NAND with one input tied VDD
    generic_pmos I_3227(.D(I_3291_D), .G(VDD), .S(VDD));
    generic_pmos I_3259(.D(VDD), .G(I_3514_S), .S(I_3291_D));
    generic_pmos I_3291(.D(I_3291_D), .G(I_3354_S), .S(VDD));
    generic_nmos I_3226(.D(I_3291_D), .G(VDD), .S(I_3258_D));
    generic_nmos I_3258(.D(I_3258_D), .G(I_3514_S), .S(I_3290_D));
    generic_nmos I_3290(.D(I_3290_D), .G(I_3354_S), .S(VSS));

// Receives VADDR2 H
// Set of 8 NAND gates (Q) that drive above (F) in order RC0..RC7
  // ASCII code bit 5/A8
  nand auto_871(I_3935_D, I_3679_S, I_3838_S, I_2969_D);
    generic_pmos I_3871(.D(I_3935_D), .G(I_3679_S), .S(VDD));
    generic_pmos I_3903(.D(VDD), .G(I_3838_S), .S(I_3935_D));
    generic_pmos I_3935(.D(I_3935_D), .G(I_2969_D), .S(VDD));
    generic_nmos I_3870(.D(I_3935_D), .G(I_3679_S), .S(I_3902_D));
    generic_nmos I_3902(.D(I_3902_D), .G(I_3838_S), .S(I_3934_D));
    generic_nmos I_3934(.D(I_3934_D), .G(I_2969_D), .S(VSS));
  // ASCII code bit 6/A9
  nand auto_867(I_3929_D, I_3673_S, I_3832_S, I_3129_D);
    generic_pmos I_3865(.D(I_3929_D), .G(I_3673_S), .S(VDD));
    generic_pmos I_3897(.D(VDD), .G(I_3832_S), .S(I_3929_D));
    generic_pmos I_3929(.D(I_3929_D), .G(I_3129_D), .S(VDD));
    generic_nmos I_3864(.D(I_3929_D), .G(I_3673_S), .S(I_3896_D));
    generic_nmos I_3896(.D(I_3896_D), .G(I_3832_S), .S(I_3928_D));
    generic_nmos I_3928(.D(I_3928_D), .G(I_3129_D), .S(VSS));
  // A10 logic from (text/hires and std/alt mode)
  nand auto_797(I_3607_D, I_3351_S, I_3510_S, I_1962_D);
    generic_pmos I_3543(.D(I_3607_D), .G(I_3351_S), .S(VDD));
    generic_pmos I_3575(.D(VDD), .G(I_3510_S), .S(I_3607_D));
    generic_pmos I_3607(.D(I_3607_D), .G(I_1962_D), .S(VDD));
    generic_nmos I_3542(.D(I_3607_D), .G(I_3351_S), .S(I_3574_D));
    generic_nmos I_3574(.D(I_3574_D), .G(I_3510_S), .S(I_3606_D));
    generic_nmos I_3606(.D(I_3606_D), .G(I_1962_D), .S(VSS));
  // A11 logic from (text/hires and std/alt mode)
  nand auto_451(I_1855_D, I_1758_S, I_1599_S, I_1901_D);
    generic_pmos I_1791(.D(I_1855_D), .G(I_1599_S), .S(VDD));
    generic_pmos I_1823(.D(VDD), .G(I_1758_S), .S(I_1855_D));
    generic_pmos I_1855(.D(I_1855_D), .G(I_1901_D), .S(VDD));
    generic_nmos I_1790(.D(I_1855_D), .G(I_1599_S), .S(I_1822_D));
    generic_nmos I_1822(.D(I_1822_D), .G(I_1758_S), .S(I_1854_D));
    generic_nmos I_1854(.D(I_1854_D), .G(I_1901_D), .S(VSS));
  // A12=1 (VDD)
  nand auto_550(I_2335_D, I_2079_S, I_2238_S, VDD);
    // Warning: Actually 2 Input NAND with one input tied VDD
    generic_pmos I_2271(.D(I_2335_D), .G(I_2079_S), .S(VDD));
    generic_pmos I_2303(.D(VDD), .G(I_2238_S), .S(I_2335_D));
    generic_pmos I_2335(.D(I_2335_D), .G(VDD), .S(VDD));
    generic_nmos I_2270(.D(I_2335_D), .G(I_2079_S), .S(I_2302_D));
    generic_nmos I_2302(.D(I_2302_D), .G(I_2238_S), .S(I_2334_D));
    generic_nmos I_2334(.D(I_2334_D), .G(VDD), .S(VSS));
  // A13 logic from (text/hires and std/alt mode)
  nand auto_633(I_2815_D, I_2559_S, I_2718_S, I_2157_S);
    generic_pmos I_2751(.D(I_2815_D), .G(I_2559_S), .S(VDD));
    generic_pmos I_2783(.D(VDD), .G(I_2718_S), .S(I_2815_D));
    generic_pmos I_2815(.D(I_2815_D), .G(I_2157_S), .S(VDD));
    generic_nmos I_2750(.D(I_2815_D), .G(I_2559_S), .S(I_2782_D));
    generic_nmos I_2782(.D(I_2782_D), .G(I_2718_S), .S(I_2814_D));
    generic_nmos I_2814(.D(I_2814_D), .G(I_2157_S), .S(VSS));
  // A14=0 (VSS)
  nand auto_724(I_3295_D, I_3039_S, I_3198_S, VSS);
    // Warning: Actually Output = TRUE with one input tied VSS
    generic_pmos I_3231(.D(I_3295_D), .G(I_3039_S), .S(VDD));
    generic_pmos I_3263(.D(VDD), .G(I_3198_S), .S(I_3295_D));
    generic_pmos I_3295(.D(I_3295_D), .G(VSS), .S(VDD));
    generic_nmos I_3230(.D(I_3295_D), .G(I_3039_S), .S(I_3262_D));
    generic_nmos I_3262(.D(I_3262_D), .G(I_3198_S), .S(I_3294_D));
    generic_nmos I_3294(.D(I_3294_D), .G(VSS), .S(VSS));
  // A15=1
  nand auto_799(I_3611_D, I_3355_S, I_3514_S, VDD);
    // Warning: Actually 2 Input NAND with one input tied VDD
    generic_pmos I_3547(.D(I_3611_D), .G(I_3355_S), .S(VDD));
    generic_pmos I_3579(.D(VDD), .G(I_3514_S), .S(I_3611_D));
    generic_pmos I_3611(.D(I_3611_D), .G(VDD), .S(VDD));
    generic_nmos I_3546(.D(I_3611_D), .G(I_3355_S), .S(I_3578_D));
    generic_nmos I_3578(.D(I_3578_D), .G(I_3514_S), .S(I_3610_D));
    generic_nmos I_3610(.D(I_3610_D), .G(VDD), .S(VSS));

// Set of 8 NOT gates (R) that drive above (O,Q) in order RC0..RC7
  not auto_858(I_3839_S, I_3838_S);
    generic_pmos I_3839(.D(VDD), .G(I_3838_S), .S(I_3839_S));
    generic_nmos I_3806(.D(I_3839_S), .G(I_3838_S), .S(VSS));
  not auto_857(I_3833_S, I_3832_S);
    generic_pmos I_3833(.D(VDD), .G(I_3832_S), .S(I_3833_S));
    generic_nmos I_3800(.D(I_3833_S), .G(I_3832_S), .S(VSS))
  not auto_785(I_3511_S, I_3510_S);
    generic_pmos I_3511(.D(VDD), .G(I_3510_S), .S(I_3511_S));
    generic_nmos I_3478(.D(I_3511_S), .G(I_3510_S), .S(VSS));
  not auto_439(I_1759_S, I_1758_S);
    generic_pmos I_1759(.D(VDD), .G(I_1758_S), .S(I_1759_S));
    generic_nmos I_1726(.D(I_1759_S), .G(I_1758_S), .S(VSS));
  not auto_539(I_2239_S, I_2238_S);
    generic_pmos I_2239(.D(VDD), .G(I_2238_S), .S(I_2239_S));
    generic_nmos I_2206(.D(I_2239_S), .G(I_2238_S), .S(VSS));
  not auto_623(I_2719_S, I_2718_S);
    generic_pmos I_2719(.D(VDD), .G(I_2718_S), .S(I_2719_S));
    generic_nmos I_2686(.D(I_2719_S), .G(I_2718_S), .S(VSS));
  not auto_712(I_3199_S, I_3198_S);
    generic_pmos I_3199(.D(VDD), .G(I_3198_S), .S(I_3199_S));
    generic_nmos I_3166(.D(I_3199_S), .G(I_3198_S), .S(VSS));
  not auto_786(I_3515_S, I_3514_S);
    generic_pmos I_3515(.D(VDD), .G(I_3514_S), .S(I_3515_S));
    generic_nmos I_3482(.D(I_3515_S), .G(I_3514_S), .S(VSS));

// Set of 8 NOT gates (S) that drive above (O,P) in order RC0..RC7
  not auto_818(I_3678_S, I_1597_D);  
    generic_pmos I_3647(.D(I_3678_S), .G(I_1597_D), .S(VDD));
    generic_nmos I_3678(.D(VSS), .G(I_1597_D), .S(I_3678_S));
  not auto_815(I_3672_S, I_1597_D);
    generic_pmos I_3641(.D(I_3672_S), .G(I_1597_D), .S(VDD));
    generic_nmos I_3672(.D(VSS), .G(I_1597_D), .S(I_3672_S));
  not auto_741(I_3350_S, I_1597_D);
    generic_pmos I_3319(.D(I_3350_S), .G(I_1597_D), .S(VDD));
    generic_nmos I_3350(.D(VSS), .G(I_1597_D), .S(I_3350_S));
  not auto_402(I_1598_S, I_1597_D);
    generic_pmos I_1567(.D(I_1598_S), .G(I_1597_D), .S(VDD));
    generic_nmos I_1598(.D(VSS), .G(I_1597_D), .S(I_1598_S));
  not auto_506(I_2078_S, I_1597_D);
    generic_pmos I_2047(.D(I_2078_S), .G(I_1597_D), .S(VDD));
    generic_nmos I_2078(.D(VSS), .G(I_1597_D), .S(I_2078_S));
  not auto_595(I_2558_S, I_1597_D);
    generic_pmos I_2527(.D(I_2558_S), .G(I_1597_D), .S(VDD));
    generic_nmos I_2558(.D(VSS), .G(I_1597_D), .S(I_2558_S));
  not auto_678(I_3038_S, I_1597_D);
    generic_pmos I_3007(.D(I_3038_S), .G(I_1597_D), .S(VDD));
    generic_nmos I_3038(.D(VSS), .G(I_1597_D), .S(I_3038_S));
  not auto_743(I_3354_S, I_1597_D);
    generic_pmos I_3323(.D(I_3354_S), .G(I_1597_D), .S(VDD));
    generic_nmos I_3354(.D(VSS), .G(I_1597_D), .S(I_3354_S));

// Set of 8 NOT gates (T) that drive above (R,P) in order RC0..RC7
  not auto_856(I_3838_S, I_3974_G);
    generic_pmos I_3807(.D(I_3838_S), .G(I_3974_G), .S(VDD));
    generic_nmos I_3838(.D(VSS), .G(I_3974_G), .S(I_3838_S));
  not auto_853(I_3832_S, I_3974_G);
    generic_pmos I_3801(.D(I_3832_S), .G(I_3974_G), .S(VDD));
    generic_nmos I_3832(.D(VSS), .G(I_3974_G), .S(I_3832_S));
  not auto_778(I_3510_S, I_3974_G);
    generic_pmos I_3479(.D(I_3510_S), .G(I_3974_G), .S(VDD));
    generic_nmos I_3510(.D(VSS), .G(I_3974_G), .S(I_3510_S));
  not auto_434(I_1758_S, I_3974_G);
    generic_pmos I_1727(.D(I_1758_S), .G(I_3974_G), .S(VDD));
    generic_nmos I_1758(.D(VSS), .G(I_3974_G), .S(I_1758_S));
  not auto_537(I_2238_S, I_3974_G);
    generic_pmos I_2207(.D(I_2238_S), .G(I_3974_G), .S(VDD));
    generic_nmos I_2238(.D(VSS), .G(I_3974_G), .S(I_2238_S));
  not auto_621(I_2718_S, I_3974_G);
    generic_pmos I_2687(.D(I_2718_S), .G(I_3974_G), .S(VDD));
    generic_nmos I_2718(.D(VSS), .G(I_3974_G), .S(I_2718_S));
  not auto_710(I_3198_S, I_3974_G);
    generic_pmos I_3167(.D(I_3198_S), .G(I_3974_G), .S(VDD));
    generic_nmos I_3198(.D(VSS), .G(I_3974_G), .S(I_3198_S));
  not auto_779(I_3514_S, I_3974_G);
    generic_pmos I_3483(.D(I_3514_S), .G(I_3974_G), .S(VDD));
    generic_nmos I_3514(.D(VSS), .G(I_3974_G), .S(I_3514_S));

// Set of 8 NOT gates (U) that drive above (Q) in order RC0..RC7
  not auto_821(I_3679_S, I_3678_S);
    generic_pmos I_3679(.D(VDD), .G(I_3678_S), .S(I_3679_S));
    generic_nmos I_3646(.D(I_3679_S), .G(I_3678_S), .S(VSS));
  not auto_820(I_3673_S, I_3672_S);
    generic_pmos I_3673(.D(VDD), .G(I_3672_S), .S(I_3673_S));
    generic_nmos I_3640(.D(I_3673_S), .G(I_3672_S), .S(VSS));
  not auto_746(I_3351_S, I_3350_S);
    generic_pmos I_3351(.D(VDD), .G(I_3350_S), .S(I_3351_S));
    generic_nmos I_3318(.D(I_3351_S), .G(I_3350_S), .S(VSS));
  not auto_404(I_1599_S, I_1598_S);
    generic_pmos I_1599(.D(VDD), .G(I_1598_S), .S(I_1599_S));
    generic_nmos I_1566(.D(I_1599_S), .G(I_1598_S), .S(VSS));
  not auto_507(I_2079_S, I_2078_S);
    generic_pmos I_2079(.D(VDD), .G(I_2078_S), .S(I_2079_S));
    generic_nmos I_2046(.D(I_2079_S), .G(I_2078_S), .S(VSS));
  not auto_598(I_2559_S, I_2558_S);
    generic_pmos I_2559(.D(VDD), .G(I_2558_S), .S(I_2559_S));
    generic_nmos I_2526(.D(I_2559_S), .G(I_2558_S), .S(VSS))
  not auto_680(I_3039_S, I_3038_S);
    generic_pmos I_3039(.D(VDD), .G(I_3038_S), .S(I_3039_S));
    generic_nmos I_3006(.D(I_3039_S), .G(I_3038_S), .S(VSS));
  not auto_747(I_3355_S, I_3354_S);
    generic_pmos I_3355(.D(VDD), .G(I_3354_S), .S(I_3355_S));
    generic_nmos I_3322(.D(I_3355_S), .G(I_3354_S), .S(VSS));

// ********************************************************************************************************

// DRAM row-column address multiplexing gates continued (See Page 15)

// Gate Set D,G,H,L : 8 x 2:1 Mux to select between VADDR1L (first character/pixel lookup) and VADDR2L (optional 2nd charset lookup)

  // VADDR1/2 Mux select (low)
  not auto_422(I_1755_D, I_1627_D); // NMOS strength = 4
    generic_pmos I_1659(.D(VDD), .G(I_1627_D), .S(I_1755_D));
    generic_pmos I_1691(.D(I_1755_D), .G(I_1627_D), .S(VDD));
    generic_pmos I_1723(.D(VDD), .G(I_1627_D), .S(I_1755_D));
    generic_pmos I_1755(.D(I_1755_D), .G(I_1627_D), .S(VDD));
    generic_nmos I_1658(.D(VSS), .G(I_1627_D), .S(I_1755_D));
    generic_nmos I_1690(.D(I_1755_D), .G(I_1627_D), .S(VSS));
    generic_nmos I_1722(.D(VSS), .G(I_1627_D), .S(I_1755_D));
    generic_nmos I_1754(.D(I_1755_D), .G(I_1627_D), .S(VSS));

// Set of 8 NAND gates (D) that drive above (C) in order RC0..RC7
  nand auto_895(I_3997_D, I_3933_D, I_3837_D);
    generic_pmos I_3965(.D(VDD), .G(I_3837_D), .S(I_3997_D));
    generic_pmos I_3997(.D(I_3997_D), .G(I_3933_D), .S(VDD));
    generic_nmos I_3964(.D(I_3997_D), .G(I_3933_D), .S(I_3996_D));
    generic_nmos I_3996(.D(I_3996_D), .G(I_3837_D), .S(VSS));
  nand auto_866(I_3926_D, I_3767_D, I_3831_D);
    generic_pmos I_3863(.D(VDD), .G(I_3767_D), .S(I_3926_D));
    generic_pmos I_3895(.D(I_3926_D), .G(I_3831_D), .S(VDD));
    generic_nmos I_3894(.D(I_3894_D), .G(I_3831_D), .S(I_3926_D));
    generic_nmos I_3862(.D(VSS), .G(I_3767_D), .S(I_3894_D));
  nand auto_728(I_3285_D, I_3413_D, I_3349_D);
    generic_pmos I_3253(.D(VDD), .G(I_3349_D), .S(I_3285_D));
    generic_pmos I_3285(.D(I_3285_D), .G(I_3413_D), .S(VDD));
    generic_nmos I_3284(.D(I_3284_D), .G(I_3413_D), .S(I_3285_D));
    generic_nmos I_3252(.D(VSS), .G(I_3349_D), .S(I_3284_D));
  nand auto_494(I_2011_D, I_2139_D, I_2075_D);
    generic_pmos I_1979(.D(VDD), .G(I_2075_D), .S(I_2011_D));
    generic_pmos I_2011(.D(I_2011_D), .G(I_2139_D), .S(VDD));
    generic_nmos I_2010(.D(I_2010_D), .G(I_2139_D), .S(I_2011_D));
    generic_nmos I_1978(.D(VSS), .G(I_2075_D), .S(I_2010_D));
  nand auto_566(I_2395_D, I_2331_D, I_2235_D);
    generic_pmos I_2363(.D(VDD), .G(I_2235_D), .S(I_2395_D));
    generic_pmos I_2395(.D(I_2395_D), .G(I_2331_D), .S(VDD));
    generic_nmos I_2362(.D(I_2395_D), .G(I_2331_D), .S(I_2394_D));
    generic_nmos I_2394(.D(I_2394_D), .G(I_2235_D), .S(VSS));
  nand auto_607(I_2650_D, I_2491_D, I_2555_D);
    generic_pmos I_2587(.D(VDD), .G(I_2491_D), .S(I_2650_D));
    generic_pmos I_2619(.D(I_2650_D), .G(I_2555_D), .S(VDD));
    generic_nmos I_2618(.D(I_2618_D), .G(I_2555_D), .S(I_2650_D));
    generic_nmos I_2586(.D(VSS), .G(I_2491_D), .S(I_2618_D));
  nand auto_648(I_2875_D, I_2811_D, I_2715_D);
    generic_pmos I_2843(.D(VDD), .G(I_2715_D), .S(I_2875_D));
    generic_pmos I_2875(.D(I_2875_D), .G(I_2811_D), .S(VDD));
    generic_nmos I_2842(.D(I_2875_D), .G(I_2811_D), .S(I_2874_D));
    generic_nmos I_2874(.D(I_2874_D), .G(I_2715_D), .S(VSS));
  nand auto_693(I_3130_D, I_3035_D, I_2971_D);
    generic_pmos I_3067(.D(VDD), .G(I_2971_D), .S(I_3130_D));
    generic_pmos I_3099(.D(I_3130_D), .G(I_3035_D), .S(VDD));
    generic_nmos I_3098(.D(I_3098_D), .G(I_3035_D), .S(I_3130_D));
    generic_nmos I_3066(.D(VSS), .G(I_2971_D), .S(I_3098_D));

// Receives VADDR2 L
// Set of 8 NAND gates (G) that drive above (D) in order RC0..RC7
// Related by I_1755_D
  nand auto_879(I_3933_D, I_1755_D, I_3973_D);
    generic_pmos I_3901(.D(VDD), .G(I_1755_D), .S(I_3933_D));
    generic_pmos I_3933(.D(I_3933_D), .G(I_3973_D), .S(VDD));
    generic_nmos I_3932(.D(I_3932_D), .G(I_3973_D), .S(I_3933_D));
    generic_nmos I_3900(.D(VSS), .G(I_1755_D), .S(I_3932_D));
  nand auto_841(I_3767_D, I_3767_G, I_1755_D);
    generic_pmos I_3735(.D(VDD), .G(I_1755_D), .S(I_3767_D));
    generic_pmos I_3767(.D(I_3767_D), .G(I_3767_G), .S(VDD));
    generic_nmos I_3766(.D(I_3766_D), .G(I_3767_G), .S(I_3767_D));
    generic_nmos I_3734(.D(VSS), .G(I_1755_D), .S(I_3766_D));
  nand auto_755(I_3413_D, I_3906_D, I_1755_D);
    generic_pmos I_3381(.D(VDD), .G(I_3906_D), .S(I_3413_D));
    generic_pmos I_3413(.D(I_3413_D), .G(I_1755_D), .S(VDD));
    generic_nmos I_3380(.D(I_3413_D), .G(I_3906_D), .S(I_3412_D));
    generic_nmos I_3412(.D(I_3412_D), .G(I_1755_D), .S(VSS));
  nand auto_517(I_2139_D, I_2169_D, I_1755_D);
    generic_pmos I_2107(.D(VDD), .G(I_2169_D), .S(I_2139_D));
    generic_pmos I_2139(.D(I_2139_D), .G(I_1755_D), .S(VDD));
    generic_nmos I_2106(.D(I_2139_D), .G(I_2169_D), .S(I_2138_D));
    generic_nmos I_2138(.D(I_2138_D), .G(I_1755_D), .S(VSS));
  nand auto_555(I_2331_D, I_1755_D, I_2329_D);
    generic_pmos I_2299(.D(VDD), .G(I_1755_D), .S(I_2331_D));
    generic_pmos I_2331(.D(I_2331_D), .G(I_2329_D), .S(VDD));
    generic_nmos I_2330(.D(I_2330_D), .G(I_2329_D), .S(I_2331_D));
    generic_nmos I_2298(.D(VSS), .G(I_1755_D), .S(I_2330_D));
  nand auto_584(I_2491_D, I_1755_D, I_1415_S);
    generic_pmos I_2459(.D(VDD), .G(I_1755_D), .S(I_2491_D));
    generic_pmos I_2491(.D(I_2491_D), .G(I_1415_S), .S(VDD));
    generic_nmos I_2490(.D(I_2490_D), .G(I_1415_S), .S(I_2491_D));
    generic_nmos I_2458(.D(VSS), .G(I_1755_D), .S(I_2490_D));
  nand auto_638(I_2811_D, I_1755_D, I_2649_D);
    generic_pmos I_2779(.D(VDD), .G(I_1755_D), .S(I_2811_D));
    generic_pmos I_2811(.D(I_2811_D), .G(I_2649_D), .S(VDD));
    generic_nmos I_2810(.D(I_2810_D), .G(I_2649_D), .S(I_2811_D));
    generic_nmos I_2778(.D(VSS), .G(I_1755_D), .S(I_2810_D));
  nand auto_666(I_2971_D, I_2809_D, I_1755_D);
    generic_pmos I_2939(.D(VDD), .G(I_1755_D), .S(I_2971_D));
    generic_pmos I_2971(.D(I_2971_D), .G(I_2809_D), .S(VDD));
    generic_nmos I_2970(.D(I_2970_D), .G(I_2809_D), .S(I_2971_D));
    generic_nmos I_2938(.D(VSS), .G(I_1755_D), .S(I_2970_D));

// Receives VADDR1 L
// Set of 8 NAND gates (H) that drive above (D) in order RC0..RC7
  // HC0 // A0 
  nand auto_855(I_3837_D, I_3869_D, I_3836_G);
    generic_pmos I_3805(.D(VDD), .G(I_3836_G), .S(I_3837_D));
    generic_pmos I_3837(.D(I_3837_D), .G(I_3869_D), .S(VDD));
    generic_nmos I_3836(.D(I_3836_D), .G(I_3836_G), .S(I_3837_D));
    generic_nmos I_3804(.D(VSS), .G(I_3869_D), .S(I_3836_D));
  // HC1 // A1
  nand auto_852(I_3831_D, I_3830_G, I_3703_D);
    generic_pmos I_3799(.D(VDD), .G(I_3830_G), .S(I_3831_D));
    generic_pmos I_3831(.D(I_3831_D), .G(I_3703_D), .S(VDD));
    generic_nmos I_3830(.D(I_3830_D), .G(I_3830_G), .S(I_3831_D));
    generic_nmos I_3798(.D(VSS), .G(I_3703_D), .S(I_3830_D));
  // HC2 // A2
  nand auto_740(I_3349_D, I_1831_S, I_3445_S);
    generic_pmos I_3317(.D(VDD), .G(I_1831_S), .S(I_3349_D));
    generic_pmos I_3349(.D(I_3349_D), .G(I_3445_S), .S(VDD));
    generic_nmos I_3316(.D(I_3349_D), .G(I_3445_S), .S(I_3348_D));
    generic_nmos I_3348(.D(I_3348_D), .G(I_1831_S), .S(VSS));
  // Rest from video adders lowest bit of VADDR1L upward ...
  nand auto_504(I_2075_D, I_2171_S, I_2071_D);
    generic_pmos I_2043(.D(VDD), .G(I_2071_D), .S(I_2075_D));
    generic_pmos I_2075(.D(I_2075_D), .G(I_2171_S), .S(VDD));
    generic_nmos I_2042(.D(I_2075_D), .G(I_2171_S), .S(I_2074_D));
    generic_nmos I_2074(.D(I_2074_D), .G(I_2071_D), .S(VSS));
  nand auto_535(I_2235_D, I_2267_D, I_2549_D);
    generic_pmos I_2203(.D(VDD), .G(I_2549_D), .S(I_2235_D));
    generic_pmos I_2235(.D(I_2235_D), .G(I_2267_D), .S(VDD));
    generic_nmos I_2234(.D(I_2234_D), .G(I_2549_D), .S(I_2235_D));
    generic_nmos I_2202(.D(VSS), .G(I_2267_D), .S(I_2234_D));
  nand auto_593(I_2555_D, I_2427_D, I_2871_D);
    generic_pmos I_2523(.D(VDD), .G(I_2871_D), .S(I_2555_D));
    generic_pmos I_2555(.D(I_2555_D), .G(I_2427_D), .S(VDD));
    generic_nmos I_2554(.D(I_2554_D), .G(I_2871_D), .S(I_2555_D));
    generic_nmos I_2522(.D(VSS), .G(I_2427_D), .S(I_2554_D));
  nand auto_619(I_2715_D, I_2747_D, I_2709_D);
    generic_pmos I_2683(.D(VDD), .G(I_2709_D), .S(I_2715_D));
    generic_pmos I_2715(.D(I_2715_D), .G(I_2747_D), .S(VDD));
    generic_nmos I_2714(.D(I_2714_D), .G(I_2709_D), .S(I_2715_D));
    generic_nmos I_2682(.D(VSS), .G(I_2747_D), .S(I_2714_D));
  nand auto_676(I_3035_D, I_3031_D, I_2907_D);
    generic_pmos I_3003(.D(VDD), .G(I_3031_D), .S(I_3035_D));
    generic_pmos I_3035(.D(I_3035_D), .G(I_2907_D), .S(VDD));
    generic_nmos I_3034(.D(I_3034_D), .G(I_3031_D), .S(I_3035_D));
    generic_nmos I_3002(.D(VSS), .G(I_2907_D), .S(I_3034_D));

// Set of 8 NOT gates (L) that drive above (H) in order RC0..RC7
  not auto_869(I_3869_D, I_1755_D);
    generic_pmos I_3869(.D(I_3869_D), .G(I_1755_D), .S(VDD));
    generic_nmos I_3868(.D(I_3869_D), .G(I_1755_D), .S(VSS));
  not auto_833(I_3703_D, I_1755_D);
    generic_pmos I_3703(.D(I_3703_D), .G(I_1755_D), .S(VDD));
    generic_nmos I_3702(.D(I_3703_D), .G(I_1755_D), .S(VSS));
  not auto_773(I_3445_S, I_1755_D);
    generic_pmos I_3445(.D(VDD), .G(I_1755_D), .S(I_3445_S));
    generic_nmos I_3444(.D(VSS), .G(I_1755_D), .S(I_3445_S));
  not auto_531(I_2171_S, I_1755_D);
    generic_pmos I_2171(.D(VDD), .G(I_1755_D), .S(I_2171_S));
    generic_nmos I_2170(.D(VSS), .G(I_1755_D), .S(I_2171_S));
  not auto_548(I_2267_D, I_1755_D);
    generic_pmos I_2267(.D(I_2267_D), .G(I_1755_D), .S(VDD));
    generic_nmos I_2266(.D(I_2267_D), .G(I_1755_D), .S(VSS));
  not auto_578(I_2427_D, I_1755_D);
    generic_pmos I_2427(.D(I_2427_D), .G(I_1755_D), .S(VDD));
    generic_nmos I_2426(.D(I_2427_D), .G(I_1755_D), .S(VSS));
  not auto_631(I_2747_D, I_1755_D);
    generic_pmos I_2747(.D(I_2747_D), .G(I_1755_D), .S(VDD));
    generic_nmos I_2746(.D(I_2747_D), .G(I_1755_D), .S(VSS));
  not auto_659(I_2907_D, I_1755_D);
    generic_pmos I_2907(.D(I_2907_D), .G(I_1755_D), .S(VDD));
    generic_nmos I_2906(.D(I_2907_D), .G(I_1755_D), .S(VSS));

// ********************************************************************************************************

// Gate Set A,B,C,E : 8 x 2:1 Mux to select between HIGH (as column) and LOW (as row) halves of all addresses.

  // High/low mux pt1
  not auto_486(I_2009_D, I_1879_D); // NMOS strength = 3
    generic_pmos I_1945(.D(I_2009_D), .G(I_1879_D), .S(VDD));
    generic_pmos I_1977(.D(VDD), .G(I_1879_D), .S(I_2009_D));
    generic_pmos I_2009(.D(I_2009_D), .G(I_1879_D), .S(VDD));
    generic_nmos I_1944(.D(I_2009_D), .G(I_1879_D), .S(VSS));
    generic_nmos I_1976(.D(VSS), .G(I_1879_D), .S(I_2009_D));
    generic_nmos I_2008(.D(I_2009_D), .G(I_1879_D), .S(VSS));
  // High/low mux pt2
  not auto_412(I_1689_D, I_1879_D); // NMOS strength = 3
    generic_pmos I_1625(.D(I_1689_D), .G(I_1879_D), .S(VDD));
    generic_pmos I_1657(.D(VDD), .G(I_1879_D), .S(I_1689_D));
    generic_pmos I_1689(.D(I_1689_D), .G(I_1879_D), .S(VDD));
    generic_nmos I_1624(.D(I_1689_D), .G(I_1879_D), .S(VSS));
    generic_nmos I_1656(.D(VSS), .G(I_1879_D), .S(I_1689_D));
    generic_nmos I_1688(.D(I_1689_D), .G(I_1879_D), .S(VSS));

// Set of 8 NAND gates (A) that drive DRAM row-column addresses, in order RC0..RC7
  nand auto_817(I_3677_D, I_3517_D, I_3613_D);
    generic_pmos I_3645(.D(VDD), .G(I_3517_D), .S(I_3677_D));
    generic_pmos I_3677(.D(I_3677_D), .G(I_3613_D), .S(VDD));
    generic_nmos I_3644(.D(I_3677_D), .G(I_3613_D), .S(I_3676_D));
    generic_nmos I_3676(.D(I_3676_D), .G(I_3517_D), .S(VSS));
  nand auto_894(I_3995_D, I_3931_D, I_3835_D);
    generic_pmos I_3963(.D(VDD), .G(I_3835_D), .S(I_3995_D));
    generic_pmos I_3995(.D(I_3995_D), .G(I_3931_D), .S(VDD));
    generic_nmos I_3962(.D(I_3995_D), .G(I_3931_D), .S(I_3994_D));
    generic_nmos I_3994(.D(I_3994_D), .G(I_3835_D), .S(VSS));
  nand auto_742(I_3353_D, I_3193_D, I_3289_D);
    generic_pmos I_3321(.D(VDD), .G(I_3193_D), .S(I_3353_D));
    generic_pmos I_3353(.D(I_3353_D), .G(I_3289_D), .S(VDD));
    generic_nmos I_3320(.D(I_3353_D), .G(I_3289_D), .S(I_3352_D));
    generic_nmos I_3352(.D(I_3352_D), .G(I_3193_D), .S(VSS));
  nand auto_505(I_2077_D, I_1917_D, I_2013_D);
    generic_pmos I_2045(.D(VDD), .G(I_1917_D), .S(I_2077_D));
    generic_pmos I_2077(.D(I_2077_D), .G(I_2013_D), .S(VDD));
    generic_nmos I_2044(.D(I_2077_D), .G(I_2013_D), .S(I_2076_D));
    generic_nmos I_2076(.D(I_2076_D), .G(I_1917_D), .S(VSS));
  nand auto_567(I_2397_D, I_2237_D, I_2333_D);
    generic_pmos I_2365(.D(VDD), .G(I_2237_D), .S(I_2397_D));
    generic_pmos I_2397(.D(I_2397_D), .G(I_2333_D), .S(VDD));
    generic_nmos I_2364(.D(I_2397_D), .G(I_2333_D), .S(I_2396_D));
    generic_nmos I_2396(.D(I_2396_D), .G(I_2237_D), .S(VSS));
  nand auto_620(I_2717_D, I_2557_D, I_2493_D);
    generic_pmos I_2685(.D(VDD), .G(I_2557_D), .S(I_2717_D));
    generic_pmos I_2717(.D(I_2717_D), .G(I_2493_D), .S(VDD));
    generic_nmos I_2684(.D(I_2717_D), .G(I_2493_D), .S(I_2716_D));
    generic_nmos I_2716(.D(I_2716_D), .G(I_2557_D), .S(VSS));
  nand auto_660(I_2972_D, I_2877_D, I_2813_D);
    generic_pmos I_2909(.D(VDD), .G(I_2813_D), .S(I_2972_D));
    generic_pmos I_2941(.D(I_2972_D), .G(I_2877_D), .S(VDD));
    generic_nmos I_2940(.D(I_2940_D), .G(I_2877_D), .S(I_2972_D));
    generic_nmos I_2908(.D(VSS), .G(I_2813_D), .S(I_2940_D));
  nand auto_744(I_3357_D, I_3293_D, I_3197_D);
    generic_pmos I_3325(.D(VDD), .G(I_3197_D), .S(I_3357_D));
    generic_pmos I_3357(.D(I_3357_D), .G(I_3293_D), .S(VDD));
    generic_nmos I_3324(.D(I_3357_D), .G(I_3293_D), .S(I_3356_D));
    generic_nmos I_3356(.D(I_3356_D), .G(I_3197_D), .S(VSS));

// Set of 8 NAND gates (C) that drive above (A) in order RC0..RC7
  nand auto_804(I_3613_D, I_1689_D, I_3997_D);
    generic_pmos I_3581(.D(VDD), .G(I_1689_D), .S(I_3613_D));
    generic_pmos I_3613(.D(I_3613_D), .G(I_3997_D), .S(VDD));
    generic_nmos I_3612(.D(I_3612_D), .G(I_3997_D), .S(I_3613_D));
    generic_nmos I_3580(.D(VSS), .G(I_1689_D), .S(I_3612_D));
  nand auto_877(I_3931_D, I_1689_D, I_3926_D);
    generic_pmos I_3899(.D(VDD), .G(I_1689_D), .S(I_3931_D));
    generic_pmos I_3931(.D(I_3931_D), .G(I_3926_D), .S(VDD));
    generic_nmos I_3930(.D(I_3930_D), .G(I_3926_D), .S(I_3931_D));
    generic_nmos I_3898(.D(VSS), .G(I_1689_D), .S(I_3930_D));
  nand auto_729(I_3289_D, I_1689_D, I_3285_D);
    generic_pmos I_3257(.D(VDD), .G(I_1689_D), .S(I_3289_D));
    generic_pmos I_3289(.D(I_3289_D), .G(I_3285_D), .S(VDD));
    generic_nmos I_3288(.D(I_3288_D), .G(I_3285_D), .S(I_3289_D));
    generic_nmos I_3256(.D(VSS), .G(I_1689_D), .S(I_3288_D));
  nand auto_495(I_2013_D, I_1689_D, I_2011_D);
    generic_pmos I_1981(.D(VDD), .G(I_1689_D), .S(I_2013_D));
    generic_pmos I_2013(.D(I_2013_D), .G(I_2011_D), .S(VDD));
    generic_nmos I_2012(.D(I_2012_D), .G(I_2011_D), .S(I_2013_D));
    generic_nmos I_1980(.D(VSS), .G(I_1689_D), .S(I_2012_D));
  nand auto_557(I_2333_D, I_2395_D, I_2009_D);
    generic_pmos I_2301(.D(VDD), .G(I_2009_D), .S(I_2333_D));
    generic_pmos I_2333(.D(I_2333_D), .G(I_2395_D), .S(VDD));
    generic_nmos I_2332(.D(I_2332_D), .G(I_2395_D), .S(I_2333_D));
    generic_nmos I_2300(.D(VSS), .G(I_2009_D), .S(I_2332_D));
  nand auto_585(I_2493_D, I_2009_D, I_2650_D);
    generic_pmos I_2461(.D(VDD), .G(I_2009_D), .S(I_2493_D));
    generic_pmos I_2493(.D(I_2493_D), .G(I_2650_D), .S(VDD));
    generic_nmos I_2492(.D(I_2492_D), .G(I_2650_D), .S(I_2493_D));
    generic_nmos I_2460(.D(VSS), .G(I_2009_D), .S(I_2492_D));
  nand auto_639(I_2813_D, I_2875_D, I_2009_D);
    generic_pmos I_2781(.D(VDD), .G(I_2009_D), .S(I_2813_D));
    generic_pmos I_2813(.D(I_2813_D), .G(I_2875_D), .S(VDD));
    generic_nmos I_2812(.D(I_2812_D), .G(I_2875_D), .S(I_2813_D));
    generic_nmos I_2780(.D(VSS), .G(I_2009_D), .S(I_2812_D));
  nand auto_730(I_3293_D, I_2009_D, I_3130_D);
    generic_pmos I_3261(.D(VDD), .G(I_2009_D), .S(I_3293_D));
    generic_pmos I_3293(.D(I_3293_D), .G(I_3130_D), .S(VDD));
    generic_nmos I_3292(.D(I_3292_D), .G(I_3130_D), .S(I_3293_D));
    generic_nmos I_3260(.D(VSS), .G(I_2009_D), .S(I_3292_D));

// Set of 8 NAND gates (B) that drive above (A) in order RC0..RC7
  nand auto_780(I_3517_D, I_3773_D, I_3549_D);
    generic_pmos I_3485(.D(VDD), .G(I_3773_D), .S(I_3517_D));
    generic_pmos I_3517(.D(I_3517_D), .G(I_3549_D), .S(VDD));
    generic_nmos I_3516(.D(I_3516_D), .G(I_3773_D), .S(I_3517_D));
    generic_nmos I_3484(.D(VSS), .G(I_3549_D), .S(I_3516_D));
  nand auto_854(I_3835_D, I_3867_D, I_3771_D);
    generic_pmos I_3803(.D(VDD), .G(I_3771_D), .S(I_3835_D));
    generic_pmos I_3835(.D(I_3835_D), .G(I_3867_D), .S(VDD));
    generic_nmos I_3834(.D(I_3834_D), .G(I_3771_D), .S(I_3835_D));
    generic_nmos I_3802(.D(VSS), .G(I_3867_D), .S(I_3834_D));
  nand auto_708(I_3193_D, I_3449_D, I_3225_D);
    generic_pmos I_3161(.D(VDD), .G(I_3449_D), .S(I_3193_D));
    generic_pmos I_3193(.D(I_3193_D), .G(I_3225_D), .S(VDD));
    generic_nmos I_3192(.D(I_3192_D), .G(I_3449_D), .S(I_3193_D));
    generic_nmos I_3160(.D(VSS), .G(I_3225_D), .S(I_3192_D));
  nand auto_470(I_1917_D, I_1693_D, I_1949_D);
    generic_pmos I_1885(.D(VDD), .G(I_1693_D), .S(I_1917_D));
    generic_pmos I_1917(.D(I_1917_D), .G(I_1949_D), .S(VDD));
    generic_nmos I_1916(.D(I_1916_D), .G(I_1693_D), .S(I_1917_D));
    generic_nmos I_1884(.D(VSS), .G(I_1949_D), .S(I_1916_D));
  nand auto_536(I_2237_D, I_2269_D, I_2173_D);
    generic_pmos I_2205(.D(VDD), .G(I_2173_D), .S(I_2237_D));
    generic_pmos I_2237(.D(I_2237_D), .G(I_2269_D), .S(VDD));
    generic_nmos I_2236(.D(I_2236_D), .G(I_2173_D), .S(I_2237_D));
    generic_nmos I_2204(.D(VSS), .G(I_2269_D), .S(I_2236_D));
  nand auto_594(I_2557_D, I_2653_D, I_2429_D);
    generic_pmos I_2525(.D(VDD), .G(I_2653_D), .S(I_2557_D));
    generic_pmos I_2557(.D(I_2557_D), .G(I_2429_D), .S(VDD));
    generic_nmos I_2556(.D(I_2556_D), .G(I_2653_D), .S(I_2557_D));
    generic_nmos I_2524(.D(VSS), .G(I_2429_D), .S(I_2556_D));
  nand auto_649(I_2877_D, I_2749_D, I_3133_D);
    generic_pmos I_2845(.D(VDD), .G(I_3133_D), .S(I_2877_D));
    generic_pmos I_2877(.D(I_2877_D), .G(I_2749_D), .S(VDD));
    generic_nmos I_2876(.D(I_2876_D), .G(I_3133_D), .S(I_2877_D));
    generic_nmos I_2844(.D(VSS), .G(I_2749_D), .S(I_2876_D));
  nand auto_709(I_3197_D, I_3847_G, I_3229_D);
    generic_pmos I_3165(.D(VDD), .G(I_3847_G), .S(I_3197_D));
    generic_pmos I_3197(.D(I_3197_D), .G(I_3229_D), .S(VDD));
    generic_nmos I_3196(.D(I_3196_D), .G(I_3847_G), .S(I_3197_D));
    generic_nmos I_3164(.D(VSS), .G(I_3229_D), .S(I_3196_D));

// Set of 8 NOT gates (E) that drive above (B) in order RC0..RC7
  not auto_800(I_3549_D, I_1689_D);
    generic_pmos I_3549(.D(I_3549_D), .G(I_1689_D), .S(VDD));
    generic_nmos I_3548(.D(I_3549_D), .G(I_1689_D), .S(VSS));
  not auto_868(I_3867_D, I_1689_D);
    generic_pmos I_3867(.D(I_3867_D), .G(I_1689_D), .S(VDD));
    generic_nmos I_3866(.D(I_3867_D), .G(I_1689_D), .S(VSS));
  not auto_720(I_3225_D, I_1689_D);
    generic_pmos I_3225(.D(I_3225_D), .G(I_1689_D), .S(VDD));
    generic_nmos I_3224(.D(I_3225_D), .G(I_1689_D), .S(VSS));
  not auto_487(I_1949_D, I_1689_D);
    generic_pmos I_1949(.D(I_1949_D), .G(I_1689_D), .S(VDD));
    generic_nmos I_1948(.D(I_1949_D), .G(I_1689_D), .S(VSS));
  not auto_549(I_2269_D, I_2009_D);
    generic_pmos I_2269(.D(I_2269_D), .G(I_2009_D), .S(VDD));
    generic_nmos I_2268(.D(I_2269_D), .G(I_2009_D), .S(VSS));
  not auto_579(I_2429_D, I_2009_D);
    generic_pmos I_2429(.D(I_2429_D), .G(I_2009_D), .S(VDD));
    generic_nmos I_2428(.D(I_2429_D), .G(I_2009_D), .S(VSS));
  not auto_632(I_2749_D, I_2009_D);
    generic_pmos I_2749(.D(I_2749_D), .G(I_2009_D), .S(VDD));
    generic_nmos I_2748(.D(I_2749_D), .G(I_2009_D), .S(VSS));
  not auto_722(I_3229_D, I_2009_D);
    generic_pmos I_3229(.D(I_3229_D), .G(I_2009_D), .S(VDD));
    generic_nmos I_3228(.D(I_3229_D), .G(I_2009_D), .S(VSS));

// ********************************************************************************************************

// Video output circuitry - Shift Register (See Page 16, Bottom)

// This is the 6 bit video shift register, loads from internal DB on I_1045_D
// Shifts out on delayed version of 6MHZ clock I_989_D (I_251_S)
// Video emerges at I_1250_G

// 2:1 Mux Selects between internal DB0..DB5 (D inputs load)
// And output of previous flipflop (cascade/shift)

// 6 Ganged 2:1 Muxes
// Which sense?: When 1045_D is high: 17 on, output = I_2041_D (Q of Databus Latch) common for all these.
// DB0
// 2:1 Mux with single control: Inputs: I_2041_D, VSS Output: I_155_D Control: I_1045_D
  generic_cmos pass_17(.gn(I_1045_D), .gp(I_789_D), .p1(I_2041_D), .p2(I_155_D));
    generic_pmos I_123(.D(I_2041_D), .G(I_789_D), .S(I_155_D));
    generic_nmos I_122(.D(I_2041_D), .G(I_1045_D), .S(I_155_D));
  generic_cmos pass_59(.gn(I_789_D), .gp(I_1045_D), .p1(I_155_D), .p2(VSS));
    generic_pmos I_155(.D(I_155_D), .G(I_1045_D), .S(VSS));
    generic_nmos I_154(.D(I_155_D), .G(I_789_D), .S(VSS));
// DB1
// 2:1 Mux with single control: Inputs: I_443_D, I_2201_D Output: I_475_D Control: I_1045_D
  generic_cmos pass_240(.gn(I_789_D), .gp(I_1045_D), .p1(I_443_D), .p2(I_475_D));
    generic_pmos I_443(.D(I_443_D), .G(I_1045_D), .S(I_475_D));
    generic_nmos I_442(.D(I_443_D), .G(I_789_D), .S(I_475_D));
  generic_cmos pass_247(.gn(I_1045_D), .gp(I_789_D), .p1(I_475_D), .p2(I_2201_D));
    generic_pmos I_475(.D(I_475_D), .G(I_789_D), .S(I_2201_D));
    generic_nmos I_474(.D(I_475_D), .G(I_1045_D), .S(I_2201_D));
// DB2
// 2:1 Mux with single control: Inputs: I_763_D, I_2361_D Output: I_795_D Control: I_1045_D
  generic_cmos pass_266(.gn(I_789_D), .gp(I_1045_D), .p1(I_763_D), .p2(I_795_D));
    generic_pmos I_763(.D(I_763_D), .G(I_1045_D), .S(I_795_D));
    generic_nmos I_762(.D(I_763_D), .G(I_789_D), .S(I_795_D));
  generic_cmos pass_273(.gn(I_1045_D), .gp(I_789_D), .p1(I_795_D), .p2(I_2361_D));
    generic_pmos I_795(.D(I_795_D), .G(I_789_D), .S(I_2361_D));
    generic_nmos I_794(.D(I_795_D), .G(I_1045_D), .S(I_2361_D));
// DB3
// 2:1 Mux with single control: Inputs: I_1401_D, I_2521_D Output: I_1433_D Control: I_1045_D
  generic_cmos pass_42(.gn(I_789_D), .gp(I_1045_D), .p1(I_1401_D), .p2(I_1433_D));
    generic_pmos I_1401(.D(I_1401_D), .G(I_1045_D), .S(I_1433_D));
    generic_nmos I_1400(.D(I_1401_D), .G(I_789_D), .S(I_1433_D));
  generic_cmos pass_52(.gn(I_1045_D), .gp(I_789_D), .p1(I_1433_D), .p2(I_2521_D));
    generic_pmos I_1433(.D(I_1433_D), .G(I_789_D), .S(I_2521_D));
    generic_nmos I_1432(.D(I_1433_D), .G(I_1045_D), .S(I_2521_D));
// DB4
// 2:1 Mux with single control: Inputs: I_2681_D, I_1207_D Output: I_1111_D Control: I_1045_D
  generic_cmos pass_5(.gn(I_1045_D), .gp(I_789_D), .p1(I_2681_D), .p2(I_1111_D));
    generic_pmos I_1079(.D(I_2681_D), .G(I_789_D), .S(I_1111_D));
    generic_nmos I_1078(.D(I_2681_D), .G(I_1045_D), .S(I_1111_D));
  generic_cmos pass_9(.gn(I_789_D), .gp(I_1045_D), .p1(I_1111_D), .p2(I_1207_D));
    generic_pmos I_1111(.D(I_1111_D), .G(I_1045_D), .S(I_1207_D));
    generic_nmos I_1110(.D(I_1111_D), .G(I_789_D), .S(I_1207_D));
// DB5
// 2:1 Mux with single control: Inputs: I_2841_D, I_727_D Output: I_471_S Control: I_1045_D
  generic_cmos pass_252(.gn(I_1045_D), .gp(I_789_D), .p1(I_2841_D), .p2(I_471_S));
    generic_pmos I_599(.D(I_2841_D), .G(I_789_D), .S(I_471_S));
    generic_nmos I_598(.D(I_2841_D), .G(I_1045_D), .S(I_471_S));
  generic_cmos pass_257(.gn(I_789_D), .gp(I_1045_D), .p1(I_471_S), .p2(I_727_D));
    generic_pmos I_631(.D(I_471_S), .G(I_1045_D), .S(I_727_D));
    generic_nmos I_630(.D(I_471_S), .G(I_789_D), .S(I_727_D));
// Driver
  not auto_953(I_789_D, I_1045_D); // NMOS strength = 3
    generic_pmos I_725(.D(VDD), .G(I_1045_D), .S(I_789_D));
    generic_pmos I_757(.D(VDD), .G(I_1045_D), .S(I_789_D));
    generic_pmos I_789(.D(I_789_D), .G(I_1045_D), .S(VDD));
    generic_nmos I_724(.D(VSS), .G(I_1045_D), .S(I_789_D));
    generic_nmos I_756(.D(VSS), .G(I_1045_D), .S(I_789_D));
    generic_nmos I_788(.D(I_789_D), .G(I_1045_D), .S(VSS));

// These are the 12 latches -> 6 flip-flops in a chain for above

// 12 Ganged D-Type latches (common control clock)
// In 6 chains of 2 series devices (flipflops) (reordered to F G E2 Y E1 D)
// Chain F

// D-Type Flip Flop D: I_155_D Q: I_443_D ~Q: I_409_S Rising Clock: I_251_S
// D-Type latch D: I_155_D ~Q: I_281_D Q: I_185_D Clock: I_251_S
// 2:1 Mux with single control: Inputs: I_155_D, I_185_D Output: I_153_D Control: I_251_S
  generic_cmos pass_12(.gn(I_315_D), .gp(I_251_S), .p1(I_155_D), .p2(I_153_D));
    generic_pmos I_121(.D(I_155_D), .G(I_251_S), .S(I_153_D));
    generic_nmos I_120(.D(I_155_D), .G(I_315_D), .S(I_153_D));
  generic_cmos pass_54(.gn(I_251_S), .gp(I_315_D), .p1(I_153_D), .p2(I_185_D));
    generic_pmos I_153(.D(I_153_D), .G(I_315_D), .S(I_185_D));
    generic_nmos I_152(.D(I_153_D), .G(I_251_S), .S(I_185_D));
  not auto_463(I_185_D, I_281_D);
    generic_pmos I_185(.D(I_185_D), .G(I_281_D), .S(VDD));
    generic_nmos I_184(.D(I_185_D), .G(I_281_D), .S(VSS));
  not auto_530(I_281_D, I_153_D); // NMOS strength = 2
    generic_pmos I_217(.D(VDD), .G(I_153_D), .S(I_281_D));
    generic_pmos I_249(.D(I_281_D), .G(I_153_D), .S(VDD));
    generic_nmos I_216(.D(VSS), .G(I_153_D), .S(I_281_D));
    generic_nmos I_248(.D(I_281_D), .G(I_153_D), .S(VSS));
// D-Type latch D: I_281_D ~Q: I_443_D Q: I_409_S Clock: I_251_S
// 2:1 Mux with single control: Inputs: I_281_D, I_409_S Output: I_313_D Control: I_251_S
  generic_cmos pass_146(.gn(I_251_S), .gp(I_315_D), .p1(I_281_D), .p2(I_313_D));
    generic_pmos I_281(.D(I_281_D), .G(I_315_D), .S(I_313_D));
    generic_nmos I_280(.D(I_281_D), .G(I_251_S), .S(I_313_D));
  generic_cmos pass_177(.gn(I_315_D), .gp(I_251_S), .p1(I_313_D), .p2(I_409_S));
    generic_pmos I_313(.D(I_313_D), .G(I_251_S), .S(I_409_S));
    generic_nmos I_312(.D(I_313_D), .G(I_315_D), .S(I_409_S));
  not auto_902(I_409_S, I_443_D);
    generic_pmos I_409(.D(VDD), .G(I_443_D), .S(I_409_S));
    generic_nmos I_408(.D(VSS), .G(I_443_D), .S(I_409_S));
  not auto_774(I_443_D, I_313_D); // NMOS strength = 2
    generic_pmos I_345(.D(VDD), .G(I_313_D), .S(I_443_D));
    generic_pmos I_377(.D(I_443_D), .G(I_313_D), .S(VDD));
    generic_nmos I_344(.D(VSS), .G(I_313_D), .S(I_443_D));
    generic_nmos I_376(.D(I_443_D), .G(I_313_D), .S(VSS));
// Chain G
// D-Type Flip Flop D: I_475_D Q: I_763_D ~Q: I_729_S Rising Clock: I_251_S
// D-Type latch D: I_475_D ~Q: I_601_D Q: I_505_D Clock: I_251_S
// 2:1 Mux with single control: Inputs: I_475_D, I_505_D Output: I_473_D Control: I_251_S
  generic_cmos pass_239(.gn(I_315_D), .gp(I_251_S), .p1(I_475_D), .p2(I_473_D));
    generic_pmos I_441(.D(I_475_D), .G(I_251_S), .S(I_473_D));
    generic_nmos I_440(.D(I_475_D), .G(I_315_D), .S(I_473_D));
  generic_cmos pass_246(.gn(I_251_S), .gp(I_315_D), .p1(I_473_D), .p2(I_505_D));
    generic_pmos I_473(.D(I_473_D), .G(I_315_D), .S(I_505_D));
    generic_nmos I_472(.D(I_473_D), .G(I_251_S), .S(I_505_D));
  not auto_916(I_505_D, I_601_D);
    generic_pmos I_505(.D(I_505_D), .G(I_601_D), .S(VDD));
    generic_nmos I_504(.D(I_505_D), .G(I_601_D), .S(VSS));
  not auto_924(I_601_D, I_473_D); // NMOS strength = 2
    generic_pmos I_537(.D(VDD), .G(I_473_D), .S(I_601_D));
    generic_pmos I_569(.D(I_601_D), .G(I_473_D), .S(VDD));
    generic_nmos I_536(.D(VSS), .G(I_473_D), .S(I_601_D));
    generic_nmos I_568(.D(I_601_D), .G(I_473_D), .S(VSS));
// D-Type latch D: I_601_D ~Q: I_763_D Q: I_729_S Clock: I_251_S
// 2:1 Mux with single control: Inputs: I_601_D, I_729_S Output: I_633_D Control: I_251_S
  generic_cmos pass_253(.gn(I_251_S), .gp(I_315_D), .p1(I_601_D), .p2(I_633_D));
    generic_pmos I_601(.D(I_601_D), .G(I_315_D), .S(I_633_D));
    generic_nmos I_600(.D(I_601_D), .G(I_251_S), .S(I_633_D));
  generic_cmos pass_258(.gn(I_315_D), .gp(I_251_S), .p1(I_633_D), .p2(I_729_S));
    generic_pmos I_633(.D(I_633_D), .G(I_251_S), .S(I_729_S));
    generic_nmos I_632(.D(I_633_D), .G(I_315_D), .S(I_729_S));
  not auto_954(I_729_S, I_763_D);
    generic_pmos I_729(.D(VDD), .G(I_763_D), .S(I_729_S));
    generic_nmos I_728(.D(VSS), .G(I_763_D), .S(I_729_S));
  not auto_940(I_763_D, I_633_D); // NMOS strength = 2
    generic_pmos I_665(.D(VDD), .G(I_633_D), .S(I_763_D));
    generic_pmos I_697(.D(I_763_D), .G(I_633_D), .S(VDD));
    generic_nmos I_664(.D(VSS), .G(I_633_D), .S(I_763_D));
    generic_nmos I_696(.D(I_763_D), .G(I_633_D), .S(VSS));
// Chain E2
// D-Type Flip Flop D: I_795_D Q: I_1401_D ~Q: I_1049_S Rising Clock: I_251_S
// D-Type latch D: I_795_D ~Q: I_921_D Q: I_825_D Clock: I_251_S
// 2:1 Mux with single control: Inputs: I_795_D, I_825_D Output: I_793_D Control: I_251_S
  generic_cmos pass_265(.gn(I_315_D), .gp(I_251_S), .p1(I_795_D), .p2(I_793_D));
    generic_pmos I_761(.D(I_795_D), .G(I_251_S), .S(I_793_D));
    generic_nmos I_760(.D(I_795_D), .G(I_315_D), .S(I_793_D));
  generic_cmos pass_272(.gn(I_251_S), .gp(I_315_D), .p1(I_793_D), .p2(I_825_D));
    generic_pmos I_793(.D(I_793_D), .G(I_315_D), .S(I_825_D));
    generic_nmos I_792(.D(I_793_D), .G(I_251_S), .S(I_825_D));
  not auto_963(I_825_D, I_921_D);
    generic_pmos I_825(.D(I_825_D), .G(I_921_D), .S(VDD));
    generic_nmos I_824(.D(I_825_D), .G(I_921_D), .S(VSS));
  not auto_973(I_921_D, I_793_D); // NMOS strength = 2
    generic_pmos I_857(.D(VDD), .G(I_793_D), .S(I_921_D));
    generic_pmos I_889(.D(I_921_D), .G(I_793_D), .S(VDD));
    generic_nmos I_856(.D(VSS), .G(I_793_D), .S(I_921_D));
    generic_nmos I_888(.D(I_921_D), .G(I_793_D), .S(VSS));
// D-Type latch D: I_921_D ~Q: I_1401_D Q: I_1049_S Clock: I_251_S
// 2:1 Mux with single control: Inputs: I_921_D, I_1049_S Output: I_953_D Control: I_251_S
  generic_cmos pass_280(.gn(I_251_S), .gp(I_315_D), .p1(I_921_D), .p2(I_953_D));
    generic_pmos I_921(.D(I_921_D), .G(I_315_D), .S(I_953_D));
    generic_nmos I_920(.D(I_921_D), .G(I_251_S), .S(I_953_D));
  generic_cmos pass_287(.gn(I_315_D), .gp(I_251_S), .p1(I_953_D), .p2(I_1049_S));
    generic_pmos I_953(.D(I_953_D), .G(I_251_S), .S(I_1049_S));
    generic_nmos I_952(.D(I_953_D), .G(I_315_D), .S(I_1049_S));
  not auto_301(I_1049_S, I_1401_D);
    generic_pmos I_1049(.D(VDD), .G(I_1401_D), .S(I_1049_S));
    generic_nmos I_1048(.D(VSS), .G(I_1401_D), .S(I_1049_S));
  not auto_294(I_1401_D, I_953_D); // NMOS strength = 2
    generic_pmos I_1017(.D(I_1401_D), .G(I_953_D), .S(VDD));
    generic_pmos I_985(.D(VDD), .G(I_953_D), .S(I_1401_D));
    generic_nmos I_1016(.D(I_1401_D), .G(I_953_D), .S(VSS));
    generic_nmos I_984(.D(VSS), .G(I_953_D), .S(I_1401_D));
// Chain Y
// D-Type Flip Flop D: I_1433_D Q: I_1207_D ~Q: I_1239_D Rising Clock: I_251_S
// D-Type latch D: I_1433_D ~Q: I_1335_D Q: I_1399_D Clock: I_251_S
// 2:1 Mux with single control: Inputs: I_1399_D, I_1433_D Output: I_1431_D Control: I_251_S
  generic_cmos pass_41(.gn(I_251_S), .gp(I_315_D), .p1(I_1399_D), .p2(I_1431_D));
    generic_pmos I_1399(.D(I_1399_D), .G(I_315_D), .S(I_1431_D));
    generic_nmos I_1398(.D(I_1399_D), .G(I_251_S), .S(I_1431_D));
  generic_cmos pass_51(.gn(I_315_D), .gp(I_251_S), .p1(I_1431_D), .p2(I_1433_D));
    generic_pmos I_1431(.D(I_1431_D), .G(I_251_S), .S(I_1433_D));
    generic_nmos I_1430(.D(I_1431_D), .G(I_315_D), .S(I_1433_D));
  not auto_365(I_1399_D, I_1335_D);
    generic_pmos I_1367(.D(VDD), .G(I_1335_D), .S(I_1399_D));
    generic_nmos I_1366(.D(VSS), .G(I_1335_D), .S(I_1399_D));
  not auto_350(I_1335_D, I_1431_D); // NMOS strength = 2
    generic_pmos I_1303(.D(VDD), .G(I_1431_D), .S(I_1335_D));
    generic_pmos I_1335(.D(I_1335_D), .G(I_1431_D), .S(VDD));
    generic_nmos I_1302(.D(VSS), .G(I_1431_D), .S(I_1335_D));
    generic_nmos I_1334(.D(I_1335_D), .G(I_1431_D), .S(VSS));
// D-Type latch D: I_1335_D ~Q: I_1207_D Q: I_1239_D Clock: I_251_S
// 2:1 Mux with single control: Inputs: I_1239_D, I_1335_D Output: I_1271_D Control: I_251_S
  generic_cmos pass_21(.gn(I_315_D), .gp(I_251_S), .p1(I_1239_D), .p2(I_1271_D));
    generic_pmos I_1239(.D(I_1239_D), .G(I_251_S), .S(I_1271_D));
    generic_nmos I_1238(.D(I_1239_D), .G(I_315_D), .S(I_1271_D));
  generic_cmos pass_31(.gn(I_251_S), .gp(I_315_D), .p1(I_1271_D), .p2(I_1335_D));
    generic_pmos I_1271(.D(I_1271_D), .G(I_315_D), .S(I_1335_D));
    generic_nmos I_1270(.D(I_1271_D), .G(I_251_S), .S(I_1335_D));
  not auto_320(I_1239_D, I_1207_D);
    generic_pmos I_1143(.D(I_1239_D), .G(I_1207_D), .S(VDD));
    generic_nmos I_1142(.D(I_1239_D), .G(I_1207_D), .S(VSS));
  not auto_330(I_1207_D, I_1271_D); // NMOS strength = 2
    generic_pmos I_1175(.D(VDD), .G(I_1271_D), .S(I_1207_D));
    generic_pmos I_1207(.D(I_1207_D), .G(I_1271_D), .S(VDD));
    generic_nmos I_1174(.D(VSS), .G(I_1271_D), .S(I_1207_D));
    generic_nmos I_1206(.D(I_1207_D), .G(I_1271_D), .S(VSS));
// Chain E1
// D-Type Flip Flop D: I_1111_D Q: I_727_D ~Q: I_759_D Rising Clock: I_251_S
// D-Type latch D: I_1111_D ~Q: I_855_D Q: I_919_D Clock: I_251_S
// 2:1 Mux with single control: Inputs: I_919_D, I_1111_D Output: I_951_D Control: I_251_S
  generic_cmos pass_279(.gn(I_251_S), .gp(I_315_D), .p1(I_919_D), .p2(I_951_D));
    generic_pmos I_919(.D(I_919_D), .G(I_315_D), .S(I_951_D));
    generic_nmos I_918(.D(I_919_D), .G(I_251_S), .S(I_951_D));
  generic_cmos pass_286(.gn(I_315_D), .gp(I_251_S), .p1(I_951_D), .p2(I_1111_D));
    generic_pmos I_951(.D(I_951_D), .G(I_251_S), .S(I_1111_D));
    generic_nmos I_950(.D(I_951_D), .G(I_315_D), .S(I_1111_D));
  not auto_976(I_919_D, I_855_D);
    generic_pmos I_887(.D(VDD), .G(I_855_D), .S(I_919_D));
    generic_nmos I_886(.D(VSS), .G(I_855_D), .S(I_919_D));
  not auto_962(I_855_D, I_951_D); // NMOS strength = 2
    generic_pmos I_823(.D(VDD), .G(I_951_D), .S(I_855_D));
    generic_pmos I_855(.D(I_855_D), .G(I_951_D), .S(VDD));
    generic_nmos I_822(.D(VSS), .G(I_951_D), .S(I_855_D));
    generic_nmos I_854(.D(I_855_D), .G(I_951_D), .S(VSS));
// D-Type latch D: I_855_D ~Q: I_727_D Q: I_759_D Clock: I_251_S
// 2:1 Mux with single control: Inputs: I_759_D, I_855_D Output: I_791_D Control: I_251_S
  generic_cmos pass_264(.gn(I_315_D), .gp(I_251_S), .p1(I_759_D), .p2(I_791_D));
    generic_pmos I_759(.D(I_759_D), .G(I_251_S), .S(I_791_D));
    generic_nmos I_758(.D(I_759_D), .G(I_315_D), .S(I_791_D));
  generic_cmos pass_271(.gn(I_251_S), .gp(I_315_D), .p1(I_791_D), .p2(I_855_D));
    generic_pmos I_791(.D(I_791_D), .G(I_315_D), .S(I_855_D));
    generic_nmos I_790(.D(I_791_D), .G(I_251_S), .S(I_855_D));
  not auto_939(I_759_D, I_727_D);
    generic_pmos I_663(.D(I_759_D), .G(I_727_D), .S(VDD));
    generic_nmos I_662(.D(I_759_D), .G(I_727_D), .S(VSS));
  not auto_947(I_727_D, I_791_D); // NMOS strength = 2
    generic_pmos I_695(.D(VDD), .G(I_791_D), .S(I_727_D));
    generic_pmos I_727(.D(I_727_D), .G(I_791_D), .S(VDD));
    generic_nmos I_694(.D(VSS), .G(I_791_D), .S(I_727_D));
    generic_nmos I_726(.D(I_727_D), .G(I_791_D), .S(VSS));
// Chain D
// D-Type Flip Flop D: I_471_S Q: I_1250_G ~Q: I_279_D Rising Clock: I_251_S
// D-Type latch D: I_471_S ~Q: I_375_D Q: I_439_D Clock: I_251_S
// 2:1 Mux with single control: Inputs: I_439_D, I_471_S Output: I_471_D Control: I_251_S
  generic_cmos pass_238(.gn(I_251_S), .gp(I_315_D), .p1(I_439_D), .p2(I_471_D));
    generic_pmos I_439(.D(I_439_D), .G(I_315_D), .S(I_471_D));
    generic_nmos I_438(.D(I_439_D), .G(I_251_S), .S(I_471_D));
  generic_cmos pass_245(.gn(I_315_D), .gp(I_251_S), .p1(I_471_D), .p2(I_471_S));
    generic_pmos I_471(.D(I_471_D), .G(I_251_S), .S(I_471_S));
    generic_nmos I_470(.D(I_471_D), .G(I_315_D), .S(I_471_S));
  not auto_901(I_439_D, I_375_D);
    generic_pmos I_407(.D(VDD), .G(I_375_D), .S(I_439_D));
    generic_nmos I_406(.D(VSS), .G(I_375_D), .S(I_439_D));
  not auto_767(I_375_D, I_471_D); // NMOS strength = 2
    generic_pmos I_343(.D(VDD), .G(I_471_D), .S(I_375_D));
    generic_pmos I_375(.D(I_375_D), .G(I_471_D), .S(VDD));
    generic_nmos I_342(.D(VSS), .G(I_471_D), .S(I_375_D));
    generic_nmos I_374(.D(I_375_D), .G(I_471_D), .S(VSS));
// D-Type latch D: I_375_D ~Q: I_1250_G Q: I_279_D Clock: I_251_S
// 2:1 Mux with single control: Inputs: I_279_D, I_375_D Output: I_311_D Control: I_251_S
  generic_cmos pass_145(.gn(I_315_D), .gp(I_251_S), .p1(I_279_D), .p2(I_311_D));
    generic_pmos I_279(.D(I_279_D), .G(I_251_S), .S(I_311_D));
    generic_nmos I_278(.D(I_279_D), .G(I_315_D), .S(I_311_D));
  generic_cmos pass_176(.gn(I_251_S), .gp(I_315_D), .p1(I_311_D), .p2(I_375_D));
    generic_pmos I_311(.D(I_311_D), .G(I_315_D), .S(I_375_D));
    generic_nmos I_310(.D(I_311_D), .G(I_251_S), .S(I_375_D));
  not auto_458(I_279_D, I_1250_G);
    generic_pmos I_183(.D(I_279_D), .G(I_1250_G), .S(VDD));
    generic_nmos I_182(.D(I_279_D), .G(I_1250_G), .S(VSS));
  not auto_524(I_1250_G, I_311_D); // NMOS strength = 2
    generic_pmos I_215(.D(VDD), .G(I_311_D), .S(I_1250_G));
    generic_pmos I_247(.D(I_1250_G), .G(I_311_D), .S(VDD));
    generic_nmos I_214(.D(VSS), .G(I_311_D), .S(I_1250_G));
    generic_nmos I_246(.D(I_1250_G), .G(I_311_D), .S(VSS));
// Shared Driver
  not auto_646(I_315_D, I_251_S); // NMOS strength = 2
    generic_pmos I_283(.D(VDD), .G(I_251_S), .S(I_315_D));
    generic_pmos I_315(.D(I_315_D), .G(I_251_S), .S(VDD));
    generic_nmos I_282(.D(VSS), .G(I_251_S), .S(I_315_D));
    generic_nmos I_314(.D(I_315_D), .G(I_251_S), .S(VSS));

// ********************************************************************************************************

// Video output circuitry - Palette to outputs (See Page 16, Top)

// FG/BG bit stream here, combines flashing clock with video.
// Video signal on 1250_G

// Mix flash and video
  nand auto_305(I_1091_D, I_389_S, I_1985_S);
    generic_pmos I_1059(.D(VDD), .G(I_1985_S), .S(I_1091_D));
    generic_pmos I_1091(.D(I_1091_D), .G(I_389_S), .S(VDD));
    generic_nmos I_1058(.D(I_1091_D), .G(I_389_S), .S(I_1090_D));
    generic_nmos I_1090(.D(I_1090_D), .G(I_1985_S), .S(VSS));
  nand auto_336(I_1251_D, I_1091_D, I_1250_G);
    generic_pmos I_1219(.D(VDD), .G(I_1250_G), .S(I_1251_D));
    generic_pmos I_1251(.D(I_1251_D), .G(I_1091_D), .S(VDD));
    generic_nmos I_1218(.D(I_1251_D), .G(I_1091_D), .S(I_1250_D));
    generic_nmos I_1250(.D(I_1250_D), .G(I_1250_G), .S(VSS));
  not auto_335(I_1249_D, I_1251_D); // NMOS strength = 2
    generic_pmos I_1217(.D(VDD), .G(I_1251_D), .S(I_1249_D));
    generic_pmos I_1249(.D(I_1249_D), .G(I_1251_D), .S(VDD));
    generic_nmos I_1216(.D(VSS), .G(I_1251_D), .S(I_1249_D));
    generic_nmos I_1248(.D(I_1249_D), .G(I_1251_D), .S(VSS));

// Video output: Reverse/Inverse video flag

// This is not a serial attribute, it comes along with each individual character/pixel set in (bit 7==1)

// 2 Ganged D-Type latches (common control clock)
// In 1 chain of 2 series devices (Ob)
// Chain (Ob)
// D-Type Flip Flop D: I_1355_D Q: I_1195_D ~Q: I_1227_D Rising Clock: I_245_D
// D-Type katch D: I_1355_D ~Q: I_1259_S Q: I_1225_D Clock: I_245_D
// 2:1 Mux with single control: Inputs: I_1225_D, I_1355_D Output: I_1193_G Control: I_245_D
  generic_cmos pass_15(.gn(I_245_D), .gp(I_1099_S), .p1(I_1225_D), .p2(I_1193_G));
    generic_pmos I_1225(.D(I_1225_D), .G(I_1099_S), .S(I_1193_G));
    generic_nmos I_1224(.D(I_1225_D), .G(I_245_D), .S(I_1193_G));
  generic_cmos pass_26(.gn(I_1099_S), .gp(I_245_D), .p1(I_1193_G), .p2(I_1355_D));
    generic_pmos I_1257(.D(I_1193_G), .G(I_245_D), .S(I_1355_D));
    generic_nmos I_1256(.D(I_1193_G), .G(I_1099_S), .S(I_1355_D));
  not auto_326(I_1259_S, I_1193_G); // NMOS strength = 2
    generic_pmos I_1161(.D(VDD), .G(I_1193_G), .S(I_1259_S));
    generic_pmos I_1193(.D(I_1259_S), .G(I_1193_G), .S(VDD));
    generic_nmos I_1160(.D(VSS), .G(I_1193_G), .S(I_1259_S));
    generic_nmos I_1192(.D(I_1259_S), .G(I_1193_G), .S(VSS));
  not auto_315(I_1225_D, I_1259_S);
    generic_pmos I_1129(.D(I_1225_D), .G(I_1259_S), .S(VDD));
    generic_nmos I_1128(.D(I_1225_D), .G(I_1259_S), .S(VSS));
// D-Type latch D: I_1259_S ~Q: I_1195_D Q: I_1227_D Clock: I_245_D
// 2:1 Mux with single control: Inputs: I_1227_D, I_1259_S Output: I_1259_D Control: I_245_D
  generic_cmos pass_16(.gn(I_1099_S), .gp(I_245_D), .p1(I_1227_D), .p2(I_1259_D));
    generic_pmos I_1227(.D(I_1227_D), .G(I_245_D), .S(I_1259_D));
    generic_nmos I_1226(.D(I_1227_D), .G(I_1099_S), .S(I_1259_D));
  generic_cmos pass_27(.gn(I_245_D), .gp(I_1099_S), .p1(I_1259_D), .p2(I_1259_S));
    generic_pmos I_1259(.D(I_1259_D), .G(I_1099_S), .S(I_1259_S));
    generic_nmos I_1258(.D(I_1259_D), .G(I_245_D), .S(I_1259_S));
  not auto_316(I_1227_D, I_1195_D);
    generic_pmos I_1131(.D(I_1227_D), .G(I_1195_D), .S(VDD));
    generic_nmos I_1130(.D(I_1227_D), .G(I_1195_D), .S(VSS));
  not auto_327(I_1195_D, I_1259_D); // NMOS strength = 2
    generic_pmos I_1163(.D(VDD), .G(I_1259_D), .S(I_1195_D));
    generic_pmos I_1195(.D(I_1195_D), .G(I_1259_D), .S(VDD));
    generic_nmos I_1162(.D(VSS), .G(I_1259_D), .S(I_1195_D));
    generic_nmos I_1194(.D(I_1195_D), .G(I_1259_D), .S(VSS));
// Shared Driver
  not auto_309(I_1099_S, I_245_D);
    generic_pmos I_1099(.D(VDD), .G(I_245_D), .S(I_1099_S));
    generic_nmos I_1066(.D(I_1099_S), .G(I_245_D), .S(VSS));

// Invert control signal
  nand auto_378(I_1483_D, I_1195_D, VDD);
    // Warning: Actually INVERTER with one input tied VDD
    generic_pmos I_1451(.D(VDD), .G(I_1195_D), .S(I_1483_D));
    generic_pmos I_1483(.D(I_1483_D), .G(VDD), .S(VDD));
    generic_nmos I_1450(.D(I_1483_D), .G(I_1195_D), .S(I_1482_D));
    generic_nmos I_1482(.D(I_1482_D), .G(VDD), .S(VSS));
// Pointless: NAND mux picks between signal and itself?? (I_1515_S)
// Was this part of an original "inverse video" which simply swapped INK for PAPER
// rather than complementing colours later?
  not auto_395(I_1515_S, I_1483_D);
    generic_pmos I_1515(.D(VDD), .G(I_1483_D), .S(I_1515_S));
    generic_nmos I_1514(.D(VSS), .G(I_1483_D), .S(I_1515_S));
  nand auto_427(I_1737_D, I_1515_S, I_1609_D);
    generic_pmos I_1705(.D(VDD), .G(I_1515_S), .S(I_1737_D));
    generic_pmos I_1737(.D(I_1737_D), .G(I_1609_D), .S(VDD));
    generic_nmos I_1736(.D(I_1736_D), .G(I_1515_S), .S(I_1737_D));
    generic_nmos I_1704(.D(VSS), .G(I_1609_D), .S(I_1736_D));
  nand auto_418(I_1673_D, I_1515_S, I_1249_D);
    generic_pmos I_1641(.D(VDD), .G(I_1249_D), .S(I_1673_D));
    generic_pmos I_1673(.D(I_1673_D), .G(I_1515_S), .S(VDD));
    generic_nmos I_1672(.D(I_1672_D), .G(I_1515_S), .S(I_1673_D));
    generic_nmos I_1640(.D(VSS), .G(I_1249_D), .S(I_1672_D));
  not auto_409(I_1609_D, I_1249_D);
    generic_pmos I_1609(.D(I_1609_D), .G(I_1249_D), .S(VDD));
    generic_nmos I_1608(.D(I_1609_D), .G(I_1249_D), .S(VSS));
  nand auto_444(I_1832_D, I_1737_D, I_1673_D);
    generic_pmos I_1769(.D(VDD), .G(I_1673_D), .S(I_1832_D));
    generic_pmos I_1801(.D(I_1832_D), .G(I_1737_D), .S(VDD));
    generic_nmos I_1800(.D(I_1800_D), .G(I_1737_D), .S(I_1832_D));
    generic_nmos I_1768(.D(VSS), .G(I_1673_D), .S(I_1800_D));

// Video output: HBlanking

// 2 Ganged D-Type latches (common control clock)
// In 1 chain of 2 series devices (P)
// D Input is Horizontal blank HBLANK signal
// Chain (P)
// D-Type Flip Flop D: I_2275_D Q: I_1667_D ~Q: I_1699_D Rising Clock: I_245_D
// D-Type latch D: I_2275_D ~Q: I_1731_S Q: I_1697_D Clock: I_245_D
// 2:1 Mux with single control: Inputs: I_1697_D, I_2275_D Output: I_1729_D Control: I_245_D
  generic_cmos pass_70(.gn(I_245_D), .gp(I_1761_D), .p1(I_1697_D), .p2(I_1729_D));
    generic_pmos I_1697(.D(I_1697_D), .G(I_1761_D), .S(I_1729_D));
    generic_nmos I_1696(.D(I_1697_D), .G(I_245_D), .S(I_1729_D));
  generic_cmos pass_74(.gn(I_1761_D), .gp(I_245_D), .p1(I_1729_D), .p2(I_2275_D));
    generic_pmos I_1729(.D(I_1729_D), .G(I_245_D), .S(I_2275_D));
    generic_nmos I_1728(.D(I_1729_D), .G(I_1761_D), .S(I_2275_D));
  not auto_405(I_1697_D, I_1731_S);
    generic_pmos I_1601(.D(I_1697_D), .G(I_1731_S), .S(VDD));
    generic_nmos I_1600(.D(I_1697_D), .G(I_1731_S), .S(VSS));
  not auto_415(I_1731_S, I_1729_D); // NMOS strength = 2
    generic_pmos I_1633(.D(VDD), .G(I_1729_D), .S(I_1731_S));
    generic_pmos I_1665(.D(I_1731_S), .G(I_1729_D), .S(VDD));
    generic_nmos I_1632(.D(VSS), .G(I_1729_D), .S(I_1731_S));
    generic_nmos I_1664(.D(I_1731_S), .G(I_1729_D), .S(VSS));
// D-Type latch D: I_1731_S ~Q: I_1667_D Q: I_1699_D Clock: I_245_D
// 2:1 Mux with single control: Inputs: I_1699_D, I_1731_S Output: I_1731_D Control: I_245_D
  generic_cmos pass_71(.gn(I_1761_D), .gp(I_245_D), .p1(I_1699_D), .p2(I_1731_D));
    generic_pmos I_1699(.D(I_1699_D), .G(I_245_D), .S(I_1731_D));
    generic_nmos I_1698(.D(I_1699_D), .G(I_1761_D), .S(I_1731_D));
  generic_cmos pass_75(.gn(I_245_D), .gp(I_1761_D), .p1(I_1731_D), .p2(I_1731_S));
    generic_pmos I_1731(.D(I_1731_D), .G(I_1761_D), .S(I_1731_S));
    generic_nmos I_1730(.D(I_1731_D), .G(I_245_D), .S(I_1731_S));
  not auto_406(I_1699_D, I_1667_D);
    generic_pmos I_1603(.D(I_1699_D), .G(I_1667_D), .S(VDD));
    generic_nmos I_1602(.D(I_1699_D), .G(I_1667_D), .S(VSS));
  not auto_416(I_1667_D, I_1731_D); // NMOS strength = 2
    generic_pmos I_1635(.D(VDD), .G(I_1731_D), .S(I_1667_D));
    generic_pmos I_1667(.D(I_1667_D), .G(I_1731_D), .S(VDD));
    generic_nmos I_1634(.D(VSS), .G(I_1731_D), .S(I_1667_D));
    generic_nmos I_1666(.D(I_1667_D), .G(I_1731_D), .S(VSS));
// Shared Driver
  not auto_440(I_1761_D, I_245_D);
    generic_pmos I_1761(.D(I_1761_D), .G(I_245_D), .S(VDD));
    generic_nmos I_1760(.D(I_1761_D), .G(I_245_D), .S(VSS));

// Combine HBLANK and VBLANK
  nand auto_304(I_1089_D, I_1667_D, I_2371_S);
    generic_pmos I_1057(.D(VDD), .G(I_1667_D), .S(I_1089_D));
    generic_pmos I_1089(.D(I_1089_D), .G(I_2371_S), .S(VDD));
    generic_nmos I_1056(.D(I_1089_D), .G(I_2371_S), .S(I_1088_D));
    generic_nmos I_1088(.D(I_1088_D), .G(I_1667_D), .S(VSS));

// Video RGB output:
//
// See top comments for note on original mislabelling of external pins: This is now correct.
//
// In Oric, from a software point of view, bit 0 is RED, bit 1 is GREEN bit, bit 2 is BLUE. Hence ordering of colours (0-7)
// Black, Red, Green, Yellow (R+G), Blue, Magenta (B+R), Cyan (B+G), White (R+G+B).
// 
// However, the pin for BLUE video traced back to an ink/paper reg that loads from b0 ... GREEN from b1, RED from b2 ...
// ... which is not logical.
// 
// This has exposed an error in the official Oric Schematic. Pinout at top of this document is correct
// and consistent with the ACTUAL pinout of SK2 (Video) as per Oric Basic Manual.

// Video output: Whole Blue channel.
// Starts from 1 bit each of the flipflop (registers) that hold the ink-paper colours (2 x 3 bit values in total)
// Then selects between FG and BG based on the video bitstream
// Then applies inverse video to reverse the RGB value of whatever colour selected
// And finally blank it out when doing borders

// Pick blue output based on FG/BG from ink-paper reg
  nand auto_983(I_995_D, I_1349_D, I_1249_D);
    generic_pmos I_963(.D(VDD), .G(I_1349_D), .S(I_995_D));
    generic_pmos I_995(.D(I_995_D), .G(I_1249_D), .S(VDD));
    generic_nmos I_962(.D(I_995_D), .G(I_1349_D), .S(I_994_D));
    generic_nmos I_994(.D(I_994_D), .G(I_1249_D), .S(VSS));
  nand auto_979(I_931_D, I_1027_S, I_869_S);
    generic_pmos I_899(.D(VDD), .G(I_869_S), .S(I_931_D));
    generic_pmos I_931(.D(I_931_D), .G(I_1027_S), .S(VDD));
    generic_nmos I_898(.D(I_931_D), .G(I_1027_S), .S(I_930_D));
    generic_nmos I_930(.D(I_930_D), .G(I_869_S), .S(VSS));
  not auto_298(I_1027_S, I_1249_D);
    generic_pmos I_1027(.D(VDD), .G(I_1249_D), .S(I_1027_S));
    generic_nmos I_1026(.D(VSS), .G(I_1249_D), .S(I_1027_S));
  nand auto_969(I_867_D, I_995_D, I_931_D);
    generic_pmos I_835(.D(VDD), .G(I_931_D), .S(I_867_D));
    generic_pmos I_867(.D(I_867_D), .G(I_995_D), .S(VDD));
    generic_nmos I_866(.D(I_866_D), .G(I_995_D), .S(I_867_D));
    generic_nmos I_834(.D(VSS), .G(I_931_D), .S(I_866_D));
// Reverse the colour
  nand auto_978(I_929_D, I_867_D, I_1832_D);
    generic_pmos I_897(.D(VDD), .G(I_1832_D), .S(I_929_D));
    generic_pmos I_929(.D(I_929_D), .G(I_867_D), .S(VDD));
    generic_nmos I_928(.D(I_928_D), .G(I_1832_D), .S(I_929_D));
    generic_nmos I_896(.D(VSS), .G(I_867_D), .S(I_928_D));
// OR-AND-Invert: Verilog called these "or + nand" conjoined. See diagram. First 4 transistors are a NOR
// Output: I_865_D
  or auto_968(auto_net_4, I_1832_D, I_867_D);
    generic_pmos I_801(.D(VDD), .G(I_1832_D), .S(I_833_D));
    generic_pmos I_833(.D(I_833_D), .G(I_867_D), .S(I_865_D));
    generic_nmos I_800(.D(I_864_D), .G(I_1832_D), .S(I_865_D));
    generic_nmos I_832(.D(I_865_D), .G(I_867_D), .S(I_864_D));
// These two transistors adjust the NOR output -- half a NAND?
  nand auto_967(I_865_D, I_929_D, auto_net_4);
    generic_pmos I_865(.D(I_865_D), .G(I_929_D), .S(VDD));
    generic_nmos I_864(.D(I_864_D), .G(I_929_D), .S(VSS));
// Apply Blanking
  nor auto_956(I_768_D, I_1089_D, I_865_D);
    generic_pmos I_769(.D(I_769_D), .G(I_865_D), .S(VDD));
    generic_pmos I_737(.D(I_768_D), .G(I_1089_D), .S(I_769_D));
    generic_nmos I_736(.D(VSS), .G(I_865_D), .S(I_768_D));
    generic_nmos I_768(.D(I_768_D), .G(I_1089_D), .S(VSS));

// Video output: Whole green channel.
// Starts from 1 bit each of the flipflop (registers) that hold the ink-paper colours (2 x 3 bit values in total)
// Then selects between FG and BG based on the video bitstream
// Then applies inverse video to reverse the RGB value of whatever colour selected
// And finally blank it out when doing borders

// Pick green output based on FG/BG from ink-paper reg
  nand auto_930(I_611_D, I_707_S, I_709_S);
    generic_pmos I_579(.D(VDD), .G(I_709_S), .S(I_611_D));
    generic_pmos I_611(.D(I_611_D), .G(I_707_S), .S(VDD));
    generic_nmos I_578(.D(I_611_D), .G(I_707_S), .S(I_610_D));
    generic_nmos I_610(.D(I_610_D), .G(I_709_S), .S(VSS));
  nand auto_934(I_675_D, I_1189_D, I_1249_D);
    generic_pmos I_643(.D(VDD), .G(I_1189_D), .S(I_675_D));
    generic_pmos I_675(.D(I_675_D), .G(I_1249_D), .S(VDD));
    generic_nmos I_642(.D(I_675_D), .G(I_1189_D), .S(I_674_D));
    generic_nmos I_674(.D(I_674_D), .G(I_1249_D), .S(VSS));
  not auto_950(I_707_S, I_1249_D);
    generic_pmos I_707(.D(VDD), .G(I_1249_D), .S(I_707_S));
    generic_nmos I_706(.D(VSS), .G(I_1249_D), .S(I_707_S));
  nand auto_922(I_547_D, I_611_D, I_675_D);
    generic_pmos I_515(.D(VDD), .G(I_611_D), .S(I_547_D));
    generic_pmos I_547(.D(I_547_D), .G(I_675_D), .S(VDD));
    generic_nmos I_546(.D(I_546_D), .G(I_675_D), .S(I_547_D));
    generic_nmos I_514(.D(VSS), .G(I_611_D), .S(I_546_D));
// Reverse the colour
  nand auto_929(I_609_D, I_1832_D, I_547_D);
    generic_pmos I_577(.D(VDD), .G(I_1832_D), .S(I_609_D));
    generic_pmos I_609(.D(I_609_D), .G(I_547_D), .S(VDD));
    generic_nmos I_608(.D(I_608_D), .G(I_1832_D), .S(I_609_D));
    generic_nmos I_576(.D(VSS), .G(I_547_D), .S(I_608_D));
// OR-AND-Invert: Verilog called these "or + nand" conjoined. See diagram. First 4 transistors are a NOR
// Output: I_545_D
  or auto_921(auto_net_3, I_1832_D, I_547_D);
    generic_pmos I_481(.D(VDD), .G(I_1832_D), .S(I_513_D));
    generic_pmos I_513(.D(I_513_D), .G(I_547_D), .S(I_545_D));
    generic_nmos I_480(.D(I_544_D), .G(I_1832_D), .S(I_545_D));
    generic_nmos I_512(.D(I_545_D), .G(I_547_D), .S(I_544_D));
// These two transistors adjust the NOR output -- half a NAND?
  nand auto_920(I_545_D, I_609_D, auto_net_3);
    generic_pmos I_545(.D(I_545_D), .G(I_609_D), .S(VDD));
    generic_nmos I_544(.D(I_544_D), .G(I_609_D), .S(VSS));
// Apply Blanking
  nor auto_905(I_448_D, I_1089_D, I_545_D);
    generic_pmos I_449(.D(I_449_D), .G(I_545_D), .S(VDD));
    generic_pmos I_417(.D(I_448_D), .G(I_1089_D), .S(I_449_D));
    generic_nmos I_416(.D(VSS), .G(I_545_D), .S(I_448_D));
    generic_nmos I_448(.D(I_448_D), .G(I_1089_D), .S(VSS));

// Video output: Whole red channel.
// Starts from 1 bit each of the flipflop (registers) that hold the ink-paper colours (2 x 3 bit values in total)
// Then selects between FG and BG based on the video bitstream
// Then applies inverse video to reverse the RGB value of whatever colour selected
// And finally blank it out when doing borders

// Pick red output based on FG/BG from ink-paper reg
  nand auto_723(I_355_D, I_1029_D, I_1249_D);
    generic_pmos I_323(.D(VDD), .G(I_1029_D), .S(I_355_D));
    generic_pmos I_355(.D(I_355_D), .G(I_1249_D), .S(VDD));
    generic_nmos I_322(.D(I_355_D), .G(I_1029_D), .S(I_354_D));
    generic_nmos I_354(.D(I_354_D), .G(I_1249_D), .S(VSS));
  nand auto_609(I_291_D, I_387_S, I_549_S);
    generic_pmos I_259(.D(VDD), .G(I_549_S), .S(I_291_D));
    generic_pmos I_291(.D(I_291_D), .G(I_387_S), .S(VDD));
    generic_nmos I_258(.D(I_291_D), .G(I_387_S), .S(I_290_D));
    generic_nmos I_290(.D(I_290_D), .G(I_549_S), .S(VSS));
  not auto_870(I_387_S, I_1249_D);
    generic_pmos I_387(.D(VDD), .G(I_1249_D), .S(I_387_S));
    generic_nmos I_386(.D(VSS), .G(I_1249_D), .S(I_387_S));
  nand auto_488(I_227_D, I_355_D, I_291_D);
    generic_pmos I_195(.D(VDD), .G(I_291_D), .S(I_227_D));
    generic_pmos I_227(.D(I_227_D), .G(I_355_D), .S(VDD));
    generic_nmos I_226(.D(I_226_D), .G(I_355_D), .S(I_227_D));
    generic_nmos I_194(.D(VSS), .G(I_291_D), .S(I_226_D));
// Reverse the colour
  nand auto_603(I_289_D, I_1832_D, I_227_D);
    generic_pmos I_257(.D(VDD), .G(I_1832_D), .S(I_289_D));
    generic_pmos I_289(.D(I_289_D), .G(I_227_D), .S(VDD));
    generic_nmos I_288(.D(I_288_D), .G(I_1832_D), .S(I_289_D));
    generic_nmos I_256(.D(VSS), .G(I_227_D), .S(I_288_D));
// OR-AND-Invert: Verilog called these "or + nand" conjoined. See diagram. First 4 transistors are a NOR
// Output: I_225_D
  or auto_480(auto_net_1, I_1832_D, I_227_D);
    generic_pmos I_161(.D(VDD), .G(I_1832_D), .S(I_193_D));
    generic_pmos I_193(.D(I_193_D), .G(I_227_D), .S(I_225_D));
    generic_nmos I_160(.D(I_224_D), .G(I_1832_D), .S(I_225_D));
    generic_nmos I_192(.D(I_225_D), .G(I_227_D), .S(I_224_D));
// These two transistors adjust the NOR output -- half a NAND?
  nand auto_479(I_225_D, auto_net_1, I_289_D);
    generic_pmos I_225(.D(I_225_D), .G(I_289_D), .S(VDD));
    generic_nmos I_224(.D(I_224_D), .G(I_289_D), .S(VSS));
// Apply Blanking
  nor auto_987(I_128_D, I_1089_D, I_225_D);
    generic_pmos I_129(.D(I_129_D), .G(I_225_D), .S(VDD));
    generic_pmos I_97(.D(I_128_D), .G(I_1089_D), .S(I_129_D));
    generic_nmos I_128(.D(I_128_D), .G(I_1089_D), .S(VSS));
    generic_nmos I_96(.D(VSS), .G(I_225_D), .S(I_128_D));

// Extra bit on red channel only, split drive into two (allow for tristate/input P19 at correct times on 1_3_G/~CSYNC)
  not auto_937(I_65_S, I_128_D);
    generic_pmos I_65(.D(VDD), .G(I_128_D), .S(I_65_S));
    generic_nmos I_64(.D(VSS), .G(I_128_D), .S(I_65_S));
  nor auto_943(I_67_S, I_3_D, I_65_S);
    generic_pmos I_35(.D(VDD), .G(I_3_D), .S(I_67_D));
    generic_pmos I_67(.D(I_67_D), .G(I_65_S), .S(I_67_S));
    generic_nmos I_34(.D(VSS), .G(I_3_D), .S(I_67_S));
    generic_nmos I_66(.D(I_67_S), .G(I_65_S), .S(VSS));
  nand auto_290(I_33_D, I_3_G, I_65_S);
    generic_pmos I_1(.D(VDD), .G(I_3_G), .S(I_33_D));
    generic_pmos I_33(.D(I_33_D), .G(I_65_S), .S(VDD));
    generic_nmos I_0(.D(I_33_D), .G(I_3_G), .S(I_32_D));
    generic_nmos I_32(.D(I_32_D), .G(I_65_S), .S(VSS));
  not auto_675(I_3_D, I_3_G);
    generic_pmos I_3(.D(I_3_D), .G(I_3_G), .S(VDD));
    generic_nmos I_2(.D(I_3_D), .G(I_3_G), .S(VSS));

// Video -- Sync circuit
// Takes 50/60Hz VSYNC selected timing signal, combines HSYNC into it, to get COMPSYNC

// Combine HSYNC
  nand auto_465(I_1889_D, I_1987_D, I_2535_G);
    generic_pmos I_1857(.D(VDD), .G(I_2535_G), .S(I_1889_D));
    generic_pmos I_1889(.D(I_1889_D), .G(I_1987_D), .S(VDD));
    generic_nmos I_1856(.D(I_1889_D), .G(I_1987_D), .S(I_1888_D));
    generic_nmos I_1888(.D(I_1888_D), .G(I_2535_G), .S(VSS));

// ********************************************************************************************************

// CAS Suppression (See Page 17)

// Allows generation of CAS output signal (which completes a read or write: RAS precedes it)
// CAS is ...
// Allowed by    MAP signal NOT asserted (when addr=#0000-#BFFF) -- normal access to RAM.
// Suppressed by MAP signal NOT asserted (when addr=#C000-#FFFF) -- normal access to ROM.
//
// Suppressed by MAP signal asserted (when addr=#0000-#BFFF) -- External peripheral on bus!
// Allowed by    MAP signal asserted     (when addr=#C000-#FFFF) -- allows writes to shadow RAM
  nand auto_826(I_3753_D, I_3969_S, I_3133_D, I_3847_G);
    generic_pmos I_3689(.D(I_3753_D), .G(I_3133_D), .S(VDD));
    generic_pmos I_3721(.D(VDD), .G(I_3969_S), .S(I_3753_D));
    generic_pmos I_3753(.D(I_3753_D), .G(I_3847_G), .S(VDD));
    generic_nmos I_3688(.D(I_3753_D), .G(I_3133_D), .S(I_3720_D));
    generic_nmos I_3720(.D(I_3720_D), .G(I_3969_S), .S(I_3752_D));
    generic_nmos I_3752(.D(I_3752_D), .G(I_3847_G), .S(VSS));
  nand auto_850(I_3817_D, I_3847_D, I_3971_S);
    generic_pmos I_3785(.D(VDD), .G(I_3971_S), .S(I_3817_D));
    generic_pmos I_3817(.D(I_3817_D), .G(I_3847_D), .S(VDD));
    generic_nmos I_3784(.D(I_3817_D), .G(I_3847_D), .S(I_3816_D));
    generic_nmos I_3816(.D(I_3816_D), .G(I_3971_S), .S(VSS));
  nand auto_888(I_3977_D, I_3971_S, I_3915_S);
    generic_pmos I_3945(.D(VDD), .G(I_3915_S), .S(I_3977_D));
    generic_pmos I_3977(.D(I_3977_D), .G(I_3971_S), .S(VDD));
    generic_nmos I_3944(.D(I_3977_D), .G(I_3971_S), .S(I_3976_D));
    generic_nmos I_3976(.D(I_3976_D), .G(I_3915_S), .S(VSS));
  not auto_862(I_3847_D, I_3847_G);
    generic_pmos I_3847(.D(I_3847_D), .G(I_3847_G), .S(VDD));
    generic_nmos I_3846(.D(I_3847_D), .G(I_3847_G), .S(VSS));
  not auto_897(I_3969_S, I_3971_S);
    generic_pmos I_3969(.D(VDD), .G(I_3971_S), .S(I_3969_S));
    generic_nmos I_3936(.D(I_3969_S), .G(I_3971_S), .S(VSS));
  not auto_880(I_3915_S, I_3133_D);
    generic_pmos I_3915(.D(VDD), .G(I_3133_D), .S(I_3915_S));
    generic_nmos I_3914(.D(VSS), .G(I_3133_D), .S(I_3915_S));
  nand auto_863(I_3913_S, I_3753_D, I_3817_D, I_3977_D);
    generic_pmos I_3849(.D(VDD), .G(I_3817_D), .S(I_3913_S));
    generic_pmos I_3881(.D(I_3913_S), .G(I_3753_D), .S(VDD));
    generic_pmos I_3913(.D(VDD), .G(I_3977_D), .S(I_3913_S));
    generic_nmos I_3912(.D(I_3912_D), .G(I_3977_D), .S(I_3913_S));
    generic_nmos I_3880(.D(I_3880_D), .G(I_3753_D), .S(I_3912_D));
    generic_nmos I_3848(.D(VSS), .G(I_3817_D), .S(I_3880_D));
  nand auto_887(I_3975_D, I_3755_S, I_3974_G);
    generic_pmos I_3943(.D(VDD), .G(I_3974_G), .S(I_3975_D));
    generic_pmos I_3975(.D(I_3975_D), .G(I_3755_S), .S(VDD));
    generic_nmos I_3974(.D(I_3974_D), .G(I_3974_G), .S(I_3975_D));
    generic_nmos I_3942(.D(VSS), .G(I_3755_S), .S(I_3974_D));
  nand auto_802(I_3585_D, I_3975_D, I_3913_S);
    generic_pmos I_3553(.D(VDD), .G(I_3913_S), .S(I_3585_D));
    generic_pmos I_3585(.D(I_3585_D), .G(I_3975_D), .S(VDD));
    generic_nmos I_3584(.D(I_3584_D), .G(I_3975_D), .S(I_3585_D));
    generic_nmos I_3552(.D(VSS), .G(I_3913_S), .S(I_3584_D));
  not auto_338(I_1267_S, I_3585_D);
    generic_pmos I_1231(.D(I_1267_S), .G(I_3585_D), .S(VDD));
    generic_nmos I_1262(.D(VSS), .G(I_3585_D), .S(I_1267_S));

// ********************************************************************************************************

// Address decoding: (See Page 17)

// ~ROMSEL output enables system ROM in 0xC000-0xFxxx when A15-A14=1, when ~MAP=High (not asserted) and R/~W is high

// This is a four input NAND gate not identified in original verilog (due to offgrid wires)
// Manually reassembled after nets merged
// I_3884_D = capacitor, not 738/in
// I_3529_D = not 791/out, not 881/in 
// I_3971_S = nand 850/in, nand 888/in, not 897/in, not 898/out
// I_3983_D = nand 758/in, not 882/in, not 891/out
// I_3659_S = nand 695/in, not 819/out, not 827/in
  nand manual_1(I_3884_D, I_3529_D, I_3971_S, I_3983_D, I_3659_S);
    generic_pmos I_3853(.D(I_3884_D), .G(I_3529_D), .S(VDD));
    generic_pmos I_3789(.D(VDD), .G(I_3971_S), .S(I_3884_D));
    generic_pmos I_3821(.D(I_3884_D), .G(I_3983_D), .S(VDD));
    generic_pmos I_3757(.D(VDD), .G(I_3659_S), .S(I_3884_D));
    generic_nmos I_3852(.D(I_3852_D), .G(I_3529_D), .S(I_3884_D));
    generic_nmos I_3820(.D(I_3820_D), .G(I_3971_S), .S(I_3852_D));
    generic_nmos I_3788(.D(I_3788_D), .G(I_3983_D), .S(I_3820_D));
    generic_nmos I_3756(.D(VSS), .G(I_3659_S), .S(I_3788_D));
// N-FET as capacitor for output of NAND M1 (?)
// Maybe layout artefact as other half is 3885 (supply bypass)
    generic_nmos I_3884(.D(I_3884_D), .G(VSS), .S(VSS));

// Address decoding: IO output enables 6522 VIA (and other peripherals) in 0x03XX when A15-A10=0, A9-A8=1
  nor auto_843(I_3755_S, I_3883_D, I_3725_D);
    generic_pmos I_3723(.D(VDD), .G(I_3725_D), .S(I_3755_D));
    generic_pmos I_3755(.D(I_3755_D), .G(I_3883_D), .S(I_3755_S));
    generic_nmos I_3722(.D(VSS), .G(I_3725_D), .S(I_3755_S));
    generic_nmos I_3754(.D(I_3755_S), .G(I_3883_D), .S(VSS));
  nand auto_851(I_3883_D, I_3988_S, I_3861_D, I_3851_G, I_3887_D);
    generic_pmos I_3787(.D(I_3883_D), .G(I_3988_S), .S(VDD));
    generic_pmos I_3819(.D(VDD), .G(I_3861_D), .S(I_3883_D));
    generic_pmos I_3851(.D(VDD), .G(I_3851_G), .S(I_3883_D));
    generic_pmos I_3883(.D(I_3883_D), .G(I_3887_D), .S(VDD));
    generic_nmos I_3786(.D(I_3883_D), .G(I_3861_D), .S(I_3818_D));
    generic_nmos I_3818(.D(I_3818_D), .G(I_3988_S), .S(I_3850_D));
    generic_nmos I_3850(.D(I_3850_D), .G(I_3851_G), .S(I_3882_D));
    generic_nmos I_3882(.D(I_3882_D), .G(I_3887_D), .S(VSS));
  nand auto_814(I_3725_D, I_3595_S, I_3919_S, I_3691_D, I_3859_D);
    generic_pmos I_3629(.D(I_3725_D), .G(I_3919_S), .S(VDD));
    generic_pmos I_3661(.D(VDD), .G(I_3595_S), .S(I_3725_D));
    generic_pmos I_3693(.D(VDD), .G(I_3691_D), .S(I_3725_D));
    generic_pmos I_3725(.D(I_3725_D), .G(I_3859_D), .S(VDD));
    generic_nmos I_3628(.D(I_3725_D), .G(I_3595_S), .S(I_3660_D));
    generic_nmos I_3660(.D(I_3660_D), .G(I_3919_S), .S(I_3692_D));
    generic_nmos I_3692(.D(I_3692_D), .G(I_3691_D), .S(I_3724_D));
    generic_nmos I_3724(.D(I_3724_D), .G(I_3859_D), .S(VSS));
  not auto_865(I_3861_D, I_1631_G);
    generic_pmos I_3861(.D(I_3861_D), .G(I_1631_G), .S(VDD));
    generic_nmos I_3860(.D(I_3861_D), .G(I_1631_G), .S(VSS));
  not auto_874(I_3887_D, I_3987_S);
    generic_pmos I_3887(.D(I_3887_D), .G(I_3987_S), .S(VDD));
    generic_nmos I_3886(.D(I_3887_D), .G(I_3987_S), .S(VSS));
  not auto_807(I_3595_S, I_3593_S);
    generic_pmos I_3595(.D(VDD), .G(I_3593_S), .S(I_3595_S));
    generic_nmos I_3594(.D(VSS), .G(I_3593_S), .S(I_3595_S));
  not auto_882(I_3919_S, I_3983_D);
    generic_pmos I_3919(.D(VDD), .G(I_3983_D), .S(I_3919_S));
    generic_nmos I_3918(.D(VSS), .G(I_3983_D), .S(I_3919_S));
  not auto_827(I_3691_D, I_3659_S);
    generic_pmos I_3691(.D(I_3691_D), .G(I_3659_S), .S(VDD));
    generic_nmos I_3690(.D(I_3691_D), .G(I_3659_S), .S(VSS));
  not auto_864(I_3859_D, I_3923_S);
    generic_pmos I_3859(.D(I_3859_D), .G(I_3923_S), .S(VDD));
    generic_nmos I_3858(.D(I_3859_D), .G(I_3923_S), .S(VSS));

// ********************************************************************************************************

// Other non logic structures

// FET pair as apparent capacitors to both rails (Artefact of layout of neighbouring transistors)

// I'm now considering these as "unused" transistors, they have no obvious purpose or pattern

// These are on signal lines

    generic_pmos I_1655(.D(VDD), .G(I_151_D), .S(VDD));
    generic_nmos I_1654(.D(VSS), .G(I_151_D), .S(VSS));

    generic_pmos I_1747(.D(VDD), .G(I_2151_S), .S(VDD));
    generic_nmos I_1714(.D(VSS), .G(I_2151_S), .S(VSS));

    generic_pmos I_2349(.D(VDD), .G(I_3337_D), .S(VDD));
    generic_nmos I_2380(.D(VSS), .G(I_3337_D), .S(VSS));

    generic_pmos I_2541(.D(VDD), .G(I_3591_S), .S(VDD));
    generic_nmos I_2508(.D(VSS), .G(I_3591_S), .S(VSS));

    generic_pmos I_2769(.D(VDD), .G(I_3065_D), .S(VDD));
    generic_nmos I_2768(.D(VSS), .G(I_3065_D), .S(VSS));

    generic_pmos I_2803(.D(VDD), .G(I_2709_S), .S(VDD));
    generic_nmos I_2802(.D(VSS), .G(I_2709_S), .S(VSS));

    generic_pmos I_2927(.D(VDD), .G(I_3065_D), .S(VDD));
    generic_nmos I_2926(.D(VSS), .G(I_3065_D), .S(VSS));

    generic_pmos I_3273(.D(VDD), .G(I_3591_S), .S(VDD));
    generic_nmos I_3272(.D(VSS), .G(I_3591_S), .S(VSS));

    generic_pmos I_3275(.D(VDD), .G(I_3591_S), .S(VDD));
    generic_nmos I_3274(.D(VSS), .G(I_3591_S), .S(VSS));

    generic_pmos I_3373(.D(VDD), .G(I_3659_S), .S(VDD));
    generic_nmos I_3372(.D(VSS), .G(I_3659_S), .S(VSS));

    generic_pmos I_3891(.D(VDD), .G(I_3861_D), .S(VDD));
    generic_nmos I_3890(.D(VSS), .G(I_3861_D), .S(VSS));

// These are not even on a signal line.

    generic_pmos I_1019(.D(VDD), .G(I_1019_G), .S(VDD));
    generic_nmos I_1018(.D(VSS), .G(I_1019_G), .S(VSS));

    generic_pmos I_1183(.D(VDD), .G(I_1183_G), .S(VDD));
    generic_nmos I_1182(.D(VSS), .G(I_1183_G), .S(VSS));

    generic_pmos I_1329(.D(VDD), .G(I_1329_G), .S(VDD));
    generic_nmos I_1328(.D(VSS), .G(I_1329_G), .S(VSS));

    generic_pmos I_2135(.D(VDD), .G(I_2135_G), .S(VDD));
    generic_nmos I_2134(.D(VSS), .G(I_2135_G), .S(VSS));

    generic_pmos I_2285(.D(VDD), .G(I_2285_G), .S(VDD));
    generic_nmos I_2284(.D(VSS), .G(I_2285_G), .S(VSS));

    generic_pmos I_2295(.D(VDD), .G(I_2295_G), .S(VDD));
    generic_nmos I_2294(.D(VSS), .G(I_2295_G), .S(VSS));

    generic_pmos I_2767(.D(VDD), .G(I_2767_G), .S(VDD));
    generic_nmos I_2766(.D(VSS), .G(I_2767_G), .S(VSS));

    generic_pmos I_2773(.D(VDD), .G(I_2773_G), .S(VDD));
    generic_nmos I_2772(.D(VSS), .G(I_2773_G), .S(VSS));

    generic_pmos I_3091(.D(VDD), .G(I_3091_G), .S(VDD));
    generic_nmos I_3090(.D(VSS), .G(I_3091_G), .S(VSS));

    generic_pmos I_3093(.D(VDD), .G(I_3093_G), .S(VDD));
    generic_nmos I_3092(.D(VSS), .G(I_3093_G), .S(VSS));

    generic_pmos I_3095(.D(VDD), .G(I_3095_G), .S(VDD));
    generic_nmos I_3094(.D(VSS), .G(I_3095_G), .S(VSS));

    generic_pmos I_3251(.D(VDD), .G(I_3251_G), .S(VDD));
    generic_nmos I_3250(.D(VSS), .G(I_3251_G), .S(VSS));

    generic_pmos I_3401(.D(VDD), .G(I_3401_G), .S(VDD));
    generic_nmos I_3400(.D(VSS), .G(I_3401_G), .S(VSS));

    generic_pmos I_3403(.D(VDD), .G(I_3403_G), .S(VDD));
    generic_nmos I_3402(.D(VSS), .G(I_3403_G), .S(VSS));

    generic_pmos I_3411(.D(VDD), .G(I_3411_G), .S(VDD));
    generic_nmos I_3410(.D(VSS), .G(I_3411_G), .S(VSS));

    generic_pmos I_3561(.D(VDD), .G(I_3561_G), .S(VDD));
    generic_nmos I_3560(.D(VSS), .G(I_3561_G), .S(VSS));

    generic_pmos I_3567(.D(VDD), .G(I_3567_G), .S(VDD));
    generic_nmos I_3566(.D(VSS), .G(I_3567_G), .S(VSS));

    generic_pmos I_361(.D(VDD), .G(I_361_G), .S(VDD));
    generic_nmos I_360(.D(VSS), .G(I_361_G), .S(VSS));

    generic_pmos I_3727(.D(VDD), .G(I_3727_G), .S(VDD));
    generic_nmos I_3726(.D(VSS), .G(I_3727_G), .S(VSS));

    generic_pmos I_3731(.D(VDD), .G(I_3731_G), .S(VDD));
    generic_nmos I_3730(.D(VSS), .G(I_3731_G), .S(VSS));

    generic_pmos I_3733(.D(VDD), .G(I_3733_G), .S(VDD));
    generic_nmos I_3732(.D(VSS), .G(I_3733_G), .S(VSS));

    generic_pmos I_381(.D(VDD), .G(I_381_G), .S(VDD));
    generic_nmos I_380(.D(VSS), .G(I_381_G), .S(VSS));

    generic_pmos I_539(.D(VDD), .G(I_539_G), .S(VDD));
    generic_nmos I_538(.D(VSS), .G(I_539_G), .S(VSS));

    generic_pmos I_543(.D(VDD), .G(I_543_G), .S(VDD));
    generic_nmos I_542(.D(VSS), .G(I_543_G), .S(VSS));

    generic_pmos I_55(.D(VDD), .G(I_55_G), .S(VDD));
    generic_nmos I_54(.D(VSS), .G(I_55_G), .S(VSS));

    generic_pmos I_861(.D(VDD), .G(I_861_G), .S(VDD));
    generic_nmos I_860(.D(VSS), .G(I_861_G), .S(VSS));

// ********************************************************************************************************

// Nothing more to see ...
// For reference only below here: These transistors are listed in the verilog file but are definitely not used

// Completely unused cells (full cell)

// Unused 3+2 input cell at [0,4]
  generic_nmos I_8(.D(I_8_D), .G(I_9_G), .S(I_40_D));
  generic_pmos I_9(.D(I_9_D), .G(I_9_G), .S(I_41_D));
  generic_nmos I_40(.D(I_40_D), .G(I_41_G), .S(I_72_D));
  generic_pmos I_41(.D(I_41_D), .G(I_41_G), .S(I_73_D));
  generic_nmos I_72(.D(I_72_D), .G(I_73_G), .S(I_72_S));
  generic_pmos I_73(.D(I_73_D), .G(I_73_G), .S(I_73_S));
  generic_nmos I_104(.D(I_104_D), .G(I_104_G), .S(I_136_D));
  generic_pmos I_105(.D(I_105_D), .G(I_136_G), .S(I_137_D));
  generic_nmos I_136(.D(I_136_D), .G(I_136_G), .S(I_136_S));
  generic_pmos I_137(.D(I_137_D), .G(I_137_G), .S(I_137_S));

// Unused 3+2 input cell at [0,5]
  generic_nmos I_10(.D(I_10_D), .G(I_11_G), .S(I_42_D));
  generic_pmos I_11(.D(I_11_D), .G(I_11_G), .S(I_43_D));
  generic_nmos I_42(.D(I_42_D), .G(I_43_G), .S(I_74_D));
  generic_pmos I_43(.D(I_43_D), .G(I_43_G), .S(I_75_D));
  generic_nmos I_74(.D(I_74_D), .G(I_75_G), .S(I_74_S));
  generic_pmos I_75(.D(I_75_D), .G(I_75_G), .S(I_75_S));
  generic_nmos I_106(.D(I_106_D), .G(I_106_G), .S(I_138_D));
  generic_pmos I_107(.D(I_107_D), .G(I_138_G), .S(I_139_D));
  generic_nmos I_138(.D(I_138_D), .G(I_138_G), .S(I_138_S));
  generic_pmos I_139(.D(I_139_D), .G(I_139_G), .S(I_139_S));

// Unused 3+2 input cell at [0,6]
  generic_nmos I_12(.D(I_12_D), .G(I_13_G), .S(I_44_D));
  generic_pmos I_13(.D(I_13_D), .G(I_13_G), .S(I_45_D));
  generic_nmos I_44(.D(I_44_D), .G(I_45_G), .S(I_76_D));
  generic_pmos I_45(.D(I_45_D), .G(I_45_G), .S(I_77_D));
  generic_nmos I_76(.D(I_76_D), .G(I_77_G), .S(I_76_S));
  generic_pmos I_77(.D(I_77_D), .G(I_77_G), .S(I_77_S));
  generic_nmos I_108(.D(I_108_D), .G(I_108_G), .S(I_140_D));
  generic_pmos I_109(.D(I_109_D), .G(I_140_G), .S(I_141_D));
  generic_nmos I_140(.D(I_140_D), .G(I_140_G), .S(I_140_S));
  generic_pmos I_141(.D(I_141_D), .G(I_141_G), .S(I_141_S));

// Unused 3+2 input cell at [0,7]
  generic_nmos I_14(.D(I_14_D), .G(I_15_G), .S(I_46_D));
  generic_pmos I_15(.D(I_15_D), .G(I_15_G), .S(I_47_D));
  generic_nmos I_46(.D(I_46_D), .G(I_47_G), .S(I_78_D));
  generic_pmos I_47(.D(I_47_D), .G(I_47_G), .S(I_79_D));
  generic_nmos I_78(.D(I_78_D), .G(I_79_G), .S(I_78_S));
  generic_pmos I_79(.D(I_79_D), .G(I_79_G), .S(I_79_S));
  generic_nmos I_110(.D(I_110_D), .G(I_110_G), .S(I_142_D));
  generic_pmos I_111(.D(I_111_D), .G(I_142_G), .S(I_143_D));
  generic_nmos I_142(.D(I_142_D), .G(I_142_G), .S(I_142_S));
  generic_pmos I_143(.D(I_143_D), .G(I_143_G), .S(I_143_S));

// Unused 3+2 input cell at [0,8]
  generic_nmos I_16(.D(I_16_D), .G(I_17_G), .S(I_48_D));
  generic_pmos I_17(.D(I_17_D), .G(I_17_G), .S(I_49_D));
  generic_nmos I_48(.D(I_48_D), .G(I_49_G), .S(I_80_D));
  generic_pmos I_49(.D(I_49_D), .G(I_49_G), .S(I_81_D));
  generic_nmos I_80(.D(I_80_D), .G(I_81_G), .S(I_80_S));
  generic_pmos I_81(.D(I_81_D), .G(I_81_G), .S(I_81_S));
  generic_nmos I_112(.D(I_112_D), .G(I_112_G), .S(I_144_D));
  generic_pmos I_113(.D(I_113_D), .G(I_144_G), .S(I_145_D));
  generic_nmos I_144(.D(I_144_D), .G(I_144_G), .S(I_144_S));
  generic_pmos I_145(.D(I_145_D), .G(I_145_G), .S(I_145_S));

// Unused 3+2 input cell at [0,9]
  generic_nmos I_18(.D(I_18_D), .G(I_19_G), .S(I_50_D));
  generic_pmos I_19(.D(I_19_D), .G(I_19_G), .S(I_51_D));
  generic_nmos I_50(.D(I_50_D), .G(I_51_G), .S(I_82_D));
  generic_pmos I_51(.D(I_51_D), .G(I_51_G), .S(I_83_D));
  generic_nmos I_82(.D(I_82_D), .G(I_83_G), .S(I_82_S));
  generic_pmos I_83(.D(I_83_D), .G(I_83_G), .S(I_83_S));
  generic_nmos I_114(.D(I_114_D), .G(I_114_G), .S(I_146_D));
  generic_pmos I_115(.D(I_115_D), .G(I_146_G), .S(I_147_D));
  generic_nmos I_146(.D(I_146_D), .G(I_146_G), .S(I_146_S));
  generic_pmos I_147(.D(I_147_D), .G(I_147_G), .S(I_147_S));

// Unused 3+2 input cell at [1,6]
  generic_nmos I_172(.D(I_172_D), .G(I_173_G), .S(I_204_D));
  generic_pmos I_173(.D(I_173_D), .G(I_173_G), .S(I_205_D));
  generic_nmos I_204(.D(I_204_D), .G(I_205_G), .S(I_236_D));
  generic_pmos I_205(.D(I_205_D), .G(I_205_G), .S(I_237_D));
  generic_nmos I_236(.D(I_236_D), .G(I_237_G), .S(I_236_S));
  generic_pmos I_237(.D(I_237_D), .G(I_237_G), .S(I_237_S));
  generic_nmos I_268(.D(I_268_D), .G(I_268_G), .S(I_300_D));
  generic_pmos I_269(.D(I_269_D), .G(I_300_G), .S(I_301_D));
  generic_nmos I_300(.D(I_300_D), .G(I_300_G), .S(I_300_S));
  generic_pmos I_301(.D(I_301_D), .G(I_301_G), .S(I_301_S));

// Unused 3+2 input cell at [1,7]
  generic_nmos I_174(.D(I_174_D), .G(I_175_G), .S(I_206_D));
  generic_pmos I_175(.D(I_175_D), .G(I_175_G), .S(I_207_D));
  generic_nmos I_206(.D(I_206_D), .G(I_207_G), .S(I_238_D));
  generic_pmos I_207(.D(I_207_D), .G(I_207_G), .S(I_239_D));
  generic_nmos I_238(.D(I_238_D), .G(I_239_G), .S(I_238_S));
  generic_pmos I_239(.D(I_239_D), .G(I_239_G), .S(I_239_S));
  generic_nmos I_270(.D(I_270_D), .G(I_270_G), .S(I_302_D));
  generic_pmos I_271(.D(I_271_D), .G(I_302_G), .S(I_303_D));
  generic_nmos I_302(.D(I_302_D), .G(I_302_G), .S(I_302_S));
  generic_pmos I_303(.D(I_303_D), .G(I_303_G), .S(I_303_S));

// Unused 3+2 input cell at [1,8]
  generic_nmos I_176(.D(I_176_D), .G(I_177_G), .S(I_208_D));
  generic_pmos I_177(.D(I_177_D), .G(I_177_G), .S(I_209_D));
  generic_nmos I_208(.D(I_208_D), .G(I_209_G), .S(I_240_D));
  generic_pmos I_209(.D(I_209_D), .G(I_209_G), .S(I_241_D));
  generic_nmos I_240(.D(I_240_D), .G(I_241_G), .S(I_240_S));
  generic_pmos I_241(.D(I_241_D), .G(I_241_G), .S(I_241_S));
  generic_nmos I_272(.D(I_272_D), .G(I_272_G), .S(I_304_D));
  generic_pmos I_273(.D(I_273_D), .G(I_304_G), .S(I_305_D));
  generic_nmos I_304(.D(I_304_D), .G(I_304_G), .S(I_304_S));
  generic_pmos I_305(.D(I_305_D), .G(I_305_G), .S(I_305_S));

// Unused 3+2 input cell at [1,9]
  generic_nmos I_178(.D(I_178_D), .G(I_179_G), .S(I_210_D));
  generic_pmos I_179(.D(I_179_D), .G(I_179_G), .S(I_211_D));
  generic_nmos I_210(.D(I_210_D), .G(I_211_G), .S(I_242_D));
  generic_pmos I_211(.D(I_211_D), .G(I_211_G), .S(I_243_D));
  generic_nmos I_242(.D(I_242_D), .G(I_243_G), .S(I_242_S));
  generic_pmos I_243(.D(I_243_D), .G(I_243_G), .S(I_243_S));
  generic_nmos I_274(.D(I_274_D), .G(I_274_G), .S(I_306_D));
  generic_pmos I_275(.D(I_275_D), .G(I_306_G), .S(I_307_D));
  generic_nmos I_306(.D(I_306_D), .G(I_306_G), .S(I_306_S));
  generic_pmos I_307(.D(I_307_D), .G(I_307_G), .S(I_307_S));

// Unused 3+2 input cell at [2,7]
  generic_nmos I_334(.D(I_334_D), .G(I_335_G), .S(I_366_D));
  generic_pmos I_335(.D(I_335_D), .G(I_335_G), .S(I_367_D));
  generic_nmos I_366(.D(I_366_D), .G(I_367_G), .S(I_398_D));
  generic_pmos I_367(.D(I_367_D), .G(I_367_G), .S(I_399_D));
  generic_nmos I_398(.D(I_398_D), .G(I_399_G), .S(I_398_S));
  generic_pmos I_399(.D(I_399_D), .G(I_399_G), .S(I_399_S));
  generic_nmos I_430(.D(I_430_D), .G(I_430_G), .S(I_462_D));
  generic_pmos I_431(.D(I_431_D), .G(I_462_G), .S(I_463_D));
  generic_nmos I_462(.D(I_462_D), .G(I_462_G), .S(I_462_S));
  generic_pmos I_463(.D(I_463_D), .G(I_463_G), .S(I_463_S));

// Unused 3+2 input cell at [2,8]
  generic_nmos I_336(.D(I_336_D), .G(I_337_G), .S(I_368_D));
  generic_pmos I_337(.D(I_337_D), .G(I_337_G), .S(I_369_D));
  generic_nmos I_368(.D(I_368_D), .G(I_369_G), .S(I_400_D));
  generic_pmos I_369(.D(I_369_D), .G(I_369_G), .S(I_401_D));
  generic_nmos I_400(.D(I_400_D), .G(I_401_G), .S(I_400_S));
  generic_pmos I_401(.D(I_401_D), .G(I_401_G), .S(I_401_S));
  generic_nmos I_432(.D(I_432_D), .G(I_432_G), .S(I_464_D));
  generic_pmos I_433(.D(I_433_D), .G(I_464_G), .S(I_465_D));
  generic_nmos I_464(.D(I_464_D), .G(I_464_G), .S(I_464_S));
  generic_pmos I_465(.D(I_465_D), .G(I_465_G), .S(I_465_S));

// Unused 3+2 input cell at [2,9]
  generic_nmos I_338(.D(I_338_D), .G(I_339_G), .S(I_370_D));
  generic_pmos I_339(.D(I_339_D), .G(I_339_G), .S(I_371_D));
  generic_nmos I_370(.D(I_370_D), .G(I_371_G), .S(I_402_D));
  generic_pmos I_371(.D(I_371_D), .G(I_371_G), .S(I_403_D));
  generic_nmos I_402(.D(I_402_D), .G(I_403_G), .S(I_402_S));
  generic_pmos I_403(.D(I_403_D), .G(I_403_G), .S(I_403_S));
  generic_nmos I_434(.D(I_434_D), .G(I_434_G), .S(I_466_D));
  generic_pmos I_435(.D(I_435_D), .G(I_466_G), .S(I_467_D));
  generic_nmos I_466(.D(I_466_D), .G(I_466_G), .S(I_466_S));
  generic_pmos I_467(.D(I_467_D), .G(I_467_G), .S(I_467_S));

// Unused 3+2 input cell at [3,7]
  generic_nmos I_494(.D(I_494_D), .G(I_495_G), .S(I_526_D));
  generic_pmos I_495(.D(I_495_D), .G(I_495_G), .S(I_527_D));
  generic_nmos I_526(.D(I_526_D), .G(I_527_G), .S(I_558_D));
  generic_pmos I_527(.D(I_527_D), .G(I_527_G), .S(I_559_D));
  generic_nmos I_558(.D(I_558_D), .G(I_559_G), .S(I_558_S));
  generic_pmos I_559(.D(I_559_D), .G(I_559_G), .S(I_559_S));
  generic_nmos I_590(.D(I_590_D), .G(I_590_G), .S(I_622_D));
  generic_pmos I_591(.D(I_591_D), .G(I_622_G), .S(I_623_D));
  generic_nmos I_622(.D(I_622_D), .G(I_622_G), .S(I_622_S));
  generic_pmos I_623(.D(I_623_D), .G(I_623_G), .S(I_623_S));

// Unused 3+2 input cell at [3,8]
  generic_nmos I_496(.D(I_496_D), .G(I_497_G), .S(I_528_D));
  generic_pmos I_497(.D(I_497_D), .G(I_497_G), .S(I_529_D));
  generic_nmos I_528(.D(I_528_D), .G(I_529_G), .S(I_560_D));
  generic_pmos I_529(.D(I_529_D), .G(I_529_G), .S(I_561_D));
  generic_nmos I_560(.D(I_560_D), .G(I_561_G), .S(I_560_S));
  generic_pmos I_561(.D(I_561_D), .G(I_561_G), .S(I_561_S));
  generic_nmos I_592(.D(I_592_D), .G(I_592_G), .S(I_624_D));
  generic_pmos I_593(.D(I_593_D), .G(I_624_G), .S(I_625_D));
  generic_nmos I_624(.D(I_624_D), .G(I_624_G), .S(I_624_S));
  generic_pmos I_625(.D(I_625_D), .G(I_625_G), .S(I_625_S));

// Unused 3+2 input cell at [3,9]
  generic_nmos I_498(.D(I_498_D), .G(I_499_G), .S(I_530_D));
  generic_pmos I_499(.D(I_499_D), .G(I_499_G), .S(I_531_D));
  generic_nmos I_530(.D(I_530_D), .G(I_531_G), .S(I_562_D));
  generic_pmos I_531(.D(I_531_D), .G(I_531_G), .S(I_563_D));
  generic_nmos I_562(.D(I_562_D), .G(I_563_G), .S(I_562_S));
  generic_pmos I_563(.D(I_563_D), .G(I_563_G), .S(I_563_S));
  generic_nmos I_594(.D(I_594_D), .G(I_594_G), .S(I_626_D));
  generic_pmos I_595(.D(I_595_D), .G(I_626_G), .S(I_627_D));
  generic_nmos I_626(.D(I_626_D), .G(I_626_G), .S(I_626_S));
  generic_pmos I_627(.D(I_627_D), .G(I_627_G), .S(I_627_S));

// Unused 3+2 input cell at [3,10]
  generic_nmos I_500(.D(I_500_D), .G(I_501_G), .S(I_532_D));
  generic_pmos I_501(.D(I_501_D), .G(I_501_G), .S(I_533_D));
  generic_nmos I_532(.D(I_532_D), .G(I_533_G), .S(I_564_D));
  generic_pmos I_533(.D(I_533_D), .G(I_533_G), .S(I_565_D));
  generic_nmos I_564(.D(I_564_D), .G(I_565_G), .S(I_564_S));
  generic_pmos I_565(.D(I_565_D), .G(I_565_G), .S(I_565_S));
  generic_nmos I_596(.D(I_596_D), .G(I_596_G), .S(I_628_D));
  generic_pmos I_597(.D(I_597_D), .G(I_628_G), .S(I_629_D));
  generic_nmos I_628(.D(I_628_D), .G(I_628_G), .S(I_628_S));
  generic_pmos I_629(.D(I_629_D), .G(I_629_G), .S(I_629_S));

// Unused 3+2 input cell at [4,6]
  generic_nmos I_652(.D(I_652_D), .G(I_653_G), .S(I_684_D));
  generic_pmos I_653(.D(I_653_D), .G(I_653_G), .S(I_685_D));
  generic_nmos I_684(.D(I_684_D), .G(I_685_G), .S(I_716_D));
  generic_pmos I_685(.D(I_685_D), .G(I_685_G), .S(I_717_D));
  generic_nmos I_716(.D(I_716_D), .G(I_717_G), .S(I_716_S));
  generic_pmos I_717(.D(I_717_D), .G(I_717_G), .S(I_717_S));
  generic_nmos I_748(.D(I_748_D), .G(I_748_G), .S(I_780_D));
  generic_pmos I_749(.D(I_749_D), .G(I_780_G), .S(I_781_D));
  generic_nmos I_780(.D(I_780_D), .G(I_780_G), .S(I_780_S));
  generic_pmos I_781(.D(I_781_D), .G(I_781_G), .S(I_781_S));

// Unused 3+2 input cell at [4,7]
  generic_nmos I_654(.D(I_654_D), .G(I_655_G), .S(I_686_D));
  generic_pmos I_655(.D(I_655_D), .G(I_655_G), .S(I_687_D));
  generic_nmos I_686(.D(I_686_D), .G(I_687_G), .S(I_718_D));
  generic_pmos I_687(.D(I_687_D), .G(I_687_G), .S(I_719_D));
  generic_nmos I_718(.D(I_718_D), .G(I_719_G), .S(I_718_S));
  generic_pmos I_719(.D(I_719_D), .G(I_719_G), .S(I_719_S));
  generic_nmos I_750(.D(I_750_D), .G(I_750_G), .S(I_782_D));
  generic_pmos I_751(.D(I_751_D), .G(I_782_G), .S(I_783_D));
  generic_nmos I_782(.D(I_782_D), .G(I_782_G), .S(I_782_S));
  generic_pmos I_783(.D(I_783_D), .G(I_783_G), .S(I_783_S));

// Unused 3+2 input cell at [4,8]
  generic_nmos I_656(.D(I_656_D), .G(I_657_G), .S(I_688_D));
  generic_pmos I_657(.D(I_657_D), .G(I_657_G), .S(I_689_D));
  generic_nmos I_688(.D(I_688_D), .G(I_689_G), .S(I_720_D));
  generic_pmos I_689(.D(I_689_D), .G(I_689_G), .S(I_721_D));
  generic_nmos I_720(.D(I_720_D), .G(I_721_G), .S(I_720_S));
  generic_pmos I_721(.D(I_721_D), .G(I_721_G), .S(I_721_S));
  generic_nmos I_752(.D(I_752_D), .G(I_752_G), .S(I_784_D));
  generic_pmos I_753(.D(I_753_D), .G(I_784_G), .S(I_785_D));
  generic_nmos I_784(.D(I_784_D), .G(I_784_G), .S(I_784_S));
  generic_pmos I_785(.D(I_785_D), .G(I_785_G), .S(I_785_S));

// Unused 3+2 input cell at [4,9]
  generic_nmos I_658(.D(I_658_D), .G(I_659_G), .S(I_690_D));
  generic_pmos I_659(.D(I_659_D), .G(I_659_G), .S(I_691_D));
  generic_nmos I_690(.D(I_690_D), .G(I_691_G), .S(I_722_D));
  generic_pmos I_691(.D(I_691_D), .G(I_691_G), .S(I_723_D));
  generic_nmos I_722(.D(I_722_D), .G(I_723_G), .S(I_722_S));
  generic_pmos I_723(.D(I_723_D), .G(I_723_G), .S(I_723_S));
  generic_nmos I_754(.D(I_754_D), .G(I_754_G), .S(I_786_D));
  generic_pmos I_755(.D(I_755_D), .G(I_786_G), .S(I_787_D));
  generic_nmos I_786(.D(I_786_D), .G(I_786_G), .S(I_786_S));
  generic_pmos I_787(.D(I_787_D), .G(I_787_G), .S(I_787_S));

// Unused 3+2 input cell at [5,5]
  generic_nmos I_810(.D(I_810_D), .G(I_811_G), .S(I_842_D));
  generic_pmos I_811(.D(I_811_D), .G(I_811_G), .S(I_843_D));
  generic_nmos I_842(.D(I_842_D), .G(I_843_G), .S(I_874_D));
  generic_pmos I_843(.D(I_843_D), .G(I_843_G), .S(I_875_D));
  generic_nmos I_874(.D(I_874_D), .G(I_875_G), .S(I_874_S));
  generic_pmos I_875(.D(I_875_D), .G(I_875_G), .S(I_875_S));
  generic_nmos I_906(.D(I_906_D), .G(I_906_G), .S(I_938_D));
  generic_pmos I_907(.D(I_907_D), .G(I_938_G), .S(I_939_D));
  generic_nmos I_938(.D(I_938_D), .G(I_938_G), .S(I_938_S));
  generic_pmos I_939(.D(I_939_D), .G(I_939_G), .S(I_939_S));

// Unused 3+2 input cell at [5,6]
  generic_nmos I_812(.D(I_812_D), .G(I_813_G), .S(I_844_D));
  generic_pmos I_813(.D(I_813_D), .G(I_813_G), .S(I_845_D));
  generic_nmos I_844(.D(I_844_D), .G(I_845_G), .S(I_876_D));
  generic_pmos I_845(.D(I_845_D), .G(I_845_G), .S(I_877_D));
  generic_nmos I_876(.D(I_876_D), .G(I_877_G), .S(I_876_S));
  generic_pmos I_877(.D(I_877_D), .G(I_877_G), .S(I_877_S));
  generic_nmos I_908(.D(I_908_D), .G(I_908_G), .S(I_940_D));
  generic_pmos I_909(.D(I_909_D), .G(I_940_G), .S(I_941_D));
  generic_nmos I_940(.D(I_940_D), .G(I_940_G), .S(I_940_S));
  generic_pmos I_941(.D(I_941_D), .G(I_941_G), .S(I_941_S));

// Unused 3+2 input cell at [5,7]
  generic_nmos I_814(.D(I_814_D), .G(I_815_G), .S(I_846_D));
  generic_pmos I_815(.D(I_815_D), .G(I_815_G), .S(I_847_D));
  generic_nmos I_846(.D(I_846_D), .G(I_847_G), .S(I_878_D));
  generic_pmos I_847(.D(I_847_D), .G(I_847_G), .S(I_879_D));
  generic_nmos I_878(.D(I_878_D), .G(I_879_G), .S(I_878_S));
  generic_pmos I_879(.D(I_879_D), .G(I_879_G), .S(I_879_S));
  generic_nmos I_910(.D(I_910_D), .G(I_910_G), .S(I_942_D));
  generic_pmos I_911(.D(I_911_D), .G(I_942_G), .S(I_943_D));
  generic_nmos I_942(.D(I_942_D), .G(I_942_G), .S(I_942_S));
  generic_pmos I_943(.D(I_943_D), .G(I_943_G), .S(I_943_S));

// Unused 3+2 input cell at [5,8]
  generic_nmos I_816(.D(I_816_D), .G(I_817_G), .S(I_848_D));
  generic_pmos I_817(.D(I_817_D), .G(I_817_G), .S(I_849_D));
  generic_nmos I_848(.D(I_848_D), .G(I_849_G), .S(I_880_D));
  generic_pmos I_849(.D(I_849_D), .G(I_849_G), .S(I_881_D));
  generic_nmos I_880(.D(I_880_D), .G(I_881_G), .S(I_880_S));
  generic_pmos I_881(.D(I_881_D), .G(I_881_G), .S(I_881_S));
  generic_nmos I_912(.D(I_912_D), .G(I_912_G), .S(I_944_D));
  generic_pmos I_913(.D(I_913_D), .G(I_944_G), .S(I_945_D));
  generic_nmos I_944(.D(I_944_D), .G(I_944_G), .S(I_944_S));
  generic_pmos I_945(.D(I_945_D), .G(I_945_G), .S(I_945_S));

// Unused 3+2 input cell at [5,9]
  generic_nmos I_818(.D(I_818_D), .G(I_819_G), .S(I_850_D));
  generic_pmos I_819(.D(I_819_D), .G(I_819_G), .S(I_851_D));
  generic_nmos I_850(.D(I_850_D), .G(I_851_G), .S(I_882_D));
  generic_pmos I_851(.D(I_851_D), .G(I_851_G), .S(I_883_D));
  generic_nmos I_882(.D(I_882_D), .G(I_883_G), .S(I_882_S));
  generic_pmos I_883(.D(I_883_D), .G(I_883_G), .S(I_883_S));
  generic_nmos I_914(.D(I_914_D), .G(I_914_G), .S(I_946_D));
  generic_pmos I_915(.D(I_915_D), .G(I_946_G), .S(I_947_D));
  generic_nmos I_946(.D(I_946_D), .G(I_946_G), .S(I_946_S));
  generic_pmos I_947(.D(I_947_D), .G(I_947_G), .S(I_947_S));

// Unused 3+2 input cell at [6,8]
  generic_nmos I_976(.D(I_976_D), .G(I_977_G), .S(I_1008_D));
  generic_pmos I_977(.D(I_977_D), .G(I_977_G), .S(I_1009_D));
  generic_nmos I_1008(.D(I_1008_D), .G(I_1009_G), .S(I_1040_D));
  generic_pmos I_1009(.D(I_1009_D), .G(I_1009_G), .S(I_1041_D));
  generic_nmos I_1040(.D(I_1040_D), .G(I_1041_G), .S(I_1040_S));
  generic_pmos I_1041(.D(I_1041_D), .G(I_1041_G), .S(I_1041_S));
  generic_nmos I_1072(.D(I_1072_D), .G(I_1072_G), .S(I_1104_D));
  generic_pmos I_1073(.D(I_1073_D), .G(I_1104_G), .S(I_1105_D));
  generic_nmos I_1104(.D(I_1104_D), .G(I_1104_G), .S(I_1104_S));
  generic_pmos I_1105(.D(I_1105_D), .G(I_1105_G), .S(I_1105_S));

// Unused 3+2 input cell at [6,9]
  generic_nmos I_978(.D(I_978_D), .G(I_979_G), .S(I_1010_D));
  generic_pmos I_979(.D(I_979_D), .G(I_979_G), .S(I_1011_D));
  generic_nmos I_1010(.D(I_1010_D), .G(I_1011_G), .S(I_1042_D));
  generic_pmos I_1011(.D(I_1011_D), .G(I_1011_G), .S(I_1043_D));
  generic_nmos I_1042(.D(I_1042_D), .G(I_1043_G), .S(I_1042_S));
  generic_pmos I_1043(.D(I_1043_D), .G(I_1043_G), .S(I_1043_S));
  generic_nmos I_1074(.D(I_1074_D), .G(I_1074_G), .S(I_1106_D));
  generic_pmos I_1075(.D(I_1075_D), .G(I_1106_G), .S(I_1107_D));
  generic_nmos I_1106(.D(I_1106_D), .G(I_1106_G), .S(I_1106_S));
  generic_pmos I_1107(.D(I_1107_D), .G(I_1107_G), .S(I_1107_S));

// Unused 3+2 input cell at [9,6]
  generic_nmos I_1452(.D(I_1452_D), .G(I_1453_G), .S(I_1484_D));
  generic_pmos I_1453(.D(I_1453_D), .G(I_1453_G), .S(I_1485_D));
  generic_nmos I_1484(.D(I_1484_D), .G(I_1485_G), .S(I_1516_D));
  generic_pmos I_1485(.D(I_1485_D), .G(I_1485_G), .S(I_1517_D));
  generic_nmos I_1516(.D(I_1516_D), .G(I_1517_G), .S(I_1516_S));
  generic_pmos I_1517(.D(I_1517_D), .G(I_1517_G), .S(I_1517_S));
  generic_nmos I_1548(.D(I_1548_D), .G(I_1548_G), .S(I_1580_D));
  generic_pmos I_1549(.D(I_1549_D), .G(I_1580_G), .S(I_1581_D));
  generic_nmos I_1580(.D(I_1580_D), .G(I_1580_G), .S(I_1580_S));
  generic_pmos I_1581(.D(I_1581_D), .G(I_1581_G), .S(I_1581_S));

// Unused 3+2 input cell at [10,5]
  generic_nmos I_1610(.D(I_1610_D), .G(I_1611_G), .S(I_1642_D));
  generic_pmos I_1611(.D(I_1611_D), .G(I_1611_G), .S(I_1643_D));
  generic_nmos I_1642(.D(I_1642_D), .G(I_1643_G), .S(I_1674_D));
  generic_pmos I_1643(.D(I_1643_D), .G(I_1643_G), .S(I_1675_D));
  generic_nmos I_1674(.D(I_1674_D), .G(I_1675_G), .S(I_1674_S));
  generic_pmos I_1675(.D(I_1675_D), .G(I_1675_G), .S(I_1675_S));
  generic_nmos I_1706(.D(I_1706_D), .G(I_1706_G), .S(I_1738_D));
  generic_pmos I_1707(.D(I_1707_D), .G(I_1738_G), .S(I_1739_D));
  generic_nmos I_1738(.D(I_1738_D), .G(I_1738_G), .S(I_1738_S));
  generic_pmos I_1739(.D(I_1739_D), .G(I_1739_G), .S(I_1739_S));

// Unused 3+2 input cell at [12,4]
  generic_nmos I_1928(.D(I_1928_D), .G(I_1929_G), .S(I_1960_D));
  generic_pmos I_1929(.D(I_1929_D), .G(I_1929_G), .S(I_1961_D));
  generic_nmos I_1960(.D(I_1960_D), .G(I_1961_G), .S(I_1992_D));
  generic_pmos I_1961(.D(I_1961_D), .G(I_1961_G), .S(I_1993_D));
  generic_nmos I_1992(.D(I_1992_D), .G(I_1993_G), .S(I_1992_S));
  generic_pmos I_1993(.D(I_1993_D), .G(I_1993_G), .S(I_1993_S));
  generic_nmos I_2024(.D(I_2024_D), .G(I_2024_G), .S(I_2056_D));
  generic_pmos I_2025(.D(I_2025_D), .G(I_2056_G), .S(I_2057_D));
  generic_nmos I_2056(.D(I_2056_D), .G(I_2056_G), .S(I_2056_S));
  generic_pmos I_2057(.D(I_2057_D), .G(I_2057_G), .S(I_2057_S));

// Unused 3+2 input cell at [12,9]
  generic_nmos I_1938(.D(I_1938_D), .G(I_1939_G), .S(I_1970_D));
  generic_pmos I_1939(.D(I_1939_D), .G(I_1939_G), .S(I_1971_D));
  generic_nmos I_1970(.D(I_1970_D), .G(I_1971_G), .S(I_2002_D));
  generic_pmos I_1971(.D(I_1971_D), .G(I_1971_G), .S(I_2003_D));
  generic_nmos I_2002(.D(I_2002_D), .G(I_2003_G), .S(I_2002_S));
  generic_pmos I_2003(.D(I_2003_D), .G(I_2003_G), .S(I_2003_S));
  generic_nmos I_2034(.D(I_2034_D), .G(I_2034_G), .S(I_2066_D));
  generic_pmos I_2035(.D(I_2035_D), .G(I_2066_G), .S(I_2067_D));
  generic_nmos I_2066(.D(I_2066_D), .G(I_2066_G), .S(I_2066_S));
  generic_pmos I_2067(.D(I_2067_D), .G(I_2067_G), .S(I_2067_S));

// Unused 3+2 input cell at [13,4]
  generic_nmos I_2088(.D(I_2088_D), .G(I_2089_G), .S(I_2120_D));
  generic_pmos I_2089(.D(I_2089_D), .G(I_2089_G), .S(I_2121_D));
  generic_nmos I_2120(.D(I_2120_D), .G(I_2121_G), .S(I_2152_D));
  generic_pmos I_2121(.D(I_2121_D), .G(I_2121_G), .S(I_2153_D));
  generic_nmos I_2152(.D(I_2152_D), .G(I_2153_G), .S(I_2152_S));
  generic_pmos I_2153(.D(I_2153_D), .G(I_2153_G), .S(I_2153_S));
  generic_nmos I_2184(.D(I_2184_D), .G(I_2184_G), .S(I_2216_D));
  generic_pmos I_2185(.D(I_2185_D), .G(I_2216_G), .S(I_2217_D));
  generic_nmos I_2216(.D(I_2216_D), .G(I_2216_G), .S(I_2216_S));
  generic_pmos I_2217(.D(I_2217_D), .G(I_2217_G), .S(I_2217_S));

// Unused 3+2 input cell at [13,9]
  generic_nmos I_2098(.D(I_2098_D), .G(I_2099_G), .S(I_2130_D));
  generic_pmos I_2099(.D(I_2099_D), .G(I_2099_G), .S(I_2131_D));
  generic_nmos I_2130(.D(I_2130_D), .G(I_2131_G), .S(I_2162_D));
  generic_pmos I_2131(.D(I_2131_D), .G(I_2131_G), .S(I_2163_D));
  generic_nmos I_2162(.D(I_2162_D), .G(I_2163_G), .S(I_2162_S));
  generic_pmos I_2163(.D(I_2163_D), .G(I_2163_G), .S(I_2163_S));
  generic_nmos I_2194(.D(I_2194_D), .G(I_2194_G), .S(I_2226_D));
  generic_pmos I_2195(.D(I_2195_D), .G(I_2226_G), .S(I_2227_D));
  generic_nmos I_2226(.D(I_2226_D), .G(I_2226_G), .S(I_2226_S));
  generic_pmos I_2227(.D(I_2227_D), .G(I_2227_G), .S(I_2227_S));

// Unused 3+2 input cell at [14,4]
  generic_nmos I_2248(.D(I_2248_D), .G(I_2249_G), .S(I_2280_D));
  generic_pmos I_2249(.D(I_2249_D), .G(I_2249_G), .S(I_2281_D));
  generic_nmos I_2280(.D(I_2280_D), .G(I_2281_G), .S(I_2312_D));
  generic_pmos I_2281(.D(I_2281_D), .G(I_2281_G), .S(I_2313_D));
  generic_nmos I_2312(.D(I_2312_D), .G(I_2313_G), .S(I_2312_S));
  generic_pmos I_2313(.D(I_2313_D), .G(I_2313_G), .S(I_2313_S));
  generic_nmos I_2344(.D(I_2344_D), .G(I_2344_G), .S(I_2376_D));
  generic_pmos I_2345(.D(I_2345_D), .G(I_2376_G), .S(I_2377_D));
  generic_nmos I_2376(.D(I_2376_D), .G(I_2376_G), .S(I_2376_S));
  generic_pmos I_2377(.D(I_2377_D), .G(I_2377_G), .S(I_2377_S));

// Unused 3+2 input cell at [14,9]
  generic_nmos I_2258(.D(I_2258_D), .G(I_2259_G), .S(I_2290_D));
  generic_pmos I_2259(.D(I_2259_D), .G(I_2259_G), .S(I_2291_D));
  generic_nmos I_2290(.D(I_2290_D), .G(I_2291_G), .S(I_2322_D));
  generic_pmos I_2291(.D(I_2291_D), .G(I_2291_G), .S(I_2323_D));
  generic_nmos I_2322(.D(I_2322_D), .G(I_2323_G), .S(I_2322_S));
  generic_pmos I_2323(.D(I_2323_D), .G(I_2323_G), .S(I_2323_S));
  generic_nmos I_2354(.D(I_2354_D), .G(I_2354_G), .S(I_2386_D));
  generic_pmos I_2355(.D(I_2355_D), .G(I_2386_G), .S(I_2387_D));
  generic_nmos I_2386(.D(I_2386_D), .G(I_2386_G), .S(I_2386_S));
  generic_pmos I_2387(.D(I_2387_D), .G(I_2387_G), .S(I_2387_S));

// Unused 3+2 input cell at [15,4]
  generic_nmos I_2408(.D(I_2408_D), .G(I_2409_G), .S(I_2440_D));
  generic_pmos I_2409(.D(I_2409_D), .G(I_2409_G), .S(I_2441_D));
  generic_nmos I_2440(.D(I_2440_D), .G(I_2441_G), .S(I_2472_D));
  generic_pmos I_2441(.D(I_2441_D), .G(I_2441_G), .S(I_2473_D));
  generic_nmos I_2472(.D(I_2472_D), .G(I_2473_G), .S(I_2472_S));
  generic_pmos I_2473(.D(I_2473_D), .G(I_2473_G), .S(I_2473_S));
  generic_nmos I_2504(.D(I_2504_D), .G(I_2504_G), .S(I_2536_D));
  generic_pmos I_2505(.D(I_2505_D), .G(I_2536_G), .S(I_2537_D));
  generic_nmos I_2536(.D(I_2536_D), .G(I_2536_G), .S(I_2536_S));
  generic_pmos I_2537(.D(I_2537_D), .G(I_2537_G), .S(I_2537_S));

// Unused 3+2 input cell at [15,9]
  generic_nmos I_2418(.D(I_2418_D), .G(I_2419_G), .S(I_2450_D));
  generic_pmos I_2419(.D(I_2419_D), .G(I_2419_G), .S(I_2451_D));
  generic_nmos I_2450(.D(I_2450_D), .G(I_2451_G), .S(I_2482_D));
  generic_pmos I_2451(.D(I_2451_D), .G(I_2451_G), .S(I_2483_D));
  generic_nmos I_2482(.D(I_2482_D), .G(I_2483_G), .S(I_2482_S));
  generic_pmos I_2483(.D(I_2483_D), .G(I_2483_G), .S(I_2483_S));
  generic_nmos I_2514(.D(I_2514_D), .G(I_2514_G), .S(I_2546_D));
  generic_pmos I_2515(.D(I_2515_D), .G(I_2546_G), .S(I_2547_D));
  generic_nmos I_2546(.D(I_2546_D), .G(I_2546_G), .S(I_2546_S));
  generic_pmos I_2547(.D(I_2547_D), .G(I_2547_G), .S(I_2547_S));

// Unused 3+2 input cell at [16,1]
  generic_nmos I_2562(.D(I_2562_D), .G(I_2563_G), .S(I_2594_D));
  generic_pmos I_2563(.D(I_2563_D), .G(I_2563_G), .S(I_2595_D));
  generic_nmos I_2594(.D(I_2594_D), .G(I_2595_G), .S(I_2626_D));
  generic_pmos I_2595(.D(I_2595_D), .G(I_2595_G), .S(I_2627_D));
  generic_nmos I_2626(.D(I_2626_D), .G(I_2627_G), .S(I_2626_S));
  generic_pmos I_2627(.D(I_2627_D), .G(I_2627_G), .S(I_2627_S));
  generic_nmos I_2658(.D(I_2658_D), .G(I_2658_G), .S(I_2690_D));
  generic_pmos I_2659(.D(I_2659_D), .G(I_2690_G), .S(I_2691_D));
  generic_nmos I_2690(.D(I_2690_D), .G(I_2690_G), .S(I_2690_S));
  generic_pmos I_2691(.D(I_2691_D), .G(I_2691_G), .S(I_2691_S));

// Unused 3+2 input cell at [16,6]
  generic_nmos I_2572(.D(I_2572_D), .G(I_2573_G), .S(I_2604_D));
  generic_pmos I_2573(.D(I_2573_D), .G(I_2573_G), .S(I_2605_D));
  generic_nmos I_2604(.D(I_2604_D), .G(I_2605_G), .S(I_2636_D));
  generic_pmos I_2605(.D(I_2605_D), .G(I_2605_G), .S(I_2637_D));
  generic_nmos I_2636(.D(I_2636_D), .G(I_2637_G), .S(I_2636_S));
  generic_pmos I_2637(.D(I_2637_D), .G(I_2637_G), .S(I_2637_S));
  generic_nmos I_2668(.D(I_2668_D), .G(I_2668_G), .S(I_2700_D));
  generic_pmos I_2669(.D(I_2669_D), .G(I_2700_G), .S(I_2701_D));
  generic_nmos I_2700(.D(I_2700_D), .G(I_2700_G), .S(I_2700_S));
  generic_pmos I_2701(.D(I_2701_D), .G(I_2701_G), .S(I_2701_S));

// Unused 3+2 input cell at [16,9]
  generic_nmos I_2578(.D(I_2578_D), .G(I_2579_G), .S(I_2610_D));
  generic_pmos I_2579(.D(I_2579_D), .G(I_2579_G), .S(I_2611_D));
  generic_nmos I_2610(.D(I_2610_D), .G(I_2611_G), .S(I_2642_D));
  generic_pmos I_2611(.D(I_2611_D), .G(I_2611_G), .S(I_2643_D));
  generic_nmos I_2642(.D(I_2642_D), .G(I_2643_G), .S(I_2642_S));
  generic_pmos I_2643(.D(I_2643_D), .G(I_2643_G), .S(I_2643_S));
  generic_nmos I_2674(.D(I_2674_D), .G(I_2674_G), .S(I_2706_D));
  generic_pmos I_2675(.D(I_2675_D), .G(I_2706_G), .S(I_2707_D));
  generic_nmos I_2706(.D(I_2706_D), .G(I_2706_G), .S(I_2706_S));
  generic_pmos I_2707(.D(I_2707_D), .G(I_2707_G), .S(I_2707_S));

// Unused 3+2 input cell at [17,1]
  generic_nmos I_2722(.D(I_2722_D), .G(I_2723_G), .S(I_2754_D));
  generic_pmos I_2723(.D(I_2723_D), .G(I_2723_G), .S(I_2755_D));
  generic_nmos I_2754(.D(I_2754_D), .G(I_2755_G), .S(I_2786_D));
  generic_pmos I_2755(.D(I_2755_D), .G(I_2755_G), .S(I_2787_D));
  generic_nmos I_2786(.D(I_2786_D), .G(I_2787_G), .S(I_2786_S));
  generic_pmos I_2787(.D(I_2787_D), .G(I_2787_G), .S(I_2787_S));
  generic_nmos I_2818(.D(I_2818_D), .G(I_2818_G), .S(I_2850_D));
  generic_pmos I_2819(.D(I_2819_D), .G(I_2850_G), .S(I_2851_D));
  generic_nmos I_2850(.D(I_2850_D), .G(I_2850_G), .S(I_2850_S));
  generic_pmos I_2851(.D(I_2851_D), .G(I_2851_G), .S(I_2851_S));

// Unused 3+2 input cell at [17,4]
  generic_nmos I_2728(.D(I_2728_D), .G(I_2729_G), .S(I_2760_D));
  generic_pmos I_2729(.D(I_2729_D), .G(I_2729_G), .S(I_2761_D));
  generic_nmos I_2760(.D(I_2760_D), .G(I_2761_G), .S(I_2792_D));
  generic_pmos I_2761(.D(I_2761_D), .G(I_2761_G), .S(I_2793_D));
  generic_nmos I_2792(.D(I_2792_D), .G(I_2793_G), .S(I_2792_S));
  generic_pmos I_2793(.D(I_2793_D), .G(I_2793_G), .S(I_2793_S));
  generic_nmos I_2824(.D(I_2824_D), .G(I_2824_G), .S(I_2856_D));
  generic_pmos I_2825(.D(I_2825_D), .G(I_2856_G), .S(I_2857_D));
  generic_nmos I_2856(.D(I_2856_D), .G(I_2856_G), .S(I_2856_S));
  generic_pmos I_2857(.D(I_2857_D), .G(I_2857_G), .S(I_2857_S));

// Unused 3+2 input cell at [17,6]
  generic_nmos I_2732(.D(I_2732_D), .G(I_2733_G), .S(I_2764_D));
  generic_pmos I_2733(.D(I_2733_D), .G(I_2733_G), .S(I_2765_D));
  generic_nmos I_2764(.D(I_2764_D), .G(I_2765_G), .S(I_2796_D));
  generic_pmos I_2765(.D(I_2765_D), .G(I_2765_G), .S(I_2797_D));
  generic_nmos I_2796(.D(I_2796_D), .G(I_2797_G), .S(I_2796_S));
  generic_pmos I_2797(.D(I_2797_D), .G(I_2797_G), .S(I_2797_S));
  generic_nmos I_2828(.D(I_2828_D), .G(I_2828_G), .S(I_2860_D));
  generic_pmos I_2829(.D(I_2829_D), .G(I_2860_G), .S(I_2861_D));
  generic_nmos I_2860(.D(I_2860_D), .G(I_2860_G), .S(I_2860_S));
  generic_pmos I_2861(.D(I_2861_D), .G(I_2861_G), .S(I_2861_S));

// Unused 3+2 input cell at [20,6]
  generic_nmos I_3212(.D(I_3212_D), .G(I_3213_G), .S(I_3244_D));
  generic_pmos I_3213(.D(I_3213_D), .G(I_3213_G), .S(I_3245_D));
  generic_nmos I_3244(.D(I_3244_D), .G(I_3245_G), .S(I_3276_D));
  generic_pmos I_3245(.D(I_3245_D), .G(I_3245_G), .S(I_3277_D));
  generic_nmos I_3276(.D(I_3276_D), .G(I_3277_G), .S(I_3276_S));
  generic_pmos I_3277(.D(I_3277_D), .G(I_3277_G), .S(I_3277_S));
  generic_nmos I_3308(.D(I_3308_D), .G(I_3308_G), .S(I_3340_D));
  generic_pmos I_3309(.D(I_3309_D), .G(I_3340_G), .S(I_3341_D));
  generic_nmos I_3340(.D(I_3340_D), .G(I_3340_G), .S(I_3340_S));
  generic_pmos I_3341(.D(I_3341_D), .G(I_3341_G), .S(I_3341_S));

// Unused half-cells (3-input)

// Unused 3 input half-cell at [0,12]
  generic_nmos I_24(.D(I_24_D), .G(I_25_G), .S(I_56_D));
  generic_pmos I_25(.D(I_25_D), .G(I_25_G), .S(I_57_D));
  generic_nmos I_56(.D(I_56_D), .G(I_57_G), .S(I_88_D));
  generic_pmos I_57(.D(I_57_D), .G(I_57_G), .S(I_89_D));
  generic_nmos I_88(.D(I_88_D), .G(I_89_G), .S(I_88_S));
  generic_pmos I_89(.D(I_89_D), .G(I_89_G), .S(I_89_S));

// Unused 3 input half-cell at [1,4]
  generic_nmos I_168(.D(I_168_D), .G(I_169_G), .S(I_200_D));
  generic_pmos I_169(.D(I_169_D), .G(I_169_G), .S(I_201_D));
  generic_nmos I_200(.D(I_200_D), .G(I_201_G), .S(I_232_D));
  generic_pmos I_201(.D(I_201_D), .G(I_201_G), .S(I_233_D));
  generic_nmos I_232(.D(I_232_D), .G(I_233_G), .S(I_232_S));
  generic_pmos I_233(.D(I_233_D), .G(I_233_G), .S(I_233_S));

// Unused 3 input half-cell at [1,15]
  generic_nmos I_190(.D(I_190_D), .G(I_191_G), .S(I_222_D));
  generic_pmos I_191(.D(I_191_D), .G(I_191_G), .S(I_223_D));
  generic_nmos I_222(.D(I_222_D), .G(I_223_G), .S(I_254_D));
  generic_pmos I_223(.D(I_223_D), .G(I_223_G), .S(I_255_D));
  generic_nmos I_254(.D(I_254_D), .G(I_255_G), .S(I_254_S));
  generic_pmos I_255(.D(I_255_D), .G(I_255_G), .S(I_255_S));

// Unused 3 input half-cell at [2,6]
  generic_nmos I_332(.D(I_332_D), .G(I_333_G), .S(I_364_D));
  generic_pmos I_333(.D(I_333_D), .G(I_333_G), .S(I_365_D));
  generic_nmos I_364(.D(I_364_D), .G(I_365_G), .S(I_396_D));
  generic_pmos I_365(.D(I_365_D), .G(I_365_G), .S(I_397_D));
  generic_nmos I_396(.D(I_396_D), .G(I_397_G), .S(I_396_S));
  generic_pmos I_397(.D(I_397_D), .G(I_397_G), .S(I_397_S));

// Unused 3 input half-cell at [6,5]
  generic_nmos I_970(.D(I_970_D), .G(I_971_G), .S(I_1002_D));
  generic_pmos I_971(.D(I_971_D), .G(I_971_G), .S(I_1003_D));
  generic_nmos I_1002(.D(I_1002_D), .G(I_1003_G), .S(I_1034_D));
  generic_pmos I_1003(.D(I_1003_D), .G(I_1003_G), .S(I_1035_D));
  generic_nmos I_1034(.D(I_1034_D), .G(I_1035_G), .S(I_1034_S));
  generic_pmos I_1035(.D(I_1035_D), .G(I_1035_G), .S(I_1035_S));

// Unused 3 input half-cell at [6,6]
  generic_nmos I_972(.D(I_972_D), .G(I_973_G), .S(I_1004_D));
  generic_pmos I_973(.D(I_973_D), .G(I_973_G), .S(I_1005_D));
  generic_nmos I_1004(.D(I_1004_D), .G(I_1005_G), .S(I_1036_D));
  generic_pmos I_1005(.D(I_1005_D), .G(I_1005_G), .S(I_1037_D));
  generic_nmos I_1036(.D(I_1036_D), .G(I_1037_G), .S(I_1036_S));
  generic_pmos I_1037(.D(I_1037_D), .G(I_1037_G), .S(I_1037_S));

// Unused 3 input half-cell at [7,6]
  generic_nmos I_1132(.D(I_1132_D), .G(I_1133_G), .S(I_1164_D));
  generic_pmos I_1133(.D(I_1133_D), .G(I_1133_G), .S(I_1165_D));
  generic_nmos I_1164(.D(I_1164_D), .G(I_1165_G), .S(I_1196_D));
  generic_pmos I_1165(.D(I_1165_D), .G(I_1165_G), .S(I_1197_D));
  generic_nmos I_1196(.D(I_1196_D), .G(I_1197_G), .S(I_1196_S));
  generic_pmos I_1197(.D(I_1197_D), .G(I_1197_G), .S(I_1197_S));

// Unused 3 input half-cell at [7,8]
  generic_nmos I_1136(.D(I_1136_D), .G(I_1137_G), .S(I_1168_D));
  generic_pmos I_1137(.D(I_1137_D), .G(I_1137_G), .S(I_1169_D));
  generic_nmos I_1168(.D(I_1168_D), .G(I_1169_G), .S(I_1200_D));
  generic_pmos I_1169(.D(I_1169_D), .G(I_1169_G), .S(I_1201_D));
  generic_nmos I_1200(.D(I_1200_D), .G(I_1201_G), .S(I_1200_S));
  generic_pmos I_1201(.D(I_1201_D), .G(I_1201_G), .S(I_1201_S));

// Unused 3 input half-cell at [8,6]
  generic_nmos I_1292(.D(I_1292_D), .G(I_1293_G), .S(I_1324_D));
  generic_pmos I_1293(.D(I_1293_D), .G(I_1293_G), .S(I_1325_D));
  generic_nmos I_1324(.D(I_1324_D), .G(I_1325_G), .S(I_1356_D));
  generic_pmos I_1325(.D(I_1325_D), .G(I_1325_G), .S(I_1357_D));
  generic_nmos I_1356(.D(I_1356_D), .G(I_1357_G), .S(I_1356_S));
  generic_pmos I_1357(.D(I_1357_D), .G(I_1357_G), .S(I_1357_S));

// Unused 3 input half-cell at [9,4]
  generic_nmos I_1448(.D(I_1448_D), .G(I_1449_G), .S(I_1480_D));
  generic_pmos I_1449(.D(I_1449_D), .G(I_1449_G), .S(I_1481_D));
  generic_nmos I_1480(.D(I_1480_D), .G(I_1481_G), .S(I_1512_D));
  generic_pmos I_1481(.D(I_1481_D), .G(I_1481_G), .S(I_1513_D));
  generic_nmos I_1512(.D(I_1512_D), .G(I_1513_G), .S(I_1512_S));
  generic_pmos I_1513(.D(I_1513_D), .G(I_1513_G), .S(I_1513_S));

// Unused 3 input half-cell at [9,8]
  generic_nmos I_1456(.D(I_1456_D), .G(I_1457_G), .S(I_1488_D));
  generic_pmos I_1457(.D(I_1457_D), .G(I_1457_G), .S(I_1489_D));
  generic_nmos I_1488(.D(I_1488_D), .G(I_1489_G), .S(I_1520_D));
  generic_pmos I_1489(.D(I_1489_D), .G(I_1489_G), .S(I_1521_D));
  generic_nmos I_1520(.D(I_1520_D), .G(I_1521_G), .S(I_1520_S));
  generic_pmos I_1521(.D(I_1521_D), .G(I_1521_G), .S(I_1521_S));

// Unused 3 input half-cell at [10,6]
  generic_nmos I_1612(.D(I_1612_D), .G(I_1613_G), .S(I_1644_D));
  generic_pmos I_1613(.D(I_1613_D), .G(I_1613_G), .S(I_1645_D));
  generic_nmos I_1644(.D(I_1644_D), .G(I_1645_G), .S(I_1676_D));
  generic_pmos I_1645(.D(I_1645_D), .G(I_1645_G), .S(I_1677_D));
  generic_nmos I_1676(.D(I_1676_D), .G(I_1677_G), .S(I_1676_S));
  generic_pmos I_1677(.D(I_1677_D), .G(I_1677_G), .S(I_1677_S));

// Unused 3 input half-cell at [10,9]
  generic_nmos I_1618(.D(I_1618_D), .G(I_1619_G), .S(I_1650_D));
  generic_pmos I_1619(.D(I_1619_D), .G(I_1619_G), .S(I_1651_D));
  generic_nmos I_1650(.D(I_1650_D), .G(I_1651_G), .S(I_1682_D));
  generic_pmos I_1651(.D(I_1651_D), .G(I_1651_G), .S(I_1683_D));
  generic_nmos I_1682(.D(I_1682_D), .G(I_1683_G), .S(I_1682_S));
  generic_pmos I_1683(.D(I_1683_D), .G(I_1683_G), .S(I_1683_S));

// Unused 3 input half-cell at [11,5]
  generic_nmos I_1770(.D(I_1770_D), .G(I_1771_G), .S(I_1802_D));
  generic_pmos I_1771(.D(I_1771_D), .G(I_1771_G), .S(I_1803_D));
  generic_nmos I_1802(.D(I_1802_D), .G(I_1803_G), .S(I_1834_D));
  generic_pmos I_1803(.D(I_1803_D), .G(I_1803_G), .S(I_1835_D));
  generic_nmos I_1834(.D(I_1834_D), .G(I_1835_G), .S(I_1834_S));
  generic_pmos I_1835(.D(I_1835_D), .G(I_1835_G), .S(I_1835_S));

// Unused 3 input half-cell at [11,6]
  generic_nmos I_1772(.D(I_1772_D), .G(I_1773_G), .S(I_1804_D));
  generic_pmos I_1773(.D(I_1773_D), .G(I_1773_G), .S(I_1805_D));
  generic_nmos I_1804(.D(I_1804_D), .G(I_1805_G), .S(I_1836_D));
  generic_pmos I_1805(.D(I_1805_D), .G(I_1805_G), .S(I_1837_D));
  generic_nmos I_1836(.D(I_1836_D), .G(I_1837_G), .S(I_1836_S));
  generic_pmos I_1837(.D(I_1837_D), .G(I_1837_G), .S(I_1837_S));

// Unused 3 input half-cell at [13,8]
  generic_nmos I_2096(.D(I_2096_D), .G(I_2097_G), .S(I_2128_D));
  generic_pmos I_2097(.D(I_2097_D), .G(I_2097_G), .S(I_2129_D));
  generic_nmos I_2128(.D(I_2128_D), .G(I_2129_G), .S(I_2160_D));
  generic_pmos I_2129(.D(I_2129_D), .G(I_2129_G), .S(I_2161_D));
  generic_nmos I_2160(.D(I_2160_D), .G(I_2161_G), .S(I_2160_S));
  generic_pmos I_2161(.D(I_2161_D), .G(I_2161_G), .S(I_2161_S));

// Unused 3 input half-cell at [15,1]
  generic_nmos I_2402(.D(I_2402_D), .G(I_2403_G), .S(I_2434_D));
  generic_pmos I_2403(.D(I_2403_D), .G(I_2403_G), .S(I_2435_D));
  generic_nmos I_2434(.D(I_2434_D), .G(I_2435_G), .S(I_2466_D));
  generic_pmos I_2435(.D(I_2435_D), .G(I_2435_G), .S(I_2467_D));
  generic_nmos I_2466(.D(I_2466_D), .G(I_2467_G), .S(I_2466_S));
  generic_pmos I_2467(.D(I_2467_D), .G(I_2467_G), .S(I_2467_S));

// Unused 3 input half-cell at [15,5]
  generic_nmos I_2410(.D(I_2410_D), .G(I_2411_G), .S(I_2442_D));
  generic_pmos I_2411(.D(I_2411_D), .G(I_2411_G), .S(I_2443_D));
  generic_nmos I_2442(.D(I_2442_D), .G(I_2443_G), .S(I_2474_D));
  generic_pmos I_2443(.D(I_2443_D), .G(I_2443_G), .S(I_2475_D));
  generic_nmos I_2474(.D(I_2474_D), .G(I_2475_G), .S(I_2474_S));
  generic_pmos I_2475(.D(I_2475_D), .G(I_2475_G), .S(I_2475_S));

// Unused 3 input half-cell at [15,6]
  generic_nmos I_2412(.D(I_2412_D), .G(I_2413_G), .S(I_2444_D));
  generic_pmos I_2413(.D(I_2413_D), .G(I_2413_G), .S(I_2445_D));
  generic_nmos I_2444(.D(I_2444_D), .G(I_2445_G), .S(I_2476_D));
  generic_pmos I_2445(.D(I_2445_D), .G(I_2445_G), .S(I_2477_D));
  generic_nmos I_2476(.D(I_2476_D), .G(I_2477_G), .S(I_2476_S));
  generic_pmos I_2477(.D(I_2477_D), .G(I_2477_G), .S(I_2477_S));

// Unused 3 input half-cell at [16,7]
  generic_nmos I_2574(.D(I_2574_D), .G(I_2575_G), .S(I_2606_D));
  generic_pmos I_2575(.D(I_2575_D), .G(I_2575_G), .S(I_2607_D));
  generic_nmos I_2606(.D(I_2606_D), .G(I_2607_G), .S(I_2638_D));
  generic_pmos I_2607(.D(I_2607_D), .G(I_2607_G), .S(I_2639_D));
  generic_nmos I_2638(.D(I_2638_D), .G(I_2639_G), .S(I_2638_S));
  generic_pmos I_2639(.D(I_2639_D), .G(I_2639_G), .S(I_2639_S));

// Unused 3 input half-cell at [16,10]
  generic_nmos I_2580(.D(I_2580_D), .G(I_2581_G), .S(I_2612_D));
  generic_pmos I_2581(.D(I_2581_D), .G(I_2581_G), .S(I_2613_D));
  generic_nmos I_2612(.D(I_2612_D), .G(I_2613_G), .S(I_2644_D));
  generic_pmos I_2613(.D(I_2613_D), .G(I_2613_G), .S(I_2645_D));
  generic_nmos I_2644(.D(I_2644_D), .G(I_2645_G), .S(I_2644_S));
  generic_pmos I_2645(.D(I_2645_D), .G(I_2645_G), .S(I_2645_S));

// Unused 3 input half-cell at [18,1]
  generic_nmos I_2882(.D(I_2882_D), .G(I_2883_G), .S(I_2914_D));
  generic_pmos I_2883(.D(I_2883_D), .G(I_2883_G), .S(I_2915_D));
  generic_nmos I_2914(.D(I_2914_D), .G(I_2915_G), .S(I_2946_D));
  generic_pmos I_2915(.D(I_2915_D), .G(I_2915_G), .S(I_2947_D));
  generic_nmos I_2946(.D(I_2946_D), .G(I_2947_G), .S(I_2946_S));
  generic_pmos I_2947(.D(I_2947_D), .G(I_2947_G), .S(I_2947_S));

// Unused 3 input half-cell at [18,9]
  generic_nmos I_2898(.D(I_2898_D), .G(I_2899_G), .S(I_2930_D));
  generic_pmos I_2899(.D(I_2899_D), .G(I_2899_G), .S(I_2931_D));
  generic_nmos I_2930(.D(I_2930_D), .G(I_2931_G), .S(I_2962_D));
  generic_pmos I_2931(.D(I_2931_D), .G(I_2931_G), .S(I_2963_D));
  generic_nmos I_2962(.D(I_2962_D), .G(I_2963_G), .S(I_2962_S));
  generic_pmos I_2963(.D(I_2963_D), .G(I_2963_G), .S(I_2963_S));

// Unused 3 input half-cell at [18,10]
  generic_nmos I_2900(.D(I_2900_D), .G(I_2901_G), .S(I_2932_D));
  generic_pmos I_2901(.D(I_2901_D), .G(I_2901_G), .S(I_2933_D));
  generic_nmos I_2932(.D(I_2932_D), .G(I_2933_G), .S(I_2964_D));
  generic_pmos I_2933(.D(I_2933_D), .G(I_2933_G), .S(I_2965_D));
  generic_nmos I_2964(.D(I_2964_D), .G(I_2965_G), .S(I_2964_S));
  generic_pmos I_2965(.D(I_2965_D), .G(I_2965_G), .S(I_2965_S));

// Unused 3 input half-cell at [18,11]
  generic_nmos I_2902(.D(I_2902_D), .G(I_2903_G), .S(I_2934_D));
  generic_pmos I_2903(.D(I_2903_D), .G(I_2903_G), .S(I_2935_D));
  generic_nmos I_2934(.D(I_2934_D), .G(I_2935_G), .S(I_2966_D));
  generic_pmos I_2935(.D(I_2935_D), .G(I_2935_G), .S(I_2967_D));
  generic_nmos I_2966(.D(I_2966_D), .G(I_2967_G), .S(I_2966_S));
  generic_pmos I_2967(.D(I_2967_D), .G(I_2967_G), .S(I_2967_S));

// Unused 3 input half-cell at [20,1]
  generic_nmos I_3202(.D(I_3202_D), .G(I_3203_G), .S(I_3234_D));
  generic_pmos I_3203(.D(I_3203_D), .G(I_3203_G), .S(I_3235_D));
  generic_nmos I_3234(.D(I_3234_D), .G(I_3235_G), .S(I_3266_D));
  generic_pmos I_3235(.D(I_3235_D), .G(I_3235_G), .S(I_3267_D));
  generic_nmos I_3266(.D(I_3266_D), .G(I_3267_G), .S(I_3266_S));
  generic_pmos I_3267(.D(I_3267_D), .G(I_3267_G), .S(I_3267_S));

// Unused 3 input half-cell at [21,8]
  generic_nmos I_3376(.D(I_3376_D), .G(I_3377_G), .S(I_3408_D));
  generic_pmos I_3377(.D(I_3377_D), .G(I_3377_G), .S(I_3409_D));
  generic_nmos I_3408(.D(I_3408_D), .G(I_3409_G), .S(I_3440_D));
  generic_pmos I_3409(.D(I_3409_D), .G(I_3409_G), .S(I_3441_D));
  generic_nmos I_3440(.D(I_3440_D), .G(I_3441_G), .S(I_3440_S));
  generic_pmos I_3441(.D(I_3441_D), .G(I_3441_G), .S(I_3441_S));

// Unused 3 input half-cell at [22,9]
  generic_nmos I_3538(.D(I_3538_D), .G(I_3539_G), .S(I_3570_D));
  generic_pmos I_3539(.D(I_3539_D), .G(I_3539_G), .S(I_3571_D));
  generic_nmos I_3570(.D(I_3570_D), .G(I_3571_G), .S(I_3602_D));
  generic_pmos I_3571(.D(I_3571_D), .G(I_3571_G), .S(I_3603_D));
  generic_nmos I_3602(.D(I_3602_D), .G(I_3603_G), .S(I_3602_S));
  generic_pmos I_3603(.D(I_3603_D), .G(I_3603_G), .S(I_3603_S));

// Unused 3 input half-cell at [22,10]
  generic_nmos I_3540(.D(I_3540_D), .G(I_3541_G), .S(I_3572_D));
  generic_pmos I_3541(.D(I_3541_D), .G(I_3541_G), .S(I_3573_D));
  generic_nmos I_3572(.D(I_3572_D), .G(I_3573_G), .S(I_3604_D));
  generic_pmos I_3573(.D(I_3573_D), .G(I_3573_G), .S(I_3605_D));
  generic_nmos I_3604(.D(I_3604_D), .G(I_3605_G), .S(I_3604_S));
  generic_pmos I_3605(.D(I_3605_D), .G(I_3605_G), .S(I_3605_S));

// Unused half-cells (2-input)

// Unused 2 input half-cell at [0,10]
  generic_nmos I_116(.D(I_116_D), .G(I_116_G), .S(I_148_D));
  generic_pmos I_117(.D(I_117_D), .G(I_148_G), .S(I_149_D));
  generic_nmos I_148(.D(I_148_D), .G(I_148_G), .S(I_148_S));
  generic_pmos I_149(.D(I_149_D), .G(I_149_G), .S(I_149_S));

// Unused 2 input half-cell at [1,5]
  generic_nmos I_266(.D(I_266_D), .G(I_266_G), .S(I_298_D));
  generic_pmos I_267(.D(I_267_D), .G(I_298_G), .S(I_299_D));
  generic_nmos I_298(.D(I_298_D), .G(I_298_G), .S(I_298_S));
  generic_pmos I_299(.D(I_299_D), .G(I_299_G), .S(I_299_S));

// Unused 2 input half-cell at [2,1]
  generic_nmos I_418(.D(I_418_D), .G(I_418_G), .S(I_450_D));
  generic_pmos I_419(.D(I_419_D), .G(I_450_G), .S(I_451_D));
  generic_nmos I_450(.D(I_450_D), .G(I_450_G), .S(I_450_S));
  generic_pmos I_451(.D(I_451_D), .G(I_451_G), .S(I_451_S));

// Unused 2 input half-cell at [3,6]
  generic_nmos I_588(.D(I_588_D), .G(I_588_G), .S(I_620_D));
  generic_pmos I_589(.D(I_589_D), .G(I_620_G), .S(I_621_D));
  generic_nmos I_620(.D(I_620_D), .G(I_620_G), .S(I_620_S));
  generic_pmos I_621(.D(I_621_D), .G(I_621_G), .S(I_621_S));

// Unused 2 input half-cell at [4,1]
  generic_nmos I_738(.D(I_738_D), .G(I_738_G), .S(I_770_D));
  generic_pmos I_739(.D(I_739_D), .G(I_770_G), .S(I_771_D));
  generic_nmos I_770(.D(I_770_D), .G(I_770_G), .S(I_770_S));
  generic_pmos I_771(.D(I_771_D), .G(I_771_G), .S(I_771_S));

// Unused 2 input half-cell at [6,10]
  generic_nmos I_1076(.D(I_1076_D), .G(I_1076_G), .S(I_1108_D));
  generic_pmos I_1077(.D(I_1077_D), .G(I_1108_G), .S(I_1109_D));
  generic_nmos I_1108(.D(I_1108_D), .G(I_1108_G), .S(I_1108_S));
  generic_pmos I_1109(.D(I_1109_D), .G(I_1109_G), .S(I_1109_S));

// Unused 2 input half-cell at [9,5]
  generic_nmos I_1546(.D(I_1546_D), .G(I_1546_G), .S(I_1578_D));
  generic_pmos I_1547(.D(I_1547_D), .G(I_1578_G), .S(I_1579_D));
  generic_nmos I_1578(.D(I_1578_D), .G(I_1578_G), .S(I_1578_S));
  generic_pmos I_1579(.D(I_1579_D), .G(I_1579_G), .S(I_1579_S));

// Unused 2 input half-cell at [9,7]
  generic_nmos I_1550(.D(I_1550_D), .G(I_1550_G), .S(I_1582_D));
  generic_pmos I_1551(.D(I_1551_D), .G(I_1582_G), .S(I_1583_D));
  generic_nmos I_1582(.D(I_1582_D), .G(I_1582_G), .S(I_1582_S));
  generic_pmos I_1583(.D(I_1583_D), .G(I_1583_G), .S(I_1583_S));

// Unused 2 input half-cell at [9,9]
  generic_nmos I_1554(.D(I_1554_D), .G(I_1554_G), .S(I_1586_D));
  generic_pmos I_1555(.D(I_1555_D), .G(I_1586_G), .S(I_1587_D));
  generic_nmos I_1586(.D(I_1586_D), .G(I_1586_G), .S(I_1586_S));
  generic_pmos I_1587(.D(I_1587_D), .G(I_1587_G), .S(I_1587_S));

// Unused 2 input half-cell at [11,4]
  generic_nmos I_1864(.D(I_1864_D), .G(I_1864_G), .S(I_1896_D));
  generic_pmos I_1865(.D(I_1865_D), .G(I_1896_G), .S(I_1897_D));
  generic_nmos I_1896(.D(I_1896_D), .G(I_1896_G), .S(I_1896_S));
  generic_pmos I_1897(.D(I_1897_D), .G(I_1897_G), .S(I_1897_S));

// Unused 2 input half-cell at [11,7]
  generic_nmos I_1870(.D(I_1870_D), .G(I_1870_G), .S(I_1902_D));
  generic_pmos I_1871(.D(I_1871_D), .G(I_1902_G), .S(I_1903_D));
  generic_nmos I_1902(.D(I_1902_D), .G(I_1902_G), .S(I_1902_S));
  generic_pmos I_1903(.D(I_1903_D), .G(I_1903_G), .S(I_1903_S));

// Unused 2 input half-cell at [12,6]
  generic_nmos I_2028(.D(I_2028_D), .G(I_2028_G), .S(I_2060_D));
  generic_pmos I_2029(.D(I_2029_D), .G(I_2060_G), .S(I_2061_D));
  generic_nmos I_2060(.D(I_2060_D), .G(I_2060_G), .S(I_2060_S));
  generic_pmos I_2061(.D(I_2061_D), .G(I_2061_G), .S(I_2061_S));

// Unused 2 input half-cell at [13,7]
  generic_nmos I_2190(.D(I_2190_D), .G(I_2190_G), .S(I_2222_D));
  generic_pmos I_2191(.D(I_2191_D), .G(I_2222_G), .S(I_2223_D));
  generic_nmos I_2222(.D(I_2222_D), .G(I_2222_G), .S(I_2222_S));
  generic_pmos I_2223(.D(I_2223_D), .G(I_2223_G), .S(I_2223_S));

// Unused 2 input half-cell at [15,7]
  generic_nmos I_2510(.D(I_2510_D), .G(I_2510_G), .S(I_2542_D));
  generic_pmos I_2511(.D(I_2511_D), .G(I_2542_G), .S(I_2543_D));
  generic_nmos I_2542(.D(I_2542_D), .G(I_2542_G), .S(I_2542_S));
  generic_pmos I_2543(.D(I_2543_D), .G(I_2543_G), .S(I_2543_S));

// Unused 2 input half-cell at [16,4]
  generic_nmos I_2664(.D(I_2664_D), .G(I_2664_G), .S(I_2696_D));
  generic_pmos I_2665(.D(I_2665_D), .G(I_2696_G), .S(I_2697_D));
  generic_nmos I_2696(.D(I_2696_D), .G(I_2696_G), .S(I_2696_S));
  generic_pmos I_2697(.D(I_2697_D), .G(I_2697_G), .S(I_2697_S));

// Unused 2 input half-cell at [17,7]
  generic_nmos I_2830(.D(I_2830_D), .G(I_2830_G), .S(I_2862_D));
  generic_pmos I_2831(.D(I_2831_D), .G(I_2862_G), .S(I_2863_D));
  generic_nmos I_2862(.D(I_2862_D), .G(I_2862_G), .S(I_2862_S));
  generic_pmos I_2863(.D(I_2863_D), .G(I_2863_G), .S(I_2863_S));

// Unused 2 input half-cell at [17,9]
  generic_nmos I_2834(.D(I_2834_D), .G(I_2834_G), .S(I_2866_D));
  generic_pmos I_2835(.D(I_2835_D), .G(I_2866_G), .S(I_2867_D));
  generic_nmos I_2866(.D(I_2866_D), .G(I_2866_G), .S(I_2866_S));
  generic_pmos I_2867(.D(I_2867_D), .G(I_2867_G), .S(I_2867_S));

// Unused 2 input half-cell at [19,5]
  generic_nmos I_3146(.D(I_3146_D), .G(I_3146_G), .S(I_3178_D));
  generic_pmos I_3147(.D(I_3147_D), .G(I_3178_G), .S(I_3179_D));
  generic_nmos I_3178(.D(I_3178_D), .G(I_3178_G), .S(I_3178_S));
  generic_pmos I_3179(.D(I_3179_D), .G(I_3179_G), .S(I_3179_S));

// Unused 2 input half-cell at [21,10]
  generic_nmos I_3476(.D(I_3476_D), .G(I_3476_G), .S(I_3508_D));
  generic_pmos I_3477(.D(I_3477_D), .G(I_3508_G), .S(I_3509_D));
  generic_nmos I_3508(.D(I_3508_D), .G(I_3508_G), .S(I_3508_S));
  generic_pmos I_3509(.D(I_3509_D), .G(I_3509_G), .S(I_3509_S));

// Unused 2 input half-cell at [21,12]
  generic_nmos I_3480(.D(I_3480_D), .G(I_3480_G), .S(I_3512_D));
  generic_pmos I_3481(.D(I_3481_D), .G(I_3512_G), .S(I_3513_D));
  generic_nmos I_3512(.D(I_3512_D), .G(I_3512_G), .S(I_3512_S));
  generic_pmos I_3513(.D(I_3513_D), .G(I_3513_G), .S(I_3513_S));

// Unused 2 input half-cell at [22,11]
  generic_nmos I_3638(.D(I_3638_D), .G(I_3638_G), .S(I_3670_D));
  generic_pmos I_3639(.D(I_3639_D), .G(I_3670_G), .S(I_3671_D));
  generic_nmos I_3670(.D(I_3670_D), .G(I_3670_G), .S(I_3670_S));
  generic_pmos I_3671(.D(I_3671_D), .G(I_3671_G), .S(I_3671_S));

// More unused transistors, these are those left over within a 3 input "cell
// that is in use", but these play no part.

// "Middle And Left": Source/Drains connected to VSS and VDD, gates interconnected (and go to nothing else), drains/sources floating

// Unused partial 3 input cell (left/middle) at [0,10]
  generic_pmos I_21(.D(I_21_D), .G(I_21_G), .S(I_53_D));
  generic_nmos I_20(.D(I_20_D), .G(I_21_G), .S(I_52_D));
  generic_pmos I_53(.D(I_53_D), .G(I_53_G), .S(VDD));
  generic_nmos I_52(.D(I_52_D), .G(I_53_G), .S(VSS));

// Unused partial 3 input cell (left/middle) at [4,4]
  generic_pmos I_649(.D(I_649_D), .G(I_649_G), .S(I_681_D));
  generic_nmos I_648(.D(I_648_D), .G(I_649_G), .S(I_680_D));
  generic_pmos I_681(.D(I_681_D), .G(I_681_G), .S(VDD));
  generic_nmos I_680(.D(I_680_D), .G(I_681_G), .S(VSS));

// Unused partial 3 input cell (left/middle) at [4,10]
  generic_pmos I_661(.D(I_661_D), .G(I_661_G), .S(I_693_D));
  generic_nmos I_660(.D(I_660_D), .G(I_661_G), .S(I_692_D));
  generic_pmos I_693(.D(I_693_D), .G(I_693_G), .S(VDD));
  generic_nmos I_692(.D(I_692_D), .G(I_693_G), .S(VSS));

// Unused partial 3 input cell (left/middle) at [11,9]
  generic_pmos I_1779(.D(I_1779_D), .G(I_1779_G), .S(I_1811_D));
  generic_nmos I_1778(.D(I_1778_D), .G(I_1779_G), .S(I_1810_D));
  generic_pmos I_1811(.D(I_1811_D), .G(I_1811_G), .S(VDD));
  generic_nmos I_1810(.D(I_1810_D), .G(I_1811_G), .S(VSS));

// Unused partial 3 input cell (left/middle) at [13,6]
  generic_pmos I_2093(.D(I_2093_D), .G(I_2093_G), .S(I_2125_D));
  generic_nmos I_2092(.D(I_2092_D), .G(I_2093_G), .S(I_2124_D));
  generic_pmos I_2125(.D(I_2125_D), .G(I_2125_G), .S(VDD));
  generic_nmos I_2124(.D(I_2124_D), .G(I_2125_G), .S(VSS));

// Unused partial 3 input cell (left/middle) at [17,9]
  generic_pmos I_2739(.D(I_2739_D), .G(I_2739_G), .S(I_2771_D));
  generic_nmos I_2738(.D(I_2738_D), .G(I_2739_G), .S(I_2770_D));
  generic_pmos I_2771(.D(I_2771_D), .G(I_2771_G), .S(VDD));
  generic_nmos I_2770(.D(I_2770_D), .G(I_2771_G), .S(VSS));

// Unused partial 3 input cell (left/middle) at [20,5]
  generic_pmos I_3211(.D(I_3211_D), .G(I_3211_G), .S(I_3243_D));
  generic_nmos I_3210(.D(I_3210_D), .G(I_3211_G), .S(I_3242_D));
  generic_pmos I_3243(.D(I_3243_D), .G(I_3243_G), .S(VDD));
  generic_nmos I_3242(.D(I_3242_D), .G(I_3243_G), .S(VSS));

// "Middle And Right": Source/Drains connected to VSS and VDD, gates interconnected (and go to nothing else), drains/sources floating

// Unused partial 3 input cell (right/middle) at [2,13]
  generic_pmos I_379(.D(VDD), .G(I_379_G), .S(I_411_D));
  generic_nmos I_378(.D(VSS), .G(I_379_G), .S(I_410_D));
  generic_pmos I_411(.D(I_411_D), .G(I_411_G), .S(I_411_S));
  generic_nmos I_410(.D(I_410_D), .G(I_411_G), .S(I_410_S));

// Unused partial 3 input cell (right/middle) at [3,11]
  generic_pmos I_535(.D(VDD), .G(I_535_G), .S(I_567_D));
  generic_nmos I_534(.D(VSS), .G(I_535_G), .S(I_566_D));
  generic_pmos I_567(.D(I_567_D), .G(I_567_G), .S(I_567_S));
  generic_nmos I_566(.D(I_566_D), .G(I_567_G), .S(I_566_S));

// Unused partial 3 input cell (right/middle) at [24,10]
  generic_pmos I_3893(.D(VDD), .G(I_3893_G), .S(I_3925_D));
  generic_nmos I_3892(.D(VSS), .G(I_3893_G), .S(I_3924_D));
  generic_pmos I_3925(.D(I_3925_D), .G(I_3925_G), .S(I_3925_S));
  generic_nmos I_3924(.D(I_3924_D), .G(I_3925_G), .S(I_3924_S));

// Right side: Drains connected to VSS and VDD, gates interconnected (and go to nothing else), sources floating

// Unused partial 3 input cell (right side) at [2,10]
  generic_pmos I_405(.D(VDD), .G(I_405_G), .S(I_405_S));
  generic_nmos I_404(.D(VSS), .G(I_405_G), .S(I_404_S));

// Unused partial 3 input cell (right side) at [3,6]
  generic_pmos I_557(.D(VDD), .G(I_557_G), .S(I_557_S));
  generic_nmos I_556(.D(VSS), .G(I_557_G), .S(I_556_S));

// Unused partial 3 input cell (right side) at [4,13]
  generic_pmos I_731(.D(VDD), .G(I_731_G), .S(I_731_S));
  generic_nmos I_730(.D(VSS), .G(I_731_G), .S(I_730_S));

// Unused partial 3 input cell (right side) at [5,10]
  generic_pmos I_885(.D(VDD), .G(I_885_G), .S(I_885_S));
  generic_nmos I_884(.D(VSS), .G(I_885_G), .S(I_884_S));

// Unused partial 3 input cell (right side) at [5,13]
  generic_pmos I_891(.D(VDD), .G(I_891_G), .S(I_891_S));
  generic_nmos I_890(.D(VSS), .G(I_891_G), .S(I_890_S));

// Unused partial 3 input cell (right side) at [6,11]
  generic_pmos I_1047(.D(VDD), .G(I_1047_G), .S(I_1047_S));
  generic_nmos I_1046(.D(VSS), .G(I_1047_G), .S(I_1046_S));

// Unused partial 3 input cell (right side) at [8,15]
  generic_pmos I_1375(.D(VDD), .G(I_1375_G), .S(I_1375_S));
  generic_nmos I_1374(.D(VSS), .G(I_1375_G), .S(I_1374_S));

// Unused partial 3 input cell (right side) at [12,10]
  generic_pmos I_2005(.D(VDD), .G(I_2005_G), .S(I_2005_S));
  generic_nmos I_2004(.D(VSS), .G(I_2005_G), .S(I_2004_S));

// Unused partial 3 input cell (right side) at [14,1]
  generic_pmos I_2307(.D(VDD), .G(I_2307_G), .S(I_2307_S));
  generic_nmos I_2306(.D(VSS), .G(I_2307_G), .S(I_2306_S));

// Unused partial 3 input cell (right side) at [14,5]
  generic_pmos I_2315(.D(VDD), .G(I_2315_G), .S(I_2315_S));
  generic_nmos I_2314(.D(VSS), .G(I_2315_G), .S(I_2314_S));

// Unused partial 3 input cell (right side) at [17,8]
  generic_pmos I_2801(.D(VDD), .G(I_2801_G), .S(I_2801_S));
  generic_nmos I_2800(.D(VSS), .G(I_2801_G), .S(I_2800_S));

// Unused partial 3 input cell (right side) at [18,7]
  generic_pmos I_2959(.D(VDD), .G(I_2959_G), .S(I_2959_S));
  generic_nmos I_2958(.D(VSS), .G(I_2959_G), .S(I_2958_S));

// Unused partial 3 input cell (right side) at [19,1]
  generic_pmos I_3107(.D(VDD), .G(I_3107_G), .S(I_3107_S));
  generic_nmos I_3106(.D(VSS), .G(I_3107_G), .S(I_3106_S));

// Unused partial 3 input cell (right side) at [19,5]
  generic_pmos I_3115(.D(VDD), .G(I_3115_G), .S(I_3115_S));
  generic_nmos I_3114(.D(VSS), .G(I_3115_G), .S(I_3114_S));

// Unused partial 3 input cell (right side) at [21,15]
  generic_pmos I_3455(.D(VDD), .G(I_3455_G), .S(I_3455_S));
  generic_nmos I_3454(.D(VSS), .G(I_3455_G), .S(I_3454_S));

// Right side: Some here are connected to other logic, but with gates interconnected 
// (and isolated), and sources floating these are not used.

// Unused partial 3 input cell (right side) at [7,7]
  generic_pmos I_1199(.D(VDD), .G(I_1199_G), .S(I_1199_S));
  generic_nmos I_1198(.D(I_2071_S), .G(I_1199_G), .S(I_1198_S));

// Unused partial 3 input cell (right side) at [9,7]
  generic_pmos I_1519(.D(VDD), .G(I_1519_G), .S(I_1519_S));
  generic_nmos I_1518(.D(I_1518_D), .G(I_1519_G), .S(I_1518_S));

// Unused partial 3 input cell (right side) at [10,10]
  generic_pmos I_1685(.D(I_1685_D), .G(I_1685_G), .S(I_1685_S));
  generic_nmos I_1684(.D(I_1685_D), .G(I_1685_G), .S(I_1684_S));

// Unused partial 3 input cell (right side) at [11,4]
  generic_pmos I_1833(.D(VDD), .G(I_1833_G), .S(I_1833_S));
  generic_nmos I_1832(.D(I_1832_D), .G(I_1833_G), .S(I_1832_S));

// Unused partial 3 input cell (right side) at [16,13]
  generic_pmos I_2651(.D(VDD), .G(I_2651_G), .S(I_2651_S));
  generic_nmos I_2650(.D(I_2650_D), .G(I_2651_G), .S(I_2650_S));

// Unused partial 3 input cell (right side) at [18,14]
  generic_pmos I_2973(.D(VDD), .G(I_2973_G), .S(I_2973_S));
  generic_nmos I_2972(.D(I_2972_D), .G(I_2973_G), .S(I_2972_S));

// Unused partial 3 input cell (right side) at [19,4]
  generic_pmos I_3113(.D(VDD), .G(I_3113_G), .S(I_3113_S));
  generic_nmos I_3112(.D(I_3112_D), .G(I_3113_G), .S(I_3112_S));

// Unused partial 3 input cell (right side) at [19,6]
  generic_pmos I_3117(.D(VDD), .G(I_3117_G), .S(I_3117_S));
  generic_nmos I_3116(.D(I_3116_D), .G(I_3117_G), .S(I_3116_S));

// Unused partial 3 input cell (right side) at [19,13]
  generic_pmos I_3131(.D(VDD), .G(I_3131_G), .S(I_3131_S));
  generic_nmos I_3130(.D(I_3130_D), .G(I_3131_G), .S(I_3130_S));

// Unused partial 3 input cell (right side) at [24,0]
  generic_pmos I_3905(.D(VDD), .G(I_3905_G), .S(I_3905_S));
  generic_nmos I_3904(.D(I_3767_G), .G(I_3905_G), .S(I_3904_S));

// Unused partial 3 input cell (right side) at [24,1]
  generic_pmos I_3907(.D(VDD), .G(I_3907_G), .S(I_3907_S));
  generic_nmos I_3906(.D(I_3906_D), .G(I_3907_G), .S(I_3906_S));

// Unused partial 3 input cell (right side) at [24,11]
  generic_pmos I_3927(.D(VDD), .G(I_3927_G), .S(I_3927_S));
  generic_nmos I_3926(.D(I_3926_D), .G(I_3927_G), .S(I_3926_S));

// Left side: Sources connected to VSS and VDD, gates interconnected (and go to nothing else), drains floating

// Unused partial 3 input cell (left side) at [1,1]
  generic_pmos I_163(.D(I_163_D), .G(I_163_G), .S(VDD));
  generic_nmos I_162(.D(I_162_D), .G(I_163_G), .S(VSS));

// Unused partial 3 input cell (left side) at [3,1]
  generic_pmos I_483(.D(I_483_D), .G(I_483_G), .S(VDD));
  generic_nmos I_482(.D(I_482_D), .G(I_483_G), .S(VSS));

// Unused partial 3 input cell (left side) at [4,0]
  generic_pmos I_641(.D(I_641_D), .G(I_641_G), .S(VDD));
  generic_nmos I_640(.D(I_640_D), .G(I_641_G), .S(VSS));

// Unused partial 3 input cell (left side) at [4,15]
  generic_pmos I_671(.D(I_671_D), .G(I_671_G), .S(VDD));
  generic_nmos I_670(.D(I_670_D), .G(I_671_G), .S(VSS));

// Unused partial 3 input cell (left side) at [5,1]
  generic_pmos I_803(.D(I_803_D), .G(I_803_G), .S(VDD));
  generic_nmos I_802(.D(I_802_D), .G(I_803_G), .S(VSS));

// Unused partial 3 input cell (left side) at [6,0]
  generic_pmos I_961(.D(I_961_D), .G(I_961_G), .S(VDD));
  generic_nmos I_960(.D(I_960_D), .G(I_961_G), .S(VSS));

// Unused partial 3 input cell (left side) at [7,0]
  generic_pmos I_1121(.D(I_1121_D), .G(I_1121_G), .S(VDD));
  generic_nmos I_1120(.D(I_1120_D), .G(I_1121_G), .S(VSS));

// Unused partial 3 input cell (left side) at [7,12]
  generic_pmos I_1145(.D(I_1145_D), .G(I_1145_G), .S(VDD));
  generic_nmos I_1144(.D(I_1144_D), .G(I_1145_G), .S(VSS));

// Unused partial 3 input cell (left side) at [8,0]
  generic_pmos I_1281(.D(I_1281_D), .G(I_1281_G), .S(VDD));
  generic_nmos I_1280(.D(I_1280_D), .G(I_1281_G), .S(VSS));

// Unused partial 3 input cell (left side) at [8,12]
  generic_pmos I_1305(.D(I_1305_D), .G(I_1305_G), .S(VDD));q
  generic_nmos I_1304(.D(I_1304_D), .G(I_1305_G), .S(VSS));

// Unused partial 3 input cell (left side) at [10,7]
  generic_pmos I_1615(.D(I_1615_D), .G(I_1615_G), .S(VDD));
  generic_nmos I_1614(.D(I_1614_D), .G(I_1615_G), .S(VSS));

// Unused partial 3 input cell (left side) at [10,10]
  generic_pmos I_1621(.D(I_1621_D), .G(I_1621_G), .S(VDD));
  generic_nmos I_1620(.D(I_1620_D), .G(I_1621_G), .S(VSS));

// Unused partial 3 input cell (left side) at [12,7]
  generic_pmos I_1935(.D(I_1935_D), .G(I_1935_G), .S(VDD));
  generic_nmos I_1934(.D(I_1934_D), .G(I_1935_G), .S(VSS));

// Unused partial 3 input cell (left side) at [12,13]
  generic_pmos I_1947(.D(I_1947_D), .G(I_1947_G), .S(VDD));
  generic_nmos I_1946(.D(I_1946_D), .G(I_1947_G), .S(VSS));

// Unused partial 3 input cell (left side) at [14,7]
  generic_pmos I_2255(.D(I_2255_D), .G(I_2255_G), .S(VDD));
  generic_nmos I_2254(.D(I_2254_D), .G(I_2255_G), .S(VSS));

// Unused partial 3 input cell (left side) at [17,8]
  generic_pmos I_2737(.D(I_2737_D), .G(I_2737_G), .S(VDD));
  generic_nmos I_2736(.D(I_2736_D), .G(I_2737_G), .S(VSS));

// Unused partial 3 input cell (left side) at [18,7]
  generic_pmos I_2895(.D(I_2895_D), .G(I_2895_G), .S(VDD));
  generic_nmos I_2894(.D(I_2894_D), .G(I_2895_G), .S(VSS));

// Unused partial 3 input cell (left side) at [20,10]
  generic_pmos I_3221(.D(I_3221_D), .G(I_3221_G), .S(VDD));
  generic_nmos I_3220(.D(I_3220_D), .G(I_3221_G), .S(VSS));

// Left side: Some here are connected to other logic, but with gates interconnected 
// (and isolated), and sources floating these are not used.

// Unused partial 3 input cell (left side) at [8,9]
  generic_pmos I_1299(.D(I_1299_D), .G(I_1299_G), .S(I_1331_D));
  generic_nmos I_1298(.D(I_1298_D), .G(I_1299_G), .S(I_1331_D));

// Unused partial 3 input cell (left side) at [12,8]
  generic_pmos I_1937(.D(I_1937_D), .G(I_1937_G), .S(I_1969_D));
  generic_nmos I_1936(.D(I_1936_D), .G(I_1937_G), .S(I_1969_D));

// Unused partial 3 input cell (left side) at [15,10]
  generic_pmos I_2421(.D(I_2421_D), .G(I_2421_G), .S(I_2453_D));
  generic_nmos I_2420(.D(I_2420_D), .G(I_2421_G), .S(I_2453_D));

// Unused partial 3 input cell (left side) at [16,8]
  generic_pmos I_2577(.D(I_2577_D), .G(I_2577_G), .S(I_2609_D));
  generic_nmos I_2576(.D(I_2576_D), .G(I_2577_G), .S(I_2609_D));

// Unused partial 3 input cell (left side) at [17,11]
  generic_pmos I_2743(.D(I_2743_D), .G(I_2743_G), .S(I_2775_D));
  generic_nmos I_2742(.D(I_2742_D), .G(I_2743_G), .S(I_2775_D));

// Unused partial 3 input cell (left side) at [20,8]
  generic_pmos I_3217(.D(I_3217_D), .G(I_3217_G), .S(I_3249_D));
  generic_nmos I_3216(.D(I_3216_D), .G(I_3217_G), .S(I_3249_D));

// Unused partial 3 input cell (left side) at [21,7]
  generic_pmos I_3375(.D(I_3375_D), .G(I_3375_G), .S(I_3407_D));
  generic_nmos I_3374(.D(I_3374_D), .G(I_3375_G), .S(I_3407_D));

// Unused partial 3 input cell (left side) at [24,7]
  generic_pmos I_3855(.D(I_3855_D), .G(I_3855_G), .S(I_3887_D));
  generic_nmos I_3854(.D(I_3854_D), .G(I_3855_G), .S(I_3887_D));

// Unused partial 3 input cell (left side) at [24,8]
  generic_pmos I_3857(.D(I_3857_D), .G(I_3857_G), .S(I_3889_D));
  generic_nmos I_3856(.D(I_3856_D), .G(I_3857_G), .S(I_3889_D));

// These are cross-connected pairs in the 2 input cells
// where the two lone transistors are being used, but these two aren't
// Upper left source to VDD, lower right drain to VSS. 
// Other sources/drains floating, gates cross connected and floating.

// Unused partial 2 input cell (cross pair) at [0,1]
  generic_pmos I_99(.D(I_99_D), .G(I_130_G), .S(VDD));
  generic_nmos I_130(.D(VSS), .G(I_130_G), .S(I_130_S));

// Unused partial 2 input cell (cross pair) at [1,4]
  generic_pmos I_265(.D(I_265_D), .G(I_296_G), .S(VDD));
  generic_nmos I_296(.D(VSS), .G(I_296_G), .S(I_296_S));

// Unused partial 2 input cell (cross pair) at [2,6]
  generic_pmos I_429(.D(I_429_D), .G(I_460_G), .S(VDD));
  generic_nmos I_460(.D(VSS), .G(I_460_G), .S(I_460_S));

// Unused partial 2 input cell (cross pair) at [4,5]
  generic_pmos I_747(.D(I_747_D), .G(I_778_G), .S(VDD));
  generic_nmos I_778(.D(VSS), .G(I_778_G), .S(I_778_S));

// Unused partial 2 input cell (cross pair) at [6,4]
  generic_pmos I_1065(.D(I_1065_D), .G(I_1096_G), .S(VDD));
  generic_nmos I_1096(.D(VSS), .G(I_1096_G), .S(I_1096_S));

// Unused partial 2 input cell (cross pair) at [6,5]
  generic_pmos I_1067(.D(I_1067_D), .G(I_1098_G), .S(VDD));
  generic_nmos I_1098(.D(VSS), .G(I_1098_G), .S(I_1098_S));

// Unused partial 2 input cell (cross pair) at [6,6]
  generic_pmos I_1069(.D(I_1069_D), .G(I_1100_G), .S(VDD));
  generic_nmos I_1100(.D(VSS), .G(I_1100_G), .S(I_1100_S));

// Unused partial 2 input cell (cross pair) at [8,1]
  generic_pmos I_1379(.D(I_1379_D), .G(I_1410_G), .S(VDD));
  generic_nmos I_1410(.D(VSS), .G(I_1410_G), .S(I_1410_S));

// Unused partial 2 input cell (cross pair) at [10,6]
  generic_pmos I_1709(.D(I_1709_D), .G(I_1740_G), .S(VDD));
  generic_nmos I_1740(.D(VSS), .G(I_1740_G), .S(I_1740_S));

// Unused partial 2 input cell (cross pair) at [10,9]
  generic_pmos I_1715(.D(I_1715_D), .G(I_1746_G), .S(VDD));
  generic_nmos I_1746(.D(VSS), .G(I_1746_G), .S(I_1746_S));

// Unused partial 2 input cell (cross pair) at [13,5]
  generic_pmos I_2187(.D(I_2187_D), .G(I_2218_G), .S(VDD));
  generic_nmos I_2218(.D(VSS), .G(I_2218_G), .S(I_2218_S));

// Unused partial 2 input cell (cross pair) at [15,6]
  generic_pmos I_2509(.D(I_2509_D), .G(I_2540_G), .S(VDD));
  generic_nmos I_2540(.D(VSS), .G(I_2540_G), .S(I_2540_S));

// Unused partial 2 input cell (cross pair) at [18,5]
  generic_pmos I_2987(.D(I_2987_D), .G(I_3018_G), .S(VDD));
  generic_nmos I_3018(.D(VSS), .G(I_3018_G), .S(I_3018_S));

// Unused partial 2 input cell (cross pair) at [19,13]
  generic_pmos I_3163(.D(I_3163_D), .G(I_3194_G), .S(VDD));
  generic_nmos I_3194(.D(VSS), .G(I_3194_G), .S(I_3194_S));

// Unused partial 2 input cell (cross pair) at [22,5]
  generic_pmos I_3627(.D(I_3627_D), .G(I_3658_G), .S(VDD));
  generic_nmos I_3658(.D(VSS), .G(I_3658_G), .S(I_3658_S));

// Unused partial 2 input cell (cross pair) at [24,0]
  generic_pmos I_3937(.D(I_3937_D), .G(I_3968_G), .S(VDD));
  generic_nmos I_3968(.D(VSS), .G(I_3968_G), .S(I_3968_S));

// Unused partial 2 input cell (cross pair) at [24,1]
  generic_pmos I_3939(.D(I_3939_D), .G(I_3970_G), .S(VDD));
  generic_nmos I_3970(.D(VSS), .G(I_3970_G), .S(I_3970_S));

// Unused partial 2 input cell (cross pair) at [24,9]
  generic_pmos I_3955(.D(I_3955_D), .G(I_3986_G), .S(VDD));
  generic_nmos I_3986(.D(VSS), .G(I_3986_G), .S(I_3986_S));

// Unused partial 2 input cell (cross pair) at [24,12]
  generic_pmos I_3961(.D(I_3961_D), .G(I_3992_G), .S(VDD));
  generic_nmos I_3992(.D(VSS), .G(I_3992_G), .S(I_3992_S));

// Upper left source to (other logic), lower right drain to (other logic)
// But other sources/drains floating, gates cross connected and floating -- not used!

// Unused partial 2 input cell (cross pair) at [0,15]
  generic_pmos I_127(.D(I_127_D), .G(I_158_G), .S(I_1407_D));
  generic_nmos I_158(.D(I_159_S), .G(I_158_G), .S(I_158_S));

// Unused partial 2 input cell (cross pair) at [3,15]
  generic_pmos I_607(.D(I_607_D), .G(I_638_G), .S(I_1407_D));
  generic_nmos I_638(.D(I_639_S), .G(I_638_G), .S(I_638_S));

// Unused partial 2 input cell (cross pair) at [4,15]
  generic_pmos I_767(.D(I_767_D), .G(I_798_G), .S(I_1407_D));
  generic_nmos I_798(.D(I_799_S), .G(I_798_G), .S(I_798_S));

// Unused partial 2 input cell (cross pair) at [6,14]
  generic_pmos I_1085(.D(I_1085_D), .G(I_1116_G), .S(I_1117_D));
  generic_nmos I_1116(.D(I_1407_D), .G(I_1116_G), .S(I_1116_S));

// Unused partial 2 input cell (cross pair) at [10,8]
  generic_pmos I_1713(.D(I_1713_D), .G(I_1744_G), .S(I_2545_S));
  generic_nmos I_1744(.D(I_2545_S), .G(I_1744_G), .S(I_1744_S));

// Unused partial 2 input cell (cross pair) at [11,8]
  generic_pmos I_1873(.D(I_1873_D), .G(I_1904_G), .S(I_2545_S));
  generic_nmos I_1904(.D(I_1906_S), .G(I_1904_G), .S(I_1904_S));

// Unused partial 2 input cell (cross pair) at [13,10]
  generic_pmos I_2197(.D(I_2197_D), .G(I_2228_G), .S(I_2711_S));
  generic_nmos I_2228(.D(I_2711_S), .G(I_2228_G), .S(I_2228_S));

// Unused partial 2 input cell (cross pair) at [14,8]
  generic_pmos I_2353(.D(I_2353_D), .G(I_2384_G), .S(I_3185_S));
  generic_nmos I_2384(.D(I_3185_S), .G(I_2384_G), .S(I_2384_S));

// Unused partial 2 input cell (cross pair) at [14,10]
  generic_pmos I_2357(.D(I_2357_D), .G(I_2388_G), .S(I_2711_S));
  generic_nmos I_2388(.D(I_2389_S), .G(I_2388_G), .S(I_2388_S));

// Unused partial 2 input cell (cross pair) at [15,8]
  generic_pmos I_2513(.D(I_2513_D), .G(I_2544_G), .S(I_3185_S));
  generic_nmos I_2544(.D(I_2545_S), .G(I_2544_G), .S(I_2544_S));

// Unused partial 2 input cell (cross pair) at [15,11]
  generic_pmos I_2519(.D(I_2519_D), .G(I_2550_G), .S(I_2869_D));
  generic_nmos I_2550(.D(I_2869_D), .G(I_2550_G), .S(I_2550_S));

// Unused partial 2 input cell (cross pair) at [16,11]
  generic_pmos I_2679(.D(I_2679_D), .G(I_2710_G), .S(I_2869_D));
  generic_nmos I_2710(.D(I_2711_S), .G(I_2710_G), .S(I_2710_S));

// Unused partial 2 input cell (cross pair) at [18,8]
  generic_pmos I_2993(.D(I_2993_D), .G(I_3024_G), .S(I_3825_S));
  generic_nmos I_3024(.D(I_3825_S), .G(I_3024_G), .S(I_3024_S));

// Unused partial 2 input cell (cross pair) at [19,6]
  generic_pmos I_3149(.D(I_3149_D), .G(I_3593_S), .S(I_3181_D));
  generic_nmos I_3180(.D(I_3180_D), .G(I_3593_S), .S(I_3180_S));

// Unused partial 2 input cell (cross pair) at [19,7]
  generic_pmos I_3151(.D(I_3151_D), .G(I_3182_G), .S(I_3823_D));
  generic_nmos I_3182(.D(I_3823_D), .G(I_3182_G), .S(I_3182_S));

// Unused partial 2 input cell (cross pair) at [19,8]
  generic_pmos I_3153(.D(I_3153_D), .G(I_3184_G), .S(I_3825_S));
  generic_nmos I_3184(.D(I_3185_S), .G(I_3184_G), .S(I_3184_S));

// Unused partial 2 input cell (cross pair) at [20,7]
  generic_pmos I_3311(.D(I_3311_D), .G(I_3342_G), .S(I_3823_D));
  generic_nmos I_3342(.D(I_3535_D), .G(I_3342_G), .S(I_3342_S));

// Unused partial 2 input cell (cross pair) at [22,8]
  generic_pmos I_3633(.D(I_3633_D), .G(I_3664_G), .S(I_3825_D));
  generic_nmos I_3664(.D(I_3825_D), .G(I_3664_G), .S(I_3664_S));

// Unused partial 2 input cell (cross pair) at [23,8]
  generic_pmos I_3793(.D(I_3793_D), .G(I_3824_G), .S(I_3825_D));
  generic_nmos I_3824(.D(I_3825_S), .G(I_3824_G), .S(I_3824_S));

// Down to the individual transistors in the 2-input cells now ...

// Lower-left (N) source connected to VSS or
// Upper-right (P) drain connected to VDD
// With gates and other leg floating - not used!

// Unused transistor pair in 2 input cell at [2,5]
  generic_nmos I_426(.D(I_426_D), .G(I_426_G), .S(VSS));
  generic_pmos I_459(.D(VDD), .G(I_459_G), .S(I_459_S));

// Unused transistor pair in 2 input cell at [3,4]
  generic_nmos I_584(.D(I_584_D), .G(I_584_G), .S(VSS));
  generic_pmos I_617(.D(VDD), .G(I_617_G), .S(I_617_S));

// Unused transistor pair in 2 input cell at [3,5]
  generic_nmos I_586(.D(I_586_D), .G(I_586_G), .S(VSS));
  generic_pmos I_619(.D(VDD), .G(I_619_G), .S(I_619_S));

// Unused transistor pair in 2 input cell at [7,6]
  generic_nmos I_1228(.D(I_1228_D), .G(I_1228_G), .S(VSS));
  generic_pmos I_1261(.D(VDD), .G(I_1261_G), .S(I_1261_S));

// Unused transistor pair in 2 input cell at [7,7]
  generic_nmos I_1230(.D(I_1230_D), .G(I_1230_G), .S(VSS));
  generic_pmos I_1263(.D(VDD), .G(I_1263_G), .S(I_1263_S));

// Unused transistor pair in 2 input cell at [8,6]
  generic_nmos I_1388(.D(I_1388_D), .G(I_1388_G), .S(VSS));
  generic_pmos I_1421(.D(VDD), .G(I_1421_G), .S(I_1421_S));

// Unused transistor pair in 2 input cell at [8,13]
  generic_nmos I_1402(.D(I_1402_D), .G(I_1402_G), .S(VSS));
  generic_pmos I_1435(.D(I_1435_D), .G(I_1435_G), .S(I_1435_S));

// Unused transistor pair in 2 input cell at [9,4]
  generic_nmos I_1544(.D(I_1544_D), .G(I_1544_G), .S(VSS));
  generic_pmos I_1577(.D(VDD), .G(I_1577_G), .S(I_1577_S));

// Unused transistor pair in 2 input cell at [11,9]
  generic_nmos I_1874(.D(I_1874_D), .G(I_1874_G), .S(VSS));
  generic_pmos I_1907(.D(VDD), .G(I_1907_G), .S(I_1907_S));

// Unused transistor pair in 2 input cell at [11,10]
  generic_nmos I_1876(.D(I_1876_D), .G(I_1876_G), .S(VSS));
  generic_pmos I_1909(.D(VDD), .G(I_1909_G), .S(I_1909_S));

// Unused transistor pair in 2 input cell at [12,5]
  generic_nmos I_2026(.D(I_2026_D), .G(I_2026_G), .S(VSS));
  generic_pmos I_2059(.D(VDD), .G(I_2059_G), .S(I_2059_S));

// Unused transistor pair in 2 input cell at [14,6]
  generic_nmos I_2348(.D(I_2348_D), .G(I_2348_G), .S(VSS));
  generic_pmos I_2381(.D(VDD), .G(I_2381_G), .S(I_2381_S));

// Unused transistor pair in 2 input cell at [15,1]
  generic_nmos I_2498(.D(I_2498_D), .G(I_2498_G), .S(VSS));
  generic_pmos I_2531(.D(VDD), .G(I_2531_G), .S(I_2531_S));

// Unused transistor pair in 2 input cell at [17,5]
  generic_nmos I_2826(.D(I_2826_D), .G(I_2826_G), .S(VSS));
  generic_pmos I_2859(.D(VDD), .G(I_2859_G), .S(I_2859_S));

// Unused transistor pair in 2 input cell [18,14]
  generic_nmos I_3004(.D(I_3004_D), .G(I_3004_G), .S(VSS));
  generic_pmos I_3037(.D(VDD), .G(I_3037_G), .S(I_3037_S));

// Unused transistor pair in 2 input cell at [24,7]
  generic_nmos I_3950(.D(I_3950_D), .G(I_3950_G), .S(VSS));
  generic_pmos I_3983(.D(I_3983_D), .G(I_3983_G), .S(I_3983_S));

// Unused transistor pair in 2 input cell at [24,10]
  generic_nmos I_3956(.D(I_3956_D), .G(I_3956_G), .S(VSS));
  generic_pmos I_3989(.D(VDD), .G(I_3989_G), .S(I_3989_S));

// Unused transistor pair in 2 input cell at [24,11]
  generic_nmos I_3958(.D(I_3958_D), .G(I_3958_G), .S(VSS));
  generic_pmos I_3991(.D(VDD), .G(I_3991_G), .S(I_3991_S));

// Lower-left (N) sources connected to other logic
// Upper-right (P) drains connected to other logic
// With gates and other leg floating - not used!

// Unused transistor pair in 2 input cell at [19,6]
  generic_nmos I_3148(.D(I_3148_D), .G(I_3148_G), .S(I_3180_D));
  generic_pmos I_3181(.D(I_3181_D), .G(I_3181_G), .S(I_3181_S));

// Single transistors.

// Unused single transistor in 2 input cell (lower-left) at [0,11]
  generic_nmos I_118(.D(I_118_D), .G(I_118_G), .S(I_151_D));

// Unused single transistor in 2 input cell (lower-left) at [7,14]
// Should be part of NOT 340, but is NC
  generic_nmos I_1244(.D(I_1244_D), .G(I_1244_G), .S(VSS));

// Unused single transistor in 2 input cell (upper-left) at [8,8]
  generic_pmos I_1393(.D(I_1393_D), .G(I_1361_S), .S(I_1999_D));

// Unused single transistor in 2 input cell (upper-left) at [13,11]
  generic_pmos I_2199(.D(I_2199_D), .G(I_2167_S), .S(I_1991_S));

// Unused single transistor in 2 input cell (upper-left) at [17,10]
  generic_pmos I_2837(.D(I_2837_D), .G(I_2805_S), .S(I_2869_D));

// Unused single transistor in 2 input cell (upper-left) at [19,9]
  generic_pmos I_3155(.D(I_3155_D), .G(I_3123_S), .S(I_3219_D));

// Unused single transistor in 2 input cell (upper-left) at [19,10]
  generic_pmos I_3157(.D(I_3157_D), .G(I_3125_S), .S(I_3191_S));

// Unused single transistor in 2 input cell (upper-left) at [19,11]
  generic_pmos I_3159(.D(I_3159_D), .G(I_3127_S), .S(I_3191_D));

// Unused single transistor in 2 input cell (upper-left) at [21,4]
  generic_pmos I_3465(.D(I_3465_D), .G(I_3433_S), .S(I_3591_S));

// Unused single transistor in 2 input cell (upper-left) at [21,5]
  generic_pmos I_3467(.D(I_3467_D), .G(I_3435_S), .S(I_3499_D));

// Unused single transistor in 2 input cell (upper-left) at [21,9]
  generic_pmos I_3475(.D(I_3475_D), .G(I_3443_S), .S(I_3507_D));

// Unused single transistor in 2 input cell (upper-left) at [23,7]
  generic_pmos I_3791(.D(I_3791_D), .G(I_3759_S), .S(I_3823_D));

// Unused single transistor in 2 input cell (upper-left) at [23,9]
  generic_pmos I_3795(.D(I_3795_D), .G(I_3763_S), .S(I_3827_D));

// Unused single transistor in 2 input cell (upper-left) at [23,10]
  generic_pmos I_3797(.D(I_3797_D), .G(I_3765_S), .S(I_3829_D));

// End of verilog!
// ********************************************************************************************************
