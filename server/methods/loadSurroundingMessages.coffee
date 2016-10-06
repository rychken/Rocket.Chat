Meteor.methods
	loadSurroundingMessages: (message, limit=50) ->

		check message, Object
		check limit, Number

		if not Meteor.userId()
			throw new Meteor.Error 'error-invalid-user', 'Invalid user', { method: 'loadSurroundingMessages' }

		viewerId = Meteor.userId()

		unless message._id
			return false

		message = RocketChat.models.Messages.findOneById(message._id)

		unless message?.rid
			return false

		unless Meteor.call 'canAccessRoom', message.rid, viewerId
			return false

		limit = limit - 1

		options =
			sort:
				ts: -1
			limit: Math.ceil(limit/2)

		if not RocketChat.settings.get 'Message_ShowEditedStatus'
			options.fields = { 'editedAt': 0 }

		records = RocketChat.models.Messages.findVisibleByRoomIdBeforeTimestamp(message.rid, message.ts, options).fetch()

		moreBefore = records.length is options.limit

		messages = _.map records, (message) ->
			message.starred = _.findWhere message.starred, { _id: viewerId }
			return message

		messages.push message

		options.sort = { ts: 1 }
		options.limit = Math.floor(limit/2)

		records = RocketChat.models.Messages.findVisibleByRoomIdAfterTimestamp(message.rid, message.ts, options).fetch()

		moreAfter = records.length is options.limit
		
		afterMessages = _.map records, (message) ->
			message.starred = _.findWhere message.starred, { _id: viewerId }
			return message

		messages = messages.concat afterMessages

		messages = messages.filter (message) ->
			return not RocketChat.isApprovalRequired message.rid, viewerId, message._id

		return {
			messages: messages
			moreBefore: moreBefore
			moreAfter: moreAfter
		}
