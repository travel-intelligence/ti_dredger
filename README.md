## Install Redis

```
sudo apt-get install redis-server
```

## Install ZeroMQ dependencies

```
sudo apt-get install -y git-all build-essential libtool pkg-config autotools-dev autoconf automake cmake

mkdir zeromq
cd zeromq

# Important to get latest master versions from Git repositories, and not packaged tarballs.

git clone https://github.com/zeromq/libzmq.git
cd libzmq
./autogen.sh
./configure
make check
sudo make install
sudo ldconfig
cd ..

git clone https://github.com/zeromq/czmq.git
cd czmq
./autogen.sh && ./configure && make check
sudo make install
sudo ldconfig
cd ..
cd ..

## Run ti_dredger tests

```
bundle install

# Do that if ZeroMQ libraries were installed in non standard directories
export LD_LIBRARY_PATH=/opt/czmq-*/lib:/opt/libzmq-*/lib

bundle exec rspec
```

## Run tidredger locally

```
bundle exec puma
```

Entry point URL in local mode:
[http://localhost:9292/v2/entry]

## Run the queue workers to perform the SQL queries locally against a database

```
QUEUE=query RAILS_ENV=development bundle exec rake resque:work
```

## To use the TI Calcite server locally instead of the dummy SQL parser

Set use_calcite to true in config/development.rb and run the TI Calcite server locally by doing the following:

Install the JDK, Maven, SDKMan and Gradle:
```
sudo apt-get install default-jdk maven
curl -s https://get.sdkman.io | bash
source "/home/murielsalvan/.sdkman/bin/sdkman-init.sh"
sdk install gradle 3.1
```

Get the TI Calcite project locally
```
git clone git@gitorious.orinet.nce.amadeus.net:projects/ti_calcite.git
```

If the project should use a standard Calcite version (like 1.11.0), edit the build.gradle file and set
```
compile 'org.apache.calcite:calcite-core:1.11.0'
```
If the project should use a local Calcite version, keep version 1.8.0-SNAPSHOT, and build Calcite locally (see next section).

Run the TI Calcite server (listening on port 5555)
```
cd ti_calcite
# Don't forget --info otherwise gradle will complain about dependencies that can't be installed due to network errors.
gradle run --info
```

## To use a local Calcite library with the TI Calcite server

Install the Calcite library locally
```
git clone git@gitorious.orinet.nce.amadeus.net:projects/calcite.git
```

Build it
```
mvn install
```
