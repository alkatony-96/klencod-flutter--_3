import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models.dart';
import 'scheduler.dart';

class AppState extends ChangeNotifier {
  List<Teacher> teachers = [];
  List<SchoolClass> classes = [];
  ScheduleSettings settings = ScheduleSettings();
  Map<String, List<List<Lesson?>>>? generated;
  String? lastMessage;

  static const _kTeachers = 'teachers_v1';
  static const _kClasses = 'classes_v1';
  static const _kSettings = 'settings_v1';

  Future<void> load() async {
    final sp = await SharedPreferences.getInstance();
    final t = sp.getString(_kTeachers);
    final c = sp.getString(_kClasses);
    final s = sp.getString(_kSettings);
    if (t != null) {
      teachers =
          (jsonDecode(t) as List).map((x) => Teacher.fromJson(x)).toList();
    }
    if (c != null) {
      classes = (jsonDecode(c) as List)
          .map((x) => SchoolClass.fromJson(x))
          .toList();
    }
    if (s != null) {
      settings = ScheduleSettings.fromJson(jsonDecode(s));
    }
    notifyListeners();
  }

  Future<void> _persist() async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_kTeachers,
        jsonEncode(teachers.map((t) => t.toJson()).toList()));
    await sp.setString(_kClasses,
        jsonEncode(classes.map((c) => c.toJson()).toList()));
    await sp.setString(_kSettings, jsonEncode(settings.toJson()));
  }

  // ====== المدرسون ======
  void addTeacher(Teacher t) {
    teachers.add(t);
    notifyListeners();
    _persist();
  }

  void updateTeacher(Teacher t) {
    final i = teachers.indexWhere((x) => x.id == t.id);
    if (i != -1) teachers[i] = t;
    notifyListeners();
    _persist();
  }

  void removeTeacher(String id) {
    teachers.removeWhere((t) => t.id == id);
    notifyListeners();
    _persist();
  }

  // ====== الصفوف ======
  void addClass(SchoolClass c) {
    classes.add(c);
    notifyListeners();
    _persist();
  }

  void removeClass(String id) {
    classes.removeWhere((c) => c.id == id);
    // احذف التكليفات المرتبطة
    for (final t in teachers) {
      t.assignments.removeWhere((a) => a.classId == id);
    }
    notifyListeners();
    _persist();
  }

  // ====== الإعدادات ======
  void updateSettings(ScheduleSettings s) {
    settings = s;
    notifyListeners();
    _persist();
  }

  // ====== التوليد ======
  ScheduleResult generate() {
    final sched = Scheduler(
      teachers: teachers,
      classes: classes,
      days: settings.days,
      periodsPerDay: settings.periodsPerDay,
    );
    final res = sched.schedule();
    generated = res.grid;
    lastMessage = res.message;
    notifyListeners();
    return res;
  }

  SchoolClass? classById(String id) {
    try {
      return classes.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }
}