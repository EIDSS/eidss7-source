﻿CREATE TABLE [dbo].[AspNetUserLogins] (
    [LoginProvider] NVARCHAR (128) NOT NULL,
    [ProviderKey]   NVARCHAR (128) NOT NULL,
    [UserId]        NVARCHAR (128) NOT NULL,
    CONSTRAINT [PK_dbo.AspNetUserLogins] PRIMARY KEY CLUSTERED ([LoginProvider] ASC, [ProviderKey] ASC, [UserId] ASC),
    CONSTRAINT [FK_dbo.AspNetUserLogins_dbo.AspNetUsers_UserId] FOREIGN KEY ([UserId]) REFERENCES [dbo].[AspNetUsers] ([Id]) ON DELETE CASCADE
);


GO
GRANT DELETE
    ON OBJECT::[dbo].[AspNetUserLogins] TO [db_execAspNet]
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[AspNetUserLogins] TO [db_execAspNet]
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[AspNetUserLogins] TO [db_execAspNet]
    AS [dbo];


GO
GRANT UPDATE
    ON OBJECT::[dbo].[AspNetUserLogins] TO [db_execAspNet]
    AS [dbo];

