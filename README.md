# Baywatch 
This is a Tool for receiving log- messages from running **log harvester (like LogFisher.js)**, parsing them with saved REGEX- settings before pushing them to a MongoDB / monitoring them in your browser - IN REALTIME.   
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
POST request to: ``http://your.url/api/logs/insert``   
data: ``{'line':'(your log line here...)', 'system':'(name of the setting this line should be parsed with)'}``
#### Getting a specific log object
``http://your.url/api/log/:id``   
replace :id with _id of existing log object from Baywatch DB  
#### TCP server
``$mrt add npm``  
and set tcp . enabled to true in settings.json  
