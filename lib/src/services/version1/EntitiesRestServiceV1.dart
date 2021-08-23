import 'dart:async';
import 'dart:io';
import 'package:angel_framework/angel_framework.dart' as angel;
import 'package:pip_service_data_dart/src/data/version1/data.dart';

import 'package:pip_service_data_dart/src/logic/logic.dart';
import 'package:pip_services3_commons/pip_services3_commons.dart';
import 'package:pip_services3_rpc/pip_services3_rpc.dart';

class EntitiesRestServiceV1 extends RestService {
  IEntitiesController _controller;

  EntitiesRestServiceV1() : super() {
    baseRoute = 'v1/entities';
    dependencyResolver.put('controller',
        Descriptor('pip-service-data', 'controller', 'default', '*', '*'));
  }

  @override
  void setReferences(IReferences references) {
    super.setReferences(references);
    _controller =
        dependencyResolver.getOneRequired<IEntitiesController>('controller');
  }

  Future<void> getEntities(
      angel.RequestContext req, angel.ResponseContext res) async {
    var filter = FilterParams();
    var paging = PagingParams();

    var correlationId = req.params['correlationId'] ?? '';

    if (req.params['filter'] != null) filter.fromJson(req.params['filter']);
    if (req.params['paging'] != null) paging.fromJson(req.params['paging']);

    var timing = instrument(correlationId, 'get_entities');

    try {
      var page = await _controller.getEntities(correlationId, filter, paging);
      HttpResponseSender.sendResult(req, res, null, page);
    } catch (err) {
      HttpResponseSender.sendError(req, res, err);
    } finally {
      timing.endTiming();
    }
  }

  Future<void> getEntityById(
      angel.RequestContext req, angel.ResponseContext res) async {
    var id = req.params['id'];
    var correlationId = req.params['correlationId'] ?? '';
    var timing = instrument(correlationId, 'get_entity_by_id');
    try {
      var result = await _controller.getEntityById(correlationId, id);
      HttpResponseSender.sendResult(req, res, null, result);
    } catch (err) {
      HttpResponseSender.sendError(req, res, err);
    } finally {
      timing.endTiming();
    }
  }

  Future<void> getEntityByName(
      angel.RequestContext req, angel.ResponseContext res) async {
    var name = req.params['name'];
    var correlationId = req.params['correlationId'] ?? '';
    var timing = instrument(correlationId, 'get_entity_by_name');
    try {
      var result = await _controller.getEntityByName(correlationId, name);
      HttpResponseSender.sendResult(req, res, null, result);
    } catch (err) {
      HttpResponseSender.sendError(req, res, err);
    } finally {
      timing.endTiming();
    }
  }

  Future<void> createEntity(
      angel.RequestContext req, angel.ResponseContext res) async {
    await req.parseBody();
    var entity = EntityV1();
    entity.fromJson(req.bodyAsMap['entity']);
    var correlationId = req.params['correlationId'] ?? '';
    var timing = instrument(correlationId, 'create_entity');

    try {
      var result = await _controller.createEntity(correlationId, entity);
      HttpResponseSender.sendResult(req, res, null, result);
    } catch (err) {
      HttpResponseSender.sendError(req, res, err);
    } finally {
      timing.endTiming();
    }
  }

  Future<void> updateEntity(
      angel.RequestContext req, angel.ResponseContext res) async {
    await req.parseBody();
    var entity = EntityV1().fromJson(req.bodyAsMap['entity']);
    var correlationId = req.params['correlationId'] ?? '';
    var timing = instrument(correlationId, 'get_entity_by_name');
    try {
      var result = await _controller.updateEntity(correlationId, entity);
      HttpResponseSender.sendResult(req, res, null, result);
    } catch (err) {
      HttpResponseSender.sendError(req, res, err);
    } finally {
      timing.endTiming();
    }
  }

  Future<void> deleteEntityById(
      angel.RequestContext req, angel.ResponseContext res) async {
    var id = req.params['id'];
    var correlationId = req.params['correlationId'] ?? '';

    var timing = instrument(correlationId, 'get_entity_by_name');

    try {
      var result = await _controller.deleteEntityById(correlationId, id);
      HttpResponseSender.sendResult(req, res, null, result);
    } catch (err) {
      HttpResponseSender.sendError(req, res, err);
    } finally {
      timing.endTiming();
    }
  }

  @override
  void register() {
    registerRoute('get', '/entities', null, getEntities);
    registerRoute('get', '/entities/:id', null, getEntityById);
    registerRoute('get', '/entities/name/:name', null, getEntityByName);
    registerRoute('post', '/entities', null, createEntity);
    registerRoute('put', '/entities', null, updateEntity);
    registerRoute('del', '/entities/:id', null, deleteEntityById);

    registerOpenApiSpecFromFile(
        Directory.current.path + '/lib/src/swagger/entities_v1.yaml');
  }
}
