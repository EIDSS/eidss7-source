CREATE TABLE [dbo].[AspNetRoles] (
    [Id]               NVARCHAR (128) NOT NULL,
    [Name]             NVARCHAR (256) NOT NULL,
    [idfEmployeeGroup] BIGINT         NOT NULL,
    CONSTRAINT [PK_dbo.AspNetRoles] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_ASPNetRole_tlbEmployeeGRoup_idfemployeeGroup] FOREIGN KEY ([idfEmployeeGroup]) REFERENCES [dbo].[tlbEmployeeGroup] ([idfEmployeeGroup])
);


GO
GRANT DELETE
    ON OBJECT::[dbo].[AspNetRoles] TO [db_execAspNet]
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[AspNetRoles] TO [db_execAspNet]
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[AspNetRoles] TO [db_execAspNet]
    AS [dbo];


GO
GRANT UPDATE
    ON OBJECT::[dbo].[AspNetRoles] TO [db_execAspNet]
    AS [dbo];

