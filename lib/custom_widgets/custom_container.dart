import 'package:flutter/material.dart';

enum ContainerType {circle, rounded, standard}

class CustomContainer extends StatelessWidget {
  ContainerType containerType;
  final Color? color;
  Widget? child;
  double width;
  double height;
  double radius;
  Color? borderColor;
  double borderWidth;
  EdgeInsetsGeometry? padding;

  CustomContainer({
    Key? key,
    this.containerType=ContainerType.rounded,
    this.color,
    this.child,
    this.width=40,
    this.height=40,
    this.radius=10,
    this.borderColor,
    this.borderWidth=1,
    this.padding
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _baseContainer(color: color, child: child);
  }

  Widget _baseContainer({
    Color? color,
    Widget? child
  }) {
    return Container(
      width: width,
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        border: borderColor == null ? null : Border.all(color: borderColor!, width: borderWidth),
        borderRadius: containerType == ContainerType.rounded ? BorderRadius.circular(radius) : null,
        shape: containerType == ContainerType.circle ? BoxShape.circle : BoxShape.rectangle
      ),
      child: child,
    );
  }
}
