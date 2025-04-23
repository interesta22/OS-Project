import 'package:flutter/material.dart';
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

class GanttItem {
  final String id;
  final int start;
  final int end;

  GanttItem({required this.id, required this.start, required this.end});
}

enum SchedulingAlgorithm { fcfs, sjf, priority, roundRobin }

class SchedulerScreen extends StatefulWidget {
  @override
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
        runFCFS();
        break;
      case SchedulingAlgorithm.sjf:
        runSJF();
        break;
      case SchedulingAlgorithm.priority:
        runPriority();
        break;
      case SchedulingAlgorithm.roundRobin:
        runRoundRobin();
        break;
    }
    setState(() {});
  }

  void runFCFS() {
    processes.sort((a, b) => a.arrival.compareTo(b.arrival));
    int currentTime = 0;
    ganttChart.clear();
    for (var p in processes) {
      if (currentTime < p.arrival) currentTime = p.arrival;
      p.waiting = (currentTime - p.arrival).clamp(0, double.infinity).toInt();
      ganttChart.add(
        GanttItem(id: p.id, start: currentTime, end: currentTime + p.burst),
      );
      currentTime += p.burst;
    }
  }

  void runSJF() {
    List<Process> remaining = List.from(processes);
    remaining.sort((a, b) => a.arrival.compareTo(b.arrival));
    int currentTime = 0;
    ganttChart.clear();
    List<Process> done = [];

    while (remaining.isNotEmpty) {
      List<Process> available =
          remaining.where((p) => p.arrival <= currentTime).toList();
      if (available.isEmpty) {
        currentTime = remaining.first.arrival;
        continue;
      }
      available.sort((a, b) => a.burst.compareTo(b.burst));
      var p = available.first;
      p.waiting = (currentTime - p.arrival).clamp(0, double.infinity).toInt();
      ganttChart.add(
        GanttItem(id: p.id, start: currentTime, end: currentTime + p.burst),
      );
      currentTime += p.burst;
      remaining.remove(p);
      done.add(p);
    }
    processes = done;
  }

  void runPriority() {
    List<Process> remaining = List.from(processes);
    remaining.sort((a, b) => a.arrival.compareTo(b.arrival));
    int currentTime = 0;
    ganttChart.clear();
    List<Process> done = [];

    while (remaining.isNotEmpty) {
      List<Process> available =
          remaining.where((p) => p.arrival <= currentTime).toList();
      if (available.isEmpty) {
        currentTime = remaining.first.arrival;
        continue;
      }
      available.sort((a, b) => (b.priority ?? 0).compareTo(a.priority ?? 0));
      var p = available.first;
      p.waiting = (currentTime - p.arrival).clamp(0, double.infinity).toInt();
      ganttChart.add(
        GanttItem(id: p.id, start: currentTime, end: currentTime + p.burst),
      );
      currentTime += p.burst;
      remaining.remove(p);
      done.add(p);
    }
    processes = done;
  }

  void runRoundRobin() {
    List<Process> queue = List.from(processes);
    queue.sort((a, b) => a.arrival.compareTo(b.arrival));
    int currentTime = 0;
    Map<String, int> remainingBurst = {for (var p in queue) p.id: p.burst};
    Map<String, int> firstStart = {};
    ganttChart.clear();
    List<Process> completed = [];
    List<Process> readyQueue = [];

    while (queue.isNotEmpty || readyQueue.isNotEmpty) {
      readyQueue.addAll(
        queue.where((p) => p.arrival <= currentTime && !readyQueue.contains(p)),
      );
      queue.removeWhere((p) => p.arrival <= currentTime);

      if (readyQueue.isEmpty) {
        currentTime++;
        continue;
      }

      var p = readyQueue.removeAt(0);
      int burst = remainingBurst[p.id]!;
      int runTime = burst > timeQuantum ? timeQuantum : burst;

      if (!firstStart.containsKey(p.id)) {
        firstStart[p.id] = currentTime;
      }

      ganttChart.add(
        GanttItem(id: p.id, start: currentTime, end: currentTime + runTime),
      );
      currentTime += runTime;
      remainingBurst[p.id] = burst - runTime;

      if (remainingBurst[p.id]! > 0) {
        queue.add(
          Process(id: p.id, arrival: currentTime, burst: remainingBurst[p.id]!),
        );
      } else {
        p.waiting =
            (currentTime - p.arrival - p.burst)
                .clamp(0, double.infinity)
                .toInt();
        completed.add(p);
      }
    }

    processes = completed;
  }

  double get averageWaiting =>
      processes.isEmpty
          ? 0
          : processes.map((p) => p.waiting ?? 0).reduce((a, b) => a + b) /
              processes.length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('OS Scheduling Algorithms'),
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
              Row(
                children: [
                  SizedBox(
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
              Text(
                'Total Processes: ${processes.length}',
                style: AppTextStyles.font18BlackSemibold,
              ),
              Text(
                'Average Waiting Time: ${averageWaiting.toStringAsFixed(2)}',
                style: AppTextStyles.font18BlackSemibold,
              ),
              SizedBox(height: 10.h),
              Divider(),
              Text('Gantt Chart:', style: AppTextStyles.font18BlackSemibold),
              SizedBox(height: 10.h),
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
