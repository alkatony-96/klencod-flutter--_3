import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';
import '../models.dart';

class TeacherEditScreen extends StatefulWidget {
  final String? teacherId;
  const TeacherEditScreen({super.key, this.teacherId});

  @override
  State<TeacherEditScreen> createState() => _TeacherEditScreenState();
}

class _TeacherEditScreenState extends State<TeacherEditScreen> {
  final _nameCtrl = TextEditingController();
  int? _offDay;
  final List<TeacherAssignment> _assignments = [];
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) return;
    _loaded = true;
    if (widget.teacherId != null) {
      final st = context.read<AppState>();
      final t = st.teachers.firstWhere((x) => x.id == widget.teacherId);
      _nameCtrl.text = t.name;
      _offDay = t.offDayIndex;
      _assignments.addAll(t.assignments
          .map((a) => TeacherAssignment(
                id: a.id,
                subject: a.subject,
                classId: a.classId,
                periodsPerWeek: a.periodsPerWeek,
                isArtOrSport: a.isArtOrSport,
                preferredPeriods: Set<int>.from(a.preferredPeriods),
              ))
          .toList());
    }
  }

  @override
  Widget build(BuildContext context) {
    final st = context.watch<AppState>();
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.teacherId == null ? 'مدرس جديد' : 'تعديل المدرس'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _nameCtrl,
            decoration: const InputDecoration(
              labelText: 'اسم المدرس',
              prefixIcon: Icon(Icons.person),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<int?>(
            value: _offDay,
            decoration: const InputDecoration(
              labelText: 'يوم الإجازة (اختياري)',
              prefixIcon: Icon(Icons.event_busy),
              border: OutlineInputBorder(),
            ),
            items: [
              const DropdownMenuItem<int?>(
                  value: null, child: Text('لا يوجد يوم إجازة')),
              for (var i = 0; i < st.settings.days; i++)
                DropdownMenuItem<int?>(
                    value: i, child: Text(st.settings.dayNames[i])),
            ],
            onChanged: (v) => setState(() => _offDay = v),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              const Expanded(
                child: Text('المواد التي يدرّسها',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              FilledButton.tonalIcon(
                icon: const Icon(Icons.add),
                label: const Text('إضافة تكليف'),
                onPressed: st.classes.isEmpty
                    ? () => ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('أضف صفوفاً أولاً من الشاشة الرئيسية')),
                        )
                    : () => _addAssignmentDialog(st),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (_assignments.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('لم تتم إضافة تكليفات بعد',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey)),
            )
          else
            ..._assignments.asMap().entries.map((e) => _assignmentCard(
                e.key, e.value, st)),
          const SizedBox(height: 40),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: FilledButton.icon(
            icon: const Icon(Icons.save),
            label: const Text('حفظ'),
            style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(50)),
            onPressed: () => _save(st),
          ),
        ),
      ),
    );
  }

  Widget _assignmentCard(int i, TeacherAssignment a, AppState st) {
    final cls = st.classById(a.classId);
    final pref = a.isArtOrSport && a.preferredPeriods.isNotEmpty
        ? ' • حصص مفضلة: ${a.preferredPeriods.map((p) => 'ح${p + 1}').join(', ')}'
        : '';
    return Card(
      child: ListTile(
        leading: Icon(
          a.isArtOrSport ? Icons.palette : Icons.book,
          color: a.isArtOrSport ? Colors.orange : Colors.blue,
        ),
        title: Text('${a.subject} → ${cls?.displayName ?? '—'}'),
        subtitle: Text(
            '${a.periodsPerWeek} حصة أسبوعياً${a.isArtOrSport ? ' • فنية/رياضية' : ''}$pref'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, size: 20),
              onPressed: () => _addAssignmentDialog(st, existing: a, index: i),
            ),
            IconButton(
              icon: const Icon(Icons.delete, size: 20, color: Colors.red),
              onPressed: () => setState(() => _assignments.removeAt(i)),
            ),
          ],
        ),
      ),
    );
  }

  void _addAssignmentDialog(AppState st,
      {TeacherAssignment? existing, int? index}) {
    final subjectCtrl =
        TextEditingController(text: existing?.subject ?? '');
    final periodsCtrl = TextEditingController(
        text: existing?.periodsPerWeek.toString() ?? '1');
    String? classId = existing?.classId ??
        (st.classes.isNotEmpty ? st.classes.first.id : null);
    bool isArtOrSport = existing?.isArtOrSport ?? false;
    final preferred = Set<int>.from(existing?.preferredPeriods ?? {});

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setD) => AlertDialog(
          title: Text(existing == null ? 'إضافة تكليف' : 'تعديل التكليف'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: subjectCtrl,
                  decoration: const InputDecoration(
                    labelText: 'اسم المادة',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: classId,
                  decoration: const InputDecoration(
                    labelText: 'الصف والشعبة',
                    border: OutlineInputBorder(),
                  ),
                  items: st.classes
                      .map((c) => DropdownMenuItem(
                          value: c.id, child: Text(c.displayName)))
                      .toList(),
                  onChanged: (v) => setD(() => classId = v),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: periodsCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'عدد الحصص أسبوعياً',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('درس فنية / رياضية'),
                  subtitle:
                      const Text('يمكن تحديد حصص مفضلة لجدولتها'),
                  value: isArtOrSport,
                  onChanged: (v) => setD(() => isArtOrSport = v),
                ),
                if (isArtOrSport) ...[
                  const Align(
                    alignment: Alignment.centerRight,
                    child: Text('الحصص المفضلة:',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: List.generate(
                      st.settings.periodsPerDay,
                      (p) => FilterChip(
                        label: Text('حصة ${p + 1}'),
                        selected: preferred.contains(p),
                        onSelected: (v) => setD(() {
                          v ? preferred.add(p) : preferred.remove(p);
                        }),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('إلغاء')),
            FilledButton(
              onPressed: () {
                final subject = subjectCtrl.text.trim();
                final periods =
                    int.tryParse(periodsCtrl.text.trim()) ?? 0;
                if (subject.isEmpty || classId == null || periods <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('أكمل جميع الحقول بقيم صحيحة')));
                  return;
                }
                final a = TeacherAssignment(
                  id: existing?.id,
                  subject: subject,
                  classId: classId!,
                  periodsPerWeek: periods,
                  isArtOrSport: isArtOrSport,
                  preferredPeriods: preferred,
                );
                setState(() {
                  if (index != null) {
                    _assignments[index] = a;
                  } else {
                    _assignments.add(a);
                  }
                });
                Navigator.pop(ctx);
              },
              child: const Text('حفظ'),
            ),
          ],
        ),
      ),
    );
  }

  void _save(AppState st) {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('أدخل اسم المدرس')));
      return;
    }
    final t = Teacher(
      id: widget.teacherId,
      name: name,
      offDayIndex: _offDay,
      assignments: _assignments,
    );
    if (widget.teacherId == null) {
      st.addTeacher(t);
    } else {
      st.updateTeacher(t);
    }
    Navigator.pop(context);
  }
}