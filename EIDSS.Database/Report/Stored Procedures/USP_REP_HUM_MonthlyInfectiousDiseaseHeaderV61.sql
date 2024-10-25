--*************************************************************************
-- Name 				: report.USP_REP_HUM_MonthlyInfectiousDiseaseHeaderV61
-- DescriptiON			: Select data for Reportable Infectious Diseases (Monthly Form IV03) for 01-2/N.
-- 
-- Author               : Srini Goli
-- RevisiON History
--		Name			Date       Change Detail
--	
/*
NOTES:
Form 03 by MoLHSA Order 01-02N:
-------------------------------
@strOrderNumber
br.strBaseReferenceCode = N'Order #(01-2/N)'
@strOrderDate
br.strBaseReferenceCode = = N'Order Date(01-2/N)'

Form 03 by MoLHSA Order 01-82N:
-------------------------------
@strOrderNumber
br.strBaseReferenceCode = N'Order #(01-82/N)'
@strOrderDate
br.strBaseReferenceCode = N'Order Date(01-82/N)'

Form 03 by MoLHSA Order 01-27N:
--------------------------------
@strOrderNumber
br.strBaseReferenceCode = N'Order #'
@strOrderDate
br.strBaseReferenceCode = N'Order Date'
*/		
-- Testing code:
/*

EXEC report.USP_REP_HUM_MonthlyInfectiousDiseaseHeaderV61 'en',  37020000000, 3260000000

*/

CREATE PROCEDURE [Report].[USP_REP_HUM_MonthlyInfectiousDiseaseHeaderV61]
	(
		@LangID		AS NVARCHAR(10), 
		@RegionID	AS BIGINT = NULL,
		@RayonID	AS BIGINT = NULL,
		@SiteID		AS BIGINT = NULL,
		@UserID		AS BIGINT = NULL
	)
AS	

/*

Spec: https://95.167.107.114/BTRP/Project_Documents/08x-Implementation/Customizations/GG/Customization EIDSS v6 phase 3/Reports/Form IV-03/Form IV-03 (Order 01-2N)/Specification for report development - Official Form.doc

*/

DECLARE	@ReportTable	TABLE
(	
	strOrderNumber		NVARCHAR(200) COLLATE DATABASE_DEFAULT NULL, --1
	strOrderDate		NVARCHAR(200) COLLATE DATABASE_DEFAULT NULL, --2
	strNA				NVARCHAR(200) COLLATE DATABASE_DEFAULT NULL,
	strNameOfRespondent NVARCHAR(200) COLLATE DATABASE_DEFAULT NULL, --3
	strActualAddress	NVARCHAR(200) COLLATE DATABASE_DEFAULT NULL, --4
	strTelephone		NVARCHAR(200) COLLATE DATABASE_DEFAULT NULL, --8
	strChief			NVARCHAR(200) COLLATE DATABASE_DEFAULT NULL --69
)

DECLARE 
    @idfsLanguage		 BIGINT,
    @strNameOfRespondent NVARCHAR(200),
    @strActualAddress	NVARCHAR(200),
    @strTelephone		NVARCHAR(200),
	@strOrderNumber		NVARCHAR(200),
	@strOrderDate		NVARCHAR(200),
	@strNA				NVARCHAR(200),
    @strChief			NVARCHAR(200),
    @idfsSite			BIGINT,
    @idfsUser			BIGINT


SET @idfsLanguage = report.FN_GBL_LanguageCode_GET(@LangID)

SET @idfsUser = ISNULL(@UserID, dbo.fnUserID())

IF @RayonID IS NOT NULL
BEGIN
	SELECT @idfsSite = fnfl.idfsSite
	FROM report.FN_REP_ReportingFacilitiesList(@idfsLanguage, @RayonID) fnfl
END

IF @idfsSite IS NULL
BEGIN
  SET @idfsSite = @SiteID
END

IF @idfsSite IS NULL
BEGIN
select	@idfsSite = ut.idfsSite
from	dbo.tstUserTable ut
where	ut.idfUserID = @idfsUser
END

IF @idfsSite IS NULL
BEGIN
SET	@idfsSite = dbo.FN_GBL_SITEID_GET()
END



SELECT 
    @strActualAddress = report.FN_REP_AddressSharedString(@LangID, tlbOffice.idfLocation),
    @strTelephone = tlbOffice.strContactPhone,
    @strNameOfRespondent = ISNULL(trtStringNameTranslation.strTextString, trtBaseReference.strDefault)
FROM tlbOffice
    INNER JOIN tstSite
    ON tlbOffice.idfOffice = tstSite.idfOffice
    AND tstSite.intRowStatus = 0

    INNER JOIN trtBaseReference
    ON tlbOffice.idfsOfficeName = trtBaseReference.idfsBaseReference --AND

    LEFT OUTER JOIN trtStringNameTranslation
    ON trtBaseReference.idfsBaseReference = trtStringNameTranslation.idfsBaseReference
    AND trtStringNameTranslation.idfsLanguage = @idfsLanguage 
    AND trtStringNameTranslation.intRowStatus = 0

WHERE tstSite.idfsSite = @idfsSite AND tlbOffice.intRowStatus = 0




SELECT @strOrderNumber = ISNULL(RTRIM(r.[name]) + N' ', N'')
FROM report.FN_GBL_ReferenceRepair_GET(@LangID, 19000132) r -- Additional report Text
  INNER JOIN trtBaseReference br
  ON br.idfsBaseReference = r.idfsReference
WHERE br.strBaseReferenceCode = N'Order #(01-2/N)'


SELECT @strOrderDate =  ISNULL(RTRIM(r.[name]) + N' ', N'')
FROM report.FN_GBL_ReferenceRepair_GET(@LangID, 19000132) r	-- Additional report Text
  INNER JOIN trtBaseReference br
  ON br.idfsBaseReference = r.idfsReference
WHERE	br.strBaseReferenceCode = N'Order Date(01-2/N)'


SELECT @strNA = ISNULL(RTRIM(r.[name]) + N' ', N'')
FROM report.FN_GBL_ReferenceRepair_GET(@LangID, 19000132) r -- Additional report Text
WHERE r.strDefault = N'N/A'



SELECT
  @strChief = ISNULL(strFirstName, '') +  ISNULL(' ' + strFamilyName, '')
FROM tstUserTable
  INNER JOIN tlbPerson
  ON tstUserTable.idfPerson = tlbPerson.idfPerson
  AND tlbPerson.intRowStatus = 0
WHERE tstUserTable.idfUserID = @idfsUser


INSERT INTO @ReportTable
SELECT
  @strOrderNumber,
	@strOrderDate ,
	@strNA,
	@strNameOfRespondent,
	@strActualAddress,
	@strTelephone,
	@strChief

SELECT * 
FROM @ReportTable
	




