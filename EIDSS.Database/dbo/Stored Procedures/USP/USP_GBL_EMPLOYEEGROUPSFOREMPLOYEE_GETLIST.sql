--	==================================================================================================
--
--	Name 				: USP_GBL_EMPLOYEEGROUPSFOREMPLOYEE_GETLIST
--	Description			: Input: personid, languageid; Output: person list, group list
--          
--	Author               : Ricky Moss
--
--	Revision History
--	Name			Date			Change Detail
--	Ricky Moss		11/14/2019		Initial Release
--
--	exec USP_GBL_EMPLOYEEGROUPSFOREMPLOYEE_GETLIST -485, 'en'
--
--====================================================================================================
CREATE PROCEDURE [dbo].[USP_GBL_EMPLOYEEGROUPSFOREMPLOYEE_GETLIST]
( 
	@idfPerson AS BIGINT, --##PARAM @idfPerson - person ID
	@LangID NVARCHAR(50) --##PARAM @LangID - language ID
)
AS
BEGIN
	BEGIN TRY
		SELECT	EG.idfEmployeeGroup,
				EG.idfsEmployeeGroupName,
				E.idfEmployee,
				ISNULL(GroupName.name,EG.strName) AS strName,
				EG.strDescription
		FROM	dbo.tlbEmployeeGroup EG
		INNER JOIN	dbo.tlbEmployeeGroupMember EM ON	
					EM.idfEmployeeGroup=EG.idfEmployeeGroup
		INNER JOIN	dbo.tlbEmployee E ON 
					E.idfEmployee=EM.idfEmployee
		LEFT JOIN	FN_GBL_ReferenceRepair(@LangID, 19000022) GroupName ON GroupName.idfsReference = EG.idfsEmployeeGroupName
		WHERE	E.intRowStatus=0 
		AND		EG.idfEmployeeGroup<>-1 
		AND		EG.intRowStatus=0
		AND		EM.intRowStatus = 0
		AND		E.idfEmployee = @idfPerson
	END TRY
	BEGIN CATCH
		THROW
	END CATCH
END
