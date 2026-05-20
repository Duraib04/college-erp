import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/data_service.dart';

class PlacementDriveListPage extends StatelessWidget {
  const PlacementDriveListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ds = Provider.of<DataService>(context);
    final drives = ds.placementDrives;
    final isStudent = ds.currentRole == 'student';
    final studentId = ds.currentUserId;

    return Scaffold(
      appBar: AppBar(title: const Text('Placement Drives')),
      body: ListView.builder(
        itemCount: drives.length,
        itemBuilder: (context, i) {
          final d = drives[i];
          final driveId = d['driveId'] as String? ?? '';
          final required = (d['requiredSkills'] as List<dynamic>?)?.cast<String>() ?? [];
          final matchPct = isStudent && studentId != null ? ds.calculateSkillMatch(studentId, driveId) : 0;
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: ListTile(
              leading: d['companyLogo'] != null ? Image.network(d['companyLogo'], width: 48, height: 48, errorBuilder: (_, __, ___) => const Icon(Icons.business)) : const Icon(Icons.business),
              title: Text('${d['companyName']} - ${d['jobProfile'] ?? ''}'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${d['visitDate'] ?? ''} • ${d['basePackage'] ?? ''}'),
                  Text('Required skills: ${required.join(', ')}'),
                  if (isStudent) Text('Your skill match: $matchPct%')
                ],
              ),
              trailing: ElevatedButton(
                child: const Text('Apply'),
                onPressed: isStudent && studentId != null
                    ? () {
                        ds.applyToDrive(studentId, driveId);
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Applied to drive')));
                      }
                    : null,
              ),
            ),
          );
        },
      ),
    );
  }
}
