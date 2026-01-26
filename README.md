# Smart Khata 📒  
### Digital Ledger Mobile Application (Flutter)

Smart Khata is a mobile-based digital ledger application developed using **Flutter**.  
The application helps **small business owners (shopkeepers)** manage customer records and credit/debit transactions digitally, while allowing **customers** to view their ledger details.

This project is developed as a **Mini Project for MCA Semester 2**.

---

## 📌 Project Features

### 🔐 Authentication
- Single **Signup screen** with role selection (Shopkeeper / Customer)
- **Role-based Login**
- Different dashboards based on user role

### 👨‍💼 Shopkeeper (Owner) Features
- Add new customers
- View customer list
- Add credit (+) and debit (–) transactions
- Digital replacement of traditional khata book
- Simple and user-friendly interface

### 👤 Customer Features
- Separate customer dashboard
- View ledger details (basic)
- Transparent record access

### 🎨 UI & UX
- Splash screen with app branding
- Icon-based logo (no image assets)
- Clean and modern Material UI
- Bottom navigation for easy access

---

## 🛠️ Technology Stack

- **Frontend:** Flutter (Dart)
- **Platform:** Android
- **UI Framework:** Material Design
- **State Management:** Basic Stateful & Stateless Widgets
- **Database:** Not connected yet (Dummy/local data for demo)

---

## 📂 Project Structure

lib/
├── main.dart
└── screens/
├── splash_screen.dart
├── home_screen.dart
├── signup_screen.dart
├── login_screen.dart
├── owner_dashboard.dart
├── customer_dashboard.dart
├── add_customer_screen.dart
├── customer_list_screen.dart
└── add_transaction_screen.dart


---

## 🚀 How to Run the Project

1. Install **Flutter SDK**
2. Set up **Android Studio** and Android Emulator
3. Clone the repository:
   ```bash
   git clone <your-repo-url>
Navigate to project folder:

cd smart_khata
Get dependencies:

flutter pub get
Run the app:

flutter run
🎓 Academic Details
Course: MCA

Semester: 2

Project Type: Group Mini Project

Purpose: Academic Submission

🔮 Future Enhancements
Backend integration using Node.js & MongoDB

Secure authentication with JWT / Firebase

Payment reminders and notifications

Graphical spending analysis for customers

Cloud data storage

👥 Team Contribution
This project is developed as a group project, with responsibilities divided among team members for frontend development, logic implementation, UI design, and documentation.

📝 Conclusion
Smart Khata provides a simple, digital solution to manage daily financial records for small businesses.
The application reduces manual errors, improves transparency, and offers a user-friendly alternative to traditional paper-based khata books.

