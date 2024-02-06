--*************************************************************************
-- Name 				: Report.USP_REP_HUM_AnnualInfectiousDisease
-- Description			: SELECT data for Reportable Infectious Diseases (Annual Form IV03)..
-- 
-- Author               : Srini Goli
-- Revision History
--		Name			Date       Change Detail
--	    Mark Wilson		2/15/2022  Updated to use proper location FN and for diagnosis translations
--      Mirnaya O.      12/10/2023 Retrieve data deom both actual and archive databases if needed; utilize location hierarchy for HDRS; exclude connected HDRs except the final HDRs; retrieve report rows customization from database
/*
--Example of a call of procedure:

EXEC report.USP_REP_HUM_AnnualInfectiousDisease 'en-US', '2016-01-01', '2016-12-31',  NULL, 3660000000
EXEC report.USP_REP_HUM_AnnualInfectiousDisease 'ka-GE', '2016-01-01', '2016-12-31',  null, null
EXEC report.USP_REP_HUM_AnnualInfectiousDisease 'ru-RU', '2016-01-01', '2016-12-31',  null, null

*/

CREATE PROCEDURE [Report].[USP_REP_HUM_AnnualInfectiousDisease]
	(
		@LangID		AS NVARCHAR(10), 
		@StartDate	AS DATETIME,	 
		@FinishDate	AS DATETIME,
		@RegionID	AS BIGINT = NULL,
		@RayonID	AS BIGINT = NULL,
		@SiteID		AS BIGINT = NULL,
		@UseArchiveData	AS BIT = 0 --if User selected Use Archive Data then 1
	)
AS	

set nocount on;


-- Field description may be found here
-- "https://repos.btrp.net/BTRP/Project_Documents/08x-Implementation/Customizations/GG/Reports/Specification for report development - Intermediate Report by Annual Form 03 Human GG 1.0.doc"
-- by number marked red at screen form prototype 

EXEC dbo.USP_GBL_FIRSTDAY_SET

--Declare variables with dynamic SQL command and names of temporary tables
declare	@cmd nvarchar(max) = N''

declare	@TableSuffix sysname = replace(cast(newid() as nvarchar(36)), N'-', N'')

declare @reportTable sysname = N'##ReportTable_' + @TableSuffix collate Cyrillic_General_CI_AS
declare @reportTableInTempDb sysname = N'tempdb..' + @reportTable collate Cyrillic_General_CI_AS

declare @AnnualReportDiagnosisTable sysname = N'##AnnualReportDiagnosisTable_' + @TableSuffix collate Cyrillic_General_CI_AS
declare @AnnualReportDiagnosisTableInTempDb sysname = N'tempdb..' + @AnnualReportDiagnosisTable collate Cyrillic_General_CI_AS

declare @AnnualReportHumanAggregateCase sysname = N'##AnnualReportHumanAggregateCase_' + @TableSuffix collate Cyrillic_General_CI_AS
declare @AnnualReportHumanAggregateCaseInTempDb sysname = N'tempdb..' + @AnnualReportHumanAggregateCase collate Cyrillic_General_CI_AS

declare @AnnualReportHumanAggregateCaseRow sysname = N'##AnnualReportHumanAggregateCaseRow_' + @TableSuffix collate Cyrillic_General_CI_AS
declare @AnnualReportHumanAggregateCaseRowInTempDb sysname = N'tempdb..' + @AnnualReportHumanAggregateCaseRow collate Cyrillic_General_CI_AS

declare @AnnualReportAggregateDiagnosisValuesTable sysname = N'##AnnualReportAggregateDiagnosisValuesTable_' + @TableSuffix collate Cyrillic_General_CI_AS
declare @AnnualReportAggregateDiagnosisValuesTableInTempDb sysname = N'tempdb..' + @AnnualReportAggregateDiagnosisValuesTable collate Cyrillic_General_CI_AS

declare @AnnualReportCaseTable sysname = N'##AnnualReportCaseTable_' + @TableSuffix collate Cyrillic_General_CI_AS
declare @AnnualReportCaseTableInTempDb sysname = N'tempdb..' + @AnnualReportCaseTable collate Cyrillic_General_CI_AS

declare @AnnualReportCaseDiagnosisTotalValuesTable sysname = N'##AnnualReportCaseDiagnosisTotalValuesTable_' + @TableSuffix collate Cyrillic_General_CI_AS
declare @AnnualReportCaseDiagnosisTotalValuesTableInTempDb sysname = N'tempdb..' + @AnnualReportCaseDiagnosisTotalValuesTable collate Cyrillic_General_CI_AS

declare @AnnualReportCaseDiagnosis_Age_0_1_TotalValuesTable sysname = N'##AnnualReportCaseDiagnosis_Age_0_1_TotalValuesTable_' + @TableSuffix collate Cyrillic_General_CI_AS
declare @AnnualReportCaseDiagnosis_Age_0_1_TotalValuesTableInTempDb sysname = N'tempdb..' + @AnnualReportCaseDiagnosis_Age_0_1_TotalValuesTable collate Cyrillic_General_CI_AS

declare @AnnualReportCaseDiagnosis_Age_1_4_TotalValuesTable sysname = N'##AnnualReportCaseDiagnosis_Age_1_4_TotalValuesTable_' + @TableSuffix collate Cyrillic_General_CI_AS
declare @AnnualReportCaseDiagnosis_Age_1_4_TotalValuesTableInTempDb sysname = N'tempdb..' + @AnnualReportCaseDiagnosis_Age_1_4_TotalValuesTable collate Cyrillic_General_CI_AS

declare @AnnualReportCaseDiagnosis_Age_5_14_TotalValuesTable sysname = N'##AnnualReportCaseDiagnosis_Age_5_14_TotalValuesTable_' + @TableSuffix collate Cyrillic_General_CI_AS
declare @AnnualReportCaseDiagnosis_Age_5_14_TotalValuesTableInTempDb sysname = N'tempdb..' + @AnnualReportCaseDiagnosis_Age_5_14_TotalValuesTable collate Cyrillic_General_CI_AS

declare @AnnualReportCaseDiagnosis_Age_15_19_TotalValuesTable sysname = N'##AnnualReportCaseDiagnosis_Age_15_19_TotalValuesTable_' + @TableSuffix collate Cyrillic_General_CI_AS
declare @AnnualReportCaseDiagnosis_Age_15_19_TotalValuesTableInTempDb sysname = N'tempdb..' + @AnnualReportCaseDiagnosis_Age_15_19_TotalValuesTable collate Cyrillic_General_CI_AS

declare @AnnualReportCaseDiagnosis_Age_20_29_TotalValuesTable sysname = N'##AnnualReportCaseDiagnosis_Age_20_29_TotalValuesTable_' + @TableSuffix collate Cyrillic_General_CI_AS
declare @AnnualReportCaseDiagnosis_Age_20_29_TotalValuesTableInTempDb sysname = N'tempdb..' + @AnnualReportCaseDiagnosis_Age_20_29_TotalValuesTable collate Cyrillic_General_CI_AS

declare @AnnualReportCaseDiagnosis_Age_30_59_TotalValuesTable sysname = N'##AnnualReportCaseDiagnosis_Age_30_59_TotalValuesTable_' + @TableSuffix collate Cyrillic_General_CI_AS
declare @AnnualReportCaseDiagnosis_Age_30_59_TotalValuesTableInTempDb sysname = N'tempdb..' + @AnnualReportCaseDiagnosis_Age_30_59_TotalValuesTable collate Cyrillic_General_CI_AS

declare @AnnualReportCaseDiagnosis_Age_60_more_TotalValuesTable sysname = N'##AnnualReportCaseDiagnosis_Age_60_more_TotalValuesTable_' + @TableSuffix collate Cyrillic_General_CI_AS
declare @AnnualReportCaseDiagnosis_Age_60_more_TotalValuesTableInTempDb sysname = N'tempdb..' + @AnnualReportCaseDiagnosis_Age_60_more_TotalValuesTable collate Cyrillic_General_CI_AS

declare @AnnualReportCaseDiagnosis_LabTested_TotalValuesTable sysname = N'##AnnualReportCaseDiagnosis_LabTested_TotalValuesTable_' + @TableSuffix collate Cyrillic_General_CI_AS
declare @AnnualReportCaseDiagnosis_LabTested_TotalValuesTableInTempDb sysname = N'tempdb..' + @AnnualReportCaseDiagnosis_LabTested_TotalValuesTable collate Cyrillic_General_CI_AS

declare @AnnualReportCaseDiagnosis_LabConfirmed_TotalValuesTable sysname = N'##AnnualReportCaseDiagnosis_LabConfirmed_TotalValuesTable_' + @TableSuffix collate Cyrillic_General_CI_AS
declare @AnnualReportCaseDiagnosis_LabConfirmed_TotalValuesTableInTempDb sysname = N'tempdb..' + @AnnualReportCaseDiagnosis_LabConfirmed_TotalValuesTable collate Cyrillic_General_CI_AS

declare @AnnualReportCaseDiagnosis_TotalConfirmed_TotalValuesTable sysname = N'##AnnualReportCaseDiagnosis_TotalConfirmed_TotalValuesTable_' + @TableSuffix collate Cyrillic_General_CI_AS
declare @AnnualReportCaseDiagnosis_TotalConfirmed_TotalValuesTableInTempDb sysname = N'tempdb..' + @AnnualReportCaseDiagnosis_TotalConfirmed_TotalValuesTable collate Cyrillic_General_CI_AS

declare @AnnualReportDiagnosisGroupTable sysname = N'##AnnualReportDiagnosisGroupTable_' + @TableSuffix collate Cyrillic_General_CI_AS
declare @AnnualReportDiagnosisGroupTableInTempDb sysname = N'tempdb..' + @AnnualReportDiagnosisGroupTable collate Cyrillic_General_CI_AS


--Declare variables with database names
declare @dbName_Actual sysname
declare	@dbName_Archive sysname
declare @ArchiveSuffix nvarchar(20) = N'_Archive'
declare @ArchiveExists bit = 0

set @dbName_Actual = DB_NAME()

if	@UseArchiveData = 1 and @dbName_Actual like N'%' + @ArchiveSuffix collate Cyrillic_General_CI_AS 
	and exists(select 1 from sys.databases d where d.[name] = left(@dbName_Actual, len(@dbName_Actual) - len(@ArchiveSuffix)) collate Cyrillic_General_CI_AS)
begin
	set	@dbName_Archive = @dbName_Actual
	set @dbName_Actual = left(@dbName_Actual, len(@dbName_Actual) - len(@ArchiveSuffix))
	set @ArchiveExists = 1
end

if @dbName_Archive is null and exists(select 1 from sys.databases d where d.[name] = @dbName_Actual + @ArchiveSuffix collate Cyrillic_General_CI_AS)
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


if OBJECT_ID(@AnnualReportDiagnosisTableInTempDb) IS NOT NULL
BEGIN
	set @cmd = N'drop table ' + @AnnualReportDiagnosisTable collate Cyrillic_General_CI_AS
	exec sp_executesql @cmd
END


if OBJECT_ID(@AnnualReportHumanAggregateCaseInTempDb) IS NOT NULL
BEGIN
	set @cmd = N'drop table ' + @AnnualReportHumanAggregateCase collate Cyrillic_General_CI_AS
	exec sp_executesql @cmd
END


if OBJECT_ID(@AnnualReportHumanAggregateCaseRowInTempDb) IS NOT NULL
BEGIN
	set @cmd = N'drop table ' + @AnnualReportHumanAggregateCaseRow collate Cyrillic_General_CI_AS
	exec sp_executesql @cmd
END


if OBJECT_ID(@AnnualReportAggregateDiagnosisValuesTableInTempDb) IS NOT NULL
BEGIN
	set @cmd = N'drop table ' + @AnnualReportAggregateDiagnosisValuesTable collate Cyrillic_General_CI_AS
	exec sp_executesql @cmd
END


if OBJECT_ID(@AnnualReportCaseTableInTempDb) IS NOT NULL
BEGIN
	set @cmd = N'drop table ' + @AnnualReportCaseTable collate Cyrillic_General_CI_AS
	exec sp_executesql @cmd
END


if OBJECT_ID(@AnnualReportCaseDiagnosisTotalValuesTableInTempDb) IS NOT NULL
BEGIN
	set @cmd = N'drop table ' + @AnnualReportCaseDiagnosisTotalValuesTable collate Cyrillic_General_CI_AS
	exec sp_executesql @cmd
END


if OBJECT_ID(@AnnualReportCaseDiagnosis_Age_0_1_TotalValuesTableInTempDb) IS NOT NULL
BEGIN
	set @cmd = N'drop table ' + @AnnualReportCaseDiagnosis_Age_0_1_TotalValuesTable collate Cyrillic_General_CI_AS
	exec sp_executesql @cmd
END


if OBJECT_ID(@AnnualReportCaseDiagnosis_Age_1_4_TotalValuesTableInTempDb) IS NOT NULL
BEGIN
	set @cmd = N'drop table ' + @AnnualReportCaseDiagnosis_Age_1_4_TotalValuesTable collate Cyrillic_General_CI_AS
	exec sp_executesql @cmd
END


