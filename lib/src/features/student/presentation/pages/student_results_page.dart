import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/data_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_card_styles.dart';

class StudentResultsPage extends StatelessWidget {
  const StudentResultsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DataService>(builder: (context, ds, _) {
      if (!ds.isLoaded) {
        return const Scaffold(backgroundColor: AppColors.background, body: Center(child: CircularProgressIndicator()));
      }
      final studentId = ds.currentUserId ?? '';
      final resultsList = ds.getStudentResultsFiltered(studentId);
      final cgpa = ds.currentCGPA;

      return Scaffold(
        backgroundColor: AppColors.background,
        body: LayoutBuilder(builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 700;
          return SingleChildScrollView(
            padding: EdgeInsets.all(isMobile ? 16 : 24),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: const [
                Icon(Icons.assessment, color: AppColors.primary, size: 28),
                SizedBox(width: 12),
                Text('Examination Results', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textDark)),
              ]),
              const SizedBox(height: 8),
              const Text('Your examination performance', style: TextStyle(color: AppColors.textLight, fontSize: 14)),
              const SizedBox(height: 24),
              _buildCGPACard(cgpa),
              const SizedBox(height: 24),
              _buildResultsTable(resultsList, isMobile),
            ]),
          );
        }),
      );
    });
  }

  Widget _buildCGPACard(double cgpa) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.4)),
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Icon(Icons.emoji_events, color: AppColors.accent, size: 32),
        const SizedBox(width: 16),
        Column(children: [
          const Text('Current CGPA', style: TextStyle(color: AppColors.accent, fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(cgpa.toStringAsFixed(1), style: const TextStyle(color: AppColors.accent, fontSize: 36, fontWeight: FontWeight.bold)),
        ]),
      ]),
    );
  }

  Widget _buildResultsTable(List<Map<String, dynamic>> resultsList, bool isMobile) {
    final tableWidget = Table(
      columnWidths: const {0: FixedColumnWidth(80), 1: FlexColumnWidth(2), 2: FixedColumnWidth(80), 3: FixedColumnWidth(60), 4: FixedColumnWidth(60), 5: FixedColumnWidth(50), 6: FixedColumnWidth(60)},
      children: [
        TableRow(
          decoration: BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border))),
          children: ['Code', 'Subject', 'Exam Type', 'Marks', 'Grade', 'GP', 'Status'].map((h) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(h, style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold, fontSize: 12)),
          )).toList(),
        ),
        ...resultsList.map((r) {
          final grade = r['grade'] as String? ?? '-';
          Color gradeColor = grade == 'A' ? Colors.green : grade == 'B' ? Colors.blue : grade == 'C' ? Colors.orange : grade == 'F' ? Colors.redAccent : AppColors.textDark;
          final status = r['status'] as String? ?? '';
          Color statusColor = status == 'Pass' ? Colors.green : status == 'Absent' ? Colors.orange : Colors.redAccent;
          return TableRow(children: [
            Padding(padding: const EdgeInsets.symmetric(vertical: 10), child: Text(r['courseCode'] as String? ?? '', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 12))),
            Padding(padding: const EdgeInsets.symmetric(vertical: 10), child: Text(r['courseName'] as String? ?? '', style: const TextStyle(color: AppColors.textDark, fontSize: 12))),
            Padding(padding: const EdgeInsets.symmetric(vertical: 10), child: Text(r['examType'] as String? ?? '', style: const TextStyle(color: AppColors.textMedium, fontSize: 12))),
            Padding(padding: const EdgeInsets.symmetric(vertical: 10), child: Text('${r['obtainedMarks'] ?? 0}/${r['maxMarks'] ?? 0}', style: const TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold, fontSize: 12))),
            Padding(padding: const EdgeInsets.symmetric(vertical: 10), child: Text(grade, style: TextStyle(color: gradeColor, fontWeight: FontWeight.bold, fontSize: 12))),
            Padding(padding: const EdgeInsets.symmetric(vertical: 10), child: Text('${r['gradePoint'] ?? 0}', style: const TextStyle(color: AppColors.textMedium, fontSize: 12))),
            Padding(padding: const EdgeInsets.symmetric(vertical: 10), child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(4)),
              child: Text(status, style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold)),
            )),
          ]);
        }),
      ],
    );

    return Container(
      padding: EdgeInsets.all(isMobile ? 12 : 20),
      decoration: AppCardStyles.elevated,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Exam Results', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark)),
        const SizedBox(height: 16),
        isMobile
            ? SingleChildScrollView(scrollDirection: Axis.horizontal, child: ConstrainedBox(constraints: const BoxConstraints(minWidth: 600), child: tableWidget))
            : tableWidget,
      ]),
    );
  }
}
