part of 'voice_bloc.dart';

sealed class VoiceState extends Equatable {
  const VoiceState();
  @override
  List<Object?> get props => [];
}

final class VoiceInitial extends VoiceState {
  const VoiceInitial();
}

final class VoiceParsing extends VoiceState {
  const VoiceParsing();
}

final class VoicePendingConfirmation extends VoiceState {
  final List<ParsedMealItem> items;
  final String transcription;
  const VoicePendingConfirmation({required this.items, required this.transcription});
  @override
  List<Object?> get props => [items, transcription];
}

final class VoiceError extends VoiceState {
  final String message;
  const VoiceError(this.message);
  @override
  List<Object?> get props => [message];
}
