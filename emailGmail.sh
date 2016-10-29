#!/bin/sh
OS=`uname -a | sed 's/^\([^ ]*\).*/\1/g'`
email=
alias=
password=
to=
subject=
body=
file=
waitTime=

usage(){
cat << EOF
usage: $0 [REQUIRED] [OPTIONAL]
ex: ./emailGmail.sh -e steve@foo.com -p password -t "john@foo.com" -s "Alphabet" -b "abcdefghijklmnopqrstuvwxyz"

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

EOF
}

startTime=`ruby -e 'puts Time.now.to_f'`
currentTime() {
	curTime=`ruby -e 'puts Time.now.to_f'`-0.00363
	echo $curTime-$startTime | bc
	startTime=$curTime
}

while getopts “he:p:t:c:s:b:f:a:z:w:v” OPTION
do
     case "$OPTION" in
         h) usage; exit 1;;
         e) email="$OPTARG";;
         p) password="$OPTARG";;
         t) to=`echo "$OPTARG" | tr ',' '\n'`;;
         c) contentType="$OPTARG";;
         a) alias="$OPTARG";;
         s) subject="$OPTARG";;
         b) body="$OPTARG";;
         f) file="$OPTARG";;
		 w) waitTime="$OPTARG";;
         v) verbose=1;;
         ?) usage; exit;;
     esac
done

#CHECK FOR REQUIRED PARAMETERS - if not there then show usage info and quit
if [[ -z $email ]] || [[ -z $password ]] || [[ -z $to ]]; then
     usage
     exit 1
fi
login=`echo "$email" | sed 's/^\([^@]*\).*/\1/g'`
server=`echo "$email" | sed 's/^[^@]*@\(.*\)/\1/g'`
authInfo64=`perl -MMIME::Base64 -e 'print encode_base64("\000'"$login"'\@'"$server"'\000'"$password"'")'`

#SET DEFAULT CONTENT-TYPE IF EMPTY
if [[ -z $contentType ]]; then
     contentType="text/html; charset=utf-8"
fi

#REFER TO FILE FOR TEXT IF BODY VARIABLE IS EMPTY
if [[ -z $body ]]; then
	if [[ ! -z $file ]]; then
	     body=`cat "$file"`
	fi
fi

if [[ -z $waitTime ]]; then
     waitTime="2"
fi

doEmailStuff() { #PRINTS TO STDOUT
	#Login to server
	sleep "$waitTime"; echo "ehlo localhost"
	sleep "$waitTime"; echo "auth plain"
	sleep "$waitTime"; echo "$authInfo64"
	#Specify information required from server
    sleep "$waitTime"; echo "mail from: <$email>"
	for item in $to; do #Loop through multiple to addresses
		sleep "$waitTime"; echo "rcpt to: <$item>"
	done
	sleep "$waitTime"; echo "data" #2
	#Email header
    if [[ -z $alias ]]; then
        sleep "$waitTime"; echo "From: $email"
    else
        sleep "$waitTime"; echo "From: $alias <$email>"
	fi
	sleep "$waitTime"; echo "Subject: $subject"
	for item in $to; do #Loop through multiple to addresses
		sleep "$waitTime"; echo "To: $item"
	done
	sleep "$waitTime"; echo "Content-Type: $contentType"
	sleep "$waitTime"; echo ""
	sleep "$waitTime"; echo "$body"

	#Close email (w/ "CRLF.CRLF") and server connection
	while sleep "$waitTime"; do
		if [ "$OS" = "Darwin" ]; then
			sleep "$waitTime"; printf "\n"
			sleep "$waitTime"; printf ".\n"
			# DEPRICATED # sleep "$waitTime"; echo "\x0D"
			# DEPRICATED # sleep "$waitTime"; echo ".\x0D"
		elif [ "$OS" = "Linux" ]; then
			sleep "$waitTime"; echo -e "\r"
			sleep "$waitTime"; echo -e ".\r"
		fi
		sleep "$waitTime"; echo "quit"
		sleep "$waitTime"; exit 1 #2
	done
}

#CONNECT TO SERVER - print to stdout
if [ "$OS" = "Darwin" ]; then
	reply=$(doEmailStuff | openssl s_client -connect smtp.gmail.com:465 -crlf -ign_eof | tee /dev/stderr)
	echo "$reply" > out2
	check=`echo "$reply" | tr -d '\n' | grep 'closing connection'`
	check2=`echo "$reply" | tr -d '\n' | grep 'Go ahead'`
	if [[ -z "$check" || -z "$check2" ]]; then echo "FALSE"
	else echo "TRUE"; fi
elif [ "$OS" = "Linux" ]; then
	reply=$(doEmailStuff | openssl s_client -connect smtp.gmail.com:25 -starttls smtp | tee /dev/stderr)
	check=`echo "$reply" | tr -d '\n' | grep 'closing connection'`
	check2=`echo "$reply" | tr -d '\n' | grep 'Go ahead'`
	if [[ -z "$check" || -z "$check2" ]]; then echo "FALSE"
	else echo "TRUE"; fi
else
	echo "Do not support operating system: $OS"
	exit 1
fi
