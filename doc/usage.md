# Usage examples for serval-dna and *servalshellscripts*

## Installation of dependencies

Assuming debian/ubuntu based distro:

```
apt-get install curl jq
```
 
 A `servald` binary should also be present in PATH. 

 ## Installation of *servalshellscripts*

 Just add the *cmds/* directory to your PATH environment.

 ```
export PATH=$PATH:<completepathtoservalshellscripts/cmds>
 ```

 You may add this to your `~/.bashrc`.

 ## Usage example in test network

 For the test network three hosts are used with the following layout:

 `n1 <-> n2 <-> n3`

 Hostname | IP | SID
 ---------|----|-----
 n1 | 10.0.0.20 | CBDECA838535B64EF2868148E43020C124E01C2CC1E1CA356B171BCE68F79252
 n2 | 10.0.0.21 | 1CF665DAC21437B1841A1BC9BE34A11A075F985CFCBB3A0C28E8F0FEC9B25D3B
 n3 | 10.0.0.22 | 00224C08CC240C36571791E8CBCB7EFEB29C551B585EA85815A369767AB55978

### Starting serval for the first time

Repeat this on each node:

```
n1 ~ # mkdir servaldir
n1 ~ # cd servaldir
n1 ~/servaldir # start_serval -i
Starting daemon
INFO: Local date/time: 2017-05-19 13:04:03 +0200
INFO: Serval DNA version: START-3734-g9b7d8bf
WARN: conf.c:65:reload()  config file /tmp/pycore.54650/n1.conf/serval.conf does not exist -- using all defaults
WARN: No network interfaces configured (empty 'interfaces' config option)
Setting interfaces to '*'
INFO: Local date/time: 2017-05-19 13:04:04 +0200
INFO: Serval DNA version: START-3734-g9b7d8bf
WARN: conf.c:65:reload()  config file /tmp/pycore.54650/n1.conf/serval.conf does not exist -- using all defaults
Setting RESTAUTH to pum:pum123
Creating new identity
sid:CBDECA838535B64EF2868148E43020C124E01C2CC1E1CA356B171BCE68F79252
identity:8C7D1B972890EC7D8021926A508B363CE57D7658840C2B32C2995F847B99AF21
Restarting daemon
Going interactive

n1 ~/servaldir #  
```

After this command you get an interactive shell with *SERVALINSTANCE_PATH* set to your current directory.
Omitting the optional parameter to `start_serval` you get back to your regular shell without the added environment variable.

The command starts serval, generates a new identity if none is present, adds a REST user and adds *ALL* network interfaces to `servald`.
Edit `start_serval` script for different REST credentials or only specific interfaces (e.g. `wlan*`).

### File distribution

Sharing a file with the `rhizome` helper script is easy:

```
n2 ~/servaldir # echo "hallo world example" > /tmp/myfile
n2 ~/servaldir # rhizome put /tmp/myfile
n2 ~/servaldir #
```

Receiving on n1:

```
n1 ~/servaldir # rhizome list
 + 54D5A0C1FF192DDA671CC76DDF058D1835D55E35F17CDB87091A2A0771392BD2
 + 20 Bytes | 13:05:30 05/19/2017 | 13:05:30 05/19/2017
 + A: null* S: 1CF665DA* R: null*
n1 ~/servaldir # rhizome get 54D5A0C1FF192DDA671CC76DDF058D1835D55E35F17CDB87091A2A0771392BD2
hallo world example
n1 ~/servaldir # 
```

Updating *myfile* in place on n2 again (BID of file required):

```
n2 ~/servaldir # echo "goodbye world example" > /tmp/myfile
n2 ~/servaldir # rhizome update /tmp/myfile 54D5A0C1FF192DDA671CC76DDF058D1835D55E35F17CDB87091A2A0771392BD2
n2 ~/servaldir #
```

Changing again to n1:
```
n1 ~/servaldir # rhizome list
 + 54D5A0C1FF192DDA671CC76DDF058D1835D55E35F17CDB87091A2A0771392BD2
 + 22 Bytes | 13:05:30 05/19/2017 | 13:09:37 05/19/2017
 + A: null* S: 1CF665DA* R: null*
n1 ~/servaldir # rhizome get 54D5A0C1FF192DDA671CC76DDF058D1835D55E35F17CDB87091A2A0771392BD2
goodbye world example
n1 ~/servaldir # 
```

The bundle id has stayed the same but the number of bytes and the timestamp have changed.

### Keeping a public journal

Having append only files shared is sometimes useful if you want to distribute for example sensor data such as a position log.

```
n2 ~/servaldir # journal append SENSORLOG coords "$(date +"%s") x: 23 y: 26"
n2 ~/servaldir #
```

```
n1 ~/servaldir # journal list SENSORLOG coords
service, bundle_id, author, size, name
SENSORLOG,4D46A163FBB3763607FAE345B1E4A475B72B7CE486D4F716CB80DB31DD65906B,null,23,coords
n1 ~/servaldir # journal show 4D46A163FBB3763607FAE345B1E4A475B72B7CE486D4F716CB80DB31DD65906B
1495192585 x: 23 y: 26
n1 ~/servaldir #
```

So far one entry, so lets add another position to our log on n2:

```
n2 ~/servaldir # journal append SENSORLOG coords "$(date +"%s") x: 24 y: 27"
n2 ~/servaldir #
```

Reading out the journal back on n1:

```
n1 ~/servaldir # journal show 4D46A163FBB3763607FAE345B1E4A475B72B7CE486D4F716CB80DB31DD65906B
1495192585 x: 23 y: 26
1495192825 x: 24 y: 27
n1 ~/servaldir #
```

### Using the messaging functionality and chatbot

The chat bot can be used as a simple remote command trigger.

```
n3 ~/servaldir # cp ~/src/servalshellscripts/bot/chat-ng .
n3 ~/servaldir # vim chat-ng
```

Change the script in the CONFIG and HOOKS sections. In this case ADMIN_SID is set to the SID of n1.
The cmd to execute as normal user is `meshms send $1 "PUBLIC" >/dev/null` and as admin `meshms send $1 "ADMIN: $(df -h / | tail -n1)" >/dev/null`.
This means that the admin gets the current free disk space as a reply and anyone else only the string "PUBLIC".

```
 n3 ~/servaldir # ./chatbot-ng 
```

Now lets send a message to n3 from n2:

```
n2 ~/servaldir # meshms send 00224C08CC240C36571791E8CBCB7EFEB29C551B585EA85815A369767AB55978 "hello"
{
 "http_status_code": 201,
 "http_status_message": "Message sent",
 "meshms_status_code": 1,
 "meshms_status_message": "Updated"
}
n2 ~/servaldir # meshms list
# header: ["_id","their_sid","read","last_message","read_offset"]
[0,"00224C08CC240C36571791E8CBCB7EFEB29C551B585EA85815A369767AB55978",false,18,0]
n2 ~/servaldir # meshms msgs 00224C08CC240C36571791E8CBCB7EFEB29C551B585EA85815A369767AB55978
{
"read_offset":0,
"latest_ack_offset":8,
"header":["type","my_offset","their_offset","token","text","delivered","read","timestamp","ack_offset"],
"rows":[
["<",17,18,"AhII","PUBLIC",true,false,1495193503,null],
["ACK",8,3,"AQgI",null,true,false,null,8],
[">",8,0,"AQgA","hello",true,false,1495193462,null]
]
}
n2 ~/servaldir # meshms read 00224C08CC240C36571791E8CBCB7EFEB29C551B585EA85815A369767AB55978
{
 "http_status_code": 201,
 "http_status_message": "Read offset updated",
 "meshms_status_code": 1,
 "meshms_status_message": "Updated"
}
n2 ~/servaldir # 
```

After sending the message we checked for new conversations, listed the messages in the conversation with n3 and afterwards marked all messages as read.

Now the same from n1:

```
n1 ~/servaldir # meshms send 00224C08CC240C36571791E8CBCB7EFEB29C551B585EA85815A369767AB55978 "hello"
{
 "http_status_code": 201,
 "http_status_message": "Message sent",
 "meshms_status_code": 1,
 "meshms_status_message": "Updated"
}
n1 ~/servaldir # meshms msgs 00224C08CC240C36571791E8CBCB7EFEB29C551B585EA85815A369767AB55978
{
"read_offset":58,
"latest_ack_offset":8,
"header":["type","my_offset","their_offset","token","text","delivered","read","timestamp","ack_offset"],
"rows":[
["<",17,58,"AjoI","ADMIN: /dev/sda1        26G   22G  2.3G  91% /",true,true,1495193708,null],
["ACK",8,3,"AQgI",null,true,false,null,8],
[">",8,0,"AQgA","hello",true,false,1495193695,null]
]
}
n1 ~/servaldir # meshms read 00224C08CC240C36571791E8CBCB7EFEB29C551B585EA85815A36967AB55978
{
 "http_status_code": 201,
 "http_status_message": "Read offset updated",
 "meshms_status_code": 1,
 "meshms_status_message": "Updated"
}
```

Here the reply message is different and contains the output of the disk free command.

Meanwhile the output of `chatbot-ng` on n3 should look like this:

```
n1 ~/servaldir # ./chatbot-ng 
Fri May 19 13:31:03 CEST 2017 | 1CF665* : hello
Fri May 19 13:34:56 CEST 2017 | ADMIN(CBDECA*) : hello
```

### Automatic new content triggers

In the following example we want process any new SENSOR journals that n1 receives as soon as possible.

First we need a script to handle new content, therefore we create a file named `/tmp/sensorevent` with the following content:

```
#!/bin/sh

SERVICE=$1
NAME=$2
BID=$3

journal show $BID | wc -l > /tmp/$SERVICE-$NAME.numcoords
```

Now make it executable and start `rtrigger` on n1:
```
n1 ~/servaldir # chmod a+x /tmp/sensorevent
n1 ~/servaldir # rtrigger /tmp/sensorevent SENSORLOG coord*
CMD: /tmp/sensorevent
SERVICE FILTER: SENSORLOG
FILE FILTER: coord*
```

This filters only for files of SERVICE 'SENSORLOG' and with a filename matchig the regex 'coord*'.

Now lets append something to our log again on n2:

```
n2 ~/servaldir # journal append SENSORLOG coords "$(date +"%s") x: 25 y: 27"
n2 ~/servaldir # journal append SENSORLOG coords "$(date +"%s") x: 25 y: 26"
```

Switching back to the console of n1:

```
[...]
CMD: /tmp/sensorevent
SERVICE FILTER: SENSORLOG
FILE FILTER: coord*
TRIGGER (Fri May 19 13:50:09 CEST 2017): SENSORLOG coords 4D46A163FBB3763607FAE345B1E4A475B72B7CE486D4F716CB80DB31DD65906B
Executing /tmp/sensorevent
TRIGGER (Fri May 19 13:50:26 CEST 2017): SENSORLOG coords 4D46A163FBB3763607FAE345B1E4A475B72B7CE486D4F716CB80DB31DD65906B
Executing /tmp/sensorevent
```

Checking the output files on n1:
```
n1 ~/servaldir # ls -1 /tmp/SENSORLOG*
/tmp/SENSORLOG-coords.numcoords
n1 ~/servaldir # cat /tmp/SENSORLOG-coords.numcoords
4
n1 ~/servaldir # 
```



