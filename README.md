# Baywatch (preview)

	$npm install meteorite
	$npm install meteor-npm
	$cd /dir/to/baywatch/ && mrt

This is a Tool for receiving Log- Messages via TCP (RsyslogD), parsing them with saved regexp. and saving to a MongoDB / monitoring them in your Web browser - IN REALTIME.   
Made with Meteor.js <3   
      
### Configuration for rsyslogd
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
- search function
- add a graph / chart (http://www.chartjs.org/)
