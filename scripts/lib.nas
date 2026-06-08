using local_packages
using quit_resets_runargs
using no_runarg_underscore_conversion
using allow_include
using cef

// this is a general purpose file for a bunch of libraries i
// might wind up using for my own stuff. you are welcome to use this
// for your own purposes by putting "include os/bravelycowering+lib"
// at the top of your script

// everything here will be annotated with the method of calling it, for example:
// call #Namespace:funcname|arg1|{arg2}|{arg3}
// arguments in {braces} require a direct value to be passed, otherwise a package name is expected

////////////////////////////////////////////////////////////////
//                        Uniqe Sets                          //
////////////////////////////////////////////////////////////////

// magic value: @!::$

// call #Set:add|set|{value}
// adds {value} to the given set if it does not already contain it
#Set:add
	if runArg2|has|"@!::$" error Set values cannot contain '@!::$'
	set l_check @!::${runArg2}@!::$
	ifnot {runArg1}|has|l_check set {runArg1} {{runArg1}}{l_check}
quit

// call #Set:remove|set|{value}
// removes {value} from the given set if it contains it
#Set:remove
	if runArg2|has|"@!::$" error Set values cannot contain '@!::$'
	set l_check @!::${runArg2}@!::$
	ifnot {runArg1}|has|l_check quit
	set l_set {{runArg1}}
	setsplit l_set {l_check}
	if l_set.Length|>|1 set {runArg1} {l_set[0]}{l_set[1]}
	else set {runArg1} {l_set[0]}
	if l_set.Length|=|0 set {runArg1}
quit

// call #Set:replace|set|{value}|{newvalue}
// replace {value} with {newvalue} only if the given set contains {value}
// and doesnt yet contain {value2}
#Set:replace
	if runArg2|has|"@!::$" error Set values cannot contain '@!::$'
	set l_check @!::${runArg2}@!::$
	ifnot {runArg1}|has|l_check quit
	if runArg3|has|"@!::$" error Set values cannot contain '@!::$'
	set l_check2 @!::${runArg3}@!::$
	if {runArg1}|has|l_check2 quit
	set l_set {{runArg1}}
	setsplit l_set {l_check}
	if l_set.Length|>|1 set {runArg1} {l_set[0]}{l_check2}{l_set[1]}
	else set {runArg1} {l_set[0]}{l_check2}
	if l_set.Length|=|0 set {runArg1}
quit

// call #Set:sethas|set|{value}
// sets set.Has to a boolean based on whether or not the given set has {value}
#Set:sethas
	if runArg2|has|"@!::$" error Set values cannot contain '@!::$'
	set l_check @!::${runArg2}@!::$
	if {runArg1}|has|l_check set {runArg1}.Has true
	else set {runArg1}.Has false
quit

// call #Set:setsplit|set
// splits the set into individual packages for iterating on (similar to setsplit)
#Set:setsplit
	setsplit {runArg1} @!::$
quit

// call #Set:setlength|set
// sets set.Length to the size of the set (similar to setlength)
#Set:setlength
	setlength {runArg1} @!::$
quit

// #Set:setfromlist|list
// creates a set from sub packages generated from setsplit
// it is VERY not recommended to edit a set by splitting it and then
// editing individual packages to then re-merge, as the time complexity
// of this is O(n) as opposed to O(1) (bigger sets are gonna consume
// more actions if you do it this way)
#Set:setfromlist
	// todo: make this
quit

////////////////////////////////////////////////////////////////
//                      Struct Packing                        //
////////////////////////////////////////////////////////////////

// todo: rewrite this shit

// call #Struct:pack|struct|format
#Struct:pack
	set l_format {{runArg2}}
	setsplit l_format |
	set {runArg1}
	set l_i 0
	#Struct:pack.loop
		set {runArg1} {{runArg1}}{l_format[{l_i}]}|{{runArg1}.{l_format[{l_i}]}}||
		setadd l_i 1
	if l_i|<|l_format.Length jump #Struct:pack.loop
quit

// call #Struct:unpack|struct
#Struct:unpack
	set l_struct {{runArg1}}
	setsplit l_struct ||
	set l_i 0
	#Struct:unpack.loop
		setsplit l_struct[{l_i}] |
		set {runArg1}.{l_struct[{l_i}][0]} {l_struct[{l_i}][1]}
		setadd l_i 1
	if l_i|<|l_format.Length jump #Struct:unpack.loop
quit

////////////////////////////////////////////////////////////////
//                           Time                             //
////////////////////////////////////////////////////////////////

