import 'package:hive_flutter/hive_flutter.dart';

import '../constants/app_constants.dart';
import '../../features/reminder/data/models/reminder_event_model.dart';

class HiveService {
  const HiveService._();

  static late Box<ReminderEventModel> remindersBox;

  static Future<void> initialize() async {
    await Hive.initFlutter();

    if (!Hive.isAdapterRegistered(ReminderEventModelAdapter.typeIdValue)) {
      Hive.registerAdapter(ReminderEventModelAdapter());
    }

    remindersBox = await Hive.openBox<ReminderEventModel>(
      AppConstants.remindersBoxName,
    );
  }

  static Future<void> dispose() async {
    await remindersBox.close();
    await Hive.close();
  }
}
