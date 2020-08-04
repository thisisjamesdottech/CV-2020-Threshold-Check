# CV-2020-Threshold-Check
 This SQL script will scan all video drives in a Salient CompleteView 2020 setup, looking for any that are exceeding the volume threshold specified in the Desktop Client GUI.

 The use case for this came about when a client had a large enterprise setup, spanning a large chunk of the southern U.S. While CompleteView 2020 does natively offer email alerts, due to network connectivity for some of the client's sites there was concern that they may not initiate correctly/emails be received.

 To abate this, SQL was leveraged so a representative of the client could pull up-to-date threshold data from the Microsoft SQL Server database within seconds; to further enhance this script, I wrote it to not simply identify video storage volumes that exceeded their threshold, but also those that were approaching it.

Instructions:

1. This works specifically with Microsoft SQL Server and the CompleteView database structure as it pertains to the use of Microsoft SQL Server; if you are using SQLite, this will not apply/work.

2. Ensure you are logged onto the server that is hosting the SQL Server database.

3. Note where you have saved the threshold_check.sql query file.

4. Open SQL Server Management Studio and log in as admin.

5. Across the menu go to Tools > Options, expand the Query Results tree, expand the SQL Server tree, select Results to Grid, and ensure "Include column headers when copying or saving the results" is checked.

NOTE: If it was not already checked, you must restart SQL Server Management Studio for the change to take effect.

6. Across the menu go to File > Open, choose File..., and via File Explorer go to the location from item 3 above.

7. Select and open threshold_check.sql

8. Locate near the bottom the WHERE clause in between three rows of -- top and bottom that looks like this:

WHERE r.DeviceName NOT IN ('C:','E:','F:')

9. Change the values inside the parentheses to equal all drives NOT associated with video storage that exist on the server(s) you will be checking. For example, if you have three servers in your CompleteView environment and, out of those three servers you use D: as the storage volume, and each server has a C:, E:, and/or F: drive,
by listing NOT IN ('C:','E:','F:') we are able to query only the video drives.

10. When ready, click Execute (or press F5) to run the query.

11. When it is finished, go to the Results in the pane below the query code.

12. Here, we will left-click the top-left corner to highlight all columns and rows.

13. Next, right-click over the data and choose Save Results As..., defining the file name and destination

14. Navigate to the destination from item 13 above, open your file, and analyze/edit as you desire.

15. If you wish to add colors, trend lines, graphs, etc., remember to save as a .xlsx file first!