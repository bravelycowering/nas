# Using labels as boolean constants

todo: write this and make the example make sense

um so basically you define a label and then check if it exists idfk

```c
#MOVABLE[141]
#MOVABLE[142]
#MOVABLE[143]
#MOVABLE[602]
#MOVABLE[603]

#onLeftClick
	if label #MOVABLE[{clickedID}] jump #onMoveClick|PULL
quit
#onRightClick
	if label #MOVABLE[{clickedID}] jump #onMoveClick|PUSH
quit
```

why? um doesnt consume an action to define the label and it auto updates when u reload script thank you for coming to my ted talk