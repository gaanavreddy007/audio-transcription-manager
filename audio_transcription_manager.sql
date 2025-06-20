
-- ================================================
-- DevifyX Audio Transcription Manager SQL Script
-- ================================================

-- Step 1: Create Database
CREATE DATABASE IF NOT EXISTS AudioTranscriptionDB;
USE AudioTranscriptionDB;

-- Step 2: Create Users Table
CREATE TABLE Users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(100) UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Step 3: Create AudioFiles Table
CREATE TABLE AudioFiles (
    audio_id INT AUTO_INCREMENT PRIMARY KEY,
    filename VARCHAR(100) NOT NULL,
    file_type VARCHAR(10),
    duration INT,
    upload_date DATE,
    uploader_id INT,
    status ENUM('pending', 'transcribed', 'reviewed') DEFAULT 'pending',
    is_deleted BOOLEAN DEFAULT FALSE,
    deleted_at DATETIME DEFAULT NULL,
    FOREIGN KEY (uploader_id) REFERENCES Users(user_id)
);

-- Step 4: Create Transcriptions Table
CREATE TABLE Transcriptions (
    transcription_id INT AUTO_INCREMENT PRIMARY KEY,
    audio_id INT NOT NULL,
    version INT NOT NULL,
    content TEXT NOT NULL,
    language_code VARCHAR(10) DEFAULT 'en',
    transcriber_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (audio_id) REFERENCES AudioFiles(audio_id),
    FOREIGN KEY (transcriber_id) REFERENCES Users(user_id),
    UNIQUE(audio_id, version)
);

-- Step 5: Create Languages Table
CREATE TABLE Languages (
    language_code VARCHAR(10) PRIMARY KEY,
    language_name VARCHAR(50) NOT NULL UNIQUE
);

-- Step 6: Add FK to Transcriptions
ALTER TABLE Transcriptions
ADD CONSTRAINT fk_language
FOREIGN KEY (language_code) REFERENCES Languages(language_code);

-- Step 7: Create Tags Table
CREATE TABLE Tags (
    tag_id INT AUTO_INCREMENT PRIMARY KEY,
    tag_name VARCHAR(50) NOT NULL UNIQUE
);

-- Step 8: Create AudioTags Table
CREATE TABLE AudioTags (
    audio_id INT NOT NULL,
    tag_id INT NOT NULL,
    PRIMARY KEY (audio_id, tag_id),
    FOREIGN KEY (audio_id) REFERENCES AudioFiles(audio_id),
    FOREIGN KEY (tag_id) REFERENCES Tags(tag_id)
);

-- Step 9: Create AuditLogs Table
CREATE TABLE AuditLogs (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    action_type ENUM('upload', 'edit', 'delete') NOT NULL,
    user_id INT NOT NULL,
    audio_id INT,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    details TEXT,
    FOREIGN KEY (user_id) REFERENCES Users(user_id),
    FOREIGN KEY (audio_id) REFERENCES AudioFiles(audio_id)
);

