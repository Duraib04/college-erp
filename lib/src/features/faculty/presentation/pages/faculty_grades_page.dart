import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/data_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_card_styles.dart';

class FacultyGradesPage extends StatefulWidget {
  const FacultyGradesPage({super.key});

  @override
  State<FacultyGradesPage> createState() => _FacultyGradesPageState();
}

class _FacultyGradesPageState extends State<FacultyGradesPage> {
  String? _selectedCourse;
  String _examType = 'Internal 1';

  @override
  Widget build(BuildContext context) {
    return Consumer<DataService>(builder: (context, ds, _) {
      final fid = ds.currentUserId ?? '';
      final courses = ds.getFacultyCourses(fid);
      if (_selectedCourse == null && courses.isNotEmpty) {
        _selectedCourse = courses.first['courseId'] as String?;
      }
      final results = _selectedCourse != null
          ? ds.results.where((r) => r['courseId'] == _selectedCourse).toList()
          : <Map<String, dynamic>>[];
      final students = _selectedCourse != null
          ? ds.getCourseStudents(_selectedCourse!)
          : <Map<String, dynamic>>[];

      final gradeMap = <String, int>{};
      for (final r in results) {
        final grade = r['grade'] ?? 'N/A';
        gradeMap[grade] = (gradeMap[grade] ?? 0) + 1;
      }
      final graded = results.where((r) => r['grade'] != null && r['grade'] != '-').length;

      return Scaffold(
        backgroundColor: AppColors.background,
        body: LayoutBuilder(builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 700;
          return SingleChildScrollView(
            padding: EdgeInsets.all(isMobile ? 16 : 28),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.grading_rounded, color: AppColors.primary, size: 24),
                ),
                const SizedBox(width: 14),
                const Expanded(child: Text('Grade Management', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textDark, letterSpacing: -0.3))),
              ]),
              const SizedBox(height: 24),
              // Stats row
              if (isMobile)
                Column(children: [
                  Row(children: [
                    Expanded(child: _statCard('Students', '${students.length}', Icons.people_rounded, const Color(0xFF3B82F6))),
                    const SizedBox(width: 12),
                    Expanded(child: _statCard('Graded', '$graded', Icons.check_circle_rounded, const Color(0xFF10B981))),
                  ]),
                  const SizedBox(height: 12),
                  Row(children: [
                    Expanded(child: _statCard('Pending', '${students.length - graded}', Icons.pending_rounded, const Color(0xFFF97316))),
                    const SizedBox(width: 12),
                    Expanded(child: _statCard('Results', '${results.length}', Icons.assessment_rounded, const Color(0xFF8B5CF6))),
                  ]),
                ])
              else
                Row(children: [
                  Expanded(child: _statCard('Students', '${students.length}', Icons.people_rounded, const Color(0xFF3B82F6))),
                  const SizedBox(width: 14),
                  Expanded(child: _statCard('Graded', '$graded', Icons.check_circle_rounded, const Color(0xFF10B981))),
                  const SizedBox(width: 14),
                  Expanded(child: _statCard('Pending', '${students.length - graded}', Icons.pending_rounded, const Color(0xFFF97316))),
                  const SizedBox(width: 14),
                  Expanded(child: _statCard('Results', '${results.length}', Icons.assessment_rounded, const Color(0xFF8B5CF6))),
                ]),
              const SizedBox(height: 24),
              // Course + exam type selectors
              Container(
                padding: const EdgeInsets.all(16),
                decoration: AppCardStyles.elevated,
                child: Wrap(spacing: 16, runSpacing: 12, children: [
                  SizedBox(
                    width: isMobile ? double.infinity : 300,
                    child: DropdownButtonFormField<String>(
                      initialValue: _selectedCourse,
                      decoration: _inputDeco('Course'),
                      dropdownColor: AppColors.surface,
                      style: const TextStyle(color: AppColors.textDark, fontSize: 14),
                      items: courses.map((c) => DropdownMenuItem(value: c['courseId'] as String?,
                        child: Text('${c['courseId']} - ${c['courseName'] ?? ''}'))).toList(),
                      onChanged: (v) => setState(() => _selectedCourse = v),
                    ),
                  ),
                  SizedBox(
                    width: isMobile ? double.infinity : 200,
                    child: DropdownButtonFormField<String>(
                      initialValue: _examType,
                      decoration: _inputDeco('Exam Type'),
                      dropdownColor: AppColors.surface,
                      style: const TextStyle(color: AppColors.textDark, fontSize: 14),
                      items: ['Internal 1', 'Internal 2', 'Internal 3', 'Model', 'University', 'Assignment', 'Lab']
                          .map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                      onChanged: (v) => setState(() => _examType = v!),
                    ),
                  ),
                ]),
              ),
              const SizedBox(height: 24),
              _buildGradeDistribution(gradeMap),
              const SizedBox(height: 24),
              _buildStudentGrades(students, results, ds),
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

  Widget _buildGradeDistribution(Map<String, int> gradeMap) {
    final grades = ['O', 'A+', 'A', 'B+', 'B', 'C', 'F'];
    final maxCount = gradeMap.values.fold(0, (max, v) => v > max ? v : max);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppCardStyles.elevated,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.bar_chart_rounded, size: 18, color: AppColors.textMedium),
          const SizedBox(width: 8),
          const Text('Grade Distribution', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textDark)),
        ]),
        const SizedBox(height: 16),
        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: grades.map((g) {
          final count = gradeMap[g] ?? 0;
          final height = maxCount > 0 ? (count / maxCount * 100) : 0.0;
          final color = g == 'O' || g == 'A+' ? const Color(0xFF10B981)
              : g == 'A' || g == 'B+' ? const Color(0xFF3B82F6)
              : g == 'F' ? const Color(0xFFF43F5E) : const Color(0xFFF97316);
          return Column(children: [
            Text('$count', style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
            const SizedBox(height: 4),
            Container(width: 30, height: height.clamp(4.0, 100.0),
              decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4))),
            const SizedBox(height: 4),
            Text(g, style: const TextStyle(color: AppColors.textMedium, fontSize: 12)),
          ]);
        }).toList()),
      ]),
    );
  }

  Widget _buildStudentGrades(List<Map<String, dynamic>> students, List<Map<String, dynamic>> results, DataService ds) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppCardStyles.elevated,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.people_alt_rounded, size: 18, color: AppColors.textMedium),
          const SizedBox(width: 8),
          const Expanded(child: Text('Student Grades', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textDark))),
        ]),
        const SizedBox(height: 4),
        Text('Tap a student row to enter/edit marks', style: TextStyle(color: AppColors.textLight, fontSize: 12)),
        const SizedBox(height: 16),
        // Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.04), borderRadius: BorderRadius.circular(8)),
          child: Row(children: const [
            SizedBox(width: 100, child: Text('Roll No', style: TextStyle(color: AppColors.textMedium, fontSize: 12, fontWeight: FontWeight.w600))),
            Expanded(child: Text('Name', style: TextStyle(color: AppColors.textMedium, fontSize: 12, fontWeight: FontWeight.w600))),
            SizedBox(width: 90, child: Text('Marks', style: TextStyle(color: AppColors.textMedium, fontSize: 12, fontWeight: FontWeight.w600))),
            SizedBox(width: 60, child: Text('Grade', style: TextStyle(color: AppColors.textMedium, fontSize: 12, fontWeight: FontWeight.w600))),
            SizedBox(width: 40, child: SizedBox()),
          ]),
        ),
        const SizedBox(height: 8),
        if (students.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 30),
            child: Center(child: Text('No students enrolled', style: TextStyle(color: AppColors.textLight))),
          ),
        ...students.map((s) {
          final sid = s['studentId'] ?? '';
          final matchingResults = results.where((r) => r['studentId'] == sid).toList();
          final hasResult = matchingResults.isNotEmpty;
          final result = hasResult ? matchingResults.first : null;
          final grade = hasResult ? (result!['grade'] ?? '-') : '-';
          final marks = hasResult ? result!['marks']?.toString() ?? '-' : '-';
          final total = hasResult ? result!['totalMarks']?.toString() ?? '100' : '100';
          final gradeColor = grade == 'O' || grade == 'A+' ? const Color(0xFF10B981)
              : grade == 'A' || grade == 'B+' ? const Color(0xFF3B82F6)
              : grade == 'F' ? const Color(0xFFF43F5E) : const Color(0xFFF97316);

          return InkWell(
            onTap: () => _showGradeEntry(context, ds, s, result),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: hasResult ? gradeColor.withValues(alpha: 0.12) : AppColors.border.withValues(alpha: 0.3)),
              ),
              child: Row(children: [
                SizedBox(width: 100, child: Text(sid, style: const TextStyle(color: AppColors.textMedium, fontSize: 13))),
                Expanded(child: Text(s['name'] ?? '', style: const TextStyle(color: AppColors.textDark, fontWeight: FontWeight.w500, fontSize: 14))),
                SizedBox(width: 90, child: Text('$marks/$total', style: TextStyle(color: hasResult ? AppColors.textDark : AppColors.textLight, fontSize: 13))),
                SizedBox(width: 60, child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: gradeColor.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(8)),
                  child: Text(grade, textAlign: TextAlign.center, style: TextStyle(color: gradeColor, fontWeight: FontWeight.w700, fontSize: 13)),
                )),
                const SizedBox(width: 8),
                Icon(Icons.edit_rounded, size: 16, color: AppColors.textMuted.withValues(alpha: 0.4)),
              ]),
            ),
          );
        }),
      ]),
    );
  }

  void _showGradeEntry(BuildContext context, DataService ds, Map<String, dynamic> student, Map<String, dynamic>? existing) {
    final sid = student['studentId'] ?? '';
    final name = student['name'] ?? '';
    final marksCtrl = TextEditingController(text: existing?['marks']?.toString() ?? '');
    final totalCtrl = TextEditingController(text: existing?['totalMarks']?.toString() ?? '100');
    String selectedGrade = existing?['grade']?.toString() ?? 'O';
    final grades = ['O', 'A+', 'A', 'B+', 'B', 'C', 'F', 'AB'];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setDlgState) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: const Color(0xFF10B981).withValues(alpha: 0.08), borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.grading_rounded, color: Color(0xFF10B981), size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(existing != null ? 'Edit Grade' : 'Enter Grade', style: const TextStyle(color: AppColors.textDark, fontSize: 16, fontWeight: FontWeight.w600)),
              Text('$sid — $name', style: const TextStyle(color: AppColors.textLight, fontSize: 12)),
            ])),
          ]),
          content: SizedBox(
            width: 380,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(10)),
                child: Row(children: [
                  const Icon(Icons.class_rounded, size: 16, color: AppColors.textMedium),
                  const SizedBox(width: 8),
                  Text('$_selectedCourse • $_examType', style: const TextStyle(color: AppColors.textDark, fontSize: 13, fontWeight: FontWeight.w500)),
                ]),
              ),
              const SizedBox(height: 16),
              Row(children: [
                Expanded(child: TextField(
                  controller: marksCtrl,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: AppColors.textDark, fontSize: 18, fontWeight: FontWeight.w700),
                  textAlign: TextAlign.center,
                  decoration: _inputDeco('Marks'),
                )),
                const SizedBox(width: 12),
                Expanded(child: TextField(
                  controller: totalCtrl,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: AppColors.textDark, fontSize: 18, fontWeight: FontWeight.w700),
                  textAlign: TextAlign.center,
                  decoration: _inputDeco('Total'),
                )),
              ]),
              const SizedBox(height: 16),
              const Align(alignment: Alignment.centerLeft, child: Text('Grade', style: TextStyle(color: AppColors.textMedium, fontSize: 13, fontWeight: FontWeight.w600))),
              const SizedBox(height: 8),
              Wrap(spacing: 8, runSpacing: 8, children: grades.map((g) {
                final isSelected = selectedGrade == g;
                final color = g == 'O' || g == 'A+' ? const Color(0xFF10B981)
                    : g == 'A' || g == 'B+' ? const Color(0xFF3B82F6)
                    : g == 'F' ? const Color(0xFFF43F5E) : const Color(0xFFF97316);
                return InkWell(
                  onTap: () => setDlgState(() => selectedGrade = g),
                  borderRadius: BorderRadius.circular(10),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? color.withValues(alpha: 0.12) : AppColors.background,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: isSelected ? color : AppColors.border, width: isSelected ? 2 : 1),
                    ),
                    child: Text(g, style: TextStyle(
                      color: isSelected ? color : AppColors.textMedium,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      fontSize: 14,
                    )),
                  ),
                );
              }).toList()),
            ]),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
            ElevatedButton.icon(
              onPressed: () {
                final marks = int.tryParse(marksCtrl.text);
                final total = int.tryParse(totalCtrl.text) ?? 100;
                if (marks == null || marks < 0 || marks > total) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Enter valid marks (0–$total)'),
                    backgroundColor: const Color(0xFFF43F5E),
                  ));
                  return;
                }
                if (existing != null && existing['resultId'] != null) {
                  ds.updateResult(existing['resultId'] as String, {
                    'marks': marks,
                    'totalMarks': total,
                    'grade': selectedGrade,
                    'examType': _examType,
                    'gradedDate': DateTime.now().toIso8601String().substring(0, 10),
                    'gradedBy': ds.currentUserId ?? '',
                  });
                } else {
                  ds.addResult({
                    'studentId': sid,
                    'courseId': _selectedCourse,
                    'marks': marks,
                    'totalMarks': total,
                    'grade': selectedGrade,
                    'examType': _examType,
                    'gradedDate': DateTime.now().toIso8601String().substring(0, 10),
                    'gradedBy': ds.currentUserId ?? '',
                  });
                }
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('$name — $selectedGrade ($marks/$total)'),
                  backgroundColor: const Color(0xFF10B981),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  margin: const EdgeInsets.all(16),
                ));
              },
              icon: const Icon(Icons.check_rounded, size: 16),
              label: Text(existing != null ? 'Update' : 'Save Grade'),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), foregroundColor: Colors.white),
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
