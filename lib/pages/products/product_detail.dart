import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../constant.dart';
import '../../controllers/products_controller.dart';
import '../../custom_widgets/custom_container.dart';
import '../../custom_widgets/custom_image_container.dart';
import '../../models/product_model.dart';
import '../../routes.dart';
import '../../utils.dart';

class ProductDetailNew extends StatelessWidget {
  ProductDetailNew({Key? key}) : super(key: key);

  late Product currentProduct;
  late int imageCount;
  ValueNotifier<int> currentImagePos = ValueNotifier(0);
  CarouselController bigImageSliderController = CarouselController();
  // CarouselController smallImageSliderController = CarouselController();
  ScrollController smallImageSliderController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: StatefulBuilder(
            builder: (context, setState) {

              currentProduct = ProductController.isSearchActive
                  ? ProductController.searchProductList[ProductController.productIndex]
                  : ProductController.productList[ProductController.productIndex];

              imageCount = currentProduct.imagesPath.length;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      /// ================= big image slider ===================
                      _buildBigImageSlider(),

                      /// ================= back button & edit button ===================
                      _buildBackAndEditButton(context, setState),

                      /// ================= current image index/position =======================
                      _buildImagePositionIndicator()

                    ],
                  ),

                  const SizedBox(height: 6,),

                  /// ================= small image slider =======================
                  currentProduct.imagesPath.length == 1
                    ? const SizedBox()
                    : _buildSmallImageList(),

                  /// ==================== product name ===================
                  SizedBox(height: imageCount > 1 ? 6 : 0),
                  Padding(
                    padding: const EdgeInsets.only(left: 8, right: 8),
                    // child: Text(currentProduct.name),
                    child: Text(currentProduct.name),
                  ),

                  /// ==================== product price & stock ===================
                  const SizedBox(height: 6,),
                  CustomContainer(
                    containerType: ContainerType.standard,
                    width: double.infinity,
                    height: 30,
                    padding: const EdgeInsets.only(left: 8, right: 8),
                    color: Colors.grey.withOpacity(0.1),
                    child: Row(
                      children: [
                        Expanded(child: Text('Price: ${Constant.currencySymbol}${Utils.formatAmount(value: currentProduct.price.toString())}')),
                        Text('Stock: ${currentProduct.stock}')
                      ],
                    ),
                  ),

