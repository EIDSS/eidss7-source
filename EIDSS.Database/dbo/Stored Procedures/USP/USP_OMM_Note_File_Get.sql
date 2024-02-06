
--*************************************************************
-- Name: [USP_OMM_Session_Note_GetDetail]
-- Description: Insert/Update for Outbreak Session Note
--          
-- Author: Doug Albanese
-- Revision History
--	Name			Date		Change Detail
--	Doug Albanese	10/15/2021	Refactored for proper EF generation
--	Doug Albanese	10/19/2021	Added content type to the return
--*************************************************************
CREATE PROCEDURE [dbo].[USP_OMM_Note_File_Get]
(    
	@idfOutbreakNote	BIGINT
)
AS

BEGIN    

	SELECT
		UploadFileName,
		UploadFileObject,
		DocumentContentType
	FROM		
		tlbOutbreakNote 
	where 
		idfOutbreakNote =	@idfOutbreakNote

END
