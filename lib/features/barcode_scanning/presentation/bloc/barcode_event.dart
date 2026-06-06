part of 'barcode_bloc.dart';

abstract class BarcodeEvent extends Equatable {
  const BarcodeEvent();
  @override
  List<Object?> get props => [];
}

class BarcodeStartRequested extends BarcodeEvent {
  const BarcodeStartRequested();
}

class BarcodeCodeDetected extends BarcodeEvent {
  final String code;
  const BarcodeCodeDetected(this.code);
  @override
  List<Object?> get props => [code];
}

class BarcodeRetryRequested extends BarcodeEvent {
  const BarcodeRetryRequested();
}
