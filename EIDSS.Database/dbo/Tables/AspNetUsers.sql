CREATE TABLE [dbo].[AspNetUsers] (
    [Id]                     NVARCHAR (128)     NOT NULL,
    [idfUserID]              BIGINT             NOT NULL,
    [Email]                  NVARCHAR (256)     NULL,
    [EmailConfirmed]         BIT                NOT NULL,
    [PasswordHash]           NVARCHAR (MAX)     NULL,
    [SecurityStamp]          NVARCHAR (MAX)     NULL,
    [PhoneNumber]            NVARCHAR (MAX)     NULL,
    [PhoneNumberConfirmed]   BIT                NOT NULL,
    [TwoFactorEnabled]       BIT                NOT NULL,
    [LockoutEnd]             DATETIMEOFFSET (7) NULL,
    [LockoutEnabled]         BIT                NOT NULL,
    [AccessFailedCount]      INT                NOT NULL,
    [UserName]               NVARCHAR (256)     NOT NULL,
    [blnDisabled]            BIT                NULL,
    [strDisabledReason]      NVARCHAR (256)     NULL,
    [datPasswordLastChanged] DATETIME           NULL,
    [PasswordResetRequired]  BIT                CONSTRAINT [DF_AspNetUsers_PasswordResetRequired] DEFAULT ((0)) NOT NULL,
    [NormalizedUsername]     NVARCHAR (256)     NULL,
    [ConcurrencyStamp]       NVARCHAR (MAX)     NULL,
    [NormalizedEmail]        NVARCHAR (256)     NULL,
    [DateDisabled]           DATETIME           NULL,
    CONSTRAINT [PK_dbo.AspNetUsers] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_AspNetUsers_tstUserTable_UserID] FOREIGN KEY ([idfUserID]) REFERENCES [dbo].[tstUserTable] ([idfUserID])
);


GO
GRANT DELETE
    ON OBJECT::[dbo].[AspNetUsers] TO [db_execAspNet]
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[AspNetUsers] TO [db_execAspNet]
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[AspNetUsers] TO [db_execAspNet]
    AS [dbo];


GO
GRANT UPDATE
    ON OBJECT::[dbo].[AspNetUsers] TO [db_execAspNet]
    AS [dbo];

