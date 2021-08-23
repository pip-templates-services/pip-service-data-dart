# <img src="https://uploads-ssl.webflow.com/5ea5d3315186cf5ec60c3ee4/5edf1c94ce4c859f2b188094_logo.svg" alt="Pip.Services Logo" width="200"> <br/> Sample data microservice

This is a sample data microservice that stores and retries generic entities. This microservice shall be used
as a template to create general purpose data microservices.

Supported functionality:
* Deployment platforms: Standalone Process, Docker, AWS Lambda
* External APIs: HTTP (REST and Commandable), GRPC (Custom and Commandable)
* Persistence: Memory, Flat Files, MongoDB
* Health checks: Heartbeat, Status
* Consolidated logging: ElasticSearch
* Consolidated metrics: Prometheus

This microservice does not depend on other microservices.

Key patterns implemented in this library:

**Zero-time onboarding:** A new developer doesn't have to have a prior khowledge of the code
nor preinstalled and preconfigured development environment.
To get started with any component he/she just need to do 3 simple steps:
+ Checkout the code
+ Launch dependencies via [docker-compose.dev.yml](docker/docker-compose.dev.yml)
+ Execute **dart test** or **dart ./bin/main.dart**. 

**Automated build and test processes:** Clear, build and test actions are dockerized and scripted.
The scripts shall be run before committing the code. And the same scripts shall be executed in automated
CI/CD pipelines. That approach allows to make identical build and test actions across the entire delivery
pipeline. And have a clear separation between developer and DevOps roles (developers are responsible
for individual components, their build, test and packaging. DevOps are responsible for running CI/CD pipelines, assembling and testing entire system from individual components).

**Multiple persistence options:** This microservice contains persistence for several databases. During the deployment time, based on configuration settings a particular type of persistence can be activated and included into the microservice configuration. That entire process can be done without any code changes.

**Multiple communication protocols:** The microservice contains services that allow to connect several different ways, depending on the environment or client requirements. For instance: on-premises the microservice can be deployed as a docker container. Locally it can be called via GRPC interface and externally via REST. Moreover, several microservice can be packaged into a single process, essentially represending a monolith. In that scenario, then can be called using in-process calls using the DirectClient.

**Monitoring and Observability:** All services are instrumented to collect logs of called operations, metrics that collect number of calls, average call times and number of erors, and traces. Depending on the deployment configuration that information can be sent to different destinations: console, Promethous service, ApplicationInsights and others. Additionally, the microservice exposes additional heartbeat and status endpoints that can be used for health monitoring.

**Versioning:** Data objects and clients are versioned from the beginning. When breaking changes are introduced into the microservice, it shall keep the old version of the interface for backward-compatibility and expose a new version of the interface simultaniously. Then client library will have a new set of objects and clients for the new version, while keeping the old one intact. That will provide a clear versioning and backward-compatibility for users of the microservice.

<a name="links"></a> Quick links:

* Communication Protocols:
  - [gRPC Version 1](src/protos/entities_v1.proto)
  - [HTTP Version 1](src/swagger/entities_v1.yaml)
