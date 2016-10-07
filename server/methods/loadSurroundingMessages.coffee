Meteor.methods
	loadSurroundingMessages: (message, limit=50) ->

		check message, Object
		check limit, Number

		if not Meteor.userId()
			throw new Meteor.Error 'error-invalid-user', 'Invalid user', { method: 'loadSurroundingMessages' }

		unless message._id
			return false

		message = RocketChat.models.Messages.findOneById(message._id)

		unless message?.rid
			return false

		# Rest of verification is in RocketChat.loadMessages

		limit = limit - 1

		options =
			sort:
				ts: -1
			limit: Math.ceil(limit/2)

		[beforeMessages, moreBefore] = RocketChat.loadMessages(message.rid, message.ts, 'before', options)
		
		if beforeMessages is false
			return false

		options.sort = { ts: 1 }
		options.limit = Math.floor(limit/2)

		[afterMessages, moreAfter] = RocketChat.loadMessages(message.rid, message.ts, 'after', options)
		
		if afterMessages is false
			return false

		messages = beforeMessages.concat message, afterMessages
		
		if messages is false
			return false

		return {
			messages: messages
			moreBefore: moreBefore
			moreAfter: moreAfter
		}
