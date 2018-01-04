#! /bin/bash
docker pull gitlab/gitlab-ce

docker run --detach \
    --name gitlab \
    --hostname git.cobol.com \
    --publish 443:443 --publish 80:80 --publish 22:22 \
    --env GITLAB_OMNIBUS_CONFIG="external_url 'http://git.cobol.com/'; gitlab_rails['lfs_enabled'] = true;" \
    gitlab/gitlab-ce:latest

# docker run --detach \
#     --name gitlab \
#     --hostname git.cobol.com \
#     --publish 443:443 --publish 80:80 --publish 22:22 \
#     --env GITLAB_OMNIBUS_CONFIG="external_url 'http://git.cobol.com/'; gitlab_rails['lfs_enabled'] = true;" \
#     --restart always \
#     --volume /data/gitlab/config:/etc/gitlab \
#     --volume /data/gitlab/logs:/var/log/gitlab \
#     --volume /data/gitlab/data:/var/opt/gitlab \
#     gitlab/gitlab-ce:latest
