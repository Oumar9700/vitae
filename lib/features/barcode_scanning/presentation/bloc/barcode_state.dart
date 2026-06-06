part of 'barcode_bloc.dart';

abstract class BarcodeState extends Equatable {
  const BarcodeState();
  @override
  List<Object?> get props => [];
}

class BarcodeInitial extends BarcodeState {}

class BarcodeScannerReady extends BarcodeState {}

class BarcodeDetected extends BarcodeState {
  final String code;
  const BarcodeDetected({required this.code});
  @override
  List<Object?> get props => [code];
}

class BarcodeProductLoading extends BarcodeState {}

class BarcodeProductFound extends BarcodeState {
  final Food food;
  const BarcodeProductFound({required this.food});
  @override
  List<Object?> get props => [food.id];
}

class BarcodeProductNotFound extends BarcodeState {
  final String code;
  const BarcodeProductNotFound({required this.code});
  @override
  List<Object?> get props => [code];
}

class BarcodeError extends BarcodeState {
  final String message;
  const BarcodeError({required this.message});
  @override
  List<Object?> get props => [message];
}
