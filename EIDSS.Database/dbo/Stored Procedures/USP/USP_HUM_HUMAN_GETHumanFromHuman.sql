
-- ================================================================================================
-- Name: [USP_HUM_HUMAN_GETHumanFromHumanActual]
-- Description:	Get human Records from the humanId HumanTable
--          
-- Revision History:
-- Name            Date       Change Detail
-- --------------- ---------- --------------------------------------------------------------------
--Lamont Mitchell	10/15yy/2020	Initial
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_HUM_HUMAN_GETHumanFromHuman]
(
	@LangId			NVARCHAR(20),
	@IdfHuman BIGINT
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
	where idfHuman = @IdfHuman
	And intRowStatus = 0
	Order By datEnteredDate desc
	END TRY
	BEGIN CATCH
		;THROW;
	END CATCH
END
