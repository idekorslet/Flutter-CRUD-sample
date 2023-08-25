import 'package:flutter/material.dart';
import 'package:flutter_crud/custom_widgets/custom_container.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import '../../controllers/product_filter_controller.dart';
import '../../controllers/products_controller.dart';


class ProductFilter extends StatelessWidget {
  final PagingController pagingController;

  ProductFilter({Key? key, required this.pagingController}) : super(key: key);

  List<bool> colorizedStock = [false, false];
  List<bool> colorizedPrice = [false, false];
  bool _isEmptyStockOnly = false;
  bool _isFilterActive = false;
  bool _isFilterResetted = false;
  bool disableApppyButton = true;
  bool firstBuild = true;
  bool _lastActiveFilterStatus = false; // to keep last status of filter active or not

  @override
  Widget build(BuildContext context) {
    /// this part executed only once, because stateless widget
    final scrHeight = MediaQuery.of(context).size.height;
    final scrWidth = MediaQuery.of(context).size.width;

    if (FilterController.filterData.isNotEmpty) {
      _isFilterActive = FilterController.filterData["isFilterActive"];
      _lastActiveFilterStatus = _isFilterActive;

      /// set checkbox "Show empty only" value
      _isEmptyStockOnly = FilterController.filterData["isEmptyStockOnly"];

      /// set color for stock container / button
      colorizedStock.clear();
      colorizedStock.addAll(FilterController.filterData["stockSortData"]);

      /// set color for price container / button
      colorizedPrice.clear();
      colorizedPrice.addAll(FilterController.filterData["priceSortData"]);

      FilterController.lastFilterParamValue = FilterController.filterData["filterParamValue"];
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(10),
          width: scrWidth * 0.8,
          height: scrHeight * 0.7,
          constraints: const BoxConstraints(
            maxWidth: 350,
            maxHeight: 475
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(10))
          ),
          child: StatefulBuilder(
            builder: (context, innerState) {

              FilterController.setFilterData(_isEmptyStockOnly);

              if (!firstBuild) {

                if (colorizedStock[0] || colorizedStock[1]||
                    colorizedPrice[0] || colorizedPrice[1]||
                    _isEmptyStockOnly
                ) {
                  _isFilterActive = true;
                }
                else {
                  _isFilterActive = false;
                }

                disableApppyButton = !FilterController.hasFilterChanged();

                if (_lastActiveFilterStatus && _isFilterResetted) {
                  disableApppyButton = false;
                }
              }

              firstBuild = false;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Filter', style: TextStyle(fontSize: 24),),
                  const Divider(thickness: 1,),
                  /// ============================ Stock =========================
                  const Text('Stock', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
                  CheckboxListTile(
                      title: const Text('\t\tShow empty only'),
                      value: _isEmptyStockOnly,
                      onChanged: (newValue) {
                        innerState(() {
                          _isEmptyStockOnly = newValue!;

                          if (_isEmptyStockOnly) {
                            colorizedStock = [false, false];
                          }
                          else {
                            /// set color for stock container / button
                            colorizedStock.clear();
                            colorizedStock.addAll(FilterController.filterData["stockSortData"]);
                          }

                        });
                      }
                  ),

                  AbsorbPointer(
                    absorbing: _isEmptyStockOnly, // set to true to disable option
                    child: Padding(
                      padding: const EdgeInsets.only(left: 24.0, top: 14),
                      child: Row(
                          children: [
                            optionContainer(title: 'Low to High', index: 0, setState: innerState, changeStockColor: true),
                            const SizedBox(width: 30,),
                            optionContainer(title: 'High to Low', index: 1, setState: innerState, changeStockColor: true),
                          ]
                      ),
                    ),
                  ),

                  /// ============================ Price =========================
                  const SizedBox(height: 30,),
                  const Text('Price', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),

                  Padding(
                    padding: const EdgeInsets.only(left: 24.0, top: 14),
                    child: Row(
                        children: [
                          optionContainer(title: 'Low to High', index: 0, setState: innerState),
                          const SizedBox(width: 30,),
                          optionContainer(title: 'High to Low', index: 1, setState: innerState),
                        ]
                    ),
                  ),

                  const Expanded(child: SizedBox()),
                  Center(
                      child: GestureDetector(
                          onTap: () {
                            _isFilterActive ? _resetFilter(innerState) : null;
                          },
                          child: Text(
                              'Reset filter',
                              style: TextStyle(color: _isFilterActive ? Colors.blue : Colors.grey)
                          )
                      )
                  ),
                  const SizedBox(height: 10,),
                  const Divider(thickness: 1,),

                  /// ========================= cancel & apply button ==================
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      FilledButton.tonal(
                        child: const Text('Cancel'),
                        onPressed:  () {
                          _isFilterResetted = false;
                          FilterController.isFilterCanceled = true;
                          FilterController.isFilterActive = _lastActiveFilterStatus;
                          Navigator.pop(context);
                        },
                      ),

                      _buildApplyButton(context, innerState)
                    ],
                  ),
                ],
              );
            }
          ),
        ),
      ),
    );
  }


  _buildApplyButton(BuildContext context, Function setState) {
    return AbsorbPointer(
      absorbing: disableApppyButton,
      child: FilledButton.tonal(
        child: Text(
          'Apply',
          style: TextStyle(color: disableApppyButton ? Colors.grey : null),
        ),
        onPressed:  () {
          if (_isFilterResetted) {
            FilterController.resetFilter();
          }

          if (_isEmptyStockOnly) {
            FilterController.filterData["stockSortData"] = [false, false];
          }

          FilterController.isFilterCanceled = false;

          // clear list of products
          ProductController.productList.clear();
          ProductController.pageNo = 1;

          pagingController.itemList?.clear();

          // save current filter config
          FilterController.saveNewFilterData(_isEmptyStockOnly);

          if (context.mounted) {
            // close the filter form
            Navigator.pop(context);
          }

        },
      ),
    );
  }

  Widget optionContainer({
    required String title,
    required int index,
    bool changeStockColor = false,
    required Function setState
  }) {
    return InkWell(
      onTap: () {
        setState(() {
          if (changeStockColor) {
            setColorValue(colorizedStock, index);
            FilterController.setActiveSortData(data: colorizedStock);
          }
          else {
            setColorValue(colorizedPrice, index);
            FilterController.setActiveSortData(data: colorizedPrice, isChangeSortStock: false);
          }
        });
      },
      child: CustomContainer(
        containerType: ContainerType.rounded,
        width: 100,
        radius: 18,
        borderColor: changeStockColor
            ? (_isEmptyStockOnly ? Colors.grey : Colors.purple.shade200)
            : Colors.purple.shade200,
        color: changeStockColor
            ? (colorizedStock[index] ? Colors.purple.shade200 : Colors.transparent)
            : (colorizedPrice[index] ? Colors.purple.shade200 : Colors.transparent),
        child: Center(
            child: Text(title,
              style: TextStyle(
                color: changeStockColor ? (_isEmptyStockOnly ? Colors.grey : null) : null
              ),
            )
        ),
      ),
    );
  }

  void _resetFilter(Function setState) {
    _isEmptyStockOnly = false;
    colorizedStock = [false, false];
    colorizedPrice = [false, false];
    _isFilterResetted = true;
    _isFilterActive = false;
    setState(() {
    });
  }

  void setColorValue(List<bool> data, index) {
    data[index] = !data[index];

    if (index == 0 && data[0]) {
      data[1] = false;
    }
    else {
      data[0] = false;
    }
  }

}
