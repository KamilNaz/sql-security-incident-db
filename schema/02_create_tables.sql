-- =====================================================
-- Security Incident Database - Table Creation Script
-- Author: Kamil Nazaruk
-- Description: Creates core tables for incident tracking
-- =====================================================

USE SecurityIncidents;
GO

-- =====================================================
-- Facilities Table
-- =====================================================
CREATE TABLE Facilities (
    FacilityID INT IDENTITY(1,1) PRIMARY KEY,
    FacilityName NVARCHAR(100) NOT NULL,
    Location NVARCHAR(200),
    FacilityType NVARCHAR(50),
    Capacity INT,
    IsActive BIT DEFAULT 1,
    CreatedDate DATETIME DEFAULT GETDATE(),
    ModifiedDate DATETIME DEFAULT GETDATE()
);

-- =====================================================
-- Categories Table
-- =====================================================
CREATE TABLE Categories (
    CategoryID INT IDENTITY(1,1) PRIMARY KEY,
    CategoryName NVARCHAR(100) NOT NULL,
    Description NVARCHAR(500),
    ParentCategoryID INT NULL,
    IsActive BIT DEFAULT 1,
    FOREIGN KEY (ParentCategoryID) REFERENCES Categories(CategoryID)
);

-- =====================================================
-- Personnel Table
-- =====================================================
CREATE TABLE Personnel (
    PersonnelID INT IDENTITY(1,1) PRIMARY KEY,
    FirstName NVARCHAR(50) NOT NULL,
    LastName NVARCHAR(50) NOT NULL,
    Email NVARCHAR(100),
    Phone NVARCHAR(20),
    Role NVARCHAR(50),
    FacilityID INT,
    IsActive BIT DEFAULT 1,
    HireDate DATE,
    CreatedDate DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (FacilityID) REFERENCES Facilities(FacilityID)
);

-- =====================================================
-- Incidents Table (Main)
-- =====================================================
CREATE TABLE Incidents (
    IncidentID INT IDENTITY(1,1) PRIMARY KEY,
    FacilityID INT NOT NULL,
    CategoryID INT NOT NULL,
    IncidentDate DATETIME NOT NULL DEFAULT GETDATE(),
    ReportedBy INT NOT NULL,
    Severity NVARCHAR(20) CHECK (Severity IN ('Low', 'Medium', 'High', 'Critical')),
    Status NVARCHAR(20) DEFAULT 'Open' CHECK (Status IN ('Open', 'In Progress', 'Resolved', 'Closed')),
    Title NVARCHAR(200) NOT NULL,
    Description NVARCHAR(MAX),
    Location NVARCHAR(200),
    ResolutionDate DATETIME NULL,
    ResolvedBy INT NULL,
    ResolutionNotes NVARCHAR(MAX),
    EstimatedCost DECIMAL(10,2),
    ActualCost DECIMAL(10,2),
    CreatedDate DATETIME DEFAULT GETDATE(),
    ModifiedDate DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (FacilityID) REFERENCES Facilities(FacilityID),
    FOREIGN KEY (CategoryID) REFERENCES Categories(CategoryID),
    FOREIGN KEY (ReportedBy) REFERENCES Personnel(PersonnelID),
    FOREIGN KEY (ResolvedBy) REFERENCES Personnel(PersonnelID)
);

-- =====================================================
-- Actions Table
-- =====================================================
CREATE TABLE Actions (
    ActionID INT IDENTITY(1,1) PRIMARY KEY,
    IncidentID INT NOT NULL,
    ActionDate DATETIME DEFAULT GETDATE(),
    PerformedBy INT NOT NULL,
    ActionType NVARCHAR(50),
    ActionDescription NVARCHAR(MAX),
    Status NVARCHAR(20),
    CreatedDate DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (IncidentID) REFERENCES Incidents(IncidentID),
    FOREIGN KEY (PerformedBy) REFERENCES Personnel(PersonnelID)
);

-- =====================================================
-- Audit Log Table
-- =====================================================
CREATE TABLE AuditLog (
    AuditID INT IDENTITY(1,1) PRIMARY KEY,
    TableName NVARCHAR(50) NOT NULL,
    RecordID INT NOT NULL,
    OperationType NVARCHAR(20) CHECK (OperationType IN ('INSERT', 'UPDATE', 'DELETE')),
    OldValue NVARCHAR(MAX),
    NewValue NVARCHAR(MAX),
    ChangedBy NVARCHAR(100),
    ChangeDate DATETIME DEFAULT GETDATE(),
    IPAddress NVARCHAR(45)
);

-- =====================================================
-- Metrics Table (for dashboard/reporting)
-- =====================================================
CREATE TABLE IncidentMetrics (
    MetricID INT IDENTITY(1,1) PRIMARY KEY,
    MetricDate DATE NOT NULL,
    FacilityID INT,
    TotalIncidents INT DEFAULT 0,
    OpenIncidents INT DEFAULT 0,
    ClosedIncidents INT DEFAULT 0,
    AvgResolutionHours DECIMAL(10,2),
    HighSeverityCount INT DEFAULT 0,
    CriticalSeverityCount INT DEFAULT 0,
    CreatedDate DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (FacilityID) REFERENCES Facilities(FacilityID)
);

-- =====================================================
-- Comments Table
-- =====================================================
CREATE TABLE Comments (
    CommentID INT IDENTITY(1,1) PRIMARY KEY,
    IncidentID INT NOT NULL,
    CommentBy INT NOT NULL,
    CommentText NVARCHAR(MAX),
    CommentDate DATETIME DEFAULT GETDATE(),
    IsInternal BIT DEFAULT 0,
    FOREIGN KEY (IncidentID) REFERENCES Incidents(IncidentID),
    FOREIGN KEY (CommentBy) REFERENCES Personnel(PersonnelID)
);

-- =====================================================
-- Create Indexes for Performance
-- =====================================================

-- Incidents table indexes
CREATE INDEX IX_Incidents_FacilityID ON Incidents(FacilityID);
CREATE INDEX IX_Incidents_CategoryID ON Incidents(CategoryID);
CREATE INDEX IX_Incidents_IncidentDate ON Incidents(IncidentDate);
CREATE INDEX IX_Incidents_Status ON Incidents(Status);
CREATE INDEX IX_Incidents_Severity ON Incidents(Severity);
CREATE INDEX IX_Incidents_Composite ON Incidents(FacilityID, IncidentDate, Status);

-- Actions table indexes
CREATE INDEX IX_Actions_IncidentID ON Actions(IncidentID);
CREATE INDEX IX_Actions_ActionDate ON Actions(ActionDate);

-- Personnel table indexes
CREATE INDEX IX_Personnel_FacilityID ON Personnel(FacilityID);
CREATE INDEX IX_Personnel_Email ON Personnel(Email);

-- Audit Log indexes
CREATE INDEX IX_AuditLog_TableName ON AuditLog(TableName);
CREATE INDEX IX_AuditLog_RecordID ON AuditLog(RecordID);
CREATE INDEX IX_AuditLog_ChangeDate ON AuditLog(ChangeDate);

GO

PRINT 'Tables and indexes created successfully!';
