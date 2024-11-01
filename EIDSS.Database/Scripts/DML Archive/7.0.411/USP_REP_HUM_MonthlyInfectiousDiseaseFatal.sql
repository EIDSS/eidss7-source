SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



--##SUMMARY Select data for Reportable Infectious Diseases (Monthly Form IV03).
--##REMARKS Author: 
--##REMARKS Create date: 10.01.2011

--##REMARKS UPDATED BY: Vorobiev E. --deleted tlbCase
--##REMARKS Date: 22.04.2013

--##REMARKS Updated 30.05.2013 by Romasheva S.

--##REMARKS Updated 10.12.2023 by Mirnaya O. - retrieve data deom both actual and archive databases if needed; utilize location hierarchy for HDRS; exclude connected HDRs except the final HDRs

--##RETURNS Doesn't use

/*
--Example of a call of procedure:

exec report.USP_REP_HUM_MonthlyInfectiousDiseaseFatal 'en', '1/1/2010', '5/31/2018',  37020000000, 3260000000

exec report.USP_REP_HUM_MonthlyInfectiousDiseaseFatal 'en', '2010-01-01', '2016-02-01'
*/

CREATE OR ALTER  Procedure [Report].[USP_REP_HUM_MonthlyInfectiousDiseaseFatal]
	(
		@LangID		as nvarchar(10), 
		@StartDate	as datetime,	 
		@FinishDate	as datetime,
		@RegionID	as bigint = null,
		@RayonID	as bigint = null,
		@SiteID		as bigint = null,
		@UseArchiveData	AS BIT = 0 --if User selected Use Archive Data then 1
	)
AS	


set nocount on;


-- Field description may be found here
-- "https://repos.btrp.net/BTRP/Project_Documents/08x-Implementation/Customizations/GG/Reports/Specification for report development - Monthly Form 03 Human GG v1.0.doc"
-- by number marked red at screen form prototype 

EXEC dbo.USP_GBL_FIRSTDAY_SET

--Declare variables with dynamic SQL command and names of temporary tables
declare	@cmd nvarchar(max) = N''

declare	@TableSuffix sysname = replace(cast(newid() as nvarchar(36)), N'-', N'')

declare @reportTable sysname = N'##ReportTable_' + @TableSuffix collate Cyrillic_General_CI_AS
declare @reportTableInTempDb sysname = N'tempdb..' + @reportTable collate Cyrillic_General_CI_AS

declare @MonthlyReportDiagnosisTable sysname = N'##MonthlyReportDiagnosisTable_' + @TableSuffix collate Cyrillic_General_CI_AS
declare @MonthlyReportDiagnosisTableInTempDb sysname = N'tempdb..' + @MonthlyReportDiagnosisTable collate Cyrillic_General_CI_AS

declare @MonthlyReportHumanAggregateCase sysname = N'##MonthlyReportHumanAggregateCase_' + @TableSuffix collate Cyrillic_General_CI_AS
declare @MonthlyReportHumanAggregateCaseInTempDb sysname = N'tempdb..' + @MonthlyReportHumanAggregateCase collate Cyrillic_General_CI_AS

declare @MonthlyReportHumanAggregateCaseRow sysname = N'##MonthlyReportHumanAggregateCaseRow_' + @TableSuffix collate Cyrillic_General_CI_AS
declare @MonthlyReportHumanAggregateCaseRowInTempDb sysname = N'tempdb..' + @MonthlyReportHumanAggregateCaseRow collate Cyrillic_General_CI_AS

declare @MonthlyReportAggregateDiagnosisValuesTable sysname = N'##MonthlyReportAggregateDiagnosisValuesTable_' + @TableSuffix collate Cyrillic_General_CI_AS
declare @MonthlyReportAggregateDiagnosisValuesTableInTempDb sysname = N'tempdb..' + @MonthlyReportAggregateDiagnosisValuesTable collate Cyrillic_General_CI_AS

declare @MonthlyReportCaseTable sysname = N'##MonthlyReportCaseTable_' + @TableSuffix collate Cyrillic_General_CI_AS
declare @MonthlyReportCaseTableInTempDb sysname = N'tempdb..' + @MonthlyReportCaseTable collate Cyrillic_General_CI_AS

declare @MonthlyReportCaseDiagnosisLethalCasesValuesTable sysname = N'##MonthlyReportCaseDiagnosisLethalCasesValuesTable_' + @TableSuffix collate Cyrillic_General_CI_AS
declare @MonthlyReportCaseDiagnosisLethalCasesValuesTableInTempDb sysname = N'tempdb..' + @MonthlyReportCaseDiagnosisLethalCasesValuesTable collate Cyrillic_General_CI_AS

declare @MonthlyReportCaseDiagnosis_Age_0_1_TotalValuesTable sysname = N'##MonthlyReportCaseDiagnosis_Age_0_1_TotalValuesTable_' + @TableSuffix collate Cyrillic_General_CI_AS
declare @MonthlyReportCaseDiagnosis_Age_0_1_TotalValuesTableInTempDb sysname = N'tempdb..' + @MonthlyReportCaseDiagnosis_Age_0_1_TotalValuesTable collate Cyrillic_General_CI_AS

declare @MonthlyReportCaseDiagnosis_Age_1_4_TotalValuesTable sysname = N'##MonthlyReportCaseDiagnosis_Age_1_4_TotalValuesTable_' + @TableSuffix collate Cyrillic_General_CI_AS
declare @MonthlyReportCaseDiagnosis_Age_1_4_TotalValuesTableInTempDb sysname = N'tempdb..' + @MonthlyReportCaseDiagnosis_Age_1_4_TotalValuesTable collate Cyrillic_General_CI_AS

declare @MonthlyReportCaseDiagnosis_Age_5_14_TotalValuesTable sysname = N'##MonthlyReportCaseDiagnosis_Age_5_14_TotalValuesTable_' + @TableSuffix collate Cyrillic_General_CI_AS
declare @MonthlyReportCaseDiagnosis_Age_5_14_TotalValuesTableInTempDb sysname = N'tempdb..' + @MonthlyReportCaseDiagnosis_Age_5_14_TotalValuesTable collate Cyrillic_General_CI_AS

declare @MonthlyReportCaseDiagnosis_Age_15_19_TotalValuesTable sysname = N'##MonthlyReportCaseDiagnosis_Age_15_19_TotalValuesTable_' + @TableSuffix collate Cyrillic_General_CI_AS
declare @MonthlyReportCaseDiagnosis_Age_15_19_TotalValuesTableInTempDb sysname = N'tempdb..' + @MonthlyReportCaseDiagnosis_Age_15_19_TotalValuesTable collate Cyrillic_General_CI_AS

declare @MonthlyReportCaseDiagnosis_Age_20_29_TotalValuesTable sysname = N'##MonthlyReportCaseDiagnosis_Age_20_29_TotalValuesTable_' + @TableSuffix collate Cyrillic_General_CI_AS
declare @MonthlyReportCaseDiagnosis_Age_20_29_TotalValuesTableInTempDb sysname = N'tempdb..' + @MonthlyReportCaseDiagnosis_Age_20_29_TotalValuesTable collate Cyrillic_General_CI_AS

declare @MonthlyReportCaseDiagnosis_Age_30_59_TotalValuesTable sysname = N'##MonthlyReportCaseDiagnosis_Age_30_59_TotalValuesTable_' + @TableSuffix collate Cyrillic_General_CI_AS
declare @MonthlyReportCaseDiagnosis_Age_30_59_TotalValuesTableInTempDb sysname = N'tempdb..' + @MonthlyReportCaseDiagnosis_Age_30_59_TotalValuesTable collate Cyrillic_General_CI_AS

declare @MonthlyReportCaseDiagnosis_Age_60_more_TotalValuesTable sysname = N'##MonthlyReportCaseDiagnosis_Age_60_more_TotalValuesTable_' + @TableSuffix collate Cyrillic_General_CI_AS
declare @MonthlyReportCaseDiagnosis_Age_60_more_TotalValuesTableInTempDb sysname = N'tempdb..' + @MonthlyReportCaseDiagnosis_Age_60_more_TotalValuesTable collate Cyrillic_General_CI_AS

declare @MonthlyReportDiagnosisGroupTable sysname = N'##MonthlyReportDiagnosisGroupTable_' + @TableSuffix collate Cyrillic_General_CI_AS
declare @MonthlyReportDiagnosisGroupTableInTempDb sysname = N'tempdb..' + @MonthlyReportDiagnosisGroupTable collate Cyrillic_General_CI_AS


--Declare variables with database names
declare @dbName_Actual sysname
declare	@dbName_Archive sysname
declare @ArchiveSuffix nvarchar(20) = N'_Archive'
declare @ArchiveExists bit = 0

set @dbName_Actual = DB_NAME()

if	@dbName_Actual like N'%' + @ArchiveSuffix collate Cyrillic_General_CI_AS 
	and exists(select 1 from sys.databases d where d.[name] = left(@dbName_Actual, len(@dbName_Actual) - len(@ArchiveSuffix)) collate Cyrillic_General_CI_AS)
begin
	set	@dbName_Archive = @dbName_Actual
	set @dbName_Actual = left(@dbName_Actual, len(@dbName_Actual) - len(@ArchiveSuffix))
	set @ArchiveExists = 1
end

if @UseArchiveData = 1 and @dbName_Archive is null and exists(select 1 from sys.databases d where d.[name] = @dbName_Actual + @ArchiveSuffix collate Cyrillic_General_CI_AS)
begin
	set @dbName_Archive = @dbName_Actual + @ArchiveSuffix collate Cyrillic_General_CI_AS
	set @ArchiveExists = 1
end

--Remove temporary tables

if OBJECT_ID(@reportTableInTempDb) IS NOT NULL
BEGIN
	set @cmd = N'drop table ' + @reportTable collate Cyrillic_General_CI_AS
	exec sp_executesql @cmd
END


if OBJECT_ID(@MonthlyReportDiagnosisTableInTempDb) IS NOT NULL
BEGIN
	set @cmd = N'drop table ' + @MonthlyReportDiagnosisTable collate Cyrillic_General_CI_AS
	exec sp_executesql @cmd
END


if OBJECT_ID(@MonthlyReportHumanAggregateCaseInTempDb) IS NOT NULL
BEGIN
	set @cmd = N'drop table ' + @MonthlyReportHumanAggregateCase collate Cyrillic_General_CI_AS
	exec sp_executesql @cmd
END


if OBJECT_ID(@MonthlyReportHumanAggregateCaseRowInTempDb) IS NOT NULL
BEGIN
	set @cmd = N'drop table ' + @MonthlyReportHumanAggregateCaseRow collate Cyrillic_General_CI_AS
	exec sp_executesql @cmd
END


if OBJECT_ID(@MonthlyReportAggregateDiagnosisValuesTableInTempDb) IS NOT NULL
BEGIN
	set @cmd = N'drop table ' + @MonthlyReportAggregateDiagnosisValuesTable collate Cyrillic_General_CI_AS
	exec sp_executesql @cmd
END


