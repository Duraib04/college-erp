import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/data_service.dart';

class MentorManagementPage extends StatefulWidget {
  const MentorManagementPage({super.key});

  @override
  State<MentorManagementPage> createState() => _MentorManagementPageState();
}

class _MentorManagementPageState extends State<MentorManagementPage> {
  String? _selectedFaculty;
  String? _selectedStudent;

  @override
  Widget build(BuildContext context) {
    final ds = Provider.of<DataService>(context);
    final faculties = ds.facultyList;
    final students = ds.students;

    return Scaffold(
      appBar: AppBar(title: const Text('Mentor Assignments')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(children: [
          DropdownButtonFormField<String>(
            initialValue: _selectedFaculty,
            items: faculties.map((f) => DropdownMenuItem(value: f['facultyId'], child: Text(f['name'] ?? ''))).toList(),
            onChanged: (v) => setState(() => _selectedFaculty = v),
            decoration: const InputDecoration(labelText: 'Select Faculty'),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: _selectedStudent,
            items: students.map((s) => DropdownMenuItem(value: s['studentId'], child: Text(s['name'] ?? ''))).toList(),
            onChanged: (v) => setState(() => _selectedStudent = v),
            decoration: const InputDecoration(labelText: 'Select Student'),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: _selectedFaculty != null && _selectedStudent != null
                    ? () {
                    ds.assignSingleMentor(_selectedFaculty!, _selectedStudent!);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mentor assigned')));
                  }
                : null,
            child: const Text('Assign Mentor'),
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              itemCount: ds.mentorAssignments.length,
              itemBuilder: (c, i) {
                final m = ds.mentorAssignments[i];
                return ListTile(
                  title: Text('Faculty: ${m['facultyId']}'),
                  subtitle: Text('Student: ${m['studentId']} • ${m['assignedOn']}'),
                );
              },
            ),
          )
        ]),
      ),
    );
  }
}
