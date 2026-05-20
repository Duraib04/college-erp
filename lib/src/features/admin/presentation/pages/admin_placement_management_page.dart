import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/data_service.dart';

class AdminPlacementManagementPage extends StatefulWidget {
  const AdminPlacementManagementPage({super.key});

  @override
  State<AdminPlacementManagementPage> createState() => _AdminPlacementManagementPageState();
}

class _AdminPlacementManagementPageState extends State<AdminPlacementManagementPage> {
  @override
  Widget build(BuildContext context) {
    final ds = Provider.of<DataService>(context);
    final drives = ds.placementDrives;

    return Scaffold(
      appBar: AppBar(title: const Text('Placement Management')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const _CreateDrivePage()));
              },
              icon: const Icon(Icons.add),
              label: const Text('Create Drive'),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.separated(
                itemCount: drives.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (c, i) {
                  final d = drives[i];
                  return ListTile(
                    title: Text(d['companyName'] ?? 'Unknown'),
                    subtitle: Text('${d['jobProfile'] ?? ''} • ${d['visitDate'] ?? ''}'),
                    trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          // simple edit: open create page with prefilled values (not implemented fully)
                          Navigator.push(context, MaterialPageRoute(builder: (_) => _CreateDrivePage(prefill: d)));
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          showDialog(context: context, builder: (ctx) => AlertDialog(
                            title: const Text('Delete drive?'),
                            content: const Text('This will remove the drive from records.'),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                              ElevatedButton(onPressed: () {
                                ds.placementDrives.removeWhere((x) => x['driveId'] == d['driveId']);
                                ds.notifyListeners();
                                Navigator.pop(ctx);
                              }, child: const Text('Delete'))
                            ],
                          ));
                        },
                      )
                    ]),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _CreateDrivePage extends StatefulWidget {
  final Map<String, dynamic>? prefill;
  const _CreateDrivePage({this.prefill});

  @override
  State<_CreateDrivePage> createState() => _CreateDrivePageState();
}

class _CreateDrivePageState extends State<_CreateDrivePage> {
  final _company = TextEditingController();
  final _profile = TextEditingController();
  final _date = TextEditingController();
  final _skills = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.prefill != null) {
      _company.text = widget.prefill!['companyName'] ?? '';
      _profile.text = widget.prefill!['jobProfile'] ?? '';
      _date.text = widget.prefill!['visitDate'] ?? '';
      _skills.text = (widget.prefill!['requiredSkills'] as List<dynamic>?)?.join(', ') ?? '';
    }
  }

  @override
  void dispose() {
    _company.dispose(); _profile.dispose(); _date.dispose(); _skills.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ds = Provider.of<DataService>(context, listen: false);
    return Scaffold(
      appBar: AppBar(title: const Text('Create/Edit Drive')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(children: [
          TextField(controller: _company, decoration: const InputDecoration(labelText: 'Company')),
          TextField(controller: _profile, decoration: const InputDecoration(labelText: 'Job Profile')),
          TextField(controller: _date, decoration: const InputDecoration(labelText: 'Visit Date (YYYY-MM-DD)')),
          TextField(controller: _skills, decoration: const InputDecoration(labelText: 'Required Skills (comma-separated)')),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: () {
            final skills = _skills.text.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
            ds.addPlacementDrive({
              'companyName': _company.text.trim(),
              'jobProfile': _profile.text.trim(),
              'visitDate': _date.text.trim(),
              'requiredSkills': skills,
              'basePackage': '',
              'status': 'Open'
            });
            Navigator.pop(context);
          }, child: const Text('Save'))
        ]),
      ),
    );
  }
}
