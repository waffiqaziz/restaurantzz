enum MyWorkmanager {
  oneOff("task-identifier", "task-identifier"),
  periodic("com.waffiq.restaurantzz", "com.waffiq.restaurantzz");

  final String uniqueName;
  final String taskName;

  const MyWorkmanager(this.uniqueName, this.taskName);
}