// call #Time:setduration|time
//   sets sub packages for the provided package that splits the provided
//   time into seconds, minutes, hours, days, and years,
//   as well as preformatting a friendly-looking duration string
#Time:setduration
	// seconds
	set {runArg1}.Seconds {{runArg1}}
	setdiv {runArg1}.Seconds 1000
	setrounddown {runArg1}.Seconds
	setmod {runArg1}.Seconds 60
	// minutes
	set {runArg1}.Minutes {{runArg1}}
	setdiv {runArg1}.Minutes 60000
	setrounddown {runArg1}.Minutes
	setmod {runArg1}.Minutes 60
	// hours
	set {runArg1}.Hours {{runArg1}}
	setdiv {runArg1}.Hours 3600000
	setrounddown {runArg1}.Hours
	setmod {runArg1}.Hours 24
	// days
	set {runArg1}.Days {{runArg1}}
	setdiv {runArg1}.Days 86400000
	setrounddown {runArg1}.Days
	setmod {runArg1}.Days 365
	// years
	set {runArg1}.Years {{runArg1}}
	setdiv {runArg1}.Years 31557600000
	setrounddown {runArg1}.Years
	// preformatted
	if {runArg1}|<|31557600000 jump #Time:setduration._trydays
		set {runArg1}.Duration {{runArg1}.Years}y {{runArg1}.Days}d
		quit
	#Time:setduration._trydays
	if {runArg1}|<|86400000 jump #Time:setduration._tryhours
		set {runArg1}.Duration {{runArg1}.Days}d {{runArg1}.Hours}h
		quit
	#Time:setduration._tryhours
	if {runArg1}|<|3600000 jump #Time:setduration._trymins
		set {runArg1}.Duration {{runArg1}.Hours}h {{runArg1}.Minutes}m
		quit
	#Time:setduration._trymins
	if {runArg1}|<|60000 jump #Time:setduration._trysecs
		set {runArg1}.Duration {{runArg1}.Minutes}m {{runArg1}.Seconds}s
		quit
	#Time:setduration._trysecs
	set {runArg1}.Duration {{runArg1}.Seconds}s
quit

// call #Time:settimer|time
//   sets sub packages for the provided package that splits the provided
//   time into milliseconds, seconds, and minutes, as well as
//   pre-formatting a timer
#Time:settimer
	// milliseconds
	set {runArg1}.Milliseconds {{runArg1}}
	setmod {runArg1}.Milliseconds 1000
	if {runArg1}.Milliseconds|<|100 set {runArg1}.Milliseconds 0{{runArg1}.Milliseconds}
	if {runArg1}.Milliseconds|<|10 set {runArg1}.Milliseconds 0{{runArg1}.Milliseconds}
	// seconds
	set {runArg1}.Seconds {{runArg1}}
	setdiv {runArg1}.Seconds 1000
	setrounddown {runArg1}.Seconds
	setmod {runArg1}.Seconds 60
	if {runArg1}.Seconds|<|10 set {runArg1}.Seconds 0{{runArg1}.Seconds}
	// minutes
	set {runArg1}.Minutes {{runArg1}}
	setdiv {runArg1}.Minutes 60000
	setrounddown {runArg1}.Minutes
	if {runArg1}.Minutes|<|10 set {runArg1}.Minutes 0{{runArg1}.Minutes}
	// preformatted
	set {runArg1}.Timer {{runArg1}.Minutes}:{{runArg1}.Seconds}.{{runArg1}.Milliseconds}
quit

// call #Time:setlongtimer|time
//   sets sub packages for the provided package that splits the provided
//   time into milliseconds, seconds, minutes, and hours, as well as
//   pre-formatting a timer
#Time:setlongtimer
	// milliseconds
	set {runArg1}.Milliseconds {{runArg1}}
	setmod {runArg1}.Milliseconds 1000
	if {runArg1}.Milliseconds|<|100 set {runArg1}.Milliseconds 0{{runArg1}.Milliseconds}
	if {runArg1}.Milliseconds|<|10 set {runArg1}.Milliseconds 0{{runArg1}.Milliseconds}
	// seconds
	set {runArg1}.Seconds {{runArg1}}
	setdiv {runArg1}.Seconds 1000
	setrounddown {runArg1}.Seconds
	setmod {runArg1}.Seconds 60
	if {runArg1}.Seconds|<|10 set {runArg1}.Seconds 0{{runArg1}.Seconds}
	// minutes
	set {runArg1}.Minutes {{runArg1}}
	setdiv {runArg1}.Minutes 60000
	setrounddown {runArg1}.Minutes
	setmod {runArg1}.Minutes 60
	if {runArg1}.Minutes|<|10 set {runArg1}.Minutes 0{{runArg1}.Minutes}
	// hours
	set {runArg1}.Hours {{runArg1}}
	setdiv {runArg1}.Hours 3600000
	setrounddown {runArg1}.Hours
	if {runArg1}.Hours|<|10 set {runArg1}.Hours 0{{runArg1}.Hours}
	// preformatted
	set {runArg1}.Timer {{runArg1}.Hours}:{{runArg1}.Minutes}:{{runArg1}.Seconds}.{{runArg1}.Milliseconds}
