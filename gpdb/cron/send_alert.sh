#!/bin/bash
set -euo pipefail

###########################################################
# Greenplum Command Center alert shell example (email)
# =========================================================
#
# NB: DO NOT change this file directly
#     make a copy on your own
#
# NB: To activate the shell on alert event triggers
#     1. copy it to $MASTERDATA_DIRECTORY/gpmetrics
#     2. AND rename it to send_alert.sh
#     3. restart gpcc
#
############################################################

_main() {
    #################################################################################
    # Following code is an example for parsing input arguments passed to this script
    # Please refer comments close to each key/value
    #################################################################################
    for ARGUMENT in "$@"
    do

        KEY=$(echo "$ARGUMENT" | cut -f1 -d=)
        VALUE=$(echo "$ARGUMENT" | cut -f2- -d=)

        case "$KEY" in
            # LOGID is identity in gpmetrics.gpcc_alert_log table
            LOGID)              LOGID=${VALUE} ;;

            # RULEDESCRIPTION is description of triggerred alert, such as segment down
            RULEDESCRIPTION)    RULEDESCRIPTION=${VALUE} ;;

            # ALERTDATE is the date of triggerred alert
            ALERTDATE)          ALERTDATE=${VALUE} ;;

            # ALERTTIME is the timestamp with time zone of triggerred alert
            ALERTTIME)          ALERTTIME=${VALUE} ;;

            # SERVERNAME is the name of Greenplum Command Center server name which triggers this alert
            SERVERNAME)         SERVERNAME=${VALUE} ;;

            # LINK is the base url of Greenplum Command Center
            LINK)               LINK=${VALUE} ;;

            # QUERYID is the identity of the query who triggers this alert,
            # only available if this is a query level alert like query runtime exceeds x minutes
            # otherwise this field is empty
            QUERYID)            QUERYID=${VALUE} ;;

            # QUERYTEXT is the query text of the query who triggers this alert,
            # only available if this is a query level alert like query runtime exceeds x minutes
            # otherwise this field is empty
            QUERYTEXT)          QUERYTEXT=${VALUE} ;;

            # ACTIVERULENAME is current active alert rule name, such as If query is blocked for 1 min,
            # multiple rules are separated by ;
            ACTIVERULENAME)     ACTIVERULENAME=${VALUE} ;;

            # SUBJECT is subject of this mail
            SUBJECT)            SUBJECT=${VALUE} ;;
            *)
        esac
    done

    ###########################################################################
    # Following is an example for sending email with above input arguments
    # Can be replaced with any operation, such as SMS, slack, wechat, etc...
    ###########################################################################
    echo "$@" >> /dev/stdout

    python send_alert.py "$@"
}

_main "$@"
