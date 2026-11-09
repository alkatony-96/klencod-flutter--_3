import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';
import 'teacher_edit_screen.dart';

class TeachersScreen extends StatelessWidget {
  const TeachersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final st = context.watch<AppState>();
    return Scaffold(
      appBar: AppBar(title: const Text('المدرسون')),
      body: st.teachers.isEmpty
          ? const Center(child: Text('لا يوجد مدرسون بعد'))
          : ListView.builder(
              itemCount: st.teachers.length,
              itemBuilder: (context, i) {
                final t = st.teachers[i];
                final day = t.offDayIndex != null
                    ? st.settings.dayNames[t.offDayIndex!]
                    : 'لا يوجد';
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    title: Text(t.name,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('إجمالي الحصص: ${t.totalPeriods}'),
                        Text('يوم الإجازة: $day'),
                        Text('عدد التكليفات: ${t.assignments.length}'),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) =>
                                    TeacherEditScreen(teacherId: t.id)),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () =>
                              _confirmDelete(context, st, t.id, t.name),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('مدرس جديد'),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const TeacherEditScreen()),
        ),
      ),
    );
  }

  void _confirmDelete(
      BuildContext ctx, AppState st, String id, String name) {
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text('هل تريد حذف المدرس "$name"؟'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          FilledButton(
              onPressed: () {
                st.removeTeacher(id);
                Navigator.pop(ctx);
              },
              child: const Text('حذف')),
        ],
      ),
    );
  }
}