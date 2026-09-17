import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../seller_inventory/domain/entities/product.dart';
import 'shopping_providers.dart';

part 'search_providers.g.dart';

@riverpod
class SearchQuery extends _$SearchQuery {
  @override
  String build() => '';

  void updateQuery(String query) {
    state = query;
  }
}

@riverpod
class SelectedCategory extends _$SelectedCategory {
  @override
  String? build() => null;

  void selectCategory(String? category) {
    state = category;
  }
}

@riverpod
List<Product> filteredProducts(Ref ref) {
  final products = ref.watch(buyerProductsProvider).value ?? [];
  final query = ref.watch(searchQueryProvider).trim().toLowerCase();
  final selectedCategory = ref.watch(selectedCategoryProvider);

  return products.where((product) {
    final matchesQuery = query.isEmpty || 
        product.name.toLowerCase().contains(query) ||
        product.description.toLowerCase().contains(query);
    
    final matchesCategory = selectedCategory == null || 
        product.category == selectedCategory;

    return matchesQuery && matchesCategory;
  }).toList();
}
