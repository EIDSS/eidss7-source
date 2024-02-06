-- Add computed column nodeLevel to the table gisLocation and breadth-first index for the table
declare @cmd nvarchar(max)

declare @tablename sysname = N'gisLocation'
declare @Nodecolumnname sysname = N'node'
declare @NodeLevelcolumnname sysname = N'nodeLevel'

declare	@table_id bigint


set @table_id = object_id(@tablename, N'U')

if	@table_id is not null
	and exists
		(	select	1
			from	sys.columns c
			where	c.[object_id] = @table_id
					and c.[name] = @Nodecolumnname collate Cyrillic_General_CI_AS
		)
	and not exists
		(	select	1
			from	sys.computed_columns cc
			where	cc.[object_id] = @table_id
					and cc.[name] = @NodeLevelcolumnname collate Cyrillic_General_CI_AS
		)
begin

	set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''SET ANSI_NULLS ON''
exec [' + db_name() + N'].sys.sp_executesql @cmd

set @cmd = N''SET QUOTED_IDENTIFIER ON''
exec [' + db_name() + N'].sys.sp_executesql @cmd


set @cmd = N''
ALTER TABLE [dbo].[' + @tablename + N']
	ADD [' + @NodeLevelcolumnname + N']  AS ([' + @Nodecolumnname + N'].[GetLevel]())

EXEC [' + db_name() + N'].sys.sp_addextendedproperty @name=N''''MS_Description'''', @value=N''''Level of the hierarchical location node'''' , @level0type=N''''SCHEMA'''',@level0name=N''''dbo'''', @level1type=N''''TABLE'''',@level1name=N''''' + @tablename + N''''', @level2type=N''''COLUMN'''',@level2name=N''''' + @NodeLevelcolumnname + N'''''
''
exec [' + db_name() + N'].sys.sp_executesql @cmd

' collate Cyrillic_General_CI_AS
	exec sys.sp_executesql @cmd
end

if	@table_id is not null
	and not exists
		(	select	1
			from	sys.indexes i
			where	i.[object_id] = @table_id
					and i.[name] = N'IX_' + @tablename + N'_Breadth_First' collate Cyrillic_General_CI_AS

		)
begin
	set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
CREATE NONCLUSTERED INDEX IX_' + @tablename + N'_Breadth_First   
    ON ' + @tablename + N'([' + @NodeLevelcolumnname + N'],[' + @Nodecolumnname + N']) ;  
''
exec [' + db_name() + N'].sys.sp_executesql @cmd

' collate Cyrillic_General_CI_AS
	exec sys.sp_executesql @cmd
end

-- Add computed columns nodeLevel to the table gisLocationDenormalized and breadth-first index for the table

set @tablename = N'gisLocationDenormalized'
set @Nodecolumnname = N'Node'
set @NodeLevelcolumnname = N'NodeLevel'

set @table_id = object_id(@tablename, N'U')

if	@table_id is not null
	and exists
		(	select	1
			from	sys.columns c
			where	c.[object_id] = @table_id
					and c.[name] = @Nodecolumnname collate Cyrillic_General_CI_AS
		)
	and not exists
		(	select	1
			from	sys.computed_columns cc
			where	cc.[object_id] = @table_id
					and cc.[name] = @NodeLevelcolumnname collate Cyrillic_General_CI_AS
		)
begin

	set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''SET ANSI_NULLS ON''
exec [' + db_name() + N'].sys.sp_executesql @cmd

set @cmd = N''SET QUOTED_IDENTIFIER ON''
exec [' + db_name() + N'].sys.sp_executesql @cmd


set @cmd = N''
ALTER TABLE [dbo].[' + @tablename + N']
	ADD [' + @NodeLevelcolumnname + N']  AS ([' + @Nodecolumnname + N'].[GetLevel]())

EXEC [' + db_name() + N'].sys.sp_addextendedproperty @name=N''''MS_Description'''', @value=N''''Level of the hierarchical location node'''' , @level0type=N''''SCHEMA'''',@level0name=N''''dbo'''', @level1type=N''''TABLE'''',@level1name=N''''' + @tablename + N''''', @level2type=N''''COLUMN'''',@level2name=N''''' + @NodeLevelcolumnname + N'''''
''
exec [' + db_name() + N'].sys.sp_executesql @cmd

' collate Cyrillic_General_CI_AS
	exec sys.sp_executesql @cmd
end


if	@table_id is not null
	and not exists
		(	select	1
			from	sys.indexes i
			where	i.[object_id] = @table_id
					and i.[name] = N'IX_' + @tablename + N'_Breadth_First' collate Cyrillic_General_CI_AS

		)
begin
	set @cmd = N'
declare @cmd nvarchar(max)
set @cmd = N''
CREATE NONCLUSTERED INDEX IX_' + @tablename + N'_Breadth_First   
    ON ' + @tablename + N'([' + @NodeLevelcolumnname + N'],[' + @Nodecolumnname + N']) ;  
''
exec [' + db_name() + N'].sys.sp_executesql @cmd

' collate Cyrillic_General_CI_AS
	exec sys.sp_executesql @cmd
end

 
  
  