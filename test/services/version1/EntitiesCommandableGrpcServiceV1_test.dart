import 'dart:convert';
import 'package:pip_service_data_dart/src/data/version1/data.dart';
import 'package:pip_service_data_dart/src/logic/logic.dart';
import 'package:pip_service_data_dart/src/persistence/persistence.dart';
import 'package:pip_service_data_dart/src/services/version1/services.dart';
import 'package:test/test.dart';
import 'package:grpc/grpc.dart' as grpc;
import 'package:pip_services3_grpc/src/generated/commandable.pbgrpc.dart'
    as command;
import 'package:pip_services3_grpc/src/generated/commandable.pb.dart'
    as messages;

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
    3002
  ]);

  group('EntitiesCommandableGrpcServiceV1', () {
    EntitiesMemoryPersistence persistence;
    EntitiesController controller;
    EntitiesCommandableGrpcServiceV1 service;
    command.CommandableClient client;
    grpc.ClientChannel channel;

    setUp(() async {
      final options =
          grpc.ChannelOptions(credentials: grpc.ChannelCredentials.insecure());

      channel = grpc.ClientChannel('localhost', port: 3002, options: options);
      client = command.CommandableClient(channel);
    });

    setUpAll(() async {
      persistence = EntitiesMemoryPersistence();
      persistence.configure(ConfigParams());

      controller = EntitiesController();
      controller.configure(ConfigParams());

      service = EntitiesCommandableGrpcServiceV1();
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
      var request = messages.InvokeRequest();
      request.correlationId = '123';
      request.method = 'v1.entities.create_entity';
      request.argsEmpty = false;
      request.argsJson = json.encode({'entity': ENTITY1});
      command.InvokeReply response;
      response = await client.invoke(request);

      expect(response.resultEmpty, isFalse);
      expect(response.resultJson, isNotEmpty);
      var entity = EntityV1();
      entity.fromJson(json.decode(response.resultJson));

      expect(ENTITY1.name, entity.name);
      expect(ENTITY1.siteId, entity.siteId);
      expect(ENTITY1.type, entity.type);
      expect(ENTITY1.content, entity.content);

      // Create the second entity
      request.correlationId = '123';
      request.method = 'v1.entities.create_entity';
      request.argsEmpty = false;
      request.argsJson = json.encode({'entity': ENTITY2});
      response = await client.invoke(request);

      expect(response.resultEmpty, isFalse);
      expect(response.resultJson, isNotEmpty);
      //entity = EntityV1();
      entity.fromJson(json.decode(response.resultJson));

      expect(ENTITY2.name, entity.name);
      expect(ENTITY2.siteId, entity.siteId);
      expect(ENTITY2.type, entity.type);
      expect(ENTITY2.content, entity.content);

      // Get all entities
      request.correlationId = '123';
      request.method = 'v1.entities.get_entities';
      request.argsEmpty = false;
      request.argsJson =
          json.encode({'filter': FilterParams(), 'paging': PagingParams()});
      response = await client.invoke(request);
      expect(response.resultEmpty, isFalse);
      expect(response.resultJson, isNotEmpty);
      var page =
          DataPage<EntityV1>.fromJson(json.decode(response.resultJson), (item) {
        var entity = EntityV1();
        entity.fromJson(item);
        return entity;
      });
      expect(page, isNotNull);
      expect(page.data.length, 2);
      entity1 = page.data[0];

      // Update the entity

      entity1.name = 'ABC';
      request.correlationId = '123';
      request.method = 'v1.entities.update_entity';
      request.argsEmpty = false;
      request.argsJson = json.encode({'entity': entity1});
      response = await client.invoke(request);

      expect(response.resultEmpty, isFalse);
      expect(response.resultJson, isNotEmpty);
      entity.fromJson(json.decode(response.resultJson));

      expect(entity1.id, entity.id);
      expect('ABC', entity.name);

      // Get entity by name
      request.correlationId = '123';
      request.method = 'v1.entities.get_entity_by_name';
      request.argsEmpty = false;
      request.argsJson = json.encode({'name': entity1.name});
      response = await client.invoke(request);

      expect(response.resultEmpty, isFalse);
      expect(response.resultJson, isNotEmpty);
      entity.fromJson(json.decode(response.resultJson));

      expect(entity, isNotNull);
      expect(entity1.id, entity.id);

      // Delete the entity
      request.correlationId = '123';
      request.method = 'v1.entities.delete_entity_by_id';
      request.argsEmpty = false;
      request.argsJson = json.encode({'entity_id': entity1.id});
      response = await client.invoke(request);

      expect(response.resultEmpty, isFalse);
      expect(response.resultJson, isNotEmpty);
      entity.fromJson(json.decode(response.resultJson));

      expect(entity, isNotNull);
      expect(entity1.id, entity.id);

      // Try to get deleted entity
      request.correlationId = '123';
      request.method = 'v1.entities.get_entity_by_id';
      request.argsEmpty = false;
      request.argsJson = json.encode({'entity_id': entity1.id});
      response = await client.invoke(request);
      expect(response.resultEmpty, isTrue);
    });
  });
}
