# ERP Usage Workflow (Admin Operations)

This document explains the real app usage flow for Admin users.

## Goal
Set up the academic structure in the correct order:
1. Add Department
2. Add Faculty
3. Add Student
4. Assign Faculty as HOD to a Department
5. Ensure students are mapped to the correct Department

---

## Module 1: Department Setup

Screen:
- Admin -> Departments

Action:
1. Click Add Department
2. Enter:
   - Department Name
   - Department Code (example: CSE, ECE, MECH)
3. Save

Expected result:
- Department appears in the department list
- HOD shows as Not Assigned initially

Important:
- Department must exist before adding faculty/students for that department

---

## Module 2: Faculty Setup

Screen:
- Admin -> Faculty Management

Action:
1. Click Add Faculty
2. Fill required fields:
   - Full Name
   - Department (select from dropdown)
3. Fill optional fields (email, phone, designation, qualification)
4. Save

Expected result:
- Faculty is created and linked to selected department

Important:
- Add at least one faculty member in each department before HOD assignment

---

## Module 3: Student Setup

Screen:
- Admin -> Student Management

Action:
1. Click Add Student
2. Fill required fields:
   - Full Name
   - Department (dropdown)
   - Year
   - Section
3. Fill optional details across tabs (Personal, Contact & Family, Academic, Accommodation)
4. Save (Enroll Student)

Expected result:
- Student is created and automatically linked to the selected department

Important:
- Student-department mapping happens through Department selection in student form

---

## Module 4: Assign HOD

Screen:
- Admin -> HOD Assignment

Action:
1. Open a department row
2. Click Assign or Change
3. Select faculty member from that department
4. Confirm

Expected result:
- Department now shows selected faculty as HOD

Rules:
- HOD should be chosen from faculty belonging to the same department

---

## Module 5: Verify Department Mapping

Screen:
- Admin -> Departments
- Admin -> Student Management
- Admin -> Faculty Management

Checklist:
1. Department card shows:
   - Correct HOD
   - Faculty count
   - Student count
2. In Student list, each student shows correct department code
3. In Faculty list, each faculty shows correct department code

If student is in wrong department:
1. Open Student Management
2. Edit student
3. Change Department in Academic tab
4. Save Changes

---

## Recommended Execution Order (One Department at a Time)

For each department:
1. Create department
2. Add faculty for that department
3. Assign one faculty as HOD
4. Add students to that department
5. Verify counts on Department Management page

This avoids cross-mapping errors.

---

## Quick Example Flow (CSE)

1. Add Department: Computer Science and Engineering (CSE)
2. Add Faculty: Dr. Kumar -> Department = CSE
3. Add Faculty: Ms. Priya -> Department = CSE
4. Assign HOD: Dr. Kumar as HOD for CSE
5. Add Student: Arun -> Department = CSE, Year = 1, Section = A
6. Validate in Departments page:
   - HOD: Dr. Kumar
   - Faculty count: 2
   - Student count: 1

---

## Common Mistakes to Avoid

1. Adding faculty before creating department
2. Forgetting department selection while creating student
3. Assigning HOD before adding department faculty
4. Not validating final counts on department cards

---

## Admin Master Workflow Summary

Admin -> Departments -> Add Department
Admin -> Faculty Management -> Add Faculty
Admin -> Student Management -> Add Student
Admin -> HOD Assignment -> Assign HOD
Admin -> Departments -> Verify HOD + Faculty count + Student count
