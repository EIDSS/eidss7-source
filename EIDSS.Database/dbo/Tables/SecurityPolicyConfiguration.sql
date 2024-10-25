CREATE TABLE [dbo].[SecurityPolicyConfiguration] (
    [SecurityPolicyConfigurationUID] INT              NOT NULL,
    [MinPasswordLength]              INT              NULL,
    [EnforcePasswordHistoryCount]    INT              NULL,
    [MinPasswordAgeDays]             INT              NULL,
    [ForceUppercaseFlag]             BIT              NULL,
    [ForceLowercaseFlag]             BIT              NULL,
    [ForceNumberUsageFlag]           BIT              NULL,
    [ForceSpecialCharactersFlag]     BIT              NULL,
    [AllowUseOfSpaceFlag]            BIT              NULL,
    [PreventSequentialCharacterFlag] BIT              NULL,
    [PreventUsernameUsageFlag]       BIT              NULL,
    [LockoutThld]                    INT              NULL,
    [LockoutDurationMinutes]         INT              NULL,
    [MaxSessionLength]               INT              NULL,
    [SesnIdleTimeoutWarnThldMins]    INT              NULL,
    [SesnIdleCloseoutThldMins]       INT              NULL,
    [intRowStatus]                   INT              CONSTRAINT [Def_SecurityPolicyConfiguration_intRowStatus] DEFAULT ((0)) NOT NULL,
    [rowguid]                        UNIQUEIDENTIFIER CONSTRAINT [DF_SecurityPolicyConfiguration_rowguid] DEFAULT (newsequentialid()) ROWGUIDCOL NOT NULL,
    [AuditCreateUser]                VARCHAR (100)    CONSTRAINT [DF__SecurityPolicyConfiguration__AuditCreateUSer] DEFAULT (user_name()) NOT NULL,
    [AuditCreateDTM]                 DATETIME         CONSTRAINT [DF__SecurityPolicyConfiguration__AuditCreateDTM] DEFAULT (getdate()) NOT NULL,
    [AuditUpdateUser]                VARCHAR (100)    CONSTRAINT [DF__SecurityPolicyConfiguration__AuditUpdateUser] DEFAULT (user_name()) NOT NULL,
    [AuditUpdateDTM]                 DATETIME         NULL,
    [SourceSystemNameID]             BIGINT           NULL,
    [SourceSystemKeyValue]           NVARCHAR (MAX)   NULL,
    [SesnInactivityTimeOutMins]      INT              NULL,
    CONSTRAINT [XPKSecurityPolicy] PRIMARY KEY CLUSTERED ([SecurityPolicyConfigurationUID] ASC),
    CONSTRAINT [FK_SecurityPolicyConfig_trtBaseReference_SourceSystemNameID] FOREIGN KEY ([SourceSystemNameID]) REFERENCES [dbo].[trtBaseReference] ([idfsBaseReference])
);


GO


CREATE TRIGGER [dbo].[TR_SecurityPolicyConfiguration_A_Update] on [dbo].[SecurityPolicyConfiguration]
FOR UPDATE
NOT FOR REPLICATION
AS

BEGIN
	IF(dbo.FN_GBL_TriggersWork ()=1) AND (UPDATE(SecurityPolicyConfigurationUID))
	BEGIN
		RAISERROR('Update Trigger: Not allowed to update PK.',16,1)
		ROLLBACK TRANSACTION
	END

END

GO



CREATE TRIGGER [dbo].[TR_SecurityPolicyConfiguration_I_Delete] on [dbo].[SecurityPolicyConfiguration]
INSTEAD OF DELETE
NOT FOR REPLICATION
AS
BEGIN

	IF (dbo.FN_GBL_TriggersWork() = 1)
	BEGIN

		WITH cteOnlyDeletedRows([SecurityPolicyConfigurationUID]) as
		(
			SELECT [SecurityPolicyConfigurationUID] FROM deleted
			EXCEPT
			SELECT [SecurityPolicyConfigurationUID] FROM inserted
		)

		UPDATE a
		SET intRowStatus = 1,
			AuditUpdateUser = SYSTEM_USER,
			AuditUpdateDTM = GETDATE()
		FROM dbo.SecurityPolicyConfiguration as a 
		INNER JOIN cteOnlyDeletedRows as b 
			ON a.[SecurityPolicyConfigurationUID] = b.[SecurityPolicyConfigurationUID];

	END

END
