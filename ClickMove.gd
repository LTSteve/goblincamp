extends Camera3D

const RAY_LENGTH = 1000.0
const SCROLL_RATE = 5.0

var leftRight = 0
var upDown = 0

var aPressed
var dPressed
var wPressed
var sPressed

func _input(event):
	if event is InputEventKey:
		if(event.keycode == KEY_A):
			aPressed = true if event.is_pressed() else false
		if(event.keycode == KEY_D):
			dPressed = true if event.is_pressed() else false
		if(event.keycode == KEY_W):
			wPressed = true if event.is_pressed() else false
		if(event.keycode == KEY_S):
			sPressed = true if event.is_pressed() else false
	
	leftRight = 0
	upDown = 0
	
	if aPressed && !dPressed:
		leftRight = -1
	if dPressed && !aPressed:
		leftRight = 1
	if wPressed && !sPressed:
		upDown = -1
	if sPressed && !wPressed:
		upDown = 1
	pass


func _physics_process(delta):
	if leftRight != 0:
		global_position += quaternion * Vector3(SCROLL_RATE * leftRight * delta, 0, 0)
	if upDown != 0:
		global_position += quaternion * Vector3(0,0,SCROLL_RATE * upDown * delta)
