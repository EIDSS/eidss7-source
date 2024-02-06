-- ================================================================================================
-- Name: USP_ADMIN_EMP_ORGANIZATION_USER_GROUP_GETList		
-- 
-- Description: Returns a list of Organizations, site IDs, User Groups for an Employee.
--
-- Revision History:
--		
-- Name				Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Ann Xiong     	08/24/2020 Initial release.
-- Ann Xiong     	08/31/2020 Changed to consider default Organization
-- Ann Xiong     	09/08/2020 Rearranged scripts to return UserGroupID and UserGroup
-- Ann Xiong     	09/10/2020 Modified to return multiple Organizations
-- Ann Xiong     	09/14/2020 Added idfUserID to the select list.
-- Ann Xiong     	10/15/2020 Modified to return correct Organization from tlbPerson and return '' for SiteID and SiteName when s.idfsSite = 1.
-- Ann Xiong     	10/20/2020 Modified to return only active records (intRowStatus = 0) if there is any active records otherwise return Deactivated records (intRowStatus = 1).
-- Ann Xiong     	11/06/2020 Modified to only return record if intRowStatus = 0 for tlbEmployeeGroupMember
-- Stephen Long     12/11/2020 Added site group ID and site type ID to the query.
-- Stephen Long     01/08/2021 Add string aggregate function on site to site group to get a list 
--                             of site groups in a concatenated list.  Removed join on main query 
--                             to eliminate duplicates.
-- Mani				01/22/2021  Added OrganizationFullName
-- Minal			08/09/2021  Organization is picked from EmployeeToInstitution in place of Person
-- Ann Xiong     	03/23/2023 Modified to return translated User Group name
-- Stephen Long     05/05/2023 Replaced institution with institution min.
--
-- Testing Code:
-- EXEC USP_ADMIN_EMP_ORGANIZATION_USER_GROUP_GETList -471, 'en'
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_ADMIN_EMP_ORGANIZATION_USER_GROUP_GETList] (
	@idfPerson BIGINT
	,@LangID NVARCHAR(50)
	)
AS
BEGIN
	DECLARE @returnMsg VARCHAR(MAX) = 'SUCCESS';
	DECLARE @returnCode BIGINT = 0;

	BEGIN TRY
		DECLARE @aspNetUserId NVARCHAR(128);

		SELECT @aspNetUserId = ei.aspNetUserId
		FROM dbo.tstUserTable ut
		LEFT JOIN dbo.EmployeeToInstitution ei ON ut.idfUserID = ei.idfUserID
		WHERE ut.idfPerson = @idfPerson;

		SELECT ROW_NUMBER() OVER (
				ORDER BY ei.IsDefault DESC
					,ut.idfUserID
				) AS Row
			,s.idfsSite
			,CASE 
				WHEN s.idfsSite = 1
					THEN ''
				ELSE s.strSiteID
				END AS SiteID
			,CASE 
				WHEN s.idfsSite = 1
					THEN ''
				ELSE s.strSiteName
				END AS SiteName
			,ei.idfInstitution AS OrganizationID
			,o.AbbreviatedName AS Organization
			,o.EnglishFullName AS OrganizationFullName
			,STRING_AGG(g.idfEmployeeGroup, ', ') WITHIN
		GROUP (
				ORDER BY g.idfEmployeeGroup DESC
				) AS UserGroupID
			,STRING_AGG(egbr.[name], ', ') AS UserGroup
			,e.idfEmployee
			,ISNULL(ei.intRowStatus, 1) AS STATUS
			,ei.Active 
			,ei.IsDefault
			,ut.idfUserID
			,s.idfsSiteType AS SiteTypeID
			,NULL AS SiteGroupID --TODO: temporary fix until site filtration logic is adjusted to use new site group list below.  Will remove this field once complete.  SHL
			,(
				SELECT STRING_AGG(ssg.idfSiteGroup, ',') WITHIN
				GROUP (
						ORDER BY ssg.idfSiteGroup ASC
						) AS SiteGroupID
				FROM dbo.tflSiteToSiteGroup AS ssg 
				WHERE ssg.idfsSite = s.idfsSite
				) AS SiteGroupList
		FROM dbo.tstUserTable ut
		LEFT JOIN dbo.tlbEmployee e ON e.idfEmployee = ut.idfPerson
		LEFT JOIN dbo.tstSite s ON s.idfsSite = e.idfsSite
			AND s.intRowStatus = 0
		LEFT JOIN dbo.tlbPerson p ON e.idfEmployee = p.idfPerson
		LEFT JOIN dbo.EmployeeToInstitution ei ON ut.idfUserID = ei.idfUserID
		LEFT JOIN dbo.FN_GBL_Institution_Min(@LangID) o ON ei.idfInstitution = o.idfOffice
		LEFT JOIN dbo.tlbEmployeeGroupMember m ON m.idfEmployee = ut.idfPerson
			AND m.intRowStatus = 0
		LEFT JOIN dbo.tlbEmployeeGroup g ON m.idfEmployeeGroup = g.idfEmployeeGroup
			AND g.idfEmployeeGroup <> - 1
			AND g.intRowStatus = 0
		LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LangID, 19000022) egbr
					ON g.idfsEmployeeGroupName = egbr.idfsReference
		WHERE ei.aspNetUserId = @aspNetUserId
			AND ut.intRowStatus = 0
			AND e.intRowStatus = 0
		GROUP BY s.idfsSite
			,s.strSiteID
			,s.strSiteName
			,ei.idfInstitution
			,o.AbbreviatedName
			,e.idfEmployee
			,ei.intRowStatus
			,ei.Active
			,ei.IsDefault
			,ut.idfUserID
			,s.idfsSiteType
			,o.EnglishFullName;
	END TRY

	BEGIN CATCH
	THROW;
	END CATCH;
END