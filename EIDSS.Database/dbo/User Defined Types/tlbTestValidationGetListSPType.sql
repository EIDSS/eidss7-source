﻿CREATE TYPE [dbo].[tlbTestValidationGetListSPType] AS TABLE (
    [idfTestValidation]           BIGINT         NOT NULL,
    [idfsDiagnosis]               BIGINT         NULL,
    [DiagnosisName]               NVARCHAR (200) NULL,
    [idfsInterpretedStatus]       BIGINT         NULL,
    [InterpretedStatusTypeName]   NVARCHAR (200) NULL,
    [idfValidatedByOffice]        BIGINT         NULL,
    [ValidatedByOfficeSiteName]   NVARCHAR (200) NULL,
    [idfValidatedByPerson]        BIGINT         NULL,
    [ValidatedByPersonName]       NVARCHAR (200) NULL,
    [idfInterpretedByOffice]      BIGINT         NULL,
    [InterpretedByOfficeSiteName] NVARCHAR (200) NULL,
    [idfInterpretedByPerson]      BIGINT         NULL,
    [InterpretedByPersonName]     NVARCHAR (200) NULL,
    [idfTesting]                  BIGINT         NOT NULL,
    [blnValidateStatus]           BIT            NULL,
    [blnCaseCreated]              BIT            NULL,
    [strValidateComment]          NVARCHAR (200) NULL,
    [strInterpretedComment]       NVARCHAR (200) NULL,
    [datValidationDate]           DATETIME       NULL,
    [datInterpretationDate]       DATETIME       NULL,
    [intRowStatus]                INT            NOT NULL,
    [blnReadOnly]                 BIT            NOT NULL,
    [strMaintenanceFlag]          NVARCHAR (20)  NULL,
    [idfMaterial]                 BIGINT         NULL,
    [strFieldBarcode]             NVARCHAR (200) NULL,
    [strBarCode]                  NVARCHAR (200) NULL,
    [SampleTypeName]              NVARCHAR (200) NULL,
    [idfSpecies]                  BIGINT         NULL,
    [SpeciesTypeName]             NVARCHAR (200) NULL,
    [idfAnimal]                   BIGINT         NULL,
    [strAnimalCode]               NVARCHAR (200) NULL,
    [idfsTestName]                BIGINT         NULL,
    [TestNameTypeName]            NVARCHAR (200) NULL,
    [idfsTestCategory]            BIGINT         NULL,
    [TestCategoryTypeName]        NVARCHAR (200) NULL,
    [idfsTestResult]              BIGINT         NULL,
    [TestResultTypeName]          NVARCHAR (200) NULL,
    [idfFarm]                     BIGINT         NULL,
    [strFarmCode]                 NVARCHAR (200) NULL,
    [RecordAction]                NCHAR (1)      NULL,
    PRIMARY KEY CLUSTERED ([idfTestValidation] ASC));
