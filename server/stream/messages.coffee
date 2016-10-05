@msgStream = new Meteor.Streamer 'room-messages'
@modStream = new Meteor.Streamer 'moderator-room-messages'

msgStream.allowWrite 'none'
modStream.allowWrite 'none'

getAllowReadFunc = (streamType) ->
	return (eventName) ->
		try
			room = Meteor.call 'canAccessRoom', eventName, this.userId
			if not room
				return false

			if room.t is 'c' and not RocketChat.authz.hasPermission(this.userId, 'preview-c-room') and room.usernames.indexOf(room.username) is -1
				return false

			if streamType == 'mod' and not RocketChat.authz.hasPermission this.userId, 'message-approval', room._id
				return false

			return true
		catch e
			return false

msgStream.allowRead getAllowReadFunc('msg')
modStream.allowRead getAllowReadFunc('mod')

msgStream.allowRead '__my_messages__', 'all'
modStream.allowRead '__my_messages__', 'all'

allowEmitFunc = (eventName, msg, options) ->
	try
		room = Meteor.call 'canAccessRoom', msg.rid, this.userId
		if not room
			return false

		options.roomParticipant = room.usernames.indexOf(room.username) > -1
		options.roomType = room.t

		return true
	catch e
		return false

msgStream.allowEmit '__my_messages__', allowEmitFunc
modStream.allowEmit '__my_messages__', allowEmitFunc

Meteor.startup ->
	fields = undefined

	if not RocketChat.settings.get 'Message_ShowEditedStatus'
		fields = { 'editedAt': 0 }

	RocketChat.models.Messages.on 'change', (type, args...) ->
		records = RocketChat.models.Messages.getChangedRecords type, args[0], fields

		for record in records
			if record._hidden isnt true and not record.imported?
				if record.needsApproval
					modStream.emit '__my_messages__', record, {}
					modStream.emit record.rid, record
				else
					msgStream.emit '__my_messages__', record, {}
					msgStream.emit record.rid, record
