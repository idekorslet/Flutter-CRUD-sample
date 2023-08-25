import 'package:flutter/material.dart';

class InfoContainer extends StatelessWidget {
  String title;
  double? width;
  double height;
  double fontSize;
  double bottomPadding;
  double topPadding;
  double topMargin;
  double bottomMargin;
  Color? color;
  Color? borderColor;
  double? borderRadius;
  Color? fontColor;
  double? leftPadding;
  double? rightPadding;

  InfoContainer({
    Key? key,
    required this.title,
    this.width,
    this.height=17,
    this.fontSize=12,
    this.bottomPadding=0,
    this.topPadding=0,
    this.topMargin=0,
    this.bottomMargin=0,
    this.color,
    this.borderColor,
    this.borderRadius,
    this.fontColor,
    this.leftPadding,
    this.rightPadding

  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _buildInfoContainer();
  }

  Container _buildInfoContainer() {
    /// this container is used for information to show
    /// total product text, near MyProduct title
    /// "all data loaded" text in the very bottom of product list
    return Container(
      height: height,
      width: width,
      margin: EdgeInsets.only(left: 2, top: topMargin, bottom: bottomMargin),
      padding: EdgeInsets.only(left: leftPadding ?? 4, right: rightPadding ?? 4, bottom: bottomPadding, top: topPadding),
      decoration: BoxDecoration(
          color: color ?? Colors.lightGreen,
          border: Border.all(color: borderColor ?? Colors.transparent),
          borderRadius: BorderRadius.all(Radius.circular(borderRadius ?? 10)),
      ),
      child: Center(
        child: Text(
          title,
          style: TextStyle(fontSize: fontSize, color: fontColor ?? Colors.black),
        ),
      ),
    );
  }
}
