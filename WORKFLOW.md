# College ERP Clear-Cut Workflow

This is the single source of truth for local development, release flow, and Firebase deployment.

## 1) One-Time Setup

### Prerequisites
- Flutter stable installed
- Firebase CLI installed
- Git installed
- GitHub repository connected

### Login once
```powershell
flutter --version
firebase --version
firebase login
git --version
```

### Confirm Firebase target
`.firebaserc` should contain:
```json
{
  "projects": {
    "default": "ksrce-campus-stack"
  }
}
```

## 2) Daily Development Workflow

### Step A: Pull latest
```powershell
git pull origin main
```

### Step B: Install/update deps
```powershell
flutter pub get
```

### Step C: Run locally (optional)
```powershell
flutter run -d chrome -t lib/src/main.dart
```

### Step D: Run tests
```powershell
flutter test
```

### Step E: Build production web
```powershell
flutter build web -t lib/src/main.dart
```

## 3) Manual Production Deploy (Immediate)

Use when you want to release instantly from your machine.

```powershell
firebase deploy --only hosting --project ksrce-campus-stack
```

Live URL:
- https://ksrce-campus-stack.web.app

## 4) Git + Release Workflow (Recommended)

### Step A: Commit changes
```powershell
git add .
git commit -m "feat: your change summary"
```

### Step B: Push to GitHub
```powershell
git push origin main
```

### Result
- GitHub Actions workflow deploys to Firebase Hosting automatically on push to main.

## 5) PR Preview Workflow

When you open a PR to main:
- A preview channel is created automatically
- URL is posted in PR checks/comments
- Preview is cleaned up when PR is closed

Workflow file:
- .github/workflows/firebase-hosting-pr-preview.yml

## 6) CI Secrets Setup (GitHub)

You must add this repository secret once:

- `FIREBASE_SERVICE_ACCOUNT_KSRCE_CAMPUS_STACK`

How to create it:
1. Firebase Console -> Project Settings -> Service Accounts
2. Generate new private key (JSON)
3. In GitHub repo -> Settings -> Secrets and variables -> Actions
4. New repository secret:
   - Name: `FIREBASE_SERVICE_ACCOUNT_KSRCE_CAMPUS_STACK`
   - Value: full JSON content

## 7) Troubleshooting

### Build error: Target file not found
Use the correct target:
```powershell
flutter build web -t lib/src/main.dart
```

### Firebase deploy permission error
- Re-run `firebase login`
- Ensure project access in Firebase Console
- Ensure correct project in `.firebaserc`

### GitHub Action fails on deploy
- Verify secret exists: `FIREBASE_SERVICE_ACCOUNT_KSRCE_CAMPUS_STACK`
- Verify workflow projectId is `ksrce-campus-stack`

## 8) Fast Checklist

Before release:
- `flutter test` passes
- `flutter build web -t lib/src/main.dart` passes
- push to main OR deploy manually

After release:
- Open https://ksrce-campus-stack.web.app
- Verify login, dashboard, and key pages