if OBJECT_ID(@MonthlyReportCaseTableInTempDb) IS NOT NULL
BEGIN
	set @cmd = N'drop table ' + @MonthlyReportCaseTable collate Cyrillic_General_CI_AS
	exec sp_executesql @cmd
END


if OBJECT_ID(@MonthlyReportCaseDiagnosisLethalCasesValuesTableInTempDb) IS NOT NULL
BEGIN
	set @cmd = N'drop table ' + @MonthlyReportCaseDiagnosisLethalCasesValuesTable collate Cyrillic_General_CI_AS
	exec sp_executesql @cmd
END


if OBJECT_ID(@MonthlyReportCaseDiagnosis_Age_0_1_TotalValuesTableInTempDb) IS NOT NULL
BEGIN
	set @cmd = N'drop table ' + @MonthlyReportCaseDiagnosis_Age_0_1_TotalValuesTable collate Cyrillic_General_CI_AS
	exec sp_executesql @cmd
END


if OBJECT_ID(@MonthlyReportCaseDiagnosis_Age_1_4_TotalValuesTableInTempDb) IS NOT NULL
BEGIN
	set @cmd = N'drop table ' + @MonthlyReportCaseDiagnosis_Age_1_4_TotalValuesTable collate Cyrillic_General_CI_AS
	exec sp_executesql @cmd
END


if OBJECT_ID(@MonthlyReportCaseDiagnosis_Age_5_14_TotalValuesTableInTempDb) IS NOT NULL
BEGIN
	set @cmd = N'drop table ' + @MonthlyReportCaseDiagnosis_Age_5_14_TotalValuesTable collate Cyrillic_General_CI_AS
	exec sp_executesql @cmd
END


if OBJECT_ID(@MonthlyReportCaseDiagnosis_Age_15_19_TotalValuesTableInTempDb) IS NOT NULL
BEGIN
	set @cmd = N'drop table ' + @MonthlyReportCaseDiagnosis_Age_15_19_TotalValuesTable collate Cyrillic_General_CI_AS
	exec sp_executesql @cmd
END


if OBJECT_ID(@MonthlyReportCaseDiagnosis_Age_20_29_TotalValuesTableInTempDb) IS NOT NULL
BEGIN
	set @cmd = N'drop table ' + @MonthlyReportCaseDiagnosis_Age_20_29_TotalValuesTable collate Cyrillic_General_CI_AS
	exec sp_executesql @cmd
END


if OBJECT_ID(@MonthlyReportCaseDiagnosis_Age_30_59_TotalValuesTableInTempDb) IS NOT NULL
BEGIN
	set @cmd = N'drop table ' + @MonthlyReportCaseDiagnosis_Age_30_59_TotalValuesTable collate Cyrillic_General_CI_AS
	exec sp_executesql @cmd
END


if OBJECT_ID(@MonthlyReportCaseDiagnosis_Age_60_more_TotalValuesTableInTempDb) IS NOT NULL
BEGIN
	set @cmd = N'drop table ' + @MonthlyReportCaseDiagnosis_Age_60_more_TotalValuesTable collate Cyrillic_General_CI_AS
	exec sp_executesql @cmd
END


if OBJECT_ID(@MonthlyReportDiagnosisGroupTableInTempDb) IS NOT NULL
BEGIN
	set @cmd = N'drop table ' + @MonthlyReportDiagnosisGroupTable collate Cyrillic_General_CI_AS
	exec sp_executesql @cmd
END


--Create temporary tables

if OBJECT_ID(@reportTableInTempDb) IS NULL
BEGIN
	set @cmd = N'
create table ' + @reportTable + N'
(	strICD10			NVARCHAR(200) collate database_default NULL,	--6 -- strICD10 should be null!
	intAge_0_1			FLOAT NULL,	--7
	intAge_1_4			FLOAT NULL, --8
	intAge_5_14			FLOAT NULL, --9
	intAge_15_19		FLOAT NULL, --10
	intAge_20_29		FLOAT NULL, --11
	intAge_30_59		FLOAT NULL, --12
	intAge_60_more		FLOAT NULL, --13
	intLethalCases		FLOAT NOT NULL, --14
	strSpecifyDiseases  nvarchar(max) --45
)
' collate Cyrillic_General_CI_AS
	exec sp_executesql @cmd
END

if OBJECT_ID(@reportTableInTempDb) IS NOT NULL
BEGIN
	set @cmd = N'
truncate table ' + @reportTable collate Cyrillic_General_CI_AS
	exec sp_executesql @cmd
end

if OBJECT_ID(@MonthlyReportDiagnosisTableInTempDb) IS NULL
BEGIN
	set @cmd = N'
create table ' + @MonthlyReportDiagnosisTable + N'
(	idfsDiagnosis		BIGINT NOT NULL PRIMARY KEY,
    blnIsAggregate		BIT,
	intAge_0_1			BIGINT NOT NULL,	--7
	intAge_1_4			BIGINT NOT NULL, --8
	intAge_5_14			BIGINT NOT NULL, --9
	intAge_15_19		BIGINT NOT NULL, --10
	intAge_20_29		BIGINT NOT NULL, --11
	intAge_30_59		BIGINT NOT NULL, --12
	intAge_60_more		BIGINT NOT NULL, --13
	intLethalCases		BIGINT NOT NULL --14
)
' collate Cyrillic_General_CI_AS
	exec sp_executesql @cmd
END

if OBJECT_ID(@MonthlyReportDiagnosisTableInTempDb) IS NOT NULL
BEGIN
	set @cmd = N'
truncate table ' + @MonthlyReportDiagnosisTable collate Cyrillic_General_CI_AS
	exec sp_executesql @cmd
end


if OBJECT_ID(@MonthlyReportHumanAggregateCaseInTempDb) IS NULL
BEGIN
	set @cmd = N'
create table ' + @MonthlyReportHumanAggregateCase + N'
(	idfAggrCase	BIGINT NOT NULL PRIMARY KEY,
	idfCaseObservation BIGINT,
	datStartDate DATETIME,
	idfVersion BIGINT
)
' collate Cyrillic_General_CI_AS
	exec sp_executesql @cmd
END

if OBJECT_ID(@MonthlyReportHumanAggregateCaseInTempDb) IS NOT NULL
BEGIN
	set @cmd = N'
truncate table ' + @MonthlyReportHumanAggregateCase collate Cyrillic_General_CI_AS
	exec sp_executesql @cmd
end


if OBJECT_ID(@MonthlyReportHumanAggregateCaseRowInTempDb) IS NULL
BEGIN
	set @cmd = N'
create table ' + @MonthlyReportHumanAggregateCaseRow + N'
(	idfAggrCase	BIGINT NOT NULL,
	idfCaseObservation BIGINT NULL,
	idfRow BIGINT NOT NULL,
	idfsBaseReference BIGINT NOT NULL,
	PRIMARY KEY
	(	idfAggrCase ASC,
		idfRow ASC
	)
)
' collate Cyrillic_General_CI_AS
	exec sp_executesql @cmd
END

if OBJECT_ID(@MonthlyReportHumanAggregateCaseRowInTempDb) IS NOT NULL
BEGIN
	set @cmd = N'
truncate table ' + @MonthlyReportHumanAggregateCaseRow collate Cyrillic_General_CI_AS
	exec sp_executesql @cmd
end


if OBJECT_ID(@MonthlyReportAggregateDiagnosisValuesTableInTempDb) IS NULL
BEGIN
	set @cmd = N'
create table ' + @MonthlyReportAggregateDiagnosisValuesTable + N'
(	idfsBaseReference	BIGINT NOT NULL PRIMARY KEY,
	intAge_0_1			BIGINT NOT NULL, --7
	intAge_1_4			BIGINT NOT NULL, --8
	intAge_5_14			BIGINT NOT NULL, --9
	intAge_15_19		BIGINT NOT NULL, --10
	intAge_20_29		BIGINT NOT NULL, --11
	intAge_30_59		BIGINT NOT NULL, --12
	intAge_60_more		BIGINT NOT NULL, --13
	intLethalCases		BIGINT NOT NULL --14

)
' collate Cyrillic_General_CI_AS
	exec sp_executesql @cmd
END

if OBJECT_ID(@MonthlyReportAggregateDiagnosisValuesTableInTempDb) IS NOT NULL
BEGIN
	set @cmd = N'
truncate table ' + @MonthlyReportAggregateDiagnosisValuesTable collate Cyrillic_General_CI_AS
	exec sp_executesql @cmd
end



if OBJECT_ID(@MonthlyReportCaseTableInTempDb) IS NULL
BEGIN
	set @cmd = N'
create table ' + @MonthlyReportCaseTable + N'
(	idfsDiagnosis		BIGINT NOT NULL,
	idfCase				BIGINT NOT NULL PRIMARY KEY,
	intYear				INT NULL
)
' collate Cyrillic_General_CI_AS
	exec sp_executesql @cmd
END

if OBJECT_ID(@MonthlyReportCaseTableInTempDb) IS NOT NULL
BEGIN
	set @cmd = N'
truncate table ' + @MonthlyReportCaseTable collate Cyrillic_General_CI_AS
	exec sp_executesql @cmd
end



if OBJECT_ID(@MonthlyReportCaseDiagnosisLethalCasesValuesTableInTempDb) IS NULL
BEGIN
	set @cmd = N'
create table ' + @MonthlyReportCaseDiagnosisLethalCasesValuesTable + N'
(	idfsDiagnosis			BIGINT NOT NULL PRIMARY KEY,
	intLethalCases			BIGINT NOT NULL
)
' collate Cyrillic_General_CI_AS
	exec sp_executesql @cmd
END

if OBJECT_ID(@MonthlyReportCaseDiagnosisLethalCasesValuesTableInTempDb) IS NOT NULL
BEGIN
	set @cmd = N'
truncate table ' + @MonthlyReportCaseDiagnosisLethalCasesValuesTable collate Cyrillic_General_CI_AS
	exec sp_executesql @cmd
end



if OBJECT_ID(@MonthlyReportCaseDiagnosis_Age_0_1_TotalValuesTableInTempDb) IS NULL
BEGIN
	set @cmd = N'
create table ' + @MonthlyReportCaseDiagnosis_Age_0_1_TotalValuesTable + N'
(	idfsDiagnosis			BIGINT NOT NULL PRIMARY KEY,
	intAge_0_1				BIGINT NOT NULL
)
' collate Cyrillic_General_CI_AS
	exec sp_executesql @cmd
END

if OBJECT_ID(@MonthlyReportCaseDiagnosis_Age_0_1_TotalValuesTableInTempDb) IS NOT NULL
BEGIN
	set @cmd = N'
truncate table ' + @MonthlyReportCaseDiagnosis_Age_0_1_TotalValuesTable collate Cyrillic_General_CI_AS
	exec sp_executesql @cmd
end



if OBJECT_ID(@MonthlyReportCaseDiagnosis_Age_1_4_TotalValuesTableInTempDb) IS NULL
BEGIN
	set @cmd = N'
create table ' + @MonthlyReportCaseDiagnosis_Age_1_4_TotalValuesTable + N'
(	idfsDiagnosis			BIGINT NOT NULL PRIMARY KEY,
	intAge_1_4				BIGINT NOT NULL
)
' collate Cyrillic_General_CI_AS
	exec sp_executesql @cmd
