extends AutoworkTest

func _after_each():
	if ClassDB.class_exists("RemoteControlServer") and RemoteControlServer.is_started():
		RemoteControlServer.stop()

func test_001_lifecycle():
	assert_true(ClassDB.class_exists("RemoteControlServer"), "RemoteControlServer class registered")
	assert_true(ClassDB.class_exists("RemoteControlRegistry"), "RemoteControlRegistry class registered")
	assert_false(RemoteControlServer.is_started(), "Server starts stopped")

	var err = RemoteControlServer.start()
	assert_eq(err, OK, "start() succeeds")
	assert_true(RemoteControlServer.is_started(), "Server reports started")
	assert_true(RemoteControlServer.get_port() > 0, "Port assigned")

	RemoteControlServer.stop()
	assert_false(RemoteControlServer.is_started(), "stop() clears started state")
