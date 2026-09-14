using local_packages

#FIRESTARTER[196]
#FIRESTARTER[197]

#onJoin
	coordchangedevent sync register #onCoordChanged
	set LastMBCoords {PlayerCoords}
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
	if StandInID|=|54 kill @color@nick&7 went up in &cflames!
	if StandOnID|=|41 call #checkpoint

	// set the last coords
	set LastMBCoords {MBCoords}
quit

// call #placetempblock|{block}|{X} {Y} {Z}
#placetempblock
	set l_c {runArg2}
	setsplit l_c " "
	tempblock {runArg1} {l_c}
	set World[{l_c[0]},{l_c[1]},{l_c[2]}] {runArg1}
quit

// call #settempblock|pkg|{X} {Y} {Z}
#settempblock
	set l_c {runArg2}
	setsplit l_c " "
	set {runArg1} {World[{l_c[0]},{l_c[1]},{l_c[2]}]}
	if {runArg1}|=|"" setblockid {runArg1} {runArg2}
quit

// call #ignite|{X} {Y} {Z}
#ignite
	setrandrangedecimal l_pitch 0.9 1.1
	cs pos {runArg1} fire light:pitch({l_pitch})
	effect puff {runArg1} 0 0 0
	effect puff {runArg1} 0 0 0
	effect puff {runArg1} 0 0 0
	effect puff {runArg1} 0 0 0
	effect puff {runArg1} 0 0 0
jump #placetempblock|54|{runArg1}

#checkpoint
	if Checkpoint|=|runArg1 quit
	cs me levelclear:cut(0.2):pitch(-0.5):echo(0.2,0.9)
	set Checkpoint {runArg1}
	setspawn {runArg1}
	setdeathspawn {runArg1}
quit