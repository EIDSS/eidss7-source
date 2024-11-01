﻿CREATE TYPE [dbo].[tlbFarmHerdSpeciesGetListSPType] AS TABLE (
    [RecordID]            BIGINT          NOT NULL,
    [RecordType]          VARCHAR (10)    NOT NULL,
    [idfFarm]             BIGINT          NULL,
    [idfFarmActual]       BIGINT          NULL,
    [idfHerd]             BIGINT          NULL,
    [idfHerdActual]       BIGINT          NULL,
    [idfSpecies]          BIGINT          NULL,
    [idfSpeciesActual]    BIGINT          NULL,
    [idfsSpeciesType]     BIGINT          NULL,
    [SpeciesTypeName]     NVARCHAR (200)  NULL,
    [strFarmCode]         NVARCHAR (200)  NULL,
    [strHerdCode]         NVARCHAR (200)  NULL,
    [datStartOfSignsDate] DATETIME        NULL,
    [strAverageAge]       NVARCHAR (200)  NULL,
    [intSickAnimalQty]    INT             NULL,
    [intTotalAnimalQty]   INT             NULL,
    [intDeadAnimalQty]    INT             NULL,
    [idfObservation]      BIGINT          NULL,
    [strNote]             NVARCHAR (2000) NULL,
    [intRowStatus]        INT             NULL,
    [strMaintenanceFlag]  NVARCHAR (20)   NULL,
    [RecordAction]        NCHAR (1)       NOT NULL,
    PRIMARY KEY CLUSTERED ([RecordID] ASC));

