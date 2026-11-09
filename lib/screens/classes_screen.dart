import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';
import '../models.dart';

class ClassesScreen extends StatelessWidget {
  const ClassesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final st = context.watch<AppState>();
    return Scaffold(
      appBar: AppBar(title: const Text('الصفوف')),
      body: st.classes.isEmpty
          ? const Center(child: Text('لا يوجد صفوف بعد'))
          : ListView.builder(
              itemCount: st.classes.length,
              itemBuilder: (context, i) {
                final c = st.classes[i];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    leading: const Icon(Icons.class_, color: Colors.blue),
                    title: Text(c.displayName),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => st.removeClass(c.id),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('صف جديد'),
        onPressed: () => _addDialog(context, st),
      ),
    );
  }

  void _addDialog(BuildContext ctx, AppState st) {
    final gradeCtrl = TextEditingController();
    final sectionCtrl = TextEditingController();
    showDialog(
      context: ctx,
      builder: (c) => AlertDialog(
        title: const Text('صف جديد'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: gradeCtrl,
              decoration: const InputDecoration(
                labelText: 'الصف (مثال: الأول)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: sectionCtrl,
              decoration: const InputDecoration(
                labelText: 'الشعبة (مثال: أ)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(c), child: const Text('إلغاء')),
          FilledButton(
            onPressed: () {
              final g = gradeCtrl.text.trim();
              final s = sectionCtrl.text.trim();
              if (g.isEmpty || s.isEmpty) return;
              st.addClass(SchoolClass(grade: g, section: s));
              Navigator.pop(c);
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }
}