if OBJECT_ID(@AnnualReportCaseDiagnosis_Age_5_14_TotalValuesTableInTempDb) IS NOT NULL
BEGIN
	set @cmd = N'drop table ' + @AnnualReportCaseDiagnosis_Age_5_14_TotalValuesTable collate Cyrillic_General_CI_AS
	exec sp_executesql @cmd
END


if OBJECT_ID(@AnnualReportCaseDiagnosis_Age_15_19_TotalValuesTableInTempDb) IS NOT NULL
BEGIN
	set @cmd = N'drop table ' + @AnnualReportCaseDiagnosis_Age_15_19_TotalValuesTable collate Cyrillic_General_CI_AS
	exec sp_executesql @cmd
END


if OBJECT_ID(@AnnualReportCaseDiagnosis_Age_20_29_TotalValuesTableInTempDb) IS NOT NULL
BEGIN
	set @cmd = N'drop table ' + @AnnualReportCaseDiagnosis_Age_20_29_TotalValuesTable collate Cyrillic_General_CI_AS
	exec sp_executesql @cmd
END


if OBJECT_ID(@AnnualReportCaseDiagnosis_Age_30_59_TotalValuesTableInTempDb) IS NOT NULL
BEGIN
	set @cmd = N'drop table ' + @AnnualReportCaseDiagnosis_Age_30_59_TotalValuesTable collate Cyrillic_General_CI_AS
	exec sp_executesql @cmd
END


if OBJECT_ID(@AnnualReportCaseDiagnosis_Age_60_more_TotalValuesTableInTempDb) IS NOT NULL
BEGIN
	set @cmd = N'drop table ' + @AnnualReportCaseDiagnosis_Age_60_more_TotalValuesTable collate Cyrillic_General_CI_AS
	exec sp_executesql @cmd
END


if OBJECT_ID(@AnnualReportCaseDiagnosis_LabTested_TotalValuesTableInTempDb) IS NOT NULL
BEGIN
	set @cmd = N'drop table ' + @AnnualReportCaseDiagnosis_LabTested_TotalValuesTable collate Cyrillic_General_CI_AS
	exec sp_executesql @cmd
END


if OBJECT_ID(@AnnualReportCaseDiagnosis_LabConfirmed_TotalValuesTableInTempDb) IS NOT NULL
BEGIN
	set @cmd = N'drop table ' + @AnnualReportCaseDiagnosis_LabConfirmed_TotalValuesTable collate Cyrillic_General_CI_AS
	exec sp_executesql @cmd
END


if OBJECT_ID(@AnnualReportCaseDiagnosis_TotalConfirmed_TotalValuesTableInTempDb) IS NOT NULL
BEGIN
	set @cmd = N'drop table ' + @AnnualReportCaseDiagnosis_TotalConfirmed_TotalValuesTable collate Cyrillic_General_CI_AS
	exec sp_executesql @cmd
END


if OBJECT_ID(@AnnualReportDiagnosisGroupTableInTempDb) IS NOT NULL
BEGIN
	set @cmd = N'drop table ' + @AnnualReportDiagnosisGroupTable collate Cyrillic_General_CI_AS
	exec sp_executesql @cmd
END



--Create temporary tables

if OBJECT_ID(@reportTableInTempDb) IS NULL
BEGIN
	set @cmd = N'
