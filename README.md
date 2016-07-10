# servalshellscripts

Various shell scripts to work with [serval-dna](http://github.com/servalproject/serval-dna)

## cmds

Some commands shortening and automating some serval-dna tasks.

* `listconv` - list all conversations for oneself
* `listmsgs <remote_sid>` - list all messages with `remote_sid` and oneself
* `readmsgs <remote_sid> [offset]` - mark all message read or up until `offset`
* `sendmsg <remote_sid> "<msg>"` - send a message to `remote_sid`

**ATM all commands via cmdline interface, NOT restful!**

## mon

ANSI-colored status monitor for serval-dna, prints status, number of peers, files, unread messages and your own SID.

* `servalmon`