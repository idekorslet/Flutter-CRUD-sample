import 'package:flutter/material.dart';
import 'package:flutter_crud/pages/products/edit_product.dart';
import 'package:flutter_crud/pages/products/fullscreen_image.dart';
import 'package:flutter_crud/pages/products/my_products.dart';
import 'package:flutter_crud/pages/products/new_product.dart';
import 'package:flutter_crud/pages/products/product_description.dart';
import 'package:flutter_crud/pages/products/product_detail.dart';
import 'package:flutter_crud/pages/products/search_product.dart';

/// useful example reference about route: https://stackoverflow.com/a/60939874/22171100

enum PageName {
  newProduct, home, productDetail, productDescription, searchProduct, editProduct, fullscreenImage
}

class Routes {
  static moveToPage({
    required BuildContext context,
    bool keepPrevPage=true,
    required PageName pageName,
    dynamic data,
    Function? setState
  }) async {
    /// reference: https://stackoverflow.com/a/61534096/22171100
    ///  SchedulerBinding used to wait for completing the state before navigating to another screen

    // SchedulerBinding.instance.addPostFrameCallback((_) {
      await Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
            builder: (BuildContext ctx) => _getPageClassName(pageName: pageName, data: data)
        ),
        (Route<dynamic> route) => keepPrevPage, // if you want to disable back feature set to false
      ).then((value) {
        if (setState != null) {
          setState(() {

          });
        }

      });
  }

  static backToPreviousPage(BuildContext context) {
    // Navigator.pop(context);
    Navigator.of(context, rootNavigator: true).pop();
  }

  static _getPageClassName({required PageName pageName, dynamic data}) {
    switch (pageName) {
      case PageName.newProduct:
        return const NewProduct();
      case PageName.editProduct:
        // return EditProduct(oldProductData: data as Product);
        return const EditProduct();
      case PageName.searchProduct:
        return const SearchProduct();
      case PageName.home:
        return const MyProducts();
      case PageName.productDetail:
        return ProductDetailNew();
      case PageName.fullscreenImage:
        return FullScreenImage(data: data as Map);
      case PageName.productDescription:
        return ProductDescription(data: data as Map);
    }
  }
}