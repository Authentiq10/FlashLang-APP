# FlashLang - German Vocabulary Learning App 🇩🇪

A beautiful, modern iOS app built with SwiftUI for learning German vocabulary through interactive flashcards. Features a polished interface with professional animations, native email verification, and an intuitive learning system designed following Apple's Human Interface Guidelines.

## Features

### 🔐 Production-Grade Authentication System
- **Supabase Integration**: Enterprise-level email/password authentication with robust backend
- **Intelligent Email Verification**: Auto-detecting email confirmation with multiple trigger points
- **Advanced Deep Linking**: `flashlang://` URLs with automatic verification status detection
- **Smart State Management**: Real-time verification checking on app foreground and deep link events
- **Cross-Device Verification**: Works seamlessly when email is verified on different devices
- **Professional Verification UI**: Dedicated iOS-native view with live status updates and animations
- **Automatic Loading State Management**: Prevents stuck loading states with intelligent state resets
- **Unified Login/Signup**: Single elegant screen with smooth mode transitions
- **Complete User Profiles**: Full name support with comprehensive account information display
- **Session Persistence**: Auto-refresh tokens with secure UserDefaults storage
- **Context-Aware Error Handling**: Intelligent error messages with user guidance and recovery options
- **Real-time Form Validation**: Live validation with immediate feedback for all form fields
- **Smart Resend System**: 60-second cooldown protection with countdown timer
- **Production-Ready Loading States**: Responsive UI with proper loading state management
- **Apple HIG Compliance**: Native iOS design following Human Interface Guidelines perfectly

### 🏠 Enhanced Main Interface
- **Personalized Welcome**: Dynamic greeting with user's name and daily motivation
- **Learning Streak Display**: Visual streak counter with celebration animations
- **Quiz Mode**: Interactive testing system unlocked after learning 8+ cards
- **Enhanced Progress Cards**: Beautiful gradient cards showing Mastered, Learning, and To Study counts
- **Weekly Progress Bar**: Visual timeline of your learning journey with percentage completion
- **Improved Category Cards**: Modern design with progress indicators and green progress bars
- **Smart Header**: Professional hamburger menu, search bar, and profile avatar integration
- **Responsive Layout**: Optimized for all iOS device sizes with perfect spacing

### 🔍 Advanced Search System
- **Global Word Search**: Search across all categories simultaneously
- **Multi-Language Search**: Find words by typing in German, English, or example sentences
- **Real-Time Results**: Instant filtering as you type
- **Clickable Results**: Tap any search result to view detailed flashcard
- **Keyboard Integration**: Auto-focus with proper search keyboard
- **Result Statistics**: Shows number of matches found

### 📚 Enhanced Flashcard Learning
- **Simple Flip Design**: Tap card to flip between German word and English translation
- **Audio Pronunciation**: Tap "Listen" button to hear German words pronounced correctly
- **Example Sentences**: Tap "Example" button to hear the word used in context
- **Native German Voice**: Uses iOS speech synthesis with German (de-DE) voice
- **Interactive Cards**: Tap to flip between German and English
- **Smooth Slide Animations**: Cards slide in/out when navigating (0.4s duration)
- **Three-Tier Learning System**: 
  - **New** (Red): Words you haven't learned yet
  - **Familiar** (Orange): Words you're getting to know
  - **Learned** (Green): Words you've mastered
- **Smart Repetition**: Words continue to appear until marked as "Learned"
- **Navigation**: Use elegant circular arrow buttons to navigate between cards
- **Progress Indicator**: See current position with clear typography (e.g., "3 of 8")

### 🧠 Interactive Quiz Mode
- **Progress-Based Unlocking**: Available after learning 8+ cards (learned + familiar)
- **Multiple Choice Questions**: 4 options per question with smart answer generation
- **German-to-English Testing**: Shows German words, asks for English translations
- **Smart Answer Pool**: Uses only learned/familiar cards for wrong answer options
- **Haptic Feedback**: Tactile response for correct/incorrect answers
- **Automatic Progression**: Moves to next question after 1.5-second delay
- **Visual Feedback**: Green for correct, red for incorrect answers with checkmarks
- **Progress Tracking**: Visual progress dots showing current question position
- **Results Summary**: Detailed score with percentage and performance message
- **Time Tracking**: Measures quiz completion time
- **Performance Messages**: Encouraging feedback based on score (Excellent, Great job, etc.)
- **Professional UI**: Full-screen immersive experience with purple gradient background
- **Offline Functionality**: Works completely offline using existing vocabulary data
- **Easy Expansion**: Designed to easily support more than 5 questions

