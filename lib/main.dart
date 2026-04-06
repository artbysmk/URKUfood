import 'package:flutter/widgets.dart';

import 'app/app.dart';
import 'app/app_controller.dart';
import 'app/backend_bridge.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await BackendBridge.instance.init();
  final controller = AppController();
  await controller.bootstrap();
  runApp(UrkuFoodApp(controller: controller));
}
