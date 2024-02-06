CREATE TABLE [dbo].[AccessRulePermission] (
    [AccessRulePermissionID] BIGINT           NOT NULL,
    [AccessRuleID]           BIGINT           NOT NULL,
    [AccessPermissionID]     BIGINT           NOT NULL,
    [intRowStatus]           INT              CONSTRAINT [DF_AccessRulePermission_intRowStatus] DEFAULT ((0)) NOT NULL,
    [AuditCreateUser]        VARCHAR (100)    CONSTRAINT [DF_AccessRulePermission__Audit__21C31603] DEFAULT (user_name()) NOT NULL,
    [AuditCreateDTM]         DATETIME         CONSTRAINT [DF_AccessRulePermission__Audit__22B73A3C] DEFAULT (getdate()) NOT NULL,
    [AuditUpdateUser]        VARCHAR (100)    CONSTRAINT [DF_AccessRulePermission__Audit__23AB5E75] DEFAULT (user_name()) NOT NULL,
    [AuditUpdateDTM]         DATETIME         CONSTRAINT [DF_AccessRulePermission__Audit__249F82AE] DEFAULT (getdate()) NOT NULL,
    [rowguid]                UNIQUEIDENTIFIER CONSTRAINT [DF_AccessRulePermission_rowguid] DEFAULT (newsequentialid()) ROWGUIDCOL NOT NULL,
    [SourceSystemNameID]     BIGINT           NULL,
    [SourceSystemKeyValue]   NVARCHAR (MAX)   NULL,
    CONSTRAINT [PK__AccessRu__90E672BF1F9832CD] PRIMARY KEY CLUSTERED ([AccessRulePermissionID] ASC),
    CONSTRAINT [FK_AccessRulePermission_AccessRule_AccessRuleID] FOREIGN KEY ([AccessRuleID]) REFERENCES [dbo].[AccessRule] ([AccessRuleID]),
    CONSTRAINT [FK_AccessRulePermission_trtBaseReference_AccessPermissionID] FOREIGN KEY ([AccessPermissionID]) REFERENCES [dbo].[trtBaseReference] ([idfsBaseReference]),
    CONSTRAINT [FK_AccessRulePermission_trtBaseReference_SourceSystemNameID] FOREIGN KEY ([SourceSystemNameID]) REFERENCES [dbo].[trtBaseReference] ([idfsBaseReference])
);

