import boto.s3.connection
access_key = 'GW7WXHQ66LKUKHXHAKPM'
secret_key = 'zqAdafdROLbRYENvM5CCUNANEN8oeetGCX797zBn'

conn = boto.connect_s3(
        aws_access_key_id=access_key,
        aws_secret_access_key=secret_key,
        host='10.191.7.11',
        port=7480,
        is_secure=False,
        calling_format=boto.s3.connection.OrdinaryCallingFormat(),
       )
bucket = conn.create_bucket('spi-rejudge')
for bucket in conn.get_all_buckets():
    print "{name} {created}".format(
        name=bucket.name,
        created=bucket.creation_date,
    )