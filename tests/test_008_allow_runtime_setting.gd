extends AutoworkTest

func test_008_allow_runtime_project_setting():
	## Template/runtime builds gate auto-start on blazium/remote_control/allow_runtime.
	## Editor Autowork runs under TOOLS_ENABLED, so we assert the setting surface exists
	## and can be toggled for Hub-exported projects that ship with hub_build=yes.
	assert_true(
		ProjectSettings.has_setting("blazium/remote_control/allow_runtime"),
		"allow_runtime project setting is registered"
	)
	var previous = ProjectSettings.get_setting("blazium/remote_control/allow_runtime")
	ProjectSettings.set_setting("blazium/remote_control/allow_runtime", true)
	assert_true(bool(ProjectSettings.get_setting("blazium/remote_control/allow_runtime")))
	ProjectSettings.set_setting("blazium/remote_control/allow_runtime", false)
	assert_false(bool(ProjectSettings.get_setting("blazium/remote_control/allow_runtime")))
	ProjectSettings.set_setting("blazium/remote_control/allow_runtime", previous)
