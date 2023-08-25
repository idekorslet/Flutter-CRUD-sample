class FilterController {
  static bool isFilterActive = false;
  static bool isFilterCanceled = false;
  static Map<String, dynamic> filterData = {};
  static String lastFilterParamValue = "";
  static String newFilterParamValue = "";
  static bool isFilterChanged = false;
  static List<bool> _sortStock = [false, false];
  static List<bool> _sortPrice = [false, false];

  static setActiveSortData({required List<bool> data, bool isChangeSortStock = true}) {
    if (isChangeSortStock) {
      _sortStock = data;
    }
    else {
      _sortPrice = data;
    }
  }

  static String _setOrderValue({required bool isAscending, required bool isDescending}) {
    return isAscending ? "asc" : (isDescending ? "desc" : ""); // result: "asc", "desc", ""
  }

  static bool hasFilterChanged() {
    isFilterChanged = lastFilterParamValue != newFilterParamValue;
    return isFilterChanged;
  }

  static void setFilterData(bool showEmptyStock) {
    String sortBy = "sortby=";

    String stockSortMethod = _setOrderValue(isAscending: _sortStock[0], isDescending: _sortStock[1]);
    String priceSortMethod = _setOrderValue(isAscending: _sortPrice[0], isDescending: _sortPrice[1]);

    if (showEmptyStock) {
      stockSortMethod = "";
    }

    if (stockSortMethod.isNotEmpty) {
      sortBy += "stock-$stockSortMethod";
      stockSortMethod += "-$stockSortMethod";
    }

    if (priceSortMethod.isNotEmpty) {
      sortBy += stockSortMethod.isEmpty ? "price" : "_price";
      sortBy += "-$priceSortMethod";
    }

    if (stockSortMethod.isEmpty && priceSortMethod.isEmpty && showEmptyStock == false) {
      isFilterActive = false;
    }
    else {
      isFilterActive = true;
    }

    newFilterParamValue = "&filter=$isFilterActive&only-empty-stock=$showEmptyStock&$sortBy";
  }

  static void saveNewFilterData(bool showEmptyStock) {
    if (showEmptyStock) {
      _sortStock = [false, false];
    }

    filterData = {
      "isFilterActive": isFilterActive,
      "isEmptyStockOnly": showEmptyStock,
      "stockSortData": _sortStock,
      "priceSortData": _sortPrice,
      "filterParamValue": newFilterParamValue
    };

    lastFilterParamValue = newFilterParamValue;
  }

  static void resetFilter() {
    isFilterActive = false;
    lastFilterParamValue = "";
    newFilterParamValue = "";
    _sortStock = [false, false];
    _sortPrice = [false, false];
  }
}