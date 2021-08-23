import 'dart:async';

import 'package:pip_service_data_dart/src/data/version1/data.dart';
import 'package:pip_services3_commons/pip_services3_commons.dart';

abstract class IEntitiesController {
  Future<DataPage<EntityV1>> getEntities(
      String correlationId, FilterParams filter, PagingParams paging);

  Future<EntityV1> getEntityById(String correlationId, String entityId);

  Future<EntityV1> getEntityByName(String correlationId, String entityName);

  Future<EntityV1> createEntity(String correlationId, EntityV1 entity);

  Future<EntityV1> updateEntity(String correlationId, EntityV1 entity);

  Future<EntityV1> deleteEntityById(String correlationId, String entityId);
}
