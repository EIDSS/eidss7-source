
--=================================================================================================================
-- Created by:				Joan Li
-- Last modified by:		
-- Joan Li					06/13/17	Created based on V6 spStatistic_Post:  V7 usp54 purpose: save records in tlbStatistic
-- Joan Li	                06/15/17	change action parameter
-- Lamont Mitchell			1/2/19		Added ReturnCode and ReturnMessage and changed @idfStatistic from output parameter added it to the Select output
-- Ricky Moss				3/12/20		Check for Duplicates and return a message and statistic id if record exists.
-- Ricky Moss				3/18/20		Added settlement parameter
-- Ricky Moss				3/23/20		Developed search for existing statistic data
-- LAMONT MITCHELL			6/7/2022	ADDED BULKINPORT PARAMETER TO DISTINGUISH BETWEEN BULK IMPORT AND SINGLE ENTERIES.. BULK IMPORT BYPASSES DUPLICATE CHECK
-- Leo Tracchia				9/6/2022	modified logic to handle duplicate data during bulk import
-- Leo Tracchia				10/26/2022	fix for GAT defect #472, DevOps 5259
-- Leo Tracchia				3/1/2023	added logic for data auditing
-- Leo Tracchia				4/3/2023	corrected @idfsObjectType to 10017049
--=================================================================================================================

CREATE PROCEDURE [dbo].[USP_ADMIN_STAT_SET]
(
	@idfStatistic						BIGINT		= NULL,	--##PARAM @idfStatistic - statistic record ID
	@idfsStatisticDataType				BIGINT		= NULL,	--##PARAM @idfsStatisticDataType - statistic data Type
	@idfsMainBaseReference				BIGINT		= NULL,	--##PARAM @idfsMainBaseReference - statistic base reference
	@idfsStatisticAreaType				BIGINT		= NULL,	--##PARAM @idfsStatisticAreaType - statistic Area Type
	@idfsStatisticPeriodType			BIGINT		= NULL,	--##PARAM @idfsStatisticPeriodType - statistic period Type
	@LocationUserControlidfsCountry		BIGINT		= NULL,	--##PARAM @idfsArea - statistic Area
	@LocationUserControlidfsRegion		BIGINT		= NULL,	--##PARAM @idfsArea - statistic Area
	@LocationUserControlidfsRayon 		BIGINT		= NULL,	--##PARAM @idfsArea - statistic Area
	@LocationUserControlidfsSettlement	BIGINT		= NULL,	--##PARAM @idfsArea - statistic Area
	@datStatisticStartDate				DATETIME	= NULL,	--##PARAM @datStatisticStartDate - start date
	@datStatisticFinishDate				DATETIME	= NULL,	--##PARAM @datStatisticFinishDate - finish date 
	@varValue							INT			= NULL,	--##PARAM @varValue - statistic content
	@idfsStatisticalAgeGroup			BIGINT		= NULL,
	@idfsParameterName					BIGINT		= NULL,
	@bulkImport							BIT			= 0,
	@SiteId								BIGINT,
	@UserId								BIGINT
)
AS

DECLARE @returnCode					INT = 0 
DECLARE	@returnMsg					NVARCHAR(max) = 'SUCCESS' 
DECLARE @existingStatistic			BIGINT = null;
DECLARE @idfsArea					BIGINT

Declare @SupressSelect table
( 
	retrunCode int,
	returnMessage varchar(200)
)

--Data Audit--

	DECLARE @idfUserId BIGINT = @UserId;
	DECLARE @idfSiteId BIGINT = @SiteId;
	DECLARE @idfsDataAuditEventType bigint = NULL;
	DECLARE @idfsObjectType bigint = 10017049; 
	DECLARE @idfObject bigint = @idfStatistic;
	DECLARE @idfObjectTable_tlbStatistic bigint = 75720000000;		
	DECLARE @idfDataAuditEvent bigint = NULL;		

	DECLARE @tlbStatistic_BeforeEdit TABLE
	(
		idfStatistic bigint,
		idfsStatisticDataType bigint, 
		idfsMainBaseReference bigint, 
		idfsStatisticAreaType bigint, 
		idfsStatisticPeriodType bigint, 
		idfsArea bigint,
		datStatisticStartDate datetime,
		datStatisticFinishDate datetime,
		varValue sql_variant,
		idfsStatisticalAgeGroup bigint
	)

	DECLARE @tlbStatistic_AfterEdit TABLE
	(
		idfStatistic bigint,
		idfsStatisticDataType bigint, 
		idfsMainBaseReference bigint, 
		idfsStatisticAreaType bigint, 
		idfsStatisticPeriodType bigint, 
		idfsArea bigint,
		datStatisticStartDate datetime,
		datStatisticFinishDate datetime,
		varValue sql_variant,
		idfsStatisticalAgeGroup bigint
	)	

