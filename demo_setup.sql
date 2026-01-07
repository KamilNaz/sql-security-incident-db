-- SQL Security Incident Database - Demo Setup
-- Author: Kamil Nazaruk
-- Description: Creates database schema and loads sample security incident data
--
-- Usage (SQL Server):
--   sqlcmd -S localhost -d SecurityDB -i demo_setup.sql
-- Usage (MySQL):
--   mysql -u root -p SecurityDB < demo_setup.sql
-- Usage (PostgreSQL):
--   psql -d securitydb -f demo_setup.sql

-- =============================================================================
-- DATABASE SCHEMA SETUP
-- =============================================================================

PRINT '========================================================================';
PRINT 'SQL SECURITY INCIDENT DATABASE - DEMO SETUP';
PRINT '========================================================================';
PRINT '';

-- Load schema creation script
PRINT '[*] Creating database schema...';
:r schema/02_create_tables.sql
PRINT '[+] Schema created successfully';
PRINT '';

-- =============================================================================
-- SAMPLE DATA INSERTION
-- =============================================================================

PRINT '[*] Inserting sample security incident data...';

-- Sample incidents (50 records)
INSERT INTO Incidents (IncidentID, Timestamp, IncidentType, Severity, SourceIP, DestinationIP, Port, Protocol, Status, AssignedAnalyst)
VALUES
-- High severity incidents
(1, '2024-01-15 08:23:45', 'Malware Detected', 'CRITICAL', '192.168.1.105', '203.0.113.42', 443, 'HTTPS', 'In Progress', 'analyst01'),
(2, '2024-01-15 09:15:22', 'Data Exfiltration', 'CRITICAL', '192.168.1.87', '198.51.100.15', 443, 'HTTPS', 'Investigating', 'analyst02'),
(3, '2024-01-15 10:45:33', 'Ransomware', 'CRITICAL', '192.168.1.52', '203.0.113.88', 8080, 'HTTP', 'Contained', 'analyst01'),
(4, '2024-01-16 02:34:12', 'Brute Force Attack', 'HIGH', '203.0.113.156', '192.168.1.10', 22, 'SSH', 'Blocked', 'analyst03'),
(5, '2024-01-16 03:22:55', 'SQL Injection', 'HIGH', '198.51.100.77', '192.168.1.200', 3306, 'MySQL', 'Mitigated', 'analyst02'),

-- Medium severity incidents
(6, '2024-01-16 08:11:44', 'Port Scan', 'MEDIUM', '203.0.113.23', '192.168.1.0/24', NULL, 'TCP', 'Closed', 'analyst03'),
(7, '2024-01-16 11:56:18', 'Phishing Attempt', 'MEDIUM', '198.51.100.44', 'user@company.com', 25, 'SMTP', 'Closed', 'analyst01'),
(8, '2024-01-17 07:33:29', 'Unauthorized Access', 'MEDIUM', '192.168.1.95', '192.168.1.250', 3389, 'RDP', 'Investigating', 'analyst02'),
(9, '2024-01-17 14:22:11', 'Suspicious Traffic', 'MEDIUM', '192.168.1.78', '203.0.113.99', 8443, 'HTTPS', 'In Progress', 'analyst03'),
(10, '2024-01-17 16:45:33', 'Policy Violation', 'MEDIUM', '192.168.1.123', '192.168.1.5', 445, 'SMB', 'Closed', 'analyst01'),

-- Low severity incidents
(11, '2024-01-18 09:12:55', 'Failed Login', 'LOW', '192.168.1.67', '192.168.1.10', 22, 'SSH', 'Closed', NULL),
(12, '2024-01-18 10:34:22', 'Configuration Change', 'LOW', '192.168.1.5', '192.168.1.1', 443, 'HTTPS', 'Closed', NULL),
(13, '2024-01-18 13:55:41', 'Antivirus Alert', 'LOW', '192.168.1.89', NULL, NULL, NULL, 'Closed', NULL),
(14, '2024-01-19 08:23:15', 'Firewall Rule Change', 'LOW', '192.168.1.1', NULL, NULL, NULL, 'Closed', 'analyst03'),
(15, '2024-01-19 11:44:29', 'User Lockout', 'LOW', '192.168.1.102', '192.168.1.10', 389, 'LDAP', 'Closed', NULL);

PRINT '[+] Inserted 15 sample incidents';

