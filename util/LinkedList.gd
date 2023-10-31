class_name LinkedList

class LinkedListItem extends Object:
	var previous = null
	var next = null
	var value
	func _init(v):
		value = v

var _front:LinkedListItem = null
var _end:LinkedListItem = null

var _size: int = 0

func size():
	return _size

func push(value):
	_size += 1
	
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
	
	_size -= 1
	
	var old_front = _front
	var value = old_front.value
	
	_front = old_front.next
	if _front == null: _end = null
	
	#badass alert
	old_front.free()
	
	return value

func empty():
	return !_front

func _link(before:LinkedListItem, after:LinkedListItem):
	before.next = after
	after.previous = before
