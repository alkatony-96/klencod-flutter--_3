import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';
import '../models.dart';

class TimetableScreen extends StatefulWidget {
  const TimetableScreen({super.key});
  @override
  State<TimetableScreen> createState() => _TimetableScreenState();
}

class _TimetableScreenState extends State<TimetableScreen> {
  bool _byClass = true;

  @override
  Widget build(BuildContext context) {
    final st = context.watch<AppState>();
    if (st.generated == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('الجدول')),
        body: const Center(child: Text('لم يتم توليد جدول بعد')),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('جدول الحصص'),
        actions: [
          ToggleButtons(
            isSelected: [_byClass, !_byClass],
            onPressed: (i) => setState(() => _byClass = i == 0),
            borderRadius: BorderRadius.circular(8),
            constraints:
                const BoxConstraints(minWidth: 70, minHeight: 36),
            children: const [Text('صف'), Text('مدرس')],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _byClass
          ? _classTabs(context, st)
          : _teacherTabs(context, st),
    );
  }

  Widget _classTabs(BuildContext context, AppState st) {
    final classes = st.classes;
    return DefaultTabController(
      length: classes.length,
      child: Column(
        children: [
          TabBar(
            isScrollable: true,
            tabs: classes.map((c) => Tab(text: c.displayName)).toList(),
          ),
          Expanded(
            child: TabBarView(
              children: classes
                  .map((c) => _gridForClass(context, st, c))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _gridForClass(BuildContext context, AppState st, SchoolClass c) {
    final grid = st.generated![c.id]!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(8),
      child: Table(
        border: TableBorder.all(color: Colors.grey.shade300),
        defaultColumnWidth: const FlexColumnWidth(),
        columnWidths: {0: const IntrinsicColumnWidth()},
        children: [
          TableRow(
            decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer),
            children: [
              const Padding(
                padding: EdgeInsets.all(8),
                child: Text('الحصة', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              for (var d = 0; d < st.settings.days; d++)
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(st.settings.dayNames[d],
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
            ],
          ),
          for (var p = 0; p < st.settings.periodsPerDay; p++)
            TableRow(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text('${p + 1}',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
                for (var d = 0; d < st.settings.days; d++)
                  _cell(grid[d][p]),
              ],
            ),
        ],
      ),
    );
  }

  Widget _cell(Lesson? l) {
    if (l == null) return const SizedBox(height: 40);
    final color = l.isArtOrSport ? Colors.orange.shade100 : Colors.blue.shade50;
    return Container(
      color: color,
      padding: const EdgeInsets.all(6),
      child: Column(
        children: [
          Text(l.subject,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 12)),
          Text(l.teacherName,
              style: const TextStyle(fontSize: 10, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _teacherTabs(BuildContext context, AppState st) {
    final teachers = st.teachers;
    return DefaultTabController(
      length: teachers.length,
      child: Column(
        children: [
          TabBar(
            isScrollable: true,
            tabs: teachers.map((t) => Tab(text: t.name)).toList(),
          ),
          Expanded(
            child: TabBarView(
              children:
                  teachers.map((t) => _gridForTeacher(context, st, t)).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _gridForTeacher(BuildContext context, AppState st, Teacher t) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(8),
      child: Table(
        border: TableBorder.all(color: Colors.grey.shade300),
        defaultColumnWidth: const FlexColumnWidth(),
        columnWidths: {0: const IntrinsicColumnWidth()},
        children: [
          TableRow(
            decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer),
            children: [
              const Padding(
                padding: EdgeInsets.all(8),
                child: Text('الحصة', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              for (var d = 0; d < st.settings.days; d++)
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(st.settings.dayNames[d],
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
            ],
          ),
          for (var p = 0; p < st.settings.periodsPerDay; p++)
            TableRow(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text('${p + 1}',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
                for (var d = 0; d < st.settings.days; d++)
                  _teacherCell(st, t, d, p),
              ],
            ),
        ],
      ),
    );
  }

  Widget _teacherCell(AppState st, Teacher t, int d, int p) {
    // ابحث في كل الصفوف
    for (final c in st.classes) {
      final l = st.generated![c.id]![d][p];
      if (l != null && l.teacherId == t.id) {
        return Container(
          color: l.isArtOrSport ? Colors.orange.shade100 : Colors.blue.shade50,
          padding: const EdgeInsets.all(6),
          child: Column(
            children: [
              Text(l.subject,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 12)),
              Text(c.displayName,
                  style: const TextStyle(fontSize: 10, color: Colors.grey)),
            ],
          ),
        );
      }
    }
    if (t.offDayIndex == d) {
      return Container(
        color: Colors.grey.shade200,
        alignment: Alignment.center,
        child: const Text('إجازة',
            style: TextStyle(fontSize: 11, color: Colors.grey)),
      );
    }
    return const SizedBox(height: 40);
  }
}