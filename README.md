# Baywatch 
This is a Tool for receiving log- messages from running **log harvester (LogFisher.js)**, parsing them with saved REGEX- settings before pushing them to a MongoDB / monitoring them in your browser - IN REALTIME.   
Made with Meteor.js <3   
(You need npm on your machine)  
### Installation
``$npm install -g meteorite``
### Start the app
``$sh startup.sh``
### New: API
You should get LogFisher.js (a small NodeJS app) for watching log files / sending them to Baywatch.   
(But you are also free to build your own log harvester.)
#### Sending Logs
``http://your.url/api/logs/insert``
#### Getting a specific log object
``http://your.url/api/log/:id``   
``replace :id with id of existing log object from Baywatch DB``