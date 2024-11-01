-- Script rebuilds or reorganizes all database indexes and updates statistics.
-- Execute this script on correct database.
SET NOCOUNT ON;
DECLARE @objectid int;
DECLARE @indexid int;
DECLARE @partitioncount bigint;
DECLARE @schemaname sysname;
DECLARE @objectname sysname;
DECLARE @indexname sysname;
DECLARE @partitionnum bigint;
DECLARE @partitions bigint;
DECLARE @frag float;
DECLARE @command varchar(8000);
-- ensure the temporary table does not exist
IF EXISTS (SELECT name FROM sys.objects WHERE name = 'work_to_do')
    DROP TABLE dbo.work_to_do;
-- conditionally select from the function, converting object and index IDs to names.
SELECT
    object_id AS objectid,
    index_id AS indexid,
    partition_number AS partitionnum,
    avg_fragmentation_in_percent AS frag
INTO dbo.work_to_do
FROM sys.dm_db_index_physical_stats (DB_ID(), NULL, NULL , NULL, 'LIMITED')
WHERE avg_fragmentation_in_percent > 10.0 AND index_id > 0;
-- Declare the cursor for the list of partitions to be processed.
DECLARE partitions CURSOR FOR SELECT * FROM dbo.work_to_do;

-- Open the cursor.
OPEN partitions;

-- Loop through the partitions.
FETCH NEXT
   FROM partitions
   INTO @objectid, @indexid, @partitionnum, @frag;

WHILE @@FETCH_STATUS = 0
    BEGIN;
        SELECT @objectname = o.name, @schemaname = s.name
        FROM sys.objects AS o
        JOIN sys.schemas as s ON s.[schema_id] = o.[schema_id]
        WHERE o.[object_id] = @objectid;

        SELECT @indexname = name 
        FROM sys.indexes
        WHERE  [object_id] = @objectid AND index_id = @indexid;

        SELECT @partitioncount = count (*) 
        FROM sys.partitions
        WHERE [object_id] = @objectid AND index_id = @indexid;

-- 30 is an arbitrary decision point at which to switch between reorganizing and rebuilding
IF @frag < 30.0 and @indexname not like '%geomShape%'
    BEGIN;
    SELECT @command = '
SET QUOTED_IDENTIFIER ON;
ALTER INDEX [' + @indexname + '] ON ' + @schemaname + '.' + @objectname + ' REORGANIZE';
    IF @partitioncount > 1
        SELECT @command = @command + ' PARTITION=' + CONVERT (CHAR, @partitionnum);
	--PRINT @command
    EXEC (@command);
    END;

IF @frag >= 30.0 and @indexname not like '%geomShape%'
    BEGIN;
    SELECT @command = '
SET QUOTED_IDENTIFIER ON;
ALTER INDEX [' + @indexname +'] ON ' + @schemaname + '.' + @objectname + ' REBUILD';
    IF @partitioncount > 1
        SELECT @command = @command + ' PARTITION=' + CONVERT (CHAR, @partitionnum);
	--PRINT @command
    EXEC (@command);
    END;
--PRINT 'Executed ' + @command;

FETCH NEXT FROM partitions INTO @objectid, @indexid, @partitionnum, @frag;
END;
-- Close and deallocate the cursor.
CLOSE partitions;
DEALLOCATE partitions;

-- drop the temporary table
IF EXISTS (SELECT name FROM sys.objects WHERE name = 'work_to_do')
    DROP TABLE dbo.work_to_do;
GO

exec sp_updatestats
--GO

--declare	@cmd	nvarchar(MAX)
--set	@cmd = N'DBCC SHRINKDATABASE(N''' + db_name() + N''')'

--exec sp_executesql @cmd

--GO