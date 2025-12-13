#!/bin/bash

SCR_DIR=$(realpath $(dirname $0))
SCR_DIR_PARENT=$(realpath $SCR_DIR/..)
SCR_BASE=$(basename $0)
LOG="/var/log/duplicity.log"
if [ -a "$BFILELIST" ]; then
    FILELIST="--include-filelist=$BFILELIST"
else
    FILELIST=""
fi
if [ -n "$BSSHOPTS" ]; then
    SSHOPTS="--ssh-options=$BSSHOPTS"
else
    SSHOPTS=""
fi
if [ -n "$BHOST" ]; then
    if [ -n "$BUSER" ]; then
        DEST="sftp://$BUSER@$BHOST/$BPREFIX"
    else
        DEST="sftp://$BHOST/$BPREFIX"
    fi
else
    echo "Variable BHOST missing!"
    echo ""
    exit 1
fi

# Usage output
usage () {
    echo "Usage: $SCR_BASE (full | incremental | collection-status | list-current-files | remove-all-but-n-full <count> | cleanup)"
    echo ""
    echo "Variables:"
    echo "BHOST - Backup Destination including Port (e.g :23) if not default"
    echo "BUSER - Backup User"
    echo "BFILELIST - Filename with a duplicity filelist"
    echo "BUSERSSHOPTS - Options for SSH connection (e.g. key file)"
    echo "BPREFIX - Prefix of backup"
    echo "BPARAMS - Additional parameters for duplicity"
}

case "$1" in
    full | incremental)
        duplicity $1 \
            --log-file $LOG \
            --no-encryption \
            --allow-source-mismatch \
            $SSHOPTS \
            $FILELIST \
            $BPARAMS \
            / \
            $DEST
        ;;

    collection-status | list-current-files)
        /usr/bin/duplicity $1 \
            --no-encryption \
            --allow-source-mismatch \
            $SSHOPTS \
            $BPARAMS \
            $DEST
        ;;

    cleanup)
        /usr/bin/duplicity $1 \
            --force \
            --no-encryption \
            --allow-source-mismatch \
            $SSHOPTS \
            $BPARAMS \
            $DEST
        ;;

    remove-all-but-n-full)
        if [ -n "$2" ]; then
            NUM=$2
        else
            NUM=2
        fi
        /usr/bin/duplicity $1 $NUM \
            --no-encryption \
            --allow-source-mismatch \
            $SSHOPTS \
            --force \
            $BPARAMS \
            $DEST
        ;;

    *)
        echo "Invalid parameters"
        echo ""
        usage
        exit 1
esac
