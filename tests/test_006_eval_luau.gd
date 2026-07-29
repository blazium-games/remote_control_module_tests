extends AutoworkTest

const Helpers = preload("res://tests/http_helpers.gd")

func after_each():
	if RemoteControlServer.is_started():
		RemoteControlServer.stop()

func test_006_eval_luau_expression_and_statement():
	if not ClassDB.class_exists("LuaState"):
		pending("LuaState not available (luau_module disabled)")
		return

	var err = RemoteControlServer.start()
	assert_eq(err, OK)
	RemoteControlServer.allow_eval = true
	var port = RemoteControlServer.get_port()

	var status = Helpers.request(HTTPClient.METHOD_GET, "http://127.0.0.1:%d/v1/status" % port)
	assert_eq(status.get("code", 0), 200)
	var status_body = JSON.parse_string(status.get("body", "{}"))
	assert_true(status_body.get("luau_eval_available", false), "status reports luau_eval_available")

	var expr_body = JSON.stringify({"expression": "1 + 1", "language": "luau"})
	var expr_res = Helpers.request(
		HTTPClient.METHOD_POST,
		"http://127.0.0.1:%d/v1/eval" % port,
		PackedStringArray(["Content-Type: application/json"]),
		expr_body
	)
	assert_eq(expr_res.get("code", 0), 200, "luau expression eval HTTP 200")
	var expr_json = JSON.parse_string(expr_res.get("body", "{}"))
	assert_true(expr_json.get("ok", false), "luau expression ok")
	assert_eq(expr_json.get("language", ""), "luau")
	assert_eq(int(expr_json.get("result", -1)), 2)

	var stmt_body = JSON.stringify({"expression": "local x = 3; return x", "language": "luau"})
	var stmt_res = Helpers.request(
		HTTPClient.METHOD_POST,
		"http://127.0.0.1:%d/v1/eval" % port,
		PackedStringArray(["Content-Type: application/json"]),
		stmt_body
	)
	assert_eq(stmt_res.get("code", 0), 200, "luau statement eval HTTP 200")
	var stmt_json = JSON.parse_string(stmt_res.get("body", "{}"))
	assert_true(stmt_json.get("ok", false), "luau statement ok: %s" % str(stmt_json.get("error", "")))
	assert_eq(int(stmt_json.get("result", -1)), 3)

	var direct = RemoteControlServer.eval_expression("2 * 5", "lua")
	assert_true(direct.get("ok", false), "direct luau via language alias lua")
	assert_eq(int(direct.get("result", -1)), 10)
