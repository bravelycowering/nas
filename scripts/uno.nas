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
	set PARTICLES red orange green blue
	setsplit PARTICLES " "
	// preload important sounds
	cs me gup:choose(0):volume(0)
	cs me gup:choose(1):volume(0)
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
	setblockid l_id {click.coordsX} {l_y} {click.coordsZ}
	set l_coords {click.coordsX} {l_y} {click.coordsZ}
	call #getcardfromblock|l_prev|{l_id}
	if label #specificaction[{PlayerHeldBlock}] jump #specificaction[{PlayerHeldBlock}]
	call #getcardfromitem|l_card|{PlayerHeldBlock}
	if l_card.id|=|"" quit
	call #getcardscompatible|l_allow|l_prev|l_card
	ifnot l_allow jump #cantplacethat
	// msg ID: {l_card.id} (item: {l_card.item}, block: {l_card.block})
	// msg COLOR: {l_card.color}, SYMBOL: {l_card.symbol}
	// msg NAME: {l_card.name}
	localmsg announce @color@nick&7 played a {l_card.name}
	placeblock {l_card.block} {click.coordsX} {l_y} {click.coordsZ}
	setrandrangedecimal l_pitch 0.9 1.1
	localcs pos {l_coords} ui pagescroll:pitch({l_pitch})
	if label #coloraction[{l_card.color}] call #coloraction[{l_card.color}]
	if label #symbolaction[{l_card.symbol}] call #symbolaction[{l_card.symbol}]
quit

#cantplacethat
	cs me noteblock:choose(8)
	cpemsg smallannounce &cCan't play that card!
quit

// call #getcardscompatible|pkg|card_a|card_b
#getcardscompatible
	set {runArg1} true
	if {runArg2}.id|=|"" quit
	if {runArg3}.id|=|"" quit
	if {runArg2}.symbol|=|{runArg3}.symbol quit
	if {runArg2}.color|=|{runArg3}.color quit
	if {runArg2}.color|=|4 quit
	if {runArg3}.color|=|4 quit
	if {runArg2}.symbol|=|15 quit
	if {runArg3}.symbol|=|15 quit
	set {runArg1} false
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

#getcardfromblock
	set l_temp {runArg2}
	setsub l_temp 512
jump #getcard|{runArg1}|{l_temp}

// has access to l_card, l_prev, and l_coords
#coloraction[0]
#coloraction[1]
#coloraction[2]
#coloraction[3]
	setsplit l_coords " "
	setsub l_coords[1] 0.25
	effect {PARTICLES[{l_card.color}]} {l_coords[0]} {l_coords[1]} {l_coords[2]} 0 0 0 true
quit

#coloraction[4]
	setsplit l_coords " "
	setsub l_coords[1] 0.25
	effect white {l_coords[0]} {l_coords[1]} {l_coords[2]} 0 0 0 true
	effect redprecise {l_coords[0]} {l_coords[1]} {l_coords[2]} 1 -1 1 true
	effect orangeprecise {l_coords[0]} {l_coords[1]} {l_coords[2]} -1 -1 1 true
	effect greenprecise {l_coords[0]} {l_coords[1]} {l_coords[2]} 1 -1 -1 true
	effect blueprecise {l_coords[0]} {l_coords[1]} {l_coords[2]} -1 -1 -1 true
	localcs pos {l_coords} pickup scifi:pitch(.5):skip(1)
quit

#symbolaction[10]
	localcs pos {l_coords} dukeitempickup:pitch(-1)
quit

#symbolaction[11]
	localcs pos {l_coords} pickup beer
quit

#symbolaction[12]
	localcs pos {l_coords} pickup secret:pitch(-1.5):skip(.5)
quit

#symbolaction[13]
	localcs pos {l_coords} pickup beer
	localcs pos {l_coords} gup:cut(.2)pickup beer:pitch(1.02)
quit

// has access to l_prev and l_coords
#specificaction[251]
#specificaction[252]
#specificaction[253]
#specificaction[254]
	ifnot l_prev.color|=|4 quit
	set l_color {PlayerHeldBlock}
	setsub l_color 251
	setsplit l_coords " "
	setsub l_coords[1] 0.25
	effect {PARTICLES[{l_color}]} {l_coords[0]} {l_coords[1]} {l_coords[2]} 0 0 0 true
	set l_id {l_color}
	setmul l_id 48
	setadd l_id {l_prev.symbol}
	setadd l_id 512
	placeblock {l_id} {l_coords}
	localcs pos {l_coords} poof:choose(1)
quit