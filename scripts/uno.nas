using local_packages
using quit_resets_runargs
using no_runarg_underscore_conversion

#onJoin
	clientactionevent sync register #onclientaction
	clickevent sync register #onclick
	set PREFIXES &c &k &2 &r &f■
	setsplit PREFIXES " "
	set SYMBOLS 1 2 3 4 5 6 7 8 9 0 ▄ +2 ▀ +4 ? █ ♥ ♦ ♣ ♠ ╙ ╞
	setsplit SYMBOLS " "
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
	msg ID: {l_card.id} (item: {l_card.item}, block: {l_card.block})
	msg COLOR: {l_card.color}, SYMBOL: {l_card.symbol}
	msg NAME: {l_card.name}
	placeblock {l_card.block} {click.coordsX} {l_y} {click.coordsZ}
	localcs pos {click.coordsX} {l_y} {click.coordsZ} ui pagescroll
	setsub l_y 0.25
	effect white {click.coordsX} {l_y} {click.coordsZ} 0 0 0 true
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
	set {runArg1}.name {PREFIXES[{{runArg1}.color}]}{SYMBOLS[{{runArg1}.symbol}]}
	// single hardcoded instance to make wild card just appear as wild
	if {runArg1}.name|=|"{PREFIXES[4]}{SYMBOLS[15]}" set {runArg1}.name {PREFIXES[4]}
quit

#getcardfromitem
	set l_temp {runArg2}
	setsub l_temp 256
jump #getcard|{runArg1}|{l_temp}