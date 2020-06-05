# CV-2020-Threshold-Check
 This SQL script will scan all video drives in a Salient CompleteView 2020 setup, looking for any that are exceeding the volume threshold specified in the Desktop Client GUI.

 The use case for this came about when a client had a large enterprise setup, spanning a large chunk of the southern U.S. While CompleteView 2020 does natively offer email alerts, due to network connectivity for some of the client's sites there was concern that they may not initiate correctly/emails be received.

 To abate this, SQL was leveraged so a representative of the client could pull up-to-date threshold data from the Microsoft SQL Server database within seconds; to further enhance this script, I wrote it to not simply identify video storage volumes that exceeded their threshold, but also those that were approaching it.