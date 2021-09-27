# Run in Docker

Login to the docker registry of gitlab.

    docker login https://registry.gitlab.com

Obtain registry credentials from Kerberos team.
 
Pull the docker image from the repo

    docker pull registry.gitlab.com/kerberos-io/turn:1.0.951040586

Allow host networking

    docker run -e KERBEROS_TURN_PUBLIC_IP="64.225.70.217" \ 
    -e KERBEROS_TURN_USERS="username1=password1" \ 
    -e KERBEROS_TURN_PORT="8443" \ 
    -e KERBEROS_TURN_REALM="kerberos.io" \ 
    --network host \ 
    registry.gitlab.com/kerberos-io/turn:1.0.951040586# turn-and-stun
