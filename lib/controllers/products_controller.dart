import '../config.dart';
import '../constant.dart';
import '../models/product_model.dart';
import 'package:flutter/material.dart';
import '../utils.dart';

class ProductController {
  static List<Product> productList = [];
  static List<Product> searchProductList = [];

  static int pageNo = 1;
  static int totalData = 0;
  // static int totalPage = 1;
  static int productIndex = -1;
  static int previousPageNo = 1;
  static int totalDataDeleted = 0;
  static int previousTotalData = 0;
  static bool isFirstSearch = false;
  static bool isSearchActive = false;
  static bool isAllDataLoaded = false;
  static bool isAddNewProduct = false;
  static bool isProductEdited = false;
  static bool isProductDeleted = false;
  static bool isEditProductFromDetailPage = false;

  static late TextEditingController prodNameCtrl;
  static late TextEditingController prodDescCtrl;
  static late TextEditingController priceCtrl;
  static late TextEditingController stockCtrl;

  static init({String productName='', String productDesc='', String productPrice='', String productStock=''}) {
    prodNameCtrl = TextEditingController(text: productName);
    prodDescCtrl = TextEditingController(text: productDesc);
    priceCtrl = TextEditingController(text: Utils.formatAmount(value: productPrice));
    stockCtrl = TextEditingController(text: Utils.formatAmount(value: productStock));
    debugPrint('[product_controller] init');
    debugPrint('[product_controller] is edit product from detail page: $isEditProductFromDetailPage');
    // selectedProduct = Product(id: 0, description: 'xx', imagesPath: [], name: 'baju', price: 90, stock: 90);
  }

  static dispose() {
    prodNameCtrl.dispose();
    prodDescCtrl.dispose();
    priceCtrl.dispose();
    stockCtrl.dispose();
  }

  static void addProduct({required Map<String, dynamic> data}) {
    productList.add(Product.fromJson(data: data));
    totalData++;
  }

  static void editProduct({
    required int productId,
    required Map<String, dynamic> newProductData,
  }) {
    /// kondisi setelah data diubah | condition after data has changes:
    /// 1. jika search aktif dan user mengedit data, maka
    ///    data yang ada di searchProductList dan di productList juga diubah
    ///    if search is active & user edit data, then the data in searchProductList & productList should updated
    /// 2. jika search tidak aktif dan user mengedit data, maka hanya data
    ///    yang ada di productList saja yang diubah
    ///    if search is inactive & user edit data, then only the data in productList updated

    final dataSource = isSearchActive ? [searchProductList, productList] : [productList];

    for (int i = 0; i < dataSource.length; i++) {

      int counter = 0;
      for (final prod in dataSource[i]) {
        if (prod.id == productId) {
          dataSource[i][counter] = Product.fromJson(data: newProductData);
          break;
        }
        counter++;
      }

    }

  }

  static void deleteProduct({required int prodId}) {
    isProductDeleted = true;
    totalData--;
    totalDataDeleted++;
    productList.removeWhere((product) => product.id == prodId);
    searchProductList.removeWhere((product) => product.id == prodId);
  }

  static Map<String, Object> getProductDataByIndex({required List<Product> productDataSource}) {
    final oldProduct = {
      "id": productDataSource[productIndex].id,
      "name": productDataSource[productIndex].name,
      "description": productDataSource[productIndex].description,
      "stock": productDataSource[productIndex].stock,
      "price": productDataSource[productIndex].price,
      "images_url": productDataSource[productIndex].imagesPath
    };

    return oldProduct;
  }

  static List<Product> processNewData({required dynamic data}) {
    debugPrint('[product_controller] inserting new data');
    List<Product> result = [];

    for (final product in data) {
      // ProductController.productList.add(Product.fromJson(data: product)); // fail use this method, because List<dynamic> is not sub type of List<String>
      final List<String> imgPath = List<String>.from(product["images_url"]);

      for (int i=0; i < imgPath.length; i++) {
        // add host address in front of image path
        imgPath[i] = "${Config.host}${imgPath[i]}";
      }

      if (isSearchActive) {
        searchProductList.add(Product.fromJson(data: product, imageList: imgPath));
      }
      else {
        productList.add(Product.fromJson(data: product, imageList: imgPath));
      }

      result.add(Product.fromJson(data: product, imageList: imgPath));
    }

    debugPrint('[product_controller] ${result.length} data inserted...');
    return result;
  }
}