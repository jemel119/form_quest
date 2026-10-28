## The Haunted Signup Mansion

### Project Overview

The Haunted Signup Mansion is a Flutter signup application built upon Activity 10. It introduces an animated welcome screen, enhanced form validation, a birth-date picker, a password visibility toggle, a submission loading indicator, and a personalized success screen with confetti.

The existing AI Signup Coach remains available on the signup screen.

### Application Flow

1. **Welcome Screen:** Displays the animated haunted welcome message and an entry button.
2. **Signup Screen:** Collects the user's name, email, password, confirmation password, and birth date.
3. **Success Screen:** Displays a personalized welcome message with confetti after a successful submission.
4. **Back to the Foyer:** Returns the user to the welcome screen.

### Task C: The Guarded Crypt

The Guarded Crypt adds defensive navigation and submission handling.

- **Empty username protection:** The Success screen checks whether the supplied username is empty or contains only whitespace. If it is invalid, the user is redirected to the Welcome screen.
- **Duplicate submission protection:** An internal `_submitting` flag prevents the submission handler from running more than once while a request is in progress.
- **Safe asynchronous navigation:** The signup screen checks `mounted` after the two-second delay to avoid navigating after the widget has been disposed.
- **Route replacement:** Successful submission uses `Navigator.pushReplacement()` to prevent returning to the completed signup form through the normal Back action.

### Hostile Test Cases

| Test Case | Expected Result | Observed Result |
|---|---|---|
| Open Success with an empty username | Redirect to Welcome without displaying an empty greeting | Passed automated widget test |
| Attempt duplicate submission | Only one Success screen should be created | Passed automated widget test |
| Leave the signup screen during loading | No delayed navigation or disposed-state exception | Passed automated widget test |

### Testing

The project includes widget tests for form validation, personalized success navigation, AI Signup Coach behavior, and Graduate Task C defensive scenarios.

Verification commands:

```powershell
flutter analyze
flutter test
```

**Verification status:** All tests passed.

### Technologies

- Flutter and Dart
- `animated_text_kit` for welcome-screen animation
- `confetti` for the Success screen
- Flutter Form and TextFormField validation
- Flutter widget testing framework
- Existing Activity 10 Signup Tip Service