quit

////////////////////////////////////////////////////////////////
//                       Items System                         //
////////////////////////////////////////////////////////////////

// call #Item:setup
// sets up specific constants needed for the library to function
// this will automatically be called when defining an item among
// other things, so you shouldn't need to worry about calling this
// manually
#Item:setup
	set Item:TONAME[q] Q
	set Item:TONAME[w] W
	set Item:TONAME[e] E
	set Item:TONAME[r] R
	set Item:TONAME[t] T
	set Item:TONAME[y] Y
	set Item:TONAME[u] U
	set Item:TONAME[i] I
	set Item:TONAME[o] O
	set Item:TONAME[p] P
	set Item:TONAME[a] A
	set Item:TONAME[s] S
	set Item:TONAME[d] D
	set Item:TONAME[f] F
	set Item:TONAME[g] G
	set Item:TONAME[h] H
	set Item:TONAME[j] J
	set Item:TONAME[k] K
	set Item:TONAME[l] L
	set Item:TONAME[z] Z
	set Item:TONAME[x] X
	set Item:TONAME[c] C
	set Item:TONAME[v] V
	set Item:TONAME[b] B
	set Item:TONAME[n] N
	set Item:TONAME[m] M
	set Item:TONAME[_] { } { }
	set Item:VALIDCHARS QWERTYUIOPASDFGHJKLZXCVBNM1234567890-'#$?_ .
	set Item:IDCONVERTCHARS qwertyuiopasdfghjklzxcvbnm
	set Item:setup true
quit

// call #Item:setsaving|{shouldSave}
// sets whether or not the item system should utilized the saved packages
// system to persist items
#Item:setsaving
	if runArg1 set Item:saveDot .
	else set Item:saveDot
quit

// call #Item:define|{definition}
// syntax for item definition is as follows
// 1. The first thing in the definition MUST be the item ID, comprised
//    of characters matching the regex [A-Za-z0-9_.?#$"'-] (spaces will
//    be converted to underscores for the item id to maintain compat
//    with scripts that dont use no_runarg_underscore_conversion
// 2. The item ID can optionally be followed immediately by a ! to
//    indicate that the item is 'important' meaning it can't be thrown
//    away with #Item:drop (it's worth noting that the ! is NOT part of
//    the item id, and should not be specified in future calls)
// 3. The item ID can optionally be followed immediately by a \\,
//    where everything after the double backslash is used as the item
//    flavor text in #Item:look. If not specified (or it is empty), the
//    item will have no flavor text. This also means the flavor text
//    cannot contain 2 backslashes in a row.
#Item:define
	set l_args {runArg1}
	set l_args[1]
	setsplit l_args \\
	set l_id {l_args[0]}
	set l_flavor {l_args[1]}
	ifnot Item:setup call #Item:setup
	// verify valid id and generate item name
	setsplit l_id
	set l_id
	set l_name
	set l_i 0
	set l_important false
	#Item:define._nameloop
		set l_char {l_id[{l_i}]}
		ifnot l_char|=|"!" jump #Item:define._nameloop_skipimportant
			setadd l_i 1
			ifnot l_i|=|l_id.Length error '!' must be the last character of the item ID to indicate importance
			set Item:definitions[{l_id}].important true
			jump #Item:define._finishsetup
		#Item:define._nameloop_skipimportant
		ifnot Item:VALIDCHARS|has|l_char error Item ID cannot contain '{l_char}'
		if l_char|=|Item:TONAME[_] set l_id {l_id}_
		else set l_id {l_id}{l_char}
		ifnot Item:TONAME[{l_char}]|=|"" set l_char {Item:TONAME[{l_char}]}
		set l_name {l_name}{l_char}
		setadd l_i 1
	if l_i|<|l_id.Length jump #Item:define._nameloop
	// setup item definition
	set Item:definitions[{l_id}].important false
	#Item:define._finishsetup
	set Item:definitions[{l_id}].name {l_name}
	if l_flavor|=|"" set Item:definitions[{l_id}].cname &a{l_name}
	else set Item:definitions[{l_id}].cname &6{l_name}
	ifnot l_flavor|=|"" set Item:definitions[{l_id}].flavor {l_flavor}
	set Item:definitions[{l_id}] true
