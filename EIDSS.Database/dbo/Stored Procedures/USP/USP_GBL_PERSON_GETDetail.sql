--*************************************************************
-- Name 				: USP_GBL_PERSON_GETDetail
-- Description			: Input: personid, languageid; Output: person list, group list
--          
-- Author               : Mandar Kulkarni
-- Revision History
--		Name       Date       Change Detail
-- Ricky Moss		12/19/2019	Added Personal ID Type and Personal ID field, Merge site and personal person sql statements, removed employee group queries
-- Ricky Moss		12/20/2019	Added the ASPNETUsers Table to include the username field
-- Ricky Moss		01/15/2019	Removed login credentials fields
-- Ann Xiong     	10/09/2020  Added idfsSite to the select
-- Testing code:
-- exec USP_GBL_PERSON_GETDetail -430, 'en'
--====================================================================================================
 CREATE PROCEDURE [dbo].[USP_GBL_PERSON_GETDetail]

( 
	@idfPerson AS BIGINT, --##PARAM @idfPerson - person ID
	@LangID NVARCHAR(50) --##PARAM @LangID - language ID
)	
AS
DECLARE @returnMsg VARCHAR(MAX) = 'Success'
DECLARE @returnCode BIGINT = 0
BEGIN

	BEGIN TRY  
		SELECT	p.idfPerson,
				idfsStaffPosition,
				spbr.name as strStaffPosition,
				idfInstitution,
				o.FullName as strOrganizationFullName,
				o.name as strOrganizationName,
				p.idfDepartment,
				deptbr.name as strDepartmentName,
				strFamilyName,
				strFirstName,
				strSecondName,
				p.strContactPhone,
				strBarcode,
				p.PersonalIDValue,
				p.PersonalIDTypeID,
				pidbr.name as strPersonalIDType,
				e.idfsSite,
				--f.strSiteName,
				f.strSiteID strSiteName,
				e.idfsEmployeeCategory,
				empcat.strDefault AS strEmployeeCategory
		FROM	tlbPerson p
		INNER JOIN 	tlbEmployee e ON
					p.idfPerson=e.idfEmployee
		LEFT JOIN dbo.FN_GBL_Reference_GETList(@LangID, 19000148) pidbr ON
					p.PersonalIDTypeID = pidbr.idfsReference
		LEFT JOIN FN_GBL_Institution(@LangID) o ON
					p.idfInstitution = o.idfOffice
		LEFT JOIN tlbDepartment d ON
					p.idfDepartment = d.idfDepartment
		LEFT JOIN dbo.FN_GBL_Reference_GETList(@LangID, 19000164) deptbr ON
					d.idfsDepartmentName = deptbr.idfsReference
		LEFT JOIN dbo.FN_GBL_Reference_GETList(@LangID, 19000073) spbr on
					p.idfsStaffPosition = spbr.idfsReference
		INNER JOIN dbo.tstSite f ON e.idfsSite = f.idfsSite 
		LEFT JOIN dbo.FN_GBL_Reference_GETList(@LangID,19000526) empcat ON
					e.idfsEmployeeCategory = empcat.idfsReference
		WHERE 	e.idfEmployee=@idfPerson
		AND		e.intRowStatus=0 
		AND		e.idfsEmployeeType=10023002 --Person 

		--1, User Table jl:BV blocked 4/19/2017 reopen 7/3/2017 based on discussion 

		--SELECT	UT.idfUserID,
		--		UT.idfPerson,
		--		UT.idfsSite,
		--		UT.strAccountName,
		--		S.strSiteID,
		--		S.strSiteName,
		--		S.idfsSiteType,
		--		ISNULL(Rf.name, Rf.strDefault) AS strSiteType
		--FROM	dbo.tstUserTable UT
		--INNER JOIN dbo.tstSite S ON 
		--			S.idfsSite = UT.idfsSite And S.intRowStatus = 0
		--INNER JOIN dbo.fnReference(@LangID, 19000085/*Site Type*/) Rf ON 
		--			S.idfsSiteType = Rf.idfsReference
		--WHERE	UT.idfPerson=@idfPerson	
		--AND		UT.intRowStatus=0

		-- Groups
		--SELECT	EG.idfEmployeeGroup,
		--		EG.idfsEmployeeGroupName,
		--		E.idfEmployee,
		--		ISNULL(GroupName.name,EG.strName) AS strName,
		--		EG.strDescription
		--FROM	dbo.tlbEmployeeGroup EG
		--INNER JOIN	dbo.tlbEmployeeGroupMember EM ON	
		--			EM.idfEmployeeGroup=EG.idfEmployeeGroup
		--INNER JOIN	dbo.tlbEmployee E ON 
		--			E.idfEmployee=EM.idfEmployee
		--LEFT JOIN	FN_GBL_ReferenceRepair(@LangID, 19000022) GroupName ON GroupName.idfsReference = EG.idfsEmployeeGroupName
		--WHERE	E.intRowStatus=0 
		--AND		EG.idfEmployeeGroup<>-1 
		--AND		EG.intRowStatus=0
		--AND		EM.intRowStatus = 0
		--AND		E.idfEmployee = @idfPerson

		--SELECT @returnCode, @returnMsg

	END TRY  

	BEGIN CATCH 
			THROW
	END CATCH; 
END
