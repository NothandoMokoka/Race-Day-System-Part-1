IF DB_ID('RaceDay.sql') IS NOT NULL
BEGIN
   ALTER DATABASE RaceDay.sql SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
   DROP DATABASE RaceDay.sql;
END;
GO
CREATE DATABASE RaceDay;
GO
USE RaceDay.sql;
GO
 
CREATE TABLE Role
(
   RoleID INT IDENTITY(1,1) NOT NULL,
   RoleName VARCHAR(20) NOT NULL,
   Description VARCHAR(100) NULL,
   CONSTRAINT PK_Role PRIMARY KEY (RoleID),
   CONSTRAINT UQ_Role_RoleName UNIQUE (RoleName)
);
GO
 
CREATE TABLE [User]
(
   UserID INT IDENTITY(1,1) NOT NULL,
   RoleID INT NOT NULL,
   FirstName VARCHAR(50) NOT NULL,
   LastName VARCHAR(50) NOT NULL,
   Email VARCHAR(100) NOT NULL,
   PasswordHash VARCHAR(255) NOT NULL,
   PhoneNumber VARCHAR(20) NULL,
   CreatedDate DATETIME NOT NULL
       CONSTRAINT DF_User_CreatedDate DEFAULT GETDATE(),
   CONSTRAINT PK_User PRIMARY KEY (UserID),
   CONSTRAINT UQ_User_Email UNIQUE (Email),
   CONSTRAINT FK_User_Role FOREIGN KEY (RoleID) REFERENCES Role(RoleID)
);
GO
 
CREATE TABLE Event
(
   EventID INT IDENTITY(1,1) NOT NULL,
   OrganizerID INT NOT NULL,
   Name VARCHAR(150) NOT NULL,
   Description VARCHAR(255) NULL,
   EventDate DATE NOT NULL,
   Location VARCHAR(150) NOT NULL,
   Distance DECIMAL(6,2) NOT NULL,
   EventType VARCHAR(30) NOT NULL,
   CreatedAt DATETIME NOT NULL
       CONSTRAINT DF_Event_CreatedAt DEFAULT GETDATE(),
   CONSTRAINT PK_Event PRIMARY KEY (EventID),
   CONSTRAINT FK_Event_Organizer FOREIGN KEY (OrganizerID) REFERENCES [User](UserID),
   CONSTRAINT CK_Event_Distance CHECK (Distance > 0),
   CONSTRAINT CK_Event_Type CHECK (EventType IN ('Running','Walking','Cycling'))
);
GO
 
CREATE TABLE Category
(
   CategoryID INT IDENTITY(1,1) NOT NULL,
   EventID INT NOT NULL,
   CategoryName VARCHAR(100) NOT NULL,
   MinimumAge INT NULL,
   MaximumAge INT NULL,
   Distance DECIMAL(6,2) NULL,
   CONSTRAINT PK_Category PRIMARY KEY (CategoryID),
   CONSTRAINT FK_Category_Event FOREIGN KEY (EventID) REFERENCES Event(EventID),
   CONSTRAINT UQ_Category_Event_Name UNIQUE (EventID, CategoryName),
   CONSTRAINT CK_Category_MinAge CHECK (MinimumAge IS NULL OR MinimumAge >= 0),
   CONSTRAINT CK_Category_MaxAge CHECK (MaximumAge IS NULL OR MaximumAge >= 0),
   CONSTRAINT CK_Category_AgeRange CHECK
       (MinimumAge IS NULL OR MaximumAge IS NULL OR MinimumAge <= MaximumAge),
   CONSTRAINT CK_Category_Distance CHECK (Distance IS NULL OR Distance > 0)
);
GO
 
