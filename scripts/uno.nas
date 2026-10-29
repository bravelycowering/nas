using local_packages
using quit_resets_runargs
using no_runarg_underscore_conversion

#onJoin
	clientactionevent sync register #onclientaction
	clickevent sync register #onclick
	// set PREFIXES &c &k &2 &r &f■
	set PREFIXES &c &e &a &b &f■
	setsplit PREFIXES " "
	set COLORS Red;Yellow;Green;Blue; {PREFIXES[0]}W{PREFIXES[1]}i{PREFIXES[2]}l{PREFIXES[3]}d&f
	setsplit COLORS ;
	set SYMBOLS 1 2 3 4 5 6 7 8 9 0 ▄ +2 ▀ +4 ? █ ♥ ♦ ♣ ♠ ╙ ╞
	setsplit SYMBOLS " "
	set PARTICLES redprecise orangeprecise greenprecise blueprecise
	setsplit PARTICLES " "
quit

#onclientaction
	if clientaction.type|=|"BlockListSelected" msg {clientaction.value} {PlayerHeldBlock}
quit

#onclick
	set l_y {click.coordsY}
	setblockid l_id {click.coordsX} {l_y} {click.coordsZ}
	ifnot l_id|=|42 setsub l_y 1
	setblockid l_id {click.coordsX} {l_y} {click.coordsZ}
	ifnot l_id|=|42 quit
	setadd l_y 1
	call #getcardfromitem|l_card|{PlayerHeldBlock}
	if l_card.id|=|"" quit
	// msg ID: {l_card.id} (item: {l_card.item}, block: {l_card.block})
	// msg COLOR: {l_card.color}, SYMBOL: {l_card.symbol}
	// msg NAME: {l_card.name}
	localmsg announce @color@nick&7 played a {l_card.name}
	placeblock {l_card.block} {click.coordsX} {l_y} {click.coordsZ}
	setrandrangedecimal l_pitch 0.9 1.1
	localcs pos {click.coordsX} {l_y} {click.coordsZ} ui pagescroll:pitch({l_pitch})
	set l_coords {click.coordsX} {l_y} {click.coordsZ}
	if label #coloraction[{l_card.color}] call #coloraction[{l_card.color}]
	if label #symbolaction[{l_card.symbol}] call #symbolaction[{l_card.symbol}]
quit

// call #getcard|pkg|{id}
#getcard
	resetdata packages {runArg1}.*
	if runArg2|<|0 quit
	if runArg2|>=|240 quit
	set {runArg1}.id {runArg2}
	set {runArg1}.item {runArg2}
	setadd {runArg1}.item 256
	set {runArg1}.block {runArg2}
	setadd {runArg1}.block 512
	set {runArg1}.color {runArg2}
	setdiv {runArg1}.color 48
	setrounddown {runArg1}.color
	set {runArg1}.symbol {runArg2}
	setmod {runArg1}.symbol 48
	set {runArg1}.shortname {PREFIXES[{{runArg1}.color}]}{SYMBOLS[{{runArg1}.symbol}]}
	set {runArg1}.name {PREFIXES[{{runArg1}.color}]}{COLORS[{{runArg1}.color}]} {SYMBOLS[{{runArg1}.symbol}]}
	// single hardcoded instance to make wild card just appear as wild
	if {runArg1}.shortname|=|"{PREFIXES[4]}{SYMBOLS[15]}" set {runArg1}.name {PREFIXES[4]}{COLORS[4]}
	if {runArg1}.shortname|=|"{PREFIXES[4]}{SYMBOLS[15]}" set {runArg1}.shortname {PREFIXES[4]}
quit

#getcardfromitem
	set l_temp {runArg2}
	setsub l_temp 256
jump #getcard|{runArg1}|{l_temp}

// call #placeparticles|{type}|{count}|{coords}
#placeparticles
	if runArg2|=|0 quit
	set l_temp {runArg3}
	setsplit l_temp " "
	setsub l_temp[1] 0.4
	setrandrangedecimal l_temp2 -0.3 0.3
	setsub l_temp[0] {l_temp2}
	setrandrangedecimal l_temp3 -0.3 0.3
	setsub l_temp[2] {l_temp3}
	effect {runArg1} {l_temp[0]} {l_temp[1]} {l_temp[2]} {l_temp2} -1 {l_temp3} true
	set l_temp {runArg2}
	setsub l_temp 1
jump #placeparticles|{runArg1}|{l_temp}|{runArg3}

// has access to l_card and l_coords
#coloraction[0]
#coloraction[1]
#coloraction[2]
#coloraction[3]
jump #placeparticles|{PARTICLES[{l_card.color}]}|10|{l_coords}

#coloraction[4]
	call #placeparticles|{PARTICLES[{l_card.color}]}|10|{l_coords}
	localcs all pickup scifi:pitch(.5):skip(1)
quit

#symbolaction[10]
	localcs all dukeitempickup:pitch(-1)
quit

#symbolaction[11]
	localcs all pickup beer
quit

#symbolaction[12]
	localcs all pickup secret:pitch(-1.5):skip(.5)
quit

#symbolaction[13]
	localcs all pickup beer:cut(.35)pickup beer:skip(.15):pitch(1.02)
quit