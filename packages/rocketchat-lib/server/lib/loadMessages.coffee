
RocketChat.loadMessages = (rid, ts, direction, queryOptions) ->

	viewerId = Meteor.userId()
	room = Meteor.call 'canAccessRoom', rid, viewerId
	unless room
		return [false, 0]

	if room.t is 'c' and room.usernames.indexOf(room.username) is -1 and not RocketChat.authz.hasPermission(viewerId, 'preview-c-room')
		return [false, 0]

	if not RocketChat.settings.get 'Message_ShowEditedStatus'
		queryOptions.fields = { 'editedAt': 0 }
	
	if not RocketChat.isApprovalRequired rid, viewerId
		finderArgs = _.compact([rid, ts, queryOptions])
		switch
			when direction is 'before' then records = RocketChat.models.Messages.findVisibleByRoomIdBeforeTimestamp(finderArgs...).fetch()
			when direction is 'after'  then records = RocketChat.models.Messages.findVisibleByRoomIdAfterTimestamp(finderArgs...).fetch()
			when direction is 'both'   then records = RocketChat.models.Messages.findVisibleByRoomId(finderArgs...).fetch()
	else
		finderArgs = _.compact([rid, viewerId, ts, queryOptions])
		switch
			when direction is 'before' then records = RocketChat.models.Messages.findVisibleAcceptedByRoomIdBeforeTimestamp(finderArgs...).fetch()
			when direction is 'after'  then records = RocketChat.models.Messages.findVisibleAcceptedByRoomIdAfterTimestamp(finderArgs...).fetch()
			when direction is 'both'   then records = RocketChat.models.Messages.findVisibleAcceptedByRoomId(finderArgs...).fetch()

	more = records.length is queryOptions.limit

	messages = _.map records, (message) ->
		message.starred = _.findWhere message.starred, { _id: viewerId }
		return message

	return [messages, more]
