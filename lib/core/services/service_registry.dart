import '../../features/parser/data/services/local_event_parser_service.dart';
import '../../features/parser/domain/services/event_parser_service.dart';
import '../../features/reminder/data/datasources/reminder_local_datasource.dart';
import '../../features/reminder/data/repositories/reminder_repository_impl.dart';
import '../../features/reminder/domain/repositories/reminder_repository.dart';
import 'hive_service.dart';
import 'notification_service.dart';
import 'voice_input_service.dart';

class ServiceRegistry {
  const ServiceRegistry._();

  static late EventParserService parserService;
  static late ReminderRepository reminderRepository;
  static late NotificationService notificationService;
  static late VoiceInputService voiceInputService;

  static Future<void> initialize() async {
    await HiveService.initialize();

    parserService = LocalEventParserService();
    reminderRepository = ReminderRepositoryImpl(
      ReminderLocalDatasource(HiveService.remindersBox),
    );

    notificationService = NotificationService();
    await notificationService.initialize();

    voiceInputService = VoiceInputService();
  }
}
