
-- ================================================================================================
-- Name: USP_ADMIN_EMPLOYEE_GETCOUNT
--
-- Description:	Get a list of employees for the various EIDSS use cases.
--
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Ricky Moss		02/09/2019 Initial Release
-- Ricky Moss       02/06/2020 Added Personal ID and Personal ID Type fields
-- Ann Xiong        09/24/2020 Added TotalCount to the select and idfsEmployeeCategory and AccountState to the paramter list
-- Ann Xiong     	11/11/2020 Modified to return non user employees after Update and Delete Triggers have been added to EmployeeToInstitution.
-- Ann Xiong     	11/19/2020	Modified to return old user Employee records.
-- Ann Xiong     	01/20/2020	Modified TotalCount to be the same as when no Search Criteria specified.
--
-- EXEC USP_ADMIN_EMPLOYEE_GETCOUNT 'en', null, null, null, null, null, null, null, null, null, null, null, null, null
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_ADMIN_EMPLOYEE_GETCOUNT] (
	@LanguageID AS NVARCHAR(50),
	@EmployeeID AS BIGINT = NULL,
	@FirstOrGivenName AS NVARCHAR(400) = NULL,
	@SecondName AS NVARCHAR(400) = NULL,
	@LastOrSurName AS NVARCHAR(400) = NULL,
	@ContactPhone AS NVARCHAR(400) = NULL,
	@OrganizationAbbreviatedName AS NVARCHAR(4000) = NULL,
	@OrganizationFullName AS NVARCHAR(4000) = NULL,
	@EIDSSOrganizationID AS NVARCHAR(200) = NULL,
	@OrganizationID AS BIGINT = NULL,
	@PositionTypeName AS NVARCHAR(4000) = NULL,
	@PositionTypeID AS BIGINT = NULL,
	@PersonalID			AS NVARCHAR(100)    = NULL,
	@PersonalIDType		AS BIGINT			= NULL
	,@idfsEmployeeCategory	AS BIGINT			= NULL
	,@AccountStateID		AS BIGINT			= NULL
	)
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		SELECT	COUNT(*) AS EmployeeCount
				,(
					SELECT	COUNT(*)
					--FROM	dbo.tlbEmployee
					--WHERE	intRowStatus = 0
					FROM	dbo.tlbPerson p
							INNER JOIN dbo.tlbEmployee AS e
								ON e.idfEmployee = p.idfPerson
								AND e.intRowStatus = 0
							LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000073) AS position
								ON p.idfsStaffPosition = position.idfsReference
							LEFT JOIN dbo.FN_GBL_Institution(@LanguageID) AS organization
								ON organization.idfOffice = p.idfInstitution
							LEFT JOIN  tstUserTable ut
								ON ut.idfPerson = p.idfPerson  
							LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000526) AS employeeCategory
								ON e.idfsEmployeeCategory = employeeCategory.idfsReference
							LEFT  JOIN 	EmployeeToInstitution ei
								ON	ut.idfUserID = ei.idfUserID 
								--AND ei.IsDefault = 1
							LEFT JOIN  AspNetUsers u 
								ON u.idfUserID = ut.idfUserID
					WHERE	e.intRowStatus = 0 
							AND p.intRowStatus = 0
				 			AND (ut.intRowStatus is NULL or ut.intRowStatus = 0)
				 			AND (	ei.IsDefault = 1 
									or (e.idfsEmployeeCategory = 10526002 
										AND (	ei.intRowStatus is NULL 
												--or ei.intRowStatus = 1
											)
										) 
									or (e.idfsEmployeeCategory = 10526001 AND ei.intRowStatus is NULL)
								)
				) AS TotalCount
		FROM	dbo.tlbPerson p
				INNER JOIN dbo.tlbEmployee AS e
					ON e.idfEmployee = p.idfPerson
					AND e.intRowStatus = 0
				LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000073) AS position
					ON p.idfsStaffPosition = position.idfsReference
				LEFT JOIN dbo.FN_GBL_Institution(@LanguageID) AS organization
					ON organization.idfOffice = p.idfInstitution
				LEFT JOIN  tstUserTable ut
					ON ut.idfPerson = p.idfPerson  
				LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000526) AS employeeCategory
					ON e.idfsEmployeeCategory = employeeCategory.idfsReference
				LEFT  JOIN 	EmployeeToInstitution ei
					ON	ut.idfUserID = ei.idfUserID 
					--AND ei.IsDefault = 1
				LEFT JOIN  AspNetUsers u 
					ON u.idfUserID = ut.idfUserID
		WHERE	e.intRowStatus = 0 
				AND p.intRowStatus = 0
				 AND (ut.intRowStatus is NULL or ut.intRowStatus = 0)
				 AND (	ei.IsDefault = 1 
						or (e.idfsEmployeeCategory = 10526002 
							AND (	ei.intRowStatus is NULL 
									--or ei.intRowStatus = 1
								)
							) 
						or (e.idfsEmployeeCategory = 10526001 AND ei.intRowStatus is NULL)
					)
				AND (
					(
					(p.idfPerson = @EmployeeID)
					OR (@EmployeeID IS NULL)
					)
				AND (
					(p.strContactPhone = @ContactPhone)
					OR (@ContactPhone IS NULL)
					)
				AND (
					(p.idfInstitution = @OrganizationID)
					OR (@OrganizationID IS NULL)
					)
				AND (
					(position.idfsReference = @PositionTypeID)
					OR (@PositionTypeID IS NULL)
					)
				AND (
					(position.[name] = @PositionTypeName)
					OR (@PositionTypeName IS NULL)
					)
				AND (
					(p.strContactPhone = @ContactPhone)
					OR (@ContactPhone IS NULL)
					)
				AND (
					(p.strFirstName LIKE '%' + @FirstOrGivenName + '%')
					OR (@FirstOrGivenName IS NULL)
					)
				AND (
					(p.strSecondName LIKE '%' + @SecondName + '%')
					OR (@SecondName IS NULL)
					)
				AND (
					(p.strFamilyName LIKE '%' + @LastOrSurName + '%')
					OR (@LastOrSurName IS NULL)
					)
				AND (
					(organization.strOrganizationID LIKE '%' + @EIDSSOrganizationID + '%')
					OR (@EIDSSOrganizationID IS NULL)
					)
				AND (
					(organization.[name] LIKE '%' + @OrganizationAbbreviatedName + '%')
					OR (@OrganizationAbbreviatedName IS NULL)
					)
				AND (
					(organization.FullName LIKE '%' + @OrganizationFullName + '%')
					OR (@OrganizationFullName IS NULL)
					)
				AND (
					(p.PersonalIDValue LIKE '%' + @PersonalID + '%')
					OR (@PersonalID IS NULL)
					)
				AND (
					(p.PersonalIDTypeID = @PersonalIDType)
					OR (@PersonalIDType IS NULL)
					)
				AND (
					(e.idfsEmployeeCategory = @idfsEmployeeCategory)
					OR (@idfsEmployeeCategory IS NULL)
					)
				AND	
					(1 = CASE
						WHEN @AccountStateID = 10527001 and (u.LockoutEnabled = 1 and u.LockoutEnd IS Not NULL) THEN 1
              			WHEN @AccountStateID = 10527002 and u.blnDisabled = 1 THEN 1
              			WHEN @AccountStateID IS NULL THEN 1
              			ELSE 0
           			END
					)
				);
	END TRY

	BEGIN CATCH
		THROW;
	END CATCH
END;
