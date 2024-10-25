

CREATE FUNCTION [dbo].[FN_GBL_EventLog_ObjectType_Get]
(
	@idfsEventType BIGINT
)
RETURNS NVARCHAR(50)
AS
BEGIN
RETURN CASE 
	WHEN @idfsEventType = 10025030	
	THEN N'Settlement'--Settlement Changed

	WHEN @idfsEventType IN 
	(
		SELECT 
			idfsBaseReference 
		FROM dbo.trtBaseReference
		WHERE idfsReferenceType = 19000025
		AND LOWER(strDefault) LIKE '%human disease report%' 
		AND intRowStatus = 0
	)
	THEN N'HumanDiseaseReport'

	WHEN @idfsEventType IN 
	(
		SELECT 
			idfsBaseReference

		FROM dbo.trtBaseReference 
		WHERE idfsReferenceType = 19000025
		AND LOWER(strDefault) LIKE '%outbreak%' 
		AND intRowStatus = 0		
	)
	THEN N'Outbreak'

	WHEN @idfsEventType IN 
	(
		SELECT 
			idfsBaseReference

		FROM dbo.trtBaseReference 
		WHERE idfsReferenceType = 19000025
		AND LOWER(strDefault) LIKE '%veterinary disease report%' 
		AND LOWER(strDefault) NOT LIKE '%outbreak%'
		AND intRowStatus = 0
	)
	THEN N'VetDiseaseReport'

	WHEN @idfsEventType IN 	
	(
		SELECT 
			idfsBaseReference

		FROM dbo.trtBaseReference 
		WHERE idfsReferenceType = 19000025 
		AND LOWER(strDefault) LIKE '%vector surveillance session%'
		AND LOWER(strDefault) NOT LIKE '%outbreak%'
		AND intRowStatus = 0
	)

	THEN N'VsSession'


	WHEN @idfsEventType IN 
	(
		SELECT 
			idfsBaseReference

		FROM dbo.trtBaseReference 
		WHERE idfsReferenceType = 19000025 
		AND LOWER(strDefault) LIKE '%human active surveillance session%' 
		AND LOWER(strDefault) NOT LIKE '%outbreak%'
		AND intRowStatus = 0
	)
	THEN N'HumanASSession'

	WHEN @idfsEventType IN 
	(
		SELECT 
			idfsBaseReference

		FROM dbo.trtBaseReference 
		WHERE idfsReferenceType = 19000025 
		AND LOWER(strDefault) LIKE '%veterinary active surveillance session%' 
		AND LOWER(strDefault) NOT LIKE '%outbreak%'
		AND intRowStatus = 0
	)
	THEN N'VetASSession'


	WHEN @idfsEventType IN 
	(
		SELECT 
			idfsBaseReference

		FROM dbo.trtBaseReference 
		WHERE idfsReferenceType = 19000025
		AND LOWER(strDefault) LIKE '%human active surveillance campaign%'
		AND LOWER(strDefault) NOT LIKE '%outbreak%'
		AND intRowStatus = 0
	)
	THEN N'HumanASCampaign'

	WHEN @idfsEventType IN 
	(
		SELECT 
			idfsBaseReference

		FROM dbo.trtBaseReference 
		WHERE idfsReferenceType = 19000025
		AND LOWER(strDefault) LIKE '%veterinary active surveillance campaign%'
		AND LOWER(strDefault) NOT LIKE '%outbreak%'
		AND intRowStatus = 0
	)
	THEN N'VetASCampaign'

	WHEN @idfsEventType IN 
	(
		SELECT 
			idfsBaseReference

		FROM dbo.trtBaseReference 
		WHERE idfsReferenceType = 19000025
		AND LOWER(strDefault) LIKE '%human aggregate disease report%'
		AND LOWER(strDefault) NOT LIKE '%outbreak%'
		AND intRowStatus = 0
	)
	THEN N'HumanAggrDiseaseReport'

	WHEN @idfsEventType IN 
	(
		SELECT 
			idfsBaseReference

		FROM dbo.trtBaseReference 
		WHERE idfsReferenceType = 19000025
		AND LOWER(strDefault) LIKE '%veterinary aggregate disease report%'
		AND LOWER(strDefault) NOT LIKE '%outbreak%'
		AND intRowStatus = 0
	)
	THEN N'VetAggrDiseaseReport'

	WHEN @idfsEventType IN 
	(
		SELECT 
			idfsBaseReference

		FROM dbo.trtBaseReference 
		WHERE idfsReferenceType = 19000025
		AND LOWER(strDefault) LIKE '%veterinary aggregate action%'
		AND intRowStatus = 0
	)
	THEN N'VetAggrAction'


	WHEN @idfsEventType IN 
	(
		SELECT 
			idfsBaseReference

		FROM dbo.trtBaseReference 
		WHERE idfsReferenceType = 19000025
		AND LOWER(strDefault) LIKE '%aggregate settings%'
		AND intRowStatus = 0
	)
	THEN N'AggregateSettings'

	WHEN @idfsEventType IN 
	(
		SELECT 
			idfsBaseReference

		FROM dbo.trtBaseReference 
		WHERE idfsReferenceType = 19000025
		AND LOWER(strDefault) LIKE '%security policy%'
		AND intRowStatus = 0
	)
	THEN N'SecurityPolicy'

	WHEN @idfsEventType IN 
	(
		SELECT 
			idfsBaseReference

		FROM dbo.trtBaseReference 
		WHERE idfsReferenceType = 19000025
		AND LOWER(strDefault) LIKE '%flexible form%'
		AND intRowStatus = 0
	)
	THEN N'FFDesigner'

	WHEN @idfsEventType IN 
	(
		SELECT 
			idfsBaseReference

		FROM dbo.trtBaseReference 
		WHERE idfsReferenceType = 19000025
		AND LOWER(strDefault) LIKE '%reference table%'
		AND intRowStatus = 0
	)
	THEN N'Reference'

	WHEN @idfsEventType IN 
	(
		SELECT 
			idfsBaseReference

		FROM dbo.trtBaseReference 
		WHERE idfsReferenceType = 19000025
		AND LOWER(strDefault) LIKE '%matrix%'
		AND intRowStatus = 0
	)
	THEN N'Matrix'

	WHEN @idfsEventType IN 
	(
		SELECT 
			idfsBaseReference

		FROM dbo.trtBaseReference 
		WHERE idfsReferenceType = 19000025
		AND LOWER(strDefault) LIKE '%sample%transfer%'
		AND LOWER(strDefault) NOT LIKE '%test%'
		AND intRowStatus = 0
	)
	THEN N'SampleTransfer'

	WHEN @idfsEventType IN 
	(
		SELECT 
			idfsBaseReference

		FROM dbo.trtBaseReference 
		WHERE idfsReferenceType = 19000025
		AND LOWER(strDefault) LIKE '%sample%transfer%'
		AND LOWER(strDefault) LIKE '%test%'
		AND intRowStatus = 0
	)
	THEN N'Test'

	WHEN @idfsEventType IN 
	(
		SELECT 
			idfsBaseReference

		FROM dbo.trtBaseReference 
		WHERE idfsReferenceType = 19000025
		AND LOWER(strDefault) LIKE '%ili%'
		AND intRowStatus = 0
	)
	THEN N'BssForm'

	WHEN @idfsEventType IN 
	(
		SELECT 
			idfsBaseReference

		FROM dbo.trtBaseReference 
		WHERE idfsReferenceType = 19000025
		AND LOWER(strDefault) LIKE '%ili aggregate%'
	)
	THEN N'BssAggrForm' -- read only

	ELSE

		N''
	END

END

