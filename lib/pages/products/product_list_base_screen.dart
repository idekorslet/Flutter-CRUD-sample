import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_crud/controllers/infinite_scroll_controller.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import '../../config.dart';
import '../../constant.dart';
import '../../controllers/products_controller.dart';
import '../../custom_widgets/custom_image_container.dart';
import '../../custom_widgets/custom_popup.dart';
import '../../custom_widgets/info_container.dart';
import '../../models/product_model.dart';
import '../../payload.dart';
import '../../routes.dart';
import '../../services/api.dart';
import '../../utils.dart';

class ProductListBaseScreen extends StatefulWidget {
  final PagingController<int, Product> pagingCtrl;
  final List<Product> dataSource;
  final Function refreshUIFunction;

  const ProductListBaseScreen({
    Key? key,
    required this.pagingCtrl,
    required this.dataSource,
    required this.refreshUIFunction
  }) : super(key: key);

  @override
  State<ProductListBaseScreen> createState() => _ProductListBaseScreenState();
}

class _ProductListBaseScreenState extends State<ProductListBaseScreen> {

  @override
  void initState() {
    super.initState();
    debugPrint('[product_list_base_screen] initializing...');
  }

  @override
  Widget build(BuildContext context) {
    if (ProductController.isSearchActive && ProductController.isFirstSearch) {
      return _buildEmptyView(showEmptyText: false);
    }

    debugPrint('[product_list_base_screen] data source length: ${widget.dataSource.length} / paging data length: ${widget.pagingCtrl.itemList?.length}');

    return _buildProductView();
  }

