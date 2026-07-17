part of '../sport_zone_state.dart';

extension ProductStateActions on SportZoneState {
  // Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬ Products / Categories / Brands (API) Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬

  Future<void> fetchProducts({
    String? categoryId,
    String? brandId,
    int? minPrice,
    int? maxPrice,
    String? gender,
    String? size,
    String? search,
  }) async {
    isLoadingProducts = true;
    notifyStateChanged();

    if (search != null) {
      searchQuery = search.isEmpty ? null : search;
    }

    final result = await ApiService.getProducts(
      limit: 50,
      categoryId: categoryId,
      brandId: brandId,
      minPrice: minPrice,
      maxPrice: maxPrice,
      gender: gender,
      size: size,
      search: searchQuery,
    );

    if (result.isSuccess && result.data != null) {
      final data = result.data as Map<String, dynamic>;
      final items = data['items'] as List<dynamic>? ?? [];
      apiProducts = items
          .map((json) => Product.fromJson(json as Map<String, dynamic>))
          .toList();
    }

    isLoadingProducts = false;
    notifyStateChanged();
  }

  Future<void> fetchCategories() async {
    final result = await ApiService.getCategories();
    if (result.isSuccess && result.data != null) {
      final list = result.data as List<dynamic>;
      apiCategories = list
          .map((json) => Category.fromJson(json as Map<String, dynamic>))
          .toList();
      notifyStateChanged();
    }
  }

  Future<void> fetchBrands() async {
    final result = await ApiService.getBrands();
    if (result.isSuccess && result.data != null) {
      final list = result.data as List<dynamic>;
      apiBrands = list
          .map((json) => Brand.fromJson(json as Map<String, dynamic>))
          .toList();
      notifyStateChanged();
    }
  }

  // Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬ Category / Cart / Chat / Notifications Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬

  void selectCategory(String value, {String? categoryId}) {
    selectedCategory = value;
    selectedCategoryId = categoryId;
    fetchProducts(
      categoryId: categoryId,
      brandId: selectedBrandId,
      minPrice: filterMinPrice,
      maxPrice: filterMaxPrice,
      gender: filterGender,
      size: filterSize,
    );
  }

  void selectBrand(String value, {String? brandId}) {
    selectedBrand = value;
    selectedBrandId = brandId;
    fetchProducts(
      categoryId: selectedCategoryId,
      brandId: brandId,
      minPrice: filterMinPrice,
      maxPrice: filterMaxPrice,
      gender: filterGender,
      size: filterSize,
    );
  }

  void applyFilters({
    int? minPrice,
    int? maxPrice,
    String? gender,
    String? size,
    String? categoryName,
    String? categoryId,
    String? brandName,
    String? brandId,
  }) {
    filterMinPrice = minPrice;
    filterMaxPrice = maxPrice;
    filterGender = gender;
    filterSize = size;

    if (categoryName != null) {
      selectedCategory = categoryName;
      selectedCategoryId = categoryId;
    }
    if (brandName != null) {
      selectedBrand = brandName;
      selectedBrandId = brandId;
    }

    fetchProducts(
      categoryId: selectedCategoryId,
      brandId: selectedBrandId,
      minPrice: filterMinPrice,
      maxPrice: filterMaxPrice,
      gender: filterGender,
      size: filterSize,
    );
  }
}
