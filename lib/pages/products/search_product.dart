import 'package:flutter/material.dart';
import 'package:flutter_crud/pages/products/product_list_base_screen.dart';
import 'package:flutter_crud/services/api.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import '../../controllers/infinite_scroll_controller.dart';
import '../../controllers/products_controller.dart';
import '../../custom_widgets/info_container.dart';
import '../../models/product_model.dart';
import '../../routes.dart';
import '../../utils.dart';

class SearchProduct extends StatefulWidget {
  final PagingController<int, Product>? pagingProductController;
  const SearchProduct({Key? key, this.pagingProductController}) : super(key: key);

  @override
  State<SearchProduct> createState() => _SearchProductState();
}

class _SearchProductState extends State<SearchProduct> {

  final TextEditingController _searchCtrl = TextEditingController();
  final searchBoxHeight = 46.0;
  final searchFocusNode = FocusNode();
  bool isFirstBuild = true;
  bool isShowDeleteIcon = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    if (isFirstBuild) {
      debugPrint('[search_product] first build');
      searchFocusNode.requestFocus();
      isFirstBuild = false;
    }

    ProductController.pageNo = 0;

    InfiniteScrollController.pagingSearchController.addPageRequestListener((pageKey) {
      debugPrint('[search_product] listener executed / isLoading: $_isLoading / isFirstSearch: ${ProductController.isFirstSearch}');
      final searchFilter = '&search=1&name=${_searchCtrl.text}';

      if (ProductController.isFirstSearch == false && _isLoading == false) {

        Future.delayed(const Duration(milliseconds: 500)).then((value) async {
          ProductController.pageNo++;
          _isLoading = true;

          await ApiService.getDataFromServer(
              searchParams: searchFilter,
              pagingController: InfiniteScrollController.pagingSearchController
          ).whenComplete(() {
            if (mounted) {
              setState(() {
                _isLoading = false;
              });
            }

            debugPrint('[search_product] listener execution done');
          });
        });
      }

    });

  }

  @override
  Widget build(BuildContext context) {
    // print('[search_product] on build: ProductController.isFirstSearch: ${ProductController.isFirstSearch}');
    return SafeArea(
      child: WillPopScope(
          onWillPop: () {
            _backToHome();
            return Future.value(true);
          },
          child: Scaffold(
              appBar: AppBar(
                leading: TextButton(
                  onPressed: () {
                    _backToHome();
                    // Routes.backToPreviousPage(context);
                    // Routes.moveToPage(context: context, pageName: PageName.home, keepPrevPage: false);
                  },
                  child: const Icon(Icons.arrow_back),
                ),
                actions: [
                  const SizedBox(width: 60,),
                  Expanded(
                    child: _buildSearchBox(),
                  ),

                  Stack(
                    children: [
                      /// ============================= search button =============================
                      TextButton(
                        onPressed: () async {
                          await _searchData();
                          return;
                        },
                        child: const Icon(Icons.search),
                      ),

                      /// ============================== search count badge =======================
                      Positioned(
                        bottom: 0,
                        right: 4,
                        child: ProductController.isFirstSearch
                          ? const SizedBox()
                          : ProductController.totalData == 0
                            ? const SizedBox()
                            : InfoContainer(
                                height: 17,
                                fontSize: 10,
                                title: ProductController.totalData.toString()
                              )
                      )
                    ],
                  ),
                ],
              ),
              body: searchProductView()
          )
      ),
    );
  }

  ProductListBaseScreen searchProductView() {
    final searchView = ProductListBaseScreen(
      pagingCtrl: InfiniteScrollController.pagingSearchController,
      dataSource: ProductController.searchProductList,
      refreshUIFunction: setState
    );

    return searchView;
  }

  Future<void> _backToHome() async {
    ProductController.searchProductList.clear();
    InfiniteScrollController.pagingSearchController.itemList?.clear();
    Utils.hideKeyboard();
    ProductController.isSearchActive = false;

    if (ProductController.isProductDeleted) {
      Routes.moveToPage(context: context, pageName: PageName.home, keepPrevPage: false);
    }
    else {
      ProductController.totalData = ProductController.previousTotalData;
      ProductController.pageNo = ProductController.previousPageNo;
      Routes.backToPreviousPage(context);
    }

  }

  Widget _buildSearchBox() {
    return SizedBox(
      width: double.infinity,
      height: searchBoxHeight - 6,
      // margin: const EdgeInsets.only(left: 8),
      child: TextField(
        focusNode: searchFocusNode,
        controller: _searchCtrl,
        textInputAction: TextInputAction.go,
        textAlignVertical: TextAlignVertical.center,
        onChanged: (newValue) {
          isShowDeleteIcon = newValue.isNotEmpty;
          setState(() {

          });
        },
        decoration: InputDecoration(
            contentPadding: const EdgeInsets.only(
              // bottom: searchBoxHeight / 2,
              left: 8,
            ),
            border: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10))
            ),
            hintText: 'Search product',
            suffixIcon: isShowDeleteIcon
                ? InkWell(
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                      onTap: () {
                        _searchCtrl.clear();
                        isShowDeleteIcon = false;
                      },
                      child: const Icon(Icons.cancel_outlined)
                  )
                : const Text('')
        ),

        onSubmitted: (value) async {
          await _searchData();
        },
      ),
    );
  }

  Future<void> _searchData() async {
    if (_searchCtrl.text.isNotEmpty && _isLoading == false) {
      debugPrint('[search_product] search button pressed');

      Utils.hideKeyboard();
      _isLoading = true;

      final searchFilter = '&search=1&name=${_searchCtrl.text}';

      ProductController.searchProductList.clear();
      InfiniteScrollController.pagingSearchController.itemList?.clear();
      ProductController.pageNo = 1;
      await ApiService.getDataFromServer(
          searchParams: searchFilter,
          pagingController: InfiniteScrollController.pagingSearchController
      ).whenComplete(() {
        if (mounted) {
          setState(() {

          });
        }
      });

      debugPrint('[search_product] first search done');
      ProductController.isFirstSearch = false;
      _isLoading = false;
    }
  }

}
