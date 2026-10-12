# Development Setup Guide

This guide will help you set up the OpenNutriTracker development environment safely and securely.

## Prerequisites

- **Flutter SDK**: >=3.0.0
- **Dart SDK**: >=3.0.0
- **Git**: Latest version
- **IDE**: Android Studio, VS Code, or IntelliJ IDEA
- **Android SDK**: For Android development
- **Xcode**: For iOS development (macOS only)

## Initial Setup

### 1. Clone the Repository
```bash
git clone https://github.com/MarcD25/OpenNutriTracker.git
cd OpenNutriTracker
```

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Environment Configuration

#### Create Environment File
Create a `.env` file in the root directory:

```env
# Required API Keys
FDC_API_KEY=your_fdc_api_key_here
SUPABASE_PROJECT_URL=your_supabase_project_url
SUPABASE_PROJECT_ANON_KEY=your_supabase_anon_key

# Optional Services
SENTRY_DNS=your_sentry_dns_here
```

#### Get API Keys

**FDC API Key (Required)**
1. Visit [Food Data Central](https://fdc.nal.usda.gov/api-key-signup.html)
2. Sign up for a free account
3. Request an API key
4. Add the key to your `.env` file

**Supabase (Required)**
1. Create an account at [Supabase](https://supabase.com)
2. Create a new project
3. Go to Settings > API
4. Copy the Project URL and anon/public key
5. Add both to your `.env` file

**Sentry (Optional)**
1. Create an account at [Sentry](https://sentry.io)
2. Create a new project
3. Copy the DSN
4. Add to your `.env` file

### 4. Generate Environment Files
```bash
flutter packages pub run build_runner build
```

This will generate the `lib/core/utils/env.g.dart` file with obfuscated API keys.

### 5. Verify Setup
```bash
flutter doctor
flutter analyze
flutter test
```

## Development Workflow

### Running the App
```bash
# Debug mode
flutter run

# Release mode
flutter run --release

# Specific device
flutter run -d emulator-5554
```

### Code Generation
When you modify environment variables or add new ones:
```bash
flutter packages pub run build_runner build
```

### Testing
```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/unit/example_test.dart

# Run with coverage
flutter test --coverage
```

## Security Best Practices

### ✅ Do's
- Always use environment variables for API keys
- Test with dummy keys in development
- Keep `.env` file in `.gitignore`
- Run `flutter packages pub run build_runner build` after env changes
- Use secure storage for sensitive data
- Validate all user inputs

### ❌ Don'ts
- Never commit API keys to version control
- Don't hardcode sensitive data in source code
- Don't log sensitive information
- Don't use real API keys in development
- Don't share your `.env` file

## Project Structure

```
lib/
├── core/                    # Core utilities and constants
│   ├── data/               # Data layer
│   ├── domain/             # Domain layer
│   ├── presentation/       # Presentation layer
│   └── utils/              # Utilities
├── features/               # Feature modules
│   ├── chat/              # AI chat functionality
│   ├── diary/             # Diary and calendar
│   ├── add_meal/          # Meal addition
│   └── home/              # Home screen
└── generated/              # Generated files
```

## Key Features to Test

### AI Chat Functionality
1. Open the chat tab
2. Test basic conversation
3. Try food logging commands
4. Test debug mode toggle
5. Verify error handling

### Diary Features
1. Check calendar dot visualization
2. Test dynamic calorie calculation
3. Verify meal type handling
4. Test bulk operations

### Data Management
1. Add/remove food items
2. Test barcode scanning
3. Verify data persistence
4. Test offline functionality

## Troubleshooting

### Common Issues

**Build Errors**
```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter packages pub run build_runner build
```

**Environment Issues**
```bash
# Regenerate environment files
flutter packages pub run build_runner clean
flutter packages pub run build_runner build
```

**API Key Issues**
- Verify all required keys are in `.env`
- Check key format and validity
- Ensure no extra spaces or quotes
- Test API endpoints separately

**Device Issues**
```bash
# List available devices
flutter devices

# Check device connectivity
flutter doctor
```

## Contributing

### Before Submitting PR
- [ ] Run `flutter analyze`
- [ ] Run `flutter test`
- [ ] Test on both Android and iOS
- [ ] Verify no sensitive data in code
- [ ] Update documentation if needed
- [ ] Follow the existing code style

### Code Style
- Use meaningful variable names
- Add comments for complex logic
- Follow Flutter conventions
- Use proper error handling
- Write unit tests for new features

## Deployment

### Android
```bash
flutter build apk --release
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

### Web
```bash
flutter build web --release
```

## Support

For issues or questions:
- Create a GitHub issue
- Check existing documentation
- Review the original project: [simonoppowa/OpenNutriTracker](https://github.com/simonoppowa/OpenNutriTracker)

## Security Checklist

Before pushing to GitHub:
- [ ] No API keys in code
- [ ] `.env` file is in `.gitignore`
- [ ] No sensitive data in logs
- [ ] All tests pass
- [ ] Code analysis clean
- [ ] Documentation updated
- [ ] Security measures implemented 