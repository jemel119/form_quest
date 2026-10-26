# Flutter Signup Form Quest

## Student Information

- **Name:** Jeremy Henry-Atohengbe
- **Track:** Graduate
- **Work:** Individual
- **Selected Tasks:** Task A: AI Signup Coach and Task C: Confirm & Celebrate

## Project Overview

This Flutter application demonstrates a signup form with local input validation, password confirmation, personalized success feedback, and an AI Signup Coach interface.

The app is a demonstration only. It does not create or store real accounts.

## Features

### Core Signup Form

- Full name, email, and password fields
- Required-field validation
- Email validation requiring an `@` symbol
- Password validation requiring at least six characters
- Green success SnackBar after valid submission

### Task A: AI Signup Coach

- "Get a signup tip" button
- Loading indicator while requesting advice
- Success message labeled as AI-generated advice
- Response text trimmed to a maximum of 240 characters
- Friendly error message and Retry button
- Ten-second timeout
- Fixed request fields that exclude personal form information


Request:

```json
{
  "task": "signup_tip",
  "topic": "password_help"
}
```

Expected successful response:

```json
{
  "tip": "Use a long, unique password."
}
```

### Task C: Confirm & Celebrate

- Additional Confirm Password field
- Empty confirmation produces a validation error
- Mismatched passwords block submission
- Matching passwords allow submission when the other fields are valid
- Successful validation displays a personalized welcome message using the entered name

## Privacy and Security

The AI service request uses only two fixed fields: `task` and `topic`.

Names, email addresses, passwords, and password confirmations are never included in the AI request. All form validation remains local, and AI advice cannot approve or reject signup.

The HTTP service requires HTTPS and does not contain provider credentials or API keys.

## Testing

The project includes automated Flutter widget tests and HTTP service tests.

### Core Form and Task C

| Test | Expected behavior |
|---|---|
| Empty form | Required-field errors |
| Invalid email | Email validation error |
| Short password | Password-length error |
| Password mismatch | Submission blocked |
| Valid form | Personalized success message |

### AI Signup Coach

| Test | Expected behavior |
|---|---|
| Deterministic mock | Returns the predefined password tip |
| HTTP success | Extracts a valid tip |
| Loading | Shows progress indicator |
| Long response | Limits displayed advice to 240 characters |
| Empty response | Shows error and retry |
| Malformed JSON | Rejects invalid response |
| Non-200 response | Reports service failure |
| Offline failure | Shows error and retry |
| Timeout | Fails after ten seconds |
| Retry | Recovers after an initial failure |
| Privacy | Sends only the fixed task and topic |
| Non-HTTPS endpoint | Rejects the request |

### Commands

```powershell
flutter analyze
flutter test
```


## Graduate Critical Thinking

### Question 1: Identify one privacy or security boundary in the client-to-proxy-to-model flow. What threat does it reduce, and what risk remains?

The application keeps personal signup information separate from the AI request by sending only the fixed `signup_tip` task and `password_help` topic. This reduces the risk of accidentally exposing names, email addresses, or passwords to an external service. The HTTP implementation also requires HTTPS to protect information during transmission. A remaining risk is that a future external service could return incorrect or misleading advice, so the response is displayed only as guidance and never used for signup validation. The current mock does not contact an external model.

### Question 3: What should the UI do for timeout, invalid JSON, empty output, or unsafe/unhelpful AI content? Explain your chosen fallback.

The AI Signup Coach displays a loading indicator while waiting for a response and handles request failures without interrupting the signup form. A timeout, malformed response, or empty tip results in a friendly error message and a Retry button. The application also limits displayed advice to 240 characters and presents it as plain text rather than executable content.

### Question 4: Describe one trade-off in your design and a practical improvement.

The application uses a deterministic mock because an instructor-provided AI proxy was unavailable. This improves reliability and repeatability during testing because the mock returns a predictable result without requiring network access. However, it cannot demonstrate the usefulness or consistency of real model-generated suggestions. A practical improvement would be to connect the existing HTTP service to an authorized proxy when available and evaluate several safe password-help prompts. The ten-second timeout would remain in place to prevent indefinite waiting.

## Individual Contribution

I implemented the Flutter signup form, local validation, password confirmation, personalized success feedback, and AI Signup Coach interface. I also added the HTTP service contract, deterministic mock, and automated tests for validation, request handling, privacy, and failure recovery.

## Build Instructions

Install dependencies:

```powershell
flutter pub get
```

Run analysis and tests:

```powershell
flutter analyze
flutter test
```

Build the release APK:

```powershell
flutter build apk --release
```

Expected output:

`build/app/outputs/flutter-apk/app-release.apk`

