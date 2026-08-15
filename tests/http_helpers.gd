extends RefCounted
class_name RemoteControlHTTPHelpers

static func request(method: int, url: String, headers: PackedStringArray = PackedStringArray(), body: String = "") -> Dictionary:
	var parsed = url
	if parsed.begins_with("http://"):
		parsed = parsed.substr(7)
	var host_port = parsed.get_slice("/", 0)
	var path = "/" + parsed.substr(host_port.length() + 1) if parsed.length() > host_port.length() else "/"
	var host = host_port.get_slice(":", 0)
	var port = int(host_port.get_slice(":", 1))

	var client := HTTPClient.new()
	var err := client.connect_to_host(host, port)
	if err != OK:
		return {"code": 0, "body": "", "error": "connect failed: %s" % err}

	var tree := Engine.get_main_loop() as SceneTree
	var deadline := Time.get_ticks_msec() + 5000
	while client.get_status() == HTTPClient.STATUS_CONNECTING or client.get_status() == HTTPClient.STATUS_RESOLVING:
		client.poll()
		if tree:
			await tree.process_frame
		else:
			OS.delay_msec(10)
		if Time.get_ticks_msec() > deadline:
			return {"code": 0, "body": "", "error": "connect timeout"}

	err = client.request(method, path, headers, body)
	if err != OK:
		return {"code": 0, "body": "", "error": "request failed: %s" % err}

	deadline = Time.get_ticks_msec() + 5000
	while client.get_status() == HTTPClient.STATUS_REQUESTING:
		client.poll()
		if tree:
			await tree.process_frame
		else:
			OS.delay_msec(10)
		if Time.get_ticks_msec() > deadline:
			return {"code": 0, "body": "", "error": "request timeout"}

	var code := client.get_response_code()
	var response := PackedByteArray()
	while client.get_status() == HTTPClient.STATUS_BODY:
		client.poll()
		var chunk := client.read_response_body_chunk()
		if chunk.size() > 0:
			response.append_array(chunk)
		elif tree:
			await tree.process_frame
		else:
			OS.delay_msec(5)

	return {"code": code, "body": response.get_string_from_utf8(), "error": ""}
