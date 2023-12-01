extends Control

class_name UIPopup

signal popup_close()

func open():
	visible = true

func close():
	visible = false
	popup_close.emit()

func click_out():
	close()