quit

// call #Item:setitemid|pkg|{value}
// converts the {value} to uppercase and replace spaces with _ and stores it
// in pkg. this is required because setsplit is case sensitive apparently
#Item:setitemid
	ifnot Item:setup call #Item:setup
	set l_id {runArg2}
	setsplit l_id
	set {runArg1}
	set l_i 0
	#Item:setitemid._loop
		set l_char {l_id[{l_i}]}
		if l_char|=|Item:TONAME[_] set l_char _
		if Item:IDCONVERTCHARS|has|l_char set l_char {Item:TONAME[{l_char}]}
		set {runArg1} {{runArg1}}{l_char}
		setadd l_i 1
	if l_i|<|{runArg1}.Length jump #Item:setitemid._loop
quit

// call #Item:sethas|pkg|{ID}
// sets pkg to a boolean based on whether or not the player has the item {ID}
#Item:sethas
	set l_return {runArg1}
	call #Item:setitemid|l_id|{runArg2}
	ifnot Item:definitions[{l_id}] error Invalid item ID "{l_id}"
	set l_item ;{l_id};
	if Item:items{Item:saveDot}|has|l_item set {l_return} true
	else set {l_return} false
quit

// call #Item:give|{ID}
// tries to give the provided item to the player
// shows a different message if the player already has the item specified
#Item:give
	call #Item:setitemid|l_id|{runArg1}
	ifnot Item:definitions[{l_id}] error Invalid item ID "{l_id}"
	set l_item ;{l_id};
	if Item:items{Item:saveDot}|has|l_item msg &7You've already found the {Item:definitions[{l_id}].name}...
	else msg &7You found an item: {Item:definitions[{l_id}].cname}&7!
	ifnot Item:itemsCmdTip|=|"" msg &7Check what items you have with &a{Item:itemsCmdTip}&7.
	ifnot Item:items{Item:saveDot}|has|l_item set Item:items{Item:saveDot} {Item:items{Item:saveDot}}{l_item}
quit

// call #Item:givesilent|{ID}
// tries to give the provided item to the player
// unlike #Item:give, this does not notify the player
#Item:givesilent
	call #Item:setitemid|l_id|{runArg1}
	ifnot Item:definitions[{l_id}] error Invalid item ID "{l_id}"
	set l_item ;{l_id};
	ifnot Item:items{Item:saveDot}|has|l_item set Item:items{Item:saveDot} {Item:items{Item:saveDot}}{l_item}
quit

// call #Item:take|{ID}
// tries to take the provided item from the player
// silently fails if the player already has the item specified
#Item:take
	call #Item:setitemid|l_id|{runArg1}
	ifnot Item:definitions[{l_id}] error Invalid item ID "{l_id}"
	set l_item ;{l_id};
	ifnot Item:items{Item:saveDot}|has|l_item quit
	msg {Item:definitions[{l_id}].cname}&7 was removed from your items.
	set Item:items{Item:saveDot}[1]
	setsplit Item:items{Item:saveDot} {l_item}
	if Item:items{Item:saveDot}.Length|>|1 set Item:items{Item:saveDot} {Item:items{Item:saveDot}[0]}{Item:items{Item:saveDot}[1]}
	else set Item:items{Item:saveDot} {Item:items{Item:saveDot}[0]}
	if Item:items{Item:saveDot}.Length|=|0 set Item:items{Item:saveDot}
quit

// call #Item:takesilent|{ID}
// tries to take the provided item from the player
// unlike #Item:take, this does not notify the player
#Item:takesilent
	call #Item:setitemid|l_id|{runArg1}
	ifnot Item:definitions[{l_id}] error Invalid item ID "{l_id}"
	set l_item ;{l_id};
	ifnot Item:items{Item:saveDot}|has|l_item quit
	set Item:items{Item:saveDot}[1]
	setsplit Item:items{Item:saveDot} {l_item}
	if Item:items{Item:saveDot}.Length|>|1 set Item:items{Item:saveDot} {Item:items{Item:saveDot}[0]}{Item:items{Item:saveDot}[1]}
	else set Item:items{Item:saveDot} {Item:items{Item:saveDot}[0]}
	if Item:items{Item:saveDot}.Length|=|0 set Item:items{Item:saveDot}
quit

