# SentinelsHQ - Cyber Sentinels Club Management App

## Overview

SentinelsHQ is a Flutter & Firebase-powered mobile application designed for managing the Cyber Sentinels Club at REC, Chennai. The app streamlines team management, task assignments, event organization, resource sharing, and issue tracking, providing an efficient and user-friendly experience for club members, admins, and super admins.

## Features

### 🏛 User Roles & Permissions

The app is structured around three user roles, each with specific privileges:

- **🔹 Super Admin (SA)**
  - Full control over the application
  - Manages admins, members, tasks, events, and resources
  - Resolves issues raised by users

- **🔹 Admins (President, VP, Founders, Leads)**
  - Manage team members
  - Assign and track tasks
  - Organize events
  - Approve task completions
  - Handle issue resolution

- **🔹 Team Members (Design, Content, PR, Event, Tech, etc.)**
  - View assigned tasks
  - Mark tasks as completed (verified by admins)
  - Raise and track issues
  - Access shared resources and event details

### Core Modules & Implementations

- **✅ 1. User Authentication**
  - Firebase Authentication used for secure login & account creation
  - Each user’s role is determined based on Firestore data
  - Users are redirected to the appropriate dashboard based on their role

- **🏢 2. Super Admin Dashboard**
  - The Super Admin has access to all functionalities in the app, including:
    - Managing Admins & Members
    - Assigning & Tracking Tasks
    - Handling Issues Raised by Users
    - Organizing & Overseeing Events
    - Managing Shared Resources

- **📂 3. Team Management**
  - View & Manage Members
  - Members are categorized by teams (Design, Content, PR, Tech, Event, etc.)
  - Admins & Super Admins can add/remove users from teams

- **📌 4. Task Management**
  - Admins can assign tasks to specific teams or individuals
  - Team members can view & update task status
  - Task completion requires admin verification
  - Tasks include:
    - Title
    - Description
    - Assigned to (team/member)
    - Due date
    - Status (Pending, In Progress, Completed)

- **📅 5. Event Management**
  - Admins can create & manage events
  - Events include:
    - Title
    - Date & Time
    - Description
    - Location (if applicable)
    - Participants
  - Users can view upcoming events

- **📜 6. Resource Management**
  - Admins can upload and share important resources
  - Resources include documents, links, images, PDFs
  - Users can access, download, and view shared resources

- **🛠 7. Issue Tracking System**
  - Users can raise issues, which are tracked through a status-based system:
    - **🔄 Issue Status Flow:**
      1. **RAISED** → User raises an issue
      2. **ACK** → Admin acknowledges the issue
      3. **FIXED** → Admin marks the issue as resolved
      4. **FIXED_ACK** → User confirms resolution
    - **🛠 Issue Details Include:**
      - Issue ID
      - Description
      - Raised By (Name & Contact)
      - Status
      - Call & WhatsApp buttons for direct communication
  - Admins can filter & sort issues based on status and priority.

- **⚙ 8. Settings Screen**
  - View/Edit Profile (Currently a dummy implementation)
  - Logout with confirmation
  - Navigate to the About Page

- **ℹ 9. About Page**
  - The About Page provides details about:
    - The SentinelsHQ app and its purpose
    - Rahul Babu M P (developer & founder of the Cyber Sentinels Club)
    - Contact information with links to:
      - GitHub
      - Portfolio
      - Email
      - Phone

## Tech Stack

- **Frontend:**
  - Flutter (Dart) for UI & app logic
  - Provider for state management

- **Backend & Database:**
  - Firebase Authentication (User login/signup)
  - Cloud Firestore (Database for user roles, tasks, events, resources, and issues)
  - Firebase Storage (For storing shared resources & documents)

- **Other Technologies Used:**
  - URL Launcher (For opening external links like WhatsApp, GitHub, etc.)
  - Firebase Firestore Querying (For filtering & sorting data efficiently)

## Future Enhancements

- **🚀 Potential Features for Future Updates:**
  - Push Notifications for tasks, events, and issue updates
  - In-App Messaging for team collaboration
  - Dark Mode Support
  - Better Profile Customization

## How to Run the Project?

1. **Prerequisites**
   - Ensure you have the following installed:
     - Flutter SDK
     - Android Studio / VS Code
     - Firebase Setup (Follow Firebase setup for Flutter)

2. **Clone the Repository**
   ```bash
   git clone https://github.com/yourusername/SentinelsHQ.git
   cd SentinelsHQ
   ```

3. **Install Dependencies**
   ```bash
   flutter pub get
   ```

4. **Run the App**
   ```bash
   flutter run
   ```

## Contributors

- **👨‍💻 Developed by Rahul Babu M P**
   - 📧 Email: rahulbabuoffl@gmail.com
   - 🌐 Portfolio: https://rahulbabump.online
   - 🔗 GitHub: rahulthewhitehat
