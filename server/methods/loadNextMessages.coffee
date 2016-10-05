Meteor.methods
	loadNextMessages: (rid, end, limit=20) ->

		check rid, String
		# check end, Match.Optional(Number)
		check limit, Number

		if not Meteor.userId()
			throw new Meteor.Error 'error-invalid-user', 'Invalid user', { method: 'loadNextMessages' }

		fromId = Meteor.userId()

		unless Meteor.call 'canAccessRoom', rid, fromId
			return false

		options =
			needsApproval: {$ne: true}
			sort:
				ts: 1
			limit: limit

		if not RocketChat.settings.get 'Message_ShowEditedStatus'
			options.fields = { 'editedAt': 0 }

		if end?
			if !RocketChat.isApprovalRequired(rid) or RocketChat.authz.hasPermission(fromId, 'message-approval', rid)
				records = RocketChat.models.Messages.findVisibleByRoomIdAfterTimestamp(rid, end, options).fetch()
			else
				records = RocketChat.models.Messages.findVisibleAcceptedByRoomIdAfterTimestamp(rid, end, options).fetch()
		else
			if !RocketChat.isApprovalRequired(rid) or RocketChat.authz.hasPermission(fromId, 'message-approval', rid)
				records = RocketChat.models.Messages.findVisibleByRoomId(rid, options).fetch()
			else
				records = RocketChat.models.Messages.findVisibleAcceptedByRoomId(rid, options).fetch()

		messages = _.map records, (message) ->
			message.starred = _.findWhere message.starred, { _id: fromId }
			return message

		return {
			messages: messages
		}
