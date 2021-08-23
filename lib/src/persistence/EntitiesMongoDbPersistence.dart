import 'dart:async';

import 'package:mongo_dart_query/mongo_dart_query.dart' as mngquery;

import 'package:pip_service_data_dart/src/data/version1/data.dart';
import 'package:pip_services3_commons/src/data/PagingParams.dart';
import 'package:pip_services3_commons/src/data/FilterParams.dart';
import 'package:pip_services3_commons/src/data/DataPage.dart';
import 'package:pip_services3_mongodb/pip_services3_mongodb.dart';

import 'IEntitiesPersistence.dart';

class EntitiesMongoDbPersistence
    extends IdentifiableMongoDbPersistence<EntityV1, String>
    implements IEntitiesPersistence {
  EntitiesMongoDbPersistence() : super('entities') {
    maxPageSize = 1000;
  }

  dynamic composeFilter(FilterParams filter) {
    filter = filter ?? FilterParams();

    var criteria = [];

    var id = filter.getAsNullableString('id');
    if (id != null) {
      criteria.add({'_id': id});
    }

    var siteId = filter.getAsNullableString('site_id');
    if (siteId != null) {
      criteria.add({'site_id': siteId});
    }

    var name = filter.getAsNullableString('name');
    if (name != null) {
      criteria.add({'name': name});
    }

    var names = filter.getAsObject('names');
    if (names is String) {
      names = (names as String).split(',');
    }
    if (names is List) {
      criteria.add({
        'name': {r'$in': names}
      });
    }

    return criteria.isNotEmpty ? {r'$and': criteria} : null;
  }

  @override
  Future<EntityV1> getOneByName(String correlationId, String name) async {
    var filter = {'name': name};
    var query = mngquery.SelectorBuilder();
    var selector = <String, dynamic>{};
    if (filter != null && filter.isNotEmpty) {
      selector[r'$query'] = filter;
    }
    query.raw(selector);

    var item = await collection.findOne(filter);

    if (item == null) {
      logger.trace(correlationId, 'Cannot find entity by %s', [name]);
      return null;
    }
    logger.trace(correlationId, 'Found entity by %s', [name]);
    return convertToPublic(item);
  }

  @override
  Future<DataPage<EntityV1>> getPageByFilter(
      String correlationId, FilterParams filter, PagingParams paging) {
    return super
        .getPageByFilterEx(correlationId, composeFilter(filter), paging, null);
  }
}
