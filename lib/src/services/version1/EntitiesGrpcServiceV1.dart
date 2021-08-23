import 'dart:async';

import 'package:grpc/grpc.dart';
import 'package:pip_service_data_dart/src/logic/logic.dart';
import 'package:pip_service_data_dart/src/services/version1/EntitiesGrpcConverterV1.dart';
import 'package:pip_services3_commons/pip_services3_commons.dart';
import 'package:pip_services3_grpc/pip_services3_grpc.dart';

import 'package:pip_service_data_dart/src/generated/generated.dart' as proto;

class EntitiesGrpcServiceV1 extends proto.EntitiesServiceBase with GrpcService {
  IEntitiesController _controller;

  EntitiesGrpcServiceV1() {
    serviceName = $name;
    dependencyResolver.put('controller',
        Descriptor('pip-service-data', 'controller', '*', '*', '*'));
  }

  @override
  void setReferences(IReferences references) {
    super.setReferences(references);
    _controller =
        dependencyResolver.getOneRequired<IEntitiesController>('controller');
  }

  @override
  Future<proto.EntitiesPageReply> get_entities(
      ServiceCall call, proto.EntitiesPageRequest request) async {
    var correlationId = request.correlationId;
    var filter = FilterParams(request.filter);
    var paging = EntitiesGrpcConverterV1.toPagingParams(request.paging);
    var response = proto.EntitiesPageReply();
    var timing = instrument(correlationId, 'get_entities');
    try {
      var result = await _controller.getEntities(correlationId, filter, paging);
      response.page = EntitiesGrpcConverterV1.fromEntitiesPage(result);
    } catch (err) {
      var error = EntitiesGrpcConverterV1.fromError(err);
      response.error = error;
    } finally {
      timing.endTiming();
    }
    return response;
  }

  @override
  Future<proto.EntityReply> get_entity_by_id(
      ServiceCall call, proto.EntityIdRequest request) async {
    var correlationId = request.correlationId;
    var id = request.entityId;
    var response = proto.EntityReply();

    var timing = instrument(correlationId, 'get_entity_by_id');

    try {
      var result = await _controller.getEntityById(correlationId, id);
      response.entity = result != null
          ? EntitiesGrpcConverterV1.fromEntity(result)
          : proto.Entity();
    } catch (err) {
      var error = EntitiesGrpcConverterV1.fromError(err);
      response.error = error;
    } finally {
      timing.endTiming();
    }
    return response;
  }

  @override
  Future<proto.EntityReply> get_entity_by_name(
      ServiceCall call, proto.EntityNameRequest request) async {
    var correlationId = request.correlationId;
    var name = request.name;
    var response = proto.EntityReply();
    var timing = instrument(correlationId, 'get_entity_by_name');
    try {
      var result = await _controller.getEntityByName(correlationId, name);
      response.entity = EntitiesGrpcConverterV1.fromEntity(result);
    } catch (err) {
      var error = EntitiesGrpcConverterV1.fromError(err);
      response.error = error;
    } finally {
      timing.endTiming();
    }
    return response;
  }

  @override
  Future<proto.EntityReply> create_entity(
      ServiceCall call, proto.EntityRequest request) async {
    var correlationId = request.correlationId;
    var beacon = EntitiesGrpcConverterV1.toEntity(request.entity);
    var response = proto.EntityReply();
    var timing = instrument(correlationId, 'create_entity');
    try {
      var result = await _controller.createEntity(correlationId, beacon);
      response.entity = EntitiesGrpcConverterV1.fromEntity(result);
    } catch (err) {
      var error = EntitiesGrpcConverterV1.fromError(err);
      response.error = error;
    } finally {
      timing.endTiming();
    }
    return response;
  }

  @override
  Future<proto.EntityReply> update_entity(
      ServiceCall call, proto.EntityRequest request) async {
    var correlationId = request.correlationId;
    var beacon = EntitiesGrpcConverterV1.toEntity(request.entity);
    var response = proto.EntityReply();
    var timing = instrument(correlationId, 'update_entity');
    try {
      var result = await _controller.updateEntity(correlationId, beacon);
      response.entity = EntitiesGrpcConverterV1.fromEntity(result);
    } catch (err) {
      var error = EntitiesGrpcConverterV1.fromError(err);
      response.error = error;
    } finally {
      timing.endTiming();
    }
    return response;
  }

  @override
  Future<proto.EntityReply> delete_entity_by_id(
      ServiceCall call, proto.EntityIdRequest request) async {
    var correlationId = request.correlationId;
    var id = request.entityId;
    var response = proto.EntityReply();
    var timing = instrument(correlationId, 'delete_entity_by_id');
    try {
      var result = await _controller.deleteEntityById(correlationId, id);
      response.entity = EntitiesGrpcConverterV1.fromEntity(result);
    } catch (err) {
      var error = EntitiesGrpcConverterV1.fromError(err);
      response.error = error;
    } finally {
      timing.endTiming();
    }
    return response;
  }

  @override
  void register() {
    registerService(this);
  }
}
