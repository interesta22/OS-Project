class Process {
  final String id;
  final int arrival;
  final int burst;
  int? waiting;
  int? turnaround;
  int? priority;

  Process({
    required this.id,
    required this.arrival,
    required this.burst,
    this.priority,
  });
}
