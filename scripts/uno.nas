#onJoin
	clientactionevent sync register #onclientaction
	clickevent sync register #onclick
quit

#onclientaction
	if clientaction.type|=|"BlockListSelected" msg {clientaction.value} {PlayerHeldBlock}
quit

#onclick
	set y {click.coordsY}
	setblockid id {click.coordsX} {y} {click.coordsZ}
	ifnot id|=|42 setsub y 1
	setblockid id {click.coordsX} {y} {click.coordsZ}
	ifnot id|=|42 quit
	setadd y 1
	set card {PlayerHeldBlock}
	setadd card 256
	placeblock {card} {click.coordsX} {y} {click.coordsZ}
	localcs pos {click.coordsX} {y} {click.coordsZ} ui pagescroll
	setsub y 0.25
	effect white {click.coordsX} {y} {click.coordsZ} 0 0 0 true
quit