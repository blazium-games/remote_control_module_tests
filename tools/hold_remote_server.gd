extends SceneTree

func _initialize() -> void:
	var err = RemoteControlServer.start()
	print("hold_remote_server start err=", err, " port=", RemoteControlServer.get_port())
	var timer := Timer.new()
	root.add_child(timer)
	timer.wait_time = 15.0
	timer.one_shot = true
	timer.timeout.connect(func(): quit(0))
	timer.start()
