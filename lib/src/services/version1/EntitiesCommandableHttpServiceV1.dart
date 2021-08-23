import 'package:pip_services3_rpc/pip_services3_rpc.dart';
import 'package:pip_services3_commons/pip_services3_commons.dart';

class EntitiesCommandableHttpServiceV1 extends CommandableHttpService {
  EntitiesCommandableHttpServiceV1() : super('v1/entities') {
    dependencyResolver.put('controller',
        Descriptor('pip-service-data', 'controller', '*', '*', '1.0'));
  }
}
