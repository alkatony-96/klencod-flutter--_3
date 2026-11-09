import 'dart:math';
import 'models.dart';

class ScheduleResult {
  final Map<String, List<List<Lesson?>>> grid; // classId → [day][period]
  final bool success;
  final String? message;

  ScheduleResult({
    required this.grid,
    required this.success,
    this.message,
  });
}

class _LessonRequest {
  final Teacher teacher;
  final TeacherAssignment assignment;
  _LessonRequest(this.teacher, this.assignment);
}

class _Slot {
  final String classId;
  final int day;
  final int period;
  _Slot(this.classId, this.day, this.period);
}

/// محرك الجدولة: Backtracking + MRV (Minimum Remaining Values)
/// مع أولويات لتوزيع الحصص ومنع الحصص المزدوجة في نفس اليوم.
class Scheduler {
  final List<Teacher> teachers;
  final List<SchoolClass> classes;
  final int days;
  final int periodsPerDay;
  final Duration timeLimit;

  Scheduler({
    required this.teachers,
    required this.classes,
    required this.days,
    required this.periodsPerDay,
    this.timeLimit = const Duration(seconds: 15),
  });

  late DateTime _startTime;

  ScheduleResult schedule() {
    _startTime = DateTime.now();

    // 1) تهيئة الشبكة
    final grid = <String, List<List<Lesson?>>>{};
    for (final c in classes) {
      grid[c.id] =
          List.generate(days, (_) => List<Lesson?>.filled(periodsPerDay, null));
    }

    // 2) بناء طلبات الدروس
    final requests = <_LessonRequest>[];
    for (final t in teachers) {
      for (final a in t.assignments) {
        if (!grid.containsKey(a.classId)) continue;
        for (var i = 0; i < a.periodsPerWeek; i++) {
          requests.add(_LessonRequest(t, a));
        }
      }
    }

    // 3) تحقق مسبق: هل الصف يستوعب كل دروسه؟
    for (final c in classes) {
      final total = requests
          .where((r) => r.assignment.classId == c.id)
          .length;
      final capacity = days * periodsPerDay;
      if (total > capacity) {
        return ScheduleResult(
          grid: grid,
          success: false,
          message:
              'الصف ${c.displayName} يحتاج $total حصة، والأسبوع يتسع لـ $capacity فقط.',
        );
      }
    }

    // 4) تحقق: هل المدرس يستطيع تدريس حصصه؟
    for (final t in teachers) {
      final availDays =
          days - (t.offDayIndex != null ? 1 : 0);
      final cap = availDays * periodsPerDay;
      if (t.totalPeriods > cap) {
        return ScheduleResult(
          grid: grid,
          success: false,
          message:
              'المدرس ${t.name} يحتاج ${t.totalPeriods} حصة والأيام المتاحة له تتسع لـ $cap فقط.',
        );
      }
    }

    // 5) حالة التتبع
    final teacherBusy =
        <String, Set<int>>{for (final t in teachers) t.id: {}};
    final teacherDayCount = <String, List<int>>{
      for (final t in teachers) t.id: List.filled(days, 0)
    };
    final remaining = List<_LessonRequest>.from(requests);

    bool timedOut() =>
        DateTime.now().difference(_startTime) > timeLimit;

    // 6) قائمة الحصص المتاحة لهذا الطلب
    List<_Slot> availableSlots(_LessonRequest r) {
      final slots = <_Slot>[];
      final t = r.teacher;
      final cls = r.assignment.classId;
      final busy = teacherBusy[t.id]!;
      for (var d = 0; d < days; d++) {
        if (t.offDayIndex == d) continue;
        for (var p = 0; p < periodsPerDay; p++) {
          if (grid[cls]![d]![p] != null) continue;
          if (busy.contains(d * 100 + p)) continue;
          slots.add(_Slot(cls, d, p));
        }
      }
      return slots;
    }

    // 7) ترتيب أولوية الحصص (أعلى = أفضل)
    int slotPriority(_LessonRequest r, _Slot slot) {
      var score = 0;

      // تفضيل حصص الفنية/الرياضية
      if (r.assignment.isArtOrSport &&
          r.assignment.preferredPeriods.contains(slot.period)) {
        score += 5000;
      }

      // توزيع المدرس على الأيام (يُفضل ألا يتركز في يوم واحد)
      score -= teacherDayCount[r.teacher.id]![slot.day] * 1000;

      // عدم تكرار نفس المادة في نفس اليوم لنفس الصف
      final sameSubject =
          grid[slot.classId]![slot.day]!.where((l) =>
              l != null && l.subject == r.assignment.subject).length;
      score -= sameSubject * 800;

      // تعبئة الأيام الأقل امتلاءً أولاً (توزيع)
      final filled =
          grid[slot.classId]![slot.day]!.where((l) => l != null).length;
      score -= filled * 50;

      // تفضيل الحصص الأولى
      score -= slot.period * 5;

      // كسر التعادل عشوائياً للتنويع
      score += Random().nextInt(10);

      return score;
    }

    // 8) Backtracking
    bool backtrack() {
      if (timedOut()) return false;
      if (remaining.isEmpty) return true;

      // MRV: اختر الطلب الأكثر تقييداً
      _LessonRequest? best;
      List<_Slot> bestSlots = const [];
      for (final r in remaining) {
        final slots = availableSlots(r);
        if (slots.isEmpty) return false;
        if (best == null || slots.length < bestSlots.length) {
          best = r;
          bestSlots = slots;
        }
      }

      final req = best!;
      final ordered = List<_Slot>.from(bestSlots)
        ..sort((a, b) => slotPriority(req, b).compareTo(slotPriority(req, a)));

      remaining.remove(req);

      for (final slot in ordered) {
        final lesson = Lesson(
          teacherId: req.teacher.id,
          teacherName: req.teacher.name,
          subject: req.assignment.subject,
          classId: slot.classId,
          isArtOrSport: req.assignment.isArtOrSport,
        );
        grid[slot.classId]![slot.day]![slot.period] = lesson;
        teacherBusy[req.teacher.id]!.add(slot.day * 100 + slot.period);
        teacherDayCount[req.teacher.id]![slot.day]++;

        if (backtrack()) return true;

        // تراجع
        grid[slot.classId]![slot.day]![slot.period] = null;
        teacherBusy[req.teacher.id]!.remove(slot.day * 100 + slot.period);
        teacherDayCount[req.teacher.id]![slot.day]--;
      }

      remaining.add(req);
      return false;
    }

    // 9) التشغيل
    if (backtrack()) {
      return ScheduleResult(grid: grid, success: true);
    }
    if (timedOut()) {
      return ScheduleResult(
        grid: grid,
        success: false,
        message:
            'انتهى الوقت دون إيجاد جدول. جرّب تقليل الحصص أو زيادة الأيام أو إزالة بعض القيود.',
      );
    }
    return ScheduleResult(
      grid: grid,
      success: false,
      message:
          'تعذّر إيجاد جدول بدون تضارب. تحقق من البيانات (عدد الحصص، أيام الإجازة).',
    );
  }
}