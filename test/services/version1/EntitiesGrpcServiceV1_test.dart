import 'package:pip_service_data_dart/src/data/version1/data.dart';
import 'package:pip_service_data_dart/src/logic/logic.dart';
import 'package:pip_service_data_dart/src/persistence/persistence.dart';
import 'package:pip_service_data_dart/src/services/version1/EntitiesGrpcConverterV1.dart';
import 'package:pip_service_data_dart/src/services/version1/EntitiesGrpcServiceV1.dart';
import 'package:test/test.dart';

import 'package:grpc/grpc.dart' as grpc;
import 'package:pip_service_data_dart/src/generated/generated.dart' as proto;

import 'package:pip_services3_commons/pip_services3_commons.dart';

final ENTITY1 = EntityV1(
    id: '1',
    name: '00001',
    type: EntityTypeV1.Type1,
    siteId: '1',
    content: 'ABC');

final ENTITY2 = EntityV1(
    id: '2',
    name: '00002',
    type: EntityTypeV1.Type2,
    siteId: '1',
    content: 'XYZ');

void main() {
  var grpcConfig = ConfigParams.fromTuples([
    'connection.protocol',
    'http',
    'connection.host',
    'localhost',
    'connection.port',
    3001
  ]);

  group('EntitiesGrpcServiceV1', () {
    EntitiesMemoryPersistence persistence;
    EntitiesController controller;
    EntitiesGrpcServiceV1 service;

    proto.EntitiesClient client;
    grpc.ClientChannel channel;

    setUp(() {
      final options =
          grpc.ChannelOptions(credentials: grpc.ChannelCredentials.insecure());

      channel = grpc.ClientChannel('localhost', port: 3001, options: options);
      client = proto.EntitiesClient(channel);
    });

    setUpAll(() async {
      persistence = EntitiesMemoryPersistence();
      persistence.configure(ConfigParams());

      controller = EntitiesController();
      controller.configure(ConfigParams());

      service = EntitiesGrpcServiceV1();
      service.configure(grpcConfig);

      var references = References.fromTuples([
        Descriptor(
            'pip-service-data', 'persistence', 'memory', 'default', '1.0'),
        persistence,
        Descriptor(
            'pip-service-data', 'controller', 'default', 'default', '1.0'),
        controller,
        Descriptor('pip-service-data', 'service', 'grpc', 'default', '1.0'),
        service
      ]);

      controller.setReferences(references);
      service.setReferences(references);

      await persistence.open(null);

      await service.open(null);
    });

    tearDownAll(() async {
      await service.close(null);
      await persistence.close(null);
    });

    test('CRUD Operations', () async {
      EntityV1 entity1;
      // Create the first entity
      var request = proto.EntityRequest();
      request.correlationId = '123';
      request.entity = EntitiesGrpcConverterV1.fromEntity(ENTITY1);
      var response = await client.create_entity(request);
      expect(response.entity, isNotNull);
      expect(ENTITY1.name, response.entity.name);
      expect(ENTITY1.siteId, response.entity.siteId);
      expect(ENTITY1.type, response.entity.type);
      expect(ENTITY1.content, response.entity.content);

      // Create the second entity
      request = proto.EntityRequest();
      request.correlationId = '123';
      request.entity = EntitiesGrpcConverterV1.fromEntity(ENTITY2);
      response = await client.create_entity(request);
      expect(response.entity, isNotNull);
      expect(ENTITY2.name, response.entity.name);
      expect(ENTITY2.siteId, response.entity.siteId);
      expect(ENTITY2.type, response.entity.type);
      expect(ENTITY2.content, response.entity.content);

      // Get all entities
      var pageRequest = proto.EntitiesPageRequest();
      pageRequest.correlationId = '123';
      pageRequest.filter.addAll(FilterParams().innerValue());
      pageRequest.paging =
          EntitiesGrpcConverterV1.fromPagingParams(PagingParams());

      var pageResponse = await client.get_entities(pageRequest);
      var page = pageResponse.page;
      expect(page, isNotNull);
      expect(page.data.length, 2);
      entity1 = EntitiesGrpcConverterV1.toEntity(page.data[0]);

      // Update the entity

      entity1.name = 'ABC';
      var updateRequest = proto.EntityRequest();
      updateRequest.correlationId = '123';
      updateRequest.entity = EntitiesGrpcConverterV1.fromEntity(entity1);
      var updateResponse = await client.update_entity(updateRequest);
      var entity = updateResponse.entity;

      expect(entity, isNotNull);
      expect(entity1.id, entity.id);
      expect('ABC', entity.name);

      // Get entity by name
      var udiRequest = proto.EntityNameRequest();
      udiRequest.correlationId = '123';
      udiRequest.name = entity1.name;
      var udiResponse = await client.get_entity_by_name(udiRequest);
      entity = udiResponse.entity;

      expect(entity, isNotNull);
      expect(entity1.id, entity.id);

      // Delete the entity
      var delRequest = proto.EntityIdRequest();
      delRequest.correlationId = '123';
      delRequest.entityId = entity1.id;
      var delResponse = await client.delete_entity_by_id(delRequest);
      entity = delResponse.entity;
      expect(entity, isNotNull);
      expect(entity1.id, entity.id);

      // Try to get deleted entity
      var getRequest = proto.EntityIdRequest();
      getRequest.correlationId = '123';
      getRequest.entityId = entity1.id;
      delResponse = await client.get_entity_by_id(getRequest);

      entity = delResponse.entity;

      expect(entity.id, isEmpty);
      expect(entity.siteId, isEmpty);
      expect(entity.type, isEmpty);
    });
  });
}
