import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/notification_service.dart';
import '../../domain/entities/reminder_event.dart';

part 'reminder_event.dart';
part 'reminder_state.dart';

class ReminderBloc extends Bloc<ReminderEventAction, ReminderState> {
  ReminderBloc({
    required NotificationService notificationService,
  })  : _notificationService = notificationService,
        super(const ReminderState()) {
    on<ReminderScheduleRequested>(_onScheduleRequested);
    on<ReminderCancelRequested>(_onCancelRequested);
    on<ReminderRescheduleRequested>(_onRescheduleRequested);
    on<ReminderStatusResetRequested>(_onStatusResetRequested);
  }

  final NotificationService _notificationService;

  Future<void> _onScheduleRequested(
    ReminderScheduleRequested event,
    Emitter<ReminderState> emit,
  ) async {
    emit(
      state.copyWith(
        status: ReminderStatus.processing,
        errorMessage: null,
        eventId: event.event.id,
      ),
    );

    try {
      await _notificationService.scheduleReminder(event.event);
      emit(state.copyWith(status: ReminderStatus.success));
    } catch (error) {
      emit(
        state.copyWith(
          status: ReminderStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<void> _onCancelRequested(
    ReminderCancelRequested event,
    Emitter<ReminderState> emit,
  ) async {
    emit(
      state.copyWith(
        status: ReminderStatus.processing,
        errorMessage: null,
        eventId: event.eventId,
      ),
    );

    try {
      await _notificationService.cancelReminder(event.eventId);
      emit(state.copyWith(status: ReminderStatus.success));
    } catch (error) {
      emit(
        state.copyWith(
          status: ReminderStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<void> _onRescheduleRequested(
    ReminderRescheduleRequested event,
    Emitter<ReminderState> emit,
  ) async {
    emit(
      state.copyWith(
        status: ReminderStatus.processing,
        errorMessage: null,
        eventId: event.event.id,
      ),
    );

    try {
      await _notificationService.cancelReminder(event.event.id);
      await _notificationService.scheduleReminder(event.event);
      emit(state.copyWith(status: ReminderStatus.success));
    } catch (error) {
      emit(
        state.copyWith(
          status: ReminderStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  void _onStatusResetRequested(
    ReminderStatusResetRequested event,
    Emitter<ReminderState> emit,
  ) {
    emit(state.copyWith(status: ReminderStatus.initial, errorMessage: null));
  }
}
