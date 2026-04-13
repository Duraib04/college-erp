import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/data_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_card_styles.dart';

class HodStudentsPage extends StatelessWidget {
  const HodStudentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DataService>(builder: (context, ds, _) {
      if (!ds.isLoaded) return const Scaffold(backgroundColor: AppColors.background, body: Center(child: CircularProgressIndicator()));

      final deptId = ds.currentFaculty?['departmentId'] as String? ?? '';
      final deptStudents = ds.getDepartmentStudents(deptId);
      final deptClasses = ds.getDepartmentClasses(deptId);

      return Scaffold(
        backgroundColor: AppColors.background,
        body: LayoutBuilder(builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 700;
          return SingleChildScrollView(
            padding: EdgeInsets.all(isMobile ? 16 : 24),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: const [
                Icon(Icons.school, color: AppColors.primary, size: 28),
                SizedBox(width: 12),
                Text('Department Students', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textDark)),
              ]),
              const SizedBox(height: 8),
              Text('${ds.getDepartmentCode(deptId)} Department - ${deptStudents.length} students', style: const TextStyle(color: AppColors.textLight, fontSize: 14)),
              const SizedBox(height: 20),
              // Group by class
              ...deptClasses.map((cls) {
                final classStudentIds = (cls['studentIds'] as List<dynamic>?)?.cast<String>() ?? [];
                final classStudents = classStudentIds.map((id) => ds.getStudentById(id)).where((s) => s != null).toList();
                if (classStudents.isEmpty) return const SizedBox.shrink();

                return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(8)),
                    child: Row(children: [
                      const Icon(Icons.class_, color: AppColors.primary, size: 18),
                      const SizedBox(width: 8),
                      Text('Year ${cls['year']} - Section ${cls['section']}', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 14)),
                      const Spacer(),
                      Text('${classStudents.length} students', style: const TextStyle(color: AppColors.textLight, fontSize: 12)),
                    ]),
                  ),
                  const SizedBox(height: 8),
                  ...classStudents.map((s) {
                    final mentorId = s?['mentorId'] as String?;
                    final mentorName = mentorId != null ? ds.getFacultyName(mentorId) : 'Not Assigned';
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(14),
                      decoration: AppCardStyles.raised,
                      child: Row(children: [
                        CircleAvatar(radius: 18, backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                          child: Text((s?['name'] as String? ?? '?')[0].toUpperCase(), style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 14))),
                        const SizedBox(width: 12),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(s?['name'] as String? ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textDark)),
                          Text('${s?['studentId'] ?? ''} | CGPA: ${s?['cgpa'] ?? 'N/A'} | Mentor: $mentorName', style: const TextStyle(color: AppColors.textLight, fontSize: 12)),
                        ])),
                      ]),
                    );
                  }),
                  const SizedBox(height: 16),
                ]);
              }),
            ]),
          );
        }),
      );
    });
  }
}
