CREATE PROC dbo.usp_SearchFK 
  @table VARCHAR(256) -- use two part name convention
, @lvl INT=0 -- do not change
, @ParentTable VARCHAR(256)='' -- do not change
, @debug BIT = 1
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @dbg BIT;
	SET @dbg=@debug;
	IF OBJECT_ID('tempdb..#tbl', 'U') IS NULL
		CREATE TABLE  #tbl  (id INT IDENTITY, tablename VARCHAR(256), lvl INT, ParentTable VARCHAR(256));
	declare @curS cursor;
	if @lvl = 0
		insert into #tbl (tablename, lvl, ParentTable)
		select @table, @lvl, Null;
	else
		insert into #tbl (tablename, lvl, ParentTable)
		select @table, @lvl,@ParentTable;
	if @dbg=1	
		print replicate('----', @lvl) + 'lvl ' + cast(@lvl as varchar(10)) + ' = ' + @table;
	
	if not exists (select * from sys.foreign_keys where referenced_object_id = object_id(@table))
		return;
	else
	begin -- else
		set @ParentTable = @table;
		set @curS = cursor for
		select tablename=object_schema_name(parent_object_id)+'.'+object_name(parent_object_id)
		from sys.foreign_keys 
		where referenced_object_id = object_id(@table)
		and parent_object_id <> referenced_object_id; -- add this to prevent self-referencing which can create a indefinitive loop;

		open @curS;
		fetch next from @curS into @table;

		while @@fetch_status = 0
		begin --while
			set @lvl = @lvl+1;
			-- recursive call
			exec dbo.usp_SearchFK @table, @lvl, @ParentTable, @dbg;
			set @lvl = @lvl-1;
			fetch next from @curS into @table;
		end --while
		close @curS;
		deallocate @curS;
	end -- else
	if @lvl = 0
		select * from #tbl;
	return;
end