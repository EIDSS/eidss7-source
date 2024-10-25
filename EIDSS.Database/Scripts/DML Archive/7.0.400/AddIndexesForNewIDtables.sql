-- Add indexes for the table tstNewID
declare @cmd nvarchar(max)

declare @tablename sysname = N'tstNewID'
declare @columnname sysname = N'NewID'

declare	@table_id bigint


set @table_id = object_id(@tablename, N'U')

if	@table_id is not null
	and not exists
		(	select	1
			from	sys.indexes i
			where	i.[object_id] = @table_id
					and i.[name] = N'IX_' + @tablename + N'_' + @columnname collate Cyrillic_General_CI_AS

		)
begin
	set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
CREATE UNIQUE CLUSTERED INDEX IX_' + @tablename + N'_' + @columnname + N'   
    ON ' + @tablename + N'([' + @columnname + N'] ASC)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY] 
''
exec [' + db_name() + N'].sys.sp_executesql @cmd

' collate Cyrillic_General_CI_AS
print @cmd
	exec sys.sp_executesql @cmd
end


if	@table_id is not null
	and not exists
		(	select	1
			from	sys.indexes i
			where	i.[object_id] = @table_id
					and i.[name] = N'IX_' + @tablename + N'_KeyFields' collate Cyrillic_General_CI_AS

		)
begin
	set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_PADDING ON
CREATE NONCLUSTERED INDEX IX_' + @tablename + N'_KeyFields ON ' + @tablename + N'
(
	[idfTable] ASC,
	[idfKey1] ASC,
	[idfKey2] ASC,
	[strRowGuid] ASC
)
INCLUDE([NewID]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
''
exec [' + db_name() + N'].sys.sp_executesql @cmd

' collate Cyrillic_General_CI_AS
print @cmd
	exec sys.sp_executesql @cmd
end

-- Add indexes for the table tflNewID

set @tablename = N'tflNewID'
set	@columnname = N'NewID'


set @table_id = object_id(@tablename, N'U')

if	@table_id is not null
	and not exists
		(	select	1
			from	sys.indexes i
			where	i.[object_id] = @table_id
					and i.[name] = N'IX_' + @tablename + N'_' + @columnname collate Cyrillic_General_CI_AS

		)
begin
	set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
CREATE UNIQUE CLUSTERED INDEX IX_' + @tablename + N'_' + @columnname + N'   
    ON ' + @tablename + N'([' + @columnname + N'] ASC)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY] 
''
exec [' + db_name() + N'].sys.sp_executesql @cmd

' collate Cyrillic_General_CI_AS
print @cmd
	exec sys.sp_executesql @cmd
end


if	@table_id is not null
	and not exists
		(	select	1
			from	sys.indexes i
			where	i.[object_id] = @table_id
					and i.[name] = N'IX_' + @tablename + N'_KeyFields' collate Cyrillic_General_CI_AS

		)
begin
	set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
SET ANSI_PADDING ON
CREATE NONCLUSTERED INDEX IX_' + @tablename + N'_KeyFields ON ' + @tablename + N'
(
	[strTableName] ASC,
	[idfKey1] ASC,
	[idfKey2] ASC
)
INCLUDE([NewID]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
''
exec [' + db_name() + N'].sys.sp_executesql @cmd

' collate Cyrillic_General_CI_AS
print @cmd
	exec sys.sp_executesql @cmd
end

