import 'dart:convert';

import 'package:pip_service_data_dart/src/data/version1/data.dart';
import 'package:pip_service_data_dart/src/logic/logic.dart';
import 'package:pip_service_data_dart/src/persistence/persistence.dart';
import 'package:pip_service_data_dart/src/services/version1/services.dart';
import 'package:pip_services3_commons/pip_services3_commons.dart';
import 'package:http/http.dart' as http;
import 'package:test/test.dart';

final ENTITY1 = EntityV1(
    id: '1',
    type: EntityTypeV1.Type1,
    siteId: '1',
    name: '00001',
    content: 'ABC');

final ENTITY2 = EntityV1(
    id: '2',
    type: EntityTypeV1.Type2,
    siteId: '1',
    name: '00002',
    content: 'XYZ');

void main() {
  var httpConfig = ConfigParams.fromTuples([
    'connection.protocol',
    'http',
    'connection.host',
    'localhost',
    'connection.port',
    3000
  ]);

  group('EntitiesRestServiceV1', () {
    EntitiesMemoryPersistence persistence;
    EntitiesController controller;
    EntitiesRestServiceV1 service;
    http.Client rest;
    String url;

    setUp(() async {
      url = 'http://localhost:3000';
      rest = http.Client();
    });

    setUpAll(() async {
      persistence = EntitiesMemoryPersistence();
      controller = EntitiesController();

      service = EntitiesRestServiceV1();
      service.configure(httpConfig);

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
    });

    tearDownAll(() async {
      await service.close(null);
      await persistence.close(null);
    });

    test('CRUD Operations', () async {
      EntityV1 entity1;

      // Create the first entity
      var resp = await rest.post(url + '/v1/entities/entities',
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'entity': ENTITY1}));

      var entity = EntityV1();
      entity.fromJson(json.decode(resp.body));
      expect(entity, isNotNull);
      expect(ENTITY1.name, entity.name);
      expect(ENTITY1.siteId, entity.siteId);
      expect(ENTITY1.type, entity.type);
      expect(ENTITY1.content, entity.content);

      // Create the second entity
      resp = await rest.post(url + '/v1/entities/entities',
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'entity': ENTITY2}));
      entity = EntityV1();
      entity.fromJson(json.decode(resp.body));
      expect(entity, isNotNull);
      expect(ENTITY2.name, entity.name);
      expect(ENTITY2.siteId, entity.siteId);
      expect(ENTITY2.type, entity.type);
      expect(ENTITY2.content, entity.content);

      // Get all beacons
      resp = await rest.get(url + '/v1/entities/entities');
      var page = DataPage<EntityV1>.fromJson(json.decode(resp.body), (item) {
        var entity = EntityV1();
        entity.fromJson(item);
        return entity;
      });
      expect(page, isNotNull);
      expect(page.data.length, 2);

      entity1 = page.data[0];
      entity1.name = 'ABC';

      // Update the entity
      resp = await rest.put(url + '/v1/entities/entities',
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'entity': entity1}));
      entity = EntityV1();
      entity.fromJson(json.decode(resp.body));

      expect(entity, isNotNull);
      expect(entity1.id, entity.id);
      expect(entity1.name, entity.name);

      // Get entity by name
      resp = await rest.get(url + '/v1/entities/entities/name/' + entity1.name);
      entity = EntityV1();
      entity.fromJson(json.decode(resp.body));
      expect(entity, isNotNull);
      expect(entity1.id, entity.id);

      // Delete the entity
      resp = await rest.delete(url + '/v1/entities/entities/' + entity1.id);
      entity = EntityV1();
      entity.fromJson(json.decode(resp.body));
      expect(entity, isNotNull);
      expect(entity1.id, entity.id);

      // Try to get deleted entity
      resp = await rest.get(url + '/v1/entities/entities/' + entity1.id);
      expect(resp.body, isEmpty);
    });
  });
}