                  /// ====================== product description ====================
                  Container(
                    padding: const EdgeInsets.only(left: 8, right: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Product Description'),
                        Text(currentProduct.description)
                      ],
                    ),
                  )

                ],
              );
            }
          ),
        ),
      ),
    );
  }

  _buildBackAndEditButton(BuildContext context, Function setState) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          /// =================== back button ===================
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              // fixedSize: const Size(40, 40),
              backgroundColor: Colors.transparent,
              shape: const CircleBorder(),
            ),
            onPressed: () {
              Routes.backToPreviousPage(context);
            },

            child: const Icon(Icons.arrow_back, color: Colors.white),
          ),

          const Expanded(child: SizedBox()),

          /// ==================== edit button ======================
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              // fixedSize: const Size(40, 40),
              backgroundColor: Colors.transparent,
              shape: const CircleBorder(),
            ),
            onPressed: () {
              ProductController.isEditProductFromDetailPage = true;

              Routes.moveToPage(
                  context: context,
                  keepPrevPage: true,
                  pageName: PageName.editProduct,
                  // data: oldProductData,
                  setState: setState
              );

            },

            child: const Icon(Icons.edit_note, color: Colors.white),
          ),
        ],
      ),
    );
  }

  _buildImagePositionIndicator() {
    return Positioned(
        bottom: 5, right: 5,
        child: CustomContainer(
            height: 24,
            width: 40,
            containerType: ContainerType.rounded,
            color: Colors.white70,
            child: ValueListenableBuilder(
                valueListenable: currentImagePos,
                builder: (context, value, Widget? child) {
                  return Center(child: Text('${value + 1}/${currentProduct.imagesPath.length}'));
                }
            )
        )
    );
  }

  Widget _buildBigImageSlider() {
    return CarouselSlider.builder(
        itemCount: imageCount,
        carouselController: bigImageSliderController,
        options: CarouselOptions(
            aspectRatio: 1,
            enableInfiniteScroll: false,
            viewportFraction: 1.0,
            // enlargeCenterPage: false,
            onPageChanged: (pageIndex, carouselPageChangeReason) {
              currentImagePos.value = pageIndex;
              // print('current image pos: ${currentImagePos.value} / $carouselPageChangeReason');

              /// if user change image by slide, then change the small image focus position
              /// same with big image position/index
              if (carouselPageChangeReason.name == 'manual') {
                // smallImageSliderController.animateToPage(pageIndex);
                smallImageSliderController.animateTo(
                    60 * double.parse(pageIndex.toString()), /// 60 adalah nilai kurang lebih ukuran lebar image slider yang kecil / 60 is approximately the size (width) of small image slider
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.ease
                );
                // smallImageSliderController.jumpTo(double.parse(pageIndex.toString()));
              }
            }

        ),
        itemBuilder: (BuildContext context, int itemIndex, int pageViewIndex) {
          return GestureDetector(
            onTap: () {
              Routes.moveToPage(
                  context: context,
                  pageName: PageName.fullscreenImage,
                  data: {
                    "imageList": currentProduct.imagesPath,
                    "selectedIndex": itemIndex
                  }
              );
            },
            child: ProductImageContainer(
              imageIndex: itemIndex,
              isSmallImage: false,
              imageLocation: currentProduct.imagesPath[itemIndex],
              currentImagePos: currentImagePos,
              // child: Text('item index: $itemIndex / pageViewIndex: $pageViewIndex'),
            ),
          );
        }
    );
  }

  Widget _buildSmallImageList() {
    /// saya menggunakan ListView.builder untuk membuat list image yang kecil, karena ada fungsi shrinkWrap yang dapat mengelompokkan image ke tengah dan digabung dengan widget center
    /// i used ListView.builder to make small image list, because i need the shrinkWrap function to grouped the images to the center position and combined with center widget
    return SizedBox(
      height: 60,
      width: double.infinity,
      // decoration: BoxDecoration(
      //   border: Border.all(color: Colors.red)
      // ),
      child: Center(
        child: ListView.builder(
            controller: smallImageSliderController,
            shrinkWrap: true,
            itemCount: imageCount,
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, itemIndex) {
              return GestureDetector(
                onTap: () {
                  currentImagePos.value = itemIndex;
                  bigImageSliderController.jumpToPage(itemIndex);
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 6),
                  child: ProductImageContainer(
                    imageIndex: itemIndex,
                    isSmallImage: true,
                    imageLocation: currentProduct.imagesPath[itemIndex],
                    currentImagePos: currentImagePos,
                    // child: Text('item index: $itemIndex / pageViewIndex: $pageViewIndex'),
                  ),
                ),
              );
            }
        ),
      ),
    );
  }
}

class ProductImageContainer extends StatelessWidget {
  final bool isSmallImage;
  final String imageLocation;
  final ValueListenable<int> currentImagePos;
  final double? width;
  final int imageIndex;

  const ProductImageContainer({
    super.key,
    required this.imageLocation,
    this.width,
    required this.imageIndex,
    required this.isSmallImage,
    required this.currentImagePos
  });

  Widget productImage({double blcRadius=8, double brcRadius=8}) {
    return CustomImageContainer(
      imageLocation: imageLocation,
      bottomLeftCircularRadius: blcRadius,
      bottomRightCircularRadius: brcRadius,
      width: width,
    );
  }

  @override
  Widget build(BuildContext context) {
    return isSmallImage
      ? ValueListenableBuilder(
          valueListenable: currentImagePos,
          builder: (context, imagePos, Widget? child) {
            return CustomContainer(
              width: width ?? 80,
              // height: 60,
              containerType: ContainerType.rounded,
              borderColor: imagePos == imageIndex ? Colors.red : null,
              borderWidth: 4,
              child: productImage(),
            );
          }
        )
      : productImage(blcRadius: 0, brcRadius: 0);
  }
}
