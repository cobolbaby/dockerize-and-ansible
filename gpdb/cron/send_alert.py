from __future__ import print_function

# 必须支持python2.7的环境
import httplib
import json
import sys


def send_mail(subject, content):
    '''
    Send email by insight
    '''

    payload = {
        'alarmTypeName': 'infra-monitor.gpcc',
        'mailFrom': 'BigDataQualityCenter@inventec.com',
        'mailTo': 'ITC180012',
        'mailSubject': subject,
        'mailContent': content,
    }
    headers = {
        'Content-type': 'application/json'
    }

    conn = httplib.HTTPConnection('10.190.80.236:8080')
    conn.request('POST', '/RestDMApplication/Rest/alarmPostData?userName=GPCC-Prod',
                 json.dumps(payload), headers)

    response = conn.getresponse()
    data = response.read()
    conn.close()

    return data.decode("utf-8")


MAIL_TEMPLATE = """
    <style>
        .styled-table {
            border-collapse: collapse;
            margin: 25px 0;
            font-size: 0.9em;
            font-family: sans-serif;
            min-width: 400px;
            box-shadow: 0 0 20px rgba(0, 0, 0, 0.15);
        }

        .styled-table thead tr {
            background-color: #009879;
            color: #ffffff;
            text-align: left;
        }
        
        .styled-table th,
        .styled-table td {
            padding: 12px 15px;
        }

        .styled-table tbody tr {
            border-bottom: 1px solid #dddddd;
        }

        .styled-table tbody tr:nth-of-type(even) {
            background-color: #f3f3f3;
        }
    </style>

    <table class="styled-table">
        <thead>
            <tr>
                <th>Name</th>
                <th>Value</th>
            </tr>
        </thead>
        <tbody>
            <tr>
                <td>RULEDESCRIPTION</td>
                <td>%s</td>
            </tr>
            <tr>
                <td>ALERTTIME</td>
                <td>%s %s</td>
            </tr>
            <tr>
                <td>SERVERNAME</td>
                <td>%s</td>
            </tr>
            <tr>
                <td>QUERYID</td>
                <td>%s</td>
            </tr>
            <tr>
                <td>QUERYTEXT</td>
                <td>%s</td>
            </tr>
            <!-- and so on... -->
        </tbody>
    </table>
"""

if __name__ == "__main__":
    # Convert command line parameters into dict
    args = dict(l.split('=', 1) for l in sys.argv[1:])
    print(args)

    subject = '[Greenplum]' + (args.get('SUBJECT') if args.get(
        'SUBJECT') is not None else 'Unknown Issue.')

    content = MAIL_TEMPLATE % (args.get('RULEDESCRIPTION'),
                               args.get('ALERTDATE'),
                               args.get('ALERTTIME'),
                               'IPT Greenplum Cluster',
                               args.get('QUERYID'),
                               args.get('QUERYTEXT'),
                               )

    res = send_mail(subject, content)
    print(res)