--Data Audit--

BEGIN

	BEGIN TRY  	

		BEGIN TRANSACTION

			IF @LocationUserControlidfsSettlement IS NOT NULL
				SELECT @idfsArea = @LocationUserControlidfsSettlement
			ELSE IF @LocationUserControlidfsRayon IS NOT NULL 
				SELECT @idfsArea = @LocationUserControlidfsRayon
			ELSE IF @LocationUserControlidfsRegion IS NOT NULL
				SELECT @idfsArea = @LocationUserControlidfsRegion
			ELSE 
				SELECT @idfsArea = @LocationUserControlidfsCountry

			--SELECT @existingStatistic = (SELECT top 1(idfStatistic) from tlbStatistic WHERE idfsStatisticDataType = @idfsStatisticDataType AND idfsStatisticPeriodType = @idfsStatisticPeriodType AND ((idfsStatisticalAgeGroup = @idfsStatisticalAgeGroup) OR (idfsStatisticalAgeGroup IS NULL AND @idfsStatisticalAgeGroup IS NULL ))AND idfsStatisticAreaType = @idfsStatisticAreaType AND idfsArea = @idfsArea AND datStatisticStartDate = @datStatisticStartDate AND ((idfsMainBaseReference = @idfsMainBaseReference ) OR idfsMainBaseReference IS NULL AND @idfsMainBaseReference IS NULL) )
			--SELECT @existingStatistic =
			--	(SELECT top 1(idfStatistic) 
			--	FROM tlbStatistic 
			--	WHERE 
			--	idfsStatisticDataType = @idfsStatisticDataType 
			--	AND idfsStatisticAreaType = @idfsStatisticAreaType 
			--	AND idfsStatisticPeriodType = @idfsStatisticPeriodType 
			--	AND idfsArea = @idfsArea --Georgia?
			--	AND datStatisticStartDate = @datStatisticStartDate 
			--	AND datStatisticFinishDate = @datStatisticFinishDate 
			--	--AND varValue = @varValue
			--	AND idfsStatisticalAgeGroup = @idfsStatisticalAgeGroup)

			--IF(@existingStatistic IS NOT NULL AND @idfStatistic IS NULL) --AND @bulkImport = 0)
			--	BEGIN
			--		SELECT @returnMsg = 'DOES EXIST'
			--		SELECT @idfStatistic = @existingStatistic
			--	END
			--ELSE 

			-- if @idfStatistic is not passed in... (possibly a new record)
			IF NOT EXISTS (SELECT * FROM dbo.tlbStatistic WHERE  idfStatistic = @idfStatistic) 

				BEGIN

					--print 'getting existing statistic...'

					-- check if a row already exists with the same data
					SELECT @existingStatistic =
						(SELECT top 1(idfStatistic) 
						FROM tlbStatistic 
						WHERE 
						(idfsStatisticDataType = @idfsStatisticDataType or @idfsStatisticDataType is null)
						AND (idfsMainBaseReference = @idfsMainBaseReference or @idfsMainBaseReference is null)
						AND (idfsStatisticAreaType = @idfsStatisticAreaType or @idfsStatisticAreaType is null)
						AND (idfsStatisticPeriodType = @idfsStatisticPeriodType or @idfsStatisticPeriodType is null)
						AND (idfsArea = @idfsArea or @idfsArea is null)
						AND (datStatisticStartDate = @datStatisticStartDate or @datStatisticStartDate is null)
						AND (datStatisticFinishDate = @datStatisticFinishDate or @datStatisticFinishDate is null)
						--AND (varValue = @varValue or @varValue is null)
						AND (idfsStatisticalAgeGroup = @idfsStatisticalAgeGroup or @idfsStatisticalAgeGroup is null)
						AND intRowStatus = 0)

					--print @existingStatistic

					-- if row doesn't exists, then insert new data
					IF(@existingStatistic IS NULL)
						BEGIN

							--print 'existing statistic is null, so insert'

							INSERT INTO @SupressSelect
							EXEC dbo.USP_GBL_NEXTKEYID_GET 'tlbStatistic', @idfStatistic OUTPUT

							--Data Audit--

								-- tauDataAuditEvent Event Type - Create 
								set @idfsDataAuditEventType = 10016001;
			
								-- insert record into tauDataAuditEvent - 
								INSERT INTO @SupressSelect
								EXEC USSP_GBL_DataAuditEvent_GET @idfUserId, @idfSiteId, @idfsDataAuditEventType, @idfsObjectType, @idfStatistic, @idfObjectTable_tlbStatistic, @idfDataAuditEvent OUTPUT

							--Data Audit--

							INSERT INTO tlbStatistic
								(
									idfStatistic,
									idfsStatisticDataType,
									idfsMainBaseReference,
									idfsStatisticAreaType,
									idfsStatisticPeriodType,
									idfsArea,
									datStatisticStartDate,
									datStatisticFinishDate,
									varValue,
									idfsStatisticalAgeGroup
								)
							VALUES
								(
									@idfStatistic,
									@idfsStatisticDataType,
									@idfsMainBaseReference,
									@idfsStatisticAreaType,
									@idfsStatisticPeriodType,
									CASE ISNULL(@LocationUserControlidfsSettlement , '') 
									WHEN '' THEN
										CASE ISNULL(@LocationUserControlidfsRayon, '') 
										WHEN '' THEN
											CASE ISNULL(@LocationUserControlidfsRegion,'')
												WHEN '' THEN
													@LocationUserControlidfsCountry 
												ELSE 
													@LocationUserControlidfsRegion
												END
										ELSE 
												@LocationUserControlidfsRayon 
										END 
									ELSE 
										@LocationUserControlidfsSettlement  
									END,
									@datStatisticStartDate,
									@datStatisticFinishDate,
									CAST(@varValue AS INT),
									@idfsStatisticalAgeGroup
								)

							--Data Audit--							

								INSERT INTO tauDataAuditDetailCreate(idfDataAuditEvent, idfObjectTable, idfObject)
								VALUES (@idfDataAuditEvent, @idfObjectTable_tlbStatistic, @idfStatistic)
			
							--Data Audit--

						END
					-- else, just update it with @existingStatistic
					ELSE

						--print 'existing statistic is NOT null, so update'

						--BEGIN: DataAudit-- 
				
							--  tauDataAuditEvent  Event Type - Edit 
							set @idfsDataAuditEventType = 10016003;
			
							-- insert record into tauDataAuditEvent - 
							INSERT INTO @SupressSelect
							EXEC USSP_GBL_DataAuditEvent_GET @idfUserId, @idfSiteId, @idfsDataAuditEventType, @idfsObjectType, @idfStatistic, @idfObjectTable_tlbStatistic, @idfDataAuditEvent OUTPUT						

							INSERT INTO @tlbStatistic_BeforeEdit(
								idfStatistic,
								idfsStatisticDataType, 
								idfsMainBaseReference, 
								idfsStatisticAreaType, 
								idfsStatisticPeriodType, 
								idfsArea,
								datStatisticStartDate,
								datStatisticFinishDate,
								varValue,
								idfsStatisticalAgeGroup
								)
							SELECT 
								idfStatistic,
								idfsStatisticDataType, 
								idfsMainBaseReference, 
								idfsStatisticAreaType, 
								idfsStatisticPeriodType, 
								idfsArea,
								datStatisticStartDate,
								datStatisticFinishDate,
								varValue,
								idfsStatisticalAgeGroup				
								FROM tlbStatistic WHERE idfStatistic = @idfStatistic;

						--END: DataAudit-- 

						UPDATE	tlbStatistic
						SET		idfsStatisticDataType = @idfsStatisticDataType,
								idfsMainBaseReference = @idfsMainBaseReference,
								idfsStatisticAreaType = @idfsStatisticAreaType,
								idfsStatisticPeriodType = @idfsStatisticPeriodType,
								idfsArea = CASE ISNULL(@LocationUserControlidfsSettlement , '') 
									WHEN '' THEN
										CASE ISNULL(@LocationUserControlidfsRayon, '') 
										WHEN '' THEN
											CASE ISNULL(@LocationUserControlidfsRegion,'')
												WHEN '' THEN
													@LocationUserControlidfsCountry 
												ELSE 
													@LocationUserControlidfsRegion
												END
										ELSE 
												@LocationUserControlidfsRayon 
										END 
									ELSE 
										@LocationUserControlidfsSettlement  
									END,
								datStatisticStartDate = @datStatisticStartDate,
								datStatisticFinishDate = @datStatisticFinishDate,
								varValue = CAST(@varValue AS INT),
								idfsStatisticalAgeGroup = @idfsStatisticalAgeGroup
						 WHERE 	idfStatistic = @existingStatistic

						 --BEGIN: DataAudit-- 

							INSERT INTO @tlbStatistic_AfterEdit(
								idfStatistic,
								idfsStatisticDataType, 
								idfsMainBaseReference, 
								idfsStatisticAreaType, 
								idfsStatisticPeriodType, 
								idfsArea,
								datStatisticStartDate,
								datStatisticFinishDate,
								varValue,
								idfsStatisticalAgeGroup
								)
							SELECT 
								idfStatistic,
								idfsStatisticDataType, 
								idfsMainBaseReference, 
								idfsStatisticAreaType, 
								idfsStatisticPeriodType, 
								idfsArea,
								datStatisticStartDate,
								datStatisticFinishDate,
								varValue,
								idfsStatisticalAgeGroup				
								FROM tlbStatistic WHERE idfStatistic = @idfStatistic;

							--idfsStatisticDataType
							insert into dbo.tauDataAuditDetailUpdate(
								idfDataAuditEvent, 
								idfObjectTable, 
								idfColumn, 
								idfObject, 
								idfObjectDetail, 
								strOldValue, 
								strNewValue)
							select 
								@idfDataAuditEvent,
								@idfObjectTable_tlbStatistic, 
								80410000000,
								a.idfStatistic,
								null,
								a.idfsStatisticDataType,
								b.idfsStatisticDataType 
							from @tlbStatistic_BeforeEdit a  inner join @tlbStatistic_AfterEdit b on a.idfStatistic = b.idfStatistic
							where (a.idfsStatisticDataType <> b.idfsStatisticDataType) 
								or(a.idfsStatisticDataType is not null and b.idfsStatisticDataType is null)
								or(a.idfsStatisticDataType is null and b.idfsStatisticDataType is not null)

							--idfsMainBaseReference
							insert into dbo.tauDataAuditDetailUpdate(
								idfDataAuditEvent, 
								idfObjectTable, 
								idfColumn, 
								idfObject, 
								idfObjectDetail, 
								strOldValue, 
								strNewValue)
							select 
								@idfDataAuditEvent,
								@idfObjectTable_tlbStatistic, 
								4577930000000,
								a.idfStatistic,
								null,
								a.idfsMainBaseReference,
								b.idfsMainBaseReference 
							from @tlbStatistic_BeforeEdit a  inner join @tlbStatistic_AfterEdit b on a.idfStatistic = b.idfStatistic
							where (a.idfsMainBaseReference <> b.idfsMainBaseReference) 
								or(a.idfsMainBaseReference is not null and b.idfsMainBaseReference is null)
								or(a.idfsMainBaseReference is null and b.idfsMainBaseReference is not null)

							--idfsStatisticAreaType
							insert into dbo.tauDataAuditDetailUpdate(
								idfDataAuditEvent, 
								idfObjectTable, 
								idfColumn, 
								idfObject, 
								idfObjectDetail, 
								strOldValue, 
								strNewValue)
							select 
								@idfDataAuditEvent,
								@idfObjectTable_tlbStatistic, 
								80400000000,
								a.idfStatistic,
								null,
								a.idfsStatisticAreaType,
								b.idfsStatisticAreaType 
							from @tlbStatistic_BeforeEdit a  inner join @tlbStatistic_AfterEdit b on a.idfStatistic = b.idfStatistic
							where (a.idfsStatisticAreaType <> b.idfsStatisticAreaType) 
								or(a.idfsStatisticAreaType is not null and b.idfsStatisticAreaType is null)
								or(a.idfsStatisticAreaType is null and b.idfsStatisticAreaType is not null)

							--idfsStatisticPeriodType
							insert into dbo.tauDataAuditDetailUpdate(
								idfDataAuditEvent, 
								idfObjectTable, 
								idfColumn, 
								idfObject, 
								idfObjectDetail, 
								strOldValue, 
								strNewValue)
							select 
								@idfDataAuditEvent,
								@idfObjectTable_tlbStatistic, 
								80420000000,
								a.idfStatistic,
								null,
								a.idfsStatisticPeriodType,
								b.idfsStatisticPeriodType 
							from @tlbStatistic_BeforeEdit a  inner join @tlbStatistic_AfterEdit b on a.idfStatistic = b.idfStatistic
							where (a.idfsStatisticPeriodType <> b.idfsStatisticPeriodType) 
								or(a.idfsStatisticPeriodType is not null and b.idfsStatisticPeriodType is null)
								or(a.idfsStatisticPeriodType is null and b.idfsStatisticPeriodType is not null)

							--idfsArea
							insert into dbo.tauDataAuditDetailUpdate(
								idfDataAuditEvent, 
								idfObjectTable, 
								idfColumn, 
								idfObject, 
								idfObjectDetail, 
								strOldValue, 
								strNewValue)
							select 
								@idfDataAuditEvent,
								@idfObjectTable_tlbStatistic, 
								80390000000,
								a.idfStatistic,
								null,
								a.idfsArea,
								b.idfsArea 
							from @tlbStatistic_BeforeEdit a  inner join @tlbStatistic_AfterEdit b on a.idfStatistic = b.idfStatistic
							where (a.idfsArea <> b.idfsArea) 
								or(a.idfsArea is not null and b.idfsArea is null)
								or(a.idfsArea is null and b.idfsArea is not null)

							--datStatisticStartDate
							insert into dbo.tauDataAuditDetailUpdate(
								idfDataAuditEvent, 
								idfObjectTable, 
								idfColumn, 
								idfObject, 
								idfObjectDetail, 
								strOldValue, 
								strNewValue)
							select 
								@idfDataAuditEvent,
								@idfObjectTable_tlbStatistic, 
								80380000000,
								a.idfStatistic,
								null,
								a.datStatisticStartDate,
								b.datStatisticStartDate 
							from @tlbStatistic_BeforeEdit a  inner join @tlbStatistic_AfterEdit b on a.idfStatistic = b.idfStatistic
							where (a.datStatisticStartDate <> b.datStatisticStartDate) 
								or(a.datStatisticStartDate is not null and b.datStatisticStartDate is null)
								or(a.datStatisticStartDate is null and b.datStatisticStartDate is not null)
								
							--datStatisticFinishDate
							insert into dbo.tauDataAuditDetailUpdate(
								idfDataAuditEvent, 
								idfObjectTable, 
								idfColumn, 
								idfObject, 
								idfObjectDetail, 
								strOldValue, 
								strNewValue)
							select 
								@idfDataAuditEvent,
								@idfObjectTable_tlbStatistic, 
								80370000000,
								a.idfStatistic,
								null,
								a.datStatisticFinishDate,
								b.datStatisticFinishDate 
							from @tlbStatistic_BeforeEdit a  inner join @tlbStatistic_AfterEdit b on a.idfStatistic = b.idfStatistic
							where (a.datStatisticFinishDate <> b.datStatisticFinishDate) 
								or(a.datStatisticFinishDate is not null and b.datStatisticFinishDate is null)
								or(a.datStatisticFinishDate is null and b.datStatisticFinishDate is not null)

							--varValue
							insert into dbo.tauDataAuditDetailUpdate(
								idfDataAuditEvent, 
								idfObjectTable, 
								idfColumn, 
								idfObject, 
								idfObjectDetail, 
								strOldValue, 
								strNewValue)
							select 
								@idfDataAuditEvent,
								@idfObjectTable_tlbStatistic, 
								80440000000,
								a.idfStatistic,
								null,
								a.varValue,
								b.varValue 
							from @tlbStatistic_BeforeEdit a  inner join @tlbStatistic_AfterEdit b on a.idfStatistic = b.idfStatistic
							where (a.varValue <> b.varValue) 
								or(a.varValue is not null and b.varValue is null)
								or(a.varValue is null and b.varValue is not null)

							--idfsStatisticalAgeGroup
							insert into dbo.tauDataAuditDetailUpdate(
								idfDataAuditEvent, 
								idfObjectTable, 
								idfColumn, 
								idfObject, 
								idfObjectDetail, 
								strOldValue, 
								strNewValue)
							select 
								@idfDataAuditEvent,
								@idfObjectTable_tlbStatistic, 
								12014500000000,
								a.idfStatistic,
								null,
								a.idfsStatisticalAgeGroup,
								b.idfsStatisticalAgeGroup 
							from @tlbStatistic_BeforeEdit a  inner join @tlbStatistic_AfterEdit b on a.idfStatistic = b.idfStatistic
							where (a.idfsStatisticalAgeGroup <> b.idfsStatisticalAgeGroup) 
								or(a.idfsStatisticalAgeGroup is not null and b.idfsStatisticalAgeGroup is null)
								or(a.idfsStatisticalAgeGroup is null and b.idfsStatisticalAgeGroup is not null)

						--END: DataAudit-- 

				END

			-- update record with the passed in @idfStatistic (does not happen during bulk import)
			ELSE 

				--print '@idfStatistic was passed in (does not happen during bulk import)'

				--BEGIN: DataAudit-- 
				
					--  tauDataAuditEvent  Event Type - Edit 
					set @idfsDataAuditEventType = 10016003;
			
					-- insert record into tauDataAuditEvent - 
					INSERT INTO @SupressSelect
					EXEC USSP_GBL_DataAuditEvent_GET @idfUserId, @idfSiteId, @idfsDataAuditEventType, @idfsObjectType, @idfStatistic, @idfObjectTable_tlbStatistic, @idfDataAuditEvent OUTPUT						

					INSERT INTO @tlbStatistic_BeforeEdit(
						idfStatistic,
						idfsStatisticDataType, 
						idfsMainBaseReference, 
						idfsStatisticAreaType, 
						idfsStatisticPeriodType, 
						idfsArea,
						datStatisticStartDate,
						datStatisticFinishDate,
						varValue,
						idfsStatisticalAgeGroup
						)
					SELECT 
						idfStatistic,
						idfsStatisticDataType, 
						idfsMainBaseReference, 
						idfsStatisticAreaType, 
						idfsStatisticPeriodType, 
						idfsArea,
						datStatisticStartDate,
						datStatisticFinishDate,
						varValue,
						idfsStatisticalAgeGroup				
						FROM tlbStatistic WHERE idfStatistic = @idfStatistic;

				--END: DataAudit-- 

				UPDATE	tlbStatistic
				SET		idfsStatisticDataType = @idfsStatisticDataType,
						idfsMainBaseReference = @idfsMainBaseReference,
						idfsStatisticAreaType = @idfsStatisticAreaType,
						idfsStatisticPeriodType = @idfsStatisticPeriodType,
						idfsArea = CASE ISNULL(@LocationUserControlidfsSettlement , '') 
							WHEN '' THEN
								CASE ISNULL(@LocationUserControlidfsRayon, '') 
								WHEN '' THEN
									CASE ISNULL(@LocationUserControlidfsRegion,'')
										WHEN '' THEN
											@LocationUserControlidfsCountry 
										ELSE 
											@LocationUserControlidfsRegion
										END
								ELSE 
										@LocationUserControlidfsRayon 
								END 
							ELSE 
								@LocationUserControlidfsSettlement  
							END,
						datStatisticStartDate = @datStatisticStartDate,
						datStatisticFinishDate = @datStatisticFinishDate,
						varValue = CAST(@varValue AS INT),
						idfsStatisticalAgeGroup = @idfsStatisticalAgeGroup
				WHERE 	idfStatistic = @idfStatistic

				--BEGIN: DataAudit-- 

					INSERT INTO @tlbStatistic_AfterEdit(
						idfStatistic,
						idfsStatisticDataType, 
						idfsMainBaseReference, 
						idfsStatisticAreaType, 
						idfsStatisticPeriodType, 
						idfsArea,
						datStatisticStartDate,
						datStatisticFinishDate,
						varValue,
						idfsStatisticalAgeGroup
						)
					SELECT 
						idfStatistic,
						idfsStatisticDataType, 
						idfsMainBaseReference, 
						idfsStatisticAreaType, 
						idfsStatisticPeriodType, 
						idfsArea,
						datStatisticStartDate,
						datStatisticFinishDate,
						varValue,
						idfsStatisticalAgeGroup				
						FROM tlbStatistic WHERE idfStatistic = @idfStatistic;

					--idfsStatisticDataType
					insert into dbo.tauDataAuditDetailUpdate(
						idfDataAuditEvent, 
						idfObjectTable, 
						idfColumn, 
						idfObject, 
						idfObjectDetail, 
						strOldValue, 
						strNewValue)
					select 
						@idfDataAuditEvent,
						@idfObjectTable_tlbStatistic, 
						80410000000,
						a.idfStatistic,
						null,
						a.idfsStatisticDataType,
						b.idfsStatisticDataType 
					from @tlbStatistic_BeforeEdit a  inner join @tlbStatistic_AfterEdit b on a.idfStatistic = b.idfStatistic
					where (a.idfsStatisticDataType <> b.idfsStatisticDataType) 
						or(a.idfsStatisticDataType is not null and b.idfsStatisticDataType is null)
						or(a.idfsStatisticDataType is null and b.idfsStatisticDataType is not null)

					--idfsMainBaseReference
					insert into dbo.tauDataAuditDetailUpdate(
						idfDataAuditEvent, 
						idfObjectTable, 
						idfColumn, 
						idfObject, 
						idfObjectDetail, 
						strOldValue, 
						strNewValue)
					select 
						@idfDataAuditEvent,
						@idfObjectTable_tlbStatistic, 
						4577930000000,
						a.idfStatistic,
						null,
						a.idfsMainBaseReference,
						b.idfsMainBaseReference 
					from @tlbStatistic_BeforeEdit a  inner join @tlbStatistic_AfterEdit b on a.idfStatistic = b.idfStatistic
					where (a.idfsMainBaseReference <> b.idfsMainBaseReference) 
						or(a.idfsMainBaseReference is not null and b.idfsMainBaseReference is null)
						or(a.idfsMainBaseReference is null and b.idfsMainBaseReference is not null)

					--idfsStatisticAreaType
					insert into dbo.tauDataAuditDetailUpdate(
						idfDataAuditEvent, 
						idfObjectTable, 
						idfColumn, 
						idfObject, 
						idfObjectDetail, 
						strOldValue, 
						strNewValue)
					select 
						@idfDataAuditEvent,
						@idfObjectTable_tlbStatistic, 
						80400000000,
						a.idfStatistic,
						null,
						a.idfsStatisticAreaType,
						b.idfsStatisticAreaType 
					from @tlbStatistic_BeforeEdit a  inner join @tlbStatistic_AfterEdit b on a.idfStatistic = b.idfStatistic
					where (a.idfsStatisticAreaType <> b.idfsStatisticAreaType) 
						or(a.idfsStatisticAreaType is not null and b.idfsStatisticAreaType is null)
						or(a.idfsStatisticAreaType is null and b.idfsStatisticAreaType is not null)

					--idfsStatisticPeriodType
					insert into dbo.tauDataAuditDetailUpdate(
						idfDataAuditEvent, 
						idfObjectTable, 
						idfColumn, 
						idfObject, 
						idfObjectDetail, 
						strOldValue, 
						strNewValue)
					select 
						@idfDataAuditEvent,
						@idfObjectTable_tlbStatistic, 
						80420000000,
						a.idfStatistic,
						null,
						a.idfsStatisticPeriodType,
						b.idfsStatisticPeriodType 
					from @tlbStatistic_BeforeEdit a  inner join @tlbStatistic_AfterEdit b on a.idfStatistic = b.idfStatistic
					where (a.idfsStatisticPeriodType <> b.idfsStatisticPeriodType) 
						or(a.idfsStatisticPeriodType is not null and b.idfsStatisticPeriodType is null)
						or(a.idfsStatisticPeriodType is null and b.idfsStatisticPeriodType is not null)

					--idfsArea
					insert into dbo.tauDataAuditDetailUpdate(
						idfDataAuditEvent, 
						idfObjectTable, 
						idfColumn, 
						idfObject, 
						idfObjectDetail, 
						strOldValue, 
						strNewValue)
					select 
						@idfDataAuditEvent,
						@idfObjectTable_tlbStatistic, 
						80390000000,
						a.idfStatistic,
						null,
						a.idfsArea,
						b.idfsArea 
					from @tlbStatistic_BeforeEdit a  inner join @tlbStatistic_AfterEdit b on a.idfStatistic = b.idfStatistic
					where (a.idfsArea <> b.idfsArea) 
						or(a.idfsArea is not null and b.idfsArea is null)
						or(a.idfsArea is null and b.idfsArea is not null)

					--datStatisticStartDate
					insert into dbo.tauDataAuditDetailUpdate(
						idfDataAuditEvent, 
						idfObjectTable, 
						idfColumn, 
						idfObject, 
						idfObjectDetail, 
						strOldValue, 
						strNewValue)
					select 
						@idfDataAuditEvent,
						@idfObjectTable_tlbStatistic, 
						80380000000,
						a.idfStatistic,
						null,
						a.datStatisticStartDate,
						b.datStatisticStartDate 
					from @tlbStatistic_BeforeEdit a  inner join @tlbStatistic_AfterEdit b on a.idfStatistic = b.idfStatistic
					where (a.datStatisticStartDate <> b.datStatisticStartDate) 
						or(a.datStatisticStartDate is not null and b.datStatisticStartDate is null)
						or(a.datStatisticStartDate is null and b.datStatisticStartDate is not null)
								
					--datStatisticFinishDate
					insert into dbo.tauDataAuditDetailUpdate(
						idfDataAuditEvent, 
						idfObjectTable, 
						idfColumn, 
						idfObject, 
						idfObjectDetail, 
						strOldValue, 
						strNewValue)
					select 
						@idfDataAuditEvent,
						@idfObjectTable_tlbStatistic, 
						80370000000,
						a.idfStatistic,
						null,
						a.datStatisticFinishDate,
						b.datStatisticFinishDate 
					from @tlbStatistic_BeforeEdit a  inner join @tlbStatistic_AfterEdit b on a.idfStatistic = b.idfStatistic
					where (a.datStatisticFinishDate <> b.datStatisticFinishDate) 
						or(a.datStatisticFinishDate is not null and b.datStatisticFinishDate is null)
						or(a.datStatisticFinishDate is null and b.datStatisticFinishDate is not null)

					--varValue
					insert into dbo.tauDataAuditDetailUpdate(
						idfDataAuditEvent, 
						idfObjectTable, 
						idfColumn, 
						idfObject, 
						idfObjectDetail, 
						strOldValue, 
						strNewValue)
					select 
						@idfDataAuditEvent,
						@idfObjectTable_tlbStatistic, 
						80440000000,
						a.idfStatistic,
						null,
						a.varValue,
						b.varValue 
					from @tlbStatistic_BeforeEdit a  inner join @tlbStatistic_AfterEdit b on a.idfStatistic = b.idfStatistic
					where (a.varValue <> b.varValue) 
						or(a.varValue is not null and b.varValue is null)
						or(a.varValue is null and b.varValue is not null)

					--idfsStatisticalAgeGroup
					insert into dbo.tauDataAuditDetailUpdate(
						idfDataAuditEvent, 
						idfObjectTable, 
						idfColumn, 
						idfObject, 
						idfObjectDetail, 
						strOldValue, 
						strNewValue)
					select 
						@idfDataAuditEvent,
						@idfObjectTable_tlbStatistic, 
						12014500000000,
						a.idfStatistic,
						null,
						a.idfsStatisticalAgeGroup,
						b.idfsStatisticalAgeGroup 
					from @tlbStatistic_BeforeEdit a  inner join @tlbStatistic_AfterEdit b on a.idfStatistic = b.idfStatistic
					where (a.idfsStatisticalAgeGroup <> b.idfsStatisticalAgeGroup) 
						or(a.idfsStatisticalAgeGroup is not null and b.idfsStatisticalAgeGroup is null)
						or(a.idfsStatisticalAgeGroup is null and b.idfsStatisticalAgeGroup is not null)

				--END: DataAudit-- 

		-- Commit the transaction
		IF @@TRANCOUNT > 0
			COMMIT  
		
		Select @returnCode 'ReturnCode', @returnMsg 'ReturnMessage' , @idfStatistic 'idfStatistic'
	END TRY  

	BEGIN CATCH  

		-- Execute error retrieval routine. 
		IF @@TRANCOUNT > 0
			BEGIN
				ROLLBACK


			END;
			Throw;		
	END CATCH; 
END


