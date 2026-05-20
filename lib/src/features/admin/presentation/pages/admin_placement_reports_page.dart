import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/data_service.dart';

class AdminPlacementReportsPage extends StatelessWidget {
  const AdminPlacementReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ds = Provider.of<DataService>(context);
    final drives = ds.placementDrives;
    final applications = ds.placementApplications;

    return Scaffold(
      appBar: AppBar(title: const Text('Placement Reports')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(children: [
          Card(
            child: ListTile(
              title: const Text('Total Drives'),
              trailing: Text('${drives.length}'),
            ),
          ),
          Card(
            child: ListTile(
              title: const Text('Total Applications'),
              trailing: Text('${applications.length}'),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.builder(
              itemCount: drives.length,
              itemBuilder: (c, i) {
                final d = drives[i];
                final apps = applications.where((a) => a['driveId'] == d['driveId']).toList();
                return Card(
                  child: ListTile(
                    title: Text(d['companyName'] ?? 'Unknown'),
                    subtitle: Text('${d['jobProfile'] ?? ''} • ${d['visitDate'] ?? ''}'),
                    trailing: Text('${apps.length} apps'),
                  ),
                );
              },
            ),
          )
        ]),
      ),
    );
  }
}
