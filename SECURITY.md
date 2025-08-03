# Security Policy

## Supported Versions

| Version | Supported          |
| ------- | ------------------ |
| 1.0.x   | :white_check_mark: |

## Reporting a Vulnerability

If you discover a security vulnerability within OpenNutriTracker, please send an email to [your-email@example.com]. All security vulnerabilities will be promptly addressed.

## Security Measures

### API Key Protection
- All API keys are stored in environment variables (`.env` file)
- The `.env` file is excluded from version control via `.gitignore`
- API keys are obfuscated using the `envied` package
- Generated `env.g.dart` file is also excluded from version control

### Data Privacy
- User data is stored locally on the device
- No personal data is transmitted to external servers without user consent
- AI chat interactions are processed securely and do not store personal data
- All sensitive data is encrypted using Flutter's secure storage

### Required Environment Variables
The following environment variables must be set in a `.env` file:

```env
FDC_API_KEY=your_fdc_api_key_here
SUPABASE_PROJECT_URL=your_supabase_project_url
SUPABASE_PROJECT_ANON_KEY=your_supabase_anon_key
SENTRY_DNS=your_sentry_dns_here
```

### API Key Sources
- **FDC API Key**: [Food Data Central](https://fdc.nal.usda.gov/api-key-signup.html)
- **Supabase**: [Supabase](https://supabase.com) - Create a new project
- **Sentry**: [Sentry](https://sentry.io) - For error tracking (optional)

### Security Checklist for Contributors
- [ ] Never commit API keys or sensitive data
- [ ] Always use environment variables for configuration
- [ ] Test with dummy API keys in development
- [ ] Ensure `.env` file is in `.gitignore`
- [ ] Run `flutter packages pub run build_runner build` after changing environment variables
- [ ] Verify no sensitive data in logs or debug output
- [ ] Test security measures before submitting PR

### Build Security
1. Generate environment file: `flutter packages pub run build_runner build`
2. Verify `env.g.dart` is generated and contains obfuscated values
3. Test application with dummy keys before deployment
4. Never commit the actual `.env` file

### Deployment Security
- Use CI/CD secrets for production API keys
- Rotate API keys regularly
- Monitor API usage for unusual patterns
- Use environment-specific configurations

## Security Features

### Data Encryption
- Local data is encrypted using Flutter's secure storage
- API communications use HTTPS
- Sensitive data is obfuscated in compiled code

### Privacy Controls
- User consent required for data collection
- Local-first data storage
- Optional cloud synchronization
- Clear data deletion options

### Code Security
- Regular dependency updates
- Static analysis with `flutter_lints`
- Secure coding practices
- Input validation and sanitization

## Contact

For security-related issues, please contact:
- Email: [your-email@example.com]
- GitHub Issues: [Security Issues](https://github.com/MarcD25/OpenNutriTracker/issues)

## Acknowledgments

This security policy is based on best practices for Flutter applications and open-source projects. 