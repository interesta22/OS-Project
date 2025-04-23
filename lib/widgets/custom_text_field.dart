import 'package:flutter/material.dart';
import 'package:os_project/utils/fonts.dart';
import 'package:os_project/utils/colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// ignore: must_be_immutable
class CustomTextField extends StatefulWidget {
  final EdgeInsetsGeometry? contentPadding;
  final InputBorder? focusedBorder;
  final InputBorder? enabledBorder;
  final InputBorder? errorBorder; // حدود الخطأ
  final InputBorder? focusedErrorBorder; // حدود الخطأ عند التركيز
  final TextStyle? inputTextStyle;
  final TextStyle? hintStyle;
  final String hintText;
  final Color? backgroundColor;
  bool isObsecure;
  final Widget? suffixIcon;
  final TextEditingController? controller;
  final Function(String?) validator;
  bool isEnabled;

  CustomTextField({
    this.isEnabled = true,
    this.contentPadding,
    this.focusedBorder,
    this.enabledBorder,
    this.errorBorder,
    this.focusedErrorBorder,
    this.inputTextStyle,
    this.hintStyle,
    required this.hintText,
    this.backgroundColor,
    required this.isObsecure,
    this.suffixIcon,
    this.controller,
    required this.validator,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      // To rebuild the widget when focus changes
      setState(() {});
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      enabled: widget.isEnabled,
      controller: widget.controller,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: (value) {
        return widget.validator(value);
      },
      focusNode: _focusNode,
      decoration: InputDecoration(
        suffixIconColor: _focusNode.hasFocus
            ? AppColors.mainblue
            : AppColors.lightgrey,
        suffixIcon: widget.suffixIcon,
        filled: true,
        fillColor: widget.backgroundColor ?? Colors.white,
        isDense: true,
        contentPadding: widget.contentPadding ??
            EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        focusedBorder: widget.focusedBorder ??
            OutlineInputBorder(
              borderSide: BorderSide(
                color: AppColors.mainblue,
                width: 1.3,
              ),
              borderRadius: BorderRadius.circular(16.0),
            ),
        enabledBorder: widget.enabledBorder ??
            OutlineInputBorder(
              borderSide: BorderSide(
                color: AppColors.lighterGrey,
                width: 1.3,
              ),
              borderRadius: BorderRadius.circular(16.0),
            ),
        errorBorder: widget.errorBorder ??
            OutlineInputBorder(
              borderSide: BorderSide(
                color: AppColors.red, // لون الحدود عند وجود خطأ
                width: 1.3,
              ),
              borderRadius: BorderRadius.circular(16.0),
            ),
        focusedErrorBorder: widget.focusedErrorBorder ??
            OutlineInputBorder(
              borderSide: BorderSide(
                color:
                    AppColors.red, // لون الحدود عند وجود خطأ أثناء التركيز
                width: 1.3,
              ),
              borderRadius: BorderRadius.circular(16.0),
            ),
        disabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: AppColors.lighterGrey,
                width: 1.3,
              ),
              borderRadius: BorderRadius.circular(16.0),
            ),
        hintStyle: widget.hintStyle ?? AppTextStyles.font13GreyRegular,
        hintText: widget.hintText,
      ),
      obscureText: widget.isObsecure,
      style: widget.inputTextStyle ?? AppTextStyles.font13BlackRegular,
    );
  }
}