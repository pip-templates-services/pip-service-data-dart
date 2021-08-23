import 'dart:async';

import 'package:pip_service_data_dart/src/data/version1/data.dart';
import 'package:pip_services3_commons/pip_services3_commons.dart';

abstract class IEntitiesPersistence {
  Future<DataPage<EntityV1>> getPageByFilter(
      String correlationId, FilterParams filter, PagingParams paging);
  Future<EntityV1> getOneById(String correlationId, String id);
  Future<EntityV1> getOneByName(String correlationId, String name);
  Future<EntityV1> create(String correlationId, EntityV1 item);
  Future<EntityV1> update(String correlationId, EntityV1 item);
  Future<EntityV1> deleteById(String correlationId, String id);
}
