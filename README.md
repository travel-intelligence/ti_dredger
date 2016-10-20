TI Dredger
==========

## Install the Ruby environment

```bash
bundle install
```

## Install ZeroMQ dependencies

```bash
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
```

## Run ti_dredger tests

```bash
# Do that if ZeroMQ libraries were installed in non standard directories
export LD_LIBRARY_PATH=/opt/czmq-*/lib:/opt/libzmq-*/lib

bundle exec rspec
```

## Run tidredger locally

```bash
bundle exec puma
```

Entry point URL in local mode:
[http://localhost:9292/v2/entry]
