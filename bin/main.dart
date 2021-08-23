import 'package:pip_service_data_dart/src/container/container.dart';

void main(List<String> argument) {
  try {
    var proc = EntitiesProcess();
    proc.configPath = './config/config.yml'; // YamlConfigReader have an errors
    proc.run(argument);
  } catch (ex) {
    print(ex);
  }
}
