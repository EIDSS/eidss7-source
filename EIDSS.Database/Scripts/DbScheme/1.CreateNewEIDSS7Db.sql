SET XACT_ABORT ON 
SET NOCOUNT ON 

/*Specify or update name of the EIDSSv7 database here
  Note: (1) Database will be created if and only if database name is not in use.
		(2) Script is not applicable for cloud-hosted databases.
		(3) Stored Procedure sp_executesql shall be enabled for the instance of SQL Server, where database shall be created.
*/
declare @DbName sysname = N'EIDSS7'

declare	@Error	int
set	@Error = 0

declare	@ErrorMsg	nvarchar(MAX)
set	@ErrorMsg = N''

declare	@HandleError bit = 0


begin try
set @HandleError = 1
if @DbName is null or @DbName = N''
	print	N'Database name cannot be empty. Please specify not empty name and execute the script again.'
if exists (select 1 from [master].sys.databases d where d.[name] = @DbName)
begin
	set @HandleError = 0
	declare @errDbExists nvarchar(2000)
	set @errDbExists = 'Database with name [' + isnull(@DbName, N'') + N'] exists. Please specify different name or delete the database, and then execute the script again.'
	raiserror(@errDbExists, 16, 1)
end
else begin
declare @cmd nvarchar(max) = N''
declare @DbNameNoSpecialCharacters sysname = replace(translate(@DbName, N'!@#$%^&*()-+=~`[]\{}|;:''",.<>/? ', N'################################'), N'#', N'')

declare	@InstanceDefaultDataPath nvarchar(4000)
declare	@InstanceDefaultLogPath nvarchar(4000)
select 
    @InstanceDefaultDataPath = cast(serverproperty('InstanceDefaultDataPath') as nvarchar(4000)),
    @InstanceDefaultLogPath = cast(serverproperty('InstanceDefaultLogPath') as nvarchar(4000))

