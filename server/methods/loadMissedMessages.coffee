Meteor.methods
	loadMissedMessages: (rid, start) ->

		check rid, String
		check start, Date

		if not Meteor.userId()
			throw new Meteor.Error 'error-invalid-user', 'Invalid user', { method: 'loadMissedMessages' }

		viewerId = Meteor.userId()
		unless Meteor.call 'canAccessRoom', rid, viewerId
			return false

		options =
			sort:
				ts: -1

		if not RocketChat.settings.get 'Message_ShowEditedStatus'
			options.fields = { 'editedAt': 0 }

		records = RocketChat.models.Messages.findVisibleByRoomIdAfterTimestamp(rid, start, options).fetch()

		messages = records.filter (message) ->
			return not RocketChat.isApprovalRequired rid, viewerId, message._id

		return messages
