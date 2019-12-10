## Overview

`ti_dredger` is a Ruby on Rails backend
* exposing a [JSON:API](https://jsonapi.org/) RESTful Web API over relational domains (using [`ti_sqlegalize`](https://github.com/travel-intelligence/ti_sqlegalize)),
* handling LDAP authentication,
* providing a tokens mechanism to access the API,
* internally protecting database accesses using a [Resque](http://resque.github.io/) queue mechanism with workers,
* validating SQL queries using a [Calcite](https://calcite.apache.org/) microservice implemented as a [0MQ](https://zeromq.org/) server in [`ti-calcite`](https://github.com/travel-intelligence/ti_calcite),
* being configured using JSON configuration files,
* being packaged as a simple Debian package to be deployed in various environments.

## Dependencies

As a full-featured Ruby on Rails backend, here are the dependencies needed to run `ti_dredger`:

### Install Ruby >= 2.5

```bash
sudo apt-get install ruby
```

If you want to install Ruby from sources:
```bash
mkdir ruby
cd ruby
wget https://cache.ruby-lang.org/pub/ruby/2.5/ruby-2.5.0.tar.gz
tar xvzf ruby-2.5.0.tar.gz
cd ruby-2.5.0
sudo apt-get install -y build-essential zlib1g-dev libyaml-dev libssl-dev libgdbm-dev libreadline-dev libncurses5-dev libffi-dev
./configure
make
sudo make install
cd ../..
```

### Install Redis

```bash
sudo apt install redis-server
```

### Install ZeroMQ dependencies

```bash
sudo apt install -y git-all build-essential libtool pkg-config autotools-dev autoconf automake cmake

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

# Do that if ZeroMQ libraries were installed in non standard directories
export LD_LIBRARY_PATH=/opt/czmq-*/lib:/opt/libzmq-*/lib
```

### Install Rubygems dependencies

```bash
bundle install
```

### Install a running ti-calcite microservice

#### Install the JDK, Maven, SDKMan and Gradle

```bash
sudo apt-get install default-jdk maven
curl -s https://get.sdkman.io | bash
source "~/.sdkman/bin/sdkman-init.sh"
sdk install gradle 3.1
```

#### Get the TI Calcite project locally

```bash
git clone https://github.com/travel-intelligence/ti_calcite.git
```

If the project should use a standard Calcite version (like 1.11.0), edit the build.gradle file and set
```
compile 'org.apache.calcite:calcite-core:1.11.0'
```

#### Optional: To use a local Calcite library with the TI Calcite server

Install the Calcite library locally
```bash
git clone https://github.com/apache/calcite.git
```

Build it
```bash
mvn install
```

Use the local version by editing the [`build.gradle`](https://github.com/travel-intelligence/ti_calcite/blob/master/build.gradle) file and set the correct snapshot version to use.
For example:
```
compile 'org.apache.calcite:calcite-core:1.11.0-SNAPSHOT'
```

## Run unit tests

```bash
bundle exec rspec
```

## Run ti_dredger locally

`ti_dredger` has 3 main components to run:
* The `puma` web server, serving the Web API.
* The Resque workers, accessing the database.
* The Calcite microservice, valdating SQL queries.
Each component has to be run in a separate terminal.

Locally the database is being mocked (as there is no access to Impala), with mocked SQL statements and results configured in the [development configuration file](https://github.com/travel-intelligence/ti_dredger/tree/master/config/environments/development.rb).

### Run the Puma web server

```bash
bundle exec puma
```

It will listen on port 9292.

Entry point URL in local mode: http://localhost:9292/v1

### Run the Resque workers

```bash
QUEUE=query RAILS_ENV=development bundle exec rake resque:work
```

### Run the `ti-calcite` microservice

This has to be done in a checked out and setup repository of [`ti-calcite`](https://github.com/travel-intelligence/ti_calcite).

```bash
# Don't forget --info otherwise gradle will complain about dependencies that can't be installed due to network errors.
gradle run --info
```

### Alternative: use sqliterate instead of ti-calcite microservice

There is also the possibility to use a dummy SQL parser (using [`sqliterate`](https://github.com/ebastien/sqliterate)) instead of the `ti-calcite` microservice.

To use this dummy SQL parser, set `use_calcite` to `false` in [`config/environments/development.rb`](https://github.com/travel-intelligence/ti_dredger/tree/master/config/environments/development.rb).

### Use the API

While the components are running, the API can be accessed using any HTTP stack.

For example:
```bash
curl http://localhost:9292/v1
```
```json
{
   "api" : {
      "href" : "http://localhost:9292/v1",
      "links" : {
         "r_new_query" : "http://localhost:9292/v1/queries",
         "tokens" : "http://localhost:9292/v1/tokens"
      },
      "version" : 1
   }
}
```

## API

### Usage and browsing the API

As a JSON:API standard, the API is organized around resources accessed through a single entry point and linked together with relationships.

The entry point of the API is the `/v1` URL, then next URLs can be accessed by following links and relationships from the resulting JSON.

Example:
```bash
curl -H "Content-Type: application/json" http://localhost:9292/v1
```
```json
{
   "api" : {
      "href" : "http://localhost:9292/v1",
      "links" : {
         "r_new_query" : "http://localhost:9292/v1/queries",
         "tokens" : "http://localhost:9292/v1/tokens"
      },
      "version" : 1
   }
}
```

In this example, the tokens resource can be accessed following the URL given at `['api']['links']['tokens']`

For example, browsing the API in Ruby:

```ruby
require 'net/http'
require 'json'
json_entry = JSON.parse(Net::HTTP.get(URI('http://localhost:9292/v1')))
# Here we have the JSON for the entry resource
tokens_url = json_entry['api']['links']['tokens']
json_tokens = JSON.parse(Net::HTTP.get(URI(tokens_url)))
# Here we have the JSON for the tokens resource
```

Each resource can have a set of attributes accessible in `['data']['attributes']` of each JSON.

Each HTTP response will use HTTP status codes to indicate eventual errors. Refer to the [HTTP status codes](https://www.w3.org/Protocols/rfc2616/rfc2616-sec10.html) to get the meaning out of them.

Non-documented properties of the returned JSON (pagination, limits...) are specific to the JSON:API standard and are documented on the [JSON:API specification](https://jsonapi.org/).

### Authentication

Authentication can be done 3 different ways.

#### Using LDAP credentials in query headers (manual only)

This method is preferable for manual usage or to create API access tokens only.
It is best to not use this authentication mechanism in an automated way for security reasons, as passwords should never be part of an automated script.

User name and passwords are given as HTTP post-data parameters in a JSON object.

```bash
curl -H "Content-Type: application/json" -d '{ "user": { "user_name": "ldap_user_name", "password": "ldap_user_password" } }' -X GET http://localhost:9292/v1/tokens
```

#### Using API tokens

This method is the preferred one for any automated access to the API.
Check the API [tokens]() resource documentation below to know how to create an API token (the creation query will need to be authenticated using the LDAP credentials as seen in previsou section).

API token is given in the `Authorization` HTTP header.

```bash
curl -H "Authorization: Token user_api_token" http://localhost:9292/v1/tokens
```

#### Using auto-login users (dev and test only)

This method is only used in test and local environments as it does not rely on any connectivity to the LDAP.
It should never be used in production environments.

Auto-logged users are configured in the [Rails environment's configuration file](https://github.com/travel-intelligence/ti_dredger/tree/master/config/environments/development.rb).
They are given using the `DevUserName` HTTP header.

```bash
curl -H "DevUserName: dev_user" http://localhost:9292/v1/tokens
```

### JSON:API model

Here is the model of resources with their relations and attributes, published by the API, with links to each resource's details:

<pre><code>
<a href="#resource_entry">entry</a>
│
└── <a href="#resource_token">tokens</a>
│   │   comment
│   │   expires_at
│   │   token
│
└── <a href="#resource_reljson">relational json</a>

</code></pre>

### API resources

#### <a name="resource_entry"></a>Entry

This resource is the entry point of the API.

Links:
* [`tokens`](#resource_token): URL to handling tokens.
* [`rel_json`](#resource_rel_json): URL to the relational JSON entry point.

Example of data structure:
```json
{
   "api" : {
      "href" : "http://localhost:9292/v1",
      "version" : 1,
      "links" : {
         "rel_json" : "http://localhost:9292/v2",
         "tokens" : "http://localhost:9292/v1/tokens"
      }
   }
}
```

##### Method `GET`: Get the entry point

Example:
```bash
curl http://localhost:9292/v1
```
```json
{
   "api" : {
      "version" : 1,
      "links" : {
         "tokens" : "http://localhost:9292/v1/tokens",
         "rel_json" : "http://localhost:9292/v2"
      },
      "href" : "http://localhost:9292/v1"
   }
}
```

#### <a name="resource_token"></a>Token

A token gives a way to authenticate a user using a unique ID that can be create on demand, deleted and organized at the will of the user creating it.
A user can have several tokens associated to it.

Attributes:
* `comment` (String): Optional comment associated to this token. This can be used to give a description of what this token is being used for.
* `expires_at` (String): Timestamp (in ISO-8601 format) of the time starting from the token will be expired.
* `token` (String): The token itself that can be used in authorization headers.

Example of data structure:
```json
{
   "type" : "tokens",
   "links" : {
      "delete" : "http://localhost:9292/v1/tokens/20",
      "self" : "http://localhost:9292/v1/tokens/20"
   },
   "attributes" : {
      "expires_at" : "2020-06-10T10:34:39.568Z",
      "comment" : null,
      "token" : "0e54681f440df23581a1aaac0554045e44b143ae6247400906039129f940fb05d77031c26e6228d3f599671df91d30f23ecf6d56940f13497465547ae7b78a1e"
   },
   "relationships" : {
      "user" : {
         "meta" : {
            "included" : false
         }
      }
   },
   "id" : "20"
}
```

##### Method `GET`: Get the list of tokens

Example:
```bash
curl http://localhost:9292/v1/tokens
```
```json
{
   "jsonapi" : {
      "version" : "1.0"
   },
   "data" : [
      {
         "type" : "tokens",
         "links" : {
            "delete" : "http://localhost:9292/v1/tokens/20",
            "self" : "http://localhost:9292/v1/tokens/20"
         },
         "attributes" : {
            "expires_at" : "2020-06-10T10:34:39.568Z",
            "comment" : null,
            "token" : "0e54681f440df23581a1aaac0554045e44b143ae6247400906039129f940fb05d77031c26e6228d3f599671df91d30f23ecf6d56940f13497465547ae7b78a1e"
         },
         "relationships" : {
            "user" : {
               "meta" : {
                  "included" : false
               }
            }
         },
         "id" : "20"
      },
      {
         "relationships" : {
            "user" : {
               "meta" : {
                  "included" : false
               }
            }
         },
         "attributes" : {
            "expires_at" : "2020-06-10T10:34:54.638Z",
            "token" : "5f01a2dbc914d931fe06b1a48e543a297754ada226caf24acb6a6711d599dcf237cf9d65cd5a9527905b17bafad7be9d4fbfacd6cf44d2ca1f07a0a50edbaf7e",
            "comment" : null
         },
         "id" : "21",
         "links" : {
            "self" : "http://localhost:9292/v1/tokens/21",
            "delete" : "http://localhost:9292/v1/tokens/21"
         },
         "type" : "tokens"
      }
   ]
}
```

##### Method `GET`: Get the details of a token

Example:
```bash
curl http://localhost:9292/v1/tokens/32
```
```json
{
   "jsonapi" : {
      "version" : "1.0"
   },
   "data" : {
      "attributes" : {
         "token" : "4f41de1e15d26a9255cc1f31b381a389fb0a5ded89f4fbf13ec177511a604e9ab1766f5145dfd3ab342b57c2dce437d3b32f279124cc3fcdaa8d5f0de5227b5b",
         "comment" : "A nice comment",
         "expires_at" : "2020-06-10T12:08:12.405Z"
      },
      "type" : "tokens",
      "id" : "32",
      "links" : {
         "delete" : "http://localhost:9292/v1/tokens/32",
         "self" : "http://localhost:9292/v1/tokens/32"
      },
      "relationships" : {
         "user" : {
            "meta" : {
               "included" : false
            }
         }
      }
   }
}
```

##### Method `POST`: Create a new token

Parameters:
* `token` (Hash): Structure defining the token:
  * `comment` (String): Optional comment to associate to the token.

Example:
```bash
curl -X POST http://localhost:9292/v1/tokens
```
```json
{
   "jsonapi" : {
      "version" : "1.0"
   },
   "data" : {
      "id" : "31",
      "relationships" : {
         "user" : {
            "meta" : {
               "included" : false
            }
         }
      },
      "attributes" : {
         "token" : "9494c1d92aa5cdf39e771192e09a335ceac6b7093a989fee85709c8220db8f690d79843edff7caffe0b27ff5e0d2ed8da89d7dbf470b78babba467f45fd3ffa8",
         "expires_at" : "2020-06-10T12:06:59.872Z",
         "comment" : null
      },
      "type" : "tokens",
      "links" : {
         "delete" : "http://localhost:9292/v1/tokens/31",
         "self" : "http://localhost:9292/v1/tokens/31"
      }
   }
}
```

Example with associating a comment to the new token:
```bash
curl -X POST http://localhost:9292/v1/tokens -d '{ "token": { "comment": "Token used by our CI" } }' -H "Content-Type: application/json"
```
```json
{
   "data" : {
      "attributes" : {
         "expires_at" : "2020-06-10T12:08:15.785Z",
         "token" : "17826b87269f5526838c30112dd8fc1c8bfcc86f681bfcbc7805da8d0e85f314bd4f55a0528e9d112e1f30d249229fe64ba228c3e80c2b31615d9af35c6b63ec",
         "comment" : "Token used by our CI"
      },
      "type" : "tokens",
      "links" : {
         "self" : "http://localhost:9292/v1/tokens/33",
         "delete" : "http://localhost:9292/v1/tokens/33"
      },
      "id" : "33",
      "relationships" : {
         "user" : {
            "meta" : {
               "included" : false
            }
         }
      }
   },
   "jsonapi" : {
      "version" : "1.0"
   }
}
```

##### Method `DELETE`: Delete a token

Example:
```bash
curl -X DELETE http://localhost:9292/v1/tokens/33
```
```json
{
   "jsonapi" : {
      "version" : "1.0"
   },
   "data" : null
}
```

#### <a name="resource_rel_json"></a>Relational JSON

This resource is the entry point of the relational JSON mapped on the schemas and on which queries can be made.
Please refer to the [`ti_sqlegalize` API entry point](https://github.com/travel-intelligence/ti_sqlegalize) to get all details about this JSON:API.

### Examples

#### Ruby: Creating a token for a user and using it to get the list of schemas

```ruby
require 'net/http'
require 'json'

# Start from the entry point.
entry_uri = URI('http://localhost:9292/v1')
ldap_user_name = 'ldap_user_name'
ldap_password = 'ldap_password'

Net::HTTP.start(entry_uri.host, entry_uri.port) do |http|

  # Get the entry JSON
  entry_json = JSON.parse(http.get(entry_uri.request_uri).body)

  # Get the tokens URL
  tokens_url = entry_json['api']['links']['tokens']

  # Create a new token and get its ID
  token_id = JSON.parse(
    http.post(
      URI(tokens_url).request_uri,
      { user: { user_name: ldap_user_name, password: ldap_password } }.to_json,
      'Content-Type' => 'application/json'
    ).body
  )['data']['attributes']['token']
  puts "Token ID: #{token_id}"

  # Get the relational JSON URL
  rel_json_url = URI(entry_json['api']['links']['rel_json'])

  # Get the schemas URL, using the token as authentication mechanism
  schemas_url = JSON.parse(
    http.get(
      URI(rel_json_url).request_uri,
      'Authorization' => "Token #{token_id}"
    ).body
  )['data']['relationships']['schemas']['links']['related']

  # Get the list of schema names on screen
  market_names = JSON.parse(
    http.get(
      URI(schemas_url).request_uri,
      'Authorization' => "Token #{token_id}"
    ).body
  )['data'].map { |schema_json| schema_json['attributes']['name'] }

  puts "Accessible markets for user #{ldap_user_name}: #{market_names.join(', ')}"

end
```

Example of output:
```
Token ID: a584c20ecca1992e2d5cfad402dc54cd89ecbdcbd58489ee86388940a85e82eed01961f67f43d4abbdb440900fa6a753a0e2369529709dd4422008321527ab01
Accessible markets for user msalvan: MARKET
```

#### Ruby: Creating a query, waiting for its completion and display its results

```ruby
require 'net/http'
require 'json'

# Start from the entry point.
entry_uri = URI('http://localhost:9292/v1')
api_token = 'a584c20ecca1992e2d5cfad402dc54cd89ecbdcbd58489ee86388940a85e82eed01961f67f43d4abbdb440900fa6a753a0e2369529709dd4422008321527ab01'

Net::HTTP.start(entry_uri.host, entry_uri.port) do |http|

  # Get the entry JSON
  entry_json = JSON.parse(http.get(entry_uri.request_uri).body)

  # Get the relational JSON URL
  rel_json_url = URI(entry_json['api']['links']['rel_json'])

  # Get the queries URL
  queries_url = JSON.parse(
    http.get(
      URI(rel_json_url).request_uri,
      'Authorization' => "Token #{token_id}"
    ).body
  )['data']['relationships']['queries']['links']['related']

  # Create a new query and get its URL back to query for its status
  query_url = JSON.parse(
    http.post(
      URI(queries_url).request_uri,
      {
        data: {
          type: 'query',
          attributes: { sql: 'SELECT BOARD_CITY FROM MARKET.BOOKINGS_OND' }
        }
      }.to_json,
      'Content-Type' => 'application/json',
      'Authorization' => "Token #{token_id}"
    ).body
  )['data']['links']['self']

  # Query for the query's status until it is finished or in error
  query_result_url = nil
  loop do
    query_data = JSON.parse(
      http.get(
        URI(query_url).request_uri,
        'Authorization' => "Token #{token_id}"
      ).body
    )['data']

    query_status = query_data['attributes']['status']
    puts "Query status: #{query_status}"

    case query_status
    when 'finished'
      query_result_url = query_data['relationships']['result']['links']['related']
      break
    when 'error'
      break
    end
   
    # Wait 1 sec before polling again for the status
    sleep 1
  end

  # If it has finished, then query results and display them
  unless query_result_url.nil?

    result_data = JSON.parse(
      http.get(
        URI(query_result_url).request_uri,
        'Authorization' => "Token #{token_id}"
      ).body
    )['data']

    # Get the heading
    heading = result_data['attributes']['heading']

    # Get the 500 first rows
    rows = JSON.parse(
      http.get(
        "#{URI(result_data['relationships']['body']['links']['related']).request_uri}?q_limit=500",
        'Authorization' => "Token #{token_id}"
      ).body
    )['data']['attributes']['tuples']

    puts "Heading: #{heading}"
    puts "#{rows.size} rows: #{rows}"

  end

end
```

Example of output:
```
Query status: created
Query status: created
Query status: created
Query status: created
Query status: created
Query status: finished
Heading: ["BOARD_CITY"]
3 rows: [["NCE"], ["CDG"], ["MAD"]]
```
