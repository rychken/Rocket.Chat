RegExp.escape = (s) ->
	return s.replace /[-\/\\^$*+?.()|[\]{}]/g, '\\$&'

RegExp.url = ///
	([A-Za-z]{3,9}):\/\/
	([-;:&=\+\$,\w]+@{1})?
	([-A-Za-z0-9\.]+)+
	:?
	(\d+)?
	(
		(\/[-\+=!:~%\/\.@\,\w]*)?
		\??
		([-\+=&!:;%@\/\.\,\w]+)?
		(?:\#([^\s\)]+))?
	)?
	///

RegExp.urls = new RegExp RegExp.url.source, 'g'

RegExp.messageReference = new RegExp '^\\[ \\]\\(' + RegExp.url.source + '\\)'