END

if OBJECT_ID(@MonthlyReportCaseDiagnosis_Age_1_4_TotalValuesTableInTempDb) IS NOT NULL
BEGIN
	set @cmd = N'
truncate table ' + @MonthlyReportCaseDiagnosis_Age_1_4_TotalValuesTable collate Cyrillic_General_CI_AS
	exec sp_executesql @cmd
end



if OBJECT_ID(@MonthlyReportCaseDiagnosis_Age_5_14_TotalValuesTableInTempDb) IS NULL
BEGIN
	set @cmd = N'
create table ' + @MonthlyReportCaseDiagnosis_Age_5_14_TotalValuesTable + N'
(	idfsDiagnosis			BIGINT NOT NULL PRIMARY KEY,
	intAge_5_14				BIGINT NOT NULL
)
' collate Cyrillic_General_CI_AS
	exec sp_executesql @cmd
END

if OBJECT_ID(@MonthlyReportCaseDiagnosis_Age_5_14_TotalValuesTableInTempDb) IS NOT NULL
BEGIN
	set @cmd = N'
truncate table ' + @MonthlyReportCaseDiagnosis_Age_5_14_TotalValuesTable collate Cyrillic_General_CI_AS
	exec sp_executesql @cmd
end



if OBJECT_ID(@MonthlyReportCaseDiagnosis_Age_15_19_TotalValuesTableInTempDb) IS NULL
BEGIN
	set @cmd = N'
create table ' + @MonthlyReportCaseDiagnosis_Age_15_19_TotalValuesTable + N'
(	idfsDiagnosis			BIGINT NOT NULL PRIMARY KEY,
	intAge_15_19			INT NOT NULL
)
' collate Cyrillic_General_CI_AS
	exec sp_executesql @cmd
END

if OBJECT_ID(@MonthlyReportCaseDiagnosis_Age_15_19_TotalValuesTableInTempDb) IS NOT NULL
BEGIN
	set @cmd = N'
truncate table ' + @MonthlyReportCaseDiagnosis_Age_15_19_TotalValuesTable collate Cyrillic_General_CI_AS
	exec sp_executesql @cmd
end



if OBJECT_ID(@MonthlyReportCaseDiagnosis_Age_20_29_TotalValuesTableInTempDb) IS NULL
BEGIN
	set @cmd = N'
create table ' + @MonthlyReportCaseDiagnosis_Age_20_29_TotalValuesTable + N'
(	idfsDiagnosis			BIGINT NOT NULL PRIMARY KEY,
	intAge_20_29			BIGINT NOT NULL
)
' collate Cyrillic_General_CI_AS
	exec sp_executesql @cmd
END

if OBJECT_ID(@MonthlyReportCaseDiagnosis_Age_20_29_TotalValuesTableInTempDb) IS NOT NULL
BEGIN
	set @cmd = N'
truncate table ' + @MonthlyReportCaseDiagnosis_Age_20_29_TotalValuesTable collate Cyrillic_General_CI_AS
	exec sp_executesql @cmd
end



if OBJECT_ID(@MonthlyReportCaseDiagnosis_Age_30_59_TotalValuesTableInTempDb) IS NULL
BEGIN
	set @cmd = N'
create table ' + @MonthlyReportCaseDiagnosis_Age_30_59_TotalValuesTable + N'
(	idfsDiagnosis			BIGINT NOT NULL PRIMARY KEY,
	intAge_30_59			BIGINT NOT NULL
)
' collate Cyrillic_General_CI_AS
	exec sp_executesql @cmd
END

if OBJECT_ID(@MonthlyReportCaseDiagnosis_Age_30_59_TotalValuesTableInTempDb) IS NOT NULL
BEGIN
	set @cmd = N'
truncate table ' + @MonthlyReportCaseDiagnosis_Age_30_59_TotalValuesTable collate Cyrillic_General_CI_AS
	exec sp_executesql @cmd
end



if OBJECT_ID(@MonthlyReportCaseDiagnosis_Age_60_more_TotalValuesTableInTempDb) IS NULL
BEGIN
	set @cmd = N'
create table ' + @MonthlyReportCaseDiagnosis_Age_60_more_TotalValuesTable + N'
(	idfsDiagnosis			BIGINT NOT NULL PRIMARY KEY,
	intAge_60_more			BIGINT NOT NULL
)
' collate Cyrillic_General_CI_AS
	exec sp_executesql @cmd
END

if OBJECT_ID(@MonthlyReportCaseDiagnosis_Age_60_more_TotalValuesTableInTempDb) IS NOT NULL
BEGIN
	set @cmd = N'
truncate table ' + @MonthlyReportCaseDiagnosis_Age_60_more_TotalValuesTable collate Cyrillic_General_CI_AS
	exec sp_executesql @cmd
end



if OBJECT_ID(@MonthlyReportDiagnosisGroupTableInTempDb) IS NULL
BEGIN
	set @cmd = N'
create table ' + @MonthlyReportDiagnosisGroupTable + N'
(	idfsDiagnosisGroup	BIGINT NOT NULL PRIMARY KEY,
	intAge_0_1			BIGINT NOT NULL,	--7
	intAge_1_4			BIGINT NOT NULL, --8
	intAge_5_14			BIGINT NOT NULL, --9
	intAge_15_19		BIGINT NOT NULL, --10
	intAge_20_29		BIGINT NOT NULL, --11
	intAge_30_59		BIGINT NOT NULL, --12
	intAge_60_more		BIGINT NOT NULL, --13
	intLethalCases		BIGINT NOT NULL --14
)
' collate Cyrillic_General_CI_AS
	exec sp_executesql @cmd
END

if OBJECT_ID(@MonthlyReportDiagnosisGroupTableInTempDb) IS NOT NULL
BEGIN
	set @cmd = N'
truncate table ' + @MonthlyReportDiagnosisGroupTable collate Cyrillic_General_CI_AS
	exec sp_executesql @cmd
end



-- Declare internal variables

DECLARE @idfsCustomReportType BIGINT
DECLARE @idfsLanguage BIGINT
DECLARE @idfsSite BIGINT
DECLARE 
    @FFP_Age_0_1 BIGINT,--7
    @FFP_Age_1_4 BIGINT, --8
    @FFP_Age_5_14 BIGINT, --9
    @FFP_Age_15_19 BIGINT, --10
    @FFP_Age_20_29 BIGINT, --11
    @FFP_Age_30_59 BIGINT, --12
    @FFP_Age_60_more BIGINT, --13
    @FFP_LethalCases BIGINT --14
    
declare @FatalCasesOfInfectiousDiseases bigint

DECLARE @MinAdminLevel BIGINT
DECLARE @MinTimeInterval BIGINT
DECLARE @AggrCaseType BIGINT
DECLARE @idfsCountry BIGINT

declare @CountryNode hierarchyid
declare	@RegionNode hierarchyid
declare @RayonNode hierarchyid

DECLARE @NAValue AS NVARCHAR(10)

declare	@SpecifyDiadnoses	nvarchar(MAX)
declare	@Separator	nvarchar(10)


--set @FatalCasesOfInfectiousDiseases = 10750760000000 /*Fatal cases of infectious diseases*/

-- Retrieve and calculate values for the report

SET @idfsCustomReportType = 10290008 /*GG Report on Cases of Infectious Diseases (Monthly Form IV–03/1 Old Revision)*/

SET @NAValue = N'Silver'


set @cmd = N'
select	@FatalCasesOfInfectiousDiseasesOut = dg.idfsReportDiagnosisGroup
from	[' + @dbName_Actual + N'].dbo.trtReportDiagnosisGroup dg
where	dg.intRowStatus = 0
		and dg.strDiagnosisGroupAlias = N''DG_FatalCasesOfInfectiousDiseases'' collate Cyrillic_General_CI_AS
' collate Cyrillic_General_CI_AS
exec sp_executesql @cmd, N'@FatalCasesOfInfectiousDiseasesOut bigint output', @FatalCasesOfInfectiousDiseasesOut = @FatalCasesOfInfectiousDiseases output

set @cmd = N'
set	@idfsLanguageOut = [' + @dbName_Actual + N'].Report.FN_GBL_LanguageCode_GET (@LangIDInput)
' collate Cyrillic_General_CI_AS
exec sp_executesql @cmd, N'@idfsLanguageOut bigint output, @LangIDInput nvarchar(50)', @idfsLanguageOut = @idfsLanguage output, @LangIDInput = @LangID


set @cmd = N'
IF @RayonIDInput IS NOT NULL
BEGIN
  SELECT	@idfsSiteOutput = fnfl.idfsSite
  FROM		[' + @dbName_Actual + N'].Report.FN_REP_ReportingFacilitiesList(@idfsLanguageInput, @RayonIDInput) fnfl
END

IF @idfsSiteOutput IS NULL
	SET @idfsSiteOutput = ISNULL(@SiteIDInput, [' + @dbName_Actual + N'].dbo.FN_GBL_SITEID_GET())

IF @RegionIDOutput IS NULL
BEGIN
	SET @RegionIDOutput = (SELECT idfsRegion FROM [' + @dbName_Actual + N'].Report.FN_GBL_GIS_Rayon_GET(@LangIDInput, 19000002 /*Rayon*/) WHERE idfsRayon = @RayonIDInput)
END
' collate Cyrillic_General_CI_AS
exec sp_executesql @cmd, N'@SiteIDInput bigint, @idfsSiteOutput bigint output, @RegionIDOutput bigint output, @RayonIDInput bigint, @idfsLanguageInput bigint, @LangIDInput nvarchar(50)',
		@SiteIDInput = @SiteID, @idfsSiteOutput = @idfsSite output, @RegionIDOutput = @RegionID output, @RayonIDInput = @RayonID, @idfsLanguageInput = @idfsLanguage, @LangIDInput = @LangID


SET @AggrCaseType = 10102001 /*Human Aggregate Case*/
SET @idfsCountry = 780000000 /*Georgia*/

set @cmd = N'
select	@CountryNodeOut = l.[node]
from	[' + @dbName_Actual + N'].dbo.gisLocation l
where	l.idfsLocation = @idfsCountryInput
' collate Cyrillic_General_CI_AS
exec sp_executesql @cmd, N'@idfsCountryInput bigint, @CountryNodeOut hierarchyid output',
		@idfsCountryInput = @idfsCountry, @CountryNodeOut = @CountryNode output


set @cmd = N'
select	@RegionNodeOut = l.[node]
from	[' + @dbName_Actual + N'].dbo.gisLocation l
where	l.idfsLocation = @RegionIDInput
' collate Cyrillic_General_CI_AS
exec sp_executesql @cmd, N'@RegionIDInput bigint, @RegionNodeOut hierarchyid output',
		@RegionIDInput = @RegionID, @RegionNodeOut = @RegionNode output


set @cmd = N'
select	@RayonNodeOut = l.[node]
from	[' + @dbName_Actual + N'].dbo.gisLocation l
where	l.idfsLocation = @RayonIDInput
' collate Cyrillic_General_CI_AS
exec sp_executesql @cmd, N'@RayonIDInput bigint, @RayonNodeOut hierarchyid output',
		@RayonIDInput = @RayonID, @RayonNodeOut = @RayonNode output


