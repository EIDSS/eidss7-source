CREATE TABLE [dbo].[UserPreference] (
    [UserPreferenceUID]    BIGINT           NOT NULL,
    [idfUserID]            BIGINT           NOT NULL,
    [ModuleConstantID]     BIGINT           NULL,
    [PreferenceDetail]     XML              NOT NULL,
    [intRowStatus]         INT              CONSTRAINT [Def_UserPeference_intRowStatus] DEFAULT ((0)) NOT NULL,
    [AuditCreateUser]      VARCHAR (100)    NOT NULL,
    [AuditCreateDTM]       DATETIME         CONSTRAINT [DF__UserPefer__Audit__11979B32] DEFAULT (getdate()) NOT NULL,
    [AuditUpdateUser]      VARCHAR (100)    NULL,
    [AuditUpdateDTM]       DATETIME         NULL,
    [rowguid]              UNIQUEIDENTIFIER CONSTRAINT [DF_UserPreference_rowguid] DEFAULT (newsequentialid()) ROWGUIDCOL NOT NULL,
    [SourceSystemNameID]   BIGINT           NULL,
    [SourceSystemKeyValue] NVARCHAR (MAX)   NULL,
    CONSTRAINT [XPKUser] PRIMARY KEY CLUSTERED ([UserPreferenceUID] ASC),
    CONSTRAINT [FK_UserPreference_BAseRef_ModuleConstantID] FOREIGN KEY ([ModuleConstantID]) REFERENCES [dbo].[trtBaseReference] ([idfsBaseReference]),
    CONSTRAINT [FK_UserPreference_trtBaseReference_SourceSystemNameID] FOREIGN KEY ([SourceSystemNameID]) REFERENCES [dbo].[trtBaseReference] ([idfsBaseReference]),
    CONSTRAINT [FK_UserPreference_tstUserTable_UserID] FOREIGN KEY ([idfUserID]) REFERENCES [dbo].[tstUserTable] ([idfUserID])
);


GO




CREATE TRIGGER [dbo].[TR_UserPreference_I_Delete] on [dbo].[UserPreference]
INSTEAD OF DELETE
NOT FOR REPLICATION
AS
BEGIN

	IF (dbo.FN_GBL_TriggersWork() = 1)
	BEGIN

		WITH cteOnlyDeletedRows([UserPreferenceUID]) as
		(
			SELECT [UserPreferenceUID] FROM deleted
			EXCEPT
			SELECT [UserPreferenceUID] FROM inserted
		)

		UPDATE a
		SET intRowStatus = 1,
			AuditUpdateUser = SYSTEM_USER,
			AuditUpdateDTM = GETDATE()
		FROM dbo.UserPreference as a 
		INNER JOIN cteOnlyDeletedRows as b 
			ON a.[UserPreferenceUID] = b.[UserPreferenceUID];

	END

END

GO


CREATE TRIGGER [dbo].[TR_UserPreference_A_Update] on [dbo].[UserPreference]
FOR UPDATE
NOT FOR REPLICATION
AS

BEGIN
	IF(dbo.FN_GBL_TriggersWork ()=1) AND (UPDATE(UserPreferenceUID))
	BEGIN
		RAISERROR('Update Trigger: Not allowed to update PK.',16,1)
		ROLLBACK TRANSACTION
	END

END
