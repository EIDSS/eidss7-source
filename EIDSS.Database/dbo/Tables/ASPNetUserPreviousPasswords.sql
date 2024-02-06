CREATE TABLE [dbo].[ASPNetUserPreviousPasswords] (
    [ASPNetUserPreviousPasswordsUID] BIGINT           IDENTITY (1, 1) NOT NULL,
    [Id]                             NVARCHAR (128)   NOT NULL,
    [OldPasswordHash]                NVARCHAR (MAX)   NOT NULL,
    [intRowStatus]                   INT              CONSTRAINT [Def_ASPNetUserPreviousPasswords_intRowStatus] DEFAULT ((0)) NOT NULL,
    [rowguid]                        UNIQUEIDENTIFIER CONSTRAINT [DF_ASPNetUserPreviousPasswords__rowguid] DEFAULT (newid()) NOT NULL,
    [strMaintenanceFlag]             NVARCHAR (20)    NULL,
    [strReservedAttribute]           NVARCHAR (MAX)   NULL,
    [AuditCreateUser]                VARCHAR (100)    CONSTRAINT [DF__ASPNetUserPreviousPasswords__AudiCreateUser] DEFAULT (user_name()) NOT NULL,
    [AuditCreateDTM]                 DATETIME         CONSTRAINT [DF__ASPNetUserPreviousPasswords__AuditCreateDTM] DEFAULT (getdate()) NOT NULL,
    [AuditUpdateUser]                VARCHAR (100)    CONSTRAINT [DF__ASPNetUserPreviousPasswords__AuditUpdateUser] DEFAULT (user_name()) NOT NULL,
    [AuditUpdateDTM]                 DATETIME         CONSTRAINT [DF__ASPNetUserPreviousPasswords__AuditUpdateDTM] DEFAULT (getdate()) NOT NULL,
    [SourceSystemNameID]             BIGINT           CONSTRAINT [DEF_ASPNetUserPreviousPasswords_SourceSystemNameID] DEFAULT ((10519001)) NULL,
    [SourceSystemKeyValue]           NVARCHAR (MAX)   NULL,
    CONSTRAINT [XPKASPNetUserPreviousPasswords] PRIMARY KEY CLUSTERED ([ASPNetUserPreviousPasswordsUID] ASC),
    CONSTRAINT [FK_ASPNetUserPreviousPasswords_AspNetUsers_Id] FOREIGN KEY ([Id]) REFERENCES [dbo].[AspNetUsers] ([Id]),
    CONSTRAINT [FK_ASPNetUserPreviousPasswords_trtBaseReference_SourceSystemNameID] FOREIGN KEY ([SourceSystemNameID]) REFERENCES [dbo].[trtBaseReference] ([idfsBaseReference])
);

