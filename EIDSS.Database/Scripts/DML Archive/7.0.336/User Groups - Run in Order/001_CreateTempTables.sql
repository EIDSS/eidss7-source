/*
Run this script on:

        100.104.1.131\NGSQLTEST1.EIDSS7_GG_UAT    -  This database will be modified

to synchronize it with:

        100.104.1.167,49501\NGSQLDEV1.EIDSS7_GG_DT

You are recommended to back up your database before running this script

Script created by SQL Compare version 14.4.4.16824 from Red Gate Software Ltd at 2/23/2023 5:28:18 PM

*/


SET NUMERIC_ROUNDABORT OFF
GO
SET ANSI_PADDING, ANSI_WARNINGS, CONCAT_NULL_YIELDS_NULL, ARITHABORT, QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
SET XACT_ABORT ON
GO
SET TRANSACTION ISOLATION LEVEL Serializable
GO
BEGIN TRANSACTION
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
DROP TABLE IF EXISTS [dbo].[ZZZ_09Feb2023__LkupRoleToSystemFunctionAccess]
GO
PRINT N'Creating [dbo].[ZZZ_09Feb2023__LkupRoleToSystemFunctionAccess]'
GO
CREATE TABLE [dbo].[ZZZ_09Feb2023__LkupRoleToSystemFunctionAccess]
(
[FunctionName70] [nvarchar] (max) COLLATE Cyrillic_General_CI_AS NULL,
[OperationName] [nvarchar] (255) COLLATE Cyrillic_General_CI_AS NULL,
[GG Administrator Human] [nvarchar] (255) COLLATE Cyrillic_General_CI_AS NULL,
[GG Administrator Vet] [nvarchar] (255) COLLATE Cyrillic_General_CI_AS NULL,
[GG Chief Epidemiologist] [nvarchar] (255) COLLATE Cyrillic_General_CI_AS NULL,
[GG Chief Epizootologist] [nvarchar] (255) COLLATE Cyrillic_General_CI_AS NULL,
[GG Chief of Laboratory (Human)] [nvarchar] (255) COLLATE Cyrillic_General_CI_AS NULL,
[GG Chief of Laboratory (Vet)] [nvarchar] (255) COLLATE Cyrillic_General_CI_AS NULL,
[GG Epidemiologist] [nvarchar] (255) COLLATE Cyrillic_General_CI_AS NULL,
[GG Epizooltologist] [nvarchar] (255) COLLATE Cyrillic_General_CI_AS NULL,
[GG Lab Technician (Human)] [nvarchar] (255) COLLATE Cyrillic_General_CI_AS NULL,
[GG Lab Technician (Vet)] [nvarchar] (255) COLLATE Cyrillic_General_CI_AS NULL,
[GG Zoo Entomoligist (Human)] [nvarchar] (255) COLLATE Cyrillic_General_CI_AS NULL,
[GG Zoo Entomologist (Vet)] [nvarchar] (255) COLLATE Cyrillic_General_CI_AS NULL,
[GG Food Safety Specialist] [nvarchar] (255) COLLATE Cyrillic_General_CI_AS NULL,
[GG Form 03 Signer] [nvarchar] (255) COLLATE Cyrillic_General_CI_AS NULL,
[GG Sentinel Surv# Spe] [nvarchar] (255) COLLATE Cyrillic_General_CI_AS NULL,
[GG Director Human] [nvarchar] (255) COLLATE Cyrillic_General_CI_AS NULL,
[GG Director Vet] [nvarchar] (255) COLLATE Cyrillic_General_CI_AS NULL,
[AJ Epidemilogist] [nvarchar] (255) COLLATE Cyrillic_General_CI_AS NULL,
[AJ Human Module Admin Group] [nvarchar] (255) COLLATE Cyrillic_General_CI_AS NULL,
[AJ Deny Flulike Disease/HARI] [nvarchar] (255) COLLATE Cyrillic_General_CI_AS NULL,
[AJ Hospital staff- Baku city 7 CIDH] [nvarchar] (255) COLLATE Cyrillic_General_CI_AS NULL,
[AJ Hospital staff - Baku city CMC] [nvarchar] (255) COLLATE Cyrillic_General_CI_AS NULL,
[AJ Hospital staff- Baku city 2 CCH] [nvarchar] (255) COLLATE Cyrillic_General_CI_AS NULL,
[AJ Hospital staff- Baku city 1 CIDH] [nvarchar] (255) COLLATE Cyrillic_General_CI_AS NULL,
[AJ Hospital staff- Baku city 5 CIDH] [nvarchar] (255) COLLATE Cyrillic_General_CI_AS NULL,
[AJ Vet Module Admin Group] [nvarchar] (255) COLLATE Cyrillic_General_CI_AS NULL,
[AJ Veterinarian] [nvarchar] (255) COLLATE Cyrillic_General_CI_AS NULL,
[AJ Ministry of Agriculture] [nvarchar] (255) COLLATE Cyrillic_General_CI_AS NULL,
[AJ Baku City Vet Sites Users] [nvarchar] (255) COLLATE Cyrillic_General_CI_AS NULL,
[AJ Human Laboratory worker] [nvarchar] (255) COLLATE Cyrillic_General_CI_AS NULL,
[AJ Vet Laboratory worker] [nvarchar] (255) COLLATE Cyrillic_General_CI_AS NULL,
[AM Human Module Admin] [nvarchar] (255) COLLATE Cyrillic_General_CI_AS NULL,
[Hum Director] [nvarchar] (255) COLLATE Cyrillic_General_CI_AS NULL,
[AM Epidemiologist] [nvarchar] (255) COLLATE Cyrillic_General_CI_AS NULL,
[AM Vet Module Admin] [nvarchar] (255) COLLATE Cyrillic_General_CI_AS NULL,
[AM Chief Veterinarian] [nvarchar] (255) COLLATE Cyrillic_General_CI_AS NULL,
[AM Veterinarian] [nvarchar] (255) COLLATE Cyrillic_General_CI_AS NULL,
[AM Chief of Lab (Human)] [nvarchar] (255) COLLATE Cyrillic_General_CI_AS NULL,
[AM Laboratory Worker (human)] [nvarchar] (255) COLLATE Cyrillic_General_CI_AS NULL,
[AM Hum lab assistant (sample reg)] [nvarchar] (255) COLLATE Cyrillic_General_CI_AS NULL,
[AM Chief of Lab (vet)] [nvarchar] (255) COLLATE Cyrillic_General_CI_AS NULL,
[AM Laboratory worker (vet)] [nvarchar] (255) COLLATE Cyrillic_General_CI_AS NULL,
[AM Vet Lab Assistant (sample reg)] [nvarchar] (255) COLLATE Cyrillic_General_CI_AS NULL,
[AM MTAES/NSS Administrator] [nvarchar] (255) COLLATE Cyrillic_General_CI_AS NULL,
[AM MTAES/NSS Instructor/On duty employee] [nvarchar] (255) COLLATE Cyrillic_General_CI_AS NULL,
[AM Statist] [nvarchar] (255) COLLATE Cyrillic_General_CI_AS NULL,
[KZ National-level EIDSS Administrator] [nvarchar] (255) COLLATE Cyrillic_General_CI_AS NULL,
[KZ Chief of epidemiological surveillance department] [nvarchar] (255) COLLATE Cyrillic_General_CI_AS NULL,
[KZ Epidemiologist] [nvarchar] (255) COLLATE Cyrillic_General_CI_AS NULL,
[KZ Expert of APS] [nvarchar] (255) COLLATE Cyrillic_General_CI_AS NULL,
[KZ Chief of laboratory department] [nvarchar] (255) COLLATE Cyrillic_General_CI_AS NULL,
[KZ Laboratory Expert] [nvarchar] (255) COLLATE Cyrillic_General_CI_AS NULL,
[TH Human Module Admin Group] [nvarchar] (255) COLLATE Cyrillic_General_CI_AS NULL,
[TH Epidemiologist] [nvarchar] (255) COLLATE Cyrillic_General_CI_AS NULL,
[TH Human Laboratory Worker] [nvarchar] (255) COLLATE Cyrillic_General_CI_AS NULL,
[IQ Administrator] [nvarchar] (255) COLLATE Cyrillic_General_CI_AS NULL,
[IQ User] [nvarchar] (255) COLLATE Cyrillic_General_CI_AS NULL,
[IQ Vet Administrator] [nvarchar] (255) COLLATE Cyrillic_General_CI_AS NULL,
[IQ Vet User] [nvarchar] (255) COLLATE Cyrillic_General_CI_AS NULL,
[UA Administrator] [nvarchar] (255) COLLATE Cyrillic_General_CI_AS NULL,
[UA Chief Epidemiologist] [nvarchar] (255) COLLATE Cyrillic_General_CI_AS NULL,
[UA Epidemiologist] [nvarchar] (255) COLLATE Cyrillic_General_CI_AS NULL,
[UA Chief Veterinarian] [nvarchar] (255) COLLATE Cyrillic_General_CI_AS NULL,
[UA Veterinarian] [nvarchar] (255) COLLATE Cyrillic_General_CI_AS NULL,
[UA Lab Chief] [nvarchar] (255) COLLATE Cyrillic_General_CI_AS NULL,
[UA Lab Technician] [nvarchar] (255) COLLATE Cyrillic_General_CI_AS NULL
)
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
GO
DROP TABLE IF EXISTS [dbo].[ZZZ_DashboardMapping]
GO
PRINT N'Creating [dbo].[ZZZ_DashboardMapping]'
GO
CREATE TABLE [dbo].[ZZZ_DashboardMapping]
(
[EmployeeGroup] [nvarchar] (255) COLLATE Cyrillic_General_CI_AS NULL,
[1] [nvarchar] (255) COLLATE Cyrillic_General_CI_AS NULL,
[2] [nvarchar] (255) COLLATE Cyrillic_General_CI_AS NULL,
[3] [nvarchar] (255) COLLATE Cyrillic_General_CI_AS NULL,
[4] [nvarchar] (255) COLLATE Cyrillic_General_CI_AS NULL,
[5] [nvarchar] (255) COLLATE Cyrillic_General_CI_AS NULL,
[6] [nvarchar] (255) COLLATE Cyrillic_General_CI_AS NULL,
[7] [nvarchar] (255) COLLATE Cyrillic_General_CI_AS NULL
)
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
COMMIT TRANSACTION
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
-- This statement writes to the SQL Server Log so SQL Monitor can show this deployment.
IF HAS_PERMS_BY_NAME(N'sys.xp_logevent', N'OBJECT', N'EXECUTE') = 1
BEGIN
    DECLARE @databaseName AS nvarchar(2048), @eventMessage AS nvarchar(2048)
    SET @databaseName = REPLACE(REPLACE(DB_NAME(), N'\', N'\\'), N'"', N'\"')
    SET @eventMessage = N'Redgate SQL Compare: { "deployment": { "description": "Redgate SQL Compare deployed to ' + @databaseName + N'", "database": "' + @databaseName + N'" }}'
    EXECUTE sys.xp_logevent 55000, @eventMessage
END
GO
DECLARE @Success AS BIT
SET @Success = 1
SET NOEXEC OFF
IF (@Success = 1) PRINT 'The database update succeeded'
ELSE BEGIN
	IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
	PRINT 'The database update failed'
END
GO