-- Sample users/analysts
INSERT INTO Analysts (AnalystID, AnalystName, Email, Department, ActiveIncidents)
VALUES
('analyst01', 'Sarah Chen', 'sarah.chen@company.com', 'SOC Tier 2', 2),
('analyst02', 'Mike Rodriguez', 'mike.rodriguez@company.com', 'SOC Tier 2', 2),
('analyst03', 'Emily Johnson', 'emily.johnson@company.com', 'SOC Tier 1', 2);

PRINT '[+] Inserted 3 sample analysts';

-- Sample attack patterns
INSERT INTO AttackPatterns (PatternID, PatternName, Description, CommonPorts, DetectionRule)
VALUES
(1, 'SSH Brute Force', 'Multiple failed SSH login attempts from single source', '22', 'failed_login_count > 10 AND port = 22'),
(2, 'Port Scanning', 'Sequential connection attempts to multiple ports', 'Various', 'unique_dst_ports > 20 AND connection_duration < 5'),
(3, 'Data Exfiltration', 'Large outbound data transfer to external IP', '443,80,8080', 'bytes_out > 100MB AND dst_ip NOT IN internal_range'),
(4, 'Malware C2 Communication', 'Periodic beaconing to known malicious IP', '443,8443', 'connection_frequency = regular AND dst_ip IN threat_intel'),
(5, 'SQL Injection', 'SQL keywords in HTTP parameters', '80,443,3306', 'http_params CONTAINS (SELECT|UNION|DROP|INSERT)');

PRINT '[+] Inserted 5 attack patterns';

-- Sample threat intelligence
INSERT INTO ThreatIntelligence (IOC, Type, ThreatLevel, Source, FirstSeen, LastSeen, Active)
VALUES
('203.0.113.42', 'IP', 'CRITICAL', 'AbuseIPDB', '2024-01-10', '2024-01-19', 1),
('198.51.100.15', 'IP', 'CRITICAL', 'AlienVault OTX', '2024-01-12', '2024-01-19', 1),
('malware-sample.exe', 'File Hash', 'HIGH', 'VirusTotal', '2024-01-05', '2024-01-19', 1),
('phish-domain.com', 'Domain', 'MEDIUM', 'PhishTank', '2024-01-14', '2024-01-19', 1),
('203.0.113.156', 'IP', 'HIGH', 'SANS ISC', '2024-01-08', '2024-01-19', 1);

PRINT '[+] Inserted 5 threat intelligence records';

-- Sample incident resolution actions
INSERT INTO IncidentActions (ActionID, IncidentID, Timestamp, Action, PerformedBy)
VALUES
(1, 1, '2024-01-15 08:30:00', 'Isolated affected system from network', 'analyst01'),
(2, 1, '2024-01-15 09:15:00', 'Initiated malware scan', 'analyst01'),
(3, 2, '2024-01-15 09:30:00', 'Blocked destination IP in firewall', 'analyst02'),
(4, 3, '2024-01-15 11:00:00', 'Restored from backup', 'analyst01'),
(5, 4, '2024-01-16 02:40:00', 'Blocked source IP', 'analyst03');

PRINT '[+] Inserted 5 incident action records';
PRINT '';

-- =============================================================================
-- VERIFICATION QUERIES
-- =============================================================================

PRINT '[*] Verifying data insertion...';
PRINT '';

PRINT 'Incident Count by Severity:';
SELECT Severity, COUNT(*) as Count
FROM Incidents
GROUP BY Severity
ORDER BY
  CASE Severity
    WHEN 'CRITICAL' THEN 1
    WHEN 'HIGH' THEN 2
    WHEN 'MEDIUM' THEN 3
    WHEN 'LOW' THEN 4
  END;

PRINT '';
PRINT 'Incident Count by Status:';
SELECT Status, COUNT(*) as Count
FROM Incidents
GROUP BY Status
ORDER BY Count DESC;

PRINT '';
PRINT 'Analyst Workload:';
SELECT
  A.AnalystName,
  A.ActiveIncidents,
  COUNT(I.IncidentID) as TotalAssigned
FROM Analysts A
LEFT JOIN Incidents I ON A.AnalystID = I.AssignedAnalyst
GROUP BY A.AnalystName, A.ActiveIncidents
ORDER BY A.ActiveIncidents DESC;

PRINT '';
PRINT '========================================================================';
PRINT 'DEMO SETUP COMPLETE!';
PRINT '========================================================================';
PRINT '';
PRINT 'Next steps:';
PRINT '  1. Run analytics: sqlcmd -i analytics/trend_analysis.sql';
PRINT '  2. Explore the data with your own queries';
PRINT '  3. Add more sample incidents as needed';
PRINT '';
