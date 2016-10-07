Meteor.methods
	loadNextMessages: (rid, end, limit=20) ->

		check rid, String
		# check end, Match.Optional(Number)
		check limit, Number

		if not Meteor.userId()
			throw new Meteor.Error 'error-invalid-user', 'Invalid user', { method: 'loadNextMessages' }

		# Rest of verification is in RocketChat.loadMessages

		options =
			sort:
				ts: 1
			limit: limit

		direction = if end then 'after' else 'both'

		[messages, more] = RocketChat.loadMessages(rid, end, direction, options)
		
		if messages is false
			return false

		return {
			more: more
			messages: messages
		}
