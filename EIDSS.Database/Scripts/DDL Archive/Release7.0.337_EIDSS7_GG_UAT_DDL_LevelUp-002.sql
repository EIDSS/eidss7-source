﻿/*
Deployment script for EIDSS7_GG_UAT

This code was generated by a tool.
Changes to this file may cause incorrect behavior and will be lost if
the code is regenerated.
*/

GO
SET ANSI_NULLS, ANSI_PADDING, ANSI_WARNINGS, ARITHABORT, CONCAT_NULL_YIELDS_NULL, QUOTED_IDENTIFIER ON;

SET NUMERIC_ROUNDABORT OFF;


GO

PRINT N'Creating Default Constraint [dbo].[Def_0_2023]...';


GO
ALTER TABLE [dbo].[tstAggrSetting]
    ADD CONSTRAINT [Def_0_2023] DEFAULT ((0)) FOR [intRowStatus];


GO
PRINT N'Creating Default Constraint [dbo].[DF_tstAggrSetting_CreateDTM]...';


GO
ALTER TABLE [dbo].[tstAggrSetting]
    ADD CONSTRAINT [DF_tstAggrSetting_CreateDTM] DEFAULT (getdate()) FOR [AuditCreateDTM];


GO
PRINT N'Creating Default Constraint [dbo].[newid__2026]...';


GO
ALTER TABLE [dbo].[tstAggrSetting]
    ADD CONSTRAINT [newid__2026] DEFAULT (newid()) FOR [rowguid];


GO
PRINT N'Update complete.';


GO