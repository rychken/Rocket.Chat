Meteor.methods
	loadMissedMessages: (rid, start) ->

		check rid, String
		check start, Date

		if not Meteor.userId()
			throw new Meteor.Error 'error-invalid-user', 'Invalid user', { method: 'loadMissedMessages' }

		# Rest of verification is in RocketChat.loadMessages

		options =
			sort:
				ts: -1

		[messages, more] = RocketChat.loadMessages(rid, start, 'after', options)

		return messages
