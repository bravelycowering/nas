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

	if label #FIRESTARTER[{LastStandOnID}] call #placetempblock|54|{LastMBCoords}
	if StandInID|=|54 kill @color@nick&7 went up in &cflames!

	// set the last coords
	set LastMBCoords {MBCoords}
quit

// call #placetempblock|{block}|{X} {Y} {Z}
#placetempblock
	set l_c {runArg2}
	setsplit l_c
	tempblock {runArg1} {l_c}
	set World[{l_c[0]},{l_c[1]},{l_c[2]}] {runArg1}
quit

// call #settempblock|pkg|{X} {Y} {Z}
#settempblock
	set l_c {runArg2}
	setsplit l_c
	set {runArg1} {World[{l_c[0]},{l_c[1]},{l_c[2]}]}
	if {runArg1}|=|"" setblockid {runArg1} {runArg2}
quit