import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/data_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_card_styles.dart';

class HodClassAdvisersPage extends StatefulWidget {
  const HodClassAdvisersPage({super.key});
  @override
  State<HodClassAdvisersPage> createState() => _HodClassAdvisersPageState();
}

class _HodClassAdvisersPageState extends State<HodClassAdvisersPage> {
  @override
  Widget build(BuildContext context) {
    return Consumer<DataService>(builder: (context, ds, _) {
      if (!ds.isLoaded) return const Scaffold(backgroundColor: AppColors.background, body: Center(child: CircularProgressIndicator()));

      final deptId = ds.currentFaculty?['departmentId'] as String? ?? '';
      final deptClasses = ds.getDepartmentClasses(deptId);
      final deptFaculty = ds.getDepartmentFaculty(deptId);

      return Scaffold(
        backgroundColor: AppColors.background,
        body: LayoutBuilder(builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 700;
          return SingleChildScrollView(
            padding: EdgeInsets.all(isMobile ? 16 : 24),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: const [
                Icon(Icons.person_pin, color: AppColors.primary, size: 28),
                SizedBox(width: 12),
                Text('Class Adviser Assignment', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textDark)),
              ]),
              const SizedBox(height: 8),
              Text('Assign class advisers for ${ds.getDepartmentCode(deptId)} department', style: const TextStyle(color: AppColors.textLight, fontSize: 14)),
              const SizedBox(height: 20),
              ...deptClasses.map((cls) {
                final adviserId = cls['classAdviserId'] as String? ?? '';
                final adviserName = adviserId.isNotEmpty ? ds.getFacultyName(adviserId) : 'Not Assigned';
                final studentCount = (cls['studentIds'] as List<dynamic>?)?.length ?? 0;
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: AppCardStyles.elevated,
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
                        child: Text('Year ${cls['year']} - Section ${cls['section']}', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 14))),
                      const Spacer(),
                      Text('$studentCount students', style: const TextStyle(color: AppColors.textLight, fontSize: 13)),
                    ]),
                    const SizedBox(height: 12),
                    Row(children: [
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        const Text('Current Adviser:', style: TextStyle(color: AppColors.textLight, fontSize: 12)),
                        const SizedBox(height: 4),
                        Text(adviserName, style: TextStyle(color: adviserId.isNotEmpty ? AppColors.textDark : Colors.orange, fontWeight: FontWeight.bold, fontSize: 15)),
                      ])),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.edit, size: 16),
                        label: Text(adviserId.isNotEmpty ? 'Change' : 'Assign'),
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                        onPressed: () => _showAssignDialog(context, ds, cls, deptFaculty),
                      ),
                    ]),
                  ]),
                );
              }),
            ]),
          );
        }),
      );
    });
  }

  void _showAssignDialog(BuildContext context, DataService ds, Map<String, dynamic> cls, List<Map<String, dynamic>> facultyList) {
    showDialog(context: context, builder: (ctx) {
      return AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('Assign Adviser - Year ${cls['year']} Sec ${cls['section']}', style: const TextStyle(color: AppColors.textDark, fontSize: 16)),
        content: SizedBox(
          width: 350,
          child: ListView(
            shrinkWrap: true,
            children: facultyList.map((f) {
              final isCurrentAdviser = cls['classAdviserId'] == f['facultyId'];
              return ListTile(
                leading: CircleAvatar(radius: 18, backgroundColor: isCurrentAdviser ? AppColors.secondary.withValues(alpha: 0.2) : AppColors.primary.withValues(alpha: 0.1),
                  child: Icon(Icons.person, size: 18, color: isCurrentAdviser ? AppColors.secondary : AppColors.primary)),
                title: Text(f['name'] as String? ?? '', style: TextStyle(color: AppColors.textDark, fontWeight: isCurrentAdviser ? FontWeight.bold : FontWeight.normal, fontSize: 14)),
                subtitle: Text(f['designation'] as String? ?? '', style: const TextStyle(color: AppColors.textLight, fontSize: 12)),
                trailing: isCurrentAdviser ? const Icon(Icons.check_circle, color: AppColors.secondary, size: 20) : null,
                onTap: () {
                  ds.assignClassAdviser(cls['classId'] as String, f['facultyId'] as String);
                  Navigator.pop(ctx);
                  setState(() {});
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${f['name']} assigned as class adviser'), backgroundColor: AppColors.secondary, behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))));
                },
              );
            }).toList(),
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel'))],
      );
    });
  }
}
