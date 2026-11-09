import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';
import '../models.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late int _days;
  late int _periods;
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) return;
    _loaded = true;
    final s = context.read<AppState>().settings;
    _days = s.days;
    _periods = s.periodsPerDay;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('إعدادات الجدول')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('عدد أيام الدراسة: $_days',
              style: const TextStyle(fontSize: 16)),
          Slider(
            value: _days.toDouble(),
            min: 1,
            max: 7,
            divisions: 6,
            label: '$_days',
            onChanged: (v) => setState(() => _days = v.round()),
          ),
          const SizedBox(height: 12),
          Text('عدد الحصص في اليوم: $_periods',
              style: const TextStyle(fontSize: 16)),
          Slider(
            value: _periods.toDouble(),
            min: 3,
            max: 10,
            divisions: 7,
            label: '$_periods',
            onChanged: (v) => setState(() => _periods = v.round()),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            icon: const Icon(Icons.save),
            label: const Text('حفظ الإعدادات'),
            onPressed: () {
              final st = context.read<AppState>();
              st.updateSettings(ScheduleSettings(
                days: _days,
                periodsPerDay: _periods,
                dayNames: st.settings.dayNames,
              ));
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}