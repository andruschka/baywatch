Router.configure 
  layoutTemplate: 'appLayout'

Router.map ()->
  this.route 'home' ,
    path: '/'
    template: 'home'
  this.route 'notFound' ,
    path: '*'