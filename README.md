# Baywatch (beta)

	$npm install meteorite
	$npm install meteor-npm
	$cd /dir/to/project/baywatch/
	$mrt

This is a Tool for receiving Log- Messages via TCP (RsyslogD), parsing them with grok and saving to a MongoDB / monitoring them in your Web browser - IN REALTIME.   
made with meteor <3   
      
### Configuration for rsyslogd
	$ModLoad imfile	
	# Watch this file:
	$InputFileName /usr/home/abc/user.log
	# add a tag to log line:
	$InputFileTag user-log:
	# state file name (will be created):
	$InputFileStateFile state-user-log
	$InputRunFileMonitor
	
	# Send everything to baywatch on port 6969
	*.* @@baywatch-server.de:6969

### ToDo 
- logmessage parsing with grok
- search function
- add a graph / chart (http://www.chartjs.org/)
