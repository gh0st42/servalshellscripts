#! /usr/bin/env python

# simple python-dialog based serval-dna text UI
# Copyright: Lars Baumgaertner (c) 2017
#
# requires python-dialog package to be installed
# serval-dna running
# cmds from https://github.com/gh0st42/servalshellscripts.git to be in the PATH
# 
# REMEMBER TO SET SERVALINSTANCE_PATH
# change SERVALCMD variable below

import sys
import locale
import commands
import os
from dialog import Dialog

SERVALCMD="/usr/local/bin/sdna"

locale.setlocale(locale.LC_ALL, '')


d = Dialog(dialog="dialog")
# Dialog.set_background_title() requires pythondialog 2.13 or later
#d.set_background_title("My little program")
d.add_persistent_args(["--backtitle", "serval-dna text ui"])
d.add_persistent_args(["--no-mouse"])

def not_implemented():
    d.msgbox("Not Implemented yet!")

def show_peers():    
    cmd = SERVALCMD + " id peers | tail -n +3"
    (ret, val) = commands.getstatusoutput(cmd)
    d.scrollbox(val, title=' Current Peers ')

def rhizome_list():    
    #cmd = SERVALCMD + " rhizome list"
    cmd = "rhizome list"
    (ret, val) = commands.getstatusoutput(cmd)
    d.scrollbox(val, title=' Rhizome File List ')

def rhizome_share():
    code, fpath = d.fselect(os.getcwd(),10,60)
    if code == d.DIALOG_OK:
        print fpath
        if os.path.isfile(fpath):
            cmd = "rhizome put " + fpath
            (ret, val) = commands.getstatusoutput(cmd)
            os.system("clear")
            print val
            raw_input("Press Enter to continue...")
        else:
            d.msgbox("Only sharing of files is allowed!")

def rhizome_export():
    d.msgbox("Not Implemented yet!")

def rhizome_menu():
    while True:
        code, tag = d.menu("Rhizome Actions:",
                            choices=[("1)", "List files"),
                                        ("2)", "Share file"),
                                        ("3)", "Export file"),
                                        ("b)", "back")])
        if code == d.DIALOG_OK:                        
            if tag == "b)":
                break
            elif tag == "1)":
                rhizome_list()        
            elif tag == "2)":
                rhizome_share()
            elif tag == "3)":
                rhizome_export()
        else:
            break

def meshms_msgsend(remotesid):
    shortsid = "%s*" % (remotesid[0:8])
    code, msg = d.inputbox("Message @ " + shortsid +":", width=60)
    if code == d.DIALOG_OK and len(msg) > 0:
        ret = d.yesno("Really send \n\"%s\" \nto %s?" % (msg, shortsid))
        if ret == d.DIALOG_OK:
            cmd = "meshms send %s \"%s\"" % (remotesid, msg)
            (ret, val) = commands.getstatusoutput(cmd)
            d.msgbox("Message sent!")
        else:
            d.msgbox("Discarded message!")

def meshms_newmsg():
    ret = d.yesno("Select remote peer from list?")
    if ret == d.DIALOG_OK:
        cmd = SERVALCMD + " id allpeers | tail -n +3"
        (ret, val) = commands.getstatusoutput(cmd)
        choices=[]
        for i in val.split("\n"):
            choices.append( (i, ""))
        code, tag = d.menu("Select remote peer:",
            choices=choices)
        if code == d.DIALOG_OK:
            if len(tag) == 64:
                meshms_msgsend(tag)                    
    else:
        code, remotesid = d.inputbox("Remote SID:", width=60)
        if code == d.DIALOG_OK and len(remotesid) == 64:  
            meshms_msgsend(remotesid)

def meshms_list():
    cmd = "meshms list | tail -n +2"
    (ret, val) = commands.getstatusoutput(cmd)
    output = "Remote SID " + " " * 55 + "Read\n"
    for i in val.split("\n"):
        fields = i.split(",")
        output += "%s %s\n" % (fields[1], fields[2])
    d.scrollbox(output,title=" Conversations ")

def meshms_show():
    cmd = "meshms list | tail -n +2"
    (ret, val) = commands.getstatusoutput(cmd)
    choices = []
    for i in val.split("\n"):
        fields = i.replace("\"","").split(",")
        status = "unread"
        if fields[2] == "true":
            status = "read"
        choices.append( (fields[1], status))
    code, tag = d.menu("Select conversation", width=60, choices=choices)
    if code == d.DIALOG_OK and len(tag) == 64:
        cmd = "meshms read %s" % tag
        (ret, val) = commands.getstatusoutput(cmd)
        cmd = "meshms msgs %s | grep -e \"^\\[\\\">\" -e \"^\\[\\\"<\"" % tag
        print cmd
        (ret, val) = commands.getstatusoutput(cmd)
        output = ""
        for i in val.split("\n"):
            fields = i.replace("[", "").split(",")
            output += fields[0].replace("\"","") + " " + fields[4] + "\n"        
        d.scrollbox(output)

def meshms_menu():
    while True:
        code, tag = d.menu("MeshMS Actions:",
                            choices=[("1)", "List Conversations"),
                                        ("2)", "Read Conversation"),
                                        ("3)", "Add to Conversation"),
                                        ("4)", "New Message"),
                                        ("b)", "back")])
        if code == d.DIALOG_OK:            
            if tag == "b)":
                break
            elif tag == "1)":
                meshms_list()        
            elif tag == "2)":
                meshms_show()
            elif tag == "3)":
                not_implemented()
            elif tag == "4)":
                meshms_newmsg()
        else:
            break

while True:
    code, tag = d.menu("Main Menu",
                        choices=[("1)", "Show peers"),
                                    ("2)", "Rhizome"),
                                    ("3)", "MeshMS"),
                                    ("q)", "Exit")])
    if code == d.DIALOG_OK:        
        if tag == "q)":
            sys.exit()
        elif tag == "1)":
            show_peers()
        elif tag == "2)":
            rhizome_menu()
        elif tag == "3)":
            meshms_menu()
    else:
        sys.exit()