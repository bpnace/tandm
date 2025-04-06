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

## Development Roadmap

(Link to or detail the phases outlined above)

1.  **Phase 1:** Project Setup & Core Firebase Integration
2.  **Phase 2:** User Profile Management
3.  **Phase 3:** Collectives Management
4.  **Phase 4:** Project Management
5.  **Phase 5:** Task Management
6.  **Phase 6:** Invoice Management
7.  **Phase 7:** Firebase Functions & Storage
8.  **Phase 8:** UI Refinement, Error Handling & Final Testing

---

*This README will be updated as development progresses.* 