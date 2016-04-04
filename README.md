# swift-mysql
MySQL client implementation for swift

# Build instructions
## Run inside docker
```
$ docker run -i -t -p 8090:8090 -v $(pwd):/src --name swifty -w /src ibmcom/kitura-ubuntu:latest /bin/bash  
$ cd /root  
$ curl https://swift.org/builds/development/ubuntu1510/swift-DEVELOPMENT-SNAPSHOT-2016-03-24-a/swift-DEVELOPMENT-SNAPSHOT-2016-03-24-a-ubuntu15.10.tar.gz -o swift-DEVELOPMENT-SNAPSHOT-2016-03-24-a-ubuntu15.10.tar.gz  
$ tar -xf swift-DEVELOPMENT-SNAPSHOT-2016-03-24-a-ubuntu15.10.tar.gz  
$ export PATH=/root/swift-DEVELOPMENT-SNAPSHOT-2016-03-24-a-ubuntu15.10/usr/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
$ apt-get install libmysqlclient-dev
```

## Build and run tests
```
$ make test
```
