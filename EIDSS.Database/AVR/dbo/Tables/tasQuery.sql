CREATE TABLE [dbo].[tasQuery](
	[idflQuery] [bigint] NOT NULL,
	[idfsGlobalQuery] [bigint] NULL,
	[strFunctionName] [nvarchar](200) NOT NULL,
	[idflDescription] [bigint] NOT NULL,
	[blnReadOnly] [bit] NOT NULL,
	[blnAddAllKeyFieldValues] [bit] NOT NULL,
	[blnSubQuery] [bit] NOT NULL,
	[strReservedAttribute] [nvarchar](max) NULL,
	[rowguid] [uniqueidentifier] ROWGUIDCOL  NOT NULL,
	[SourceSystemNameID] [bigint] NULL,
	[SourceSystemKeyValue] [nvarchar](max) NULL,
	[AuditCreateUser] [nvarchar](200) NULL,
	[AuditCreateDTM] [datetime] NULL,
	[AuditUpdateUser] [nvarchar](200) NULL,
	[AuditUpdateDTM] [datetime] NULL,
	[idfOffice] [bigint] NULL,
	[idfEmployee] [bigint] NULL,
 CONSTRAINT [XPKtasQuery] PRIMARY KEY CLUSTERED 
(
	[idflQuery] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE [dbo].[tasQuery] ADD  CONSTRAINT [Def_0___2706]  DEFAULT ((0)) FOR [blnReadOnly]
GO

ALTER TABLE [dbo].[tasQuery] ADD  CONSTRAINT [Def_0_2635]  DEFAULT ((0)) FOR [blnAddAllKeyFieldValues]
GO

ALTER TABLE [dbo].[tasQuery] ADD  CONSTRAINT [Def_0_tasQuery__blnSubQuery]  DEFAULT ((0)) FOR [blnSubQuery]
GO

ALTER TABLE [dbo].[tasQuery] ADD  CONSTRAINT [DF_tasQuery_rowguid]  DEFAULT (newsequentialid()) FOR [rowguid]
GO

ALTER TABLE [dbo].[tasQuery] ADD  CONSTRAINT [DF_tasQuery_CreateDTM]  DEFAULT (getdate()) FOR [AuditCreateDTM]
GO

ALTER TABLE [dbo].[tasQuery]  WITH NOCHECK ADD  CONSTRAINT [FK_tasQuery_locBaseReference__idflDescription_R_1718] FOREIGN KEY([idflDescription])
REFERENCES [dbo].[locBaseReference] ([idflBaseReference])
NOT FOR REPLICATION 
GO

ALTER TABLE [dbo].[tasQuery] CHECK CONSTRAINT [FK_tasQuery_locBaseReference__idflDescription_R_1718]
GO

ALTER TABLE [dbo].[tasQuery]  WITH NOCHECK ADD  CONSTRAINT [FK_tasQuery_locBaseReference__idflQueryName_R_1709] FOREIGN KEY([idflQuery])
REFERENCES [dbo].[locBaseReference] ([idflBaseReference])
NOT FOR REPLICATION 
GO

ALTER TABLE [dbo].[tasQuery] CHECK CONSTRAINT [FK_tasQuery_locBaseReference__idflQueryName_R_1709]
GO

ALTER TABLE [dbo].[tasQuery]  WITH NOCHECK ADD  CONSTRAINT [FK_tasQuery_tasglQuery__idfsGlobalQuery_R_1795] FOREIGN KEY([idfsGlobalQuery])
REFERENCES [dbo].[tasglQuery] ([idfsQuery])
NOT FOR REPLICATION 
GO

ALTER TABLE [dbo].[tasQuery] CHECK CONSTRAINT [FK_tasQuery_tasglQuery__idfsGlobalQuery_R_1795]
GO

ALTER TABLE [dbo].[tasQuery]  WITH CHECK ADD  CONSTRAINT [FK_tasQuery_tlbEmployee] FOREIGN KEY([idfEmployee])
REFERENCES [dbo].[tlbEmployee] ([idfEmployee])
GO

ALTER TABLE [dbo].[tasQuery] CHECK CONSTRAINT [FK_tasQuery_tlbEmployee]
GO

ALTER TABLE [dbo].[tasQuery]  WITH CHECK ADD  CONSTRAINT [FK_tasQuery_tlbOffice] FOREIGN KEY([idfOffice])
REFERENCES [dbo].[tlbOffice] ([idfOffice])
GO

ALTER TABLE [dbo].[tasQuery] CHECK CONSTRAINT [FK_tasQuery_tlbOffice]
GO

ALTER TABLE [dbo].[tasQuery]  WITH CHECK ADD  CONSTRAINT [FK_tasQuery_trtBaseReference_SourceSystemNameID] FOREIGN KEY([SourceSystemNameID])
REFERENCES [dbo].[trtBaseReference] ([idfsBaseReference])
GO

ALTER TABLE [dbo].[tasQuery] CHECK CONSTRAINT [FK_tasQuery_trtBaseReference_SourceSystemNameID]
GO