### 🎯 Smart Filtering & Progress
- **Unlearned Only Mode**: Toggle to study only cards that aren't marked as "Learned"
- **Progress Persistence**: Your learning progress is automatically saved
- **Completion Celebration**: Special screen when all cards in a category are learned
- **Detailed Statistics**: Track New, Familiar, and Learned words separately
- **Always-Available Status Buttons**: Mark learning status at any stage

### 🔧 Professional Sidebar Navigation
- **FlashLang Branding**: App name with gradient styling and subtitle
- **Modern Design**: Clean, professional layout with custom components  
- **Dark Mode Toggle**: Seamless light/dark theme switching with purple accent
- **Progress Reset**: Reset all learning progress with confirmation dialogs
- **Sign Out**: Secure logout with session cleanup
- **Smooth Animations**: 0.3s slide-in from left with dark overlay
- **Intuitive Controls**: Tap overlay or close button to dismiss
- **Settings-Free**: Streamlined interface focused on essential functions

### 👤 Enhanced User Profile System
- **Smart Avatar Display**: Shows user initials in gradient circle (e.g., "JD" for John Doe)
- **Complete Account Information**: Displays email, full name, user ID, and account dates
- **Professional Layout**: Clean cards with icons and proper spacing
- **Account Security**: Shows creation and last updated timestamps
- **Native iOS Design**: Follows Human Interface Guidelines with beautiful typography
- **Responsive Interface**: Optimized for all screen sizes and orientations

### ⚙️ Settings & Customization
- **Dark Mode**: Toggle between light and dark themes with smooth transitions
- **Progress Reset**: Reset all learning progress with confirmation dialog
- **Statistics**: View total learned cards count with detailed descriptions
- **App Information**: Version and app details with beautiful iconography
- **Gmail-Style Layout**: Organized sections with icons and proper spacing

### 💾 Data Management
- **Local Storage**: All progress saved locally using UserDefaults
- **Automatic Sync**: Progress updates automatically across app sessions
- **No Internet Required**: Works completely offline
- **User Data**: Profile information and preferences

## Technical Details

### Architecture
- **SwiftUI**: Modern declarative UI framework
- **MVVM Pattern**: Clean separation of data and presentation
- **ObservableObject**: Reactive data management
- **UserDefaults**: Local data persistence
- **@FocusState**: Keyboard management for search
- **@Environment**: Navigation and presentation mode handling
- **Supabase**: Backend authentication and user management
- **Combine**: Reactive programming for state management

### Design System
- **Apple HIG Compliance**: Follows Human Interface Guidelines
- **Gmail-Inspired Design**: Modern sidebar and search patterns
- **System Fonts**: Uses SF Pro with proper weight hierarchy
- **Color System**: Leverages system colors for dark mode support
- **Spacing**: Consistent 8pt grid system
- **Corner Radius**: 12-24pt for modern iOS feel
- **Shadows**: Subtle depth with proper opacity values
- **Purple Accent Colors**: Modern color scheme inspired by HelloTalk

### Data Models
- `Category`: Vocabulary categories with flashcards
- `Flashcard`: Individual vocabulary cards with English/German pairs and example sentences
- `LearningStatus`: Enum for New, Familiar, and Learned states
- `UserProgress`: User learning state and preferences with card status tracking

### Key Components
- `ContentView`: Enhanced main interface with personalized greeting, quiz mode, and progress cards
- `QuizView`: **Interactive quiz mode** with multiple choice questions, haptic feedback, and results summary
- `PreSignupVerificationView`: **Professional pre-signup verification** with "I've Verified My Email" button and elegant status tracking
- `EmailVerificationView`: **Intelligent email verification** with auto-detection, multi-trigger checking, and real-time status updates
- `CategoryDetailView`: Flashcard learning interface with smooth slide animations and responsive design
- `FlashcardView`: Individual card with three-stage learning flow and audio support
- `SearchView`: Global search functionality with instant results and clickable cards
- `ProfileView`: Complete user profile with account information and smart avatar display
- `SidebarView`: Professional sidebar with FlashLang branding and essential functions
- `DataManager`: Comprehensive data persistence, state management, and quiz generation with optimized performance
- `UnifiedAuthView`: **Advanced login/signup** with intelligent loading state management and email verification integration
- `AuthService`: **Production-grade Supabase authentication** with smart deep link handling, automatic state resets, and notification coordination
- `AuthCoordinator`: **Robust authentication orchestration** with session management, token refresh, and seamless state transitions
- `QuickActionButton`: Reusable component for Practice, Daily Challenge, Review, and Achievements
- `ProgressCard`: Beautiful gradient cards for displaying learning statistics
- `EnhancedCategoryCard`: Modern category cards with progress indicators and visual feedback

