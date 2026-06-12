import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/parsed_meal_item.dart';
import '../../data/services/french_meal_parser.dart';

part 'voice_event.dart';
part 'voice_state.dart';

class VoiceBloc extends Bloc<VoiceEvent, VoiceState> {
  VoiceBloc() : super(const VoiceInitial()) {
    on<VoiceParseRequested>(_onParseRequested);
    on<VoiceResetRequested>(_onResetRequested);
  }

  void _onParseRequested(VoiceParseRequested event, Emitter<VoiceState> emit) {
    emit(const VoiceParsing());
    final trimmed = event.transcription.trim();
    if (trimmed.isEmpty) {
      emit(const VoiceError('Aucune transcription reçue.'));
      return;
    }
    final items = FrenchMealParser.parse(trimmed);
    if (items.isEmpty) {
      emit(const VoiceError('Impossible de comprendre le repas. Réessayez.'));
      return;
    }
    emit(VoicePendingConfirmation(items: items, transcription: trimmed));
  }

  void _onResetRequested(VoiceResetRequested event, Emitter<VoiceState> emit) {
    emit(const VoiceInitial());
  }
}
