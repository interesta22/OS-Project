import 'package:flutter/material.dart';
import 'package:os_project/utils/wight.dart';
import 'package:os_project/utils/colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


class AppTextStyles{
  static TextStyle font13GreyRegular = GoogleFonts.tajawal(
    fontSize: 13.sp,
    fontWeight: FontWeightHelper.regular,
    color: AppColors.grey
  );
  static TextStyle font13BlackRegular = GoogleFonts.tajawal(
    fontSize: 13.sp,
    fontWeight: FontWeightHelper.regular,
    color: AppColors.black
  );
  
  static TextStyle font18WhiteSemibold = GoogleFonts.tajawal(
    fontSize: 18.sp,
    fontWeight: FontWeightHelper.semiBold,
    color: AppColors.white
  );
  static TextStyle font18BlackSemibold = GoogleFonts.tajawal(
    fontSize: 18.sp,
    fontWeight: FontWeightHelper.semiBold,
    color: AppColors.black
  );
} 