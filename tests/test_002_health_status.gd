extends AutoworkTest

const Helpers = preload("res://tests/http_helpers.gd")

func _after_each():
	if RemoteControlServer.is_started():
		RemoteControlServer.stop()

func test_002_health_and_status_http():
	var err = RemoteControlServer.start()
	assert_eq(err, OK)
	var port = RemoteControlServer.get_port()

	var health = await Helpers.request(HTTPClient.METHOD_GET, "http://127.0.0.1:%d/v1/health" % port)
	assert_eq(health.get("error", ""), "", "health request error")
	assert_eq(health.get("code", 0), 200, "GET /v1/health returns 200")
	var health_body = JSON.parse_string(health.get("body", "{}"))
	assert_true(health_body.get("ok", false), "health ok")

	var status = await Helpers.request(HTTPClient.METHOD_GET, "http://127.0.0.1:%d/v1/status" % port)
	assert_eq(status.get("code", 0), 200, "GET /v1/status returns 200")
	var status_body = JSON.parse_string(status.get("body", "{}"))
	assert_eq(status_body.get("module", ""), "remote_control")
	assert_true(status_body.has("pid"), "status includes pid")
	assert_true(status_body.has("luau_eval_available"), "status includes luau_eval_available")
