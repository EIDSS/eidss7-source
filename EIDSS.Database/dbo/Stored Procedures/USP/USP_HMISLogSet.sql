-- =============================================
-- Author:		Steven L. Verner
-- Create date: 08.26.2020
-- Description:	Posts a entry into the HMIS Log
-- Allowed actions are 4 - add record, 8 - delete record, 16 - modify record
-- =============================================
CREATE PROCEDURE [dbo].[USP_HMISLogSet] 
	-- Add the parameters for the stored procedure here
	 @action int = 0
	,@hmisLog bigint = 0
	,@importDate datetime
	,@strHMISCaseID nvarchar(36)
	,@strHMISICD10Code nvarchar(36)
	,@strHMISPatientLastName nvarchar(128)
	,@strHMISRegionID nvarchar(36)
	,@strHMISRayonID nvarchar(36)
	,@intStatus int
	,@strComments nvarchar(256)
	,@idfsHumanCase bigint

AS
BEGIN
	SET NOCOUNT ON;
	IF @Action = 4 --insert
	BEGIN
		INSERT INTO hmisLog
			   (
				datImport,
				strHmisCaseId,
				strHmisICD10Code,
				strHmisPatientLastName,
				strHmisRegionId,
				strHmisRayonId,
				intStatus,
				strComments,
				idfsHumanCase
				)
		 VALUES
			   (
				@importDate,
				@strHmisCaseId,
				@strHmisICD10Code,
				@strHmisPatientLastName,
				@strHmisRegionId,
				@strHmisRayonId,
				@intStatus,
				@strComments,
				@idfsHumanCase
			   )
	END
	ELSE IF @Action=16 --Update
	BEGIN
		UPDATE hmisLog
		   SET 
				datImport = @importDate,
				strHmisCaseId = @strHmisCaseId,
				strHmisICD10Code = @strHmisICD10Code,
				strHmisPatientLastName = @strHmisPatientLastName,
				strHmisRegionId = @strHmisRegionId,
				strHmisRayonId = @strHmisRayonId,
				intStatus = @intStatus,
				strComments = @strComments,
				idfsHumanCase = @idfsHumanCase
		 WHERE 
			hmisLog=@hmisLog
	END
END
