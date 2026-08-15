extends AutoworkTest

func after_each():
	if RemoteControlServer.is_started():
		RemoteControlServer.stop()

func test_007_focus_window_and_mcp_status_builtins():
	var err = RemoteControlServer.start()
	assert_eq(err, OK)
	assert_true(RemoteControlRegistry.has_command("focus_window"), "focus_window builtin registered")
	assert_true(RemoteControlRegistry.has_command("bring_to_front"), "bring_to_front alias registered")
	assert_true(RemoteControlRegistry.has_command("mcp_status"), "mcp_status builtin registered")

	var focus = RemoteControlRegistry.execute("focus_window", {})
	assert_true(focus.get("ok", false), "focus_window ok: %s" % str(focus))
	assert_true(focus.get("focused", false), "focus_window focused flag")

	var mcp = RemoteControlRegistry.execute("mcp_status", {})
	assert_true(mcp.get("ok", false), "mcp_status ok: %s" % str(mcp))
	assert_true(mcp.has("available"), "mcp_status has available")
	assert_true(mcp.has("started"), "mcp_status has started")
	assert_true(mcp.has("port"), "mcp_status has port")
	# JustAMCP may be compiled in but not listening in this Autowork run.
	assert_true(bool(mcp.get("available", false)), "JustAMCP available in editor build")
