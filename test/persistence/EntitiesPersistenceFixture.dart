import 'dart:async';

import 'package:pip_service_data_dart/src/data/version1/data.dart';
import 'package:pip_service_data_dart/src/persistence/persistence.dart';
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
final ENTITY3 = EntityV1(
    id: '3',
    name: '00003',
    type: EntityTypeV1.Type1,
    siteId: '2',
    content: 'DEF');

class EntitiesPersistenceFixture {
  IEntitiesPersistence _persistence;

  EntitiesPersistenceFixture(IEntitiesPersistence persistence) {
    expect(persistence, isNotNull);
    _persistence = persistence;
  }

  Future<void> _testCreateEntities() async {
    // Create the first entity
    var entity = await _persistence.create(null, ENTITY1);

    expect(entity, isNotNull);
    expect(ENTITY1.name, entity.name);
    expect(ENTITY1.siteId, entity.siteId);
    expect(ENTITY1.type, entity.type);
    expect(ENTITY1.content, entity.content);

    // Create the second entity
    entity = await _persistence.create(null, ENTITY2);
    expect(entity, isNotNull);
    expect(ENTITY2.name, entity.name);
    expect(ENTITY2.siteId, entity.siteId);
    expect(ENTITY2.type, entity.type);
    expect(ENTITY2.content, entity.content);

    // Create the third entity
    entity = await _persistence.create(null, ENTITY3);
    expect(entity, isNotNull);
    expect(ENTITY3.name, entity.name);
    expect(ENTITY3.siteId, entity.siteId);
    expect(ENTITY3.type, entity.type);
    expect(ENTITY3.content, entity.content);
  }

  Future<void> testCrudOperations() async {
    EntityV1 entity1;

    // Create items
    await _testCreateEntities();

    // Get all entities
    var page = await _persistence.getPageByFilter(
        null, FilterParams(), PagingParams());
    expect(page, isNotNull);
    expect(page.data.length, 3);

    entity1 = page.data[0];

    // Update the entity
    entity1.name = 'ABC';

    var entity = await _persistence.update(null, entity1);
    expect(entity, isNotNull);
    expect(entity1.id, entity.id);
    expect('ABC', entity.name);

    // Get entity by name
    entity = await _persistence.getOneByName(null, entity1.name);
    expect(entity, isNotNull);
    expect(entity1.id, entity.id);

    // Delete the entity
    entity = await _persistence.deleteById(null, entity1.id);
    expect(entity, isNotNull);
    expect(entity1.id, entity.id);

    // Try to get deleted entity
    entity = await _persistence.getOneById(null, entity1.id);
    expect(entity, isNull);
  }

  Future<void> testGetWithFilters() async {
    // Create items

    await _testCreateEntities();

    // Filter by id
    var page = await _persistence.getPageByFilter(
        null, FilterParams.fromTuples(['id', '1']), PagingParams());
    expect(page.data.length, 1);

    // Filter by udi
    page = await _persistence.getPageByFilter(
        null, FilterParams.fromTuples(['name', '00002']), PagingParams());
    expect(page.data.length, 1);

    // Filter by udis
    page = await _persistence.getPageByFilter(null,
        FilterParams.fromTuples(['names', '00001,00003']), PagingParams());
    expect(page.data.length, 2);

    // Filter by site_id
    page = await _persistence.getPageByFilter(
        null, FilterParams.fromTuples(['site_id', '1']), PagingParams());
    expect(page.data.length, 2);
  }
}
