import 'package:dio/dio.dart';
import '../../../../core/error/exceptions.dart';
import '../models/food_model.dart';

abstract class OpenFoodFactsDataSource {
  Future<List<FoodModel>> searchFood(String query);
  Future<FoodModel?> getProductByBarcode(String barcode);
}

class OpenFoodFactsDataSourceImpl implements OpenFoodFactsDataSource {
  final Dio _dio;

  OpenFoodFactsDataSourceImpl({required Dio dio}) : _dio = dio;

  @override
  Future<List<FoodModel>> searchFood(String query) async {
    try {
      final response = await _dio.get(
        'https://world.openfoodacts.org/cgi/search.pl',
        queryParameters: {
          'search_terms': query,
          'search_simple': 1,
          'action': 'process',
          'json': 1,
          'fields': 'code,product_name,product_name_fr,brands,nutriments,image_front_url,generic_name',
          'page_size': 20,
        },
      );

      final products = (response.data['products'] as List<dynamic>?) ?? [];
      return products
          .map((p) => FoodModel.fromOpenFoodFacts(p as Map<String, dynamic>))
          .where((f) => f.nom.isNotEmpty && f.caloriesPer100g > 0)
          .take(15)
          .toList();
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.connectionError) {
        throw const NetworkException();
      }
      throw const ServerException('Erreur de recherche d\'aliment.');
    }
  }

  @override
  Future<FoodModel?> getProductByBarcode(String barcode) async {
    try {
      final response = await _dio.get(
        'https://world.openfoodacts.org/api/v0/product/$barcode.json',
      );
      if (response.data['status'] == 0) return null;
      final product = response.data['product'] as Map<String, dynamic>;
      return FoodModel.fromOpenFoodFacts(product);
    } on DioException {
      throw const ServerException();
    }
  }
}
