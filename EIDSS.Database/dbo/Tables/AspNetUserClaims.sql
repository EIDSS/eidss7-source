CREATE TABLE [dbo].[AspNetUserClaims] (
    [Id]         INT            IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [UserId]     NVARCHAR (128) NOT NULL,
    [ClaimType]  NVARCHAR (MAX) NULL,
    [ClaimValue] NVARCHAR (MAX) NULL,
    CONSTRAINT [PK_dbo.AspNetUserClaims] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_dbo.AspNetUserClaims_dbo.AspNetUsers_UserId] FOREIGN KEY ([UserId]) REFERENCES [dbo].[AspNetUsers] ([Id]) ON DELETE CASCADE
);


GO
GRANT DELETE
    ON OBJECT::[dbo].[AspNetUserClaims] TO [db_execAspNet]
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[AspNetUserClaims] TO [db_execAspNet]
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[AspNetUserClaims] TO [db_execAspNet]
    AS [dbo];


GO
GRANT UPDATE
    ON OBJECT::[dbo].[AspNetUserClaims] TO [db_execAspNet]
    AS [dbo];

