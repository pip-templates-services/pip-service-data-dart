import 'package:pip_services3_container/pip_services3_container.dart';
import 'package:pip_services3_elasticsearch/pip_services3_elasticsearch.dart';
import 'package:pip_services3_grpc/pip_services3_grpc.dart';
import 'package:pip_services3_prometheus/pip_services3_prometheus.dart';
import 'package:pip_services3_rpc/pip_services3_rpc.dart';

import '../build/EntitiesServiceFactory.dart';

class EntitiesProcess extends ProcessContainer {
  EntitiesProcess() : super('pip-service-data', 'Entities microservice') {
    factories.add(EntitiesServiceFactory());
    factories.add(DefaultElasticSearchFactory());
    factories.add(DefaultPrometheusFactory());
    // factories.add(DefaultDataDogFactory());
    factories.add(DefaultRpcFactory());
    // factories.add(DefaultSwaggerFactory());
    factories.add(DefaultGrpcFactory());
  }
}
