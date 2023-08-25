import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_crud/custom_widgets/input_form_builder.dart';
import '../../config.dart';
import '../../constant.dart';
import '../../controllers/infinite_scroll_controller.dart';
import '../../controllers/products_controller.dart';
import '../../custom_widgets/custom_popup.dart';
import '../../draggable_images_picker.dart';
import '../../models/product_model.dart';
import '../../routes.dart';
import '../../services/image_uploader.dart';
import '../../utils.dart';


class ProductBaseScreen extends StatefulWidget {
  final String title;
  final String cancelText;
  final bool isEditData;

  const ProductBaseScreen({
    Key? key,
    this.title = "Add Product",
    this.cancelText = "Are you sure to cancel add new product?",
    this.isEditData = false,
  }) : super(key: key);

  @override
  State<ProductBaseScreen> createState() => _ProductBaseScreenState();
}

class _ProductBaseScreenState extends State<ProductBaseScreen> {
  bool _isEditProduct = false;
  late Product _oldProductData;
  int _lastImageCount = 0;
  int _productId = -1;
  late List<String> prevImagesUrls;
  bool isInitializing = true;
  late DraggableImagesPicker draggableImagesPicker;

  Future<void> onInit(
  // required String title,
  // required String cancelText
  ) async {
    debugPrint('[product_base_screen] init');

    _isEditProduct = widget.isEditData;

    if (_isEditProduct) {
      debugPrint('[product_base_screen] Edit product');
      final productIndex = ProductController.productIndex;

      _oldProductData = ProductController.isSearchActive
          ? ProductController.searchProductList[productIndex]
          : ProductController.productList[productIndex];

      _lastImageCount = _oldProductData.imagesPath.length;
      _productId = _oldProductData.id;

      List<String> imagesString = [];
      prevImagesUrls = [];
      for (final cacheImageUrl in _oldProductData.imagesPath) {
        prevImagesUrls.add(cacheImageUrl);
        imagesString.add(await Utils.getImagePathFromCache(cacheImageUrl));
      }

      if (context.mounted) {
        draggableImagesPicker = DraggableImagesPicker(
            localContext: context,
            imageStringList: imagesString
        );
      }

      ProductController.init(
          productName: _oldProductData.name,
          productDesc: _oldProductData.description,
          productPrice: _oldProductData.price.toString(),
          productStock: _oldProductData.stock.toString()
      );
    }
    else {
      debugPrint('[product_base_screen] add new product');
      /// input new product
      draggableImagesPicker = DraggableImagesPicker(localContext: context);
      ProductController.init();
    }

    draggableImagesPicker.init(setState);

    // CustomTextFieldController.init(totalTextField: 4);
    isInitializing = false;
    debugPrint('[product_base_screen] init done');
    setState(() {

    });
  }

  @override
  void initState() {
    super.initState();
    onInit();
  }

  @override
  void dispose() {
    draggableImagesPicker.dispose();
    ProductController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isInitializing) {
      return const Scaffold(
        body: Center(
          child: Text('Loading'),
        ),
      );
    }

