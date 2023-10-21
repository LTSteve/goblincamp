class_name LinkedList

class LinkedListItem:
	var previous = null
	var next = null
	var value
	func _init(v):
		value = v

var _front:LinkedListItem = null
var _end:LinkedListItem = null

func push(value):
	var linked_list_item = LinkedListItem.new(value)
	if _front == null:
		_front = linked_list_item
		_end = linked_list_item
		return
	elif _end == _front:
		_end = linked_list_item
		_link(_front,_end)
	else:
		_link(_end, linked_list_item)
		_end = linked_list_item

func front():
	return _front.value if _front else null

func pop():
	if !_front: return null
	
	var value = _front.value
	
	_front = _front.next
	if _front == null: _end = null
	
	return value

func empty():
	return !_front

func _link(before:LinkedListItem, after:LinkedListItem):
	before.next = after
	after.previous = before