* Client SDKs:
  - [Node.js SDK](https://github.com/pip-templates-services/pip-client-data-nodex)
  - [.NET SDK](https://github.com/pip-templates-services/pip-client-data-dotnet)
  - [Golang SDK](https://github.com/pip-templates-services/pip-client-data-go)
  - [Dart SDK](https://github.com/pip-templates-services/pip-client-data-dart)
* [API Reference](https://pub.dev/documentation/pip_service_data/latest/pip_service_data/pip_service_data-library.html)
* [Change Log](CHANGELOG.md)


## Contract

The contract of the microservice is presented below. 

```dart
class EntityV1 implements IStringIdentifiable {
    @override
    String id;        // Entity ID
    String siteId;    // ID of a work site (field installation)
    String type;      // Entity type: Type2, Type1 or Type3
    String name;      // Human readable name
    String content;   // String content
}

abstract class  IEntitiesClientV1 {
    Future<DataPage<EntityV1>> getEntities(String correlationId, FilterParams filter, PagingParams paging);

    Future<EntityV1> getEntityById(String correlationId, String entityId);

    Future<EntityV1> getEntityByName(String correlationId, string entityId);

    Future<EntityV1> createEntity(String correlationId, EntityV1 entity);

    Future<EntityV1> updateEntity(String correlationId, EntityV1 entity);

    Future<EntityV1> deleteEntityById(String correlationId, String entityId);
}

```

## Get

Get the microservice source from GitHub:
```bash
git clone git@github.com:pip-templates/pip-services-beacons-dart.git
```

Install the microservice as a binary dependency:
```bash
pub get
```

Get docker image for the microservice:
```bash
docker pull pipdevs/pip-services-beacons-dart:latest
```

## Run

The microservice can be configured using the environment variables:
* ELASTICSEARCH_LOGGING_ENABLED - turn on Elasticsearch logs and metrics
* ELASTICSEARCH_PROTOCOL - connection protocol: http or https
* ELASTICSEARCH_SERVICE_URI - resource URI or connection string with all parameters in it
* ELASTICSEARCH_SERVICE_HOST - host name or IP address
* ELASTICSEARCH_SERVICE_PORT - port number
* FILE_ENABLED - turn on file persistence. Keep it undefined to turn it off
* FILE_PATH - file path where persistent data shall be stored (default: ../data/id_records.json) 
* MEMORY_ENABLED - turn on in-memory persistence. Keep it undefined to turn it off
* MONGO_ENABLED - turn on MongoDB persistence. Keep it undefined to turn it off
* MONGO_SERVICE_URI - URI to connect to MongoDB. When it's defined other database parameters are ignored
* MONGO_SERVICE_HOST - MongoDB hostname or server address
* MONGO_SERVICE_PORT - MongoDB port number (default: 3360)
* MONGO_DB - MongoDB database name (default: app)
* MONGO_COLLECTION - MongoDB collection (default: id_records)
* MONGO_USER - MongoDB user login
* PUSHGATEWAY_METRICS_ENABLED - turn on pushgetway for prometheus
* PUSHGATEWAY_PROTOCOL - connection protocol: http or https
* PUSHGATEWAY_METRICS_SERVICE_URI - resource URI or connection string with all parameters in it
* PUSHGATEWAY_METRICS_SERVICE_HOST - host name or IP address
* PUSHGATEWAY_METRICS_SERVICE_PORT - port number
* HTTP_ENABLED - turn on HTTP endpoint
* HTTP_PORT - HTTP port number (default: 8080)
* GRPC_ENABLED - turn on GRPC endpoint
* GRPC_PORT - GRPC port number (default: 8090)


Start the microservice as process:
```bash
dart ./bin/main.dart
```

Run the microservice in docker:
Then use the following command:
```bash
./run.ps1
```

Launch the microservice with all infrastructure services using docker-compose:
```bash
docker-compose -f ./docker/docker-compose.yml up
```

## Use

Add this to your package's pubspec.yaml file:
```yaml
dependencies:
  pip_service_data_dart: version
```

Now you can install package from the command line:
```bash
pub get
```

Inside your code get the reference to the client SDK
```dart
import 'package:pip_services3_commons/pip_services3_commons.dart';
import 'package:pip_client_data_dart/pip_client_data_dart.dart';
```

Instantiate the client
```dart
// Create the client instance
var client = EntitiesCommandableHttpClientV1();
```

Define client connection parameters
```dart
// Client configuration
var httpConfig = ConfigParams.fromTuples([
	"connection.protocol", "http",
	"connection.host", "localhost",
	"connection.port", 8080
]);
// Configure the client
client.configure(httpConfig);
```

Connect to the microservice
```dart
// Connect to the microservice
await client.open(null);
    
// Work with the microservice
...
```

Call the microservice using the client API
```dart
// Define a entity
var entity: EntityV1 = {
    id: '1',
    site_id: '1',
    type: EntityTypeV1.Type1,
    name: '00001',
    content: 'ABC'
};

// Create the entity
var entity = await this.client.createEntity(null, ENTITY1);

// Do something with the returned entity...

// Get a list of entities
var page = await this.client.getEntities(
    null,
    FilterParams.fromTuples([
        "name", "TestEntity",
    ]),
    PagingParams(0, 10)
);

// Do something with the returned page...
// E.g. entity = page.data[0];
```

## Develop

For development you shall install the following prerequisites:
* Dart SDK 2
* Visual Studio Code or another IDE of your choice
* Docker

Install dependencies:
```bash
pub get
```

Before running tests launch infrastructure services and required microservices:
```bash
docker-compose -f ./docker-compose.dev.yml up
```

Run automated tests:
```bash
pub run test
```

Generate GRPC protobuf stubs:
```bash
./protogen.ps1
```

Generate API documentation:
```bash
./docgen.ps1
```

Before committing changes run dockerized build and test as:
```bash
./build.ps1
./test.ps1
./package.ps1
./run.ps1
./clear.ps1
```

## Contacts

This microservice was created and currently maintained by *Sergey Seroukhov* and *Danil Prisyzhniy*.
