using local_packages
using no_runarg_underscore_conversion

#FIRESTARTER[196]
#FIRESTARTER[197]

#onJoin
	coordchangedevent sync register #onCoordChanged
	definehotkey reset|R
	set LastMBCoords {PlayerCoords}
	set Checkpoint {PlayerCoords}
quit

#onCoordChanged

	call #settempblock|StandInID|{MBCoords}

	setsplit MBCoords " "
	setsub MBCoords[1] 1
	call #settempblock|StandOnID|{MBCoords[0]} {MBCoords[1]} {MBCoords[2]}

	call #settempblock|LastStandInID|{LastMBCoords}

	setsplit LastMBCoords " "
	setsub LastMBCoords[1] 1
	call #settempblock|LastStandOnID|{LastMBCoords[0]} {LastMBCoords[1]} {LastMBCoords[2]}

	if label #FIRESTARTER[{LastStandOnID}] call #ignite|{LastMBCoords}
	if StandInID|=|54 call #reset
	if StandOnID|=|41 call #checkpoint|{MBCoords}
	if StandInID|=|766 call #crunch|{MBCoords}

	// set the last coords
	set LastMBCoords {MBCoords}
quit

#input
	if label #input_{runArg1} jump #input_{runArg1}
quit

// call #reset
#reset
#input_reset
	set LastMBCoords {PlayerCoords}
	kill
jump #undochanges

// call #placetempblock|{block}|{X} {Y} {Z}
#placetempblock
	set l_id {runArg1}
	call #settempblock|l_oldid|{runArg2}
	if WorldChanges.Last[{l_p}]|=|"" set WorldChanges {WorldChanges}|{l_p}
	if WorldChanges.Last[{l_p}]|=|"" set WorldChanges.Last[{l_p}] {l_oldid}
	tempblock {l_id} {l_c}
	set World[{l_p}] {l_id}
quit

// call #settempblock|pkg|{X} {Y} {Z}
#settempblock
	set l_c {runArg2}
	setsplit l_c " "
	set l_p {l_c[0]},{l_c[1]},{l_c[2]}
	set {runArg1} {World[{l_p}]}
	if {runArg1}|=|"" setblockid {runArg1} {runArg2}
quit

// call #ignite|{X} {Y} {Z}
#ignite
	call #settempblock|l_id|{runArg1}
	setrandrangedecimal l_pitch 0.9 1.1
	effect puff {l_c} 0 0 0
	effect puff {l_c} 0 0 0
	effect puff {l_c} 0 0 0
	effect puff {l_c} 0 0 0
	effect puff {l_c} 0 0 0
	ifnot l_id|=|765 jump #ignite.endsnowstove
		effect fire {l_c} 0 0 0
		effect fire {l_c} 0 0 0
		effect fire {l_c} 0 0 0
		effect fire {l_c} 0 0 0
		cs pos {l_c} icicle melt:pitch({l_pitch})
	jump #placetempblock|0|{l_c}
	cs pos {l_c} fire light:pitch({l_pitch})
	#ignite.endsnowstove
jump #placetempblock|54|{l_c}

// call #checkpoint|{X} {Y} {Z}
#checkpoint
	if Checkpoint|=|runArg1 quit
	setsplit runArg1 " "
	setsub runArg1[1] 1
	set l_cc {runArg1[0]} {runArg1[1]} {runArg1[2]}
	setblockmessage l_require {l_cc}
	if WorldChanges.Crunches|<|l_require cs me vote failed:choose(1):volume(2)
	if WorldChanges.Crunches|<|l_require msg &cNot enough snow crunched...
	if WorldChanges.Crunches|<|l_require quit
	cs me levelclear:cut(0.2):pitch(-0.5):echo(0.2,0.9)
	set Checkpoint {runArg1}
	setspawn {runArg1}
	setdeathspawn {runArg1} 0 0
	call #placetempblock|0|{runArg1}
	call #placetempblock|42|{l_cc}
jump #commitchanges

// call #crunch|{X} {Y} {Z}
#crunch
	cs pos {runArg1} snow:skip(0.1):pitch(1.5)
	setadd WorldChanges.Crunches 1
jump #placetempblock|53|{runArg1}

// call #undochanges
#undochanges
	setsplit WorldChanges |
	if WorldChanges.Length|=|0 quit
	set l_i 0
	#undochanges.loop
		setsplit WorldChanges[{l_i}] ,
		tempblock {WorldChanges.Last[{WorldChanges[{l_i}]}]} {WorldChanges[{l_i}][0]} {WorldChanges[{l_i}][1]} {WorldChanges[{l_i}][2]}
		setblockid l_id {WorldChanges[{l_i}][0]} {WorldChanges[{l_i}][1]} {WorldChanges[{l_i}][2]}
		set World[{WorldChanges[{l_i}]}] {WorldChanges.Last[{WorldChanges[{l_i}]}]}
		if World[{WorldChanges[{l_i}]}]|=|l_id set World[{WorldChanges[{l_i}]}]
		setadd l_i 1
	if l_i|<|WorldChanges.Length jump #undochanges.loop
// call #commitchanges
#commitchanges
	set WorldChanges
	resetdata packages WorldChanges*
quit