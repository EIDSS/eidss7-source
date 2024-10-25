
--*************************************************************
-- Name 				: USP_AGG_OBSERVATION_SET
-- Description			: Saves observation with its flexible form template.
--          
-- Author               : Maheshwar Deo
-- Revision History
--		Name       Date       Change Detail
--Manickandan Govindarajan 12/06/2022 SAUC30 and 31
--
-- Testing code:
--*************************************************************
  
CREATE PROCEDURE [dbo].[USP_AGG_OBSERVATION_SET]
	(	 
	@idfObservation		BIGINT	--##PARAM @idfObservation Observation Id
	,@idfsFormTemplate	BIGINT	--##PARAM @idfsFormTemplate Id of flexible form template (reference to ffFormTemplate)
	,@idfDataAuditEvent BIGINT
	)
AS

	declare @idfObjectTable_tlbObservationTable bigint =75640000000;
	declare @idfObjectTable_tlbObservation bigint =80060000000;
	declare @idfsFormTemplateValue bigint =80070000000;

	DECLARE @tlbObservation_BeforeEdit TABLE
	(
		idfObservation bigint,
		idfsFormTemplate bigint
	)
	DECLARE @tlbObservation_AfterEdit TABLE
	(
		idfObservation bigint,
		idfsFormTemplate bigint	)

		
	DECLARE @tlbActivityParameter_BeforeEdit TABLE
	(
		idfActivityParameters bigint,
		idfsParameter bigint,
		idfObservation bigint,
		idfRow bigint,
		varValue sql_variant
	)

	DECLARE @tlbActivityParameter_AftereEdit TABLE
	(
	idfActivityParameters bigint,
		idfsParameter bigint,
		idfObservation bigint,
		idfRow bigint,
		varValue sql_variant
	)
	--Data Audit--



BEGIN

	BEGIN TRY  	

		IF (@idfObservation IS NULL) RETURN;

		-- Post tlbObservation
		IF EXISTS (SELECT * FROM tlbObservation WHERE idfObservation = @idfObservation)
			BEGIN

				--insert into @tlbObservation_BeforeEdit (idfObservation,idfsFormTemplate)
				--select idfObservation, idfsFormTemplate from tlbObservation where idfObservation =@idfObservation;

				UPDATE	
					tlbObservation
				SET		
					idfsFormTemplate = @idfsFormTemplate
				WHERE	
					idfObservation = @idfObservation
					AND 
					ISNULL(idfsFormTemplate,0) != ISNULL(@idfsFormTemplate,0)

				----Data Audit--
				--insert into @tlbObservation_AfterEdit (idfObservation,idfsFormTemplate)
				--select idfObservation, idfsFormTemplate from tlbObservation where idfObservation =@idfObservation;

				--insert into dbo.tauDataAuditDetailUpdate(idfDataAuditEvent, idfObjectTable, idfColumn, 
				--	idfObject, idfObjectDetail, strOldValue, strNewValue)
				--select @idfDataAuditEvent,@idfObjectTable_tlbObservationTable,80070000000,
				--	a.idfObservation, null,a.idfsFormTemplate, b.idfsFormTemplate
				--from @tlbObservation_BeforeEdit a  inner join @tlbObservation_AfterEdit b on a.idfObservation = b.idfObservation
				--where (a.idfsFormTemplate <> b.idfsFormTemplate) 
				--	or(a.idfsFormTemplate is not null and b.idfsFormTemplate is null)
				--	or(a.idfsFormTemplate is null and b.idfsFormTemplate is not null)
					
				--Data Audit--
					
			END
		ELSE 
			BEGIN
				INSERT INTO	tlbObservation
					(	
					idfObservation,
					idfsFormTemplate
					)
				VALUES
					(	
					@idfObservation,
					@idfsFormTemplate
					)
				
				----Data Audit--
				--INSERT INTO tauDataAuditDetailCreate(idfDataAuditEvent, idfObjectTable, idfObject )
				--values ( @idfDataAuditEvent, @idfObjectTable_tlbObservationTable, @idfObservation)
				
				----Data Audit--

			END
	END TRY  

	BEGIN CATCH 

		DECLARE @ErrorMessage NVARCHAR(4000);  
		DECLARE @ErrorSeverity INT;  
		DECLARE @ErrorState INT;  

		SELECT   
			@ErrorMessage = ERROR_MESSAGE()
			,@ErrorSeverity = ERROR_SEVERITY()
			,@ErrorState = ERROR_STATE()

		RAISERROR 
			(
			@ErrorMessage,	-- Message text.  
			@ErrorSeverity, -- Severity.  
			@ErrorState		-- State.  
			); 
	END CATCH
END