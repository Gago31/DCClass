class_name TimeString
extends Object


static func is_valid(s: String) -> bool:
	var t := s.split(":")
	var n := t.size()
	if n > 3 or n < 1:
		return false
	for i in n:
		if i == 0:
			if not t[n - 1 - i].is_valid_float():
				return false
		elif not t[n - 1 - i].is_valid_int():
			return false
	return true

static func from_seconds(t: float) -> String:
	var total_seconds := snappedf(t, 0.01)
	var seconds := fmod(total_seconds, 60)
	var total_minutes := int(total_seconds - seconds) / 60
	var minutes := total_minutes % 60
	var hours := (total_minutes - minutes) / 60
	var s := "%02d:%02d:%02.2f" % [hours, minutes, seconds]
	return s

static func to_seconds(s: String) -> float:
	var t := s.split(":")
	var n := t.size()
	var valid := is_valid(s)
	if not valid: return 0.0
	var seconds: float = 0
	var minutes: int = 0
	var hours: int = 0
	seconds = float(t[n - 1])
	if n > 1:
		minutes = int(t[n - 2])
	if n > 2:
		hours = int(t[n - 3])
	return (hours * 60 + minutes) * 60 + seconds
