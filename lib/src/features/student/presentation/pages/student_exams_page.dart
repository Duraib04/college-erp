import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/data_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_card_styles.dart';

class StudentExamsPage extends StatelessWidget {
  const StudentExamsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DataService>(builder: (context, ds, _) {
      final uid = ds.currentUserId ?? '';
      final exams = ds.getStudentExams(uid);
      final internal = exams.where((e) => (e['type'] ?? '').toString().toLowerCase().contains('internal')).toList();
      final external_ = exams.where((e) => !(e['type'] ?? '').toString().toLowerCase().contains('internal')).toList();
      return Scaffold(
        backgroundColor: AppColors.background,
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: const [
                Icon(Icons.event_note, color: AppColors.primary, size: 28),
                SizedBox(width: 12),
                Text('Exam Schedule', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textDark)),
              ]),
              const SizedBox(height: 8),
              const Text('Upcoming Internal & External Examinations', style: TextStyle(color: AppColors.textLight, fontSize: 14)),
              const SizedBox(height: 24),
              if (exams.isNotEmpty) _buildNextExamCountdown(exams.first),
              const SizedBox(height: 24),
              if (internal.isNotEmpty) _buildExamSection('Internal Assessments', internal, Colors.orange),
              const SizedBox(height: 24),
              if (external_.isNotEmpty) _buildExamSection('End Semester Examinations', external_, Colors.redAccent),
              if (exams.isEmpty)
                const Center(child: Padding(padding: EdgeInsets.all(40), child: Text('No upcoming exams', style: TextStyle(color: AppColors.textLight, fontSize: 16)))),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildNextExamCountdown(Map<String, dynamic> exam) {
    final daysLeft = DateTime.tryParse(exam['date'] ?? '')?.difference(DateTime.now()).inDays ?? 0;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [AppColors.primary, AppColors.primary]),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.timer, color: Colors.white, size: 40),
          const SizedBox(width: 20),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Next Exam', style: TextStyle(color: Colors.white70, fontSize: 14)),
              const SizedBox(height: 4),
              Text('${exam['courseId'] ?? ''} - ${exam['examName'] ?? ''}', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              Text('${exam['date'] ?? ''} | ${exam['time'] ?? ''} | ${exam['venue'] ?? ''}', style: const TextStyle(color: Colors.white70, fontSize: 14)),
            ],
          )),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: [
                Text('$daysLeft', style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)),
                const Text('DAYS LEFT', style: TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExamSection(String title, List<Map<String, dynamic>> exams, Color accentColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppCardStyles.elevated,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(width: 4, height: 20, decoration: BoxDecoration(color: accentColor, borderRadius: BorderRadius.circular(2))),
            const SizedBox(width: 10),
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark)),
          ]),
          const SizedBox(height: 16),
          ...exams.map((e) => Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(8)),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(color: accentColor.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(6)),
                  child: Text(e['type'] ?? '', style: TextStyle(color: accentColor, fontSize: 11, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 14),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('${e['courseId'] ?? ''} - ${e['examName'] ?? ''}', style: const TextStyle(color: AppColors.textDark, fontWeight: FontWeight.w600, fontSize: 14)),
                  const SizedBox(height: 4),
                  Text('Syllabus: ${e['syllabus'] ?? 'All Units'}', style: const TextStyle(color: AppColors.textLight, fontSize: 12)),
                ])),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Text(e['date'] ?? '', style: const TextStyle(color: AppColors.textMedium, fontSize: 13)),
                  const SizedBox(height: 2),
                  Text('${e['time'] ?? ''} | ${e['venue'] ?? ''}', style: const TextStyle(color: AppColors.textLight, fontSize: 12)),
                ]),
              ],
            ),
          )),
        ],
      ),
    );
  }
}
