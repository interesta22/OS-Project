import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:os_project/helper/scheduler_helper.dart';
import 'package:os_project/models/GanttItem.dart';
import 'package:os_project/models/process.dart';
import 'package:os_project/models/enum.dart';
import 'package:os_project/utils/colors.dart';
import 'package:os_project/utils/fonts.dart';
import 'package:os_project/widgets/custom_button.dart';
import 'package:os_project/widgets/custom_text_field.dart';

class SchedulerScreen extends StatefulWidget {
  const SchedulerScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SchedulerScreenState createState() => _SchedulerScreenState();
}

class _SchedulerScreenState extends State<SchedulerScreen> {
  final idController = TextEditingController();
  final arrivalController = TextEditingController();
  final burstController = TextEditingController();
  final priorityController = TextEditingController();
  final timeQuantumController = TextEditingController(text: '2');

  List<Process> processes = [];
  List<GanttItem> ganttChart = [];
  SchedulingAlgorithm selectedAlgorithm = SchedulingAlgorithm.fcfs;
  int timeQuantum = 2;

  void addProcess() {
    final id = idController.text;
    final arrival = int.tryParse(arrivalController.text);
    final burst = int.tryParse(burstController.text);
    final priority = int.tryParse(priorityController.text);

    if (id.isEmpty || arrival == null || burst == null) return;

    setState(() {
      processes.add(
        Process(id: id, arrival: arrival, burst: burst, priority: priority),
      );
      idController.clear();
      arrivalController.clear();
      burstController.clear();
      priorityController.clear();
    });
  }

  void resetProcesses() {
    setState(() {
      processes.clear();
      ganttChart.clear();
      idController.clear();
      arrivalController.clear();
      burstController.clear();
      priorityController.clear();
      timeQuantumController.text = '2';
    });
  }

  void runScheduling() {
    timeQuantum = int.tryParse(timeQuantumController.text) ?? 2;
    switch (selectedAlgorithm) {
      case SchedulingAlgorithm.fcfs:
        ganttChart = SchedulerHelper.runFCFS(processes);
        break;
      case SchedulingAlgorithm.sjf:
        ganttChart = SchedulerHelper.runSJF(processes);
        break;
      case SchedulingAlgorithm.priority:
        ganttChart = SchedulerHelper.runPriority(processes);
        break;
      case SchedulingAlgorithm.roundRobin:
        ganttChart = SchedulerHelper.runRoundRobin(processes, timeQuantum);
        break;
    }
    setState(() {});
  }

  double get averageWaiting =>
      processes.isEmpty
          ? 0
          : processes.map((p) => p.waiting ?? 0).reduce((a, b) => a + b) /
              processes.length;

