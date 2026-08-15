extends AutoworkTest

const Helpers = preload("res://tests/http_helpers.gd")

func _after_each():
	if RemoteControlServer.is_started():
		RemoteControlServer.stop()

func test_004_command_list():
	var err = RemoteControlServer.start()
	assert_eq(err, OK)
	assert_true(RemoteControlRegistry.has_command("ping"))
	assert_true(RemoteControlRegistry.has_command("list_commands"))

	var listed = RemoteControlRegistry.list_commands()
	assert_true(listed.size() >= 3, "builtins registered")

	var port = RemoteControlServer.get_port()
	var resp = await Helpers.request(HTTPClient.METHOD_GET, "http://127.0.0.1:%d/v1/commands" % port)
	assert_eq(resp.get("code", 0), 200)
	var payload = JSON.parse_string(resp.get("body", "{}"))
	assert_true(payload.get("ok", false))
	assert_true(payload.get("commands", []).size() >= 3)
