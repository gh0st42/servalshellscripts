#!/bin/bash
# simple curl based serval-dna bash library
# Copyright: Lars Baumgaertner (c) 2017
#
# usage: source this file from your script
#        change RESTAUTH variable

RESTAUTH="pum:pum123"

############################
# KEYRING
############################

# args: none
function get_first_identity {
    curl -H "Expect:" --silent \
        --basic --user $RESTAUTH \
        "http://127.0.0.1:4110/restful/keyring/identities.json" \
        | grep -A 1 rows | tail -n1 | cut -d "\"" -f 2
}

############################
# RHIZOME
############################


# args: none
function get_rhizome_list {
    curl -H "Expect:" --silent \
        --basic --user $RESTAUTH "http://127.0.0.1:4110/restful/rhizome/bundlelist.json"    
}

# args: <service> <name> <author>
function get_bundle_id {
    get_rhizome_list | grep \"$1\" | grep \"$2\" | grep $3 | head -n1 | cut -d "," -f 4 | tr -d '"'    
}

# args: <bundle_id>
function get_bundle_content {
    curl -H "Expect:" --silent \
        --basic --user $RESTAUTH "http://127.0.0.1:4110/restful/rhizome/$1/decrypted.bin"    
}

# args: <author_id> <service> <name> <journal_entry>
function journal_new {  
    TMPDIR=$(mktemp -d)  
    echo "$4" >$TMPDIR/file1
    >$TMPDIR/manifest1
    echo "service=$2" >>$TMPDIR/manifest1
    echo "name=$3" >>$TMPDIR/manifest1
    curl \
         -H "Expect:" \
         --silent \
         --output $TMPDIR/file1.manifest \         
         --basic --user $RESTAUTH \
         --form "bundle-author=$1" \
         --form "manifest=@$TMPDIR/manifest1;type=rhizome/manifest;format=\"text+binarysig\"" \
         --form "payload=@$TMPDIR/file1" \
        "http://127.0.0.1:4110/restful/rhizome/append"
    rm $TMPDIR/*
    rmdir $TMPDIR
}

# args: <author_id> <bundle_id> <journal_entry>
function journal_update {    
    TMPDIR=$(mktemp -d) 
    echo "$3" >$TMPDIR/file1
    >$TMPDIR/manifest1    
    curl \
         -H "Expect:" \
         --silent \
         --output $TMPDIR/file1.manifest \
         --basic --user $RESTAUTH \
         --form "bundle-author=$1" \
         --form "bundle-id=$2" \
         --form "manifest=@$TMPDIR/manifest1;type=rhizome/manifest;format=\"text+binarysig\"" \
         --form "payload=@$TMPDIR/file1" \
        "http://127.0.0.1:4110/restful/rhizome/append"
    rm $TMPDIR/*
    rmdir $TMPDIR
}

# args: <service> <name>
function get_bundle_list {
    echo 1>&2  service, bundle_id, author, size, name
    get_rhizome_list | grep \"$1\" | grep \"$2\" | cut -d "," -f 3,4,8,10,14 | tr -d '"' | tr -d ']'    
}

############################
# MESHMS
############################

# args: <your_id>
function meshms_conv_list {
    SID=$(get_first_identity)
    curl -H "Expect:" --silent\
        --basic --user $RESTAUTH \
        "http://127.0.0.1:4110/restful/meshms/$1/conversationlist.json"
}

# args: <id1> <id2>
function meshms_msg_list {
    SID=$(get_first_identity)
    curl -H "Expect:" --silent \
        --basic --user $RESTAUTH \
        "http://127.0.0.1:4110/restful/meshms/$1/$2/messagelist.json"
}

# args: <id1> <id2> <since_token>
function meshms_msg_list_newsince {
    SID=$(get_first_identity)
    curl -H "Expect:" --silent\
        --basic --user $RESTAUTH \
        "http://127.0.0.1:4110/restful/meshms/$1/$2/newsince/$3/messagelist.json"
}

# args: <id1>
function meshms_readall {
    curl -H "Expect:" --silent\
        --basic --user $RESTAUTH \
        --request POST \
        "http://127.0.0.1:4110/restful/meshms/$1/readall"
}

# args: <id1> <id2>
function meshms_readall_conv {
    curl -H "Expect:" --silent\
        --basic --user $RESTAUTH \
        --request POST \
        "http://127.0.0.1:4110/restful/meshms/$1/$2/readall"
}

# args: <id1> <id2> <num>
function meshms_read {
    curl -H "Expect:" --silent\
        --basic --user $RESTAUTH \
        --request POST \
        "http://127.0.0.1:4110/restful/meshms/$1/$2/recv/$3/read"
}

# args: <sender_id> <remote_id> <text>
function meshms_send {
    SID=$(get_first_identity)
    curl -H "Expect:" --silent\
        --basic --user $RESTAUTH \
        --form "message=$3;type=text/plain;charset=utf-8" \
        "http://127.0.0.1:4110/restful/meshms/$1/$2/sendmessage"
}