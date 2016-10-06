Meteor.methods
	loadNextMessages: (rid, end, limit=20) ->

		check rid, String
		# check end, Match.Optional(Number)
		check limit, Number

		if not Meteor.userId()
			throw new Meteor.Error 'error-invalid-user', 'Invalid user', { method: 'loadNextMessages' }

		viewerId = Meteor.userId()

		unless Meteor.call 'canAccessRoom', rid, viewerId
			return false

		options =
			sort:
				ts: 1
			limit: limit

		if not RocketChat.settings.get 'Message_ShowEditedStatus'
			options.fields = { 'editedAt': 0 }

		if end?
			records = RocketChat.models.Messages.findVisibleByRoomIdAfterTimestamp(rid, end, options).fetch()
		else
			records = RocketChat.models.Messages.findVisibleByRoomId(rid, options).fetch()

		more = records.length is options.limit

		messages = records.filter (message) ->
			return not RocketChat.isApprovalRequired rid, viewerId, message._id

		messages = _.map messages, (message) ->
			message.starred = _.findWhere message.starred, { _id: viewerId }
			return message

		return {
			more: more
			messages: messages
		}