// call #Item:items
// displays a list of all items the player has, similar to /items
#Item:items
	setsplit Item:items{Item:saveDot} ;
	if Item:items{Item:saveDot}.Length|>|0 jump #Item:items.showlist
		msg &cYou have no items!
	quit
	#Item:items.showlist
	msg &eYour items:
	set l_str &f> { }
	set l_firstitem true
	set l_i 0
	#Item:items._loop
		ifnot Item:definitions[{Item:items{Item:saveDot}[{l_i}]}] jump #Item:items._loop_skip
		set l_name {Item:definitions[{Item:items{Item:saveDot}[{l_i}]}].cname}
		ifnot l_firstitem set l_name &8 • {l_name}
		set l_str {l_str}{l_name}
		set l_firstitem false
		#Item:items._loop_skip
		setadd l_i 1
	if l_i|<|Item:items{Item:saveDot}.Length jump #Item:items._loop
	msg {l_str}
	ifnot Item:generalItemTip|=|"" jump #Item:items._skipdefaulttip
		if Item:saveDot|=|"." msg &7Notably, items are different from &a/stuff&7 because you will not have access to them outside this map.
		else msg &7Notably, items are different from &a/stuff&7 because they will disappear if you leave the map.
	#Item:items._skipdefaulttip
	ifnot Item:generalItemTip|=|"" msg {Item:generalItemTip}
	ifnot Item:lookCmdTip|=|"" msg &eUse &b{Item:lookCmdTip} [item name]&e to examine items.
	ifnot Item:dropCmdTip|=|"" msg &7To delete an item, use &b{Item:dropCmdTip} [item name]
quit

// call #Item:look|{ID}
// attempts to inspect an item, similar to /stuff look {ID}
// falls back on default text if no flavor text is defined
#Item:look
	call #Item:setitemid|l_id|{runArg1}
	if l_id|has|";" jump #Item:_donthave
	set l_item ;{l_id};
	ifnot Item:items{Item:saveDot}|has|l_item jump #Item:_donthave
	ifnot Item:definitions[{l_id}] jump #Item:look.invalid
	ifnot Item:definitions[{l_id}].flavor|=|"" jump #Item:look.flavor
	msg &7You don't notice anything particular about the {Item:definitions[{l_id}].cname}&7.
quit
#Item:look.flavor
	msg &7You examine the {Item:definitions[{l_id}].cname}&7...
	delay 1000
	msg {Item:definitions[{l_id}].flavor}
quit
#Item:look.invalid
	msg &7You examine the {Item:definitions[{l_id}].cname}&7...
	delay 1000
	setlength Item:items{Item:saveDot} ;
	setrandlist l_msg Can't you see anything?|The silence is deafening.|When will you stop being yourself?|You don't notice anything particular about the {Item:definitions[{l_id}].cname}&7.|The {Item:definitions[{l_id}].cname}&7 examines you. You have {Item:items{Item:saveDot}.Length} items.|You cannot grasp the {Item:definitions[{l_id}].cname}&7's true form!|How does it feel to not exist?|It's as if it was never there.|The {Item:definitions[{l_id}].cname}&7 can't remember itself.|Humans are imperfect. The {Item:definitions[{l_id}].cname}&7 is proof of that.|None of this was supposed to happen.|The {Item:definitions[{l_id}].cname}&7 seems to be easily forgettable.|
	msg {l_msg}
quit

// call #Item:drop|{ID}
// attempts to drop an item, similar to /drop {ID}
// will fail if the item has been defined as 'important'
#Item:drop
	call #Item:setitemid|l_id|{runArg1}
	if Item:definitions[{l_id}].important jump #Item:drop._notallowed
	if l_id|has|";" jump #Item:_donthave
	set l_item ;{l_id};
	ifnot Item:items{Item:saveDot}|has|l_item jump #Item:_donthave
	msg {Item:definitions[{l_id}].cname}&7 was removed from your items.
	setsplit Item:items{Item:saveDot} {l_item}
	if Item:items{Item:saveDot}.Length|>|1 set Item:items{Item:saveDot} {Item:items{Item:saveDot}[0]}{Item:items{Item:saveDot}[1]}
	else set Item:items{Item:saveDot} {Item:items{Item:saveDot}[0]}
	if Item:items{Item:saveDot}.Length|=|0 set Item:items{Item:saveDot}
quit
#Item:drop._notallowed
	msg &7You couldn't bring yourself to drop the {Item:definitions[{l_id}].cname}&7...
quit

#Item:_donthave
	msg &cYou dont have any item called "{l_id}".
quit