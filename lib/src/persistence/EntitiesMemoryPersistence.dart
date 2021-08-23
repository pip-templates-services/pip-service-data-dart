import 'dart:async';

import 'package:pip_service_data_dart/src/data/version1/data.dart';
import 'package:pip_services3_commons/src/data/PagingParams.dart';
import 'package:pip_services3_commons/src/data/FilterParams.dart';
import 'package:pip_services3_commons/src/data/DataPage.dart';
import 'package:pip_services3_data/pip_services3_data.dart';

import 'IEntitiesPersistence.dart';

class EntitiesMemoryPersistence
    extends IdentifiableMemoryPersistence<EntityV1, String>
    implements IEntitiesPersistence {
  EntitiesMemoryPersistence() : super() {
    maxPageSize = 1000;
  }

  Function composeFilter(FilterParams filter) {
    filter = filter ?? FilterParams();

    var id = filter.getAsNullableString('id');
    var siteId = filter.getAsNullableString('site_id');
    var type = filter.getAsNullableString('type');
    var name = filter.getAsNullableString('name');
    var names = filter.getAsObject('names');
    if (names != null && names is String) {
      names = (names as String).split(',');
    }
    if (names != null && !(names is List)) {
      names = null;
    }

    return (item) {
      if (id != null && item.id != id) {
        return false;
      }
      if (siteId != null && item.siteId != siteId) {
        return false;
      }
      if (name != null && item.name != name) {
        return false;
      }
      if (type != null && item.type != type) {
        return false;
      }

      if (names != null && !(names as List).contains(item.name)) {
        return false;
      }
      return true;
    };
  }

  @override
  Future<EntityV1> getOneByName(String correlationId, String name) async {
    var item = items.firstWhere((item) => item.name == name);

    if (item != null) {
      logger.trace(correlationId, 'Found entity by %s', [name]);
    } else {
      logger.trace(correlationId, 'Cannot find entity by %s', [name]);
    }

    return item;
  }

  @override
  Future<DataPage<EntityV1>> getPageByFilter(
      String correlationId, FilterParams filter, PagingParams paging) {
    return super
        .getPageByFilterEx(correlationId, composeFilter(filter), paging, null);
  }
}
