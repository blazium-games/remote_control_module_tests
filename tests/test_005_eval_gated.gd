extends AutoworkTest

const Helpers = preload("res://tests/http_helpers.gd")

func _after_each():
	if RemoteControlServer.is_started():
		RemoteControlServer.stop()

func test_005_eval_gated_and_allowed():
	var err = RemoteControlServer.start()
	assert_eq(err, OK)
	# start() loads ProjectSettings; override after start for the gate check.
	RemoteControlServer.allow_eval = false
	var port = RemoteControlServer.get_port()

	var body = JSON.stringify({"expression": "2 + 2"})
	var denied = await Helpers.request(
		HTTPClient.METHOD_POST,
		"http://127.0.0.1:%d/v1/eval" % port,
		PackedStringArray(["Content-Type: application/json"]),
		body
	)
	assert_eq(denied.get("code", 0), 403, "eval disabled returns 403")

	RemoteControlServer.allow_eval = true
	var allowed = RemoteControlServer.eval_expression("2 + 2")
	assert_true(allowed.get("ok", false), "direct eval ok when enabled")
	assert_eq(int(allowed.get("result", -1)), 4)
	assert_eq(allowed.get("language", ""), "gdscript")

	var gd_body = JSON.stringify({"expression": "3 + 1", "language": "gdscript"})
	var gd_http = await Helpers.request(
		HTTPClient.METHOD_POST,
		"http://127.0.0.1:%d/v1/eval" % port,
		PackedStringArray(["Content-Type: application/json"]),
		gd_body
	)
	assert_eq(gd_http.get("code", 0), 200, "language gdscript HTTP 200")
	var gd_json = JSON.parse_string(gd_http.get("body", "{}"))
	assert_true(gd_json.get("ok", false), "language gdscript ok")
	assert_eq(gd_json.get("language", ""), "gdscript")
	assert_eq(int(gd_json.get("result", -1)), 4)

	var alias = RemoteControlServer.eval_expression("5 - 1", "gd")
	assert_true(alias.get("ok", false), "language alias gd")
	assert_eq(int(alias.get("result", -1)), 4)
