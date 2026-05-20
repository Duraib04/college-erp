import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/data_service.dart';

class AdminPlacementDrivesPage extends StatefulWidget {
  const AdminPlacementDrivesPage({super.key});

  @override
  State<AdminPlacementDrivesPage> createState() => _AdminPlacementDrivesPageState();
}

class _AdminPlacementDrivesPageState extends State<AdminPlacementDrivesPage> {
  final _formKey = GlobalKey<FormState>();
  final _companyController = TextEditingController();
  final _profileController = TextEditingController();
  final _dateController = TextEditingController();
  final _skillsController = TextEditingController();

  @override
  void dispose() {
    _companyController.dispose();
    _profileController.dispose();
    _dateController.dispose();
    _skillsController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final ds = Provider.of<DataService>(context, listen: false);
    final skills = _skillsController.text.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
    ds.addPlacementDrive({
      'companyName': _companyController.text.trim(),
      'jobProfile': _profileController.text.trim(),
      'visitDate': _dateController.text.trim(),
      'requiredSkills': skills,
      'basePackage': '',
      'status': 'Open'
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Drive created')));
    _companyController.clear();
    _profileController.clear();
    _dateController.clear();
    _skillsController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final ds = Provider.of<DataService>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Placement Drives')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Column(children: [
                TextFormField(controller: _companyController, decoration: const InputDecoration(labelText: 'Company')),
                TextFormField(controller: _profileController, decoration: const InputDecoration(labelText: 'Job Profile')),
                TextFormField(controller: _dateController, decoration: const InputDecoration(labelText: 'Visit Date (YYYY-MM-DD)')),
                TextFormField(controller: _skillsController, decoration: const InputDecoration(labelText: 'Required Skills (comma-separated)')),
                const SizedBox(height: 12),
                ElevatedButton(onPressed: _submit, child: const Text('Create Drive')),
              ]),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: ds.placementDrives.length,
                itemBuilder: (c, i) {
                  final d = ds.placementDrives[i];
                  return ListTile(
                    title: Text(d['companyName'] ?? ''),
                    subtitle: Text('${d['jobProfile'] ?? ''} • ${d['visitDate'] ?? ''}'),
                    trailing: Text('${d['applicantCount'] ?? 0} apps'),
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
