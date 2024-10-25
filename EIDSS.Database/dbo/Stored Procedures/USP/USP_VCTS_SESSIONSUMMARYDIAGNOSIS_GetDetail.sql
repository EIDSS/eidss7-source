--*************************************************************
-- Name 				: USP_VCTS_SESSIONSUMMARYDIAGNOSIS_GetDetail
-- Description			: Get Vector Surveillance Session Summary Diagnosis Details
--          
-- Author               : Mandar Kulkarni
-- Revision History
--		Name		Date		Change Detail
--	Lamont Mitchell	12-20-21	Modified to work with POCO . Removed multiple selects
--	Mike Kornegay	05/11/2022	Added TotalRowCount
--	Mike Kornegay	05/15/2022	Changed idfDiagnosis and strDiagnosis to DiseaseID and DiseaseName
--
-- Testing code:
--EXECUTE USP_VCTS_SESSIONSUMMARYDIAGNOSIS_GetDetail @idfsVSSessionSummary,'en'
--*************************************************************
CREATE  PROCEDURE [dbo].[USP_VCTS_SESSIONSUMMARYDIAGNOSIS_GetDetail]
(
	@idfsVSSessionSummary	BIGINT,--##PARAM @idfVectorSurveillanceSession - session ID
	@LangID					NVARCHAR(50)--##PARAM @LangID - language ID
)
AS
BEGIN
	DECLARE @returnMsg VARCHAR(MAX) = 'Success'
	DECLARE @returnCode BIGINT = 0

	BEGIN TRY  	

		SELECT		Vssd.[idfsVSSessionSummaryDiagnosis]
					,Vssd.[idfsVSSessionSummary]
					,Vssd.[idfsDiagnosis] AS DiseaseID     
					,D.name AS DiseaseName
					,Vssd.[intPositiveQuantity]
					,Vssd.[rowguid]
					,Vssd.[intRowStatus]
					,COUNT(*) OVER(PARTITION BY 1) AS TotalRowCount
		FROM		dbo.tlbVectorSurveillanceSessionSummaryDiagnosis Vssd
		INNER JOIN	dbo.FN_GBL_Reference_GETList(@LangID, 19000019) D ON Vssd.[idfsDiagnosis] = D.idfsReference 
		WHERE		Vssd.idfsVSSessionSummary  = @idfsVSSessionSummary And Vssd.intRowStatus = 0	  	
	
	END TRY  

	BEGIN CATCH 
Throw;
	END CATCH
END