  double get averageTurnaround =>
      processes.isEmpty
          ? 0
          : processes.map((p) => p.turnaround ?? 0).reduce((a, b) => a + b) /
              processes.length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'OS Scheduling Algorithms',
          style: TextStyle(color: Colors.black),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: CustomButton(
              onPressed: resetProcesses,
              buttonText: 'Reset',
              textStyle: AppTextStyles.font18WhiteSemibold,
              buttonWidth: 70.w,
              buttonHeight: 45.h,
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: SingleChildScrollView(
          child: Column(
            children: [
              //id and arrival fields
              Row(
                children: [
                  SizedBox(
                    // ignore: sort_child_properties_last
                    child: CustomTextField(
                      controller: idController,
                      hintText: 'ID',
                      isObsecure: false,
                      validator: (value) => null,
                    ),
                    width: 60.w,
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: CustomTextField(
                      controller: arrivalController,
                      hintText: 'Arrival',
                      isObsecure: false,
                      validator: (value) => null,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              //burst and priority fields
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: burstController,
                      hintText: 'Burst',
                      isObsecure: false,
                      validator: (value) => null,
                    ),
                  ),
                  if (selectedAlgorithm == SchedulingAlgorithm.priority)
                    SizedBox(width: 12.w),
                  if (selectedAlgorithm == SchedulingAlgorithm.priority)
                    Expanded(
                      child: CustomTextField(
                        controller: priorityController,
                        hintText: 'Priority',
                        isObsecure: false,
                        validator: (value) => null,
                      ),
                    ),
                  if (selectedAlgorithm == SchedulingAlgorithm.roundRobin)
                    SizedBox(
                      width: 100.w,
                      child: CustomTextField(
                        controller: timeQuantumController,
                        hintText: 'Quantum',
                        isObsecure: false,
                        validator: (value) => null,
                      ),
                    ),
                ],
              ),
              SizedBox(height: 12.h),
              //functional button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  CustomButton(
                    onPressed: addProcess,
                    buttonText: 'Add',
                    textStyle: AppTextStyles.font18WhiteSemibold,
                    buttonWidth: 70.w,
                    buttonHeight: 45.h,
                  ),
                  CustomButton(
                    onPressed: runScheduling,
                    buttonText: 'Run',
                    textStyle: AppTextStyles.font18WhiteSemibold,
                    buttonWidth: 70.w,
                    buttonHeight: 45.h,
                  ),
                  Container(
                    height: 45.h,
                    decoration: BoxDecoration(
                      color: Colors.blue, // نفس لون الزرار الأزرق
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<SchedulingAlgorithm>(
                        value: selectedAlgorithm,
                        dropdownColor: Colors.blue,
                        iconEnabledColor: Colors.white,
                        items:
                            SchedulingAlgorithm.values.map((algo) {
                              return DropdownMenuItem(
                                value: algo,
                                child: Text(
                                  algo.toString().split('.').last.toUpperCase(),
                                  style:
                                      AppTextStyles
                                          .font18WhiteSemibold, // أو اللي شبه الزرار عندك
                                ),
                              );
                            }).toList(),
                        onChanged:
                            (algo) => setState(() => selectedAlgorithm = algo!),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 15.h),
              //table
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingRowColor: WidgetStateColor.resolveWith(
                    // ignore: deprecated_member_use
                    (states) => AppColors.mainblue.withOpacity(0.2),
                  ),
                  columns: const [
                    DataColumn(label: Text('ID')),
                    DataColumn(label: Text('Burst')),
                    DataColumn(label: Text('Arrival')),
                    DataColumn(label: Text('Priority')),
                    DataColumn(label: Text('Waiting')),
                  ],
                  rows:
                      processes.map((p) {
                        return DataRow(
                          cells: [
                            DataCell(Text(p.id)),
                            DataCell(Text(p.burst.toString())),
                            DataCell(Text(p.arrival.toString())),
                            DataCell(
                              Text(p.priority?.toString() ?? "-"),
                            ), // Add a placeholder for priority
                            DataCell(Text(p.waiting?.toString() ?? "-")),
                          ],
                        );
                      }).toList(),
                ),
              ),
              SizedBox(height: 10.h),
              Divider(),
              // Add the total processes
              Card(
                margin: const EdgeInsets.symmetric(vertical: 10),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text('Results', style: AppTextStyles.font18BlackSemibold),
                      SizedBox(height: 12.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total Processes: ${processes.length}',
                            style: AppTextStyles.font18BlackSemibold,
                          ),
                          Text(
                            'Avg Wait: ${averageWaiting.toStringAsFixed(2)}',
                            style: AppTextStyles.font18BlackSemibold,
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Avg Turnaround: ${averageTurnaround.toStringAsFixed(2)}',
                            style: AppTextStyles.font18BlackSemibold,
                          ),
                          SizedBox(width: 16.w),
                          Text(
                            'Exec Time: ${ganttChart.isNotEmpty ? ganttChart.last.end : 0}',
                            style: AppTextStyles.font18BlackSemibold,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 8.h),
              Divider(),
              Text('Gantt Chart:', style: AppTextStyles.font18BlackSemibold),
              SizedBox(height: 4.h),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // العمليات
                      Row(
                        children:
                            ganttChart.map((item) {
                              return Container(
                                width: (item.end - item.start) * 30.w,
                                height: 50,
                                alignment: Alignment.center,
                                margin: const EdgeInsets.only(right: 2),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.blue.shade300,
                                      Colors.blue.shade600,
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 4,
                                      offset: Offset(1, 2),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  item.id,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              );
                            }).toList(),
                      ),

                      const SizedBox(height: 12),

                      // الخط + الشرط + الأرقام
                      Stack(
                        children: [
                          // الخط نفسه
                          Positioned.fill(
                            child: Align(
                              alignment: Alignment.bottomLeft,
                              child: Container(
                                height: 1.5,
                                color: Colors.grey.shade800,
                              ),
                            ),
                          ),

                          // الأرقام والشرط
                          // Gantt Chart visualization with animation
                          Row(
                            children:
                                ganttChart.map((item) {
                                    return Container(
                                      width: (item.end - item.start) * 30.w,
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        '${item.start}',
                                        style: TextStyle(fontSize: 14.sp),
                                      ),
                                    );
                                  }).toList()
                                  ..add(
                                    Container(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        '${ganttChart.isNotEmpty ? ganttChart.last.end : 0}',
                                        style: TextStyle(fontSize: 14.sp),
                                      ),
                                    ),
                                  ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
