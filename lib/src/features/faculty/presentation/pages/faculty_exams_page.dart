import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../core/data_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_card_styles.dart';

class FacultyExamsPage extends StatefulWidget {
  const FacultyExamsPage({super.key});

  @override
  State<FacultyExamsPage> createState() => _FacultyExamsPageState();
}

class _FacultyExamsPageState extends State<FacultyExamsPage> {

  @override
  Widget build(BuildContext context) {
    return Consumer<DataService>(builder: (context, ds, _) {
      final fid = ds.currentUserId ?? '';
      final exams = ds.getFacultyExams(fid);
      final courses = ds.getFacultyCourses(fid);
      final upcoming = exams.where((e) {
        final d = e['date'] as String? ?? '';
        return d.compareTo(DateTime.now().toIso8601String().substring(0, 10)) >= 0;
      }).length;

      return Scaffold(
        backgroundColor: AppColors.background,
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _showScheduleExam(context, ds, courses),
          backgroundColor: AppColors.primary,
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text('Schedule Exam', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        ),
        body: LayoutBuilder(builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 700;
          return SingleChildScrollView(
            padding: EdgeInsets.all(isMobile ? 16 : 28),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.quiz_rounded, color: AppColors.primary, size: 24),
                ),
                const SizedBox(width: 14),
                const Expanded(child: Text('Exam Management', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textDark, letterSpacing: -0.3))),
              ]),
              const SizedBox(height: 24),
              if (isMobile)
                Column(children: [
                  Row(children: [
                    Expanded(child: _statCard('Total', '${exams.length}', Icons.event_note_rounded, const Color(0xFF3B82F6))),
                    const SizedBox(width: 12),
                    Expanded(child: _statCard('Upcoming', '$upcoming', Icons.upcoming_rounded, const Color(0xFF10B981))),
                  ]),
                  const SizedBox(height: 12),
                  Row(children: [
                    Expanded(child: _statCard('Courses', '${courses.length}', Icons.class_rounded, const Color(0xFF8B5CF6))),
                    const SizedBox(width: 12),
                    Expanded(child: _statCard('Completed', '${exams.length - upcoming}', Icons.check_circle_rounded, const Color(0xFFF97316))),
                  ]),
                ])
              else
                Row(children: [
                  Expanded(child: _statCard('Total', '${exams.length}', Icons.event_note_rounded, const Color(0xFF3B82F6))),
                  const SizedBox(width: 14),
                  Expanded(child: _statCard('Upcoming', '$upcoming', Icons.upcoming_rounded, const Color(0xFF10B981))),
                  const SizedBox(width: 14),
                  Expanded(child: _statCard('Courses', '${courses.length}', Icons.class_rounded, const Color(0xFF8B5CF6))),
                  const SizedBox(width: 14),
                  Expanded(child: _statCard('Completed', '${exams.length - upcoming}', Icons.check_circle_rounded, const Color(0xFFF97316))),
                ]),
              const SizedBox(height: 28),
              _buildExamList(exams, ds),
            ]),
          );
        }),
      );
    });
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppCardStyles.statCard(color),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: color.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(height: 10),
        Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textDark, letterSpacing: -0.3)),
        Text(label, style: const TextStyle(color: AppColors.textLight, fontSize: 11, fontWeight: FontWeight.w500)),
      ]),
    );
  }

  Widget _buildExamList(List<Map<String, dynamic>> exams, DataService ds) {
    if (exams.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 60),
        decoration: AppCardStyles.elevated,
        child: Center(child: Column(children: [
          Icon(Icons.quiz_outlined, size: 48, color: AppColors.textMuted.withValues(alpha: 0.3)),
          const SizedBox(height: 12),
          const Text('No exams scheduled', style: TextStyle(color: AppColors.textMedium, fontSize: 15, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          const Text('Tap + to schedule one', style: TextStyle(color: AppColors.textLight, fontSize: 13)),
        ])),
      );
    }
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppCardStyles.elevated,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.list_alt_rounded, size: 18, color: AppColors.textMedium),
          const SizedBox(width: 8),
          const Text('Exam Schedule', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textDark)),
        ]),
        const SizedBox(height: 16),
        ...exams.map((e) {
          final type = (e['type'] ?? '').toString();
          final isInternal = type.toLowerCase().contains('internal');
          final color = isInternal ? const Color(0xFFF97316) : const Color(0xFFF43F5E);
          final examId = e['examId'] as String? ?? '';
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: AppColors.surface, borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withValues(alpha: 0.12)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(color: color.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(8)),
                  child: Text(type, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700)),
                ),
                const SizedBox(width: 14),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('${e['courseId'] ?? ''} - ${e['examName'] ?? ''}', style: const TextStyle(color: AppColors.textDark, fontWeight: FontWeight.w600, fontSize: 14)),
                  const SizedBox(height: 2),
                  Text('${e['date'] ?? ''} | ${e['time'] ?? ''} | ${e['venue'] ?? ''}', style: const TextStyle(color: AppColors.textLight, fontSize: 12)),
                ])),
                PopupMenuButton<String>(
                  onSelected: (v) {
                    if (v == 'delete') {
                      ds.deleteExam(examId);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Exam deleted'),
                        backgroundColor: Color(0xFFF43F5E),
                      ));
                    }
                  },
                  itemBuilder: (ctx) => [
                    const PopupMenuItem(value: 'delete', child: Row(children: [
                      Icon(Icons.delete_outline, size: 16, color: Color(0xFFF43F5E)),
                      SizedBox(width: 8),
                      Text('Delete', style: TextStyle(color: Color(0xFFF43F5E), fontSize: 13)),
                    ])),
                  ],
                  icon: const Icon(Icons.more_vert, size: 18, color: AppColors.textMuted),
                ),
              ]),
            ),
          );
        }),
      ]),
    );
  }

  void _showScheduleExam(BuildContext context, DataService ds, List<Map<String, dynamic>> courses) {
    final nameCtrl = TextEditingController();
    final dateCtrl = TextEditingController();
    final timeCtrl = TextEditingController();
    final venueCtrl = TextEditingController(text: 'Exam Hall');
    String? selectedCourseId = courses.isNotEmpty ? courses.first['courseId'] as String : null;
    String examType = 'Internal';
    final types = ['Internal', 'Model', 'University', 'Lab', 'Practical', 'Viva'];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setDlgState) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.event_note_rounded, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 12),
            const Text('Schedule Exam', style: TextStyle(color: AppColors.textDark, fontSize: 17, fontWeight: FontWeight.w600)),
          ]),
          content: SizedBox(
            width: 420,
            child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
              DropdownButtonFormField<String>(
                initialValue: selectedCourseId,
                decoration: _inputDeco('Course'),
                dropdownColor: AppColors.surface,
                style: const TextStyle(color: AppColors.textDark, fontSize: 14),
                items: courses.map((c) => DropdownMenuItem(value: c['courseId'] as String,
                  child: Text('${c['courseId']} - ${c['courseName']}'))).toList(),
                onChanged: (v) => setDlgState(() => selectedCourseId = v),
              ),
              const SizedBox(height: 12),
              TextField(controller: nameCtrl, style: const TextStyle(color: AppColors.textDark), decoration: _inputDeco('Exam Name')),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: examType,
                decoration: _inputDeco('Type'),
                dropdownColor: AppColors.surface,
                style: const TextStyle(color: AppColors.textDark, fontSize: 14),
                items: types.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                onChanged: (v) => setDlgState(() => examType = v!),
              ),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: TextField(
                  controller: dateCtrl, style: const TextStyle(color: AppColors.textDark),
                  decoration: _inputDeco('Date'), readOnly: true,
                  onTap: () async {
                    final picked = await showDatePicker(context: ctx, initialDate: DateTime.now().add(const Duration(days: 7)),
                      firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 365)));
                    if (picked != null) dateCtrl.text = DateFormat('yyyy-MM-dd').format(picked);
                  },
                )),
                const SizedBox(width: 12),
                Expanded(child: TextField(controller: timeCtrl, style: const TextStyle(color: AppColors.textDark), decoration: _inputDeco('Time (e.g. 10:00 AM)'))),
              ]),
              const SizedBox(height: 12),
              TextField(controller: venueCtrl, style: const TextStyle(color: AppColors.textDark), decoration: _inputDeco('Venue')),
            ])),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
            ElevatedButton.icon(
              onPressed: () {
                if (nameCtrl.text.isEmpty || selectedCourseId == null || dateCtrl.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Course, name, and date are required'),
                    backgroundColor: Color(0xFFF43F5E),
                  ));
                  return;
                }
                ds.addExam({
                  'courseId': selectedCourseId,
                  'examName': nameCtrl.text,
                  'type': examType,
                  'date': dateCtrl.text,
                  'time': timeCtrl.text.isNotEmpty ? timeCtrl.text : 'TBD',
                  'venue': venueCtrl.text.isNotEmpty ? venueCtrl.text : 'TBD',
                  'createdBy': ds.currentUserId ?? '',
                });
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('Exam "${nameCtrl.text}" scheduled!'),
                  backgroundColor: const Color(0xFF10B981),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  margin: const EdgeInsets.all(16),
                ));
              },
              icon: const Icon(Icons.check_rounded, size: 16),
              label: const Text('Schedule'),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
            ),
          ],
        );
      }),
    );
  }

  InputDecoration _inputDeco(String label) {
    return InputDecoration(
      labelText: label, labelStyle: const TextStyle(color: AppColors.textLight, fontSize: 13),
      filled: true, fillColor: AppColors.background,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: AppColors.border)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: AppColors.border)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
    );
  }
}
