class_name ExpressionsParser

class KeyMatch:
	var matched: String
	var value: String

static func parse(text:String, obj, params) -> String:
	while text.contains("["):
		var key_match = _find_between(text, "[", "]")
		if !key_match: break
		
		if !key_match.value.begins_with("."):
			# replace all [x] properties with obj.x
			text = text.replace(key_match.matched, str(obj.get(key_match.value)))
		else:
			# replace all [.x] properties with params.x
			text = text.replace(key_match.matched, str(params.get(key_match.value.substr(1,key_match.value.length()-1))))
	
	# eval all {} expressions
	while text.contains("{"):
		var key_match = _find_between(text, "{", "}")
		var expression = Expression.new()
		var error = expression.parse(key_match.value)
		if error == OK:
			var result = expression.execute()
			if !expression.has_execute_failed():
				text = text.replace(key_match.matched, str(result))
			else:
				text = text.replace(key_match.matched, "%s_execution_error_%s" % [str(result), expression.get_error_text()])
		else:
			text = text.replace(key_match.matched, expression.get_error_text())
	
	return text

static func _find_between(text:String, open:String, close:String):
	var open_index = text.find(open)
	if open_index == -1: return null
	
	var text1 = text.substr(open_index)
	var close_index = text1.find(close)
	if close_index <= 1: return null
	
	var key_match = KeyMatch.new()
	key_match.matched = text.substr(open_index,close_index+1)
	key_match.value = key_match.matched.substr(1,key_match.matched.length() - 2)
	
	return key_match
