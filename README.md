# tandm - iOS App

## Overview

This is the native iOS application for tandm, allowing freelancers to manage collectives, projects, tasks, and invoices. It utilizes Firebase for backend services.

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

## Setup Instructions

*(Placeholder - To be filled in once basic setup is complete)*

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