Meteor.methods
	setApprovalRequired: (rid) ->

		check rid, String

		if not Meteor.userId()
			throw new Meteor.Error 'error-invalid-user', 'Invalid user', { method: 'setApprovalRequired' }

		room = RocketChat.models.Rooms.findOneById rid

		unless room
			throw new Meteor.Error 'error-invalid-room', 'Invalid room', { method: 'setApprovalRequired' }

		unless RocketChat.authz.hasPermission(Meteor.userId(), 'message-approval', room._id)
			throw new Meteor.Error 'error-not-authorized', 'Not authorized', { method: 'setApprovalRequired' }

		RocketChat.models.Rooms.setApprovalRequiredById(rid)
