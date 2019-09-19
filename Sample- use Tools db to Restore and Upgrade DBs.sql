use master
/*  -- Extracts RESTORE AND UPGRADE

-- this runs for 4 minutes

1- Restore DB
2 - Set Options
3 - Compress tables
4 - Compress and re-index table indexes
5 - Update statistics
6 - Shrink database
7 - Truncate Log file */

Declare
 @FromBackupPath nvarchar(800)
,@FromBackupFileNm nvarchar(200)
,@ToData nvarchar(1000)
,@ToLog nvarchar(1000)
,@DBFileNm nvarchar(1000)
,@LogFileNm nvarchar(1000)
,@DBName nvarchar(1000)
,@Owner nvarchar(100)
,@SQL nvarchar(2000)
---------------------------------------------------------------------------------------------------------------
-- PLEASE EDIT THESE SETTINGS
Set @FromBackupPath = N'\\hbg-nas-01\wic-iand\_sqlbackups\vmReportingServ\'
Set @FromBackupFileNm = N'DOH_WICNet_Extracts_db_201010062352.BAK' 
Set @ToData =  N'D:\_Database\WICnet_UAT\DOH_WICnet_Extracts_DATA.mdf'
Set @ToLog = N'D:\_Logs\WICnet_UAT\DOH_WICnet_Extracts_LOG.ldf'
---------------------------------------------------------------------------------------------------------------
Set @Owner = N'SA'

---------------------------------------------------------------------------------------------------------------
-- DO NOT EDIT THESE SETTINGS
Set @DBFileNm = N'IDPH_Extracts_Data'
Set @LogFileNm = N'IDPH_Extracts_log'
Set @DBName = N'DOH_WICnet_Extracts'
---------------------------------------------------------------------------------------------------------------


EXEC DOH_WICnet_TOOLS.dbo.USP_RestoreDB 
@FromBackupPath
,@FromBackupFileNm 
,@ToData
,@ToLog 
,@DBFileNm 
,@LogFileNm 
,@DBName 



EXEC DOH_WICnet_TOOLS.DBO.USP_SetDBOptions
@DBFileNm 
,@LogFileNm
,@DBName 
,@Owner
-----------------------------------


Set @SQL = 'Use '+ @DBName + char(13)
 + 'EXEC dbo.sp_changedbowner @loginame = ''' + @OWNER + ''', @map = false'
print @SQL
Execute (@SQL)


Set @SQL = 'USE ' + @DBName + CHAR(13)


-- Table Compression
set @SQL = @SQL + 

'
EXEC dbo.sp_msForEachTable ''ALTER TABLE ? REBUILD PARTITION = ALL WITH (DATA_COMPRESSION = PAGE)'', @command2=''PRINT CONVERT(VARCHAR, GETDATE(), 9) + '''' - ? Table compressed'''''''

--Index compression and rebuild
set @SQL = @SQL + 
'
EXEC dbo.sp_msForEachTable ''alter INDEX ALL on ? REBUILD PARTITION = ALL WITH (DATA_COMPRESSION = PAGE)'', @command2=''PRINT CONVERT(VARCHAR, GETDATE(), 9) + '''' - ? Indexes compressed'''''''

-- Update the statistics for every table in the database
set @SQL = @SQL + 
'
EXEC dbo.sp_msForEachTable ''UPDATE STATISTICS ? WITH SAMPLE 10 PERCENT'', @command2=''PRINT CONVERT(VARCHAR, GETDATE(), 9) + '''' - ? Stats Updated'''''''

Set @SQL = @SQL + 
'
DBCC SHRINKFILE (' + @DBFileNm + ', 120)'
 
Set @SQL = @SQL + 
'
DBCC SHRINKFILE (' + @LogfileNm + ', 2)'

-- Check the database for any errors.
Set @SQL = @SQL + 
'
DBCC CHECKDB('  + @DBName + ') WITH ALL_ERRORMSGS'

print @SQL 
Execute (@SQL)

GO
