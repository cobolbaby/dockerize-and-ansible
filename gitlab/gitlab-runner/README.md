```
/# gitlab-runner register                
Runtime platform                                    arch=amd64 os=linux pid=138 revision=7a6612da version=13.12.0
Running in system-mode.                            
                                                   
Enter the GitLab instance URL (for example, https://gitlab.com/):
????
Enter the registration token:
????
Enter a description for the runner:
[515d23432676]: infra
Enter tags for the runner (comma-separated):

Registering runner... succeeded                     runner=1VsidHSA
Enter an executor: custom, docker-ssh, parallels, docker-ssh+machine, kubernetes, docker, shell, ssh, virtualbox, docker+machine:
docker
Enter the default Docker image (for example, ruby:2.6):
registry.inventec/proxy/library/alpine:latest
Runner registered successfully. Feel free to start it, but if it's running already the config should be automatically reloaded! 
```

