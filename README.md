# Introduction
Swift statsD is a statsD client implementation for swift, due to the incomplete nature of the current Foundation framework on Linux we have implemented a simple UDP socket class using libC.  Currently this library only supports IPV4 and UDP connectivity to a statsD server.  

For more information on libC sockets please see: http://www.gnu.org/software/libc/manual/html_node/Datagrams.html#Datagrams


# Build Instructions:
## Install latest swift 3 version in Docker container  
```
$ docker run -i -t -p 8090:8090 -v $(pwd):/src -name swifty -w /src ibmcom/kitura-ubuntu:latest /bin/bash  
$ cd /root  
$ curl https://swift.org/builds/development/ubuntu1510/swift-DEVELOPMENT-SNAPSHOT-2016-03-24-a/swift-DEVELOPMENT-SNAPSHOT-2016-03-24-a-ubuntu15.10.tar.gz -o swift-DEVELOPMENT-SNAPSHOT-2016-03-24-a-ubuntu15.10.tar.gz  
$ tar -xf swift-DEVELOPMENT-SNAPSHOT-2016-03-24-a-ubuntu15.10.tar.gz  
$ export PATH=/root/swift-DEVELOPMENT-SNAPSHOT-2016-03-24-a-ubuntu15.10/usr/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
```  
You can now run the build inside the container, note due to the immutability of Docker containers when the container exits all downloaded code will be lost.  You can re-start containers using `docker start -it swifty /bin/bash`, you might need to reset the path with the above export command.

## Running build
```
$ make test
```

## statsD info
https://github.com/etsy/statsd

## Starting statsD server
```
$ docker run -p 8080:80 -p 8125:8125/udp -d hopsoft/graphite-statsd
```
Once started the interface to see posted metrics can been accessed at http://DOCKER_IP:8080.
