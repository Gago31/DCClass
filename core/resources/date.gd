class_name Date
extends Resource


## A date resource
##
## It stores a date as an integer and wraps the [Time] methods for using it


## The string of date value, in DD-MM-YYYY format
@export var date: String :
	get:
		var yyyymmdd := Time.get_date_string_from_unix_time(_date)
		return _reverse_date_format(yyyymmdd)
	set(value):
		var yyyymmdd := _reverse_date_format(value)
		_date = Time.get_unix_time_from_datetime_string(yyyymmdd)

var _date: int


func _init():
	_date = floori(Time.get_unix_time_from_system())

func _reverse_date_format(input:String) -> String:
	var elements := input.split("-")
	elements.reverse()
	var element_array := Array(elements)
	return "{0}-{1}-{2}".format(element_array)
