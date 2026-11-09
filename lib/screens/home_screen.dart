import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';
import 'teachers_screen.dart';
import 'classes_screen.dart';
import 'timetable_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final st = context.watch<AppState>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('جدول الحصص المدرسي'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                _StatCard(
                    label: 'المدرسون',
                    value: '${st.teachers.length}',
                    icon: Icons.person),
                const SizedBox(width: 12),
                _StatCard(
                    label: 'الصفوف',
                    value: '${st.classes.length}',
                    icon: Icons.class_),
              ],
            ),
            const SizedBox(height: 16),
            _MenuTile(
              icon: Icons.people,
              title: 'إدارة المدرسين',
              subtitle: 'اسم المدرس • المواد • الحصص • يوم الإجازة',
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const TeachersScreen())),
            ),
            _MenuTile(
              icon: Icons.school,
              title: 'إدارة الصفوف',
              subtitle: 'الصف • الشعبة',
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const ClassesScreen())),
            ),
            _MenuTile(
              icon: Icons.settings,
              title: 'إعدادات الجدول',
              subtitle: 'عدد الأيام • الحصص في اليوم',
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const SettingsScreen())),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: FilledButton.icon(
                icon: const Icon(Icons.auto_awesome),
                label: const Text('توليد الجدول تلقائياً',
                    style: TextStyle(fontSize: 16)),
                onPressed: () async {
                  if (st.classes.isEmpty || st.teachers.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text(
                            'أضف مدرسين وصفوفاً أولاً قبل توليد الجدول')));
                    return;
                  }
                  final res = st.generate();
                  if (res.success) {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const TimetableScreen()));
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(res.message ?? 'فشل التوليد'),
                      backgroundColor: Colors.red,
                    ));
                  }
                },
              ),
            ),
            const SizedBox(height: 8),
            if (st.generated != null)
              TextButton.icon(
                icon: const Icon(Icons.table_chart),
                label: const Text('عرض الجدول الحالي'),
                onPressed: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const TimetableScreen())),
              ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label, value;
  final IconData icon;
  const _StatCard({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(icon, size: 32, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(value,
                      style: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.bold)),
                  Text(label, style: const TextStyle(fontSize: 12)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String title, subtitle;
  final VoidCallback onTap;
  const _MenuTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14),
        onTap: onTap,
      ),
    );
  }
}