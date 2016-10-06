Meteor.methods
	loadHistory: (rid, end, limit=20, ls) ->

		check rid, String
		# check end, Match.Optional(Number)
		# check limit, Number
		# check ls, Match.Optional(Date)

		if not Meteor.userId()
			throw new Meteor.Error 'error-invalid-user', 'Invalid user', { method: 'loadHistory' }

		viewerId = Meteor.userId()
		room = Meteor.call 'canAccessRoom', rid, viewerId
		unless room
			return false

		if room.t is 'c' and not RocketChat.authz.hasPermission(viewerId, 'preview-c-room') and room.usernames.indexOf(room.username) is -1
			return false

		options =
			sort:
				ts: -1
			limit: limit

		if not RocketChat.settings.get 'Message_ShowEditedStatus'
			options.fields = { 'editedAt': 0 }

		if end?
			records = RocketChat.models.Messages.findVisibleByRoomIdBeforeTimestamp(rid, end, options).fetch()
		else
			records = RocketChat.models.Messages.findVisibleByRoomId(rid, options).fetch()

		more = records.length is options.limit

		messages = records.filter (message) ->
			return not RocketChat.isApprovalRequired rid, viewerId, message._id

		messages = _.map messages, (message) ->
			message.starred = _.findWhere message.starred, { _id: viewerId }
			return message

		unreadNotLoaded = 0

		if ls?
			firstMessage = messages[messages.length - 1]
			if firstMessage?.ts > ls
				delete options.limit
				unreadMessages = RocketChat.models.Messages.findVisibleByRoomIdBetweenTimestamps(rid, ls, firstMessage.ts, { limit: 1, sort: { ts: 1 } })
				firstUnread = unreadMessages.fetch()[0]
				unreadNotLoaded = unreadMessages.count()

		return {
			more: more
			messages: messages
			firstUnread: firstUnread
			unreadNotLoaded: unreadNotLoaded
		}
