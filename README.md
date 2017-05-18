# servalshellscripts

Various shell scripts to work with [serval-dna](http://github.com/servalproject/serval-dna)

## dependencies

* servald from serval-dna package installed
* curl
* jq - required for json parsing in bash (`rtrigger`)
* bash in `/bin/bash` might be removed as a dependecy in the future

## /cmds

Some commands shortening and automating some serval-dna tasks.

* `journal <cmd> [parameters]` - curl based frontend to manage journals
* `meshms <cmd> [parameters]` - curl based frontend for meshms functions
* `rhizome <cmd> [parameters]` - curl based frontend for rhizome functions
* `rtrigger <cmd> [service-regex] [file-regex]` - curl based trigger for new rhizome bundles
* `start_serval [i]` - start serval with instance path = cwd, generates default identity if none exists, give any parameter goes into interactive shell with SERVALINSTANCE_PATH set corretly
* `libservalcurl.sh` - a bash library to be sourced for scripts using curl 

**all commands (except for journal and meshms) via cmdline interface, NOT restful!**

Restful username and passwort:
Edit script and change variable `RESTAUTH`

## /mon

`./servalmon`

ANSI-colored status monitor for serval-dna, prints status, number of peers, files, unread messages and your own SID.

![servalmon-demo-out](https://cloud.githubusercontent.com/assets/1264131/16715898/5485d282-46ed-11e6-9260-aa5c9a469186.gif)

## /bot

`./chatbot` (DEPRECATED)

`./chatbot-ng` - curl based version, requires `cmds/meshms` to be in PATH

Simple bash based chat bot for serval-dna. Edit script for various settings.
                                                                                  
Config variables
- `SLEEPTIME` delay between checking for new meshms
- `ADMIN_SID` a special SID, simple authentication

User defined hooks
- `cmd_parser` default just reply with string PUBLIC
- `admin_cmd_parser` only called if message is from `$ADMIN_SID`, default reply with string ADMIN
