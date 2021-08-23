import 'package:pip_service_data_dart/src/data/version1/data.dart';
import 'package:pip_service_data_dart/src/logic/logic.dart';
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

void main() {
  group('EntitiesController', () {
    EntitiesMemoryPersistence persistence;
    EntitiesController controller;

    setUp(() async {
      persistence = EntitiesMemoryPersistence();
      persistence.configure(ConfigParams());

      controller = EntitiesController();
      controller.configure(ConfigParams());

      var references = References.fromTuples([
        Descriptor(
            'pip-service-data', 'persistence', 'memory', 'default', '1.0'),
        persistence,
        Descriptor(
            'pip-service-data', 'controller', 'default', 'default', '1.0'),
        controller
      ]);

      controller.setReferences(references);

      await persistence.open(null);
    });

    tearDown(() async {
      await persistence.close(null);
    });

    test('CRUD Operations', () async {
      EntityV1 entity1;

      // Create the first entity
      var entity = await controller.createEntity(null, ENTITY1);
      expect(entity, isNotNull);
      expect(ENTITY1.name, entity.name);
      expect(ENTITY1.siteId, entity.siteId);
      expect(ENTITY1.type, entity.type);
      expect(ENTITY1.content, entity.content);

      // Create the second entity
      entity = await controller.createEntity(null, ENTITY2);
      expect(entity, isNotNull);
      expect(ENTITY2.name, entity.name);
      expect(ENTITY2.siteId, entity.siteId);
      expect(ENTITY2.type, entity.type);
      expect(ENTITY2.content, entity.content);

      // Get all entitys
      var page =
          await controller.getEntities(null, FilterParams(), PagingParams());
      expect(page, isNotNull);
      expect(page.data.length, 2);
      entity1 = page.data[0];

      // Update the entity
      entity1.name = 'ABC';

      entity = await controller.updateEntity(null, entity1);
      expect(entity, isNotNull);
      expect(entity1.id, entity.id);
      expect('ABC', entity.name);

      // Get entity by name
      entity = await controller.getEntityByName(null, entity1.name);
      expect(entity, isNotNull);
      expect(entity1.id, entity.id);

      // Delete the entity
      entity = await controller.deleteEntityById(null, entity1.id);
      expect(entity, isNotNull);
      expect(entity1.id, entity.id);

      // Try to get deleted entity
      entity = await controller.getEntityById(null, entity1.id);
      expect(entity, isNull);
    });
  });
}
