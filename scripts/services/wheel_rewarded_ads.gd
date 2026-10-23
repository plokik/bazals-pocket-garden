extends RefCounted
## Only the native SDK can produce an earned receipt. Desktop has no fake ad.
var backend: Variant

func _init() -> void:
	if OS.get_name() == "Android":
		var wrapper := Engine.get_singleton("JavaClassWrapper")
		if wrapper != null:
			backend = wrapper.wrap("com.howtogrow.ads.RewardedWheelBridge")

func available() -> bool:
	return backend != null

func request(id: String) -> bool:
	return available() and bool(backend.request(id))

func state() -> Dictionary:
	if not available(): return {}
	var value: Variant = JSON.parse_string(str(backend.getState()))
	return value if value is Dictionary else {}

func acknowledge(id: String) -> void:
	if available(): backend.acknowledge(id)
