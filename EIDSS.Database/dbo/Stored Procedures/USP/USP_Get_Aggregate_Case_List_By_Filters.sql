

--*************************************************************
-- Name 				: [[USP_Get_Aggregate_Case_List_By_Filters]]
-- Description			: Returns list of aggregate cases depending on case type and matrixVersion.
--          
-- Author               : Lamont Mitchell


--
-- Legends
/*
	Case Type
	AggregateCase = 10102001
	VetAggregateCase = 10102002
	VetAggregateAction = 10102003
*/

/* Statistic period types
    None = 0
    Month = 10091001
    Day = 10091002
    Quarter = 10091003
    Week = 10091004
    Year = 10091005

*/
/*
StatisticAreaType
    None = 0
    Country = 10089001
    Rayon = 10089002
    Region = 10089003
    Settlement = 10089004
*/

/* Aggregate Case Type
    HumanAggregateCase = 10102001
    VetAggregateCase = 10102002
    VetAggregateAction = 10102003
	exec USP_AGG_CASE_GETLIST 'en', @idfsAggrCaseType=10102001
*/ 
--*************************************************************
  

CREATE PROCEDURE [dbo].[USP_Get_Aggregate_Case_List_By_Filters]
	(
	  @UserId								Varchar(max) = Null,
	  @idfAggrCase							BigInt = Null,
	  @idfsAggrCaseType						BigInt = Null,
	  @idfsAdministrativeUnit				BigInt = Null,
      @idfReceivedByOffice					BigInt = Null,
      @idfReceivedByPerson					BigInt = Null,
      @idfSentByOffice						BigInt = Null,
      @idfSentByPerson						BigInt = Null,
      @idfEnteredByOffice					BigInt = Null,
      @idfEnteredByPerson					BigInt = Null,
      @idfCaseObservation					BigInt = Null,
      @idfDiagnosticObservation				BigInt = Null,
      @idfProphylacticObservation			BigInt = Null,
      @idfSanitaryObservation				BigInt = Null,
      @idfVersion							BigInt = Null,
      @idfDiagnosticVersion					BigInt = Null,
      @idfProphylacticVersion				BigInt = Null,
      @idfSanitaryVersion					BigInt = Null,
      @datReceivedByDate					DateTime = Null,
      @datSentByDate						DateTime = Null,
      @datEnteredByDate						DateTime = Null,
      @datStartDate							DateTime = Null,
      @datFinishDate						DateTime = Null,
      @strCaseID							VarChar(max) = Null
	
	)
AS

DECLARE @returnCode	INT = 0 
DECLARE	@returnMsg	NVARCHAR(max) = 'SUCCESS' 

BEGIN
	BEGIN TRY

 


IF EXISTS (Select  Top(1) * from  [tlbAggrCase] where  [idfVersion] = @idfVersion AND  [idfCaseObservation] = @idfCaseObservation)

	BEGIN

	SELECT 	[idfAggrCase]
      ,[idfsAggrCaseType]
      ,[idfsAdministrativeUnit]
      ,[idfReceivedByOffice]
      ,[idfReceivedByPerson]
      ,[idfSentByOffice]
      ,[idfSentByPerson]
      ,[idfEnteredByOffice]
      ,[idfEnteredByPerson]
      ,[idfCaseObservation]
      ,[idfDiagnosticObservation]
      ,[idfProphylacticObservation]
      ,[idfSanitaryObservation]
      ,[idfVersion]
      ,[idfDiagnosticVersion]
      ,[idfProphylacticVersion]
      ,[idfSanitaryVersion]
      ,[datReceivedByDate]
      ,[datSentByDate]
      ,[datEnteredByDate]
      ,[datStartDate]
      ,[datFinishDate]
      ,[strCaseID]
      ,[intRowStatus]
      ,[rowguid]
      ,[datModificationForArchiveDate]
      ,[strMaintenanceFlag]
      ,[strReservedAttribute]
      ,[idfsSite]
      ,[SourceSystemNameID]
      ,[SourceSystemKeyValue]
      ,[AuditCreateUser]
      ,[AuditCreateDTM]
      ,[AuditUpdateUser]
      ,[AuditUpdateDTM]
  FROM .[dbo].[tlbAggrCase]
		WHERE	 
		([idfVersion] = @idfVersion)  AND ([idfCaseObservation] = @idfCaseObservation) --AND ([intRowStatus] = 0)
	
	END
	ELSE
	BEGIN

	SELECT 	[idfAggrCase]
      ,[idfsAggrCaseType]
      ,[idfsAdministrativeUnit]
      ,[idfReceivedByOffice]
      ,[idfReceivedByPerson]
      ,[idfSentByOffice]
      ,[idfSentByPerson]
      ,[idfEnteredByOffice]
      ,[idfEnteredByPerson]
      ,[idfCaseObservation]
      ,[idfDiagnosticObservation]
      ,[idfProphylacticObservation]
      ,[idfSanitaryObservation]
      ,[idfVersion]
      ,[idfDiagnosticVersion]
      ,[idfProphylacticVersion]
      ,[idfSanitaryVersion]
      ,[datReceivedByDate]
      ,[datSentByDate]
      ,[datEnteredByDate]
      ,[datStartDate]
      ,[datFinishDate]
      ,[strCaseID]
      ,[intRowStatus]
      ,[rowguid]
      ,[datModificationForArchiveDate]
      ,[strMaintenanceFlag]
      ,[strReservedAttribute]
      ,[idfsSite]
      ,[SourceSystemNameID]
      ,[SourceSystemKeyValue]
      ,[AuditCreateUser]
      ,[AuditCreateDTM]
      ,[AuditUpdateUser]
      ,[AuditUpdateDTM]
  FROM .[dbo].[tlbAggrCase]
		WHERE	 
		([idfVersion] = @idfVersion) --AND ([intRowStatus] = 0)

	END
	END TRY  

	BEGIN CATCH 
	Throw;

	END CATCH
END
