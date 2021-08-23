import 'dart:convert';
import 'package:pip_service_data_dart/src/data/version1/data.dart';
import 'package:pip_service_data_dart/src/logic/logic.dart';
import 'package:pip_service_data_dart/src/persistence/persistence.dart';
import 'package:pip_service_data_dart/src/services/version1/services.dart';
import 'package:pip_services3_rpc/pip_services3_rpc.dart';
import 'package:test/test.dart';

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

var httpConfig = ConfigParams.fromTuples([
  'connection.protocol',
  'http',
  'connection.host',
  'localhost',
  'connection.port',
  3003
]);

void main() {
  group('EntitiesCommandableHttpServiceV1_test', () {
    EntitiesMemoryPersistence persistence;
    EntitiesController controller;
    EntitiesCommandableHttpServiceV1 service;
    CommandableHttpClient client;

    setUp(() async {
      persistence = EntitiesMemoryPersistence();
      persistence.configure(ConfigParams());

      controller = EntitiesController();
      controller.configure(ConfigParams());

      service = EntitiesCommandableHttpServiceV1();
      service.configure(httpConfig);

      client = CommandableHttpClient('v1/entities');
      client.configure(httpConfig);

      var references = References.fromTuples([
        Descriptor(
            'pip-service-data', 'persistence', 'memory', 'default', '1.0'),
        persistence,
        Descriptor(
            'pip-service-data', 'controller', 'default', 'default', '1.0'),
        controller,
        Descriptor('pip-service-data', 'service', 'http', 'default', '1.0'),
        service
      ]);

      controller.setReferences(references);
      service.setReferences(references);

      await persistence.open(null);
      await service.open(null);
      await client.open(null);
    });

    tearDown(() async {
      await service.close(null);
      await persistence.close(null);
      await client.close(null);
    });

    test('CRUD Operations', () async {
      EntityV1 entity1;

      // Create the first entity
      var resp =
          await client.callCommand('create_entity', null, {'entity': ENTITY1});
      var entity = EntityV1().fromJson(json.decode(resp));

      expect(ENTITY1.name, entity.name);
      expect(ENTITY1.siteId, entity.siteId);
      expect(ENTITY1.type, entity.type);
      expect(ENTITY1.content, entity.content);

      // Create the second entity
      resp =
          await client.callCommand('create_entity', null, {'entity': ENTITY2});
      entity = EntityV1().fromJson(json.decode(resp));

      expect(ENTITY2.name, entity.name);
      expect(ENTITY2.siteId, entity.siteId);
      expect(ENTITY2.type, entity.type);
      expect(ENTITY2.content, entity.content);

      // Get all entities
      resp = await client.callCommand('get_entities', null,
          {'filter': FilterParams(), 'paging': PagingParams()});
      var page = DataPage<EntityV1>.fromJson(json.decode(resp), (item) {
        var entity = EntityV1();
        entity.fromJson(item);
        return entity;
      });
      expect(page, isNotNull);
      expect(page.data.length, 2);

      entity1 = page.data[0];

      // Update the entity
      entity1.name = 'ABC';

      resp =
          await client.callCommand('update_entity', null, {'entity': entity1});
      entity = EntityV1().fromJson(json.decode(resp));
      expect(entity, isNotNull);
      expect(entity1.id, entity.id);
      expect('ABC', entity.name);

      // Get entity by name
      resp = await client
          .callCommand('get_entity_by_name', null, {'name': entity1.name});
      entity = EntityV1().fromJson(json.decode(resp));
      expect(entity, isNotNull);
      expect(entity1.id, entity.id);

      // Delete the entity
      resp = await client
          .callCommand('delete_entity_by_id', null, {'entity_id': entity1.id});
      entity = EntityV1().fromJson(json.decode(resp));
      expect(entity, isNotNull);
      expect(entity1.id, entity.id);

      // Try to get deleted entity
      resp = await client
          .callCommand('get_entity_by_id', null, {'entity_id': entity1.id});
      expect(resp, isNull);
    });
  });
}
