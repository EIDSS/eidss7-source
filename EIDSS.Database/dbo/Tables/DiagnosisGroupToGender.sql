CREATE TABLE [dbo].[DiagnosisGroupToGender] (
    [DisgnosisGroupToGenderUID] BIGINT           NOT NULL,
    [DisgnosisGroupID]          BIGINT           NULL,
    [GenderID]                  BIGINT           NULL,
    [rowguid]                   UNIQUEIDENTIFIER CONSTRAINT [DF_DiagnosisGroupToGender_rowguid] DEFAULT (newsequentialid()) NOT NULL,
    [intRowStatus]              INT              NOT NULL,
    [AuditCreateUser]           VARCHAR (100)    NOT NULL,
    [AuditCreateDTM]            DATETIME         DEFAULT (getdate()) NOT NULL,
    [AuditUpdateUser]           VARCHAR (100)    NULL,
    [AuditUpdateDTM]            DATETIME         NULL,
    [SourceSystemNameID]        BIGINT           CONSTRAINT [DEF_DiagnosisGroupToGender_SourceSystemNameID] DEFAULT ((10519001)) NULL,
    [SourceSystemKeyValue]      NVARCHAR (MAX)   NULL,
    CONSTRAINT [XPKDiagnosisToGender] PRIMARY KEY CLUSTERED ([DisgnosisGroupToGenderUID] ASC),
    CONSTRAINT [FK_DiagnosisGroupToGender_trtBaseReference_DiagnosisGroupID] FOREIGN KEY ([DisgnosisGroupID]) REFERENCES [dbo].[trtBaseReference] ([idfsBaseReference]),
    CONSTRAINT [FK_DiagnosisGroupToGender_trtBaseReference_GenderID] FOREIGN KEY ([GenderID]) REFERENCES [dbo].[trtBaseReference] ([idfsBaseReference]),
    CONSTRAINT [FK_DiagnosisGroupToGender_trtBaseReference_SourceSystemNameID] FOREIGN KEY ([SourceSystemNameID]) REFERENCES [dbo].[trtBaseReference] ([idfsBaseReference])
);


GO

CREATE TRIGGER [dbo].[TR_DiagnosisGroupToGender_I_Delete] on [dbo].[DiagnosisGroupToGender]
INSTEAD OF DELETE
NOT FOR REPLICATION
AS
BEGIN

	IF (dbo.FN_GBL_TriggersWork() = 1)
	BEGIN

		WITH cteOnlyDeletedRows([DisgnosisGroupToGenderUID]) as
		(
			SELECT [DisgnosisGroupToGenderUID] FROM deleted
			EXCEPT
			SELECT [DisgnosisGroupToGenderUID] FROM inserted
		)

		UPDATE a
		SET intRowStatus = 1,
			AuditUpdateUser = SYSTEM_USER,
			AuditUpdateDTM = GETDATE()
		FROM dbo.DiagnosisGroupToGender as a 
		INNER JOIN cteOnlyDeletedRows as b 
			ON a.[DisgnosisGroupToGenderUID] = b.[DisgnosisGroupToGenderUID];

	END

END

GO


CREATE TRIGGER [dbo].[TR_DiagnosisGroupToGender_A_Update] on [dbo].[DiagnosisGroupToGender]
FOR UPDATE
NOT FOR REPLICATION
AS

BEGIN
	IF(dbo.FN_GBL_TriggersWork ()=1) AND (UPDATE(DisgnosisGroupToGenderUID))
	BEGIN
		RAISERROR('Update Trigger: Not allowed to update PK.',16,1)
		ROLLBACK TRANSACTION
	END

END
