import 'dart:math';

String genId() =>
    '${DateTime.now().microsecondsSinceEpoch}_${Random().nextInt(99999)}';

// ================== المدرس + تكليفاته ==================
class TeacherAssignment {
  String id;
  String subject;        // اسم المادة
  String classId;        // معرف الصف
  int periodsPerWeek;    // عدد الحصص أسبوعياً لهذه المادة
  bool isArtOrSport;     // هل هي فنية أو رياضية
  Set<int> preferredPeriods; // حصص مفضلة (0-indexed)

  TeacherAssignment({
    String? id,
    required this.subject,
    required this.classId,
    required this.periodsPerWeek,
    this.isArtOrSport = false,
    Set<int>? preferredPeriods,
  })  : id = id ?? genId(),
        preferredPeriods = preferredPeriods ?? {};

  Map<String, dynamic> toJson() => {
        'id': id,
        'subject': subject,
        'classId': classId,
        'periodsPerWeek': periodsPerWeek,
        'isArtOrSport': isArtOrSport,
        'preferredPeriods': preferredPeriods.toList(),
      };

  factory TeacherAssignment.fromJson(Map<String, dynamic> j) => TeacherAssignment(
        id: j['id'],
        subject: j['subject'],
        classId: j['classId'],
        periodsPerWeek: j['periodsPerWeek'],
        isArtOrSport: j['isArtOrSport'] ?? false,
        preferredPeriods: Set<int>.from(j['preferredPeriods'] ?? []),
      );
}

class Teacher {
  String id;
  String name;
  int? offDayIndex; // فهرس يوم الإجازة، أو null إن لم يكن له يوم إجازة
  List<TeacherAssignment> assignments;

  Teacher({
    String? id,
    required this.name,
    this.offDayIndex,
    List<TeacherAssignment>? assignments,
  })  : id = id ?? genId(),
        assignments = assignments ?? [];

  int get totalPeriods =>
      assignments.fold(0, (s, a) => s + a.periodsPerWeek);

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'offDayIndex': offDayIndex,
        'assignments': assignments.map((a) => a.toJson()).toList(),
      };

  factory Teacher.fromJson(Map<String, dynamic> j) => Teacher(
        id: j['id'],
        name: j['name'],
        offDayIndex: j['offDayIndex'],
        assignments: (j['assignments'] as List)
            .map((x) => TeacherAssignment.fromJson(x))
            .toList(),
      );
}

// ================== الصف ==================
class SchoolClass {
  String id;
  String grade;   // مثل: "الأول"
  String section; // مثل: "أ"

  SchoolClass({String? id, required this.grade, required this.section})
      : id = id ?? genId();

  String get displayName => '$grade - $section';

  Map<String, dynamic> toJson() =>
      {'id': id, 'grade': grade, 'section': section};

  factory SchoolClass.fromJson(Map<String, dynamic> j) =>
      SchoolClass(id: j['id'], grade: j['grade'], section: j['section']);
}

// ================== الحصة المولدة ==================
class Lesson {
  final String teacherId;
  final String teacherName;
  final String subject;
  final String classId;
  final bool isArtOrSport;

  const Lesson({
    required this.teacherId,
    required this.teacherName,
    required this.subject,
    required this.classId,
    this.isArtOrSport = false,
  });
}

// ================== إعدادات الجدول ==================
class ScheduleSettings {
  int days;
  int periodsPerDay;
  List<String> dayNames;

  ScheduleSettings({
    this.days = 5,
    this.periodsPerDay = 7,
    List<String>? dayNames,
  }) : dayNames = dayNames ??
            const ['الأحد', 'الاثنين', 'الثلاثاء', 'الأربعاء', 'الخميس',
                   'الجمعة', 'السبت'];

  Map<String, dynamic> toJson() => {
        'days': days,
        'periodsPerDay': periodsPerDay,
        'dayNames': dayNames,
      };

  factory ScheduleSettings.fromJson(Map<String, dynamic> j) => ScheduleSettings(
        days: j['days'],
        periodsPerDay: j['periodsPerDay'],
        dayNames: List<String>.from(j['dayNames']),
      );
}