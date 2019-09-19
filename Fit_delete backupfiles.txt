DECLARE @name VARCHAR(50); -- Database name 
DECLARE @path VARCHAR(256); -- Path for backup files 
DECLARE @path1 VARCHAR(256); -- Path for backup files 
DECLARE @fileName VARCHAR(256); -- Filename for backup 
DECLARE @fileDate VARCHAR(20); -- Used for file name 
DECLARE @DeleteDate DATETIME = DATEADD(DD,-0,GETDATE()); -- Cutoff date
DECLARE @DeleteLog DATETIME = DATEADD(DD,-28,GETDATE()); -- Cutoff date
-- Path to backups. 
SET @path = 'G:\Backup\';
-- Get date to include in file name. 
SELECT @fileDate = CONVERT(VARCHAR(20),GETDATE(),112);
-- Dynamically get each database on the server. 
DECLARE db_cursor CURSOR FOR 
SELECT name 
FROM master.sys.databases
WHERE name NOT IN ('tempdb')

OPEN db_cursor;
FETCH NEXT FROM db_cursor INTO @name;
-- Loop through the list to backup each database.
WHILE @@FETCH_STATUS = 0
BEGIN  
     -- Build the path and file name.
      SET @fileName = @path + @name + '_' + @fileDate + '.BAK';
      -- Backup the database.
      BACKUP DATABASE @name TO DISK = @fileName WITH INIT;
      -- Loop to the next database.
      FETCH NEXT FROM db_cursor INTO @name;
 END  
  -- Purge old backup files older than 1 day from disk.
 EXEC master.sys.xp_delete_file 0,@path,'BAK',@DeleteDate,0;
 --Purge Old log file older than 28 days
 EXECUTE master.dbo.xp_delete_file 1,N'E:\MSSQL11.MSSQLSERVER\MSSQL\Log\',N'txt',@Deletelog,0
 -- Clean up.
 CLOSE db_cursor;
 DEALLOCATE db_cursor;
 GO