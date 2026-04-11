import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'app/app.dart';
import 'app/app_controller.dart';
import 'app/backend_bridge.dart';
import 'app/device_notification_service.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
  await BackendBridge.instance.init();
  await DeviceNotificationService.instance.init();
  final controller = AppController();
  await controller.bootstrap();
  runApp(UrkuFoodApp(controller: controller));
}
