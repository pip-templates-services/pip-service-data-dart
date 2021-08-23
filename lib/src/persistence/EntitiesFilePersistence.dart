import 'package:pip_service_data_dart/src/data/version1/data.dart';
import 'package:pip_services3_commons/pip_services3_commons.dart';
import 'package:pip_services3_data/pip_services3_data.dart';

import 'EntitiesMemoryPersistence.dart';

class EntitiesFilePersistence extends EntitiesMemoryPersistence {
  JsonFilePersister<EntityV1> persister;

  EntitiesFilePersistence([String path]) : super() {
    persister = JsonFilePersister<EntityV1>(path);
    loader = persister;
    saver = persister;
  }

  @override
  void configure(ConfigParams config) {
    super.configure(config);
    persister.configure(config);
  }
}
