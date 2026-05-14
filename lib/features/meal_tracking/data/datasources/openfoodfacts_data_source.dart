import 'dart:io';
import 'package:openfoodfacts/openfoodfacts.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/services/logger_service.dart';
import '../models/food_model.dart';

abstract class OpenFoodFactsDataSource {
  Future<List<FoodModel>> searchFood(String query);
  Future<FoodModel?> getProductByBarcode(String barcode);
}

class OpenFoodFactsDataSourceImpl implements OpenFoodFactsDataSource {
  static const _searchFields = [
    ProductField.BARCODE,
    ProductField.NAME,
    ProductField.NAME_IN_LANGUAGES,
    ProductField.GENERIC_NAME,
    ProductField.BRANDS,
    ProductField.NUTRIMENTS,
    ProductField.SELECTED_IMAGE,
    ProductField.IMAGE_FRONT_URL,
    ProductField.IMAGE_FRONT_SMALL_URL,
  ];

  @override
  Future<List<FoodModel>> searchFood(String query) async {
    try {
      final configuration = ProductSearchQueryConfiguration(
        parametersList: [
          SearchTerms(terms: [query]),
          const PageNumber(page: 1),
          const PageSize(size: 25),
          SortBy(option: SortOption.POPULARITY),
        ],
        language: OpenFoodFactsLanguage.FRENCH,
        country: OpenFoodFactsCountry.FRANCE,
        fields: _searchFields,
        version: ProductQueryVersion.v3,
      );

      final result = await OpenFoodAPIClient.searchProducts(null, configuration);

      AppLogger.d('${result.products?.length ?? 0} products found for "$query"', 'OpenFoodFacts');
      AppLogger.d('First: ${result.products?.firstOrNull?.productName ?? "none"}', 'OpenFoodFacts');
      return (result.products ?? [])
          .map((p) => FoodModel.fromProduct(p))
          .where((f) => f.nom.isNotEmpty)
          .take(15)
          .toList();
    } on SocketException {
      throw const NetworkException();
    } catch (_) {
      throw const ServerException('Erreur de recherche d\'aliment.');
    }
  }

  @override
  Future<FoodModel?> getProductByBarcode(String barcode) async {
    try {
      final configuration = ProductQueryConfiguration(
        barcode,
        language: OpenFoodFactsLanguage.FRENCH,
        country: OpenFoodFactsCountry.FRANCE,
        fields: [ProductField.ALL],
        version: ProductQueryVersion.v3,
      );

      final result = await OpenFoodAPIClient.getProductV3(configuration);
      if (result.product == null) return null;
      return FoodModel.fromProduct(result.product!);
    } on SocketException {
      throw const NetworkException();
    } catch (_) {
      throw const ServerException();
    }
  }
}