set @cmd = N'
declare @cmd nvarchar(max) = N''''
set @cmd = N''

CREATE DATABASE [' + @DbName + N']
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N''''EIDSS7_vesion7'''', FILENAME = N''''' + replace(@InstanceDefaultDataPath + N'\', N'\\', N'\') + @DbNameNoSpecialCharacters + N'.mdf'''' , SIZE = 359648KB , MAXSIZE = UNLIMITED, FILEGROWTH = 8192MB)
LOG ON
( NAME = N''''EIDSS7_version7_log'''', FILENAME = N''''' + replace(@InstanceDefaultLogPath + N'\', N'\\', N'\') + @DbNameNoSpecialCharacters + N'_LOG.ldf'''' , SIZE = 6758904KB , MAXSIZE = UNLIMITED, FILEGROWTH = 8192MB)
 COLLATE Cyrillic_General_CI_AS
'' exec [master].sys.sp_executesql @cmd set @cmd = N''
   
IF (FULLTEXTSERVICEPROPERTY(''''IsFullTextInstalled'''') = 1)
begin
	EXEC [' + @DbName + N'].[dbo].[sp_fulltext_database] @action = ''''enabled''''
end
'' exec [' + @DbName + N'].sys.sp_executesql @cmd set @cmd = N''
    
ALTER DATABASE [' + @DbName + N'] SET ANSI_NULL_DEFAULT OFF 
'' exec [' + @DbName + N'].sys.sp_executesql @cmd set @cmd = N''
  
ALTER DATABASE [' + @DbName + N'] SET ANSI_NULLS OFF 
'' exec [' + @DbName + N'].sys.sp_executesql @cmd set @cmd = N''
  
ALTER DATABASE [' + @DbName + N'] SET ANSI_PADDING OFF 
'' exec [' + @DbName + N'].sys.sp_executesql @cmd set @cmd = N''
    
ALTER DATABASE [' + @DbName + N'] SET ANSI_WARNINGS OFF 
'' exec [' + @DbName + N'].sys.sp_executesql @cmd set @cmd = N''
   
ALTER DATABASE [' + @DbName + N'] SET ARITHABORT OFF 
'' exec [' + @DbName + N'].sys.sp_executesql @cmd set @cmd = N''
  
ALTER DATABASE [' + @DbName + N'] SET AUTO_CLOSE OFF 
'' exec [' + @DbName + N'].sys.sp_executesql @cmd set @cmd = N''
  
ALTER DATABASE [' + @DbName + N'] SET AUTO_SHRINK OFF 
'' exec [' + @DbName + N'].sys.sp_executesql @cmd set @cmd = N''
 
ALTER DATABASE [' + @DbName + N'] SET AUTO_UPDATE_STATISTICS ON 
'' exec [' + @DbName + N'].sys.sp_executesql @cmd set @cmd = N''
  
ALTER DATABASE [' + @DbName + N'] SET CURSOR_CLOSE_ON_COMMIT OFF 
'' exec [' + @DbName + N'].sys.sp_executesql @cmd set @cmd = N''
 
ALTER DATABASE [' + @DbName + N'] SET CURSOR_DEFAULT GLOBAL 
'' exec [' + @DbName + N'].sys.sp_executesql @cmd set @cmd = N''
  
ALTER DATABASE [' + @DbName + N'] SET CONCAT_NULL_YIELDS_NULL OFF 
'' exec [' + @DbName + N'].sys.sp_executesql @cmd set @cmd = N''
    
ALTER DATABASE [' + @DbName + N'] SET NUMERIC_ROUNDABORT OFF 
'' exec [' + @DbName + N'].sys.sp_executesql @cmd set @cmd = N''
 
ALTER DATABASE [' + @DbName + N'] SET QUOTED_IDENTIFIER OFF 
'' exec [' + @DbName + N'].sys.sp_executesql @cmd set @cmd = N''
  
ALTER DATABASE [' + @DbName + N'] SET RECURSIVE_TRIGGERS OFF 
'' exec [' + @DbName + N'].sys.sp_executesql @cmd set @cmd = N''
 
ALTER DATABASE [' + @DbName + N'] SET DISABLE_BROKER 
'' exec [' + @DbName + N'].sys.sp_executesql @cmd set @cmd = N''
  
ALTER DATABASE [' + @DbName + N'] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
'' exec [' + @DbName + N'].sys.sp_executesql @cmd set @cmd = N''
  
ALTER DATABASE [' + @DbName + N'] SET DATE_CORRELATION_OPTIMIZATION OFF 
'' exec [' + @DbName + N'].sys.sp_executesql @cmd set @cmd = N''
 
ALTER DATABASE [' + @DbName + N'] SET TRUSTWORTHY OFF 
'' exec [' + @DbName + N'].sys.sp_executesql @cmd set @cmd = N''
 
ALTER DATABASE [' + @DbName + N'] SET ALLOW_SNAPSHOT_ISOLATION OFF 
'' exec [' + @DbName + N'].sys.sp_executesql @cmd set @cmd = N''
 
ALTER DATABASE [' + @DbName + N'] SET PARAMETERIZATION SIMPLE 
'' exec [' + @DbName + N'].sys.sp_executesql @cmd set @cmd = N''
'
set @cmd = @cmd + N'
ALTER DATABASE [' + @DbName + N'] SET READ_COMMITTED_SNAPSHOT OFF 
'' exec [' + @DbName + N'].sys.sp_executesql @cmd set @cmd = N''
    
ALTER DATABASE [' + @DbName + N'] SET HONOR_BROKER_PRIORITY OFF 
'' exec [' + @DbName + N'].sys.sp_executesql @cmd set @cmd = N''
  
ALTER DATABASE [' + @DbName + N'] SET RECOVERY FULL 
'' exec [' + @DbName + N'].sys.sp_executesql @cmd set @cmd = N''
   
ALTER DATABASE [' + @DbName + N'] SET MULTI_USER 
'' exec [' + @DbName + N'].sys.sp_executesql @cmd set @cmd = N''
 
ALTER DATABASE [' + @DbName + N'] SET PAGE_VERIFY CHECKSUM 
'' exec [' + @DbName + N'].sys.sp_executesql @cmd set @cmd = N''
   
ALTER DATABASE [' + @DbName + N'] SET DB_CHAINING OFF 
'' exec [' + @DbName + N'].sys.sp_executesql @cmd set @cmd = N''
 
ALTER DATABASE [' + @DbName + N'] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
'' exec [' + @DbName + N'].sys.sp_executesql @cmd set @cmd = N''
  
ALTER DATABASE [' + @DbName + N'] SET TARGET_RECOVERY_TIME = 60 SECONDS 
'' exec [' + @DbName + N'].sys.sp_executesql @cmd set @cmd = N''
 
ALTER DATABASE [' + @DbName + N'] SET READ_WRITE 
'' exec [' + @DbName + N'].sys.sp_executesql @cmd
'
exec sp_executesql @cmd

print	N'Database [' + @DbName + N'] created successfully.'
end
end try
begin catch

    set @Error = ERROR_NUMBER()

	if @HandleError = 1
		set	@ErrorMsg = N' ErrorSeverity: ' + CONVERT(NVARCHAR, ERROR_SEVERITY())
			+ N' ErrorState: ' + CONVERT(NVARCHAR, ERROR_STATE())
			+ N' ErrorProcedure: ' + ISNULL(ERROR_PROCEDURE(), N'')
			+ N' ErrorLine: ' +  CONVERT(NVARCHAR, ISNULL(ERROR_LINE(), N''))
			+ N' ErrorMessage: ' + ERROR_MESSAGE();
	else
		set @ErrorMsg = ERROR_MESSAGE();
	
	if	@Error <> 0
	begin
		
		if @HandleError = 1
		begin
			print	N'Some error occurred in the script. Please contact EIDSS7 development team for assistance.'
			print	N''
			raiserror (N'Error %d: %s.', -- Message text.
				   16, -- Severity,
				   1, -- State,
				   @Error,
				   @ErrorMsg) with seterror; -- Second argument.
		end
		else
			raiserror (@ErrorMsg, -- Message text.
				   16, -- Severity,
				   1 -- State
				   ) with seterror; -- Second argument.
	end
end catch;

SET NOCOUNT OFF 
SET XACT_ABORT OFF 
