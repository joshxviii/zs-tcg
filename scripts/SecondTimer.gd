class_name SecondTimer extends Node

signal timeout
signal time_changed

var time_left : int = 0
var wait_time : float = 1.0
var stopped := true

func start(duration:=wait_time):
	stopped = false
	count_down(duration)

func stop():
	time_left=0
	stopped = true

func is_stopped() -> bool:
	return stopped

func count_down(time:int):
	if stopped: return
	time_left=time
	time_changed.emit()
	await Global.get_tree().create_timer(1.0).timeout
	if time<=0:
		timeout.emit()
		stop()
		return
	count_down(time-1)
