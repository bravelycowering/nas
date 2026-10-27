#onJoin
	clientactionevent sync register #onclientaction
quit

#onclientaction
	if clientaction.type|=|BlockListSelected msg {clientaction.value} {PlayerHeldBlock}
quit