  Widget _buildEmptyView({bool showEmptyText=true}) {
    return Container(
      alignment: Alignment.center,
      // height: screenHeight - appBarHeight,
      // decoration: BoxDecoration(
      //     border: Border.all(color: Colors.red)
      // ),
      child:
      Text(showEmptyText ? 'No data' : '',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)
      ),
    );
  }

  Widget _buildProductView() {
    /** ============================== Product Grid List =====================================
     * 1. - nilai aspec ratio yang ada di SliverGridDelegateWithFixedCrossAxisCount
     *    mempengaruhi ukuran (tinggi) dari card
     *    - the aspec ratio value in SliverGridDelegateWithFixedCrossAxisCount
     *    affected the card height size
     *
     * */

    return PagedGridView(
      showNewPageProgressIndicatorAsGridChild: false,
      showNoMoreItemsIndicatorAsGridChild: false,
      showNewPageErrorIndicatorAsGridChild: false,
      pagingController: widget.pagingCtrl,
      builderDelegate: PagedChildBuilderDelegate(
        itemBuilder: (BuildContext context, item, int index) {
          return _buildProductContainer(productIndex: index);
        },

        noMoreItemsIndicatorBuilder: (_) {
          return Center(
            child: InfoContainer(
                title: 'All data loaded',
                width: 150,
                height: 26,
                bottomPadding: 4,
                topMargin: 4,
                bottomMargin: 8,
                fontSize: 16
            ),
          );
        },

      ),

      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        // mainAxisSpacing: 2,
        // crossAxisSpacing: 2,
        childAspectRatio: 0.8, /// set the aspect ratio to change the card height
      ),
    );

  }

  Widget _buildProductContainer({required int productIndex}) {
    final price = Utils.formatAmount(value: widget.dataSource[productIndex].price.toString());
    final imgLocation = widget.dataSource[productIndex].imagesPath[0];
    final productName = widget.dataSource[productIndex].name;
    final stock = widget.dataSource[productIndex].stock;

    /// ======================== on tap product =========================
    return InkWell(
      borderRadius: const BorderRadius.all(Radius.circular(10)),
      onTap: () {
        ProductController.productIndex = productIndex;

        Routes.moveToPage(
            context: context,
            pageName: PageName.productDetail,
            setState: setState
        );
      },
      child: Padding(
        padding: EdgeInsets.only(bottom: 2, top: productIndex < 2 ? 4 : 0),
        child: Card(
          child: Stack(
            children: [
              Column(
                // mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  /// =================== product image =======================
                  Expanded(child: CustomImageContainer(imageLocation: imgLocation)),

                  /// ================== product name, price and stock ================
                  Container(
                    padding: const EdgeInsets.only(left: 4, right: 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// ============ product name ==================
                        Text(
                          productName,
                          style: const TextStyle(fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),

                        /// ============ product price ==================
                        Text(
                          'Rp$price',
                          style: const TextStyle(fontSize: 12),
                        ),

                        SizedBox(
                          height: 24,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              /// ============ product stock ==================
                              Text(
                                'Stock: $stock',
                                style: const TextStyle(fontSize: 12),
                              ),
                              const Expanded(child: SizedBox()),

                              /// =================== more icon / popup menu for edit or delete ========================
                              _buildPopUpMenu(productIndex: productIndex)
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              _buildProductNumberContainer(productIndex + 1)
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductNumberContainer(int productNo) {
    return Container(
      width: productNo < 100 ? 20 : (productNo < 1000 ? 30 : 40),
      height: 22,
      // child: ProductNumberContainer(productNo: productNo),
      decoration: BoxDecoration(
        gradient: LinearGradient(
            colors: [
              Colors.greenAccent.withOpacity(.6),
              Colors.green.withOpacity(.8),
            ]
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(8),
          bottomRight: Radius.circular(10),
        ),
      ),
      child: Center(child: Text(productNo.toString(), style: const TextStyle(fontSize: 12),)),
    );
  }

  PopupMenuButton<String> _buildPopUpMenu({required int productIndex}) {
    return PopupMenuButton<String>(
      offset: const Offset(0, -80),
      itemBuilder: (context) {
        return [
          const PopupMenuItem(
            value: 'edit',
            child: Text('edit'),
          ),

          const PopupMenuItem(
            value: 'delete',
            child: Text('delete'),
          ),
        ];
      },
      onSelected: (selectedValue) async {
        final productId = widget.dataSource[productIndex].id;

        // print('selected value is $selectedValue');
        if (selectedValue == 'delete') {
          CustomPopup.showConfirmPopup(
              context: context,
              title: "Delete confirm",
              content: "Are you sure to delete the selected product?",
              cancelButtonText: 'No',
              confirmButtonText: 'Yes'
          ).then((value) async {
            if (value) {

              final payload = Payload.deletePayload(
                  sellerId: Config.sellerId,
                  token: Config.token,
                  productId: productId.toString()
              );

              final deleteStatusData = await ApiService.postData(
                  apiUrl: Config.host + Constant.deleteUrl,
                  dataToSend: payload
              );

              // print('payload');
              // print(payload);
              // print('[product_list_base_screen] deleteStatusData');
              // print(deleteStatusData);

              final isDeleteOk = deleteStatusData["info"] == "OK";

              String popUpTitle = 'Success';
              String popUpContent = 'Product deleted successfully';

              if (isDeleteOk) {
                debugPrint('[my_products] ${deleteStatusData["info"]}');

                /// remove image from image cache after product deleted
                final deletedImages = widget.dataSource[productIndex].imagesPath;
                for (final img in deletedImages) {
                  CachedNetworkImage.evictFromCache(img);
                }

                ProductController.deleteProduct(prodId: productId);
                debugPrint('[product_list_base_screen] total data after data deleted: ${ProductController.totalData}');

                ProductController.productList.clear();
                InfiniteScrollController.pagingController.itemList?.clear();
                ProductController.searchProductList.clear();
                InfiniteScrollController.pagingSearchController.itemList?.clear();

                /// reload data from page 1 after delete data
                ProductController.pageNo = 1;
                await ApiService.getDataFromServer(pagingController: widget.pagingCtrl);
                widget.refreshUIFunction(() {});
              }
              else {
                popUpTitle = 'Failed';
                popUpContent = 'Failed to delete product';
              }

              if (context.mounted) {
                CustomPopup.showDefaultPopup(title: popUpTitle, content: popUpContent, context: context);
              }

            }
          })
          .whenComplete(() {
            debugPrint('[product_list_base_screen] after delete pop up complete executed');
            setState(() {

            });
          });
        }
        else {
          /// move to edit page
          ProductController.isEditProductFromDetailPage = false;
          ProductController.productIndex = productIndex;

          Routes.moveToPage(
              context: context,
              pageName: PageName.editProduct,
              setState: setState
          );

        }
      },
      child: const Icon(Icons.more_vert),
    );
  }

}