    return _buildWidget();
  }

  Widget _buildWidget() {
    /// cek jumlah image yang ada di image picker apakah ada perbedaan dengan lastImageCount
    /// jika ada perbedaan berarti image ditambah atau di hapus sebagian

    if (draggableImagesPicker.images.length != _lastImageCount || draggableImagesPicker.isPositionChanged) {
      _lastImageCount = draggableImagesPicker.images.length;
    }

    draggableImagesPicker.onWidgetRebuild();

    return SafeArea(
      child: WillPopScope(
        onWillPop: () async {
          _back().then((value) {
            if (value) {
              Routes.backToPreviousPage(context);
            }
          });

          return false;
        },
        child: Scaffold(
            appBar: AppBar(
              leading: InkWell(
                /// back button,
                onTap: () {
                  _back().then((value) {
                    if (value) {
                      Routes.backToPreviousPage(context);
                    }
                  });
                },
                child: const Icon(
                  Icons.arrow_back,
                  color: Colors.black54,
                ),
              ),

              title: Text(widget.title),
              actions: [
                /// ================== check / save button =================
                IconButton.filledTonal(
                    onPressed: () {
                      saveProduct();
                    },
                    icon: const Icon(Icons.check)
                ),
                const SizedBox(width: 10,)
              ],
            ),
            body: _buildProductView()
        ),
      ),
    );
  }

  Future<bool> _back() async {
    return await CustomPopup.showConfirmPopup(
        context: context,
        title: "Cancel",
        content: widget.cancelText,
        cancelButtonText: 'No',
        confirmButtonText: 'Yes'
    ).then((value) {
      Utils.hideKeyboard();
      return value;
    })
    .whenComplete(() {
      debugPrint('[product_base_screen2] after popup executed');
      ProductController.isProductEdited = false;
      ProductController.isAddNewProduct = false;
    });
  }

  Future<void> saveProduct() async {
    InputValidatorHelper.checkValidation();

    if (InputValidatorHelper.isInputValid) {

      if (draggableImagesPicker.images.isEmpty) {
        CustomPopup.showDefaultPopup(
            title: 'Warning',
            content: 'Please add at least 1 product image',
            context: context
        );
      }
      else {
        /// cek response dari server:
        /// jika masih memproses, tampilkan circular progress indicator
        /// jika sukses, tampilkan pesan sukses

        Utils.hideKeyboard();
        CustomPopup.showProcessLoading(context: context);

        /// send data to server and wait for the response
        /// if status is create new data, then wait for the product id after data successfully created
        /// if status is edit data, then product id taken from the selected product

        final stock = int.parse(Utils.removeAllCharExceptNumbers(
            currencyString: ProductController.stockCtrl.text));
        final price = int.parse(Utils.removeAllCharExceptNumbers(
            currencyString: ProductController.priceCtrl.text));

        final productId = _isEditProduct ? _productId.toString() : "-1";

        final dataForServer = {
          "token": Config.token,
          "sellerId": Config.sellerId,
          "productId": productId,
          "productName": ProductController.prodNameCtrl.text,
          "description": ProductController.prodDescCtrl.text,
          "stock": stock.toString(),
          "price": price.toString(),
        };

        bool isEditImage = false;

        if (draggableImagesPicker.isImageChanged()) {
          // print('image changed');
          if (_isEditProduct) {
            isEditImage = true;
          }
        }
        else {
          // print('image not changed');
        }

        // set image data for images property/field in ImageUploader class
        ImageUploader.images = draggableImagesPicker.images;

        // send data to the server and save the result into uploadStatus variable
        final uploadStatus = await ImageUploader.uploadImage(
            data: dataForServer,
            method: _isEditProduct ? Method.put : Method.create,
            isEditImage: isEditImage
        );

        final Map<String, dynamic> uploadStatusData = jsonDecode(uploadStatus);
        // print('uploadStatusData');
        // print(uploadStatusData);

        // uploadStatusData sample output:
        // {
        //    error: false,
        //    message: ,
        //    statusCode: 200,
        //    data:
        //    {
        //        "info":"OK",
        //        "product_id":310,
        //        "total_image_processed":1,
        //        "images_url":["www/html/uploads/data/sellers/29/products/174/images/IMG_20230717_204212.jpg"]
        //    }
        // }

        final isSaveDataOk = !uploadStatusData["error"];
        final String responseString = uploadStatusData["data"];

        String popUpTitle = 'Success';
        String popUpContent = _isEditProduct ? 'Edit data successfully' : 'New data saved';

        if (isSaveDataOk) {
          // dev_log.log('[product_base_screen]');
          // dev_log.log(responseString);
          debugPrint('[product_base_screen]');
          debugPrint(responseString);
        }
        else {
          final message = uploadStatusData["message"];
          popUpTitle = message == "No data updated" ? 'Warning' : 'Failed';
          popUpContent = message == "No data updated" ? message : 'Failed to save data \n$message';
          popUpContent += '\n Status code: ${uploadStatusData["statusCode"]}';
        }

        if (context.mounted) {

          Navigator.of(context).pop(); // close the loading process popup

          CustomPopup.showDefaultPopup(title: popUpTitle, content: popUpContent, context: context)
              .then((value) {
            if (isSaveDataOk) {

              try {
                final data = jsonDecode(responseString) as Map<String, dynamic>;

                final List<String> imagesUrl = [];

                if (_isEditProduct == false ||
                    (_isEditProduct && isEditImage)) {

                  /// if add new product or (edit product and image is edited), then
                  /// add new image url into imagesUrl variable
                  for (final img in data["images_url"]) {
                    imagesUrl.add('${Config.host}/$img');
                  }

                  /// ketika data disimpan dan posisi sedang mengedit data & image di edit
                  /// cek apakah image yang lama sudah tidak ada di daftar image yang baru
                  /// jika tidak ada lagi, maka hapus image lama dari image cache

                  /******************** remove unexists image in previous image from image cache  ***********************/
                  if (_isEditProduct && isEditImage) {
                    // int counter = 0;
                    for (final oldImg in prevImagesUrls) {
                      // counter++;
                      // print('$counter: $oldImg');
                      if (imagesUrl.contains(oldImg) == false) {
                        // print('$counter - image not exists anymore');
                        CachedNetworkImage.evictFromCache(oldImg);
                      }
                    }
                  }
                }
                else {
                  /// if product edited but image not edited, then imagesUrl value taken from old image
                  imagesUrl.addAll(prevImagesUrls);
                }

                final newProductData = {
                  "id": _isEditProduct ? _productId : data["product_id"],
                  // if edit data, then id taken from old id, else id taken from server feedback
                  "name": ProductController.prodNameCtrl.text,
                  "description": ProductController.prodDescCtrl.text,
                  "stock": stock,
                  "price": price,
                  "images_url": imagesUrl
                };

                /// move to another page after save data
                if (_isEditProduct) {
                  ProductController.isProductEdited = true;

                  ProductController.editProduct(
                    productId: _productId,
                    newProductData: newProductData,
                  );

                  Routes.backToPreviousPage(context);
                }
                else {
                  // add new data into product model
                  ProductController.addProduct(data: newProductData);

                  // add new data into pagingController item list
                  InfiniteScrollController.pagingController.itemList?.add(Product.fromJson(data: newProductData));

                  Routes.moveToPage(
                      context: context,
                      pageName: PageName.home,
                      keepPrevPage: false
                  );
                }
              } catch (error) {
                debugPrint('[product_base_screen] error: $error');
                CustomPopup.showDefaultPopup(title: 'Error', content: error.toString(), context: context);
              }

            }
          }); // end then

        }
      }
    }
  }

  _buildProductView() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 14.0, top: 10),
            child: Text('Product Images'),
          ),
          const SizedBox(height: 8,),
          Center(
            child: draggableImagesPicker.wrappedImages,
          ),

          const InputFormBuilder()

        ],
      ),
    );
  }

}
