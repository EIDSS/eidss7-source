


--*************************************************************
-- Name 				: [USP_GBL_ReportForm_SET]
-- Description			: Add/Update Weekly Report Form record
--          
-- Author               : Mani
-- Revision History
--		Name       Date       Change Detail
--
--Manickandan Govindarajan 11/30/2022 Added Data Audit
-- Testing code:
--
/*

exec  [dbo].[USP_GBL_ReportForm_SET] -1,'(new)',10528000,4719270000000,18,-265,3,-490,'10/5/2020 12:00:00 AM','10/5/2020 12:00:00 AM','1/8/2020 12:00:00 AM',	
			'1/15/2020 12:00:00 AM',9888840000000,5,0,null,null
--*/
CREATE PROCEDURE [dbo].[USP_GBL_ReportForm_SET]
	@idfReportForm BIGINT = NULL,
	@strReportFormID NVARCHAR(200) = NULL,
	@idfsReportFormType BIGINT,
	@GeographicalAdministrativeUnitID BIGINT = NULL, -- Country, Region, Rayon and Settlement Statistical Area Types
	@idfSentByOffice BIGINT,
	@idfSentByPerson BIGINT,
	@idfEnteredByOffice BIGINT,
	@idfEnteredByPerson BIGINT,
	@datSentByDate DATETIME,
	@datEnteredByDate DATETIME,
	@datStartDate DATETIME,
	@datFinishDate DATETIME,
	@idfDiagnosis BIGINT,
	@total INT = 0,
	@SiteID BIGINT,
	@UserID BIGINT,
	@notified INT = NULL,
	@comments NVARCHAR(250) = NULL,
	@datModificationForArchiveDate DATETIME = NULL

AS
DECLARE @ReturnCode INT = 0;
DECLARE @ReturnMessage NVARCHAR(MAX) = 'SUCCESS';
DECLARE @SuppressSelect TABLE (
	ReturnCode INT,
	ReturnMessage VARCHAR(200)
	);

declare @idfsDataAuditEventType bigint =10016002;
declare @idfsObjectType bigint =10017074;
declare @idfObject bigint;
declare @idfObjectTable_tlbReportForm bigint =53577790000001;
declare @idfDataAuditEvent bigint;
declare @idfUserID bigint;
declare @idfSiteId bigint;

DECLARE @tlbReportForm_BeforeEdit TABLE
(
	[idfReportForm] [bigint] NOT NULL,
	[idfsReportFormType] [bigint] NOT NULL,
	[idfsAdministrativeUnit] [bigint] NOT NULL,
	[idfSentByOffice] [bigint] NOT NULL,
	[idfSentByPerson] [bigint] NOT NULL,
	[idfEnteredByOffice] [bigint] NOT NULL,
	[idfEnteredByPerson] [bigint] NOT NULL,
	[datSentByDate] [datetime] NULL,
	[datEnteredByDate] [datetime] NULL,
	[datStartDate] [datetime] NULL,
	[datFinishDate] [datetime] NULL,
	[strReportFormID] [nvarchar](200) NOT NULL,
	[idfsSite] [bigint] NOT NULL,
	[idfsDiagnosis] [bigint] NOT NULL,
	[Total] [int] NOT NULL,
	[Notified] [int] NULL,
	[Comments] [nvarchar](256) NULL
	)

DECLARE @tlbReportForm_AfterEdit TABLE
	(
	[idfReportForm] [bigint] NOT NULL,
	[idfsReportFormType] [bigint] NOT NULL,
	[idfsAdministrativeUnit] [bigint] NOT NULL,
	[idfSentByOffice] [bigint] NOT NULL,
	[idfSentByPerson] [bigint] NOT NULL,
	[idfEnteredByOffice] [bigint] NOT NULL,
	[idfEnteredByPerson] [bigint] NOT NULL,
	[datSentByDate] [datetime] NULL,
	[datEnteredByDate] [datetime] NULL,
	[datStartDate] [datetime] NULL,
	[datFinishDate] [datetime] NULL,
	[strReportFormID] [nvarchar](200) NOT NULL,
	[idfsSite] [bigint] NOT NULL,
	[idfsDiagnosis] [bigint] NOT NULL,
	[Total] [int] NOT NULL,
	[Notified] [int] NULL,
	[Comments] [nvarchar](256) NULL
)