create table ' + @reportTable + N'
(	idfsBaseReference	BIGINT NOT NULL PRIMARY KEY,
	strDiseaseName		NVARCHAR(300) collate database_default NOT NULL, --46
	strICD10			NVARCHAR(200) collate database_default NULL,	--47
	intAge_0_1			FLOAT NULL,	--7
	intAge_1_4			FLOAT NULL, --8
	intAge_5_14			FLOAT NULL, --9
	intAge_15_19		FLOAT NULL, --10
	intAge_20_29		FLOAT NULL, --11
	intAge_30_59		FLOAT NULL, --12
	intAge_60_more		FLOAT NULL, --13
	intTotal			FLOAT NOT NULL, --14
	intLabTested		FLOAT NULL,		--15
	intLabConfirmed		FLOAT NULL,		--16
	intTotalConfirmed	FLOAT NULL,		--18
	strNameOfRespondent NVARCHAR(200) collate database_default NULL, --1
	strActualAddress	NVARCHAR(200) collate database_default NULL, --2
	strTelephone		NVARCHAR(200) collate database_default NULL, --3
	intOrder			int NOT NULL
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

if OBJECT_ID(@AnnualReportDiagnosisTableInTempDb) IS NULL
BEGIN
	set @cmd = N'
create table ' + @AnnualReportDiagnosisTable + N'
(	idfsDiagnosis		BIGINT NOT NULL PRIMARY KEY,
    blnIsAggregate		BIT,
	intAge_0_1			BIGINT NOT NULL,	--7
	intAge_1_4			BIGINT NOT NULL, --8
	intAge_5_14			BIGINT NOT NULL, --9
	intAge_15_19		BIGINT NOT NULL, --10
	intAge_20_29		BIGINT NOT NULL, --11
	intAge_30_59		BIGINT NOT NULL, --12
	intAge_60_more		BIGINT NOT NULL, --13
	intTotal			BIGINT NOT NULL, --14
	intLabTested		BIGINT NULL,		--15
	intLabConfirmed		BIGINT NULL,		--18
	intTotalConfirmed	BIGINT NULL		--21
)
' collate Cyrillic_General_CI_AS
	exec sp_executesql @cmd
END

if OBJECT_ID(@AnnualReportDiagnosisTableInTempDb) IS NOT NULL
BEGIN
	set @cmd = N'
truncate table ' + @AnnualReportDiagnosisTable collate Cyrillic_General_CI_AS
	exec sp_executesql @cmd
end


if OBJECT_ID(@AnnualReportHumanAggregateCaseInTempDb) IS NULL
BEGIN
	set @cmd = N'
create table ' + @AnnualReportHumanAggregateCase + N'
(	idfAggrCase	BIGINT NOT NULL PRIMARY KEY,
	idfCaseObservation BIGINT,
	datStartDate DATETIME,
	idfVersion BIGINT
)
' collate Cyrillic_General_CI_AS
	exec sp_executesql @cmd
END

if OBJECT_ID(@AnnualReportHumanAggregateCaseInTempDb) IS NOT NULL
BEGIN
	set @cmd = N'
truncate table ' + @AnnualReportHumanAggregateCase collate Cyrillic_General_CI_AS
	exec sp_executesql @cmd
end


if OBJECT_ID(@AnnualReportHumanAggregateCaseRowInTempDb) IS NULL
BEGIN
	set @cmd = N'
create table ' + @AnnualReportHumanAggregateCaseRow + N'
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

if OBJECT_ID(@AnnualReportHumanAggregateCaseRowInTempDb) IS NOT NULL
BEGIN
	set @cmd = N'
truncate table ' + @AnnualReportHumanAggregateCaseRow collate Cyrillic_General_CI_AS
	exec sp_executesql @cmd
end


if OBJECT_ID(@AnnualReportAggregateDiagnosisValuesTableInTempDb) IS NULL
BEGIN
	set @cmd = N'
create table ' + @AnnualReportAggregateDiagnosisValuesTable + N'
(	idfsBaseReference	BIGINT NOT NULL PRIMARY KEY,
	intAge_0_1			BIGINT NOT NULL,	--7
	intAge_1_4			BIGINT NOT NULL, --8
	intAge_5_14			BIGINT NOT NULL, --9
	intAge_15_19		BIGINT NOT NULL, --10
	intAge_20_29		BIGINT NOT NULL, --11
	intAge_30_59		BIGINT NOT NULL, --12
	intAge_60_more		BIGINT NOT NULL, --13
	intTotal			BIGINT NOT NULL, --14
	intLabTested		BIGINT NULL,		--15
	intLabConfirmed		BIGINT NULL,		--18
	intTotalConfirmed	BIGINT NULL		--21
)
' collate Cyrillic_General_CI_AS
	exec sp_executesql @cmd
END

if OBJECT_ID(@AnnualReportAggregateDiagnosisValuesTableInTempDb) IS NOT NULL
BEGIN
	set @cmd = N'
truncate table ' + @AnnualReportAggregateDiagnosisValuesTable collate Cyrillic_General_CI_AS
	exec sp_executesql @cmd
end



if OBJECT_ID(@AnnualReportCaseTableInTempDb) IS NULL
BEGIN
	set @cmd = N'
create table ' + @AnnualReportCaseTable + N'
(	idfsDiagnosis		BIGINT NOT NULL,
	idfCase				BIGINT NOT NULL PRIMARY KEY,
	intYear				INT NULL,
	blnLabTested		BIT,
	blnLabConfirmed		BIT,
	blnLabEpiConfirmed	BIT
)
' collate Cyrillic_General_CI_AS
	exec sp_executesql @cmd
END

if OBJECT_ID(@AnnualReportCaseTableInTempDb) IS NOT NULL
BEGIN
	set @cmd = N'
truncate table ' + @AnnualReportCaseTable collate Cyrillic_General_CI_AS
	exec sp_executesql @cmd
end



if OBJECT_ID(@AnnualReportCaseDiagnosisTotalValuesTableInTempDb) IS NULL
BEGIN
	set @cmd = N'
create table ' + @AnnualReportCaseDiagnosisTotalValuesTable + N'
(	idfsDiagnosis			BIGINT NOT NULL PRIMARY KEY,
	intTotal				BIGINT NOT NULL
)
' collate Cyrillic_General_CI_AS
	exec sp_executesql @cmd
END

if OBJECT_ID(@AnnualReportCaseDiagnosisTotalValuesTableInTempDb) IS NOT NULL
BEGIN
	set @cmd = N'
truncate table ' + @AnnualReportCaseDiagnosisTotalValuesTable collate Cyrillic_General_CI_AS
	exec sp_executesql @cmd
end



if OBJECT_ID(@AnnualReportCaseDiagnosis_Age_0_1_TotalValuesTableInTempDb) IS NULL
BEGIN
	set @cmd = N'
create table ' + @AnnualReportCaseDiagnosis_Age_0_1_TotalValuesTable + N'
(	idfsDiagnosis			BIGINT NOT NULL PRIMARY KEY,
	intAge_0_1				BIGINT NOT NULL
)
' collate Cyrillic_General_CI_AS
	exec sp_executesql @cmd
END

if OBJECT_ID(@AnnualReportCaseDiagnosis_Age_0_1_TotalValuesTableInTempDb) IS NOT NULL
BEGIN
	set @cmd = N'
truncate table ' + @AnnualReportCaseDiagnosis_Age_0_1_TotalValuesTable collate Cyrillic_General_CI_AS
	exec sp_executesql @cmd
end



if OBJECT_ID(@AnnualReportCaseDiagnosis_Age_1_4_TotalValuesTableInTempDb) IS NULL
BEGIN
	set @cmd = N'
create table ' + @AnnualReportCaseDiagnosis_Age_1_4_TotalValuesTable + N'
(	idfsDiagnosis			BIGINT NOT NULL PRIMARY KEY,
	intAge_1_4				BIGINT NOT NULL
)
' collate Cyrillic_General_CI_AS
	exec sp_executesql @cmd
END

if OBJECT_ID(@AnnualReportCaseDiagnosis_Age_1_4_TotalValuesTableInTempDb) IS NOT NULL
BEGIN
	set @cmd = N'
truncate table ' + @AnnualReportCaseDiagnosis_Age_1_4_TotalValuesTable collate Cyrillic_General_CI_AS
	exec sp_executesql @cmd
end



if OBJECT_ID(@AnnualReportCaseDiagnosis_Age_5_14_TotalValuesTableInTempDb) IS NULL
BEGIN
	set @cmd = N'
create table ' + @AnnualReportCaseDiagnosis_Age_5_14_TotalValuesTable + N'
(	idfsDiagnosis			BIGINT NOT NULL PRIMARY KEY,
	intAge_5_14				BIGINT NOT NULL
)
' collate Cyrillic_General_CI_AS
	exec sp_executesql @cmd
END

if OBJECT_ID(@AnnualReportCaseDiagnosis_Age_5_14_TotalValuesTableInTempDb) IS NOT NULL
BEGIN
	set @cmd = N'
truncate table ' + @AnnualReportCaseDiagnosis_Age_5_14_TotalValuesTable collate Cyrillic_General_CI_AS
	exec sp_executesql @cmd
end



if OBJECT_ID(@AnnualReportCaseDiagnosis_Age_15_19_TotalValuesTableInTempDb) IS NULL
BEGIN
	set @cmd = N'
create table ' + @AnnualReportCaseDiagnosis_Age_15_19_TotalValuesTable + N'
(	idfsDiagnosis			BIGINT NOT NULL PRIMARY KEY,
	intAge_15_19			INT NOT NULL
)
' collate Cyrillic_General_CI_AS
	exec sp_executesql @cmd
END

if OBJECT_ID(@AnnualReportCaseDiagnosis_Age_15_19_TotalValuesTableInTempDb) IS NOT NULL
BEGIN
	set @cmd = N'
truncate table ' + @AnnualReportCaseDiagnosis_Age_15_19_TotalValuesTable collate Cyrillic_General_CI_AS
	exec sp_executesql @cmd
end



if OBJECT_ID(@AnnualReportCaseDiagnosis_Age_20_29_TotalValuesTableInTempDb) IS NULL
BEGIN
	set @cmd = N'
create table ' + @AnnualReportCaseDiagnosis_Age_20_29_TotalValuesTable + N'
(	idfsDiagnosis			BIGINT NOT NULL PRIMARY KEY,
	intAge_20_29			BIGINT NOT NULL
)
' collate Cyrillic_General_CI_AS
	exec sp_executesql @cmd
END

if OBJECT_ID(@AnnualReportCaseDiagnosis_Age_20_29_TotalValuesTableInTempDb) IS NOT NULL
BEGIN
	set @cmd = N'
truncate table ' + @AnnualReportCaseDiagnosis_Age_20_29_TotalValuesTable collate Cyrillic_General_CI_AS
	exec sp_executesql @cmd
end



if OBJECT_ID(@AnnualReportCaseDiagnosis_Age_30_59_TotalValuesTableInTempDb) IS NULL
BEGIN
	set @cmd = N'
create table ' + @AnnualReportCaseDiagnosis_Age_30_59_TotalValuesTable + N'
(	idfsDiagnosis			BIGINT NOT NULL PRIMARY KEY,
	intAge_30_59			BIGINT NOT NULL
)
' collate Cyrillic_General_CI_AS
	exec sp_executesql @cmd
END

if OBJECT_ID(@AnnualReportCaseDiagnosis_Age_30_59_TotalValuesTableInTempDb) IS NOT NULL
BEGIN
	set @cmd = N'
truncate table ' + @AnnualReportCaseDiagnosis_Age_30_59_TotalValuesTable collate Cyrillic_General_CI_AS
	exec sp_executesql @cmd
end



if OBJECT_ID(@AnnualReportCaseDiagnosis_Age_60_more_TotalValuesTableInTempDb) IS NULL
BEGIN
	set @cmd = N'
create table ' + @AnnualReportCaseDiagnosis_Age_60_more_TotalValuesTable + N'
(	idfsDiagnosis			BIGINT NOT NULL PRIMARY KEY,
	intAge_60_more			BIGINT NOT NULL
)
' collate Cyrillic_General_CI_AS
	exec sp_executesql @cmd
END

if OBJECT_ID(@AnnualReportCaseDiagnosis_Age_60_more_TotalValuesTableInTempDb) IS NOT NULL
BEGIN
	set @cmd = N'
truncate table ' + @AnnualReportCaseDiagnosis_Age_60_more_TotalValuesTable collate Cyrillic_General_CI_AS
	exec sp_executesql @cmd
end



if OBJECT_ID(@AnnualReportCaseDiagnosis_LabTested_TotalValuesTableInTempDb) IS NULL
BEGIN
	set @cmd = N'
create table ' + @AnnualReportCaseDiagnosis_LabTested_TotalValuesTable + N'
(	idfsDiagnosis			BIGINT NOT NULL PRIMARY KEY,
	intLabTested			BIGINT NOT NULL
)
' collate Cyrillic_General_CI_AS
	exec sp_executesql @cmd
END

if OBJECT_ID(@AnnualReportCaseDiagnosis_LabTested_TotalValuesTableInTempDb) IS NOT NULL
BEGIN
	set @cmd = N'
truncate table ' + @AnnualReportCaseDiagnosis_LabTested_TotalValuesTable collate Cyrillic_General_CI_AS
	exec sp_executesql @cmd
end



if OBJECT_ID(@AnnualReportCaseDiagnosis_LabConfirmed_TotalValuesTableInTempDb) IS NULL
BEGIN
	set @cmd = N'
create table ' + @AnnualReportCaseDiagnosis_LabConfirmed_TotalValuesTable + N'
(	idfsDiagnosis			BIGINT NOT NULL PRIMARY KEY,
	intLabConfirmed			BIGINT NOT NULL
)
' collate Cyrillic_General_CI_AS
	exec sp_executesql @cmd
END

if OBJECT_ID(@AnnualReportCaseDiagnosis_LabConfirmed_TotalValuesTableInTempDb) IS NOT NULL
BEGIN
	set @cmd = N'
truncate table ' + @AnnualReportCaseDiagnosis_LabConfirmed_TotalValuesTable collate Cyrillic_General_CI_AS
	exec sp_executesql @cmd
end



if OBJECT_ID(@AnnualReportCaseDiagnosis_TotalConfirmed_TotalValuesTableInTempDb) IS NULL
BEGIN
	set @cmd = N'
create table ' + @AnnualReportCaseDiagnosis_TotalConfirmed_TotalValuesTable + N'
(	idfsDiagnosis			BIGINT NOT NULL PRIMARY KEY,
	intTotalConfirmed		BIGINT NOT NULL
)
' collate Cyrillic_General_CI_AS
	exec sp_executesql @cmd
END

if OBJECT_ID(@AnnualReportCaseDiagnosis_TotalConfirmed_TotalValuesTableInTempDb) IS NOT NULL
BEGIN
	set @cmd = N'
truncate table ' + @AnnualReportCaseDiagnosis_TotalConfirmed_TotalValuesTable collate Cyrillic_General_CI_AS
	exec sp_executesql @cmd
end



if OBJECT_ID(@AnnualReportDiagnosisGroupTableInTempDb) IS NULL
BEGIN
	set @cmd = N'
create table ' + @AnnualReportDiagnosisGroupTable + N'
(	idfsDiagnosisGroup	BIGINT NOT NULL PRIMARY KEY,
	intAge_0_1			BIGINT NOT NULL,	--7
	intAge_1_4			BIGINT NOT NULL, --8
	intAge_5_14			BIGINT NOT NULL, --9
	intAge_15_19		BIGINT NOT NULL, --10
	intAge_20_29		BIGINT NOT NULL, --11
	intAge_30_59		BIGINT NOT NULL, --12
	intAge_60_more		BIGINT NOT NULL, --13
	intTotal			BIGINT NOT NULL, --14
	intLabTested		BIGINT NULL,		--15
	intLabConfirmed		BIGINT NULL,		--18
	intTotalConfirmed	BIGINT NULL		--21
)
' collate Cyrillic_General_CI_AS
	exec sp_executesql @cmd
END

if OBJECT_ID(@AnnualReportDiagnosisGroupTableInTempDb) IS NOT NULL
BEGIN
	set @cmd = N'
truncate table ' + @AnnualReportDiagnosisGroupTable collate Cyrillic_General_CI_AS
	exec sp_executesql @cmd
end


-- Declare internal variables

DECLARE @idfsCustomReportType BIGINT
DECLARE @idfsLanguage BIGINT
DECLARE @strNameOfRespondent NVARCHAR(200)
DECLARE @strActualAddress NVARCHAR(200)
DECLARE @strTelephone NVARCHAR(200)

DECLARE @idfsSite BIGINT
DECLARE 
    @FFP_Age_0_1 BIGINT,--7
    @FFP_Age_1_4 BIGINT, --8
    @FFP_Age_5_14 BIGINT, --9
    @FFP_Age_15_19 BIGINT, --10
    @FFP_Age_20_29 BIGINT, --11
    @FFP_Age_30_59 BIGINT, --12
    @FFP_Age_60_more BIGINT, --13
    @FFP_Total BIGINT, --14
    @FFP_LabTested BIGINT,		--15
    @FFP_LabConfirmed BIGINT,		--18
    @FFP_TotalConfirmed BIGINT --21

DECLARE @MinAdminLevel BIGINT
DECLARE @MinTimeInterval BIGINT
DECLARE @AggrCaseType BIGINT
DECLARE @idfsCountry BIGINT

declare @CountryNode hierarchyid
declare	@RegionNode hierarchyid
declare @RayonNode hierarchyid

DECLARE @NAValue AS NVARCHAR(10)


-- Retrieve and calculate values for the report

SET @idfsCustomReportType = 10290010 /*GG Annual Form IV–03 Old Revision*/

SET @NAValue = N'Silver'

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


set @cmd = N'
SELECT 
    @strActualAddressOut = [' + @dbName_Actual + N'].Report.FN_REP_AddressSharedString(@LangIDInput, tlbOffice.idfLocation),
    @strTelephoneOut = tlbOffice.strContactPhone,
    @strNameOfRespondentOut = ISNULL(trtStringNameTranslation.strTextString, trtBaseReference.strDefault)
FROM	[' + @dbName_Actual + N'].dbo.tlbOffice
    INNER JOIN	[' + @dbName_Actual + N'].dbo.tstSite
    ON tlbOffice.idfOffice = tstSite.idfOffice
    AND tstSite.intRowStatus = 0

    INNER JOIN [' + @dbName_Actual + N'].dbo.trtBaseReference
    ON tlbOffice.idfsOfficeName = trtBaseReference.idfsBaseReference

    LEFT OUTER JOIN [' + @dbName_Actual + N'].dbo.trtStringNameTranslation
    ON trtBaseReference.idfsBaseReference = trtStringNameTranslation.idfsBaseReference
    AND trtStringNameTranslation.idfsLanguage = @idfsLanguageInput 
    AND trtStringNameTranslation.intRowStatus = 0

WHERE tstSite.idfsSite = @idfsSiteInput AND tlbOffice.intRowStatus = 0
' collate Cyrillic_General_CI_AS
exec sp_executesql @cmd, N'@idfsSiteInput bigint, @idfsLanguageInput bigint, @LangIDInput nvarchar(50), @strActualAddressOut nvarchar(200) output, @strTelephoneOut nvarchar(200) output, @strNameOfRespondentOut nvarchar(200) output',
		@idfsSiteInput = @idfsSite, @idfsLanguageInput = @idfsLanguage, @LangIDInput = @LangID, @strActualAddressOut = @strActualAddress output, @strTelephoneOut = @strTelephone output, @strNameOfRespondentOut = @strNameOfRespondent output


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

select @FFP_TotalOut = idfsFFObject from [' + @dbName_Actual + N'].dbo.trtFFObjectForCustomReport
where idfsCustomReportType = @idfsCustomReportTypeInput and strFFObjectAlias = ''FFP_Total'' collate Cyrillic_General_CI_AS
and intRowStatus = 0

select @FFP_LabTestedOut = idfsFFObject from [' + @dbName_Actual + N'].dbo.trtFFObjectForCustomReport
where idfsCustomReportType = @idfsCustomReportTypeInput and strFFObjectAlias = ''FFP_LabTested'' collate Cyrillic_General_CI_AS
and intRowStatus = 0

select @FFP_LabConfirmedOut = idfsFFObject from [' + @dbName_Actual + N'].dbo.trtFFObjectForCustomReport
where idfsCustomReportType = @idfsCustomReportTypeInput and strFFObjectAlias = ''FFP_LabConfirmed'' collate Cyrillic_General_CI_AS
and intRowStatus = 0

select @FFP_TotalConfirmedOut = idfsFFObject from [' + @dbName_Actual + N'].dbo.trtFFObjectForCustomReport
where idfsCustomReportType = @idfsCustomReportTypeInput and strFFObjectAlias = ''FFP_TotalConfirmed'' collate Cyrillic_General_CI_AS
and intRowStatus = 0
' collate Cyrillic_General_CI_AS
exec sp_executesql @cmd, N'@idfsCustomReportTypeInput bigint, @FFP_Age_0_1Out bigint output, @FFP_Age_1_4Out bigint output, @FFP_Age_5_14Out bigint output, @FFP_Age_15_19Out bigint output, @FFP_Age_20_29Out bigint output, @FFP_Age_30_59Out bigint output, @FFP_Age_60_moreOut bigint output, @FFP_TotalOut bigint output, @FFP_LabTestedOut bigint output, @FFP_LabConfirmedOut bigint output, @FFP_TotalConfirmedOut bigint output',
		@idfsCustomReportTypeInput = @idfsCustomReportType, @FFP_Age_0_1Out = @FFP_Age_0_1 output, @FFP_Age_1_4Out = @FFP_Age_1_4 output, @FFP_Age_5_14Out = @FFP_Age_5_14 output, @FFP_Age_15_19Out = @FFP_Age_15_19 output,
		@FFP_Age_20_29Out = @FFP_Age_20_29 output, @FFP_Age_30_59Out = @FFP_Age_30_59 output, @FFP_Age_60_moreOut = @FFP_Age_60_more output, @FFP_TotalOut = @FFP_Total output, @FFP_LabTestedOut = @FFP_LabTested output,
		@FFP_LabConfirmedOut = @FFP_LabConfirmed output, @FFP_TotalConfirmedOut = @FFP_TotalConfirmed output

-- Report Rows from actual database
set @cmd = N'
INSERT INTO ' + @ReportTable + N'(
	idfsBaseReference,
	strDiseaseName,
	strICD10,
	intAge_0_1,
	intAge_1_4,
	intAge_5_14,
	intAge_15_19,
	intAge_20_29,
	intAge_30_59,
	intAge_60_more,
	intTotal,
	intLabTested,
	intLabConfirmed,
	intTotalConfirmed,
	strNameOfRespondent,
	strActualAddress,
	strTelephone,
	intOrder
) 
SELECT 
  rr.idfsDiagnosisOrReportDiagnosisGroup,
  ISNULL(ISNULL(snt1.strTextString, br1.strDefault) +  N'' '' collate Cyrillic_General_CI_AS, N'''')  + ISNULL(snt.strTextString, br.strDefault) collate Cyrillic_General_CI_AS,
  ISNULL(d.strIDC10, dg.strCode),
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  @strNameOfRespondentInput,
  @strActualAddressInput,
  @strTelephoneInput,
  rr.intRowOrder

  
FROM   [' + @dbName_Actual + N'].dbo.trtReportRows rr
    LEFT JOIN [' + @dbName_Actual + N'].dbo.trtBaseReference br
        LEFT JOIN trtStringNameTranslation snt
        ON br.idfsBaseReference = snt.idfsBaseReference
        AND snt.idfsLanguage = @idfsLanguageInput

        LEFT OUTER JOIN [' + @dbName_Actual + N'].dbo.trtDiagnosis d
        ON br.idfsBaseReference = d.idfsDiagnosis
        
        LEFT OUTER JOIN [' + @dbName_Actual + N'].dbo.trtReportDiagnosisGroup dg
        ON br.idfsBaseReference = dg.idfsReportDiagnosisGroup
    ON rr.idfsDiagnosisOrReportDiagnosisGroup = br.idfsBaseReference
   
    LEFT OUTER JOIN [' + @dbName_Actual + N'].dbo.trtBaseReference br1
        LEFT OUTER JOIN [' + @dbName_Actual + N'].dbo.trtStringNameTranslation snt1
        ON br1.idfsBaseReference = snt1.idfsBaseReference
        AND snt1.idfsLanguage = @idfsLanguageInput
    ON rr.idfsReportAdditionalText = br1.idfsBaseReference
    

WHERE rr.idfsCustomReportType = @idfsCustomReportTypeInput
ORDER BY rr.intRowOrder
' collate Cyrillic_General_CI_AS
exec sp_executesql @cmd, N'@idfsCustomReportTypeInput bigint, @idfsLanguageInput bigint, @strActualAddressInput nvarchar(200), @strTelephoneInput nvarchar(200), @strNameOfRespondentInput nvarchar(200)',
		@idfsCustomReportTypeInput = @idfsCustomReportType, @idfsLanguageInput = @idfsLanguage, 
		@strNameOfRespondentInput = @strNameOfRespondent, @strActualAddressInput = @strActualAddress, @strTelephoneInput = @strTelephone



-- Diagnoses from actual database included in report
set @cmd = N'
INSERT INTO ' + @AnnualReportDiagnosisTable + N' (
	idfsDiagnosis,
	blnIsAggregate,
	intAge_0_1,
	intAge_1_4,
	intAge_5_14,
	intAge_15_19,
	intAge_20_29,
	intAge_30_59,
	intAge_60_more,
	intTotal,
	intLabTested,
	intLabConfirmed,
	intTotalConfirmed
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
  0,
  0,
  0,
  0

FROM [' + @dbName_Actual + N'].dbo.trtDiagnosisToGroupForReportType fdt
    INNER JOIN [' + @dbName_Actual + N'].dbo.trtDiagnosis trtd
    ON trtd.idfsDiagnosis = fdt.idfsDiagnosis
    -- AND trtd.intRowStatus = 0
WHERE  fdt.idfsCustomReportType = @idfsCustomReportTypeInput 

       
       
INSERT INTO '+ @AnnualReportDiagnosisTable + N' (
	idfsDiagnosis,
  blnIsAggregate,
	intAge_0_1,
	intAge_1_4,
	intAge_5_14,
	intAge_15_19,
	intAge_20_29,
	intAge_30_59,
	intAge_60_more,
	intTotal,
	intLabTested,
	intLabConfirmed,
	intTotalConfirmed
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
       SELECT 1 FROM ' + @AnnualReportDiagnosisTable + N'
       WHERE idfsDiagnosis = rr.idfsDiagnosisOrReportDiagnosisGroup
       )
' collate Cyrillic_General_CI_AS
exec sp_executesql @cmd, N'@idfsCustomReportTypeInput bigint',
		@idfsCustomReportTypeInput = @idfsCustomReportType




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
insert into	' + @AnnualReportHumanAggregateCase + N'
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
			and not exists (select 1 from ' + @AnnualReportHumanAggregateCase + N' t where t.idfAggrCase = a.idfAggrCase)
' collate Cyrillic_General_CI_AS
exec sp_executesql @cmd, N'@AggrCaseTypeInput bigint, @idfsCountryInput bigint, @StartDateInput datetime, @FinishDateInput datetime, @MinTimeIntervalInput bigint, @MinAdminLevelInput bigint, @RegionIDInput bigint, @RayonIDInput bigint',
		@AggrCaseTypeInput = @AggrCaseType, @idfsCountryInput = @idfsCountry, @StartDateInput = @StartDate, @FinishDateInput = @FinishDate,
		@MinTimeIntervalInput = @MinTimeInterval, @MinAdminLevelInput = @MinAdminLevel, @RegionIDInput = @RegionID, @RayonIDInput = @RayonID

if @ArchiveExists = 1
begin
-- Aggregate Cases from archive database
	set @cmd = N'
insert into	' + @AnnualReportHumanAggregateCase + N'
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
			and not exists (select 1 from ' + @AnnualReportHumanAggregateCase + N' t where t.idfAggrCase = a.idfAggrCase)
' collate Cyrillic_General_CI_AS
	exec sp_executesql @cmd, N'@AggrCaseTypeInput bigint, @idfsCountryInput bigint, @StartDateInput datetime, @FinishDateInput datetime, @MinTimeIntervalInput bigint, @MinAdminLevelInput bigint, @RegionIDInput bigint, @RayonIDInput bigint',
			@AggrCaseTypeInput = @AggrCaseType, @idfsCountryInput = @idfsCountry, @StartDateInput = @StartDate, @FinishDateInput = @FinishDate,
			@MinTimeIntervalInput = @MinTimeInterval, @MinAdminLevelInput = @MinAdminLevel, @RegionIDInput = @RegionID, @RayonIDInput = @RayonID

end



-- Rows of aggregate case matrices retrieved from actual database for both actual and archived aggregate cases
set @cmd = N'
insert into	' + @AnnualReportHumanAggregateCaseRow + N'
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

from		' + @AnnualReportHumanAggregateCase + N' fhac
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
inner join	' + @AnnualReportDiagnosisTable + N' fdt
on			fdt.idfsDiagnosis = mtx.idfsDiagnosis

' collate Cyrillic_General_CI_AS
--exec sp_executesql @cmd



-- Summarize values from aggregate cases from both actual and archive databases: Age_0_1
--set @cmd = N'
set @cmd = @cmd + N'
insert into	' + @AnnualReportAggregateDiagnosisValuesTable + N'
(	idfsBaseReference,
	intAge_0_1,	--7
	intAge_1_4, --8
	intAge_5_14, --9
	intAge_15_19, --10
	intAge_20_29, --11
	intAge_30_59, --12
	intAge_60_more, --13
	intTotal, --14
	intLabTested,		--15
	intLabConfirmed,		--18
	intTotalConfirmed--21
)
select		
		fhacr.idfsBaseReference,
		sum(CAST(IsNull(val_Age_0_1_actual.varValue, 0) AS bigint))' + case when @ArchiveExists = 1 then N' + sum(CAST(IsNull(val_Age_0_1_archive.varValue, 0) AS bigint))' else N'' end + N',
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0

from		' + @AnnualReportHumanAggregateCaseRow + N' fhacr

outer apply
(	select	top 1 agp_Age_0_1.varValue
	from	[' + @dbName_Actual + N'].dbo.tlbActivityParameters agp_Age_0_1
	where		agp_Age_0_1.idfObservation = fhacr.idfCaseObservation
				and	agp_Age_0_1.idfsParameter = @FFP_Age_0_1Input
				and agp_Age_0_1.idfRow = fhacr.idfRow
				and agp_Age_0_1.intRowStatus = 0
				and SQL_VARIANT_PROPERTY(agp_Age_0_1.varValue, ''BaseType'') in (''bigint'',''decimal'',''float'',''int'',''numeric'',''real'',''smallint'',''tinyint'')
) val_Age_0_1_actual
' collate Cyrillic_General_CI_AS

if @ArchiveExists = 1
begin
	set @cmd = @cmd + N'
outer apply
(	select	top 1 agp_Age_0_1.varValue
	from	[' + @dbName_Archive + N'].dbo.tlbActivityParameters agp_Age_0_1
	where		agp_Age_0_1.idfObservation = fhacr.idfCaseObservation
				and	agp_Age_0_1.idfsParameter = @FFP_Age_0_1Input
				and agp_Age_0_1.idfRow = fhacr.idfRow
				and agp_Age_0_1.intRowStatus = 0
				and SQL_VARIANT_PROPERTY(agp_Age_0_1.varValue, ''BaseType'') in (''bigint'',''decimal'',''float'',''int'',''numeric'',''real'',''smallint'',''tinyint'')
) val_Age_0_1_archive
' collate Cyrillic_General_CI_AS
	
end

set @cmd = @cmd + N'
group by	fhacr.idfsBaseReference

' collate Cyrillic_General_CI_AS
--exec sp_executesql @cmd, N'@FFP_Age_0_1Input bigint',
--		@FFP_Age_0_1Input = @FFP_Age_0_1


-- Summarize values from aggregate cases from both actual and archive databases: Age_1_4
--set @cmd = N'
set @cmd = @cmd + N'
update		aggrV
set			aggrV.intAge_1_4 = isnull(val_Age_1_4.intVal, 0)
from		' + @AnnualReportAggregateDiagnosisValuesTable + N' aggrV
cross apply
(	select		fhacr.idfsBaseReference, sum(CAST(IsNull(val_Age_1_4_actual.varValue, 0) AS bigint))' + case when @ArchiveExists = 1 then N' + sum(CAST(IsNull(val_Age_1_4_archive.varValue, 0) AS bigint))' else N'' end + N' as intVal
	from		' + @AnnualReportHumanAggregateCaseRow + N' fhacr
	--Age_0_1
	outer apply
	(	select	top 1 agp_Age_1_4.varValue
		from	[' + @dbName_Actual + N'].dbo.tlbActivityParameters agp_Age_1_4
		where		agp_Age_1_4.idfObservation = fhacr.idfCaseObservation
					and	agp_Age_1_4.idfsParameter = @FFP_Age_1_4Input
					and agp_Age_1_4.idfRow = fhacr.idfRow
					and agp_Age_1_4.intRowStatus = 0
					and SQL_VARIANT_PROPERTY(agp_Age_1_4.varValue, ''BaseType'') in (''bigint'',''decimal'',''float'',''int'',''numeric'',''real'',''smallint'',''tinyint'')
	) val_Age_1_4_actual
' collate Cyrillic_General_CI_AS


if @ArchiveExists = 1
begin
	set @cmd = @cmd + N'
	outer apply
	(	select	top 1 agp_Age_1_4.varValue
		from	[' + @dbName_Archive + N'].dbo.tlbActivityParameters agp_Age_1_4
		where		agp_Age_1_4.idfObservation = fhacr.idfCaseObservation
					and	agp_Age_1_4.idfsParameter = @FFP_Age_1_4Input
					and agp_Age_1_4.idfRow = fhacr.idfRow
					and agp_Age_1_4.intRowStatus = 0
					and SQL_VARIANT_PROPERTY(agp_Age_1_4.varValue, ''BaseType'') in (''bigint'',''decimal'',''float'',''int'',''numeric'',''real'',''smallint'',''tinyint'')
	) val_Age_1_4_archive
' collate Cyrillic_General_CI_AS
	
end


set @cmd = @cmd + N'
	where		fhacr.idfsBaseReference = aggrV.idfsBaseReference
	group by	fhacr.idfsBaseReference
) val_Age_1_4

' collate Cyrillic_General_CI_AS
--exec sp_executesql @cmd, N'@FFP_Age_1_4Input bigint',
--		@FFP_Age_1_4Input = @FFP_Age_1_4


-- Summarize values from aggregate cases from both actual and archive databases: Age_5_14
--set @cmd = N'
set @cmd = @cmd + N'
update		aggrV
set			aggrV.intAge_5_14 = isnull(val_Age_5_14.intVal, 0)
from		' + @AnnualReportAggregateDiagnosisValuesTable + N' aggrV
cross apply
(	select		fhacr.idfsBaseReference, sum(CAST(IsNull(val_Age_5_14_actual.varValue, 0) AS bigint))' + case when @ArchiveExists = 1 then N' + sum(CAST(IsNull(val_Age_5_14_archive.varValue, 0) AS bigint))' else N'' end + N' as intVal
	from		' + @AnnualReportHumanAggregateCaseRow + N' fhacr
	--Age_0_1
	outer apply
	(	select	top 1 agp_Age_5_14.varValue
		from	[' + @dbName_Actual + N'].dbo.tlbActivityParameters agp_Age_5_14
		where		agp_Age_5_14.idfObservation = fhacr.idfCaseObservation
					and	agp_Age_5_14.idfsParameter = @FFP_Age_5_14Input
					and agp_Age_5_14.idfRow = fhacr.idfRow
					and agp_Age_5_14.intRowStatus = 0
					and SQL_VARIANT_PROPERTY(agp_Age_5_14.varValue, ''BaseType'') in (''bigint'',''decimal'',''float'',''int'',''numeric'',''real'',''smallint'',''tinyint'')
	) val_Age_5_14_actual
' collate Cyrillic_General_CI_AS


if @ArchiveExists = 1
begin
	set @cmd = @cmd + N'
	outer apply
	(	select	top 1 agp_Age_5_14.varValue
		from	[' + @dbName_Archive + N'].dbo.tlbActivityParameters agp_Age_5_14
		where		agp_Age_5_14.idfObservation = fhacr.idfCaseObservation
					and	agp_Age_5_14.idfsParameter = @FFP_Age_5_14Input
					and agp_Age_5_14.idfRow = fhacr.idfRow
					and agp_Age_5_14.intRowStatus = 0
					and SQL_VARIANT_PROPERTY(agp_Age_5_14.varValue, ''BaseType'') in (''bigint'',''decimal'',''float'',''int'',''numeric'',''real'',''smallint'',''tinyint'')
	) val_Age_5_14_archive
' collate Cyrillic_General_CI_AS
	
end


set @cmd = @cmd + N'
	where		fhacr.idfsBaseReference = aggrV.idfsBaseReference
	group by	fhacr.idfsBaseReference
) val_Age_5_14


' collate Cyrillic_General_CI_AS
--exec sp_executesql @cmd, N'@FFP_Age_5_14Input bigint',
--		@FFP_Age_5_14Input = @FFP_Age_5_14


-- Summarize values from aggregate cases from both actual and archive databases: Age_15_19
--set @cmd = N'
set @cmd = @cmd + N'
update		aggrV
set			aggrV.intAge_15_19 = isnull(val_Age_15_19.intVal, 0)
from		' + @AnnualReportAggregateDiagnosisValuesTable + N' aggrV
cross apply
(	select		fhacr.idfsBaseReference, sum(CAST(IsNull(val_Age_15_19_actual.varValue, 0) AS bigint))' + case when @ArchiveExists = 1 then N' + sum(CAST(IsNull(val_Age_15_19_archive.varValue, 0) AS bigint))' else N'' end + N' as intVal
	from		' + @AnnualReportHumanAggregateCaseRow + N' fhacr
	--Age_0_1
	outer apply
	(	select	top 1 agp_Age_15_19.varValue
		from	[' + @dbName_Actual + N'].dbo.tlbActivityParameters agp_Age_15_19
		where		agp_Age_15_19.idfObservation = fhacr.idfCaseObservation
					and	agp_Age_15_19.idfsParameter = @FFP_Age_15_19Input
					and agp_Age_15_19.idfRow = fhacr.idfRow
					and agp_Age_15_19.intRowStatus = 0
					and SQL_VARIANT_PROPERTY(agp_Age_15_19.varValue, ''BaseType'') in (''bigint'',''decimal'',''float'',''int'',''numeric'',''real'',''smallint'',''tinyint'')
	) val_Age_15_19_actual
' collate Cyrillic_General_CI_AS


if @ArchiveExists = 1
begin
	set @cmd = @cmd + N'
	outer apply
	(	select	top 1 agp_Age_15_19.varValue
		from	[' + @dbName_Archive + N'].dbo.tlbActivityParameters agp_Age_15_19
		where		agp_Age_15_19.idfObservation = fhacr.idfCaseObservation
					and	agp_Age_15_19.idfsParameter = @FFP_Age_15_19Input
					and agp_Age_15_19.idfRow = fhacr.idfRow
					and agp_Age_15_19.intRowStatus = 0
					and SQL_VARIANT_PROPERTY(agp_Age_15_19.varValue, ''BaseType'') in (''bigint'',''decimal'',''float'',''int'',''numeric'',''real'',''smallint'',''tinyint'')
	) val_Age_15_19_archive
' collate Cyrillic_General_CI_AS
	
end


set @cmd = @cmd + N'
	where		fhacr.idfsBaseReference = aggrV.idfsBaseReference
	group by	fhacr.idfsBaseReference
) val_Age_15_19


' collate Cyrillic_General_CI_AS
--exec sp_executesql @cmd, N'@FFP_Age_15_19Input bigint',
--		@FFP_Age_15_19Input = @FFP_Age_15_19


-- Summarize values from aggregate cases from both actual and archive databases: Age_20_29
--set @cmd = N'
set @cmd = @cmd + N'
update		aggrV
set			aggrV.intAge_20_29 = isnull(val_Age_20_29.intVal, 0)
from		' + @AnnualReportAggregateDiagnosisValuesTable + N' aggrV
cross apply
(	select		fhacr.idfsBaseReference, sum(CAST(IsNull(val_Age_20_29_actual.varValue, 0) AS bigint))' + case when @ArchiveExists = 1 then N' + sum(CAST(IsNull(val_Age_20_29_archive.varValue, 0) AS bigint))' else N'' end + N' as intVal
	from		' + @AnnualReportHumanAggregateCaseRow + N' fhacr
	--Age_0_1
	outer apply
	(	select	top 1 agp_Age_20_29.varValue
		from	[' + @dbName_Actual + N'].dbo.tlbActivityParameters agp_Age_20_29
		where		agp_Age_20_29.idfObservation = fhacr.idfCaseObservation
					and	agp_Age_20_29.idfsParameter = @FFP_Age_20_29Input
					and agp_Age_20_29.idfRow = fhacr.idfRow
					and agp_Age_20_29.intRowStatus = 0
					and SQL_VARIANT_PROPERTY(agp_Age_20_29.varValue, ''BaseType'') in (''bigint'',''decimal'',''float'',''int'',''numeric'',''real'',''smallint'',''tinyint'')
	) val_Age_20_29_actual
' collate Cyrillic_General_CI_AS


if @ArchiveExists = 1
begin
	set @cmd = @cmd + N'
	outer apply
	(	select	top 1 agp_Age_20_29.varValue
		from	[' + @dbName_Archive + N'].dbo.tlbActivityParameters agp_Age_20_29
		where		agp_Age_20_29.idfObservation = fhacr.idfCaseObservation
					and	agp_Age_20_29.idfsParameter = @FFP_Age_20_29Input
					and agp_Age_20_29.idfRow = fhacr.idfRow
					and agp_Age_20_29.intRowStatus = 0
					and SQL_VARIANT_PROPERTY(agp_Age_20_29.varValue, ''BaseType'') in (''bigint'',''decimal'',''float'',''int'',''numeric'',''real'',''smallint'',''tinyint'')
	) val_Age_20_29_archive
' collate Cyrillic_General_CI_AS
	
end


set @cmd = @cmd + N'
	where		fhacr.idfsBaseReference = aggrV.idfsBaseReference
	group by	fhacr.idfsBaseReference
) val_Age_20_29


' collate Cyrillic_General_CI_AS
--exec sp_executesql @cmd, N'@FFP_Age_20_29Input bigint',
--		@FFP_Age_20_29Input = @FFP_Age_20_29


-- Summarize values from aggregate cases from both actual and archive databases: Age_30_59
--set @cmd = N'
set @cmd = @cmd + N'
update		aggrV
set			aggrV.intAge_30_59 = isnull(val_Age_30_59.intVal, 0)
from		' + @AnnualReportAggregateDiagnosisValuesTable + N' aggrV
cross apply
(	select		fhacr.idfsBaseReference, sum(CAST(IsNull(val_Age_30_59_actual.varValue, 0) AS bigint))' + case when @ArchiveExists = 1 then N' + sum(CAST(IsNull(val_Age_30_59_archive.varValue, 0) AS bigint))' else N'' end + N' as intVal
	from		' + @AnnualReportHumanAggregateCaseRow + N' fhacr
	--Age_0_1
	outer apply
	(	select	top 1 agp_Age_30_59.varValue
		from	[' + @dbName_Actual + N'].dbo.tlbActivityParameters agp_Age_30_59
		where		agp_Age_30_59.idfObservation = fhacr.idfCaseObservation
					and	agp_Age_30_59.idfsParameter = @FFP_Age_30_59Input
					and agp_Age_30_59.idfRow = fhacr.idfRow
					and agp_Age_30_59.intRowStatus = 0
					and SQL_VARIANT_PROPERTY(agp_Age_30_59.varValue, ''BaseType'') in (''bigint'',''decimal'',''float'',''int'',''numeric'',''real'',''smallint'',''tinyint'')
	) val_Age_30_59_actual
' collate Cyrillic_General_CI_AS


if @ArchiveExists = 1
begin
	set @cmd = @cmd + N'
	outer apply
	(	select	top 1 agp_Age_30_59.varValue
		from	[' + @dbName_Archive + N'].dbo.tlbActivityParameters agp_Age_30_59
		where		agp_Age_30_59.idfObservation = fhacr.idfCaseObservation
					and	agp_Age_30_59.idfsParameter = @FFP_Age_30_59Input
					and agp_Age_30_59.idfRow = fhacr.idfRow
					and agp_Age_30_59.intRowStatus = 0
					and SQL_VARIANT_PROPERTY(agp_Age_30_59.varValue, ''BaseType'') in (''bigint'',''decimal'',''float'',''int'',''numeric'',''real'',''smallint'',''tinyint'')
	) val_Age_30_59_archive
' collate Cyrillic_General_CI_AS
	
end


set @cmd = @cmd + N'
	where		fhacr.idfsBaseReference = aggrV.idfsBaseReference
	group by	fhacr.idfsBaseReference
) val_Age_30_59


' collate Cyrillic_General_CI_AS
--exec sp_executesql @cmd, N'@FFP_Age_30_59Input bigint',
--		@FFP_Age_30_59Input = @FFP_Age_30_59


-- Summarize values from aggregate cases from both actual and archive databases: Age_60_more
--set @cmd = N'
set @cmd = @cmd + N'
update		aggrV
set			aggrV.intAge_60_more = isnull(val_Age_60_more.intVal, 0)
from		' + @AnnualReportAggregateDiagnosisValuesTable + N' aggrV
cross apply
(	select		fhacr.idfsBaseReference, sum(CAST(IsNull(val_Age_60_more_actual.varValue, 0) AS bigint))' + case when @ArchiveExists = 1 then N' + sum(CAST(IsNull(val_Age_60_more_archive.varValue, 0) AS bigint))' else N'' end + N' as intVal
	from		' + @AnnualReportHumanAggregateCaseRow + N' fhacr
	--Age_0_1
	outer apply
	(	select	top 1 agp_Age_60_more.varValue
		from	[' + @dbName_Actual + N'].dbo.tlbActivityParameters agp_Age_60_more
		where		agp_Age_60_more.idfObservation = fhacr.idfCaseObservation
					and	agp_Age_60_more.idfsParameter = @FFP_Age_60_moreInput
					and agp_Age_60_more.idfRow = fhacr.idfRow
					and agp_Age_60_more.intRowStatus = 0
					and SQL_VARIANT_PROPERTY(agp_Age_60_more.varValue, ''BaseType'') in (''bigint'',''decimal'',''float'',''int'',''numeric'',''real'',''smallint'',''tinyint'')
	) val_Age_60_more_actual
' collate Cyrillic_General_CI_AS


if @ArchiveExists = 1
begin
	set @cmd = @cmd + N'
	outer apply
	(	select	top 1 agp_Age_60_more.varValue
		from	[' + @dbName_Archive + N'].dbo.tlbActivityParameters agp_Age_60_more
		where		agp_Age_60_more.idfObservation = fhacr.idfCaseObservation
					and	agp_Age_60_more.idfsParameter = @FFP_Age_60_moreInput
					and agp_Age_60_more.idfRow = fhacr.idfRow
					and agp_Age_60_more.intRowStatus = 0
					and SQL_VARIANT_PROPERTY(agp_Age_60_more.varValue, ''BaseType'') in (''bigint'',''decimal'',''float'',''int'',''numeric'',''real'',''smallint'',''tinyint'')
	) val_Age_60_more_archive
' collate Cyrillic_General_CI_AS
	
end


set @cmd = @cmd + N'
	where		fhacr.idfsBaseReference = aggrV.idfsBaseReference
	group by	fhacr.idfsBaseReference
) val_Age_60_more


' collate Cyrillic_General_CI_AS
--exec sp_executesql @cmd, N'@FFP_Age_60_moreInput bigint',
--		@FFP_Age_60_moreInput = @FFP_Age_60_more


-- Summarize values from aggregate cases from both actual and archive databases: Total
--set @cmd = N'
set @cmd = @cmd + N'
update		aggrV
set			aggrV.intTotal = isnull(val_Total.intVal, 0)
from		' + @AnnualReportAggregateDiagnosisValuesTable + N' aggrV
cross apply
(	select		fhacr.idfsBaseReference, sum(CAST(IsNull(val_Total_actual.varValue, 0) AS bigint))' + case when @ArchiveExists = 1 then N' + sum(CAST(IsNull(val_Total_archive.varValue, 0) AS bigint))' else N'' end + N' as intVal
	from		' + @AnnualReportHumanAggregateCaseRow + N' fhacr
	--Age_0_1
	outer apply
	(	select	top 1 agp_Total.varValue
		from	[' + @dbName_Actual + N'].dbo.tlbActivityParameters agp_Total
		where		agp_Total.idfObservation = fhacr.idfCaseObservation
					and	agp_Total.idfsParameter = @FFP_TotalInput
					and agp_Total.idfRow = fhacr.idfRow
					and agp_Total.intRowStatus = 0
					and SQL_VARIANT_PROPERTY(agp_Total.varValue, ''BaseType'') in (''bigint'',''decimal'',''float'',''int'',''numeric'',''real'',''smallint'',''tinyint'')
	) val_Total_actual
' collate Cyrillic_General_CI_AS


if @ArchiveExists = 1
begin
	set @cmd = @cmd + N'
	outer apply
	(	select	top 1 agp_Total.varValue
		from	[' + @dbName_Archive + N'].dbo.tlbActivityParameters agp_Total
		where		agp_Total.idfObservation = fhacr.idfCaseObservation
					and	agp_Total.idfsParameter = @FFP_TotalInput
					and agp_Total.idfRow = fhacr.idfRow
					and agp_Total.intRowStatus = 0
					and SQL_VARIANT_PROPERTY(agp_Total.varValue, ''BaseType'') in (''bigint'',''decimal'',''float'',''int'',''numeric'',''real'',''smallint'',''tinyint'')
	) val_Total_archive
' collate Cyrillic_General_CI_AS
	
end


set @cmd = @cmd + N'
	where		fhacr.idfsBaseReference = aggrV.idfsBaseReference
	group by	fhacr.idfsBaseReference
) val_Total


' collate Cyrillic_General_CI_AS
--exec sp_executesql @cmd, N'@FFP_TotalInput bigint',
--		@FFP_TotalInput = @FFP_Total


-- Summarize values from aggregate cases from both actual and archive databases: LabTested
--set @cmd = N'
set @cmd = @cmd + N'
update		aggrV
set			aggrV.intLabTested = isnull(val_LabTested.intVal, 0)
from		' + @AnnualReportAggregateDiagnosisValuesTable + N' aggrV
cross apply
(	select		fhacr.idfsBaseReference, sum(CAST(IsNull(val_LabTested_actual.varValue, 0) AS bigint))' + case when @ArchiveExists = 1 then N' + sum(CAST(IsNull(val_LabTested_archive.varValue, 0) AS bigint))' else N'' end + N' as intVal
	from		' + @AnnualReportHumanAggregateCaseRow + N' fhacr
	--Age_0_1
	outer apply
	(	select	top 1 agp_LabTested.varValue
		from	[' + @dbName_Actual + N'].dbo.tlbActivityParameters agp_LabTested
		where		agp_LabTested.idfObservation = fhacr.idfCaseObservation
					and	agp_LabTested.idfsParameter = @FFP_LabTestedInput
					and agp_LabTested.idfRow = fhacr.idfRow
					and agp_LabTested.intRowStatus = 0
					and SQL_VARIANT_PROPERTY(agp_LabTested.varValue, ''BaseType'') in (''bigint'',''decimal'',''float'',''int'',''numeric'',''real'',''smallint'',''tinyint'')
	) val_LabTested_actual
' collate Cyrillic_General_CI_AS


if @ArchiveExists = 1
begin
	set @cmd = @cmd + N'
	outer apply
	(	select	top 1 agp_LabTested.varValue
		from	[' + @dbName_Archive + N'].dbo.tlbActivityParameters agp_LabTested
		where		agp_LabTested.idfObservation = fhacr.idfCaseObservation
					and	agp_LabTested.idfsParameter = @FFP_LabTestedInput
					and agp_LabTested.idfRow = fhacr.idfRow
					and agp_LabTested.intRowStatus = 0
					and SQL_VARIANT_PROPERTY(agp_LabTested.varValue, ''BaseType'') in (''bigint'',''decimal'',''float'',''int'',''numeric'',''real'',''smallint'',''tinyint'')
	) val_LabTested_archive
' collate Cyrillic_General_CI_AS
	
end


set @cmd = @cmd + N'
	where		fhacr.idfsBaseReference = aggrV.idfsBaseReference
	group by	fhacr.idfsBaseReference
) val_LabTested


' collate Cyrillic_General_CI_AS
--exec sp_executesql @cmd, N'@FFP_LabTestedInput bigint',
--		@FFP_LabTestedInput = @FFP_LabTested


-- Summarize values from aggregate cases from both actual and archive databases: LabConfirmed
--set @cmd = N'
set @cmd = @cmd + N'
update		aggrV
set			aggrV.intLabConfirmed = isnull(val_LabConfirmed.intVal, 0)
from		' + @AnnualReportAggregateDiagnosisValuesTable + N' aggrV
cross apply
(	select		fhacr.idfsBaseReference, sum(CAST(IsNull(val_LabConfirmed_actual.varValue, 0) AS bigint))' + case when @ArchiveExists = 1 then N' + sum(CAST(IsNull(val_LabConfirmed_archive.varValue, 0) AS bigint))' else N'' end + N' as intVal
	from		' + @AnnualReportHumanAggregateCaseRow + N' fhacr
	--Age_0_1
	outer apply
	(	select	top 1 agp_LabConfirmed.varValue
		from	[' + @dbName_Actual + N'].dbo.tlbActivityParameters agp_LabConfirmed
		where		agp_LabConfirmed.idfObservation = fhacr.idfCaseObservation
					and	agp_LabConfirmed.idfsParameter = @FFP_LabConfirmedInput
					and agp_LabConfirmed.idfRow = fhacr.idfRow
					and agp_LabConfirmed.intRowStatus = 0
					and SQL_VARIANT_PROPERTY(agp_LabConfirmed.varValue, ''BaseType'') in (''bigint'',''decimal'',''float'',''int'',''numeric'',''real'',''smallint'',''tinyint'')
	) val_LabConfirmed_actual
' collate Cyrillic_General_CI_AS


if @ArchiveExists = 1
begin
	set @cmd = @cmd + N'
	outer apply
	(	select	top 1 agp_LabConfirmed.varValue
		from	[' + @dbName_Archive + N'].dbo.tlbActivityParameters agp_LabConfirmed
		where		agp_LabConfirmed.idfObservation = fhacr.idfCaseObservation
					and	agp_LabConfirmed.idfsParameter = @FFP_LabConfirmedInput
					and agp_LabConfirmed.idfRow = fhacr.idfRow
					and agp_LabConfirmed.intRowStatus = 0
					and SQL_VARIANT_PROPERTY(agp_LabConfirmed.varValue, ''BaseType'') in (''bigint'',''decimal'',''float'',''int'',''numeric'',''real'',''smallint'',''tinyint'')
	) val_LabConfirmed_archive
' collate Cyrillic_General_CI_AS
	
end


set @cmd = @cmd + N'
	where		fhacr.idfsBaseReference = aggrV.idfsBaseReference
	group by	fhacr.idfsBaseReference
) val_LabConfirmed


' collate Cyrillic_General_CI_AS
--exec sp_executesql @cmd, N'@FFP_LabConfirmedInput bigint',
--		@FFP_LabConfirmedInput = @FFP_LabConfirmed


-- Summarize values from aggregate cases from both actual and archive databases: TotalConfirmed
--set @cmd = N'
set @cmd = @cmd + N'
update		aggrV
set			aggrV.intTotalConfirmed = isnull(val_TotalConfirmed.intVal, 0)
from		' + @AnnualReportAggregateDiagnosisValuesTable + N' aggrV
cross apply
(	select		fhacr.idfsBaseReference, sum(CAST(IsNull(val_TotalConfirmed_actual.varValue, 0) AS bigint))' + case when @ArchiveExists = 1 then N' + sum(CAST(IsNull(val_TotalConfirmed_archive.varValue, 0) AS bigint))' else N'' end + N' as intVal
	from		' + @AnnualReportHumanAggregateCaseRow + N' fhacr
	--Age_0_1
	outer apply
	(	select	top 1 agp_TotalConfirmed.varValue
		from	[' + @dbName_Actual + N'].dbo.tlbActivityParameters agp_TotalConfirmed
		where		agp_TotalConfirmed.idfObservation = fhacr.idfCaseObservation
					and	agp_TotalConfirmed.idfsParameter = @FFP_TotalConfirmedInput
					and agp_TotalConfirmed.idfRow = fhacr.idfRow
					and agp_TotalConfirmed.intRowStatus = 0
					and SQL_VARIANT_PROPERTY(agp_TotalConfirmed.varValue, ''BaseType'') in (''bigint'',''decimal'',''float'',''int'',''numeric'',''real'',''smallint'',''tinyint'')
	) val_TotalConfirmed_actual
' collate Cyrillic_General_CI_AS


if @ArchiveExists = 1
begin
	set @cmd = @cmd + N'
	outer apply
	(	select	top 1 agp_TotalConfirmed.varValue
		from	[' + @dbName_Archive + N'].dbo.tlbActivityParameters agp_TotalConfirmed
		where		agp_TotalConfirmed.idfObservation = fhacr.idfCaseObservation
					and	agp_TotalConfirmed.idfsParameter = @FFP_TotalConfirmedInput
					and agp_TotalConfirmed.idfRow = fhacr.idfRow
					and agp_TotalConfirmed.intRowStatus = 0
					and SQL_VARIANT_PROPERTY(agp_TotalConfirmed.varValue, ''BaseType'') in (''bigint'',''decimal'',''float'',''int'',''numeric'',''real'',''smallint'',''tinyint'')
	) val_TotalConfirmed_archive
' collate Cyrillic_General_CI_AS
	
end


set @cmd = @cmd + N'
	where		fhacr.idfsBaseReference = aggrV.idfsBaseReference
	group by	fhacr.idfsBaseReference
) val_TotalConfirmed


' collate Cyrillic_General_CI_AS
--exec sp_executesql @cmd, N'@FFP_TotalConfirmedInput bigint',
--		@FFP_TotalConfirmedInput = @FFP_TotalConfirmed
exec sp_executesql @cmd, N'@FFP_Age_0_1Input bigint, @FFP_Age_1_4Input bigint, @FFP_Age_5_14Input bigint, @FFP_Age_15_19Input bigint, @FFP_Age_20_29Input bigint, @FFP_Age_30_59Input bigint, @FFP_Age_60_moreInput bigint, @FFP_TotalInput bigint, @FFP_LabTestedInput bigint, @FFP_LabConfirmedInput bigint, @FFP_TotalConfirmedInput bigint',
		@FFP_Age_0_1Input = @FFP_Age_0_1, @FFP_Age_1_4Input = @FFP_Age_1_4, @FFP_Age_5_14Input = @FFP_Age_5_14,
		@FFP_Age_15_19Input = @FFP_Age_15_19, @FFP_Age_20_29Input = @FFP_Age_20_29, @FFP_Age_30_59Input = @FFP_Age_30_59, @FFP_Age_60_moreInput = @FFP_Age_60_more, 
		@FFP_TotalInput = @FFP_Total, @FFP_LabTestedInput = @FFP_LabTested, @FFP_LabConfirmedInput = @FFP_LabConfirmed, @FFP_TotalConfirmedInput = @FFP_TotalConfirmed



-- Human Cases from actual database
set @cmd = N'
insert into	' + @AnnualReportCaseTable + N'
(	idfsDiagnosis,
	idfCase,
	intYear,
	blnLabTested,
	blnLabConfirmed,
	blnLabEpiConfirmed
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
			end,
			case when hc.idfsYNTestsConducted = 10100001 then 1 else 0 end,
			CASE 
			  WHEN  hc.blnLabDiagBasis = 1 and 
			        hc.idfsYNTestsConducted = 10100001 and 
			        (
			          hc.idfsFinalCaseStatus = 350000000 /*Confirmed Case*/ or
			          (hc.idfsFinalCaseStatus is null and 
			          hc.idfsInitialCaseStatus = 350000000 /*Confirmed Case*/) 
			        )
			  THEN 1 ELSE 0 
			END,
			CASE 
			  WHEN ( (hc.blnLabDiagBasis = 1 and hc.idfsYNTestsConducted = 10100001)  or  
			          hc.blnEpiDiagBasis = 1) 
			       and
			       (
			          hc.idfsFinalCaseStatus = 350000000 /*Confirmed Case*/ or
			          (hc.idfsFinalCaseStatus is null and 
			          hc.idfsInitialCaseStatus = 350000000 /*Confirmed Case*/) 
			       )			        
			  THEN 1 ELSE 0 
			END
' collate Cyrillic_General_CI_AS
set @cmd = @cmd + N'
FROM [' + @dbName_Actual + N'].dbo.tlbHumanCase hc

    INNER JOIN	' + @AnnualReportDiagnosisTable + N' fdt
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
	and not exists (select 1 from ' + @AnnualReportCaseTable + N' t where t.idfCase = hc.idfHumanCase)
' collate Cyrillic_General_CI_AS
exec sp_executesql @cmd, N'@idfsCountryInput bigint, @CountryNodeInput hierarchyid, @StartDateInput datetime, @FinishDateInput datetime, @RegionIDInput bigint, @RegionNodeInput hierarchyid, @RayonIDInput bigint, @RayonNodeInput hierarchyid',
		@idfsCountryInput = @idfsCountry, @CountryNodeInput = @CountryNode, @StartDateInput = @StartDate, @FinishDateInput = @FinishDate,
		@RegionIDInput = @RegionID, @RegionNodeInput = @RegionNode, @RayonIDInput = @RayonID, @RayonNodeInput = @RayonNode

if @ArchiveExists = 1
begin
-- Human Cases from archive database
	set @cmd = N'
insert into	' + @AnnualReportCaseTable + N'
(	idfsDiagnosis,
	idfCase,
	intYear,
	blnLabTested,
	blnLabConfirmed,
	blnLabEpiConfirmed
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
			end,
			case when hc.idfsYNTestsConducted = 10100001 then 1 else 0 end,
			CASE 
			  WHEN  hc.blnLabDiagBasis = 1 and 
			        hc.idfsYNTestsConducted = 10100001 and 
			        (
			          hc.idfsFinalCaseStatus = 350000000 /*Confirmed Case*/ or
			          (hc.idfsFinalCaseStatus is null and 
			          hc.idfsInitialCaseStatus = 350000000 /*Confirmed Case*/) 
			        )
			  THEN 1 ELSE 0 
			END,
			CASE 
			  WHEN ( (hc.blnLabDiagBasis = 1 and hc.idfsYNTestsConducted = 10100001)  or  
			          hc.blnEpiDiagBasis = 1) 
			       and
			       (
			          hc.idfsFinalCaseStatus = 350000000 /*Confirmed Case*/ or
			          (hc.idfsFinalCaseStatus is null and 
			          hc.idfsInitialCaseStatus = 350000000 /*Confirmed Case*/) 
			       )			        
			  THEN 1 ELSE 0 
			END
' collate Cyrillic_General_CI_AS
	set @cmd = @cmd + N'
FROM [' + @dbName_Archive + N'].dbo.tlbHumanCase hc

    INNER JOIN	' + @AnnualReportDiagnosisTable + N' fdt
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
	and not exists (select 1 from ' + @AnnualReportCaseTable + N' t where t.idfCase = hc.idfHumanCase)
' collate Cyrillic_General_CI_AS
	exec sp_executesql @cmd, N'@idfsCountryInput bigint, @CountryNodeInput hierarchyid, @StartDateInput datetime, @FinishDateInput datetime, @RegionIDInput bigint, @RegionNodeInput hierarchyid, @RayonIDInput bigint, @RayonNodeInput hierarchyid',
			@idfsCountryInput = @idfsCountry, @CountryNodeInput = @CountryNode, @StartDateInput = @StartDate, @FinishDateInput = @FinishDate,
			@RegionIDInput = @RegionID, @RegionNodeInput = @RegionNode, @RayonIDInput = @RayonID, @RayonNodeInput = @RayonNode
end


-- Summarize values from human cases: Total
set @cmd = N'
insert into	' + @AnnualReportCaseDiagnosisTotalValuesTable + N'
(	idfsDiagnosis,
	intTotal
)
SELECT fct.idfsDiagnosis,
			count(fct.idfCase)
from		' + @AnnualReportCaseTable + N' fct
group by	fct.idfsDiagnosis
' collate Cyrillic_General_CI_AS





-- Summarize values from human cases: Total Age_0_1
set @cmd = @cmd + N'
insert into	' + @AnnualReportCaseDiagnosis_Age_0_1_TotalValuesTable + N'
(	idfsDiagnosis,
	intAge_0_1
)
select		fct.idfsDiagnosis,
			count(fct.idfCase)
from		' + @AnnualReportCaseTable + N' fct
where		(fct.intYear >= 0 and fct.intYear < 1)
group by	fct.idfsDiagnosis
' collate Cyrillic_General_CI_AS



-- Summarize values from human cases: Total Age_1_4
set @cmd = @cmd + N'
insert into	' + @AnnualReportCaseDiagnosis_Age_1_4_TotalValuesTable + N'
(	idfsDiagnosis,
	intAge_1_4
)
select		fct.idfsDiagnosis,
			count(fct.idfCase)
from		' + @AnnualReportCaseTable + N' fct
where		(fct.intYear >= 1 and fct.intYear <= 4)
group by	fct.idfsDiagnosis
' collate Cyrillic_General_CI_AS



-- Summarize values from human cases: Total Age_5_14
set @cmd = @cmd + N'
insert into	' + @AnnualReportCaseDiagnosis_Age_5_14_TotalValuesTable + N'
(	idfsDiagnosis,
	intAge_5_14
)
select		fct.idfsDiagnosis,
			count(fct.idfCase)
from		' + @AnnualReportCaseTable + N' fct
where		(fct.intYear >= 5 and fct.intYear <= 14)
group by	fct.idfsDiagnosis
' collate Cyrillic_General_CI_AS



-- Summarize values from human cases: Total Age_15_19
set @cmd = @cmd + N'
insert into	' + @AnnualReportCaseDiagnosis_Age_15_19_TotalValuesTable + N'
(	idfsDiagnosis,
	intAge_15_19
)
select		fct.idfsDiagnosis,
			count(fct.idfCase)
from		' + @AnnualReportCaseTable + N' fct
where		(fct.intYear >= 15 and fct.intYear <= 19)
group by	fct.idfsDiagnosis
' collate Cyrillic_General_CI_AS


-- Summarize values from human cases: Total Age_20_29
set @cmd = @cmd + N'
insert into	' + @AnnualReportCaseDiagnosis_Age_20_29_TotalValuesTable + N'
(	idfsDiagnosis,
	intAge_20_29
)
select		fct.idfsDiagnosis,
			count(fct.idfCase)
from		' + @AnnualReportCaseTable + N' fct
where		(fct.intYear >= 20 and fct.intYear <= 29)
group by	fct.idfsDiagnosis
' collate Cyrillic_General_CI_AS



-- Summarize values from human cases: Total Age_30_59
set @cmd = @cmd + N'
insert into	' + @AnnualReportCaseDiagnosis_Age_30_59_TotalValuesTable + N'
(	idfsDiagnosis,
	intAge_30_59
)
select		fct.idfsDiagnosis,
			count(fct.idfCase)
from		' + @AnnualReportCaseTable + N' fct
where		(fct.intYear >= 30 and fct.intYear <= 59)
group by	fct.idfsDiagnosis
' collate Cyrillic_General_CI_AS


-- Summarize values from human cases: Total Age_60_more
set @cmd = @cmd + N'
insert into	' + @AnnualReportCaseDiagnosis_Age_60_more_TotalValuesTable + N'
(	idfsDiagnosis,
	intAge_60_more
)
select		fct.idfsDiagnosis,
			count(fct.idfCase)
from		' + @AnnualReportCaseTable + N' fct
where		(fct.intYear >= 60)
group by	fct.idfsDiagnosis
' collate Cyrillic_General_CI_AS


-- Summarize values from human cases: Total LabTested 
set @cmd = @cmd + N'
insert into	' + @AnnualReportCaseDiagnosis_LabTested_TotalValuesTable + N'
(	idfsDiagnosis,
	intLabTested
)
select		fct.idfsDiagnosis,
			count(fct.idfCase)
from		' + @AnnualReportCaseTable + N' fct
where		fct.blnLabTested = 1
group by	fct.idfsDiagnosis
' collate Cyrillic_General_CI_AS



-- Summarize values from human cases: Total LabConfirmed 
set @cmd = @cmd + N'
insert into	' + @AnnualReportCaseDiagnosis_LabConfirmed_TotalValuesTable + N'
(	idfsDiagnosis,
	intLabConfirmed
)
select		fct.idfsDiagnosis,
			count(fct.idfCase)
from		' + @AnnualReportCaseTable + N' fct
where		fct.blnLabConfirmed = 1
group by	fct.idfsDiagnosis
' collate Cyrillic_General_CI_AS



-- Summarize values from human cases: Total TotalConfirmed
set @cmd = @cmd + N'
insert into	' + @AnnualReportCaseDiagnosis_TotalConfirmed_TotalValuesTable + N'
(	idfsDiagnosis,
	intTotalConfirmed
)
select		fct.idfsDiagnosis,
			count(fct.idfCase)
from		' + @AnnualReportCaseTable + N' fct
where		fct.blnLabEpiConfirmed = 1
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
	fdt.intTotal = fadvt.intTotal,	
	fdt.intLabTested = fadvt.intLabTested,	
	fdt.intLabConfirmed = fadvt.intLabConfirmed,	
	fdt.intTotalConfirmed = fadvt.intTotalConfirmed		
from		' + @AnnualReportDiagnosisTable + N' fdt
    inner join	' + @AnnualReportAggregateDiagnosisValuesTable + N' fadvt
    on			fadvt.idfsBaseReference = fdt.idfsDiagnosis
--where		fdt.blnIsAggregate = 1
' collate Cyrillic_General_CI_AS


-- Add summarized value for diagnoses from human cases: Total
set @cmd = @cmd + N'
update		fdt
set			fdt.intTotal = isnull (fdt.intTotal, 0) + fcdvt.intTotal
from		' + @AnnualReportDiagnosisTable + N' fdt
inner join	' + @AnnualReportCaseDiagnosisTotalValuesTable + N' fcdvt
on			fcdvt.idfsDiagnosis = fdt.idfsDiagnosis
--where		fdt.blnIsAggregate = 0
' collate Cyrillic_General_CI_AS

-- Add summarized value for diagnoses from human cases: Total Age_0_1
set @cmd = @cmd + N'
update		fdt
set			fdt.intAge_0_1 =isnull (fdt.intAge_0_1, 0) +  fcdvt.intAge_0_1
from		' + @AnnualReportDiagnosisTable + N' fdt
inner join	' + @AnnualReportCaseDiagnosis_Age_0_1_TotalValuesTable + N' fcdvt
on			fcdvt.idfsDiagnosis = fdt.idfsDiagnosis
--where		fdt.blnIsAggregate = 0
' collate Cyrillic_General_CI_AS

-- Add summarized value for diagnoses from human cases: Total Age_1_4
set @cmd = @cmd + N'
update		fdt
set			fdt.intAge_1_4 = isnull (fdt.intAge_1_4, 0) + fcdvt.intAge_1_4
from		' + @AnnualReportDiagnosisTable + N' fdt
inner join	' + @AnnualReportCaseDiagnosis_Age_1_4_TotalValuesTable + N' fcdvt
on			fcdvt.idfsDiagnosis = fdt.idfsDiagnosis
--where		fdt.blnIsAggregate = 0
' collate Cyrillic_General_CI_AS

-- Add summarized value for diagnoses from human cases: Total Age_5_14
set @cmd = @cmd + N'
update		fdt
set			fdt.intAge_5_14 = isnull (fdt.intAge_5_14, 0) + fcdvt.intAge_5_14
from		' + @AnnualReportDiagnosisTable + N' fdt
inner join	' + @AnnualReportCaseDiagnosis_Age_5_14_TotalValuesTable + N' fcdvt
on			fcdvt.idfsDiagnosis = fdt.idfsDiagnosis
--where		fdt.blnIsAggregate = 0
' collate Cyrillic_General_CI_AS

-- Add summarized value for diagnoses from human cases: Total Age_15_19
set @cmd = @cmd + N'
update		fdt
set			fdt.intAge_15_19 = isnull (fdt.intAge_15_19, 0) + fcdvt.intAge_15_19
from		' + @AnnualReportDiagnosisTable + N' fdt
inner join	' + @AnnualReportCaseDiagnosis_Age_15_19_TotalValuesTable + N' fcdvt
on			fcdvt.idfsDiagnosis = fdt.idfsDiagnosis
--where		fdt.blnIsAggregate = 0	
' collate Cyrillic_General_CI_AS

-- Add summarized value for diagnoses from human cases: Total Age_20_29
set @cmd = @cmd + N'
update		fdt
set			fdt.intAge_20_29 = isnull (fdt.intAge_20_29, 0) + fcdvt.intAge_20_29
from		' + @AnnualReportDiagnosisTable + N' fdt
inner join	' + @AnnualReportCaseDiagnosis_Age_20_29_TotalValuesTable + N' fcdvt
on			fcdvt.idfsDiagnosis = fdt.idfsDiagnosis
--where		fdt.blnIsAggregate = 0		
' collate Cyrillic_General_CI_AS

-- Add summarized value for diagnoses from human cases: Total Age_30_59
set @cmd = @cmd + N'
update		fdt
set			fdt.intAge_30_59 = isnull (fdt.intAge_30_59, 0) + fcdvt.intAge_30_59
from		' + @AnnualReportDiagnosisTable + N' fdt
inner join	' + @AnnualReportCaseDiagnosis_Age_30_59_TotalValuesTable + N' fcdvt
on			fcdvt.idfsDiagnosis = fdt.idfsDiagnosis
--where		fdt.blnIsAggregate = 0		
' collate Cyrillic_General_CI_AS

-- Add summarized value for diagnoses from human cases: Total Age_60_more
set @cmd = @cmd + N'
update		fdt
set			fdt.intAge_60_more = isnull (fdt.intAge_60_more, 0) + fcdvt.intAge_60_more
from		' + @AnnualReportDiagnosisTable + N' fdt
inner join	' + @AnnualReportCaseDiagnosis_Age_60_more_TotalValuesTable + N' fcdvt
on			fcdvt.idfsDiagnosis = fdt.idfsDiagnosis
--where		fdt.blnIsAggregate = 0		
' collate Cyrillic_General_CI_AS
	
-- Add summarized value for diagnoses from human cases: Total LabTested
set @cmd = @cmd + N'
update		fdt
set			fdt.intLabTested = isnull (fdt.intLabTested, 0) + fcdvt.intLabTested
from		' + @AnnualReportDiagnosisTable + N' fdt
inner join	' + @AnnualReportCaseDiagnosis_LabTested_TotalValuesTable + N' fcdvt
on			fcdvt.idfsDiagnosis = fdt.idfsDiagnosis
--where		fdt.blnIsAggregate = 0		
' collate Cyrillic_General_CI_AS
	
-- Add summarized value for diagnoses from human cases: Total LabConfirmed
set @cmd = @cmd + N'
update		fdt
set			fdt.intLabConfirmed = isnull (fdt.intLabConfirmed, 0) + fcdvt.intLabConfirmed
from		' + @AnnualReportDiagnosisTable + N' fdt
inner join	' + @AnnualReportCaseDiagnosis_LabConfirmed_TotalValuesTable + N' fcdvt
on			fcdvt.idfsDiagnosis = fdt.idfsDiagnosis
--where		fdt.blnIsAggregate = 0		
' collate Cyrillic_General_CI_AS
	
-- Add summarized value for diagnoses from human cases: Total TotalConfirmed
set @cmd = @cmd + N'
update		fdt
set			fdt.intTotalConfirmed = isnull (fdt.intTotalConfirmed, 0) + fcdvt.intTotalConfirmed
from		' + @AnnualReportDiagnosisTable + N' fdt
inner join	' + @AnnualReportCaseDiagnosis_TotalConfirmed_TotalValuesTable + N' fcdvt
on			fcdvt.idfsDiagnosis = fdt.idfsDiagnosis
' collate Cyrillic_General_CI_AS


-- Summarize values for diagnosis groups	
set @cmd = @cmd + N'
insert into	' + @AnnualReportDiagnosisGroupTable + N'
(	idfsDiagnosisGroup,
	intAge_0_1,	
	intAge_1_4, 
	intAge_5_14, 
	intAge_15_19, 
	intAge_20_29, 
	intAge_30_59, 
	intAge_60_more, 
	intTotal, 
	intLabTested,		
	intLabConfirmed,		
	intTotalConfirmed
)
select	dtg.idfsReportDiagnosisGroup,
	    sum(intAge_0_1),	
	    sum(intAge_1_4), 
	    sum(intAge_5_14), 
	    sum(intAge_15_19), 
	    sum(intAge_20_29), 
	    sum(intAge_30_59), 
	    sum(intAge_60_more), 
	    sum(intTotal), 
	    sum(intLabTested),		
	    sum(intLabConfirmed),		
	    sum(intTotalConfirmed)
from		' + @AnnualReportDiagnosisTable + N' fdt
inner join	[' + @dbName_Actual + N'].dbo.trtDiagnosisToGroupForReportType dtg
on			dtg.idfsDiagnosis = fdt.idfsDiagnosis AND
dtg.idfsCustomReportType = @idfsCustomReportTypeInput
group by	dtg.idfsReportDiagnosisGroup	
' collate Cyrillic_General_CI_AS


-- Update report rows with calculated values for individual diagnoses	
set @cmd = @cmd + N'
update		ft
set	
  ft.intAge_0_1 = fdt.intAge_0_1,	
	ft.intAge_1_4 = fdt.intAge_1_4, 
	ft.intAge_5_14 = fdt.intAge_5_14, 
	ft.intAge_15_19 = fdt.intAge_15_19, 
	ft.intAge_20_29 = fdt.intAge_20_29, 
	ft.intAge_30_59 = fdt.intAge_30_59, 
	ft.intAge_60_more = fdt.intAge_60_more, 
	ft.intTotal = fdt.intTotal, 
	ft.intLabTested = fdt.intLabTested,
	ft.intLabConfirmed = fdt.intLabConfirmed,
	ft.intTotalConfirmed = fdt.intTotalConfirmed

from		' + @ReportTable + N' ft
inner join	' + @AnnualReportDiagnosisTable + N' fdt
on			fdt.idfsDiagnosis = ft.idfsBaseReference	
' collate Cyrillic_General_CI_AS

	
-- Update report rows with calculated values for diagnosis groups	
set @cmd = @cmd + N'
update		ft
set	
  ft.intAge_0_1 = fdgt.intAge_0_1,	
	ft.intAge_1_4 = fdgt.intAge_1_4, 
	ft.intAge_5_14 = fdgt.intAge_5_14, 
	ft.intAge_15_19 = fdgt.intAge_15_19, 
	ft.intAge_20_29 = fdgt.intAge_20_29, 
	ft.intAge_30_59 = fdgt.intAge_30_59, 
	ft.intAge_60_more = fdgt.intAge_60_more, 
	ft.intTotal = fdgt.intTotal, 
	ft.intLabTested = fdgt.intLabTested,		
	ft.intLabConfirmed = fdgt.intLabConfirmed,		
	ft.intTotalConfirmed = fdgt.intTotalConfirmed 
from		' + @ReportTable + N' ft
inner join	' + @AnnualReportDiagnosisGroupTable + N' fdgt
on			fdgt.idfsDiagnosisGroup = ft.idfsBaseReference		
' collate Cyrillic_General_CI_AS


-- Select final report table with determined cells that should have silver background
set @cmd = @cmd + N'
SELECT	R.idfsBaseReference,
		R.strDiseaseName,
		CASE WHEN rr.intNullValueInsteadZero & 1 > 0 THEN @NAValueInput ELSE CAST(R.strICD10 AS NVARCHAR(150)) END strICD10,
		iif(R.intAge_0_1=0, NULL, R.intAge_0_1) as intAge_0_1,
		iif(R.intAge_1_4=0, NULL, R.intAge_1_4) as intAge_1_4,
		iif(R.intAge_5_14=0, NULL, R.intAge_5_14) as intAge_5_14,
		iif(R.intAge_15_19=0, NULL, R.intAge_15_19) as intAge_15_19,
		iif(R.intAge_20_29=0, NULL, R.intAge_20_29) as intAge_20_29,
		iif(R.intAge_30_59=0, NULL, R.intAge_30_59) as intAge_30_59,
		iif(R.intAge_60_more=0, NULL, R.intAge_60_more) as intAge_60_more,
		R.intTotal as intTotal,
		CASE WHEN rr.intNullValueInsteadZero & 2 > 0 THEN @NAValueInput ELSE CAST(iif(R.intLabTested=0, NULL, R.intLabTested) AS NVARCHAR(10)) END as intLabTested,
		CASE WHEN rr.intNullValueInsteadZero & 4 > 0 THEN @NAValueInput ELSE CAST(iif(R.intLabConfirmed=0, NULL, R.intLabConfirmed) AS NVARCHAR(10)) END as intLabConfirmed,
		CASE WHEN rr.intNullValueInsteadZero & 8 > 0 THEN @NAValueInput ELSE CAST(iif(R.intTotalConfirmed=0, NULL, R.intTotalConfirmed) AS NVARCHAR(10)) END as intTotalConfirmed,
		R.strNameOfRespondent,
		R.strActualAddress,
		R.strTelephone,
		R.intOrder
FROM ' + @ReportTable + N' R
  left join 	[' + @dbName_Actual + N'].dbo.trtReportRows rr
  on rr.idfsCustomReportType = @idfsCustomReportTypeInput
  and rr.idfsDiagnosisOrReportDiagnosisGroup = R.idfsBaseReference	
ORDER BY R.intOrder
' collate Cyrillic_General_CI_AS
exec sp_executesql @cmd, N'@idfsCustomReportTypeInput bigint, @NAValueInput nvarchar(10)', @idfsCustomReportTypeInput = @idfsCustomReportType, @NAValueInput = @NAValue


--Remove temporary tables

if OBJECT_ID(@reportTableInTempDb) IS NOT NULL
BEGIN
	set @cmd = N'drop table ' + @reportTable collate Cyrillic_General_CI_AS
	exec sp_executesql @cmd
END


if OBJECT_ID(@AnnualReportDiagnosisTableInTempDb) IS NOT NULL
BEGIN
	set @cmd = N'drop table ' + @AnnualReportDiagnosisTable collate Cyrillic_General_CI_AS
	exec sp_executesql @cmd
END


if OBJECT_ID(@AnnualReportHumanAggregateCaseInTempDb) IS NOT NULL
BEGIN
	set @cmd = N'drop table ' + @AnnualReportHumanAggregateCase collate Cyrillic_General_CI_AS
	exec sp_executesql @cmd
END


if OBJECT_ID(@AnnualReportHumanAggregateCaseRowInTempDb) IS NOT NULL
BEGIN
	set @cmd = N'drop table ' + @AnnualReportHumanAggregateCaseRow collate Cyrillic_General_CI_AS
	exec sp_executesql @cmd
END


if OBJECT_ID(@AnnualReportAggregateDiagnosisValuesTableInTempDb) IS NOT NULL
BEGIN
	set @cmd = N'drop table ' + @AnnualReportAggregateDiagnosisValuesTable collate Cyrillic_General_CI_AS
	exec sp_executesql @cmd
END


if OBJECT_ID(@AnnualReportCaseTableInTempDb) IS NOT NULL
BEGIN
	set @cmd = N'drop table ' + @AnnualReportCaseTable collate Cyrillic_General_CI_AS
	exec sp_executesql @cmd
END


if OBJECT_ID(@AnnualReportCaseDiagnosisTotalValuesTableInTempDb) IS NOT NULL
BEGIN
	set @cmd = N'drop table ' + @AnnualReportCaseDiagnosisTotalValuesTable collate Cyrillic_General_CI_AS
	exec sp_executesql @cmd
END


if OBJECT_ID(@AnnualReportCaseDiagnosis_Age_0_1_TotalValuesTableInTempDb) IS NOT NULL
BEGIN
	set @cmd = N'drop table ' + @AnnualReportCaseDiagnosis_Age_0_1_TotalValuesTable collate Cyrillic_General_CI_AS
	exec sp_executesql @cmd
END


if OBJECT_ID(@AnnualReportCaseDiagnosis_Age_1_4_TotalValuesTableInTempDb) IS NOT NULL
BEGIN
	set @cmd = N'drop table ' + @AnnualReportCaseDiagnosis_Age_1_4_TotalValuesTable collate Cyrillic_General_CI_AS
	exec sp_executesql @cmd
END


if OBJECT_ID(@AnnualReportCaseDiagnosis_Age_5_14_TotalValuesTableInTempDb) IS NOT NULL
BEGIN
	set @cmd = N'drop table ' + @AnnualReportCaseDiagnosis_Age_5_14_TotalValuesTable collate Cyrillic_General_CI_AS
	exec sp_executesql @cmd
END


if OBJECT_ID(@AnnualReportCaseDiagnosis_Age_15_19_TotalValuesTableInTempDb) IS NOT NULL
BEGIN
	set @cmd = N'drop table ' + @AnnualReportCaseDiagnosis_Age_15_19_TotalValuesTable collate Cyrillic_General_CI_AS
	exec sp_executesql @cmd
END


if OBJECT_ID(@AnnualReportCaseDiagnosis_Age_20_29_TotalValuesTableInTempDb) IS NOT NULL
BEGIN
	set @cmd = N'drop table ' + @AnnualReportCaseDiagnosis_Age_20_29_TotalValuesTable collate Cyrillic_General_CI_AS
	exec sp_executesql @cmd
END


if OBJECT_ID(@AnnualReportCaseDiagnosis_Age_30_59_TotalValuesTableInTempDb) IS NOT NULL
BEGIN
	set @cmd = N'drop table ' + @AnnualReportCaseDiagnosis_Age_30_59_TotalValuesTable collate Cyrillic_General_CI_AS
	exec sp_executesql @cmd
END


if OBJECT_ID(@AnnualReportCaseDiagnosis_Age_60_more_TotalValuesTableInTempDb) IS NOT NULL
BEGIN
	set @cmd = N'drop table ' + @AnnualReportCaseDiagnosis_Age_60_more_TotalValuesTable collate Cyrillic_General_CI_AS
	exec sp_executesql @cmd
END


if OBJECT_ID(@AnnualReportCaseDiagnosis_LabTested_TotalValuesTableInTempDb) IS NOT NULL
BEGIN
	set @cmd = N'drop table ' + @AnnualReportCaseDiagnosis_LabTested_TotalValuesTable collate Cyrillic_General_CI_AS
	exec sp_executesql @cmd
END


if OBJECT_ID(@AnnualReportCaseDiagnosis_LabConfirmed_TotalValuesTableInTempDb) IS NOT NULL
BEGIN
	set @cmd = N'drop table ' + @AnnualReportCaseDiagnosis_LabConfirmed_TotalValuesTable collate Cyrillic_General_CI_AS
	exec sp_executesql @cmd
END


if OBJECT_ID(@AnnualReportCaseDiagnosis_TotalConfirmed_TotalValuesTableInTempDb) IS NOT NULL
BEGIN
	set @cmd = N'drop table ' + @AnnualReportCaseDiagnosis_TotalConfirmed_TotalValuesTable collate Cyrillic_General_CI_AS
	exec sp_executesql @cmd
END


if OBJECT_ID(@AnnualReportDiagnosisGroupTableInTempDb) IS NOT NULL
BEGIN
	set @cmd = N'drop table ' + @AnnualReportDiagnosisGroupTable collate Cyrillic_General_CI_AS
	exec sp_executesql @cmd
END