## Sample Vocabulary

The app includes comprehensive vocabulary data across 4 categories with example sentences:

### 🍽️ Food
- Apple → Apfel → "Ich esse einen roten Apfel."
- Bread → Brot → "Das Brot ist frisch gebacken."
- Cheese → Käse → "Ich mag Schweizer Käse sehr."
- Milk → Milch → "Die Milch ist kalt."
- Water → Wasser → "Kann ich ein Glas Wasser haben?"
- Coffee → Kaffee → "Ich trinke gerne Kaffee am Morgen."
- Beer → Bier → "Ein kaltes Bier, bitte!"
- Wine → Wein → "Der Wein schmeckt sehr gut."

### ✈️ Travel
- Airport → Flughafen → "Der Flughafen ist sehr groß."
- Hotel → Hotel → "Wir übernachten in einem Hotel."
- Train → Zug → "Der Zug kommt in 5 Minuten."
- Bus → Bus → "Ich fahre mit dem Bus zur Arbeit."
- Ticket → Fahrkarte → "Haben Sie eine Fahrkarte?"
- Passport → Reisepass → "Vergessen Sie nicht Ihren Reisepass!"
- Map → Karte → "Können Sie mir die Karte zeigen?"
- Suitcase → Koffer → "Mein Koffer ist sehr schwer."

### 🎨 Colors
- Red → Rot → "Das Auto ist rot."
- Blue → Blau → "Der Himmel ist blau."
- Green → Grün → "Das Gras ist grün."
- Yellow → Gelb → "Die Sonne ist gelb."
- Black → Schwarz → "Die Nacht ist schwarz."
- White → Weiß → "Der Schnee ist weiß."
- Purple → Lila → "Die Blume ist lila."
- Orange → Orange → "Die Orange ist orange."

### 🔢 Numbers
- One → Eins → "Ich habe einen Hund."
- Two → Zwei → "Ich habe zwei Katzen."
- Three → Drei → "Es sind drei Uhr."
- Four → Vier → "Ich habe vier Geschwister."
- Five → Fünf → "Das Kind ist fünf Jahre alt."
- Six → Sechs → "Ich stehe um sechs Uhr auf."
- Seven → Sieben → "Es sind sieben Tage in einer Woche."
- Eight → Acht → "Das Meeting beginnt um acht Uhr."

## Getting Started

1. **Clone & Open**: Open the project in Xcode 16.0+
2. **Select Target**: Choose iOS Simulator (iPhone 16 or later recommended)
3. **Build**: Build and run the project (⌘+R)
4. **Sign Up**: Create an account with email verification
5. **Verify Email**: Check your email and tap the confirmation link
6. **Start Learning**: Begin your German vocabulary journey!

### Authentication Setup

The app uses Supabase for authentication with complete email verification:

#### Supabase Configuration
- **Project URL**: `https://cyqugaekraiyuwgfejws.supabase.co`
- **Project ID**: `cyqugaekraiyuwgfejws`
- **Anonymous Key**: Configured in `AuthCoordinator.swift`
- **Deep Link URL**: `flashlang://auth/confirm`

#### Professional Pre-Signup Email Verification Flow
1. **Email First** → User enters details and clicks "Verify Email & Create Account"
2. **Verification Email** → Beautiful pre-signup verification email sent instantly
3. **Email Link Click** → iOS deep link opens FlashLang with auto-detection
4. **"I've Verified My Email"** → Professional button confirms verification status
5. **Account Creation** → Only after email verification is confirmed, account is created
6. **Seamless Sign-In** → User automatically transitioned to authenticated state

#### Production-Grade Features
- **Multi-Trigger Verification**: Deep links, app foreground detection, and manual checks
- **Intelligent State Management**: Automatic loading state resets prevent UI freezing
- **Cross-Device Support**: Email verification works across different devices seamlessly
- **Real-Time Status Updates**: Live verification checking with immediate UI feedback
- **Notification System**: Internal notifications coordinate between deep links and UI
- **Robust Error Recovery**: Smart error handling with user guidance and retry options
- **Session Management**: Automatic token refresh with secure storage
- **Cooldown Protection**: 60-second resend timer with visual countdown