BEGIN
	BEGIN TRY
		BEGIN TRANSACTION

		IF EXISTS (
				SELECT *
				FROM dbo.tlbReportForm
				WHERE idfReportForm = @idfReportForm
				)
		BEGIN
			-- Data Audit
			set @idfsDataAuditEventType =10016003;
			set @idfObject=@idfReportForm;

				insert into @tlbReportForm_BeforeEdit ( idfReportForm,[idfsReportFormType] ,[idfsAdministrativeUnit],
						[idfSentByOffice],[idfSentByPerson],[idfEnteredByOffice],[idfEnteredByPerson],[datSentByDate],[datEnteredByDate],
						[datStartDate],[datFinishDate],[strReportFormID],[idfsSite],[idfsDiagnosis],[Total],[Notified],[Comments])
				select idfReportForm,[idfsReportFormType] ,[idfsAdministrativeUnit],
						[idfSentByOffice],[idfSentByPerson],[idfEnteredByOffice],[idfEnteredByPerson],[datSentByDate],[datEnteredByDate],
						[datStartDate],[datFinishDate],[strReportFormID],[idfsSite],[idfsDiagnosis],[Total],[Notified],[Comments]
						from tlbReportForm where idfReportForm =@idfReportForm;
			--Data Audit

			UPDATE dbo.tlbReportForm
			SET idfsReportFormType = @idfsReportFormType,
				idfsAdministrativeUnit = @GeographicalAdministrativeUnitID,
				idfSentByOffice = @idfSentByOffice,
				idfSentByPerson = @idfSentByPerson,
				datSentByDate = @datSentByDate,
				datStartDate = @datStartDate,
				datFinishDate = @datFinishDate,
				datModificationForArchiveDate = GETDATE(),
				idfsDiagnosis = @idfDiagnosis,
				Total = @total,
				Notified = @notified,
				Comments =@comments,
				idfsSite= @SiteID,
				AuditUpdateUser=@UserID,
				AuditUpdateDTM = GETDATE()
			WHERE idfReportForm = @idfReportForm;

			--Data Audit
			insert into @tlbReportForm_AfterEdit ( idfReportForm,[idfsReportFormType] ,[idfsAdministrativeUnit],
						[idfSentByOffice],[idfSentByPerson],[idfEnteredByOffice],[idfEnteredByPerson],[datSentByDate],[datEnteredByDate],
						[datStartDate],[datFinishDate],[strReportFormID],[idfsSite],[idfsDiagnosis],[Total],[Notified],[Comments])
				select idfReportForm,[idfsReportFormType] ,[idfsAdministrativeUnit],
						[idfSentByOffice],[idfSentByPerson],[idfEnteredByOffice],[idfEnteredByPerson],[datSentByDate],[datEnteredByDate],
						[datStartDate],[datFinishDate],[strReportFormID],[idfsSite],[idfsDiagnosis],[Total],[Notified],[Comments]
						from tlbReportForm where idfReportForm =@idfReportForm;

			INSERT INTO @SuppressSelect
			EXEC USSP_GBL_DataAuditEvent_GET @UserID, @SiteID, @idfsDataAuditEventType,@idfsObjectType,@idfObject, @idfObjectTable_tlbReportForm, @idfDataAuditEvent OUTPUT
			

			insert into dbo.tauDataAuditDetailUpdate(
				idfDataAuditEvent, idfObjectTable, idfColumn, 
				idfObject, idfObjectDetail, 
				strOldValue, strNewValue)
			select @idfDataAuditEvent,@idfObjectTable_tlbReportForm, 51586990000002,
				a.idfReportForm,null,
				a.idfsReportFormType,b.idfsReportFormType 
			from @tlbReportForm_BeforeEdit a  inner join @tlbReportForm_AfterEdit b on a.idfReportForm = b.idfReportForm
			where (a.idfsReportFormType <> b.idfsReportFormType) 
				or(a.idfsReportFormType is not null and b.idfsReportFormType is null)
				or(a.idfsReportFormType is null and b.idfsReportFormType is not null)

			insert into dbo.tauDataAuditDetailUpdate(
				idfDataAuditEvent, idfObjectTable, idfColumn, 
				idfObject, idfObjectDetail, 
				strOldValue, strNewValue)
			select @idfDataAuditEvent,@idfObjectTable_tlbReportForm, 51586990000003,
				a.idfReportForm,null,
				a.idfsAdministrativeUnit,b.idfsAdministrativeUnit 
			from @tlbReportForm_BeforeEdit a  inner join @tlbReportForm_AfterEdit b on a.idfReportForm = b.idfReportForm
			where (a.idfsAdministrativeUnit <> b.idfsAdministrativeUnit) 
				or(a.idfsAdministrativeUnit is not null and b.idfsAdministrativeUnit is null)
				or(a.idfsAdministrativeUnit is null and b.idfsAdministrativeUnit is not null)

			insert into dbo.tauDataAuditDetailUpdate(
				idfDataAuditEvent, idfObjectTable, idfColumn, 
				idfObject, idfObjectDetail, 
				strOldValue, strNewValue)
			select @idfDataAuditEvent,@idfObjectTable_tlbReportForm, 51586990000004,
				a.idfReportForm,null,
				a.idfSentByOffice,b.idfSentByOffice 
			from @tlbReportForm_BeforeEdit a  inner join @tlbReportForm_AfterEdit b on a.idfReportForm = b.idfReportForm
			where (a.idfSentByOffice <> b.idfSentByOffice) 
				or(a.idfSentByOffice is not null and b.idfSentByOffice is null)
				or(a.idfSentByOffice is null and b.idfSentByOffice is not null)

			insert into dbo.tauDataAuditDetailUpdate(
				idfDataAuditEvent, idfObjectTable, idfColumn, 
				idfObject, idfObjectDetail, 
				strOldValue, strNewValue)
			select @idfDataAuditEvent,@idfObjectTable_tlbReportForm, 51586990000005,
				a.idfReportForm,null,
				a.idfSentByPerson,b.idfSentByPerson 
			from @tlbReportForm_BeforeEdit a  inner join @tlbReportForm_AfterEdit b on a.idfReportForm = b.idfReportForm
			where (a.idfSentByPerson <> b.idfSentByPerson) 
				or(a.idfSentByPerson is not null and b.idfSentByPerson is null)
				or(a.idfSentByPerson is null and b.idfSentByPerson is not null)

			insert into dbo.tauDataAuditDetailUpdate(
				idfDataAuditEvent, idfObjectTable, idfColumn, 
				idfObject, idfObjectDetail, 
				strOldValue, strNewValue)
			select @idfDataAuditEvent,@idfObjectTable_tlbReportForm, 51586990000006,
				a.idfReportForm,null,
				a.idfEnteredByOffice,b.idfEnteredByOffice 
			from @tlbReportForm_BeforeEdit a  inner join @tlbReportForm_AfterEdit b on a.idfReportForm = b.idfReportForm
			where (a.idfEnteredByOffice <> b.idfEnteredByOffice) 
				or(a.idfEnteredByOffice is not null and b.idfEnteredByOffice is null)
				or(a.idfEnteredByOffice is null and b.idfEnteredByOffice is not null)

			insert into dbo.tauDataAuditDetailUpdate(
				idfDataAuditEvent, idfObjectTable, idfColumn, 
				idfObject, idfObjectDetail, 
				strOldValue, strNewValue)
			select @idfDataAuditEvent,@idfObjectTable_tlbReportForm, 51586990000007,
				a.idfReportForm,null,
				a.idfEnteredByPerson,b.idfEnteredByPerson 
			from @tlbReportForm_BeforeEdit a  inner join @tlbReportForm_AfterEdit b on a.idfReportForm = b.idfReportForm
			where (a.idfEnteredByPerson <> b.idfEnteredByPerson) 
				or(a.idfEnteredByPerson is not null and b.idfEnteredByPerson is null)
				or(a.idfEnteredByPerson is null and b.idfEnteredByPerson is not null)

			insert into dbo.tauDataAuditDetailUpdate(
				idfDataAuditEvent, idfObjectTable, idfColumn, 
				idfObject, idfObjectDetail, 
				strOldValue, strNewValue)
			select @idfDataAuditEvent,@idfObjectTable_tlbReportForm, 51586990000008,
				a.idfReportForm,null,
				a.datSentByDate,b.datSentByDate 
			from @tlbReportForm_BeforeEdit a  inner join @tlbReportForm_AfterEdit b on a.idfReportForm = b.idfReportForm
			where (a.datSentByDate <> b.datSentByDate) 
				or(a.datSentByDate is not null and b.datSentByDate is null)
				or(a.datSentByDate is null and b.datSentByDate is not null)

			insert into dbo.tauDataAuditDetailUpdate(
				idfDataAuditEvent, idfObjectTable, idfColumn, 
				idfObject, idfObjectDetail, 
				strOldValue, strNewValue)
			select @idfDataAuditEvent,@idfObjectTable_tlbReportForm, 51586990000009,
				a.idfReportForm,null,
				a.datEnteredByDate,b.datEnteredByDate 
			from @tlbReportForm_BeforeEdit a  inner join @tlbReportForm_AfterEdit b on a.idfReportForm = b.idfReportForm
			where (a.datEnteredByDate <> b.datEnteredByDate) 
				or(a.datEnteredByDate is not null and b.datEnteredByDate is null)
				or(a.datEnteredByDate is null and b.datEnteredByDate is not null)

			insert into dbo.tauDataAuditDetailUpdate(
				idfDataAuditEvent, idfObjectTable, idfColumn, 
				idfObject, idfObjectDetail, 
				strOldValue, strNewValue)
			select @idfDataAuditEvent,@idfObjectTable_tlbReportForm, 51586990000010,
				a.idfReportForm,null,
				a.datStartDate,b.datStartDate 
			from @tlbReportForm_BeforeEdit a  inner join @tlbReportForm_AfterEdit b on a.idfReportForm = b.idfReportForm
			where (a.datStartDate <> b.datStartDate) 
				or(a.datStartDate is not null and b.datStartDate is null)
				or(a.datStartDate is null and b.datStartDate is not null)
				
			insert into dbo.tauDataAuditDetailUpdate(
				idfDataAuditEvent, idfObjectTable, idfColumn, 
				idfObject, idfObjectDetail, 
				strOldValue, strNewValue)
			select @idfDataAuditEvent,@idfObjectTable_tlbReportForm, 51586990000011,
				a.idfReportForm,null,
				a.datFinishDate,b.datFinishDate 
			from @tlbReportForm_BeforeEdit a  inner join @tlbReportForm_AfterEdit b on a.idfReportForm = b.idfReportForm
			where (a.datFinishDate <> b.datFinishDate) 
				or(a.datFinishDate is not null and b.datFinishDate is null)
				or(a.datFinishDate is null and b.datFinishDate is not null)
			
			insert into dbo.tauDataAuditDetailUpdate(
				idfDataAuditEvent, idfObjectTable, idfColumn, 
				idfObject, idfObjectDetail, 
				strOldValue, strNewValue)
			select @idfDataAuditEvent,@idfObjectTable_tlbReportForm, 51586990000012,
				a.idfReportForm,null,
				a.strReportFormID,b.strReportFormID 
			from @tlbReportForm_BeforeEdit a  inner join @tlbReportForm_AfterEdit b on a.idfReportForm = b.idfReportForm
			where (a.strReportFormID <> b.strReportFormID) 
				or(a.strReportFormID is not null and b.strReportFormID is null)
				or(a.strReportFormID is null and b.strReportFormID is not null)

			insert into dbo.tauDataAuditDetailUpdate(
				idfDataAuditEvent, idfObjectTable, idfColumn, 
				idfObject, idfObjectDetail, 
				strOldValue, strNewValue)
			select @idfDataAuditEvent,@idfObjectTable_tlbReportForm, 51586990000013,
				a.idfReportForm,null,
				a.idfsSite,b.idfsSite 
			from @tlbReportForm_BeforeEdit a  inner join @tlbReportForm_AfterEdit b on a.idfReportForm = b.idfReportForm
			where (a.idfsSite <> b.idfsSite) 
				or(a.idfsSite is not null and b.idfsSite is null)
				or(a.idfsSite is null and b.idfsSite is not null)

			insert into dbo.tauDataAuditDetailUpdate(
				idfDataAuditEvent, idfObjectTable, idfColumn, 
				idfObject, idfObjectDetail, 
				strOldValue, strNewValue)
			select @idfDataAuditEvent,@idfObjectTable_tlbReportForm, 51586990000014,
				a.idfReportForm,null,
				a.idfsDiagnosis,b.idfsDiagnosis 
			from @tlbReportForm_BeforeEdit a  inner join @tlbReportForm_AfterEdit b on a.idfReportForm = b.idfReportForm
			where (a.idfsDiagnosis <> b.idfsDiagnosis) 
				or(a.idfsDiagnosis is not null and b.idfsDiagnosis is null)
				or(a.idfsDiagnosis is null and b.idfsDiagnosis is not null)
		
			insert into dbo.tauDataAuditDetailUpdate(
				idfDataAuditEvent, idfObjectTable, idfColumn, 
				idfObject, idfObjectDetail, 
				strOldValue, strNewValue)
			select @idfDataAuditEvent,@idfObjectTable_tlbReportForm, 51586990000015,
				a.idfReportForm,null,
				a.Total,b.Total 
			from @tlbReportForm_BeforeEdit a  inner join @tlbReportForm_AfterEdit b on a.idfReportForm = b.idfReportForm
			where (a.Total <> b.Total) 
				or(a.Total is not null and b.Total is null)
				or(a.Total is null and b.Total is not null)

			insert into dbo.tauDataAuditDetailUpdate(
				idfDataAuditEvent, idfObjectTable, idfColumn, 
				idfObject, idfObjectDetail, 
				strOldValue, strNewValue)
			select @idfDataAuditEvent,@idfObjectTable_tlbReportForm, 51586990000016,
				a.idfReportForm,null,
				a.Notified,b.Notified 
			from @tlbReportForm_BeforeEdit a  inner join @tlbReportForm_AfterEdit b on a.idfReportForm = b.idfReportForm
			where (a.Notified <> b.Notified) 
				or(a.Notified is not null and b.Notified is null)
				or(a.Notified is null and b.Notified is not null)

			insert into dbo.tauDataAuditDetailUpdate(
				idfDataAuditEvent, idfObjectTable, idfColumn, 
				idfObject, idfObjectDetail, 
				strOldValue, strNewValue)
			select @idfDataAuditEvent,@idfObjectTable_tlbReportForm, 51586990000017,
				a.idfReportForm,null,
				a.Comments,b.Comments 
			from @tlbReportForm_BeforeEdit a  inner join @tlbReportForm_AfterEdit b on a.idfReportForm = b.idfReportForm
			where (a.Comments <> b.Comments) 
				or(a.Comments is not null and b.Comments is null)
				or(a.Comments is null and b.Comments is not null)

			--Data Audit

		END
		ELSE
		BEGIN
			INSERT INTO @SuppressSelect
			EXEC dbo.USP_GBL_NEXTKEYID_GET 'tlbReportForm',
				@idfReportForm OUTPUT;

			IF ISNULL(@strReportFormID, N'') = N''
				OR LEFT(ISNULL(@strReportFormID, N''), 4) = '(new'
			BEGIN
				DECLARE @ObjectName NVARCHAR(600);
				SET @ObjectName ='Weekly Reporting Form';
				INSERT INTO @SuppressSelect
				EXEC dbo.USP_GBL_NextNumber_GET @ObjectName,
					@strReportFormID OUTPUT,
					NULL;
			END
			--data audit
			set @idfsDataAuditEventType =10016001;
			set @idfObject =@idfReportForm;

			EXEC USSP_GBL_DataAuditEvent_GET @UserID, @SiteID, @idfsDataAuditEventType,@idfsObjectType,@idfObject, @idfObjectTable_tlbReportForm, @idfDataAuditEvent OUTPUT
			-- insert into delete 
			INSERT INTO tauDataAuditDetailCreate(idfDataAuditEvent, idfObjectTable, idfObject )
			values(@idfDataAuditEvent, @idfObjectTable_tlbReportForm, @idfObject)
			--data audit
			INSERT INTO dbo.tlbReportForm (
				idfReportForm,
				idfsReportFormType,
				idfsAdministrativeUnit,
				idfSentByOffice,
				idfSentByPerson,
				idfEnteredByOffice,
				idfEnteredByPerson,
				datSentByDate,
				datEnteredByDate,
				datStartDate,
				datFinishDate,
				strReportFormID,
				idfsDiagnosis,
				Total,
				Notified,
				Comments,
				datModificationForArchiveDate,
				idfsSite,
				AuditCreateUser,
				AuditCreateDTM
				)
			VALUES (
				@idfReportForm,
				@idfsReportFormType,
				@GeographicalAdministrativeUnitID,
				@idfSentByOffice,
				@idfSentByPerson,
				@idfEnteredByOffice,
				@idfEnteredByPerson,
				@datSentByDate,
				@datEnteredByDate,
				@datStartDate,
				@datFinishDate,
				@strReportFormID,
				@idfDiagnosis,
				@total,
				@notified,
				@comments,
				GETDATE(),
				@SiteID,
				@UserID,
				GETDATE()
				);
		END

		IF @@TRANCOUNT > 0
			COMMIT;

		SELECT @ReturnCode 'ReturnCode',
			@ReturnMessage 'ReturnMessage',
			@idfReportForm 'idfReportForm',
			@strReportFormID 'strReportFormID';
	END TRY

	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK;

		THROW;
	END CATCH
END
