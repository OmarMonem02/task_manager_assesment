import 'package:hive_flutter/hive_flutter.dart';

class HiveStorage {
  HiveStorage._();

  static const projectsBoxName = 'projects_box';
  static const tasksBoxName = 'tasks_box';
  static const syncQueueBoxName = 'sync_queue_box';
  static const metaBoxName = 'meta_box';

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox<dynamic>(projectsBoxName);
    await Hive.openBox<dynamic>(tasksBoxName);
    await Hive.openBox<dynamic>(syncQueueBoxName);
    await Hive.openBox<dynamic>(metaBoxName);
  }

  static Box<dynamic> get projectsBox => Hive.box<dynamic>(projectsBoxName);
  static Box<dynamic> get tasksBox => Hive.box<dynamic>(tasksBoxName);
  static Box<dynamic> get syncQueueBox => Hive.box<dynamic>(syncQueueBoxName);
  static Box<dynamic> get metaBox => Hive.box<dynamic>(metaBoxName);
}
