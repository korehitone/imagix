# Imagix

A modern social image-sharing application inspired by Pinterest, built with Flutter and powered by Supabase. Share images, engage with comments, like posts, save collections, and follow creators in a beautiful Material 3 interface.

**Version**: 1.0.1 | **Platform**: Android | **Language**: Dart 3.11.0+

---

## ✨ Features

### 📸 Core Features
- **Post Images**: Upload and share images with title and description
- **Discover Feed**: Browse infinite feed of posts from all users in a staggered grid layout
- **Like System**: Like/unlike posts with real-time like counter
- **Comments**: Post, edit, delete comments on images with nested reply support
- **Save Collections**: Create custom collections and save posts to them
- **Follow System**: Follow/unfollow users and view their profiles

### 👤 User Management
- **Authentication**: Secure email/password registration and login with Supabase Auth
- **Email Verification**: Email verification on signup with resend capability
- **User Profiles**: Complete user profiles with bio, photo, follow counts
- **Account Management**: Edit profile info, change password, delete account with restoration option
- **Liked Posts**: View all posts you've liked in a dedicated section

### 🔍 Discovery
- **Search Posts**: Search posts by title, description, and tags
- **Search Users**: Discover users and view their profiles
- **User Profiles**: View other users' posts and collections

---

## 🛠️ Tech Stack

### Framework & Architecture
| Component | Version | Purpose |
|-----------|---------|---------|
| **Flutter** | Latest | Cross-platform mobile framework |
| **Dart** | 3.11.0+ | Primary programming language |
| **Clean Architecture** | - | Separation of concerns (data, domain, presentation) |
| **Material Design 3** | Latest | Modern UI design system |

### State Management & Navigation
| Library | Version | Purpose |
|---------|---------|---------|
| **Flutter Riverpod** | 3.3.1 | Reactive state management |
| **Go Router** | 17.1.0 | Modern declarative routing |
| **Async Notifier** | 3.3.1+ | Async state handling |

### Backend & Authentication
| Service | Version | Purpose |
|---------|---------|---------|
| **Supabase** | 2.12.0 | Backend-as-a-Service (Auth, Database, Storage) |
| **Supabase Flutter** | 2.12.0 | Supabase client for Flutter |

### Data & Storage
| Library | Version | Purpose |
|---------|---------|---------|
| **Shared Preferences** | 2.5.4 | Local preferences & user session caching |

### UI & Utilities
| Library | Version | Purpose |
|---------|---------|---------|
| **Flutter SVG** | 2.0.10 | SVG rendering support |
| **Lottie** | 3.3.2 | Animation support |
| **Google Fonts** | 8.0.2 | Custom font integration (Itim font) |
| **Flutter Staggered Grid View** | 0.7.0 | Pinterest-style staggered grid layout |
| **Cupertino Icons** | 1.0.8 | iOS-style icons |
| **Timeago** | 3.7.1 | Relative time display ("2 hours ago") |
| **Image Picker** | 1.2.1 | Camera & gallery image selection |
| **Envied** | 1.3.3 | Environment variables management |
| **Timezone** | 0.11.0 | Timezone support |
| **Flutter Timezone** | 5.0.1 | Platform-specific timezone |

---


### 📊 Directory Details

#### `/lib/data` - Data Layer
Handles all data operations including API calls and local storage.

- **Responsibility**: Communicate with Supabase, transform data
- **Pattern**: Repository Pattern
- **Key Components**:
  - `*_repository_impl.dart` - Data access implementation
  - `*_response.dart` - API response models (DTOs)
  - Mappers - Convert between data and domain layers

#### `/lib/domain` - Domain Layer
Pure business logic independent of frameworks.

- **Responsibility**: Define use cases and business rules
- **Pattern**: Clean Architecture
- **Key Components**:
  - `*_repository.dart` - Repository interfaces
  - `*_use_case.dart` - Business logic
  - Models - Domain entities

#### `/lib/presentation` - Presentation Layer
All UI and user interaction logic.

- **Responsibility**: UI rendering and state management
- **Pattern**: MVVM with Riverpod
- **Key Components**:
  - `*_page.dart` - Screen widgets
  - `*_view_model.dart` - State management
  - Widgets - Reusable UI components

#### `/lib/core` - Shared Resources
Common utilities and configuration used across all layers.

- Theme, colors, text styles
- Environment variables
- Error handling
- Network utilities
- Local storage wrappers
