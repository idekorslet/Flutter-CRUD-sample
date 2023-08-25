import 'package:flutter_crud/pages/products/product_base_screen.dart';

class EditProduct extends ProductBaseScreen {
  const EditProduct({
    super.key,
    super.title= 'Edit Product',
    super.cancelText = "Are you sure to cancel edit product?",
    super.isEditData = true
  });
}
