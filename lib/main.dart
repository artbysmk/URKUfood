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

  try {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
  } catch (e) {
    debugPrint('[main] Firebase init failed: $e');
  }

  try {
    await BackendBridge.instance.init();
  } catch (e) {
    debugPrint('[main] BackendBridge init failed: $e');
  }

  try {
    await DeviceNotificationService.instance.init();
  } catch (e) {
    debugPrint('[main] DeviceNotificationService init failed: $e');
  }

  final controller = AppController();
  controller.bootstrap();
  runApp(UrkuFoodApp(controller: controller));
}
