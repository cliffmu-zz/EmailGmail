# email-gmail
This script sends emails through Gmails SSL server. 
Linux/Unix supported
Dependancies: OpenSSL, SED, PERL

REQUIRED:
   -e	email username for login 		[-e "Brian@gmail.com"]
   -p	password for login			[-p "cheesesticks"]
   -t	to addresses separated by ","		[-t "steve@foo.com,doug@foo.com"]

OPTIONAL:
   -c	content-type				[-c "charset=ascii"] defaults to "text/html; charset=utf-8"
   -a   alias from address              	[-a "Brian Smith"]
   -s	subject					[-s "Sales Meeting"]
   -b	body text				[-c "Can you meet at 10am tomorrow?"]
   -f	filepath of body text file 		[-f "template.html"]
   -w	wait time-0.5 is suggested but may fail	[-s 0.5] defaults to 2
   -r	retry on fail				[not yet implemented]
   -v	verbose					[not yet implemented]
   -x	base64 password				[not yet implemented]

NOTE: New Google security standards may require you to enable access for less secure apps. Visit the following link to enable.
https://www.google.com/settings/security/lesssecureapps
