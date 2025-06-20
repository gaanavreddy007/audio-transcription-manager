
# DevifyX – Audio Transcription Manager (MySQL Core Assignment)

## 🎯 Objective
Design and implement a robust MySQL-only database to manage:
- Audio files and metadata
- Transcriptions (with versioning and languages)
- User management
- Tagging and search
- Audit logs
- Role-based access control

This is a backend-only project using DDL, DML, views, triggers, and stored procedures.

---

## 🗂️ Database Name
```sql
AudioTranscriptionDB
```

---

## 📐 Schema Overview

- **Users**: User details and IDs
- **AudioFiles**: Metadata for audio files
- **Transcriptions**: Linked to audio files, supports multiple versions and languages
- **Languages**: Centralized language table (e.g., 'en', 'hi')
- **Tags** and **AudioTags**: Categorization system for audio files
- **AuditLogs**: Tracks uploads, edits, deletions
- **Roles** and **UserRoles**: Admin, Transcriber, Reviewer with access mapping

---

## ✅ Features Implemented

| Feature                      | Status |
|------------------------------|--------|
| Audio File Metadata Storage  | ✅     |
| Transcription Versioning     | ✅     |
| User Management              | ✅     |
| Language Support             | ✅     |
| Tagging System               | ✅     |
| Search Functionality         | ✅     |
| Status Tracking              | ✅     |
| Audit Logging                | ✅     |
| Role-Based Access Control    | ✅     |
| Soft Delete (Trigger)        | ✅     |
| Stored Procedures            | ✅     |
| Views for Reporting          | ✅     |
| Sample Data (10+ Audio Files)| ✅     |

---

## 🚀 How to Run

1. Open **MySQL Workbench**
2. Run the following:
```sql
CREATE DATABASE AudioTranscriptionDB;
USE AudioTranscriptionDB;
```
3. Load the provided `.sql` file and execute all statements.
4. Test features using final query section or stored procedures.

---

## 🧪 Sample Stored Procedures

```sql
CALL SearchAudioFiles('interview');
CALL BulkInsertAudioFiles();
```

---

## 🔎 Useful Views

```sql
SELECT * FROM View_Audio_Tags;
SELECT * FROM View_Transcribed_Audio;
SELECT * FROM View_Reviewed_Files;
```

---

## 🛡️ Special Features

- **Soft Delete Trigger**: Prevents physical delete
- **Audit Trail**: Automatically records user actions
- **Multi-language Transcriptions**: Supported via FK to `Languages`
- **Normalized Structure**: All keys properly related

---

## 📦 Sample Data Includes:

- 5+ Users
- 10+ Audio Files
- 8+ Transcriptions
- Tags, Roles, Logs
- Multiple transcription versions and languages

---

## 📁 Deliverables

- `audio_transcription_manager.sql` → Full MySQL script  
- `README.md` → This file  
- Submit via: [Submission Form](https://forms.gle/HZxnwbzDnmLzMsqTA)

---

## 🧠 AI Tool Usage

AI tools like ChatGPT were used for code structuring and generation only. All logic and relationships were carefully reviewed and crafted independently.

---

## 🏁 End of README
