/*
Name:       CompleteView 2020 Bulk Volume Threshold Check
Purpose:    Scans all video drives on system looking for any that are exceeding the threshold specified in the CompleteView 2020 Desktop Client GUI
Author:     James Anderson
Date:       13Apr2020
Version:    1.3
Comments:   The clause WHERE r.DeviceName NOT IN ('C:','E:','F:') is unique to EP's environment, and will need to be modified on a per-use basis pending the needs of the environment this script is being run in; see in-line notes below

Version History:
 -  :    (04Apr2020)  1.0 Initial testing of code and assignment of column names
 -  :    (06Apr2020)  1.1 Added comments in-line with code to explain arithmetic used
 -  :    (08Apr2020)  1.2 Feature to filter both for servers with drives exceeding threshold and drives within 10% of threshold
 -  :    (13Apr2020)  1.3 I did not originally use fully-qualified table names, assuming user would perform query directly from database; to clean this up, changed table names from, for example, "Server" to "Completeview.dbo.Server"
*/

SELECT
s.ServerId AS 'Server ID',
s.DisplayName AS 'Server Details',
s.IP AS 'IP Address / Network Name',
v.PathAddress AS 'Volume Path',
d.TotalSpaceMb AS 'Total Space (MB)',
d.FreeSpaceMb AS 'Free Space (MB)',
v.VideoSpace AS 'Volume Threshold (%)',
CASE WHEN ((((d.TotalSpaceMb - (d.TotalSpaceMb * v.VideoSpace * 0.01))/d.TotalSpaceMb)-(d.FreeSpaceMb * 1.00) / (d.TotalSpaceMb * 1.00)) * 100) < 0.00 THEN 'N/A'
ELSE Str((((d.TotalSpaceMb - (d.TotalSpaceMb * v.VideoSpace * 0.01))/d.TotalSpaceMb)-(d.FreeSpaceMb * 1.00) / (d.TotalSpaceMb * 1.00)) * 100,12,2)
END AS 'Threshold Exceeded By (%)',
CASE WHEN ((((d.TotalSpaceMb - (d.TotalSpaceMb * v.VideoSpace * 0.01))/d.TotalSpaceMb)-(d.FreeSpaceMb * 1.00) / (d.TotalSpaceMb * 1.00)) * 100) >= 0.00 THEN 'N/A'
ELSE Str((((d.TotalSpaceMb - (d.TotalSpaceMb * v.VideoSpace * 0.01))/d.TotalSpaceMb)-(d.FreeSpaceMb * 1.00) / (d.TotalSpaceMb * 1.00)) * -100,12,2)
END AS 'Percent to Meeting Threshold (%)',
d.DeviceUpdateTime AS 'Free Space Last Updated'
-- ((d.TotalSpaceMb - (d.TotalSpaceMb * v.VideoSpace * 0.01))/d.TotalSpaceMb) establishes the threshold space that should be available, e.g. if a drive is set at 95%, this should return 0.05
-- (d.FreeSpaceMb * 1.00) / (d.TotalSpaceMb * 1.00) establishes the actual percentage of free space left; when subtracted from the first part, it gives us the amount, in decimal form, the threshold has been exceeded by
-- * 100 turns the decimal into a percentage
-- The multiplication of d.FreeSpaceMb and d.TotalSpaceMb allow SQL Server to see these values as integers so we can complete the arithmetic
FROM Completeview_EP.dbo.Server s
INNER JOIN Completeview_EP.dbo.DiskDrives d ON
s.ServerId=d.ServerId
INNER JOIN Completeview_EP.dbo.Device r ON
d.DeviceRelationId=r.DeviceRelationId
INNER JOIN Completeview_EP.dbo.Volume v ON
s.ServerId=v.ServerId
WHERE r.DeviceName NOT IN ('C:','E:','F:')
-- Removes non-D:\ drives from results as the original client built their environments around a single volume, D:\, on their servers, while also having C:\, E:\, and F:\ drives in some
-- When using you will need to identify 1) what server letters are assigned for volume drives and 2) what server letters may exist outside of those
-- When you have all information, you will write the WHERE clause to include all drive letters in servers the client is using that are NOT holding video
AND d.FreeSpaceMb < (d.TotalSpaceMb - (d.TotalSpaceMb * ((v.VideoSpace - 10) * 0.01)))
-- Filters for servers that are within 10% of approaching the threshold as well as those exceeding the threshold
ORDER BY 'Percent to Meeting Threshold (%)'