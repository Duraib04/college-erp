# College ERP Workflow (3 Modules)

This document explains the full workflow in 3 simple modules.

## Module 1: Build Module (Developer Machine)

Purpose:
- Prepare and build the Flutter web app.

Steps:
1. Pull latest changes
```powershell
git pull origin main
```

2. Get dependencies
```powershell
flutter pub get
```

3. Build web app (correct entrypoint)
```powershell
flutter build web --release --target lib/src/main.dart
```

Expected output:
- Production files generated in `build/web`.

---

## Module 2: Validation Module (Quality Gate)

Purpose:
- Ensure code quality before deployment.

Local validation:
```powershell
flutter test
```

CI validation (GitHub Actions):
- Workflow file: `.github/workflows/firebase-hosting-deploy.yml`
- Job `test` runs automatically on push to `main`.
- Deployment job runs only if `test` job passes.

Expected output:
- Tests pass locally and in GitHub Actions.

---

## Module 3: Deployment Module (Firebase Hosting)

Purpose:
- Publish the validated web build to production.

Manual deployment:
```powershell
firebase deploy --only hosting --project ksrce-campus-stack
```

Automatic deployment (CI/CD):
- Trigger: push to `main`
- Workflow file: `.github/workflows/firebase-hosting-deploy.yml`
- Uses GitHub secret:
  - `FIREBASE_SERVICE_ACCOUNT_KSRCE_CAMPUS_STACK`
- Deploy target:
  - `projectId: ksrce-campus-stack`

Production URL:
- https://ksrce-campus-stack.web.app

---

## Quick Run Order

1. Build Module
2. Validation Module
3. Deployment Module

In short:
```powershell
flutter pub get
flutter test
flutter build web --release --target lib/src/main.dart
firebase deploy --only hosting --project ksrce-campus-stack
```
