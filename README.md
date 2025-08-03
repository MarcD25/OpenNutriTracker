<p align="center">
  <img alt="Logo" src="assets/icon/ont_logo_square.png" width="128" />
  <h1 align="center">OpenNutriTracker</h1>
</p>

<p align="center">
  <a href="https://opensource.org/licenses/MIT" alt="License">
        <img src="https://img.shields.io/badge/license-GPLv3-blue" /></a>
  <a href="https://github.com/MarcD25/OpenNutriTracker/stargazers" alt="GitHub Stars">
        <img src="https://img.shields.io/github/stars/MarcD25/OpenNutriTracker.svg" /></a>
  <a href="https://github.com/MarcD25/OpenNutriTracker/issues" alt="GitHub Issues">
        <img src="https://img.shields.io/github/issues/MarcD25/OpenNutriTracker.svg" /></a>
  <a href="https://github.com/MarcD25/OpenNutriTracker/pulls" alt="GitHub Pull Requests">
        <img src="https://img.shields.io/github/issues-pr/MarcD25/OpenNutriTracker.svg" /></a>
</p>

## Description
OpenNutriTracker is an open-source mobile application designed to simplify nutritional tracking and management. Whether you are looking to improve your health, lose weight, or simply maintain a balanced diet, OpenNutriTracker provides a minimalistic interface to easily track and analyze your daily nutrition.

This is a fork of the original OpenNutriTracker project with enhanced features including AI-powered chat functionality for nutrition assistance.

## Key Features
- **🍎 Nutritional Tracking:** Easily log your meals and snacks, and access a vast database of food items and ingredients to get detailed nutritional information.
- **📓 Food Diary:** Maintain a comprehensive food diary to keep track of your daily food consumption, habits, and progress.
- **🍽️ Custom Meals:** Plan your meals in advance, create personalized meal plans, and optimize them according to your dietary goals.
- **📷 Barcode Scanner:** Scan barcodes on packaged food items to instantly retrieve their nutritional information.
- **🤖 AI Chat Assistant:** Get nutrition advice, meal suggestions, and help with food logging through an intelligent chat interface.
- **🔒 Privacy Focused:** OpenNutriTracker prioritizes the privacy of its users. It does not collect or share any personal data without your consent.
- **🚫💰 No Subscription, In-App Purchases, or Ads:** OpenNutriTracker is completely free to use, without any subscription fees, in-app purchases, or intrusive advertisements.

## Enhanced Features (This Fork)
- **AI-Powered Chat:** Intelligent nutrition assistant that can help with meal planning, food logging, and nutrition advice
- **Dynamic Calorie Calculation:** Real-time calorie and macro calculation based on actual food entries
- **Smart Calendar Visualization:** Calendar dots that reflect eating patterns and goal adherence
- **JSON-Based Function Calling:** Advanced AI integration with structured function calls for data operations
- **Debug Mode:** Toggle to view AI function calls and debug information
- **Error Handling:** Robust error handling with user-friendly retry mechanisms

## Privacy
- **Data Encryption**: All collected user data is encrypted and stored locally on your device
- **Minimal Data Collection**: OpenNutriTracker only collects the necessary information required for tracking nutrition and providing personalized insights. Your data will not be shared with third parties without your consent.
- **Open-Source**: OpenNutriTracker is an open-source application
- **AI Privacy**: AI interactions are processed securely and do not store personal data

## Installation & Setup

### Prerequisites
- Flutter SDK (>=3.0.0)
- Dart SDK (>=3.0.0)
- Android Studio / VS Code
- Git

### Environment Setup
1. Clone the repository:
   ```bash
   git clone https://github.com/MarcD25/OpenNutriTracker.git
   cd OpenNutriTracker
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Create a `.env` file in the root directory with your API keys:
   ```env
   FDC_API_KEY=your_fdc_api_key_here
   SUPABASE_PROJECT_URL=your_supabase_project_url
   SUPABASE_PROJECT_ANON_KEY=your_supabase_anon_key
   SENTRY_DNS=your_sentry_dns_here
   ```

4. Generate the environment file:
   ```bash
   flutter packages pub run build_runner build
   ```

5. Run the application:
   ```bash
   flutter run
   ```

### Required API Keys
- **FDC API Key**: Get from [Food Data Central](https://fdc.nal.usda.gov/api-key-signup.html)
- **Supabase**: Create a project at [Supabase](https://supabase.com) for backend services
- **OpenRouter API**: For AI chat functionality (optional)

## Architecture
This project follows Clean Architecture principles with the following structure:
- **Data Layer**: Repositories, Data Sources, DTOs
- **Domain Layer**: Entities, Use Cases, Services
- **Presentation Layer**: BLoC pattern, Widgets, Screens

## Contributing
Contributions to OpenNutriTracker are welcome! If you find any issues or have suggestions for new features, please open an issue or submit a pull request. Make sure to follow the project's code style and guidelines.

### Development Guidelines
- Follow the existing code style and architecture patterns
- Write tests for new features
- Update documentation as needed
- Ensure all API keys are properly secured

## Disclaimer
OpenNutriTracker is not a medical application. All data provided is not validated and should be used with caution. Please maintain a healthy lifestyle and consult a professional if you have any problems. Use during illness, pregnancy or lactation is not recommended.

The application is still under construction. Errors, bugs and crashes might occur.

## Acknowledgments
The OpenNutriTracker project was inspired by the need for a simple and effective nutrition tracking tool.
The food database used in OpenNutriTracker is powered by [Open Food Facts](https://world.openfoodfacts.org/) and [Food Data Central](https://fdc.nal.usda.gov/).

## License
This project is licensed under the GNU General Public License v3.0 License. See the [LICENSE](LICENSE) file for more information.

## Contact
For questions, suggestions, or collaborations, feel free to contact:

MarcD25
- GitHub: [@MarcD25](https://github.com/MarcD25)

---

**Note**: This is a fork of the original OpenNutriTracker project. For the original project, visit [simonoppowa/OpenNutriTracker](https://github.com/simonoppowa/OpenNutriTracker).