set @cmd = N'
SELECT	@MinAdminLevelOut = idfsStatisticAreaType,
		@MinTimeIntervalOut = idfsStatisticPeriodType
FROM [' + @dbName_Actual + N'].Report.FN_GBL_AggregateSettings_GET (@AggrCaseTypeInput)--@AggrCaseType
' collate Cyrillic_General_CI_AS
exec sp_executesql @cmd, N'@AggrCaseTypeInput bigint, @MinAdminLevelOut bigint output, @MinTimeIntervalOut bigint output',
		@AggrCaseTypeInput = @AggrCaseType, @MinAdminLevelOut = @MinAdminLevel output, @MinTimeIntervalOut = @MinTimeInterval output


set @cmd = N'
select @FFP_Age_0_1Out = idfsFFObject from [' + @dbName_Actual + N'].dbo.trtFFObjectForCustomReport
where idfsCustomReportType = @idfsCustomReportTypeInput and strFFObjectAlias = ''FFP_Age_0_1'' collate Cyrillic_General_CI_AS
and intRowStatus = 0

select @FFP_Age_1_4Out = idfsFFObject from [' + @dbName_Actual + N'].dbo.trtFFObjectForCustomReport
where idfsCustomReportType = @idfsCustomReportTypeInput and strFFObjectAlias = ''FFP_Age_1_4'' collate Cyrillic_General_CI_AS
and intRowStatus = 0

select @FFP_Age_5_14Out = idfsFFObject from [' + @dbName_Actual + N'].dbo.trtFFObjectForCustomReport
where idfsCustomReportType = @idfsCustomReportTypeInput and strFFObjectAlias = ''FFP_Age_5_14'' collate Cyrillic_General_CI_AS
and intRowStatus = 0

select @FFP_Age_15_19Out = idfsFFObject from [' + @dbName_Actual + N'].dbo.trtFFObjectForCustomReport
where idfsCustomReportType = @idfsCustomReportTypeInput and strFFObjectAlias = ''FFP_Age_15_19'' collate Cyrillic_General_CI_AS
and intRowStatus = 0

select @FFP_Age_20_29Out = idfsFFObject from [' + @dbName_Actual + N'].dbo.trtFFObjectForCustomReport
where idfsCustomReportType = @idfsCustomReportTypeInput and strFFObjectAlias = ''FFP_Age_20_29'' collate Cyrillic_General_CI_AS
and intRowStatus = 0

select @FFP_Age_30_59Out = idfsFFObject from [' + @dbName_Actual + N'].dbo.trtFFObjectForCustomReport
where idfsCustomReportType = @idfsCustomReportTypeInput and strFFObjectAlias = ''FFP_Age_30_59'' collate Cyrillic_General_CI_AS
and intRowStatus = 0

select @FFP_Age_60_moreOut = idfsFFObject from [' + @dbName_Actual + N'].dbo.trtFFObjectForCustomReport
where idfsCustomReportType = @idfsCustomReportTypeInput and strFFObjectAlias = ''FFP_Age_60_more'' collate Cyrillic_General_CI_AS
and intRowStatus = 0

select @FFP_LethalCasesOut = idfsFFObject from [' + @dbName_Actual + N'].dbo.trtFFObjectForCustomReport
where idfsCustomReportType = @idfsCustomReportTypeInput and strFFObjectAlias = ''FFP_LethalCases'' collate Cyrillic_General_CI_AS
and intRowStatus = 0
' collate Cyrillic_General_CI_AS
exec sp_executesql @cmd, N'@idfsCustomReportTypeInput bigint, @FFP_Age_0_1Out bigint output, @FFP_Age_1_4Out bigint output, @FFP_Age_5_14Out bigint output, @FFP_Age_15_19Out bigint output, @FFP_Age_20_29Out bigint output, @FFP_Age_30_59Out bigint output, @FFP_Age_60_moreOut bigint output, @FFP_LethalCasesOut bigint output',
		@idfsCustomReportTypeInput = @idfsCustomReportType, @FFP_Age_0_1Out = @FFP_Age_0_1 output, @FFP_Age_1_4Out = @FFP_Age_1_4 output, @FFP_Age_5_14Out = @FFP_Age_5_14 output, @FFP_Age_15_19Out = @FFP_Age_15_19 output,
		@FFP_Age_20_29Out = @FFP_Age_20_29 output, @FFP_Age_30_59Out = @FFP_Age_30_59 output, @FFP_Age_60_moreOut = @FFP_Age_60_more output, @FFP_LethalCasesOut = @FFP_LethalCases output


