import 'package:flutter/material.dart';
import 'core/services/notification_service.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'app.dart';
import 'injection_container.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.initialize();
  
  // Initialize Hive
  await Hive.initFlutter();
  
  // Initialize dependency injection
  await di.init();
  
  runApp(const App());
}
