import 'package:pip_services3_commons/pip_services3_commons.dart';
import 'package:pip_services3_grpc/pip_services3_grpc.dart';

class EntitiesCommandableGrpcServiceV1 extends CommandableGrpcService {
  EntitiesCommandableGrpcServiceV1() : super('v1.entities') {
    dependencyResolver.put('controller',
        Descriptor('pip-service-data', 'controller', '*', '*', '1.0'));
  }
}
