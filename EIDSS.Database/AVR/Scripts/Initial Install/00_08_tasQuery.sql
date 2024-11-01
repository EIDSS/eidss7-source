/*
   Wednesday, July 13, 20222:45:53 PM
   User: 
   Server: .
   Database: EIDSS7_GAT_ARCHIVE
   Application: 
*/

/* To prevent any potential data loss issues, you should review this script in detail before running it outside the context of the database designer.*/
BEGIN TRANSACTION
SET QUOTED_IDENTIFIER ON
SET ARITHABORT ON
SET NUMERIC_ROUNDABORT OFF
SET CONCAT_NULL_YIELDS_NULL ON
SET ANSI_NULLS ON
SET ANSI_PADDING ON
SET ANSI_WARNINGS ON
COMMIT
BEGIN TRANSACTION
GO
ALTER TABLE dbo.tlbEmployee SET (LOCK_ESCALATION = TABLE)
GO
COMMIT
BEGIN TRANSACTION
GO
ALTER TABLE dbo.tlbOffice SET (LOCK_ESCALATION = TABLE)
GO
COMMIT
BEGIN TRANSACTION
GO
ALTER TABLE dbo.tasQuery ADD
	idfOffice bigint NULL,
	idfEmployee bigint NULL
GO
ALTER TABLE dbo.tasQuery ADD CONSTRAINT
	FK_tasQuery_tlbOffice FOREIGN KEY
	(
	idfOffice
	) REFERENCES dbo.tlbOffice
	(
	idfOffice
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
ALTER TABLE dbo.tasQuery ADD CONSTRAINT
	FK_tasQuery_tlbEmployee FOREIGN KEY
	(
	idfEmployee
	) REFERENCES dbo.tlbEmployee
	(
	idfEmployee
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
ALTER TABLE dbo.tasQuery SET (LOCK_ESCALATION = TABLE)
GO
COMMIT

GO
