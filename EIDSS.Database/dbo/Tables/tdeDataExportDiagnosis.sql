CREATE TABLE [dbo].[tdeDataExportDiagnosis] (
    [idfsDiagnosis]        BIGINT           NOT NULL,
    [idfDataExport]        BIGINT           NOT NULL,
    [rowguid]              UNIQUEIDENTIFIER CONSTRAINT [DF_tdeDataExportDiagnosis_rowguid] DEFAULT (newsequentialid()) ROWGUIDCOL NOT NULL,
    [SourceSystemNameID]   BIGINT           NULL,
    [SourceSystemKeyValue] NVARCHAR (MAX)   NULL,
    [AuditCreateUser]      NVARCHAR (200)   NULL,
    [AuditCreateDTM]       DATETIME         CONSTRAINT [DF_tdeDataExportDiagnosis_CreateDTM] DEFAULT (getdate()) NULL,
    [AuditUpdateUser]      NVARCHAR (200)   NULL,
    [AuditUpdateDTM]       DATETIME         NULL,
    CONSTRAINT [XPKtdeDataExportDiagnosis] PRIMARY KEY CLUSTERED ([idfsDiagnosis] ASC, [idfDataExport] ASC),
    CONSTRAINT [FK_tdeDataExportDiagnosis_tdeDataExport__idfDataExport_R_1000] FOREIGN KEY ([idfDataExport]) REFERENCES [dbo].[tdeDataExport] ([idfDataExport]) NOT FOR REPLICATION,
    CONSTRAINT [FK_tdeDataExportDiagnosis_trtBaseReference_SourceSystemNameID] FOREIGN KEY ([SourceSystemNameID]) REFERENCES [dbo].[trtBaseReference] ([idfsBaseReference]),
    CONSTRAINT [FK_tdeDataExportDiagnosis_trtDiagnosis__idfsDiagnosis_R_999] FOREIGN KEY ([idfsDiagnosis]) REFERENCES [dbo].[trtDiagnosis] ([idfsDiagnosis]) NOT FOR REPLICATION
);


GO

CREATE TRIGGER [dbo].[TR_tdeDataExportDiagnosis_A_Update] ON [dbo].[tdeDataExportDiagnosis]
FOR UPDATE
NOT FOR REPLICATION
AS

BEGIN
	IF(dbo.FN_GBL_TriggersWork ()=1 AND (UPDATE(idfsDiagnosis) OR UPDATE(idfDataExport)))
	BEGIN
		RAISERROR('Update Trigger: Not allowed to update PK.',16,1)
		ROLLBACK TRANSACTION
	END

END

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'WHO Module export diagnosis', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tdeDataExportDiagnosis';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Diagnosis identifier', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tdeDataExportDiagnosis', @level2type = N'COLUMN', @level2name = N'idfsDiagnosis';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Export operation identifier', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tdeDataExportDiagnosis', @level2type = N'COLUMN', @level2name = N'idfDataExport';

