import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/data_service.dart';

class StudentSkillsPage extends StatefulWidget {
  const StudentSkillsPage({super.key});

  @override
  State<StudentSkillsPage> createState() => _StudentSkillsPageState();
}

class _StudentSkillsPageState extends State<StudentSkillsPage> {
  final _skillController = TextEditingController();

  @override
  void dispose() {
    _skillController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ds = Provider.of<DataService>(context);
    final studentId = ds.currentUserId;
    final skills = studentId != null ? ds.getStudentSkills(studentId) : [];

    return Scaffold(
      appBar: AppBar(title: const Text('My Skills')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(children: [
          Row(children: [
            Expanded(child: TextField(controller: _skillController, decoration: const InputDecoration(labelText: 'Skill'))),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () {
                final v = _skillController.text.trim();
                if (v.isEmpty || studentId == null) return;
                ds.addStudentSkill(studentId, v, 'basic');
                _skillController.clear();
              },
              child: const Text('Add'),
            )
          ]),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.builder(
              itemCount: skills.length,
              itemBuilder: (c, i) {
                final s = skills[i];
                return ListTile(
                  title: Text(s['skillName'] ?? ''),
                  subtitle: Text('Level: ${s['proficiency'] ?? ''}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_forever),
                    onPressed: () {
                      ds.removeStudentSkill(s['skillId']);
                    },
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
