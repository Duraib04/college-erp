import 'package:flutter_test/flutter_test.dart';
import 'package:ksrce_erp/src/core/data_service.dart';

void main() {
  late DataService ds;

  setUp(() {
    ds = DataService();

    // Clear collections used by these placement tests for isolation
    ds.placementDrives.clear();
    ds.placementApplications.clear();
    ds.students.clear();
    ds.users.clear();
    ds.studentSkills.clear();
    ds.faculty.clear();
    ds.mentorAssignments.clear();
  });

  test('addPlacementDrive assigns driveId and increases list', () {
    final before = ds.placementDrives.length;
    ds.addPlacementDrive({
      'companyName': 'TestCo',
      'jobProfile': 'Engineer',
      'visitDate': '2026-06-01',
      'requiredSkills': ['Dart'],
      'selectedDepartments': <String>[],
    });

    expect(ds.placementDrives.length, before + 1);
    final created = ds.placementDrives.last;
    expect(created['driveId'].toString().startsWith('DRIVE'), isTrue);
    expect(created['companyName'], 'TestCo');
  });

  test('applyToDrive creates application and increments applicantCount', () {
    // create student
    ds.addStudent({'name': 'Stu A', 'departmentId': 'DEPT_TEST'});
    final studentId = ds.students.last['studentId'] as String;

    // create drive
    ds.addPlacementDrive({
      'companyName': 'AppCo',
      'jobProfile': 'Dev',
      'requiredSkills': <String>[],
      'selectedDepartments': ['TEST'],
    });
    final drive = ds.placementDrives.last;
    final driveId = drive['driveId'] as String;

    final beforeApps = ds.placementApplications.length;
    final beforeCount = (drive['applicantCount'] as int?) ?? 0;

    ds.applyToDrive(studentId, driveId);

    expect(ds.placementApplications.length, beforeApps + 1);
    final app = ds.placementApplications.last;
    expect(app['driveId'], driveId);
    expect(app['studentId'], studentId);

    final updatedDrive = ds.placementDrives.firstWhere((d) => d['driveId'] == driveId);
    expect((updatedDrive['applicantCount'] as int), beforeCount + 1);
  });

  test('calculateSkillMatch returns expected percentage', () {
    // create student with dept
    ds.addStudent({'name': 'Stu B', 'departmentId': 'DEPT_TEST'});
    final studentId = ds.students.last['studentId'] as String;

    // add skills for student
    ds.addStudentSkill(studentId, 'Dart', 'intermediate');

    // create drive requiring two skills
    ds.addPlacementDrive({
      'companyName': 'MatchCo',
      'jobProfile': 'Dev',
      'requiredSkills': ['Dart', 'Flutter'],
      'selectedDepartments': ['TEST'],
    });
    final driveId = ds.placementDrives.last['driveId'] as String;

    final pct = ds.calculateSkillMatch(studentId, driveId);
    // Student has 1 of 2 required skills => 50%
    expect(pct, 50);
  });

  test('getEligibleDrivesForStudent respects department and skill threshold', () {
    ds.addStudent({'name': 'Stu C', 'departmentId': 'DEPT_TEST'});
    final studentId = ds.students.last['studentId'] as String;

    // student has only one skill
    ds.addStudentSkill(studentId, 'Dart', 'basic');

    // drive requires 2 skills and requires 40% match
    ds.addPlacementDrive({
      'companyName': 'EligCo',
      'jobProfile': 'Dev',
      'requiredSkills': ['Dart', 'Flutter'],
      'selectedDepartments': ['TEST'],
      'skillMatchPercentage': 40,
    });

    final eligible = ds.getEligibleDrivesForStudent(studentId);
    // matched 1/2 => 50% which is >=40% so should be eligible
    expect(eligible.any((d) => d['companyName'] == 'EligCo'), isTrue);
  });
}
