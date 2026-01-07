-- =====================================================
-- Security Incident Trend Analysis Queries
-- Author: Kamil Nazaruk
-- Description: Complex analytical queries for trend identification
-- =====================================================

USE SecurityIncidents;
GO

-- =====================================================
-- 1. Monthly Incident Trends with Year-over-Year Comparison
-- =====================================================
WITH MonthlyStats AS (
    SELECT
        YEAR(IncidentDate) AS Year,
        MONTH(IncidentDate) AS Month,
        COUNT(*) AS IncidentCount,
        AVG(DATEDIFF(hour, IncidentDate, ISNULL(ResolutionDate, GETDATE()))) AS AvgResolutionHours,
        SUM(CASE WHEN Severity = 'Critical' THEN 1 ELSE 0 END) AS CriticalCount,
        SUM(CASE WHEN Severity = 'High' THEN 1 ELSE 0 END) AS HighCount
    FROM Incidents
    GROUP BY YEAR(IncidentDate), MONTH(IncidentDate)
)
SELECT
    Year,
    Month,
    IncidentCount,
    ROUND(AvgResolutionHours, 2) AS AvgResolutionHours,
    CriticalCount,
    HighCount,
    IncidentCount - LAG(IncidentCount) OVER (ORDER BY Year, Month) AS MoMChange,
    CAST(100.0 * (IncidentCount - LAG(IncidentCount) OVER (ORDER BY Year, Month)) /
         NULLIF(LAG(IncidentCount) OVER (ORDER BY Year, Month), 0) AS DECIMAL(5,2)) AS MoMChangePercent,
    LAG(IncidentCount, 12) OVER (ORDER BY Year, Month) AS PriorYearSameMonth,
    CAST(100.0 * (IncidentCount - LAG(IncidentCount, 12) OVER (ORDER BY Year, Month)) /
         NULLIF(LAG(IncidentCount, 12) OVER (ORDER BY Year, Month), 0) AS DECIMAL(5,2)) AS YoYChangePercent
FROM MonthlyStats
ORDER BY Year DESC, Month DESC;

-- =====================================================
-- 2. Facility Performance Scorecard
-- =====================================================
SELECT
    f.FacilityName,
    COUNT(i.IncidentID) AS TotalIncidents,
    SUM(CASE WHEN i.Status = 'Closed' THEN 1 ELSE 0 END) AS ClosedIncidents,
    CAST(100.0 * SUM(CASE WHEN i.Status = 'Closed' THEN 1 ELSE 0 END) /
         NULLIF(COUNT(i.IncidentID), 0) AS DECIMAL(5,2)) AS ClosureRate,
    AVG(CASE
        WHEN i.Status = 'Closed' THEN DATEDIFF(hour, i.IncidentDate, i.ResolutionDate)
        ELSE NULL
    END) AS AvgResolutionHours,
    SUM(CASE WHEN i.Severity = 'Critical' THEN 1 ELSE 0 END) AS CriticalIncidents,
    SUM(ISNULL(i.ActualCost, 0)) AS TotalCost,
    RANK() OVER (ORDER BY COUNT(i.IncidentID) DESC) AS IncidentRank,
    RANK() OVER (ORDER BY AVG(CASE WHEN i.Status = 'Closed' THEN
                 DATEDIFF(hour, i.IncidentDate, i.ResolutionDate) ELSE NULL END)) AS PerformanceRank
FROM Facilities f
LEFT JOIN Incidents i ON f.FacilityID = i.FacilityID
WHERE f.IsActive = 1
GROUP BY f.FacilityID, f.FacilityName
ORDER BY TotalIncidents DESC;

-- =====================================================
-- 3. Category Analysis - Top Problem Areas
-- =====================================================
SELECT
    c.CategoryName,
    COUNT(i.IncidentID) AS IncidentCount,
    CAST(100.0 * COUNT(i.IncidentID) / SUM(COUNT(i.IncidentID)) OVER () AS DECIMAL(5,2)) AS PercentOfTotal,
    SUM(COUNT(i.IncidentID)) OVER (ORDER BY COUNT(i.IncidentID) DESC) AS RunningTotal,
    CAST(100.0 * SUM(COUNT(i.IncidentID)) OVER (ORDER BY COUNT(i.IncidentID) DESC) /
         SUM(COUNT(i.IncidentID)) OVER () AS DECIMAL(5,2)) AS CumulativePercent,
    AVG(CASE WHEN i.Status = 'Closed' THEN
        DATEDIFF(hour, i.IncidentDate, i.ResolutionDate) ELSE NULL END) AS AvgResolutionHours,
    SUM(ISNULL(i.ActualCost, 0)) AS TotalCost