-- Step 10: Create Roles and UserRoles
CREATE TABLE Roles (
    role_id INT AUTO_INCREMENT PRIMARY KEY,
    role_name VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE UserRoles (
    user_id INT,
    role_id INT,
    PRIMARY KEY (user_id, role_id),
    FOREIGN KEY (user_id) REFERENCES Users(user_id),
    FOREIGN KEY (role_id) REFERENCES Roles(role_id)
);

-- Step 11: Soft Delete Trigger
DELIMITER $$

CREATE TRIGGER before_audiofile_delete
BEFORE DELETE ON AudioFiles
FOR EACH ROW
BEGIN
    UPDATE AudioFiles
    SET is_deleted = TRUE,
        deleted_at = NOW()
    WHERE audio_id = OLD.audio_id;

    INSERT INTO AuditLogs (action_type, user_id, audio_id, details)
    VALUES ('delete', OLD.uploader_id, OLD.audio_id, 'Soft deleted by trigger');

    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Soft delete enforced. Row not physically deleted.';
END$$

DELIMITER ;

-- Step 12: Stored Procedures
DELIMITER $$

CREATE PROCEDURE SearchAudioFiles(IN search_term VARCHAR(100))
BEGIN
    SELECT 
        af.audio_id,
        af.filename,
        af.status,
        u.username AS uploader,
        GROUP_CONCAT(DISTINCT t.tag_name) AS tags,
        GROUP_CONCAT(DISTINCT tr.content) AS transcriptions
    FROM AudioFiles af
    LEFT JOIN Users u ON af.uploader_id = u.user_id
    LEFT JOIN AudioTags at ON af.audio_id = at.audio_id
    LEFT JOIN Tags t ON at.tag_id = t.tag_id
    LEFT JOIN Transcriptions tr ON af.audio_id = tr.audio_id
    WHERE 
        af.filename LIKE CONCAT('%', search_term, '%')
        OR u.username LIKE CONCAT('%', search_term, '%')
        OR t.tag_name LIKE CONCAT('%', search_term, '%')
        OR tr.content LIKE CONCAT('%', search_term, '%')
    GROUP BY af.audio_id;
END$$

CREATE PROCEDURE BulkInsertAudioFiles()
BEGIN
    INSERT INTO AudioFiles (filename, file_type, duration, upload_date, uploader_id, status)
    VALUES
        ('bulk1.mp3', 'mp3', 300, CURDATE(), 1, 'pending'),
        ('bulk2.wav', 'wav', 900, CURDATE(), 2, 'transcribed'),
        ('bulk3.m4a', 'm4a', 400, CURDATE(), 3, 'reviewed');
END$$

DELIMITER ;

-- Step 13: Views
CREATE VIEW View_Transcribed_Audio AS
SELECT 
    af.audio_id,
    af.filename,
    af.status,
    u.username AS uploader,
    COUNT(t.transcription_id) AS total_versions
FROM AudioFiles af
JOIN Users u ON af.uploader_id = u.user_id
JOIN Transcriptions t ON af.audio_id = t.audio_id
GROUP BY af.audio_id
HAVING total_versions > 0;

CREATE VIEW View_Reviewed_Files AS
SELECT 
    af.audio_id,
    af.filename,
    af.status,
    u.username AS uploader,
    af.upload_date
FROM AudioFiles af
JOIN Users u ON af.uploader_id = u.user_id
WHERE af.status = 'reviewed' AND af.is_deleted = FALSE;

CREATE VIEW View_Audio_Tags AS
SELECT 
    af.audio_id,
    af.filename,
    GROUP_CONCAT(t.tag_name) AS tags
FROM AudioFiles af
LEFT JOIN AudioTags at ON af.audio_id = at.audio_id
LEFT JOIN Tags t ON at.tag_id = t.tag_id
WHERE af.is_deleted = FALSE
GROUP BY af.audio_id;

-- Step 14: Sample Data
-- Users
INSERT INTO Users (username, email) VALUES
('gaanav', 'gaanav@example.com'),
('ravi123', 'ravi123@example.com'),
('megha_k', 'megha.k@example.com'),
('arjun_dev', 'arjun.dev@example.com'),
('nisha_t', 'nisha.t@example.com');

-- Audio Files
INSERT INTO AudioFiles (filename, file_type, duration, upload_date, uploader_id, status) VALUES
('interview1.mp3', 'mp3', 300, '2025-06-01', 1, 'pending'),
('lecture1.wav', 'wav', 1800, '2025-06-02', 2, 'transcribed'),
('meeting_notes.m4a', 'm4a', 600, '2025-06-03', 3, 'reviewed'),
('webinar.mp3', 'mp3', 1500, '2025-06-04', 2, 'pending'),
('demo_audio.mp3', 'mp3', 450, '2025-06-05', 1, 'pending'),
('training.wav', 'wav', 1200, '2025-06-05', 4, 'transcribed'),
('storytelling.aac', 'aac', 900, '2025-06-06', 5, 'reviewed'),
('notes.mp3', 'mp3', 400, '2025-06-07', 3, 'pending'),
('interview2.mp3', 'mp3', 350, '2025-06-08', 1, 'pending'),
('project_audio.wav', 'wav', 1000, '2025-06-09', 4, 'transcribed');

-- Transcriptions
INSERT INTO Transcriptions (audio_id, version, content, language_code, transcriber_id) VALUES
(1, 1, 'Hello, this is the first transcription of interview1.', 'en', 2),
(1, 2, 'Updated transcription with minor edits.', 'en', 3),
(2, 1, 'This lecture explains SQL normalization in depth.', 'en', 4),
(3, 1, 'Meeting notes about upcoming product launch.', 'en', 1),
(5, 1, 'Demo audio describing the new app features.', 'en', 5),
(5, 2, 'Demo audio - improved transcription.', 'en', 2),
(7, 1, 'Storytelling audio in Hindi.', 'hi', 4),
(8, 1, 'Short notes on data pipelines.', 'en', 3);

-- Languages
INSERT INTO Languages (language_code, language_name) VALUES
('en', 'English'),
('hi', 'Hindi'),
('ta', 'Tamil'),
('te', 'Telugu'),
('bn', 'Bengali'),
('ur', 'Urdu');

-- Tags
INSERT INTO Tags (tag_name) VALUES
('interview'),
('lecture'),
('meeting'),
('demo'),
('training'),
('webinar'),
('storytelling'),
('project');

-- AudioTags
INSERT INTO AudioTags (audio_id, tag_id) VALUES
(1, 1), (2, 2), (3, 3), (4, 6), (5, 4), (6, 5), (7, 7), (9, 1), (10, 8);

-- AuditLogs
INSERT INTO AuditLogs (action_type, user_id, audio_id, details) VALUES
('upload', 1, 1, 'Uploaded interview1.mp3'),
('upload', 2, 2, 'Uploaded lecture1.wav'),
('upload', 3, 3, 'Uploaded meeting_notes.m4a'),
('edit', 3, 1, 'Edited transcription version 2 for interview1'),
('upload', 1, 5, 'Uploaded demo_audio.mp3'),
('delete', 4, 6, 'Deleted training.wav (soft delete)'),
('upload', 5, 7, 'Uploaded storytelling.aac in Hindi'),
('edit', 2, 5, 'Updated demo_audio.mp3 transcription to version 2');

-- Roles and UserRoles
INSERT INTO Roles (role_name) VALUES ('admin'), ('transcriber'), ('reviewer');
INSERT INTO UserRoles (user_id, role_id) VALUES
(1, 1), (2, 2), (3, 2), (3, 3), (4, 3), (5, 2);
