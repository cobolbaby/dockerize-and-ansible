#!/bin/sh
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

        KEY=$(echo $ARGUMENT | cut -f1 -d=)
        VALUE=$(echo $ARGUMENT | cut -f2- -d=)

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
    MAIL_CONTENT="<table bgcolor=\"#FFFFFF\" border=\"2\"><tr><th>Key</th><th>Value</th></tr><tr><td>RULEDESCRIPTION</td><td>$RULEDESCRIPTION</td></tr><tr><td>LOGID</td><td>$LOGID</td></tr><tr><td>ALERTDATE</td><td>$ALERTDATE</td></tr><tr><td>ALERTTIME</td><td>$ALERTTIME</td></tr><tr><td>SERVERNAME</td><td>$SERVERNAME</td></tr><tr><td>LINK</td><td>$LINK</td></tr><tr><td>QUERYID</td><td>$QUERYID</td></tr><tr><td>QUERYTEXT</td><td>$QUERYTEXT</td></tr><tr><td>ACTIVERULENAME</td><td>$ACTIVERULENAME</td></tr></table>"
    LOG_PATH="/opt/greenplum/alert.log"

    echo "======【`date`】========" >> $LOG_PATH
    # Shell中输出一个含有符号'*'的变量，要留意转义问题，一定要加引号
    # Ref: https://blog.51cto.com/liucb/1903960
    echo "${MAIL_CONTENT}" >> $LOG_PATH

    curl -sS --connect-timeout 3 -m 10 -X POST \
        "http://10.99.170.120:8080/RestDMApplication/Rest/alarmPostData?userName=GPCC-Prod" \
        -H "Content-Type: application/json;charset=UTF-8" \
        -d "{
            'alarmTypeName': 'infra-monitor',
            'mailFrom': 'BigDataQualityCenter@inventec.com',
            'mailTo': 'ITC180012',
            'mailSubject': '""${SUBJECT}""',
            'mailContent': '""${MAIL_CONTENT}""',
            'location': '10.3.205.94:28080'
        }" >> $LOG_PATH 2>&1

    echo "" >> $LOG_PATH
}

_main "$@"                  