import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_crud/custom_widgets/custom_image_container.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

/// this class is used to show full screen of image
/// when user tap on the big image in the detail page

class FullScreenImage extends StatelessWidget {
  // final List<String> imageList;
  // final int selectedIndex;
  final Map data;
  FullScreenImage({Key? key, required this.data}) : super(key: key);
  // FullScreenImage({Key? key, required this.imageList, required this.selectedIndex}) : super(key: key);

  late List<String> imageList = data["imageList"];
  late int selectedIndex = data["selectedIndex"] ;
  late ValueNotifier<int> activeIndex = ValueNotifier(selectedIndex);
  CarouselController imgController = CarouselController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              CarouselSlider.builder(
                carouselController: imgController,
                itemCount: imageList.length,
                options: CarouselOptions(
                  aspectRatio: 1,
                  initialPage: selectedIndex,
                  enableInfiniteScroll: false,
                  viewportFraction: 1.0,
                  height: double.infinity,
                  onPageChanged: (pageIndex, carouselPageChangeReason) {
                    activeIndex.value = pageIndex;
                  },
                ),
                itemBuilder: (BuildContext context, int itemIndex, int pageViewIndex) {
                  return CustomImageContainer(
                    boxFit: BoxFit.scaleDown,
                    imageLocation: imageList[itemIndex],
                  );
                }
              ),

              // const Expanded(child: SizedBox()),

              /// =================================== dot indicator ===========================
              imageList.length == 1
                ? const SizedBox()
                : Positioned(
                bottom: 10,
                child: SizedBox(
                  // decoration: BoxDecoration(
                  //     border: Border.all(color: Colors.red)
                  // ),
                  width: constraints.maxWidth,
                  child: Center(
                    child: ValueListenableBuilder(
                      valueListenable: activeIndex,
                      builder: (context, index, widget) {
                        return AnimatedSmoothIndicator(
                          onDotClicked: (clickedIndex) {
                            imgController.jumpToPage(clickedIndex);
                          },
                          effect: const WormEffect(
                            activeDotColor: Colors.white
                          ),
                          activeIndex: index,
                          count: imageList.length,
                        );
                      },
                    )
                  ),
                ),
              )
            ],
          );
        }
      )
    );
  }
}
