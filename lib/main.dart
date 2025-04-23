import 'package:flutter/material.dart';
import 'package:os_project/models/GanttItem.dart';
import 'package:os_project/pages/SchedulerScreen.dart';
import 'package:os_project/utils/fonts.dart';
import 'package:os_project/utils/colors.dart';
import 'package:os_project/models/process.dart';
import 'package:os_project/widgets/custom_button.dart';
import 'package:os_project/widgets/custom_text_field.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          home: SchedulerScreen(),
        );
      },
    );
  }
}


