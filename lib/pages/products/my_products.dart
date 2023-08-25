import 'package:flutter/material.dart';
import 'package:flutter_crud/controllers/infinite_scroll_controller.dart';
import 'package:flutter_crud/custom_widgets/info_container.dart';
import 'package:flutter_crud/pages/products/product_filter.dart';
import 'package:flutter_crud/pages/products/product_list_base_screen.dart';
import 'package:flutter_crud/services/api.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../controllers/product_filter_controller.dart';
import '../../controllers/products_controller.dart';
import '../../routes.dart';

/// page to view list of products

class MyProducts extends StatefulWidget {
  const MyProducts({Key? key}) : super(key: key);

  @override
  State<MyProducts> createState() => _MyProductsState();
}

class _MyProductsState extends State<MyProducts> {
  String myProductTitle = 'My Products';
  double screenHeight = 100;
  double screenWidth = 100;
  double appBarHeight = 40;
  bool _isLoading = false;
  DateTime? currentBackPressTime;

  @override
  void dispose() {
    debugPrint('[my_products] dispose executed');
    // InfiniteScrollController.pagingController.dispose();
    // InfiniteScrollController.pagingSearchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    debugPrint('[my_products] on init called');
    ProductController.isAddNewProduct = false;
    // ProductController.pageNo = 0;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _refreshData();
    });

    InfiniteScrollController.pagingController.addPageRequestListener((pageKey) async {
      await Future.delayed(const Duration(milliseconds: 500));
      if (_isLoading == false) {
        ProductController.pageNo++;

        debugPrint('[my_products] pagingController.addPageRequestListener executed');
        await _loadDataFromServer();
        _isLoading = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    appBarHeight = AppBar().preferredSize.height;

    return SafeArea(
      child: WillPopScope(
        onWillPop: () {
          return _exitConfirm();
        },
        child: Scaffold(
          appBar: _buildAppBar(context),
          /// ditambahkan pengecekan kondisi ProductController.isAddNewProduct / ProductController.isSearchActive
          /// karena jika tidak ditambahkan kondisi, ketika input data baru UI yang ada
          /// di my products akan ke refresh juga
          body: ProductController.isAddNewProduct || ProductController.isSearchActive
            ? null
            : RefreshIndicator(
              onRefresh: _refreshData,
              child: _buildMyProductList()
          ),
        ),
      ),
    );
  }

  Future<bool> _exitConfirm() {
    DateTime now = DateTime.now();
    if (currentBackPressTime == null || now.difference(currentBackPressTime!) > const Duration(seconds: 2)) {
      currentBackPressTime = now;
      Fluttertoast.showToast(msg: "Press again to exit");

      return Future.value(false);
    }
    return Future.value(true);
  }

  ProductListBaseScreen _buildMyProductList() {
    final myProductsView = ProductListBaseScreen(
      pagingCtrl: InfiniteScrollController.pagingController,
      dataSource: ProductController.productList,
      refreshUIFunction: setState
    );

    return myProductsView;
  }

  Future<void> _refreshData() async {
    ProductController.pageNo = 1;
    ProductController.productList = [];
    ProductController.searchProductList = [];
    InfiniteScrollController.pagingController.value.itemList?.clear();

    await _loadDataFromServer();
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      title: _buildAppBarTitle(),
      actions: [
        /// ====================== search button ========================
        IconButton(
            onPressed: () {
              ProductController.previousPageNo = ProductController.pageNo;
              ProductController.previousTotalData = ProductController.totalData;
              ProductController.totalDataDeleted = 0;
              ProductController.isSearchActive = true;
              ProductController.isFirstSearch = true;
              ProductController.isProductDeleted = false;

              Routes.moveToPage(context: context, pageName: PageName.searchProduct, setState: setState);
            },
            icon: const Icon(Icons.search)
        ),

        /// ========================= product filter ===========================
        Stack(
          children: [
            IconButton(
              onPressed: () async {
                /// track last filter status (true or false) before the filter form showed
                final lastFilterStatus = FilterController.filterData["isFilterActive"] ?? false;

                showDialog(context: context,
                    builder: (ctx) {
                      return ProductFilter(pagingController: InfiniteScrollController.pagingController);
                    }
                ).then((value) async {

                  /// this code will executed after the filter form is closed

                  if (
                    /// reload data if:
                    /// - filter status is active & user tap apply button
                    /// - filter status inactive & user tap apply button but last filter status is active
                    (FilterController.isFilterActive && !FilterController.isFilterCanceled)
                    ||
                    (!FilterController.isFilterActive && lastFilterStatus)
                  ) {

                    await _loadDataFromServer();
                  }

                });
              },
              icon: const Icon(Icons.filter_list),
            ),

            /// show green dot icon if filter active
            Positioned(
              top: 4,
              left: 19,
              child: FilterController.isFilterActive
                  ? const CircleAvatar(
                      backgroundColor: Colors.green,
                      radius: 5,
                    )
                  : const SizedBox(),
            )
          ],
        ),

        /// ====================== Add new product button =========================
        IconButton.filledTonal(
          onPressed: () {
            ProductController.isAddNewProduct = true;
            ProductController.isEditProductFromDetailPage = false;
            Routes.moveToPage(
              context: context,
              keepPrevPage: true,
              pageName: PageName.newProduct,
              setState: setState
            );
          },

          icon: const Icon(Icons.add),
        )
      ],
    );
  }

  Future<void> _loadDataFromServer() async {
    _isLoading = true;
    await ApiService.getDataFromServer(pagingController: InfiniteScrollController.pagingController)
    .whenComplete(() {
      _isLoading = false;
      if (mounted) {
        setState(() {

        });
      }
    });
  }

  Widget _buildAppBarTitle() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const Text('My Products', style: TextStyle(fontWeight: FontWeight.bold),),

        InfoContainer(title: (ProductController.totalData).toString())
      ],
    );
  }

}