# SQL Security Incident Database

![SQL](https://img.shields.io/badge/SQL-SQL%20Server%20%7C%20MySQL%20%7C%20PostgreSQL-blue)
![Database](https://img.shields.io/badge/Database-Design-orange)
![Analytics](https://img.shields.io/badge/Analytics-T--SQL-green)
![License](https://img.shields.io/badge/License-MIT-green)

## Overview

SQL Server security incident database with comprehensive schema design, ETL procedures, and advanced analytics queries for security operations centers (SOC). This project demonstrates database design, T-SQL programming, and data analytics skills for cybersecurity incident management.

## Challenge

Design a scalable database system to track, analyze, and report on security incidents across an enterprise environment. Support incident lifecycle management, analyst workload tracking, threat intelligence integration, and trend analysis.

## Solution

Developed a normalized relational database with:
- **Comprehensive Schema**: Incidents, analysts, attack patterns, threat intelligence, actions
- **Advanced Queries**: Trend analysis, MTTD/MTTR calculations, analyst performance metrics
- **ETL Procedures**: Stored procedures for data processing and reporting
- **Sample Data**: Ready-to-use demo dataset with 15+ incidents

## Key Features

- ✅ **Normalized Schema Design**: 5+ tables with proper relationships
- ✅ **Incident Lifecycle Tracking**: From detection to resolution
- ✅ **Analyst Workload Management**: Assignment and performance tracking
- ✅ **Threat Intelligence Integration**: IOC tracking and correlation
- ✅ **Trend Analysis Queries**: Time series, severity distribution, attack patterns
- ✅ **Demo Dataset**: Pre-populated sample incidents for testing

## Technologies Used

- SQL Server / MySQL / PostgreSQL
- T-SQL
- Database design (normalization, indexes, foreign keys)

## Project Structure

```
sql-security-incident-db/
├── schema/
│   └── 02_create_tables.sql       # Database schema definition
├── analytics/
│   └── trend_analysis.sql         # Analytics queries (MTTD, trends, metrics)
├── demo_setup.sql                 # Demo mode - START HERE!
└── README.md
```

## Installation

```bash
git clone https://github.com/KamilNaz/sql-security-incident-db.git
cd sql-security-incident-db
```

**Database Setup (SQL Server):**
```sql
CREATE DATABASE SecurityDB;
GO
USE SecurityDB;
GO
```

**Database Setup (MySQL):**
```sql
CREATE DATABASE SecurityDB;
USE SecurityDB;
```

**Database Setup (PostgreSQL):**
```sql
CREATE DATABASE securitydb;
\c securitydb;
```

## Quick Start

### Run Demo with Sample Data

**SQL Server:**
```bash
sqlcmd -S localhost -d SecurityDB -i demo_setup.sql
```

**MySQL:**
```bash
mysql -u root -p SecurityDB < demo_setup.sql
```

**PostgreSQL:**
```bash
psql -d securitydb -f demo_setup.sql
```

This will:
1. Create all database tables (Incidents, Analysts, AttackPatterns, ThreatIntelligence, IncidentActions)
2. Insert 15 sample security incidents
3. Insert 3 sample analysts
4. Insert 5 attack patterns
5. Insert 5 threat intelligence records
6. Insert 5 incident actions
7. Display verification queries

**Expected output:**
```
========================================================================
SQL SECURITY INCIDENT DATABASE - DEMO SETUP
========================================================================

[*] Creating database schema...
[+] Schema created successfully

[*] Inserting sample security incident data...
[+] Inserted 15 sample incidents
[+] Inserted 3 sample analysts
[+] Inserted 5 attack patterns
[+] Inserted 5 threat intelligence records
[+] Inserted 5 incident action records

[*] Verifying data insertion...

Incident Count by Severity:
Severity    Count
---------   -----
CRITICAL    3
HIGH        2
MEDIUM      5
LOW         5

Incident Count by Status:
Status           Count
-------------    -----
Closed           8
In Progress      3
Investigating    2
Blocked          1
Contained        1

Analyst Workload:
AnalystName         ActiveIncidents  TotalAssigned
-----------------   ---------------  -------------
Sarah Chen          2                4
Mike Rodriguez      2                3
Emily Johnson       2                3

========================================================================
DEMO SETUP COMPLETE!
========================================================================
```

### Run Analytics Queries

After setup, run advanced analytics:

```bash
sqlcmd -S localhost -d SecurityDB -i analytics/trend_analysis.sql
```

This includes:
- Mean Time to Detect (MTTD)
- Mean Time to Respond (MTTR)
- Incident trends by day/hour
- Severity distribution
- Top attacked assets
- Analyst performance metrics

## Database Schema

### Main Tables

**Incidents**
- `IncidentID` (PK)
- `Timestamp`, `IncidentType`, `Severity`
- `SourceIP`, `DestinationIP`, `Port`, `Protocol`
- `Status`, `AssignedAnalyst`

**Analysts**
- `AnalystID` (PK)
- `AnalystName`, `Email`, `Department`
- `ActiveIncidents`

**AttackPatterns**
- `PatternID` (PK)
- `PatternName`, `Description`
- `CommonPorts`, `DetectionRule`

**ThreatIntelligence**
- `IOC` (PK) - Indicator of Compromise
- `Type`, `ThreatLevel`, `Source`
- `FirstSeen`, `LastSeen`, `Active`

**IncidentActions**
- `ActionID` (PK)
- `IncidentID` (FK), `Timestamp`
- `Action`, `PerformedBy`

## Example Queries

### Find Critical Incidents

```sql
SELECT
  IncidentID,
  Timestamp,
  IncidentType,
  SourceIP,
  Status
FROM Incidents
WHERE Severity = 'CRITICAL'
  AND Status != 'Closed'
ORDER BY Timestamp DESC;
```

### Analyst Performance

```sql
SELECT
  A.AnalystName,
  COUNT(I.IncidentID) as TotalIncidents,
  AVG(DATEDIFF(HOUR, I.Timestamp, IA.Timestamp)) as AvgResponseTimeHours
FROM Analysts A
JOIN Incidents I ON A.AnalystID = I.AssignedAnalyst
JOIN IncidentActions IA ON I.IncidentID = IA.IncidentID
GROUP BY A.AnalystName
ORDER BY TotalIncidents DESC;
```

### Incident Trends (Daily)

```sql
SELECT
  CAST(Timestamp AS DATE) as Date,
  COUNT(*) as IncidentCount,
  SUM(CASE WHEN Severity = 'CRITICAL' THEN 1 ELSE 0 END) as CriticalCount
FROM Incidents
WHERE Timestamp >= DATEADD(DAY, -30, GETDATE())
GROUP BY CAST(Timestamp AS DATE)
ORDER BY Date DESC;
```

## Impact & Results

Demo database metrics:

| Metric | Value |
|--------|-------|
| **Total Incidents** | 15 |
| **Critical Severity** | 3 (20%) |
| **Avg Response Time** | ~2.5 hours |
| **Analyst Workload** | 4-5 incidents/analyst |
| **Incident Types** | 8 unique types |

## Roadmap / Planned Features

- [ ] Complete ETL stored procedures
- [ ] Automated incident enrichment
- [ ] Integration with SIEM systems
- [ ] Real-time dashboards (Power BI/Tableau)
- [ ] Machine learning threat scoring
- [ ] Compliance reporting (GDPR, SOC 2)
- [ ] API endpoints for incident management

## Author

**Kamil Nazaruk**
Data Analyst & Database Design Specialist

- 🔗 LinkedIn: [kamil-nazaruk](https://www.linkedin.com/in/kamil-nazaruk-56531736a)
- 🌐 Portfolio: [kamilnaz.github.io](https://kamilnaz.github.io)

## License

MIT License - This project is open source and available for learning, portfolio, and commercial use.

---

**Note:** This is a demonstration project showcasing SQL and database design skills. For production security incident management, consider enterprise SIEM/SOAR platforms with full automation and compliance features.