set @cmd = N'
select		@SpecifyDiadnosesOut = coalesce(rtrim(snt.strTextString) + N'' '', rtrim(br.strDefault) + N'' '', N'''')
from		[' + @dbName_Actual + N'].dbo.trtBaseReference br
left join	[' + @dbName_Actual + N'].dbo.trtStringNameTranslation snt
on			snt.idfsBaseReference = br.idfsBaseReference
			and snt.idfsLanguage = @idfsLanguageInput
where		br.idfsReferenceType = 19000132 /*Additional Report Text*/
			and br.strDefault = N''Specify disease(s):'' collate Cyrillic_General_CI_AS
			and br.intRowStatus = 0
' collate Cyrillic_General_CI_AS
exec sp_executesql @cmd, N'@SpecifyDiadnosesOut nvarchar(max) output, @idfsLanguageInput bigint', @SpecifyDiadnosesOut = @SpecifyDiadnoses output, @idfsLanguageInput = @idfsLanguage

if @SpecifyDiadnoses is null
	set	@SpecifyDiadnoses = N''


-- Diagnoses from actual database included in report
set @cmd = N'
INSERT INTO ' + @MonthlyReportDiagnosisTable + N' (
	idfsDiagnosis,
	blnIsAggregate,
	intAge_0_1,
	intAge_1_4,
	intAge_5_14,
	intAge_15_19,
	intAge_20_29,
	intAge_30_59,
	intAge_60_more,
	intLethalCases
) 
SELECT DISTINCT
  fdt.idfsDiagnosis,
  CASE WHEN  trtd.idfsUsingType = 10020002  --dutAggregatedCase
    THEN 1
    ELSE 0
  END,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0

FROM [' + @dbName_Actual + N'].dbo.trtDiagnosisToGroupForReportType fdt
    INNER JOIN [' + @dbName_Actual + N'].dbo.trtDiagnosis trtd
    ON trtd.idfsDiagnosis = fdt.idfsDiagnosis
    -- AND trtd.intRowStatus = 0
WHERE  fdt.idfsCustomReportType = @idfsCustomReportTypeInput 

     and  fdt.idfsReportDiagnosisGroup = @FatalCasesOfInfectiousDiseasesInput /*Fatal cases of infectious diseases*/

       
INSERT INTO '+ @MonthlyReportDiagnosisTable + N' (
	idfsDiagnosis,
  blnIsAggregate,
	intAge_0_1,
	intAge_1_4,
	intAge_5_14,
	intAge_15_19,
	intAge_20_29,
	intAge_30_59,
	intAge_60_more,
	intLethalCases
) 
SELECT 
  trtd.idfsDiagnosis,
  CASE WHEN  trtd.idfsUsingType = 10020002  --dutAggregatedCase
    THEN 1
    ELSE 0
  END,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0

FROM [' + @dbName_Actual + N'].dbo.trtReportRows rr
    INNER JOIN [' + @dbName_Actual + N'].dbo.trtBaseReference br
    ON br.idfsBaseReference = rr.idfsDiagnosisOrReportDiagnosisGroup
        AND br.idfsReferenceType = 19000019 --''rftDiagnosis''
    INNER JOIN [' + @dbName_Actual + N'].dbo.trtDiagnosis trtd
    ON trtd.idfsDiagnosis = rr.idfsDiagnosisOrReportDiagnosisGroup 
        --AND trtd.intRowStatus = 0
WHERE  rr.idfsCustomReportType = @idfsCustomReportTypeInput 
       AND  rr.intRowStatus = 0 
       AND NOT EXISTS 
       (
       SELECT 1 FROM ' + @MonthlyReportDiagnosisTable + N'
       WHERE idfsDiagnosis = rr.idfsDiagnosisOrReportDiagnosisGroup
       )      AND
       rr.idfsDiagnosisOrReportDiagnosisGroup = @FatalCasesOfInfectiousDiseasesInput /*Fatal cases of infectious diseases*/
' collate Cyrillic_General_CI_AS
exec sp_executesql @cmd, N'@idfsCustomReportTypeInput bigint, @FatalCasesOfInfectiousDiseasesInput bigint',
		@idfsCustomReportTypeInput = @idfsCustomReportType, @FatalCasesOfInfectiousDiseasesInput = @FatalCasesOfInfectiousDiseases




/*

19000091	rftStatisticPeriodType:
    10091001	sptMonth	Month
    10091002	sptOnday	Day
    10091003	sptQuarter	Quarter
    10091004	sptWeek	Week
    10091005	sptYear	Year

19000089	rftStatisticAreaType
    10089001	satCountry	Country
    10089002	satRayon	Rayon
    10089003	satRegion	Region
    10089004	satSettlement	Settlement


19000102	rftAggregateCaseType:
    10102001  Aggregate Case

*/




-- Aggregate Cases from actual database
set @cmd = N'
insert into	' + @MonthlyReportHumanAggregateCase + N'
( idfAggrCase,
  idfCaseObservation,
  datStartDate,
  idfVersion
)
select	  a.idfAggrCase,
          a.idfCaseObservation,
		  a.datStartDate,
		  a.idfVersion
from		[' + @dbName_Actual + N'].dbo.tlbAggrCase a
    left join	[' + @dbName_Actual + N'].dbo.gisCountry c
    on			c.idfsCountry = a.idfsAdministrativeUnit
			    and c.idfsCountry = @idfsCountryInput
    left join	[' + @dbName_Actual + N'].dbo.gisRegion r
    on			r.idfsRegion = a.idfsAdministrativeUnit 
			    and r.idfsCountry = @idfsCountryInput
    left join	[' + @dbName_Actual + N'].dbo.gisRayon rr
    on			rr.idfsRayon = a.idfsAdministrativeUnit
			    and rr.idfsCountry = @idfsCountryInput
    left join	[' + @dbName_Actual + N'].dbo.gisSettlement s
    on			s.idfsSettlement = a.idfsAdministrativeUnit
			    and s.idfsCountry = @idfsCountryInput

WHERE 			
			a.idfsAggrCaseType = @AggrCaseTypeInput
			and (	@StartDateInput <= a.datStartDate
					and a.datFinishDate < DATEADD(day, 1, @FinishDateInput)
				)
			and (	(	@MinTimeIntervalInput = 10091005 --''sptYear''
						and DateDiff(year, a.datStartDate, a.datFinishDate) = 0
						and DateDiff(quarter, a.datStartDate, a.datFinishDate) > 1
						and DateDiff(month, a.datStartDate, a.datFinishDate) > 1
						and [' + @dbName_Actual + N'].Report.FN_GBL_WeekDateDiff_GET(a.datStartDate, a.datFinishDate) > 1
						and DateDiff(day, a.datStartDate, a.datFinishDate) > 1
					)
					or	(	@MinTimeIntervalInput = 10091003 --''sptQuarter''
							and DateDiff(quarter, a.datStartDate, a.datFinishDate) = 0
							and DateDiff(month, a.datStartDate, a.datFinishDate) > 1
							and [' + @dbName_Actual + N'].Report.FN_GBL_WeekDateDiff_GET(a.datStartDate, a.datFinishDate) > 1
							and DateDiff(day, a.datStartDate, a.datFinishDate) > 1
						)
					or (	@MinTimeIntervalInput = 10091001 --''sptMonth''
							and DateDiff(month, a.datStartDate, a.datFinishDate) = 0
							and [' + @dbName_Actual + N'].Report.FN_GBL_WeekDateDiff_GET(a.datStartDate, a.datFinishDate) > 1
							and DateDiff(day, a.datStartDate, a.datFinishDate) > 1
						)
					or (	@MinTimeIntervalInput = 10091004 --''sptWeek''
							and [' + @dbName_Actual + N'].Report.FN_GBL_WeekDateDiff_GET(a.datStartDate, a.datFinishDate) = 0
							and DateDiff(day, a.datStartDate, a.datFinishDate) > 1
						)
					or (	@MinTimeIntervalInput = 10091002--''sptOnday''
							and DateDiff(day, a.datStartDate, a.datFinishDate) = 0
						)
				)
			and	(	(	@MinAdminLevelInput = 10089001 --''satCountry'' 
						and a.idfsAdministrativeUnit = c.idfsCountry
					)
					or	(	@MinAdminLevelInput = 10089003 --''satRegion'' 
							and a.idfsAdministrativeUnit = r.idfsRegion
							AND (r.idfsRegion = @RegionIDInput OR @RegionIDInput IS NULL)
						)
					or	(	@MinAdminLevelInput = 10089002 --''satRayon'' 
							and a.idfsAdministrativeUnit = rr.idfsRayon
							AND (rr.idfsRayon = @RayonIDInput OR @RayonIDInput IS NULL) 
							AND (rr.idfsRegion = @RegionIDInput OR @RegionIDInput IS NULL)
						)
					or	(	@MinAdminLevelInput = 10089004 --''satSettlement'' 
							and a.idfsAdministrativeUnit = s.idfsSettlement
							AND (s.idfsRayon = @RayonIDInput OR @RayonIDInput IS NULL) 
							AND (s.idfsRegion = @RegionIDInput OR @RegionIDInput IS NULL)
						)
				  )
			and a.intRowStatus = 0
			and not exists (select 1 from ' + @MonthlyReportHumanAggregateCase + N' t where t.idfAggrCase = a.idfAggrCase)
' collate Cyrillic_General_CI_AS
exec sp_executesql @cmd, N'@AggrCaseTypeInput bigint, @idfsCountryInput bigint, @StartDateInput datetime, @FinishDateInput datetime, @MinTimeIntervalInput bigint, @MinAdminLevelInput bigint, @RegionIDInput bigint, @RayonIDInput bigint',
		@AggrCaseTypeInput = @AggrCaseType, @idfsCountryInput = @idfsCountry, @StartDateInput = @StartDate, @FinishDateInput = @FinishDate,
		@MinTimeIntervalInput = @MinTimeInterval, @MinAdminLevelInput = @MinAdminLevel, @RegionIDInput = @RegionID, @RayonIDInput = @RayonID

if @ArchiveExists = 1
begin
-- Aggregate Cases from archive database
	set @cmd = N'
insert into	' + @MonthlyReportHumanAggregateCase + N'
( idfAggrCase,
  idfCaseObservation,
  datStartDate,
  idfVersion
)
select	  a.idfAggrCase,
          a.idfCaseObservation,
		  a.datStartDate,
		  a.idfVersion
from		[' + @dbName_Archive + N'].dbo.tlbAggrCase a
    left join	[' + @dbName_Actual + N'].dbo.gisCountry c
    on			c.idfsCountry = a.idfsAdministrativeUnit
			    and c.idfsCountry = @idfsCountryInput
    left join	[' + @dbName_Actual + N'].dbo.gisRegion r
    on			r.idfsRegion = a.idfsAdministrativeUnit 
			    and r.idfsCountry = @idfsCountryInput
    left join	[' + @dbName_Actual + N'].dbo.gisRayon rr
    on			rr.idfsRayon = a.idfsAdministrativeUnit
			    and rr.idfsCountry = @idfsCountryInput
    left join	[' + @dbName_Actual + N'].dbo.gisSettlement s
    on			s.idfsSettlement = a.idfsAdministrativeUnit
			    and s.idfsCountry = @idfsCountryInput

WHERE 			
			a.idfsAggrCaseType = @AggrCaseTypeInput
			and (	@StartDateInput <= a.datStartDate
					and a.datFinishDate < DATEADD(day, 1, @FinishDateInput)
				)
			and (	(	@MinTimeIntervalInput = 10091005 --''sptYear''
						and DateDiff(year, a.datStartDate, a.datFinishDate) = 0
						and DateDiff(quarter, a.datStartDate, a.datFinishDate) > 1
						and DateDiff(month, a.datStartDate, a.datFinishDate) > 1
						and [' + @dbName_Actual + N'].Report.FN_GBL_WeekDateDiff_GET(a.datStartDate, a.datFinishDate) > 1
						and DateDiff(day, a.datStartDate, a.datFinishDate) > 1
					)
					or	(	@MinTimeIntervalInput = 10091003 --''sptQuarter''
							and DateDiff(quarter, a.datStartDate, a.datFinishDate) = 0
							and DateDiff(month, a.datStartDate, a.datFinishDate) > 1
							and [' + @dbName_Actual + N'].Report.FN_GBL_WeekDateDiff_GET(a.datStartDate, a.datFinishDate) > 1
							and DateDiff(day, a.datStartDate, a.datFinishDate) > 1
						)
					or (	@MinTimeIntervalInput = 10091001 --''sptMonth''
							and DateDiff(month, a.datStartDate, a.datFinishDate) = 0
							and [' + @dbName_Actual + N'].Report.FN_GBL_WeekDateDiff_GET(a.datStartDate, a.datFinishDate) > 1
							and DateDiff(day, a.datStartDate, a.datFinishDate) > 1
						)
					or (	@MinTimeIntervalInput = 10091004 --''sptWeek''
							and [' + @dbName_Actual + N'].Report.FN_GBL_WeekDateDiff_GET(a.datStartDate, a.datFinishDate) = 0
							and DateDiff(day, a.datStartDate, a.datFinishDate) > 1
						)
					or (	@MinTimeIntervalInput = 10091002--''sptOnday''
							and DateDiff(day, a.datStartDate, a.datFinishDate) = 0
						)
				)
			and	(	(	@MinAdminLevelInput = 10089001 --''satCountry'' 
						and a.idfsAdministrativeUnit = c.idfsCountry
					)
					or	(	@MinAdminLevelInput = 10089003 --''satRegion'' 
							and a.idfsAdministrativeUnit = r.idfsRegion
							AND (r.idfsRegion = @RegionIDInput OR @RegionIDInput IS NULL)
						)
					or	(	@MinAdminLevelInput = 10089002 --''satRayon'' 
							and a.idfsAdministrativeUnit = rr.idfsRayon
							AND (rr.idfsRayon = @RayonIDInput OR @RayonIDInput IS NULL) 
							AND (rr.idfsRegion = @RegionIDInput OR @RegionIDInput IS NULL)
						)
					or	(	@MinAdminLevelInput = 10089004 --''satSettlement'' 
							and a.idfsAdministrativeUnit = s.idfsSettlement
							AND (s.idfsRayon = @RayonIDInput OR @RayonIDInput IS NULL) 
							AND (s.idfsRegion = @RegionIDInput OR @RegionIDInput IS NULL)
						)
				  )
			and a.intRowStatus = 0
			and not exists (select 1 from ' + @MonthlyReportHumanAggregateCase + N' t where t.idfAggrCase = a.idfAggrCase)
' collate Cyrillic_General_CI_AS
	exec sp_executesql @cmd, N'@AggrCaseTypeInput bigint, @idfsCountryInput bigint, @StartDateInput datetime, @FinishDateInput datetime, @MinTimeIntervalInput bigint, @MinAdminLevelInput bigint, @RegionIDInput bigint, @RayonIDInput bigint',
			@AggrCaseTypeInput = @AggrCaseType, @idfsCountryInput = @idfsCountry, @StartDateInput = @StartDate, @FinishDateInput = @FinishDate,
			@MinTimeIntervalInput = @MinTimeInterval, @MinAdminLevelInput = @MinAdminLevel, @RegionIDInput = @RegionID, @RayonIDInput = @RayonID

end



-- Rows of aggregate case matrices retrieved from actual database for both actual and archived aggregate cases
set @cmd = N'
insert into	' + @MonthlyReportHumanAggregateCaseRow + N'
( idfAggrCase,
  idfCaseObservation,
  idfRow,
  idfsBaseReference
)
select	--distinct
		fhac.idfAggrCase,
		fhac.idfCaseObservation,
		mtx.idfAggrHumanCaseMTX,
		fdt.idfsDiagnosis

from		' + @MonthlyReportHumanAggregateCase + N' fhac
-- Updated for version 6

-- Matrix version
inner join	[' + @dbName_Actual + N'].dbo.tlbAggrMatrixVersionHeader h
on			h.idfsMatrixType = 71190000000	-- Human Aggregate Case
			and (	-- Get matrix version selected by the user in aggregate case
					h.idfVersion = fhac.idfVersion 
					-- If matrix version is not selected by the user in aggregate case, 
					-- then select active matrix with the latest date activation that is earlier than aggregate case start date
					or (	fhac.idfVersion is null 
							and	h.datStartDate <= fhac.datStartDate
							and	h.blnIsActive = 1
							and not exists	(
										select	1
										from	[' + @dbName_Actual + N'].dbo.tlbAggrMatrixVersionHeader h_later
										where	h_later.idfsMatrixType = 71190000000	-- Human Aggregate Case
												and	h_later.datStartDate <= fhac.datStartDate
												and	h_later.blnIsActive = 1
												and h_later.intRowStatus = 0
												and	h_later.datStartDate > h.datStartDate
											)
							and h.intRowStatus = 0
						))

-- Matrix row
inner join	[' + @dbName_Actual + N'].dbo.tlbAggrHumanCaseMTX mtx
on			mtx.idfVersion = h.idfVersion
			and mtx.intRowStatus <= h.intRowStatus
inner join	' + @MonthlyReportDiagnosisTable + N' fdt
on			fdt.idfsDiagnosis = mtx.idfsDiagnosis

' collate Cyrillic_General_CI_AS
--exec sp_executesql @cmd



-- Summarize values from aggregate cases from both actual and archive databases: Age_0_1
--set @cmd = N'
set @cmd = @cmd + N'
insert into	' + @MonthlyReportAggregateDiagnosisValuesTable + N'
(	idfsBaseReference,
	intAge_0_1,	--7
	intAge_1_4, --8
	intAge_5_14, --9
	intAge_15_19, --10
	intAge_20_29, --11
	intAge_30_59, --12
	intAge_60_more, --13
	intLethalCases --14
)
select		
		fhacr.idfsBaseReference,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		sum(CAST(IsNull(val_LethalCases_actual.varValue, 0) AS bigint))' + case when @ArchiveExists = 1 then N' + sum(CAST(IsNull(val_LethalCases_archive.varValue, 0) AS bigint))' else N'' end + N'

from		' + @MonthlyReportHumanAggregateCaseRow + N' fhacr

outer apply
(	select	top 1 agp_LethalCases.varValue
	from	[' + @dbName_Actual + N'].dbo.tlbActivityParameters agp_LethalCases
	where		agp_LethalCases.idfObservation = fhacr.idfCaseObservation
				and	agp_LethalCases.idfsParameter = @FFP_LethalCasesInput
				and agp_LethalCases.idfRow = fhacr.idfRow
				and agp_LethalCases.intRowStatus = 0
				and SQL_VARIANT_PROPERTY(agp_LethalCases.varValue, ''BaseType'') in (''bigint'',''decimal'',''float'',''int'',''numeric'',''real'',''smallint'',''tinyint'')
) val_LethalCases_actual
' collate Cyrillic_General_CI_AS

if @ArchiveExists = 1
begin
	set @cmd = @cmd + N'
outer apply
(	select	top 1 agp_LethalCases.varValue
	from	[' + @dbName_Archive + N'].dbo.tlbActivityParameters agp_LethalCases
	where		agp_LethalCases.idfObservation = fhacr.idfCaseObservation
				and	agp_LethalCases.idfsParameter = @FFP_LethalCasesInput
				and agp_LethalCases.idfRow = fhacr.idfRow
				and agp_LethalCases.intRowStatus = 0
				and SQL_VARIANT_PROPERTY(agp_LethalCases.varValue, ''BaseType'') in (''bigint'',''decimal'',''float'',''int'',''numeric'',''real'',''smallint'',''tinyint'')
) val_LethalCases_archive
' collate Cyrillic_General_CI_AS
	
end

set @cmd = @cmd + N'
group by	fhacr.idfsBaseReference

' collate Cyrillic_General_CI_AS
exec sp_executesql @cmd, N'@FFP_LethalCasesInput bigint',
		@FFP_LethalCasesInput = @FFP_LethalCases



-- Human Cases from actual database
set @cmd = N'
insert into	' + @MonthlyReportCaseTable + N'
(	idfsDiagnosis,
	idfCase,
	intYear
)
select distinct
			fdt.idfsDiagnosis,
			hc.idfHumanCase AS idfCase,
			case
				when	IsNull(hc.idfsHumanAgeType, -1) = 10042003	-- Years 
						and (IsNull(hc.intPatientAge, -1) >= 0 and IsNull(hc.intPatientAge, -1) <= 200)
					then	hc.intPatientAge
				when	IsNull(hc.idfsHumanAgeType, -1) = 10042002	-- Months
						and (IsNull(hc.intPatientAge, -1) >= 0 and IsNull(hc.intPatientAge, -1) <= 60)
					then	cast(hc.intPatientAge / 12 as int)
				when	IsNull(hc.idfsHumanAgeType, -1) = 10042001	-- Days
						and (IsNull(hc.intPatientAge, -1) >= 0)
					then	0
				else	null
			end
' collate Cyrillic_General_CI_AS
set @cmd = @cmd + N'
FROM [' + @dbName_Actual + N'].dbo.tlbHumanCase hc

    INNER JOIN	' + @MonthlyReportDiagnosisTable + N' fdt
    ON			--fdt.blnIsAggregate = 0 AND
             fdt.idfsDiagnosis = COALESCE(hc.idfsFinalDiagnosis, hc.idfsTentativeDiagnosis)

    INNER JOIN [' + @dbName_Actual + N'].dbo.tlbHuman h
      LEFT OUTER JOIN [' + @dbName_Actual + N'].dbo.tlbGeoLocation gl
      ON h.idfCurrentResidenceAddress = gl.idfGeoLocation
    	AND gl.intRowStatus = 0
	  LEFT OUTER JOIN [' + @dbName_Actual + N'].dbo.gisLocation l
      ON l.idfsLocation = gl.idfsLocation
    ON hc.idfHuman = h.idfHuman
       and h.intRowStatus = 0
    			
    LEFT OUTER JOIN  [' + @dbName_Actual + N'].dbo.tlbGeoLocation cgl
    ON hc.idfPointGeoLocation = cgl.idfGeoLocation
        AND cgl.intRowStatus = 0
	LEFT OUTER JOIN [' + @dbName_Actual + N'].dbo.gisLocation cl
    ON cl.idfsLocation = cgl.idfsLocation
			
' collate Cyrillic_General_CI_AS
set @cmd = @cmd + N'
WHERE	
	(	@StartDateInput <= coalesce(hc.datOnSetDate, hc.datFinalDiagnosisDate, hc.datTentativeDiagnosisDate, hc.datNotificationDate, hc.datEnteredDate)
		and coalesce(hc.datOnSetDate, hc.datFinalDiagnosisDate, hc.datTentativeDiagnosisDate, hc.datNotificationDate, hc.datEnteredDate) < DATEADD(day, 1, @FinishDateInput)
	) 
	AND
	(	
			(	cgl.idfsRegion is not null and @RegionIDInput is not null
					and cl.node.IsDescendantOf(@RegionNodeInput) = 1
					and (	(	cgl.idfsRayon is not null and @RayonIDInput is not null
								and cl.node.IsDescendantOf(@RayonNodeInput) = 1
							)
							or @RayonIDInput is null
						)
			)
			or	
			(	cgl.idfsRegion is null and gl.idfsRegion is not null and @RegionIDInput is not null
					and l.node.IsDescendantOf(@RegionNodeInput) = 1
					and (	(	gl.idfsRayon is not null and @RayonIDInput is not null
								and l.node.IsDescendantOf(@RayonNodeInput) = 1
							)
							or @RayonIDInput is null
						)
			)
			or @RegionIDInput is null
    )
    AND hc.intRowStatus = 0 
	AND hc.strCaseID is not null /* Not an Outbreak Case*/
    AND COALESCE(hc.idfsFinalCaseStatus, hc.idfsInitialCaseStatus, 370000000) <> 370000000 --''casRefused''
    AND hc.idfsOutcome = 10770000000 /*outDied*/
    and ((cgl.idfsGeoLocationType is null or cgl.idfsGeoLocationType <> 10036001 /*Foreign Address*/) 
			or cgl.idfsCountry is null or (cgl.idfsCountry is not null and cl.node.IsDescendantOf(@CountryNodeInput) = 1))
	and not exists
		(	select	1
			from	[' + @dbName_Actual + N'].dbo.HumanDiseaseReportRelationship hdrr
			join	[' + @dbName_Actual + N'].dbo.tlbHumanCase hc_created_from
			on		hc_created_from.idfHumanCase = hdrr.[HumanDiseaseReportID]
			where	hdrr.[RelateToHumanDiseaseReportID] = hc.idfHumanCase
					and hdrr.intRowStatus = 0
					and hdrr.[RelationshipTypeID] = 10503001 /*Connected Disease Report*/
		)
	and not exists (select 1 from ' + @MonthlyReportCaseTable + N' t where t.idfCase = hc.idfHumanCase)
' collate Cyrillic_General_CI_AS
exec sp_executesql @cmd, N'@idfsCountryInput bigint, @CountryNodeInput hierarchyid, @StartDateInput datetime, @FinishDateInput datetime, @RegionIDInput bigint, @RegionNodeInput hierarchyid, @RayonIDInput bigint, @RayonNodeInput hierarchyid',
		@idfsCountryInput = @idfsCountry, @CountryNodeInput = @CountryNode, @StartDateInput = @StartDate, @FinishDateInput = @FinishDate,
		@RegionIDInput = @RegionID, @RegionNodeInput = @RegionNode, @RayonIDInput = @RayonID, @RayonNodeInput = @RayonNode

if @ArchiveExists = 1
begin
-- Human Cases from archive database
	set @cmd = N'
insert into	' + @MonthlyReportCaseTable + N'
(	idfsDiagnosis,
	idfCase,
	intYear
)
select distinct
			fdt.idfsDiagnosis,
			hc.idfHumanCase AS idfCase,
			case
				when	IsNull(hc.idfsHumanAgeType, -1) = 10042003	-- Years 
						and (IsNull(hc.intPatientAge, -1) >= 0 and IsNull(hc.intPatientAge, -1) <= 200)
					then	hc.intPatientAge
				when	IsNull(hc.idfsHumanAgeType, -1) = 10042002	-- Months
						and (IsNull(hc.intPatientAge, -1) >= 0 and IsNull(hc.intPatientAge, -1) <= 60)
					then	cast(hc.intPatientAge / 12 as int)
				when	IsNull(hc.idfsHumanAgeType, -1) = 10042001	-- Days
						and (IsNull(hc.intPatientAge, -1) >= 0)
					then	0
				else	null
			end
' collate Cyrillic_General_CI_AS
	set @cmd = @cmd + N'
FROM [' + @dbName_Archive + N'].dbo.tlbHumanCase hc

    INNER JOIN	' + @MonthlyReportDiagnosisTable + N' fdt
    ON			--fdt.blnIsAggregate = 0 AND
             fdt.idfsDiagnosis = COALESCE(hc.idfsFinalDiagnosis, hc.idfsTentativeDiagnosis)

    INNER JOIN [' + @dbName_Archive + N'].dbo.tlbHuman h
      LEFT OUTER JOIN [' + @dbName_Archive + N'].dbo.tlbGeoLocation gl
      ON h.idfCurrentResidenceAddress = gl.idfGeoLocation
    	AND gl.intRowStatus = 0
	  LEFT OUTER JOIN [' + @dbName_Archive + N'].dbo.gisLocation l
      ON l.idfsLocation = gl.idfsLocation
    ON hc.idfHuman = h.idfHuman
       and h.intRowStatus = 0
    			
    LEFT OUTER JOIN  [' + @dbName_Archive + N'].dbo.tlbGeoLocation cgl
    ON hc.idfPointGeoLocation = cgl.idfGeoLocation
        AND cgl.intRowStatus = 0
	LEFT OUTER JOIN [' + @dbName_Archive + N'].dbo.gisLocation cl
    ON cl.idfsLocation = cgl.idfsLocation
			
' collate Cyrillic_General_CI_AS
	set @cmd = @cmd + N'
WHERE	
	(	@StartDateInput <= ISNULL(hc.datOnSetDate, IsNull(hc.datFinalDiagnosisDate, ISNULL(hc.datTentativeDiagnosisDate, IsNull(hc.datNotificationDate, hc.datEnteredDate))))
		and ISNULL(hc.datOnSetDate, IsNull(hc.datFinalDiagnosisDate, ISNULL(hc.datTentativeDiagnosisDate, IsNull(hc.datNotificationDate, hc.datEnteredDate)))) <  DATEADD(day, 1, @FinishDateInput)
	) 
	AND
	(	
			(	cgl.idfsRegion is not null and @RegionIDInput is not null
					and cl.node.IsDescendantOf(@RegionNodeInput) = 1
					and (	(	cgl.idfsRayon is not null and @RayonIDInput is not null
								and cl.node.IsDescendantOf(@RayonNodeInput) = 1
							)
							or @RayonIDInput is null
						)
			)
			or	
			(	cgl.idfsRegion is null and gl.idfsRegion is not null and @RegionIDInput is not null
					and l.node.IsDescendantOf(@RegionNodeInput) = 1
					and (	(	gl.idfsRayon is not null and @RayonIDInput is not null
								and l.node.IsDescendantOf(@RayonNodeInput) = 1
							)
							or @RayonIDInput is null
						)
			)
			or @RegionIDInput is null
    )
    AND hc.intRowStatus = 0 
	AND hc.strCaseID is not null /* Not an Outbreak Case*/
    AND COALESCE(hc.idfsFinalCaseStatus, hc.idfsInitialCaseStatus, 370000000) <> 370000000 --''casRefused''
    AND hc.idfsOutcome = 10770000000 /*outDied*/
    and (cgl.idfsCountry is null or (cgl.idfsCountry is not null and cl.node.IsDescendantOf(@CountryNodeInput) = 1))
	and not exists
		(	select	1
			from	[' + @dbName_Archive + N'].dbo.HumanDiseaseReportRelationship hdrr
			join	[' + @dbName_Archive + N'].dbo.tlbHumanCase hc_created_from
			on		hc_created_from.idfHumanCase = hdrr.[HumanDiseaseReportID]
			where	hdrr.[RelateToHumanDiseaseReportID] = hc.idfHumanCase
					and hdrr.intRowStatus = 0
					and hdrr.[RelationshipTypeID] = 10503001 /*Connected Disease Report*/
		)
	and not exists (select 1 from ' + @MonthlyReportCaseTable + N' t where t.idfCase = hc.idfHumanCase)
' collate Cyrillic_General_CI_AS
	exec sp_executesql @cmd, N'@idfsCountryInput bigint, @CountryNodeInput hierarchyid, @StartDateInput datetime, @FinishDateInput datetime, @RegionIDInput bigint, @RegionNodeInput hierarchyid, @RayonIDInput bigint, @RayonNodeInput hierarchyid',
			@idfsCountryInput = @idfsCountry, @CountryNodeInput = @CountryNode, @StartDateInput = @StartDate, @FinishDateInput = @FinishDate,
			@RegionIDInput = @RegionID, @RegionNodeInput = @RegionNode, @RayonIDInput = @RayonID, @RayonNodeInput = @RayonNode
end


-- Summarize values from human cases: Total
set @cmd = N'
insert into	' + @MonthlyReportCaseDiagnosisLethalCasesValuesTable + N'
(	idfsDiagnosis,
	intLethalCases
)
SELECT fct.idfsDiagnosis,
			count(fct.idfCase)
from		' + @MonthlyReportCaseTable + N' fct
group by	fct.idfsDiagnosis
' collate Cyrillic_General_CI_AS





-- Summarize values from human cases: Total Age_0_1
set @cmd = @cmd + N'
insert into	' + @MonthlyReportCaseDiagnosis_Age_0_1_TotalValuesTable + N'
(	idfsDiagnosis,
	intAge_0_1
)
select		fct.idfsDiagnosis,
			count(fct.idfCase)
from		' + @MonthlyReportCaseTable + N' fct
where		(fct.intYear >= 0 and fct.intYear < 1)
group by	fct.idfsDiagnosis
' collate Cyrillic_General_CI_AS



-- Summarize values from human cases: Total Age_1_4
set @cmd = @cmd + N'
insert into	' + @MonthlyReportCaseDiagnosis_Age_1_4_TotalValuesTable + N'
(	idfsDiagnosis,
	intAge_1_4
)
select		fct.idfsDiagnosis,
			count(fct.idfCase)
from		' + @MonthlyReportCaseTable + N' fct
where		(fct.intYear >= 1 and fct.intYear <= 4)
group by	fct.idfsDiagnosis
' collate Cyrillic_General_CI_AS



-- Summarize values from human cases: Total Age_5_14
set @cmd = @cmd + N'
insert into	' + @MonthlyReportCaseDiagnosis_Age_5_14_TotalValuesTable + N'
(	idfsDiagnosis,
	intAge_5_14
)
select		fct.idfsDiagnosis,
			count(fct.idfCase)
from		' + @MonthlyReportCaseTable + N' fct
where		(fct.intYear >= 5 and fct.intYear <= 14)
group by	fct.idfsDiagnosis
' collate Cyrillic_General_CI_AS



-- Summarize values from human cases: Total Age_15_19
set @cmd = @cmd + N'
insert into	' + @MonthlyReportCaseDiagnosis_Age_15_19_TotalValuesTable + N'
(	idfsDiagnosis,
	intAge_15_19
)
select		fct.idfsDiagnosis,
			count(fct.idfCase)
from		' + @MonthlyReportCaseTable + N' fct
where		(fct.intYear >= 15 and fct.intYear <= 19)
group by	fct.idfsDiagnosis
' collate Cyrillic_General_CI_AS


-- Summarize values from human cases: Total Age_20_29
set @cmd = @cmd + N'
insert into	' + @MonthlyReportCaseDiagnosis_Age_20_29_TotalValuesTable + N'
(	idfsDiagnosis,
	intAge_20_29
)
select		fct.idfsDiagnosis,
			count(fct.idfCase)
from		' + @MonthlyReportCaseTable + N' fct
where		(fct.intYear >= 20 and fct.intYear <= 29)
group by	fct.idfsDiagnosis
' collate Cyrillic_General_CI_AS



-- Summarize values from human cases: Total Age_30_59
set @cmd = @cmd + N'
insert into	' + @MonthlyReportCaseDiagnosis_Age_30_59_TotalValuesTable + N'
(	idfsDiagnosis,
	intAge_30_59
)
select		fct.idfsDiagnosis,
			count(fct.idfCase)
from		' + @MonthlyReportCaseTable + N' fct
where		(fct.intYear >= 30 and fct.intYear <= 59)
group by	fct.idfsDiagnosis
' collate Cyrillic_General_CI_AS


-- Summarize values from human cases: Total Age_60_more
set @cmd = @cmd + N'
insert into	' + @MonthlyReportCaseDiagnosis_Age_60_more_TotalValuesTable + N'
(	idfsDiagnosis,
	intAge_60_more
)
select		fct.idfsDiagnosis,
			count(fct.idfCase)
from		' + @MonthlyReportCaseTable + N' fct
where		(fct.intYear >= 60)
group by	fct.idfsDiagnosis
' collate Cyrillic_General_CI_AS

-- Summarize values for diagnoses from aggregate cases
set @cmd = @cmd + N'
update		fdt
set				
	fdt.intAge_0_1 = fadvt.intAge_0_1,
	fdt.intAge_1_4 = fadvt.intAge_1_4,
	fdt.intAge_5_14 = fadvt.intAge_5_14,	
	fdt.intAge_15_19 = fadvt.intAge_15_19,	
	fdt.intAge_20_29 = fadvt.intAge_20_29,	
	fdt.intAge_30_59 = fadvt.intAge_30_59,
	fdt.intAge_60_more = fadvt.intAge_60_more,	
	fdt.intLethalCases = fadvt.intLethalCases
from		' + @MonthlyReportDiagnosisTable + N' fdt
    inner join	' + @MonthlyReportAggregateDiagnosisValuesTable + N' fadvt
    on			fadvt.idfsBaseReference = fdt.idfsDiagnosis
--where		fdt.blnIsAggregate = 1
' collate Cyrillic_General_CI_AS


-- Add summarized value for diagnoses from human cases: Total
set @cmd = @cmd + N'
update		fdt
set			fdt.intLethalCases = isnull (fdt.intLethalCases, 0) + fcdvt.intLethalCases
from		' + @MonthlyReportDiagnosisTable + N' fdt
inner join	' + @MonthlyReportCaseDiagnosisLethalCasesValuesTable + N' fcdvt
on			fcdvt.idfsDiagnosis = fdt.idfsDiagnosis
--where		fdt.blnIsAggregate = 0
' collate Cyrillic_General_CI_AS

-- Add summarized value for diagnoses from human cases: Total Age_0_1
set @cmd = @cmd + N'
update		fdt
set			fdt.intAge_0_1 = isnull (fdt.intAge_0_1, 0) +  fcdvt.intAge_0_1
from		' + @MonthlyReportDiagnosisTable + N' fdt
inner join	' + @MonthlyReportCaseDiagnosis_Age_0_1_TotalValuesTable + N' fcdvt
on			fcdvt.idfsDiagnosis = fdt.idfsDiagnosis
--where		fdt.blnIsAggregate = 0
' collate Cyrillic_General_CI_AS

-- Add summarized value for diagnoses from human cases: Total Age_1_4
set @cmd = @cmd + N'
update		fdt
set			fdt.intAge_1_4 = isnull (fdt.intAge_1_4, 0) + fcdvt.intAge_1_4
from		' + @MonthlyReportDiagnosisTable + N' fdt
inner join	' + @MonthlyReportCaseDiagnosis_Age_1_4_TotalValuesTable + N' fcdvt
on			fcdvt.idfsDiagnosis = fdt.idfsDiagnosis
--where		fdt.blnIsAggregate = 0
' collate Cyrillic_General_CI_AS

-- Add summarized value for diagnoses from human cases: Total Age_5_14
set @cmd = @cmd + N'
update		fdt
set			fdt.intAge_5_14 = isnull (fdt.intAge_5_14, 0) + fcdvt.intAge_5_14
from		' + @MonthlyReportDiagnosisTable + N' fdt
inner join	' + @MonthlyReportCaseDiagnosis_Age_5_14_TotalValuesTable + N' fcdvt
on			fcdvt.idfsDiagnosis = fdt.idfsDiagnosis
--where		fdt.blnIsAggregate = 0
' collate Cyrillic_General_CI_AS

-- Add summarized value for diagnoses from human cases: Total Age_15_19
set @cmd = @cmd + N'
update		fdt
set			fdt.intAge_15_19 = isnull (fdt.intAge_15_19, 0) + fcdvt.intAge_15_19
from		' + @MonthlyReportDiagnosisTable + N' fdt
inner join	' + @MonthlyReportCaseDiagnosis_Age_15_19_TotalValuesTable + N' fcdvt
on			fcdvt.idfsDiagnosis = fdt.idfsDiagnosis
--where		fdt.blnIsAggregate = 0	
' collate Cyrillic_General_CI_AS

-- Add summarized value for diagnoses from human cases: Total Age_20_29
set @cmd = @cmd + N'
update		fdt
set			fdt.intAge_20_29 = isnull (fdt.intAge_20_29, 0) + fcdvt.intAge_20_29
from		' + @MonthlyReportDiagnosisTable + N' fdt
inner join	' + @MonthlyReportCaseDiagnosis_Age_20_29_TotalValuesTable + N' fcdvt
on			fcdvt.idfsDiagnosis = fdt.idfsDiagnosis
--where		fdt.blnIsAggregate = 0		
' collate Cyrillic_General_CI_AS

-- Add summarized value for diagnoses from human cases: Total Age_30_59
set @cmd = @cmd + N'
update		fdt
set			fdt.intAge_30_59 = isnull (fdt.intAge_30_59, 0) + fcdvt.intAge_30_59
from		' + @MonthlyReportDiagnosisTable + N' fdt
inner join	' + @MonthlyReportCaseDiagnosis_Age_30_59_TotalValuesTable + N' fcdvt
on			fcdvt.idfsDiagnosis = fdt.idfsDiagnosis
--where		fdt.blnIsAggregate = 0		
' collate Cyrillic_General_CI_AS

-- Add summarized value for diagnoses from human cases: Total Age_60_more
set @cmd = @cmd + N'
update		fdt
set			fdt.intAge_60_more = isnull (fdt.intAge_60_more, 0) + fcdvt.intAge_60_more
from		' + @MonthlyReportDiagnosisTable + N' fdt
inner join	' + @MonthlyReportCaseDiagnosis_Age_60_more_TotalValuesTable + N' fcdvt
on			fcdvt.idfsDiagnosis = fdt.idfsDiagnosis
--where		fdt.blnIsAggregate = 0		
' collate Cyrillic_General_CI_AS


-- Summarize values for diagnosis groups	
set @cmd = @cmd + N'
insert into	' + @MonthlyReportDiagnosisGroupTable + N'
(	idfsDiagnosisGroup,
	intAge_0_1,	
	intAge_1_4, 
	intAge_5_14, 
	intAge_15_19, 
	intAge_20_29, 
	intAge_30_59, 
	intAge_60_more, 
	intLethalCases
)
select	dtg.idfsReportDiagnosisGroup,
	    sum(intAge_0_1),	
	    sum(intAge_1_4), 
	    sum(intAge_5_14), 
	    sum(intAge_15_19), 
	    sum(intAge_20_29), 
	    sum(intAge_30_59), 
	    sum(intAge_60_more), 
	    sum(intLethalCases)
from		' + @MonthlyReportDiagnosisTable + N' fdt
inner join	[' + @dbName_Actual + N'].dbo.trtDiagnosisToGroupForReportType dtg
on			dtg.idfsDiagnosis = fdt.idfsDiagnosis AND
dtg.idfsCustomReportType = @idfsCustomReportTypeInput AND
dtg.idfsReportDiagnosisGroup = @FatalCasesOfInfectiousDiseasesInput /*Fatal cases of infectious diseases*/
group by	dtg.idfsReportDiagnosisGroup	
' collate Cyrillic_General_CI_AS
exec sp_executesql @cmd, N'@idfsCustomReportTypeInput bigint, @FatalCasesOfInfectiousDiseasesInput bigint', 
		@idfsCustomReportTypeInput = @idfsCustomReportType, @FatalCasesOfInfectiousDiseasesInput = @FatalCasesOfInfectiousDiseases



set @cmd = N'
set	@SeparatorOut = N''''

select		@SpecifyDiadnosesOut = @SpecifyDiadnosesOut + @SeparatorOut + isnull(snt_d.strTextString, br_d.strDefault),
			@SeparatorOut = N'', ''
from		[' + @dbName_Actual + N'].dbo.trtDiagnosisToGroupForReportType dtg
inner join	' + @MonthlyReportDiagnosisTable + N' fdt
on			fdt.idfsDiagnosis = dtg.idfsDiagnosis
			and fdt.intLethalCases > 0
inner join	[' + @dbName_Actual + N'].dbo.trtBaseReference br_d
on			br_d.idfsBaseReference = fdt.idfsDiagnosis
left join	[' + @dbName_Actual + N'].dbo.trtStringNameTranslation snt_d
on			snt_d.idfsBaseReference = br_d.idfsBaseReference
			and snt_d.idfsLanguage = @idfsLanguageInput
where		dtg.idfsReportDiagnosisGroup = @FatalCasesOfInfectiousDiseasesInput
' collate Cyrillic_General_CI_AS
exec sp_executesql @cmd, N'@SpecifyDiadnosesOut nvarchar(max) output, @SeparatorOut nvarchar(10) output, @FatalCasesOfInfectiousDiseasesInput bigint, @idfsLanguageInput bigint', 
		@SpecifyDiadnosesOut = @SpecifyDiadnoses output, @SeparatorOut = @Separator output, @FatalCasesOfInfectiousDiseasesInput = @FatalCasesOfInfectiousDiseases, @idfsLanguageInput = @idfsLanguage


-- Select final report table with determined cells that should have silver background
set @cmd = N'
INSERT INTO ' + @ReportTable + N' (
	strICD10,
	intAge_0_1,
	intAge_1_4,
	intAge_5_14,
	intAge_15_19,
	intAge_20_29,
	intAge_30_59,
	intAge_60_more,
	intLethalCases,
	strSpecifyDiseases
)
SELECT 
    NULL,
    iif(fdt.intAge_0_1=0,NULL,fdt.intAge_0_1),
    iif(fdt.intAge_1_4=0,NULL,fdt.intAge_1_4),
    iif(fdt.intAge_5_14=0,NULL,fdt.intAge_5_14),
    iif(fdt.intAge_15_19=0,NULL,fdt.intAge_15_19),
    iif(fdt.intAge_20_29=0,NULL,fdt.intAge_20_29), 
    iif(fdt.intAge_30_59=0,NULL,fdt.intAge_30_59),  
    iif(fdt.intAge_60_more=0,NULL,fdt.intAge_60_more), 
    fdt.intLethalCases, 
    @SpecifyDiadnosesInput
from	' + @MonthlyReportDiagnosisGroupTable + N' fdt

select	strICD10,
		intAge_0_1,
		intAge_1_4,
		intAge_5_14,
		intAge_15_19,
		intAge_20_29,
		intAge_30_59,
		intAge_60_more,
		intLethalCases,
		strSpecifyDiseases,
		''some_key'' as strKeyField
from	' + @ReportTable + N'

' collate Cyrillic_General_CI_AS
exec sp_executesql @cmd, N'@SpecifyDiadnosesInput nvarchar(max)', 
		@SpecifyDiadnosesInput = @SpecifyDiadnoses


--Remove temporary tables

if OBJECT_ID(@reportTableInTempDb) IS NOT NULL
BEGIN
	set @cmd = N'drop table ' + @reportTable collate Cyrillic_General_CI_AS
	exec sp_executesql @cmd
END


if OBJECT_ID(@MonthlyReportDiagnosisTableInTempDb) IS NOT NULL
BEGIN
	set @cmd = N'drop table ' + @MonthlyReportDiagnosisTable collate Cyrillic_General_CI_AS
	exec sp_executesql @cmd
END


if OBJECT_ID(@MonthlyReportHumanAggregateCaseInTempDb) IS NOT NULL
BEGIN
	set @cmd = N'drop table ' + @MonthlyReportHumanAggregateCase collate Cyrillic_General_CI_AS
	exec sp_executesql @cmd
END


if OBJECT_ID(@MonthlyReportHumanAggregateCaseRowInTempDb) IS NOT NULL
BEGIN
	set @cmd = N'drop table ' + @MonthlyReportHumanAggregateCaseRow collate Cyrillic_General_CI_AS
	exec sp_executesql @cmd
END


if OBJECT_ID(@MonthlyReportAggregateDiagnosisValuesTableInTempDb) IS NOT NULL
BEGIN
	set @cmd = N'drop table ' + @MonthlyReportAggregateDiagnosisValuesTable collate Cyrillic_General_CI_AS
	exec sp_executesql @cmd
END


if OBJECT_ID(@MonthlyReportCaseTableInTempDb) IS NOT NULL
BEGIN
	set @cmd = N'drop table ' + @MonthlyReportCaseTable collate Cyrillic_General_CI_AS
	exec sp_executesql @cmd
END


if OBJECT_ID(@MonthlyReportCaseDiagnosisLethalCasesValuesTableInTempDb) IS NOT NULL
BEGIN
	set @cmd = N'drop table ' + @MonthlyReportCaseDiagnosisLethalCasesValuesTable collate Cyrillic_General_CI_AS
	exec sp_executesql @cmd
END


if OBJECT_ID(@MonthlyReportCaseDiagnosis_Age_0_1_TotalValuesTableInTempDb) IS NOT NULL
BEGIN
	set @cmd = N'drop table ' + @MonthlyReportCaseDiagnosis_Age_0_1_TotalValuesTable collate Cyrillic_General_CI_AS
	exec sp_executesql @cmd
END


if OBJECT_ID(@MonthlyReportCaseDiagnosis_Age_1_4_TotalValuesTableInTempDb) IS NOT NULL
BEGIN
	set @cmd = N'drop table ' + @MonthlyReportCaseDiagnosis_Age_1_4_TotalValuesTable collate Cyrillic_General_CI_AS
	exec sp_executesql @cmd
END


if OBJECT_ID(@MonthlyReportCaseDiagnosis_Age_5_14_TotalValuesTableInTempDb) IS NOT NULL
BEGIN
	set @cmd = N'drop table ' + @MonthlyReportCaseDiagnosis_Age_5_14_TotalValuesTable collate Cyrillic_General_CI_AS
	exec sp_executesql @cmd
END


if OBJECT_ID(@MonthlyReportCaseDiagnosis_Age_15_19_TotalValuesTableInTempDb) IS NOT NULL
BEGIN
	set @cmd = N'drop table ' + @MonthlyReportCaseDiagnosis_Age_15_19_TotalValuesTable collate Cyrillic_General_CI_AS
	exec sp_executesql @cmd
END


if OBJECT_ID(@MonthlyReportCaseDiagnosis_Age_20_29_TotalValuesTableInTempDb) IS NOT NULL
BEGIN
	set @cmd = N'drop table ' + @MonthlyReportCaseDiagnosis_Age_20_29_TotalValuesTable collate Cyrillic_General_CI_AS
	exec sp_executesql @cmd
END


if OBJECT_ID(@MonthlyReportCaseDiagnosis_Age_30_59_TotalValuesTableInTempDb) IS NOT NULL
BEGIN
	set @cmd = N'drop table ' + @MonthlyReportCaseDiagnosis_Age_30_59_TotalValuesTable collate Cyrillic_General_CI_AS
	exec sp_executesql @cmd
END


if OBJECT_ID(@MonthlyReportCaseDiagnosis_Age_60_more_TotalValuesTableInTempDb) IS NOT NULL
BEGIN
	set @cmd = N'drop table ' + @MonthlyReportCaseDiagnosis_Age_60_more_TotalValuesTable collate Cyrillic_General_CI_AS
	exec sp_executesql @cmd
END


if OBJECT_ID(@MonthlyReportDiagnosisGroupTableInTempDb) IS NOT NULL
BEGIN
	set @cmd = N'drop table ' + @MonthlyReportDiagnosisGroupTable collate Cyrillic_General_CI_AS
	exec sp_executesql @cmd
END
