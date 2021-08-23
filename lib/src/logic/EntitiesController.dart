import 'dart:async';

import 'package:pip_service_data_dart/src/data/version1/EntityV1.dart';
import 'package:pip_service_data_dart/src/data/version1/data.dart';
import 'package:pip_service_data_dart/src/persistence/persistence.dart';
import 'package:pip_services3_commons/pip_services3_commons.dart';

import 'EntitiesCommandSet.dart';
import 'IEntitiesController.dart';

class EntitiesController
    implements
        IEntitiesController,
        IConfigurable,
        IReferenceable,
        ICommandable {
  IEntitiesPersistence _persistence;
  EntitiesCommandSet _commandSet;

  @override
  void configure(ConfigParams config) {}

  @override
  void setReferences(IReferences references) {
    _persistence = references.getOneRequired<IEntitiesPersistence>(
        Descriptor('pip-service-data', 'persistence', '*', '*', '1.0'));
  }

  @override
  CommandSet getCommandSet() {
    _commandSet ??= EntitiesCommandSet(this);

    return _commandSet;
  }

  @override
  Future<EntityV1> createEntity(String correlationId, EntityV1 entity) {
    entity.id = entity.id ?? IdGenerator.nextLong();
    entity.type = entity.type ?? EntityTypeV1.Unknown;

    return _persistence.create(correlationId, entity);
  }

  @override
  Future<EntityV1> deleteEntityById(String correlationId, String entityId) {
    return _persistence.deleteById(correlationId, entityId);
  }

  @override
  Future<DataPage<EntityV1>> getEntities(
      String correlationId, FilterParams filter, PagingParams paging) {
    return _persistence.getPageByFilter(correlationId, filter, paging);
  }

  @override
  Future<EntityV1> getEntityById(String correlationId, String entityId) {
    return _persistence.getOneById(correlationId, entityId);
  }

  @override
  Future<EntityV1> getEntityByName(String correlationId, String entityName) {
    return _persistence.getOneByName(correlationId, entityName);
  }

  @override
  Future<EntityV1> updateEntity(String correlationId, EntityV1 entity) {
    entity.type = entity.type ?? EntityTypeV1.Unknown;

    return _persistence.update(correlationId, entity);
  }
}
