
CREATE FUNCTION [dbo].[FN_GBL_EventLog_DiagnosisForObject_GET]
(
	@idfsEventTypeID BIGINT,
	@idfObject BIGINT
)
RETURNS BIGINT
AS
BEGIN
	DECLARE @idfsDiagnosis BIGINT
	DECLARE @ObjectName NVARCHAR(50)
	SELECT @ObjectName = [dbo].FN_GBL_EventLog_ObjectType_Get(@idfsEventTypeID)
	IF @ObjectName = N'HumanDiseaseReport'
	BEGIN
		SELECT @idfsDiagnosis = idfsFinalDiagnosis FROM tlbHumanCase WHERE idfHumanCase = @idfObject --AND intRowStatus = 0
	END
	ELSE IF @ObjectName = N'VetDiseaseReport'
	BEGIN
		SELECT @idfsDiagnosis = idfsShowDiagnosis FROM tlbVetCase WHERE idfVetCase = @idfObject
	END
	RETURN @idfsDiagnosis
END

