import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../meal_tracking/domain/entities/food.dart';
import '../../../meal_tracking/domain/repositories/meal_repository.dart';

part 'barcode_event.dart';
part 'barcode_state.dart';

class BarcodeBloc extends Bloc<BarcodeEvent, BarcodeState> {
  final MealRepository _mealRepository;

  BarcodeBloc({required MealRepository mealRepository})
      : _mealRepository = mealRepository,
        super(BarcodeInitial()) {
    on<BarcodeStartRequested>(_onStart);
    on<BarcodeCodeDetected>(_onCodeDetected);
    on<BarcodeRetryRequested>(_onRetry);
  }

  void _onStart(BarcodeStartRequested event, Emitter<BarcodeState> emit) {
    emit(BarcodeScannerReady());
  }

  Future<void> _onCodeDetected(
      BarcodeCodeDetected event, Emitter<BarcodeState> emit) async {
    emit(BarcodeDetected(code: event.code));
    emit(BarcodeProductLoading());

    final result = await _mealRepository.getFoodById(event.code);
    result.fold(
      (failure) => emit(BarcodeError(message: failure.message)),
      (food) {
        if (food == null || food.nom.trim().isEmpty) {
          emit(BarcodeProductNotFound(code: event.code));
        } else {
          emit(BarcodeProductFound(food: food));
        }
      },
    );
  }

  void _onRetry(BarcodeRetryRequested event, Emitter<BarcodeState> emit) {
    emit(BarcodeScannerReady());
  }
}
