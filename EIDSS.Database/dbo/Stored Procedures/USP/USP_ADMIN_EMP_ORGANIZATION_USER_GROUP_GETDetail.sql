

-- ================================================================================================
-- Name: USP_ADMIN_EMP_ORGANIZATION_USER_GROUP_GETDetail	
-- 
-- Description: Returns Detailed information for an Employee Organization.
--
-- Revision History:
--		
-- Name				Date       	Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Ann Xiong     		08/24/2020 	Initial release.
-- Ann Xiong     		09/01/2020  Changed to consider default Organization
-- Ann Xiong     		09/08/2020  Rearranged scripts to return UserGroupID and UserGroup, added strContactPhone to select 
--
-- Testing Code:
-- EXEC USP_ADMIN_EMP_ORGANIZATION_USER_GROUP_GETDetail --452, 3, 'en'
-- ================================================================================================
CREATE   PROCEDURE [dbo].[USP_ADMIN_EMP_ORGANIZATION_USER_GROUP_GETDetail]
( 
	@idfPerson 	BIGINT,
	@idfOffice	BIGINT, 	--##PARAM @idfOffice - organization ID
	@LangID		NVARCHAR(50) --##PARAM @LangID - language ID
)
AS
BEGIN
	DECLARE @returnMsg						VARCHAR(MAX) = 'SUCCESS';
	DECLARE @returnCode						BIGINT = 0;

	BEGIN TRY  	

		SELECT	p.idfPerson,
				p.idfInstitution,
				o.name AS strOrganizationName,
				s.idfsSite,
				s.strSiteID AS SiteID,
				s.strSiteName AS SiteName,
				p.idfDepartment,
				dept.name AS strDepartmentName,
				p.idfsStaffPosition,
				p.strContactPhone,
				sp.name AS strStaffPosition,
				STRING_AGG(g.idfEmployeeGroup, ', ') WITHIN GROUP (ORDER BY g.idfEmployeeGroup DESC ) AS UserGroupID,
				STRING_AGG(g.strName, ', ') AS UserGroup,
				ut.idfUserID
		FROM	tlbPerson p
				INNER JOIN 	tlbEmployee e 
					ON p.idfPerson = e.idfEmployee
				INNER JOIN 	tstUserTable ut
					ON ut.idfPerson = e.idfEmployee
				LEFT JOIN 	dbo.tstSite s 
					ON 	s.idfsSite = e.idfsSite AND s.intRowStatus = 0
				LEFT JOIN	dbo.tlbEmployeeGroupMember m 	
					ON	m.idfEmployee = ut.idfPerson
					AND	m.intRowStatus = 0
				LEFT JOIN	dbo.tlbEmployeeGroup g
					ON	m.idfEmployeeGroup = g.idfEmployeeGroup
						--e.idfsSite = g.idfsSite
						AND	g.idfEmployeeGroup <> -1 
						AND	g.intRowStatus=0
				--LEFT JOIN	FN_GBL_ReferenceRepair(@LangID, 19000022) GroupName 
				--	ON 	GroupName.idfsReference = g.idfsEmployeeGroupName
				LEFT JOIN FN_GBL_Institution(@LangID) o
					ON p.idfInstitution = o.idfOffice
				LEFT JOIN tlbDepartment d
					ON p.idfDepartment = d.idfDepartment
				LEFT JOIN dbo.FN_GBL_Reference_GETList(@LangID, 19000164) dept
					ON d.idfsDepartmentName = dept.idfsReference
				LEFT JOIN dbo.FN_GBL_Reference_GETList(@LangID, 19000073) sp
					ON p.idfsStaffPosition = sp.idfsReference
		WHERE	e.idfEmployee = @idfPerson AND p.idfInstitution = @idfOffice
				AND		e.intRowStatus=0 
				AND		ut.intRowStatus=0
				AND		e.intRowStatus=0 
				--AND		g.idfEmployeeGroup <> -1 
				--AND		g.intRowStatus=0
				--AND		m.intRowStatus = 0
		GROUP BY p.idfPerson, p.idfInstitution, p.idfDepartment, dept.name, p.idfsStaffPosition, p.strContactPhone, sp.name, s.idfsSite, s.strSiteID, s.strSiteName, s.idfOffice, o.name, e.idfEmployee,ut.idfUserID
		--GROUP BY p.idfPerson, p.idfInstitution, p.idfDepartment, dept.name, p.idfsStaffPosition, sp.name, s.idfsSite, s.strSiteID, s.strSiteName, s.idfOffice, o.name, e.idfEmployee

		--SELECT @returnCode as ReturnCode, @returnMsg as ReturnMessage
	END TRY  
	BEGIN CATCH 
		BEGIN
			SET								@returnCode = ERROR_NUMBER();
			SET								@returnMsg = 
											'ErrorNumber: ' + CONVERT(VARCHAR, ERROR_NUMBER()) 
											+ ' ErrorSeverity: ' + CONVERT(VARCHAR, ERROR_SEVERITY())
											+ ' ErrorState: ' + CONVERT(VARCHAR, ERROR_STATE())
											+ ' ErrorProcedure: ' + ISNULL(ERROR_PROCEDURE(), '')
											+ ' ErrorLine: ' +  CONVERT(VARCHAR, ISNULL(ERROR_LINE(), ''))
											+ ' ErrorMessage: ' + ERROR_MESSAGE();

			--SELECT @returnCode as ReturnCode, @returnMsg as ReturnMessage
		END
	END CATCH;
END
