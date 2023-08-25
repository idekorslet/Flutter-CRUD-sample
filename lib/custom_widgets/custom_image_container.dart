import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class CustomImageContainer extends StatelessWidget {
  final String imageLocation;
  BoxFit boxFit;
  double? width;
  double? height;
  double topLeftCircularRadius;
  double topRightCircularRadius;
  double bottomLeftCircularRadius;
  double bottomRightCircularRadius;

  CustomImageContainer({
    super.key,
    required this.imageLocation,
    this.boxFit=BoxFit.fill,
    this.width,
    this.height,
    this.topLeftCircularRadius=8, this.topRightCircularRadius=8,
    this.bottomLeftCircularRadius=0, this.bottomRightCircularRadius=0,
  });

  @override
  Widget build(BuildContext context) {
    // print('[custom_image_container] image location');
    // print(imageLocation);
    return CachedNetworkImage(
        imageUrl: imageLocation,
        width: width,
        height: height,
        imageBuilder: (context, imageProvider) => Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(topLeftCircularRadius),
              topRight: Radius.circular(topRightCircularRadius),
              bottomLeft: Radius.circular(bottomLeftCircularRadius),
              bottomRight: Radius.circular(bottomRightCircularRadius),
            ),
            image: DecorationImage(
              image: imageProvider,
              fit: boxFit,
              // colorFilter: ColorFilter.mode(Colors.red, BlendMode.colorBurn)
            ),
          ),
        ),

        errorWidget: (context, url, error) {
          return const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Failed to\nload image', style: TextStyle(fontSize: 10), textAlign: TextAlign.center),
              Icon(Icons.error)
            ],
          );
        },

        progressIndicatorBuilder: (context, url, download) {
          // Center(child: CircularProgressIndicator(value: downloadProgress.progress)),
          if (download.progress != null) {
            final percent = (download.progress! * 100).toInt();
            // // return CircularProgressIndicator(value: percent,);
            return Text('Loading image\n($percent%)', style: const TextStyle(fontSize: 10), textAlign: TextAlign.center);
          }
          else {
            return const Text('Image loaded');
          }
        }
    );
  }
}