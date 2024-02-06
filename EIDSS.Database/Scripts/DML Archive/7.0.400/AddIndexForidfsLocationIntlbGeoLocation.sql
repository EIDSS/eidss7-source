-- Add index for the column idfsLocation in the table tlbGeoLocation
declare @cmd nvarchar(max)

declare @tablename sysname = N'tlbGeoLocation'
declare @columnname sysname = N'idfsLocation'

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
CREATE NONCLUSTERED INDEX IX_' + @tablename + N'_' + @columnname + N'   
    ON ' + @tablename + N'([' + @columnname + N'] ASC)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY];  
''
exec [' + db_name() + N'].sys.sp_executesql @cmd

' collate Cyrillic_General_CI_AS
	exec sys.sp_executesql @cmd
end



