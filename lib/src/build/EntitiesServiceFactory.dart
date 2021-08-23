import 'package:pip_services3_components/pip_services3_components.dart';
import 'package:pip_services3_commons/pip_services3_commons.dart';

import '../persistence/EntitiesMemoryPersistence.dart';
import '../persistence/EntitiesFilePersistence.dart';
import '../persistence/EntitiesMongoDbPersistence.dart';
import '../logic/EntitiesController.dart';
import '../services/version1/EntitiesCommandableHttpServiceV1.dart';
import '../services/version1/EntitiesCommandableGrpcServiceV1.dart';
import '../services/version1/EntitiesRestServiceV1.dart';
import '../services/version1/EntitiesGrpcServiceV1.dart';

class EntitiesServiceFactory extends Factory {
  static final MemoryPersistenceDescriptor =
      Descriptor('pip-service-data', 'persistence', 'memory', '*', '1.0');
  static final FilePersistenceDescriptor =
      Descriptor('pip-service-data', 'persistence', 'file', '*', '1.0');
  static final MongoDbPersistenceDescriptor =
      Descriptor('pip-service-data', 'persistence', 'mongodb', '*', '1.0');
  static final CouchbasePersistenceDescriptor =
      Descriptor('pip-service-data', 'persistence', 'couchbase', '*', '1.0');
  static final ControllerDescriptor =
      Descriptor('pip-service-data', 'controller', 'default', '*', '1.0');
  static final CommandableHttpServiceV1Descriptor =
      Descriptor('pip-service-data', 'service', 'commandable-http', '*', '1.0');
  static final CommandableGrpcServiceV1Descriptor =
      Descriptor('pip-service-data', 'service', 'commandable-grpc', '*', '1.0');
  static final RestServiceDescriptor =
      Descriptor('pip-service-data', 'service', 'rest', '*', '1.0');
  static final GrpcServiceV1Descriptor =
      Descriptor('pip-service-data', 'service', 'grpc', '*', '1.0');

  EntitiesServiceFactory() : super() {
    registerAsType(EntitiesServiceFactory.MemoryPersistenceDescriptor,
        EntitiesMemoryPersistence);
    registerAsType(EntitiesServiceFactory.FilePersistenceDescriptor,
        EntitiesFilePersistence);
    registerAsType(EntitiesServiceFactory.MongoDbPersistenceDescriptor,
        EntitiesMongoDbPersistence);
    registerAsType(
        EntitiesServiceFactory.ControllerDescriptor, EntitiesController);
    registerAsType(EntitiesServiceFactory.CommandableHttpServiceV1Descriptor,
        EntitiesCommandableHttpServiceV1);
    registerAsType(EntitiesServiceFactory.CommandableGrpcServiceV1Descriptor,
        EntitiesCommandableGrpcServiceV1);
    registerAsType(
        EntitiesServiceFactory.RestServiceDescriptor, EntitiesRestServiceV1);
    registerAsType(
        EntitiesServiceFactory.GrpcServiceV1Descriptor, EntitiesGrpcServiceV1);
  }
}
