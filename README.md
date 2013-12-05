# Baywatch 
![screenshot](http://a-fritz.com/assets/img/portfolio/folio_new.png)   
This is a Tool for receiving log- messages from RsyslogD, parsing them with a saved regular- expression- setting and saving to a MongoDB / monitoring them in your browser - IN REALTIME.   
Made with Meteor.js <3   
(You need npm + meteorite on your machine)
### Start the app
      
    $sh startup.sh
   
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
