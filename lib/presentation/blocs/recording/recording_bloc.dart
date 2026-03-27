import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/services/recording_service.dart';
import '../../../core/services/subscription_service.dart';
import '../../../data/datasources/database_helper.dart';
import '../../../domain/entities/recording.dart';
import 'recording_event.dart';
import 'recording_state.dart';

class RecordingBloc extends Bloc<RecordingEvent, RecordingState> {
  final DatabaseHelper _databaseHelper;
  Timer? _durationTimer;

  RecordingBloc({DatabaseHelper? databaseHelper})
      : _databaseHelper = databaseHelper ?? DatabaseHelper(),
        super(const RecordingState()) {
    on<StartRecording>(_onStartRecording);
    on<PauseRecording>(_onPauseRecording);
    on<ResumeRecording>(_onResumeRecording);
    on<StopRecording>(_onStopRecording);
    on<CancelRecording>(_onCancelRecording);
    on<UpdateDuration>(_onUpdateDuration);
    on<UpdateAmplitude>(_onUpdateAmplitude);
    on<LoadRecordings>(_onLoadRecordings);
    on<DeleteRecording>(_onDeleteRecording);
    on<MoveToVault>(_onMoveToVault);
    on<RenameRecording>(_onRenameRecording);
  }

  Future<void> _onStartRecording(
    StartRecording event,
    Emitter<RecordingState> emit,
  ) async {
    try {
      // Check if user can record (trial/subscription)
      final canRecord = await SubscriptionService.canRecord();
      if (!canRecord) {
        emit(state.copyWith(
          status: RecordingStateStatus.error,
          errorMessage: 'Assinatura expirada. Atualize para continuar gravando.',
        ));
        return;
      }

      // Start recording
      final path = await RecordingService.startRecording();
      if (path == null) {
        emit(state.copyWith(
          status: RecordingStateStatus.error,
          errorMessage: 'Falha ao iniciar gravação',
        ));
        return;
      }

      emit(state.copyWith(
        status: RecordingStateStatus.recording,
        currentDuration: Duration.zero,
        lastRecordingPath: path,
      ));

      // Start duration timer
      _startDurationTimer();
    } catch (e) {
      emit(state.copyWith(
        status: RecordingStateStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onPauseRecording(
    PauseRecording event,
    Emitter<RecordingState> emit,
  ) async {
    try {
      await RecordingService.pauseRecording();
      _durationTimer?.cancel();
      emit(state.copyWith(status: RecordingStateStatus.paused));
    } catch (e) {
      emit(state.copyWith(
        status: RecordingStateStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onResumeRecording(
    ResumeRecording event,
    Emitter<RecordingState> emit,
  ) async {
    try {
      await RecordingService.resumeRecording();
      _startDurationTimer();
      emit(state.copyWith(status: RecordingStateStatus.recording));
    } catch (e) {
      emit(state.copyWith(
        status: RecordingStateStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onStopRecording(
    StopRecording event,
    Emitter<RecordingState> emit,
  ) async {
    try {
      emit(state.copyWith(status: RecordingStateStatus.saving));

      _durationTimer?.cancel();

      final recording = await RecordingService.stopRecording(name: event.name);
      if (recording == null) {
        emit(state.copyWith(
          status: RecordingStateStatus.error,
          errorMessage: 'Falha ao salvar gravação',
        ));
        return;
      }

      // Save to database
      await _databaseHelper.insertRecording(recording);

      // Reload recordings
      final recordings = await _databaseHelper.getAllRecordings();

      emit(state.copyWith(
        status: RecordingStateStatus.loaded,
        recordings: recordings,
        lastRecordingPath: recording.filePath,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: RecordingStateStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onCancelRecording(
    CancelRecording event,
    Emitter<RecordingState> emit,
  ) async {
    try {
      _durationTimer?.cancel();
      await RecordingService.cancelRecording();
      emit(state.copyWith(
        status: RecordingStateStatus.idle,
        currentDuration: Duration.zero,
        amplitude: 0.0,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: RecordingStateStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  void _onUpdateDuration(
    UpdateDuration event,
    Emitter<RecordingState> emit,
  ) {
    final newDuration = state.currentDuration + const Duration(milliseconds: 100);
    emit(state.copyWith(currentDuration: newDuration));
  }

  void _onUpdateAmplitude(
    UpdateAmplitude event,
    Emitter<RecordingState> emit,
  ) {
    emit(state.copyWith(amplitude: event.amplitude));
  }

  Future<void> _onLoadRecordings(
    LoadRecordings event,
    Emitter<RecordingState> emit,
  ) async {
    try {
      emit(state.copyWith(status: RecordingStateStatus.loading));

      final recordings = await _databaseHelper.getAllRecordings();

      emit(state.copyWith(
        status: RecordingStateStatus.loaded,
        recordings: recordings,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: RecordingStateStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onDeleteRecording(
    DeleteRecording event,
    Emitter<RecordingState> emit,
  ) async {
    try {
      await _databaseHelper.deleteRecording(event.recordingId);

      final recordings = await _databaseHelper.getAllRecordings();

      emit(state.copyWith(
        status: RecordingStateStatus.loaded,
        recordings: recordings,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: RecordingStateStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onMoveToVault(
    MoveToVault event,
    Emitter<RecordingState> emit,
  ) async {
    try {
      await _databaseHelper.moveToVault(event.recordingId, event.toVault);

      final recordings = await _databaseHelper.getAllRecordings();

      emit(state.copyWith(
        status: RecordingStateStatus.loaded,
        recordings: recordings,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: RecordingStateStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onRenameRecording(
    RenameRecording event,
    Emitter<RecordingState> emit,
  ) async {
    try {
      final recording = await _databaseHelper.getRecordingById(event.recordingId);
      if (recording != null) {
        final updated = recording.copyWith(name: event.newName);
        await _databaseHelper.updateRecording(updated);

        final recordings = await _databaseHelper.getAllRecordings();

        emit(state.copyWith(
          status: RecordingStateStatus.loaded,
          recordings: recordings,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: RecordingStateStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  void _startDurationTimer() {
    _durationTimer?.cancel();
    _durationTimer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      add(const UpdateDuration());
    });
  }

  @override
  Future<void> close() {
    _durationTimer?.cancel();
    return super.close();
  }
}