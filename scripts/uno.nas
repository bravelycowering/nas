#onJoin
	clientactionevent sync register #onclientaction
	clickevent sync register #onclick
quit

#onclientaction
	if clientaction.type|=|"BlockListSelected" msg {clientaction.value} {PlayerHeldBlock}
quit

#onclick
	setblockid id {click.coordsX} 64 {click.coordsZ}
	ifnot id|=|42 quit
	set card {PlayerHeldBlock}
	setadd card 256
	placeblock {card} {click.coordsX} 65 {click.coordsZ}
quit