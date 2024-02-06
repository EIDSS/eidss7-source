
-- ================================================================================================
-- Name: [USP_HUM_HUMAN_GETHumanFromHumanActual]
-- Description:	Get human Records from the HumanActualId
--          
-- Revision History:
-- Name            Date       Change Detail
-- --------------- ---------- --------------------------------------------------------------------
--Lamont Mitchell	3/11/2020	Initial
-- ================================================================================================
Create PROCEDURE [dbo].[USP_HUM_HUMAN_GETHumanFromHumanActual]
(
	@LangId			NVARCHAR(20),
	@idfHumanActual BIGINT
)
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
	Select
	top(1)
	[idfHuman], 
	[idfHumanActual], 
	[idfsOccupationType], 
	[idfsNationality], 
	[idfsHumanGender], 
	[idfCurrentResidenceAddress],
	[idfEmployerAddress], 
	[idfRegistrationAddress], 
	[datDateofBirth], 
	[datDateOfDeath], 
	[strLastName], 
	[strSecondName], 
	[strFirstName], 
	[strRegistrationPhone], 
	[strEmployerName], 
	[strHomePhone], 
	[strWorkPhone], 
	[rowguid], 
	[intRowStatus], 
	[idfsPersonIDType], 
	[strPersonID], 
	[blnPermantentAddressAsCurrent], 
	[datEnteredDate], 
	[datModificationDate], 
	[datModificationForArchiveDate], 
	[strMaintenanceFlag], 
	[strReservedAttribute], 
	[idfsSite], 
	[idfMonitoringSession], 
	[SourceSystemNameID], 
	[SourceSystemKeyValue], 
	[AuditCreateUser], 
	[AuditCreateDTM], 
	[AuditUpdateUser], 
	[AuditUpdateDTM]
	
	From tlbHuman 
	where idfHumanActual = @idfHumanActual
	And intRowStatus = 0
	Order By datEnteredDate desc
	END TRY
	BEGIN CATCH
		;THROW;
	END CATCH
END
