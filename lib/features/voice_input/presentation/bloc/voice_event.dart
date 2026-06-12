part of 'voice_bloc.dart';

sealed class VoiceEvent extends Equatable {
  const VoiceEvent();
  @override
  List<Object?> get props => [];
}

final class VoiceParseRequested extends VoiceEvent {
  final String transcription;
  const VoiceParseRequested(this.transcription);
  @override
  List<Object?> get props => [transcription];
}

final class VoiceResetRequested extends VoiceEvent {
  const VoiceResetRequested();
}