## Requirements

- iOS 18.5+
- Xcode 16.0+
- Swift 5.0+

## User Experience Highlights

- **🎯 Personalized Learning**: Dynamic greetings, daily motivation, and learning streaks
- **📱 Intelligent iOS Experience**: Auto-detecting email verification with multi-trigger deep linking
- **⚡ Smart Authentication**: No more stuck loading states with intelligent state management
- **🔄 Real-Time Updates**: Live verification checking with automatic UI state transitions
- **🎨 Modern Interface**: Professional gradients, animations, and responsive component design
- **⚡ Quick Actions**: Instant access to Practice, Daily Challenge, Review, and Achievements
- **📊 Visual Progress**: Beautiful progress cards and weekly timeline visualization
- **🔍 Smart Search**: Find any word instantly across all categories with real-time results
- **🎯 Three-Stage Learning**: Progressive New → Familiar → Learned system for retention
- **🗣️ Audio Support**: Native German pronunciation with example sentences
- **📱 Responsive Design**: Optimized for all iOS devices with perfect spacing and performance
- **🔒 Enterprise Security**: Production-grade authentication with cross-device verification support
- **✨ Smooth Animations**: Professional slide, flip, and transition animations throughout
- **🌙 Dark Mode**: Complete light/dark theme support with system integration

## Future Enhancements

### 🚀 Learning Features
- **Spaced Repetition Algorithm**: Smart scheduling based on forgetting curves
- **More Vocabulary Categories**: Animals, Body Parts, Family, Technology, Weather
- **Custom Vocabulary**: User-created flashcard sets with personal words
- **Quiz Modes**: Multiple choice, typing tests, and listening comprehension
- **Achievement System**: Badges, milestones, and learning goals
- **Word Difficulty Levels**: Beginner, Intermediate, Advanced progression

### 📊 Progress & Analytics  
- **Advanced Statistics**: Detailed learning analytics and time tracking
- **Learning Streaks**: Daily streak tracking with motivational rewards
- **Weekly/Monthly Reports**: Progress summaries and improvement insights
- **Cloud Sync**: Cross-device progress synchronization via Supabase
- **Offline Mode**: Complete functionality without internet connection

### 🎯 User Experience
- **Advanced Search Filters**: Filter by difficulty, category, or learning status
- **Voice Recognition**: Pronunciation practice with speech-to-text feedback
- **Adaptive Learning**: AI-powered word selection based on user performance
- **Social Features**: Share progress and compete with friends
- **Multiple Languages**: Expand beyond German to Spanish, French, Italian
- **Accessibility**: Enhanced VoiceOver and accessibility feature support

## 🏆 Technical Achievements

FlashLang demonstrates production-quality iOS development with:

### **🔧 Advanced SwiftUI Implementation**
- Custom reusable components with proper state management
- Complex navigation flows with deep linking integration
- Professional animations and transitions throughout the app
- Responsive design patterns for all iOS device sizes

### **🔐 Enterprise-Grade Authentication System**
- **Intelligent Email Verification**: Multi-trigger detection with deep links and app foreground events
- **Smart State Management**: Automatic loading state resets with notification-based coordination
- **Advanced Deep Linking**: Custom URL scheme handling with fallback mechanisms for various link formats
- **Real-Time Status Detection**: Live verification checking with immediate UI state updates
- **Cross-Device Workflow**: Seamless email verification across different devices and platforms
- **Production Error Handling**: Context-aware error recovery with user guidance and retry logic
- **Secure Session Management**: Automatic token refresh with encrypted local storage

### **🎨 Modern iOS Design**
- Apple Human Interface Guidelines compliance
- Beautiful gradient designs and professional color schemes
- Smooth animations and micro-interactions
- Complete dark mode support with system integration

### **⚡ Performance Optimizations**
- Efficient state management with ObservableObject patterns
- Local data persistence with UserDefaults integration
- Optimized UI updates with @StateObject and @EnvironmentObject
- Smooth scrolling and responsive user interactions

## 📄 License

This project is created for educational purposes and demonstrates modern iOS development best practices with SwiftUI, Supabase authentication, and professional UI/UX design patterns.

---

**Built with ❤️ using SwiftUI and Supabase**  
*A production-ready German vocabulary learning app for iOS* 