# Baywatch 
This is a Tool for receiving log- messages from RsyslogD, parsing them with a saved regular- expression- setting and saving to a MongoDB / monitoring them in your browser - IN REALTIME.   
Made with Meteor.js <3   
(Demo app coming soon...)   
- Edit settings.json before running -
      
    $mrt --settings settings.json
   
### Sample configuration for your rsyslogd
	$ModLoad imfile	
	# Watch this file:
	$InputFileName /usr/home/abc/foo.log
	# add a tag to log line:
	$InputFileTag foo-log:
	# state file name (will be created):
	$InputFileStateFile state-foo-log
	$InputRunFileMonitor
	
	# Send everything to baywatch on port 6969
	*.* @@your.baywatch-server.com:6969

### ToDo 
- add a graph / chart (http://www.chartjs.org/)
- write a documentation / how- to- use
