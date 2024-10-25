
CREATE TABLE [dbo].[tauPINAuditEvent](
	[idfPINAuditEvent] [bigint] NOT NULL,
	[strPIN] [nchar](11) NOT NULL,
	[idfUserID] [bigint] NOT NULL,
	[idfsSite] [bigint] NOT NULL,
	[idfHumanCase] [bigint] NULL,
	[idfH0Form] [bigint] NULL,
	[datEIDSSAccessAttempt] [datetime] NOT NULL,
	[datPINAccessAttempt] [datetime] NOT NULL,
 CONSTRAINT [PK_tauPINAuditEvent] PRIMARY KEY CLUSTERED 
(
	[idfPINAuditEvent] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[tauPINAuditEvent]  WITH CHECK ADD  CONSTRAINT [FK_tauPINAuditEvent_tstUserTable] FOREIGN KEY([idfUserID])
REFERENCES [dbo].[tstUserTable] ([idfUserID])
GO

ALTER TABLE [dbo].[tauPINAuditEvent] CHECK CONSTRAINT [FK_tauPINAuditEvent_tstUserTable]
GO

