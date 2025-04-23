import 'package:flutter/material.dart';
import 'package:os_project/utils/colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// ignore: must_be_immutable
class CustomButton extends StatelessWidget {
  final double? borderRadius;
  final Color? backgroundColor;
  final double? horizentalPadding;
  final double? verticalPadding;
  final double? buttonWidth;
  final double? buttonHeight;
  final String buttonText;
  final TextStyle textStyle;
  final VoidCallback onPressed;
  final Gradient? gradient;

  const CustomButton({
    super.key,
    this.borderRadius,
    this.backgroundColor,
    this.horizentalPadding,
    this.verticalPadding,
    this.buttonWidth,
    this.buttonHeight,
    required this.buttonText,
    required this.textStyle,
    required this.onPressed,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    final double width = buttonWidth?.w ?? double.infinity;
    final double height = buttonHeight?.h ?? 50.h;

    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(borderRadius ?? 16),
      child: Container(
        width: width,
        height: height,
        padding: EdgeInsets.symmetric(
          horizontal: horizentalPadding?.w ?? 12.w,
          vertical: verticalPadding?.h ?? 14.h,
        ),
        decoration: BoxDecoration(
          color: gradient == null ? (backgroundColor ?? Colors.blue) : null,
          gradient: gradient,
          borderRadius: BorderRadius.circular(borderRadius ?? 16),
        ),
        alignment: Alignment.center,
        child: Text(
          buttonText,
          style: textStyle,
        ),
      ),
    );
  }
}
