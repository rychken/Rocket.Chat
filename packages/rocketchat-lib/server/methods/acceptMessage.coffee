Meteor.methods
	acceptMessage: (id) ->

		check id, String

		if not Meteor.userId()
			throw new Meteor.Error 'error-invalid-user', 'Invalid user', { method: 'acceptMessage' }

		msg = RocketChat.models.Messages.findOneById id

		unless msg
			throw new Meteor.Error 'error-invalid-message', 'Invalid message', { method: 'acceptMessage' }

		unless RocketChat.authz.hasPermission(Meteor.userId(), 'message-approval', msg.rid)
			throw new Meteor.Error 'error-not-authorized', 'Not authorized', { method: 'acceptMessage' }

		RocketChat.acceptMessage(id)
