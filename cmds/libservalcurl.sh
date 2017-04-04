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
    curl -H "Expect:" --silent --dump-header http.header \
        --basic --user $RESTAUTH \
        "http://127.0.0.1:4110/restful/keyring/identities.json" \
        | grep -A 1 rows | tail -n1 | cut -d "\"" -f 2
}

############################
# RHIZOME
############################


# args: none
function get_rhizome_list {
    curl -H "Expect:" --silent --dump-header http.header \
        --basic --user $RESTAUTH "http://127.0.0.1:4110/restful/rhizome/bundlelist.json"    
}

# args: <service> <name> <author>
function get_bundle_id {
    get_rhizome_list | grep \"$1\" | grep \"$2\" | grep $3 | head -n1 | cut -d "," -f 4 | tr -d '"'    
}

# args: <bundle_id>
function get_bundle_content {
    curl -H "Expect:" --silent --dump-header http.header \
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
         --silent --show-error --write-out '%{http_code}' \
         --output $TMPDIR/file1.manifest \
         --dump-header http.header \
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
         --silent --show-error --write-out '%{http_code}' \
         --output $TMPDIR/file1.manifest \
         --dump-header http.header \
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
