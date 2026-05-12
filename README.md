# tandm - iOS App

[![Source Check](https://github.com/bpnace/tandm/actions/workflows/source-check.yml/badge.svg?branch=main)](https://github.com/bpnace/tandm/actions/workflows/source-check.yml)
![Version](https://img.shields.io/badge/version-MVP_build_log-2563EB?style=flat-square)
![Swift](https://img.shields.io/badge/Swift-iOS-F05138?style=flat-square&logo=swift&logoColor=white)
![SwiftUI](https://img.shields.io/badge/SwiftUI-native_UI-0ea5e9?style=flat-square&logo=swift&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase-backend-FFCA28?style=flat-square&logo=firebase&logoColor=111827)
![Status](https://img.shields.io/badge/status-in_development-F97316?style=flat-square)
![Contributors](https://img.shields.io/badge/contributors-welcome-2ea043?style=flat-square)

## Overview

tandm is an in-development native iOS project for freelancers and small
collectives. The app explores how independent teams can manage collectives,
projects, tasks, and invoices from one SwiftUI/Firebase workspace.

This repository is public as a contributor-friendly build log. The core product
areas are visible, several MVP slices are implemented, and the remaining work is
explicitly tracked below.

## What this shows

- Native SwiftUI product architecture for a multi-entity productivity app
- Firebase Auth, Firestore services, and cloud-backed user data
- Incremental MVP delivery across profiles, collectives, projects, tasks, and invoices
- A contributor-friendly roadmap with clear next polish and testing work

## Tech Stack

-   **UI:** SwiftUI
-   **Backend:** Firebase
    -   Authentication: Firebase Auth (Email/Password, Google)
    -   Database: Firestore
    -   Serverless Functions: Firebase Functions
    -   Storage: Firebase Storage (for profile images, etc. - TBD)
-   **Language:** Swift
-   **Package Manager:** Swift Package Manager (SPM)

## Features (MVP Roadmap)

-   [ ] User Authentication (Login, Signup)
-   [ ] User Profile Management
-   [ ] Collective Creation & Management
-   [ ] Inviting Members to Collectives
-   [ ] Project Creation & Management within Collectives
-   [ ] Task Management within Projects
-   [ ] Invoice Creation & Management (Drafts)
-   [ ] Basic PDF Invoice Generation Trigger

## Contribution Areas

- Polish SwiftUI screens and empty states
- Improve Firebase service boundaries and error handling
- Add test coverage around view models and data services
- Expand invoice export and PDF generation
- Improve onboarding and contributor setup notes

## Setup Instructions

1.  Clone the repository.
2.  Ensure you have Xcode installed.
3.  Configure Firebase:
    *   Create a Firebase project.
    *   Add an iOS app configuration.
    *   Download the `GoogleService-Info.plist` file and place it in the appropriate location within the Xcode project structure (e.g., `/tandm/`).
4.  Open the `.xcodeproj` or `.xcworkspace` file in Xcode.
5.  Build and run the project on a simulator or device.

## Development Roadmap (MVP)

- [x] **Phase 1: Setup & Authentication**
    - [x] Project Setup (Xcode, SPM)
    - [x] Firebase Integration (Core, Auth, Firestore)
    - [x] Basic Login/Signup UI (`AuthenticationView`, `LoginView`, `SignUpView`)
    - [x] Authentication Logic (`AuthenticationViewModel`)
    - [x] User Model (`User.swift`)
    - [x] Firestore User Service (`UserService.swift` - basic create/fetch)

- [x] **Phase 2: User Profile Management**
    - [x] User Profile View (`UserProfileView.swift`)
    - [x] User Profile View Model (`UserProfileViewModel.swift`)
    - [x] Update `UserService.swift` for profile CRUD.

- [x] **Phase 3: Collective Management**
    - [x] Collective Model (`Collective.swift`)
    - [x] Collective Service (`CollectiveService.swift`)
    - [x] Collective View Model (`CollectiveViewModel.swift`)
    - [x] Collective List View (`CollectivesListView.swift` - *Implicitly part of `MainAppView` for now*)
    - [x] Collective Detail View (`CollectiveDetailView.swift`)
    - [x] Create Collective View (`CreateCollectiveView.swift` - *Integrated via Alert for now*)
    - [x] Invite Member Functionality (`InviteMemberView.swift`, `UserService.fetchUser(byEmail:)`, `CollectiveViewModel.inviteMember(...)`)

- [x] **Phase 4: Project Management**
    - [x] Project Model (`Project.swift`)
    - [x] Project Service (`ProjectService.swift`)
    - [x] Project View Model (`ProjectViewModel.swift`)
    - [x] Display Projects in `CollectiveDetailView`.
    - [x] Create Project View (`CreateProjectView.swift`)

- [x] **Phase 5: Task Management**
    - [x] Task Model (`TaskModel.swift`)
    - [x] Task Service (`TaskService.swift` - fetch/create)
    - [x] Task View Model (`TaskViewModel.swift` - fetch/create, update, delete)
    - [x] Project Detail View (`ProjectDetailView.swift` - display tasks, swipe actions, context menu for assignment)
    - [x] Create Task View (`CreateTaskView.swift`)
    - [x] Task Updates (Status, Assignment - *Implemented via UI*)
    - [x] Task Deletion (*via Swipe*)

- [x] **Phase 6: Invoice Management (MVP)**
    - [x] Invoice Model (`Invoice.swift`)
    - [x] Invoice Service (`InvoiceService.swift`)
    - [x] Invoice View Model (`InvoiceViewModel.swift`)
    - [x] Basic Invoice List/Detail Views (List in `CollectiveDetailView`)
    - [x] Create Invoice View (`CreateInvoiceView.swift`)

- [ ] **Phase 7: Final Polish & Repo**
    - [ ] Code Cleanup & Refinements
    - [x] Create GitHub Repository & Initial Push
    - [ ] Further Testing

---

*This README will be updated as development progresses.*
