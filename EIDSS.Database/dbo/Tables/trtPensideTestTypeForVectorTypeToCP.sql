﻿CREATE TABLE [dbo].[trtPensideTestTypeForVectorTypeToCP] (
    [idfPensideTestTypeForVectorType] BIGINT           NOT NULL,
    [idfCustomizationPackage]         BIGINT           NOT NULL,
    [rowguid]                         UNIQUEIDENTIFIER CONSTRAINT [DF_trtPensideTestTypeForVectorTypeToCP_rowguid] DEFAULT (newid()) ROWGUIDCOL NOT NULL,
    [strMaintenanceFlag]              NVARCHAR (20)    NULL,
    [strReservedAttribute]            NVARCHAR (MAX)   NULL,
    [SourceSystemNameID]              BIGINT           NULL,
    [SourceSystemKeyValue]            NVARCHAR (MAX)   NULL,
    [AuditCreateUser]                 NVARCHAR (200)   NULL,
    [AuditCreateDTM]                  DATETIME         CONSTRAINT [DF_trtPensideTestTypeForVectorTypeToCP_CreateDTM] DEFAULT (getdate()) NULL,
    [AuditUpdateUser]                 NVARCHAR (200)   NULL,
    [AuditUpdateDTM]                  DATETIME         NULL,
    CONSTRAINT [PK_trtPensideTestTypeForVectorTypeToCP] PRIMARY KEY CLUSTERED ([idfPensideTestTypeForVectorType] ASC, [idfCustomizationPackage] ASC),
    CONSTRAINT [FK_trtPensideTestTypeForVectorTypeToCP_trtBaseReference_SourceSystemNameID] FOREIGN KEY ([SourceSystemNameID]) REFERENCES [dbo].[trtBaseReference] ([idfsBaseReference]),
    CONSTRAINT [FK_trtPensideTestTypeForVectorTypeToCP_trtPensideTestTypeForVectorType_idfPensideTestTypeForVectorType] FOREIGN KEY ([idfPensideTestTypeForVectorType]) REFERENCES [dbo].[trtPensideTestTypeForVectorType] ([idfPensideTestTypeForVectorType]) NOT FOR REPLICATION,
    CONSTRAINT [FK_trtPensideTestTypeForVectorTypeToCP_tstCustomizationPackage__idfCustomizationPackage] FOREIGN KEY ([idfCustomizationPackage]) REFERENCES [dbo].[tstCustomizationPackage] ([idfCustomizationPackage]) NOT FOR REPLICATION
);


GO

CREATE TRIGGER [dbo].[TR_trtPensideTestTypeForVectorTypeToCP_A_Update] ON [dbo].[trtPensideTestTypeForVectorTypeToCP]
FOR UPDATE
NOT FOR REPLICATION
AS
BEGIN

	IF (dbo.FN_GBL_TriggersWork() = 1 AND (UPDATE([idfPensideTestTypeForVectorType]) OR UPDATE([idfCustomizationPackage])))  -- update to Primary Key is not allowed.
	BEGIN
		RAISERROR('Update Trigger: Not allowed to update PK.',16,1);
		ROLLBACK TRANSACTION;
	END

END
