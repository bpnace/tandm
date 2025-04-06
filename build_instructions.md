# tandm – Firestore Schema & API Endpoint Roadmap (MVP)

## Overview

This document outlines the complete Firestore schema and API function logic to support the MVP of tandm. It is optimized for development via Cursor AI Agent Mode or a small dev team.

---

## 🔧 Tech Stack

- **Frontend**: React or Flutter (PWA/mobile)
- **Backend**: Firebase (Firestore, Functions, Auth)
- **Storage**: Firebase Storage (optional for file uploads)
- **Auth**: Firebase Auth (email, Google, GitHub)
- **Payments (Phase 2)**: Stripe Connect

---

## 📁 Firestore Schema Design

### 👤 USERS

**Collection:** `users`  
**Document ID:** `uid`

**Schema:**
```json
{
  "name": "Eva H.",
  "email": "eva@freelance.com",
  "bio": "UX designer",
  "skills": ["UI/UX", "Figma", "Prototyping"],
  "portfolioUrl": "https://eva.design",
  "profileImage": "path-to-image",
  "createdAt": "timestamp"
}
```

---

### 🤝 COLLECTIVES

**Collection:** `collectives`  
**Document ID:** `auto`

**Schema:**
```json
{
  "name": "Team Spark",
  "members": ["uid1", "uid2", "uid3"],
  "clientFacingName": "Spark Design",
  "createdBy": "uid1",
  "publicPageSlug": "team-spark",
  "createdAt": "timestamp"
}
```

---

### 📦 PROJECTS

**Collection:** `projects`  
**Document ID:** `auto`

**Schema:**
```json
{
  "title": "Landing Page for Acme Co",
  "description": "Design and build new homepage",
  "collectiveId": "spark-123",
  "tasks": [],
  "status": "active",
  "startDate": "2024-04-10",
  "endDate": null,
  "createdAt": "timestamp"
}
```

---

### ✅ TASKS (optional inline or subcollection)

**Inline or Collection:** `projects/{id}/tasks`  
**Schema:**
```json
{
  "title": "Wireframes",
  "assignedTo": "uid2",
  "status": "in-progress",
  "dueDate": "2024-04-15"
}
```

---

### 📄 INVOICES

**Collection:** `invoices`  
**Document ID:** `auto`

**Schema:**
```json
{
  "projectId": "acme-homepage",
  "collectiveId": "spark-123",
  "lineItems": [
    { "description": "Design", "amount": 1200, "freelancerId": "uid1" },
    { "description": "Dev", "amount": 1800, "freelancerId": "uid2" }
  ],
  "total": 3000,
  "status": "draft",
  "dueDate": "2024-05-01",
  "createdAt": "timestamp"
}
```

---

## 🌐 API Endpoints (Firebase Functions)

### `/generateInvoicePdf`

**POST**  
Generates PDF invoice from Firestore entry.

```ts
Input: { invoiceId }
Output: PDF file path
```

---

### `/inviteToCollective`

**POST**  
Sends invite to another freelancer.

```ts
Input: { email, collectiveId }
Output: { success: true }
```

---

### `/updateTaskStatus`

**POST**  
Updates task in Firestore.

```ts
Input: { taskId, status }
Output: { updated: true }
```

---

## 🔐 Firestore Rules

```js
match /users/{uid} {
  allow read, write: if request.auth.uid == uid;
}

match /collectives/{id} {
  allow read, write: if request.auth.uid in resource.data.members;
}
```

---

## 🧪 Testing

- Test document access and write security
- Validate endpoints with mock data
- Run invoice generation logic in emulated function

---
