/*
Name:       CompleteView 2020 Bulk Volume Threshold Check
Purpose:    Scans all video drives on system looking for any that are exceeding the threshold specified in the CompleteView 2020 Desktop Client GUI
Author:     James Anderson
Date:       04Aug2020
Version:    1.4
Comments:   Added more-detailed in-line notes to describe the functions of the script
Version History:
 -  :    (04Apr2020)  1.0 Initial testing of code and assignment of column names
 -  :    (06Apr2020)  1.1 Added comments in-line with code to explain arithmetic used
 -  :    (08Apr2020)  1.2 Feature to filter both for servers with drives exceeding threshold and drives within 10% of threshold
 -  :    (13Apr2020)  1.3 Fully-qualified table names have been applied to clean up script, e.g. "Server" to "Completeview.dbo.Server"
 -  :    (04Aug2020)  1.4 Notes have been edited to provide greater detail, explaining what we are doing, why, and any considerations
*/
SELECT
-- This SELECT clause establishes and properly names the columns of the data we are gathering
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
/*
((d.TotalSpaceMb - (d.TotalSpaceMb * v.VideoSpace * 0.01))/d.TotalSpaceMb) establishes the threshold space that should be available,
e.g. if a drive is set at 95%, this should return 0.05.

(d.FreeSpaceMb * 1.00) / (d.TotalSpaceMb * 1.00) establishes the actual percentage of free space left; when subtracted from the first
part, it gives us the amount, in decimal form, the threshold has been exceeded by.

We use * 100 to turn the decimal into a percentage.

Finally, the multiplication of d.FreeSpaceMb and d.TotalSpaceMb allows SQL Server to see these values as integers so we can complete
the arithmetic.
*/
FROM Completeview.dbo.Server s
INNER JOIN Completeview.dbo.DiskDrives d ON
s.ServerId=d.ServerId
INNER JOIN Completeview.dbo.Device r ON
d.DeviceRelationId=r.DeviceRelationId
INNER JOIN Completeview.dbo.Volume v ON
s.ServerId=v.ServerId
--
--
--
WHERE r.DeviceName NOT IN ('C:','E:','F:')
--
--
--
/*
When using you will need to identify 1) what server letters are assigned for volume drives and 2) what server letters may exist outside 
of those. When you have all information, you will write the WHERE clause to include all drive letters in servers the client is using that
are NOT holding video.

Every storage drive NOT used for video storage will need to be listed above in parentheses, surrounded by single quotes, and
separated by commas. For example, if out of three servers you use D: as the storage volume, and each server has a C:, E:, and/or F: drive,
by listing NOT IN ('C:','E:','F:') we are able to query only the video drives.
*/
AND d.FreeSpaceMb < (d.TotalSpaceMb - (d.TotalSpaceMb * ((v.VideoSpace - 10) * 0.01)))
-- This AND clause will filter for servers that are within 10% of approaching the threshold as well as those exceeding the threshold
ORDER BY 'Percent to Meeting Threshold (%)'
-- The final piece here, the ORDER BY clause, ensures that the data is automatically organized during the query based on volume storage