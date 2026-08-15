extends AutoworkTest

const Helpers = preload("res://tests/http_helpers.gd")

func _after_each():
	if RemoteControlServer.is_started():
		RemoteControlServer.stop()

func test_003_exec_ping():
	var err = RemoteControlServer.start()
	assert_eq(err, OK)

	var direct = RemoteControlRegistry.execute("ping", {})
	assert_true(direct.get("ok", false), "direct ping ok")
	assert_eq(direct.get("type", ""), "pong")

	var port = RemoteControlServer.get_port()
	var body = JSON.stringify({"command": "ping", "args": {}})
	var resp = await Helpers.request(
		HTTPClient.METHOD_POST,
		"http://127.0.0.1:%d/v1/exec" % port,
		PackedStringArray(["Content-Type: application/json"]),
		body
	)
	assert_eq(resp.get("code", 0), 200, "POST /v1/exec ping returns 200")
	var payload = JSON.parse_string(resp.get("body", "{}"))
	assert_true(payload.get("ok", false), "exec ping ok")
	assert_eq(payload.get("type", ""), "pong")
