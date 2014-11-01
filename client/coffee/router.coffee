Router.configure 
  layoutTemplate: 'appLayout'

Router.route '/', ()->
	this.render 'home'

Router.route '/login', ()->
	this.render 'login'

Router.route '/(.*)', ()->
	this.render 'notFound'
	
