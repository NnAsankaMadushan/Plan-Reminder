import 'package:flutter/material.dart';

import 'app.dart';
import 'core/services/service_registry.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ServiceRegistry.initialize();
  runApp(const ReminderApp());
}
