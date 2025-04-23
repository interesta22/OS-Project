import 'package:os_project/models/GanttItem.dart';

import '../models/process.dart';

class SchedulerHelper {
  static List<GanttItem> runFCFS(List<Process> processes) {
    processes.sort((a, b) => a.arrival.compareTo(b.arrival));
    int currentTime = 0;
    List<GanttItem> chart = [];

    for (var p in processes) {
      if (currentTime < p.arrival) currentTime = p.arrival;
      p.waiting = (currentTime - p.arrival).clamp(0, double.infinity).toInt();
      p.turnaround = p.waiting! + p.burst;
      chart.add(GanttItem(id: p.id, start: currentTime, end: currentTime + p.burst));
      currentTime += p.burst;
    }
    return chart;
  }

  static List<GanttItem> runSJF(List<Process> processes) {
    List<Process> remaining = List.from(processes);
    remaining.sort((a, b) => a.arrival.compareTo(b.arrival));
    int currentTime = 0;
    List<GanttItem> chart = [];
    List<Process> done = [];

    while (remaining.isNotEmpty) {
      var available = remaining.where((p) => p.arrival <= currentTime).toList();
      if (available.isEmpty) {
        currentTime = remaining.first.arrival;
        continue;
      }
      available.sort((a, b) => a.burst.compareTo(b.burst));
      var p = available.first;
      p.waiting = (currentTime - p.arrival).clamp(0, double.infinity).toInt();
      p.turnaround = p.waiting! + p.burst;
      chart.add(GanttItem(id: p.id, start: currentTime, end: currentTime + p.burst));
      currentTime += p.burst;
      remaining.remove(p);
      done.add(p);
    }
    processes
      ..clear()
      ..addAll(done);
    return chart;
  }

  static List<GanttItem> runPriority(List<Process> processes) {
    List<Process> remaining = List.from(processes);
    remaining.sort((a, b) => a.arrival.compareTo(b.arrival));
    int currentTime = 0;
    List<GanttItem> chart = [];
    List<Process> done = [];

    while (remaining.isNotEmpty) {
      var available = remaining.where((p) => p.arrival <= currentTime).toList();
      if (available.isEmpty) {
        currentTime = remaining.first.arrival;
        continue;
      }
      available.sort((a, b) => (b.priority ?? 0).compareTo(a.priority ?? 0));
      var p = available.first;
      p.waiting = (currentTime - p.arrival).clamp(0, double.infinity).toInt();
      p.turnaround = p.waiting! + p.burst;
      chart.add(GanttItem(id: p.id, start: currentTime, end: currentTime + p.burst));
      currentTime += p.burst;
      remaining.remove(p);
      done.add(p);
    }
    processes
      ..clear()
      ..addAll(done);
    return chart;
  }

  static List<GanttItem> runRoundRobin(List<Process> processes, int quantum) {
    List<Process> queue = List.from(processes);
    queue.sort((a, b) => a.arrival.compareTo(b.arrival));
    int currentTime = 0;
    Map<String, int> remainingBurst = {for (var p in queue) p.id: p.burst};
    Map<String, int> firstStart = {};
    List<GanttItem> chart = [];
    List<Process> completed = [];
    List<Process> readyQueue = [];

    while (queue.isNotEmpty || readyQueue.isNotEmpty) {
      readyQueue.addAll(queue.where((p) => p.arrival <= currentTime && !readyQueue.contains(p)));
      queue.removeWhere((p) => p.arrival <= currentTime);

      if (readyQueue.isEmpty) {
        currentTime++;
        continue;
      }

      var p = readyQueue.removeAt(0);
      int burst = remainingBurst[p.id]!;
      int runTime = burst > quantum ? quantum : burst;

      if (!firstStart.containsKey(p.id)) {
        firstStart[p.id] = currentTime;
      }

      chart.add(GanttItem(id: p.id, start: currentTime, end: currentTime + runTime));
      currentTime += runTime;
      remainingBurst[p.id] = burst - runTime;

      if (remainingBurst[p.id]! > 0) {
        queue.add(Process(id: p.id, arrival: currentTime, burst: remainingBurst[p.id]!));
      } else {
        p.waiting = (currentTime - p.arrival - p.burst).clamp(0, double.infinity).toInt();
        p.turnaround = p.waiting! + p.burst;
        completed.add(p);
      }
    }

    processes
      ..clear()
      ..addAll(completed);
    return chart;
  }
}