FROM Categories c
INNER JOIN Incidents i ON c.CategoryID = i.CategoryID
WHERE c.IsActive = 1
GROUP BY c.CategoryID, c.CategoryName
ORDER BY IncidentCount DESC;

-- =====================================================
-- 4. Severity Distribution Over Time
-- =====================================================
SELECT
    YEAR(IncidentDate) AS Year,
    MONTH(IncidentDate) AS Month,
    Severity,
    COUNT(*) AS Count,
    CAST(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (PARTITION BY YEAR(IncidentDate), MONTH(IncidentDate))
         AS DECIMAL(5,2)) AS PercentOfMonth
FROM Incidents
GROUP BY YEAR(IncidentDate), MONTH(IncidentDate), Severity
ORDER BY Year DESC, Month DESC, Severity;

-- =====================================================
-- 5. Peak Incident Times Analysis
-- =====================================================
SELECT
    DATEPART(HOUR, IncidentDate) AS HourOfDay,
    DATENAME(WEEKDAY, IncidentDate) AS DayOfWeek,
    COUNT(*) AS IncidentCount,
    AVG(CASE WHEN Status = 'Closed' THEN
        DATEDIFF(hour, IncidentDate, ResolutionDate) ELSE NULL END) AS AvgResolutionHours
FROM Incidents
GROUP BY DATEPART(HOUR, IncidentDate), DATENAME(WEEKDAY, IncidentDate)
ORDER BY IncidentCount DESC;

-- =====================================================
-- 6. Resolution Time Analysis by Category and Severity
-- =====================================================
SELECT
    c.CategoryName,
    i.Severity,
    COUNT(*) AS IncidentCount,
    MIN(DATEDIFF(hour, i.IncidentDate, i.ResolutionDate)) AS MinResolutionHours,
    AVG(DATEDIFF(hour, i.IncidentDate, i.ResolutionDate)) AS AvgResolutionHours,
    MAX(DATEDIFF(hour, i.IncidentDate, i.ResolutionDate)) AS MaxResolutionHours,
    STDEV(DATEDIFF(hour, i.IncidentDate, i.ResolutionDate)) AS StdDevResolutionHours
FROM Incidents i
INNER JOIN Categories c ON i.CategoryID = c.CategoryID
WHERE i.Status = 'Closed'
    AND i.ResolutionDate IS NOT NULL
GROUP BY c.CategoryName, i.Severity
ORDER BY AvgResolutionHours DESC;

-- =====================================================
-- 7. Cost Analysis - High Impact Incidents
-- =====================================================
SELECT
    TOP 20
    i.IncidentID,
    f.FacilityName,
    c.CategoryName,
    i.Severity,
    i.IncidentDate,
    i.Title,
    i.ActualCost,
    DATEDIFF(hour, i.IncidentDate, ISNULL(i.ResolutionDate, GETDATE())) AS HoursToResolve,
    ISNULL(i.ActualCost, 0) / NULLIF(DATEDIFF(hour, i.IncidentDate,
           ISNULL(i.ResolutionDate, GETDATE())), 0) AS CostPerHour
FROM Incidents i
INNER JOIN Facilities f ON i.FacilityID = f.FacilityID
INNER JOIN Categories c ON i.CategoryID = c.CategoryID
WHERE i.ActualCost > 0
ORDER BY i.ActualCost DESC;

-- =====================================================
-- 8. Personnel Performance Metrics
-- =====================================================
SELECT
    p.FirstName + ' ' + p.LastName AS PersonnelName,
    p.Role,
    COUNT(DISTINCT i.IncidentID) AS IncidentsResolved,
    AVG(DATEDIFF(hour, i.IncidentDate, i.ResolutionDate)) AS AvgResolutionTime,
    SUM(CASE WHEN DATEDIFF(hour, i.IncidentDate, i.ResolutionDate) <= 24 THEN 1 ELSE 0 END) AS Resolved24Hours,
    CAST(100.0 * SUM(CASE WHEN DATEDIFF(hour, i.IncidentDate, i.ResolutionDate) <= 24 THEN 1 ELSE 0 END) /
         NULLIF(COUNT(DISTINCT i.IncidentID), 0) AS DECIMAL(5,2)) AS PercentResolved24Hours
FROM Personnel p
INNER JOIN Incidents i ON p.PersonnelID = i.ResolvedBy
WHERE i.Status = 'Closed'
    AND i.ResolutionDate IS NOT NULL
GROUP BY p.PersonnelID, p.FirstName, p.LastName, p.Role
HAVING COUNT(DISTINCT i.IncidentID) >= 5
ORDER BY AvgResolutionTime;

GO

PRINT 'Trend analysis queries ready to execute!';