CREATE TABLE Enrollment
(
   EnrollmentID INT IDENTITY(1,1) NOT NULL,
   ParticipantID INT NOT NULL,
   EventID INT NOT NULL,
   CategoryID INT NOT NULL,
   EnrollmentDate DATETIME NOT NULL
       CONSTRAINT DF_Enrollment_EnrollmentDate DEFAULT GETDATE(),
   Status VARCHAR(20) NOT NULL
       CONSTRAINT DF_Enrollment_Status DEFAULT 'CONFIRMED',
   CONSTRAINT PK_Enrollment PRIMARY KEY (EnrollmentID),
   CONSTRAINT FK_Enrollment_Participant FOREIGN KEY (ParticipantID) REFERENCES [User](UserID),
   CONSTRAINT FK_Enrollment_Event FOREIGN KEY (EventID) REFERENCES Event(EventID),
   CONSTRAINT FK_Enrollment_Category FOREIGN KEY (CategoryID) REFERENCES Category(CategoryID),
   CONSTRAINT UQ_Enrollment_Participant_Event UNIQUE (ParticipantID, EventID),
   CONSTRAINT CK_Enrollment_Status CHECK (Status IN ('CONFIRMED','CANCELLED'))
);
GO
 
CREATE TABLE Result
(
   ResultID INT IDENTITY(1,1) NOT NULL,
   EnrollmentID INT NOT NULL,
   FinishPosition INT NOT NULL,
   FinishTime TIME NOT NULL,
   RecordedAt DATETIME NOT NULL
       CONSTRAINT DF_Result_RecordedAt DEFAULT GETDATE(),
   CONSTRAINT PK_Result PRIMARY KEY (ResultID),
   CONSTRAINT UQ_Result_Enrollment UNIQUE (EnrollmentID),
   CONSTRAINT FK_Result_Enrollment FOREIGN KEY (EnrollmentID) REFERENCES Enrollment(EnrollmentID),
   CONSTRAINT CK_Result_Position CHECK (FinishPosition > 0)
);
GO
 
/* Roles */
INSERT INTO Role (RoleName, Description)
VALUES
('Organizer', 'User who creates and manages Race Day events.'),
('Participant', 'User who enters events and views personal results.');
GO
 
/* Two organizers and two participants */
INSERT INTO [User]
   (RoleID, FirstName, LastName, Email, PasswordHash, PhoneNumber)
VALUES
(1, 'Lindokuhle', 'Mokoena', 'malindz.organizer@outlook.com', 'HASHED_PASSWORD_1', '0711111111'),
(1, 'Lerato', 'Baloyi', 'lerato.organizer@outlook.com', 'HASHED_PASSWORD_2', '0722222222'),
(2, 'Amahle', 'Dlamini', 'amahledlamini.participant@gmail.com', 'HASHED_PASSWORD_3', '0733333333'),
(2, 'Siphosethu', 'Ndhlovu', 'siphondhlovu.participant@gmail.com', 'HASHED_PASSWORD_4', '0744444444');
GO
 
/* Three events */
INSERT INTO Event
   (OrganizerID, Name, Description, EventDate, Location, Distance, EventType)
VALUES
(1, 'Pretoria City Run', 'Community road running event.', '2026-10-18',
'Pretoria', 10.00, 'Running'),
(1, 'Soweto Community Walk', 'Community charity walking event.', '2026-11-08',
'Soweto', 5.00, 'Walking'),
(2, 'Limpopo Cycle Challenge', 'Road cycling event.', '2026-12-06',
'Polokwane', 50.00, 'Cycling');
GO
 
/* Categories for every event */
INSERT INTO Category
   (EventID, CategoryName, MinimumAge, MaximumAge, Distance)
VALUES
(1, 'Junior 16-17', 16, 17, 10.00),
(1, 'Open 18-39', 18, 39, 10.00),
(1, 'Veteran 40+', 40, NULL, 10.00),
(2, 'Open 18+', 18, NULL, 5.00),
(2, 'Family Walk', 10, NULL, 5.00),
(3, 'Open 18-39', 18, 39, 50.00),
(3, 'Veteran 40+', 40, NULL, 50.00);
GO
 
/* Sample enrolments */
INSERT INTO Enrollment
   (ParticipantID, EventID, CategoryID)
VALUES
(3, 1, 2),
(4, 1, 2),
(3, 2, 4),
(4, 3, 6);
GO
 
/* Sample results */
INSERT INTO Result
   (EnrollmentID, FinishPosition, FinishTime)
VALUES
(1, 1, '01:02:35'),
(2, 2, '01:05:10');
GO
 
/* Verification */
SELECT * FROM Role;
SELECT * FROM [User];
SELECT * FROM Event;
SELECT * FROM Category;
SELECT * FROM Enrollment;
SELECT * FROM Result;
GO
