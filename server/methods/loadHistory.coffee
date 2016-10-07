Meteor.methods
	loadHistory: (rid, end, limit=20, ls) ->

		check rid, String
		# check end, Match.Optional(Number)
		# check limit, Number
		# check ls, Match.Optional(Date)

		if not Meteor.userId()
			throw new Meteor.Error 'error-invalid-user', 'Invalid user', { method: 'loadHistory' }

		# Rest of verification is in RocketChat.loadMessages

		options =
			sort:
				ts: -1
			limit: limit

		direction = if end then 'before' else 'both'

		[messages, more] = RocketChat.loadMessages(rid, end, direction, options)

		if messages is false
			return false

		unreadNotLoaded = 0

		if ls?
			firstMessage = messages[messages.length - 1]
			
			if firstMessage?.ts > ls

				options =
					sort:
						ts: 1
					limit: 1

				viewerId = Meteor.userId()

				if not RocketChat.isApprovalRequired rid, viewerId
					unreadMessages = RocketChat.models.Messages.findVisibleByRoomIdBetweenTimestamps(
						rid, ls, firstMessage.ts, options)
				else
					unreadMessages = RocketChat.models.Messages.findVisibleAcceptedByRoomIdBetweenTimestamps(
						rid, viewerId, ls, firstMessage.ts, options)

				# Either case finds at least one message since we use
				# firstMessage.ts and have access to it
				firstUnread = unreadMessages.fetch()[0]

				# Gets full count despite limit
				unreadNotLoaded = unreadMessages.count()
	
		return {
			more: more
			messages: messages
			firstUnread: firstUnread
			unreadNotLoaded: unreadNotLoaded
		}
