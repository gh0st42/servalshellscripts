# servalshellscripts

Various shell scripts to work with [serval-dna](http://github.com/servalproject/serval-dna)

## /cmds

Some commands shortening and automating some serval-dna tasks.

* `listconv` - list all conversations for oneself
* `listmsgs <remote_sid>` - list all messages with `remote_sid` and oneself
* `readmsgs <remote_sid> [offset]` - mark all message read or up until `offset`
* `sendmsg <remote_sid> "<msg>"` - send a message to `remote_sid`

**ATM all commands via cmdline interface, NOT restful!**

## /mon

`./servalmon`

ANSI-colored status monitor for serval-dna, prints status, number of peers, files, unread messages and your own SID.

## /bot

`./chatbot`

Simple bash based chat bot for serval-dna. Edit script for various settings.

Config variables
- `SLEEPTIME` delay between checking for new meshms
- `ADMIN_SID` a special SID, simple authentication

User defined hooks
- `cmd_parser` default just reply with string PUBLIC
- `admin_cmd_parser` only called if message is from `$ADMIN_SID`, default reply with string ADMIN
