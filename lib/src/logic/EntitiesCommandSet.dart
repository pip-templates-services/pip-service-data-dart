import 'package:pip_service_data_dart/src/data/version1/data.dart';
import 'package:pip_services3_commons/pip_services3_commons.dart';

import 'IEntitiesController.dart';

class EntitiesCommandSet extends CommandSet {
  IEntitiesController _controller;

  EntitiesCommandSet(IEntitiesController controller) : super() {
    _controller = controller;

    addCommand(_makeGetEntitiesCommand());
    addCommand(_makeGetEntityByIdCommand());
    addCommand(_makeGetEntityByNameCommand());
    addCommand(_makeCreateEntityCommand());
    addCommand(_makeUpdateEntityCommand());
    addCommand(_makeDeleteEntityByIdCommand());
  }

  ICommand _makeGetEntitiesCommand() {
    return Command(
        'get_entities',
        ObjectSchema(true)
            .withOptionalProperty('filter', FilterParamsSchema())
            .withOptionalProperty('paging', PagingParamsSchema()),
        (String correlationId, Parameters args) async {
      var filter = FilterParams.fromValue(args.get('filter'));
      var paging = PagingParams.fromValue(args.get('paging'));
      return await _controller.getEntities(correlationId, filter, paging);
    });
  }

  ICommand _makeGetEntityByIdCommand() {
    return Command('get_entity_by_id',
        ObjectSchema(true).withRequiredProperty('entity_id', TypeCode.String),
        (String correlationId, Parameters args) async {
      var entityId = args.getAsString('entity_id');
      return await _controller.getEntityById(correlationId, entityId);
    });
  }

  ICommand _makeGetEntityByNameCommand() {
    return Command('get_entity_by_name',
        ObjectSchema(true).withRequiredProperty('name', TypeCode.String),
        (String correlationId, Parameters args) async {
      var name = args.getAsString('name');
      return await _controller.getEntityByName(correlationId, name);
    });
  }

  ICommand _makeCreateEntityCommand() {
    return Command('create_entity',
        ObjectSchema(true).withRequiredProperty('entity', EntityV1Schema()),
        (String correlationId, Parameters args) async {
      var entity = EntityV1().fromJson(args.getAsObject('entity'));
      return await _controller.createEntity(correlationId, entity);
    });
  }

  ICommand _makeUpdateEntityCommand() {
    return Command('update_entity',
        ObjectSchema(true).withRequiredProperty('entity', EntityV1Schema()),
        (String correlationId, Parameters args) async {
      var entity = EntityV1().fromJson(args.getAsObject('entity'));
      return await _controller.updateEntity(correlationId, entity);
    });
  }

  ICommand _makeDeleteEntityByIdCommand() {
    return Command('delete_entity_by_id',
        ObjectSchema(true).withRequiredProperty('entity_id', TypeCode.String),
        (String correlationId, Parameters args) async {
      var entityId = args.getAsString('entity_id');
      return await _controller.deleteEntityById(correlationId, entityId);
    });
  }
}
