# Readify - A Book Sharing and Community App

![Image](https://github.com/user-attachments/assets/5200b61e-80fc-4e4a-9ca8-4d0ea9aee1d5)

Readify is a social book-sharing application designed to foster a community of readers. Built with Flutter, Firebase & Supabase, Readify provides a seamless and engaging reading experience while emphasizing social interaction through messaging, notifications, and personalized profiles.

## Overview

Readify helps users stay connected with several core functionalities:
- **Book Sharing**: Upload and share books with the community.
- **Browsing & Searching**: Find books by browsing or searching by title, author, or genre.
- **Messaging**: Message other users, send book borrow requests, and manage book exchanges.
- **Notifications**: Receive updates on book requests, new messages, and book statuses.
- **Profiles**: Customize profiles, track favorite and borrowed books, and interact with the community.
- **Bookmarking**: Bookmark books for future reference or exchange.
- **Nearby Books**: Identify books available near the user's current location using location services.

## Key Features

### Home Page
- Overview of available books with title, author, and description.
- Navigate to book details and initiate exchange requests.

### Notifications
- Updates on book requests and exchanges, with options to view details and respond.

### Messaging
- Send and receive messages about book exchanges, accept or reject requests via chat.

### Profile Page
- Showcases user’s name, bio, favorite books, borrowing history, and pending exchange requests.
- Allows profile customization and updates to the favorite books list.

### Bookmarking
- Keep track of books for future exchange or borrowing.

### Nearby Books
- Identify books near the user's location for local exchanges.

### Push Notifications
- Notify users about important activities like new book exchanges and messages.

## Tech Stack
- **Flutter**: Cross-platform framework for iOS and Android apps.
- **Firebase**:
  - Firebase Authentication: User sign-in and authentication management.
  - Firestore Database: Stores user data, book information, exchange requests, and chat messages.
  - Firebase Cloud Messaging: Sends push notifications.
- **Supabase**: 
  - Supabase Storage: Stores user profile images and book images.

## Future Features
- **User Ratings**: Implement ratings and reviews for users after exchanges.
- **Exchange Agreements**: Structured agreements with due dates and terms.
- **Book Tracking**: Enable tracking for high-value books.
- **Dispute Resolution**: Features for handling disputes and

## Benefits
- **Fostering a Reading Community**: Readify connects people who share an interest in reading, offering an opportunity to exchange books with others and discover new reading materials.
- **Sustainability**: By encouraging the sharing of books, Readify helps reduce the need to purchase new books, promoting a more sustainable way of enjoying literature.
- **Convenience**: The app makes it easy for users to find and borrow books without leaving the comfort of their homes, streamlining the exchange process through messaging and notifications.

## Installation and Setup
To run Readify locally, follow these steps:

1. **Clone the repository**:
    ```bash
    git clone https://github.com/lucifer3618/Readify-Flutter-Project.git
    cd Readify-Flutter-Project
    ```

2. **Install dependencies**:
    ```bash
    flutter pub get
    ```

3. **Firebase Configuration**:
    - Create a Firebase project and configure Firebase services (Authentication, Firestore, Cloud Messaging).
    - Download the `google-services.json` for Android or `GoogleService-Info.plist` for iOS and place them in the appropriate directories (`android/app` or `ios/Runner`).

4. **Run the app**:
    ```bash
    flutter run
    ```

## License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
