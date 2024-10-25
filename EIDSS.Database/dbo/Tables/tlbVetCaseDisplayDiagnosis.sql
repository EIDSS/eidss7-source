CREATE TABLE [dbo].[tlbVetCaseDisplayDiagnosis] (
    [idfVetCase]           BIGINT           NOT NULL,
    [idfsLanguage]         BIGINT           NOT NULL,
    [strDisplayDiagnosis]  NVARCHAR (500)   NULL,
    [intRowStatus]         INT              CONSTRAINT [Def_0_tlbVetCaseDisplayDiagnosis] DEFAULT ((0)) NOT NULL,
    [strMaintenanceFlag]   NVARCHAR (20)    NULL,
    [strReservedAttribute] NVARCHAR (MAX)   NULL,
    [rowguid]              UNIQUEIDENTIFIER CONSTRAINT [DF_tlbVetCaseDisplayDiagnosis_rowguid] DEFAULT (newsequentialid()) ROWGUIDCOL NOT NULL,
    [SourceSystemNameID]   BIGINT           CONSTRAINT [DEF_tlbVetCaseDisplayDiagnosis_SourceSystemNameID] DEFAULT ((10519001)) NULL,
    [SourceSystemKeyValue] NVARCHAR (MAX)   NULL,
    [AuditCreateUser]      NVARCHAR (200)   NULL,
    [AuditCreateDTM]       DATETIME         CONSTRAINT [DF_tlbVetCaseDisplayDiagnosis_CreateDTM] DEFAULT (getdate()) NULL,
    [AuditUpdateUser]      NVARCHAR (200)   NULL,
    [AuditUpdateDTM]       DATETIME         NULL,
    CONSTRAINT [XPKtlbVetCaseDisplayDiagnosis] PRIMARY KEY CLUSTERED ([idfVetCase] ASC, [idfsLanguage] ASC),
    CONSTRAINT [FK_tlbVetCaseDisplayDiagnosis_tlbVetCase_idfVetCase] FOREIGN KEY ([idfVetCase]) REFERENCES [dbo].[tlbVetCase] ([idfVetCase]) NOT FOR REPLICATION,
    CONSTRAINT [FK_tlbVetCaseDisplayDiagnosis_trtBaseReference_idfsLanguage] FOREIGN KEY ([idfsLanguage]) REFERENCES [dbo].[trtBaseReference] ([idfsBaseReference]) NOT FOR REPLICATION,
    CONSTRAINT [FK_tlbVetCaseDisplayDiagnosis_trtBaseReference_SourceSystemNameID] FOREIGN KEY ([SourceSystemNameID]) REFERENCES [dbo].[trtBaseReference] ([idfsBaseReference])
);


GO

CREATE TRIGGER [dbo].[TR_tlbVetCaseDisplayDiagnosis_A_Update] ON [dbo].[tlbVetCaseDisplayDiagnosis]
FOR UPDATE
NOT FOR REPLICATION
AS

BEGIN
	IF(dbo.FN_GBL_TriggersWork ()=1 AND (UPDATE(idfsLanguage) OR UPDATE(idfVetCase)))
	BEGIN
		RAISERROR('Update Trigger: Not allowed to update PK.',16,1)
		ROLLBACK TRANSACTION
	END

END

GO


CREATE TRIGGER [dbo].[TR_tlbVetCaseDisplayDiagnosis_I_Delete] on [dbo].[tlbVetCaseDisplayDiagnosis]
INSTEAD OF DELETE
NOT FOR REPLICATION
AS
BEGIN

	IF (dbo.FN_GBL_TriggersWork() = 1)
	BEGIN

		WITH cteOnlyDeletedRecords([idfVetCase], [idfsLanguage]) as
		(
			SELECT [idfVetCase], [idfsLanguage] FROM deleted
			EXCEPT
			SELECT [idfVetCase], [idfsLanguage] FROM inserted
		)

		UPDATE a
		SET intRowStatus = 1
		FROM dbo.tlbVetCaseDisplayDiagnosis as a 
		INNER JOIN cteOnlyDeletedRecords as b 
			ON a.idfVetCase = b.idfVetCase
			AND a.idfsLanguage = b.idfsLanguage;

	END

END
