﻿CREATE TABLE [dbo].[AspNetUserRoles] (
    [UserId] NVARCHAR (128) NOT NULL,
    [RoleId] NVARCHAR (128) NOT NULL,
    CONSTRAINT [PK_dbo.AspNetUserRoles] PRIMARY KEY CLUSTERED ([UserId] ASC, [RoleId] ASC),
    CONSTRAINT [FK_dbo.AspNetUserRoles_dbo.AspNetRoles_RoleId] FOREIGN KEY ([RoleId]) REFERENCES [dbo].[AspNetRoles] ([Id]) ON DELETE CASCADE,
    CONSTRAINT [FK_dbo.AspNetUserRoles_dbo.AspNetUsers_UserId] FOREIGN KEY ([UserId]) REFERENCES [dbo].[AspNetUsers] ([Id]) ON DELETE CASCADE
);


GO
GRANT DELETE
    ON OBJECT::[dbo].[AspNetUserRoles] TO [db_execAspNet]
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[AspNetUserRoles] TO [db_execAspNet]
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[AspNetUserRoles] TO [db_execAspNet]
    AS [dbo];


GO
GRANT UPDATE
    ON OBJECT::[dbo].[AspNetUserRoles] TO [db_execAspNet]
    AS [dbo];

