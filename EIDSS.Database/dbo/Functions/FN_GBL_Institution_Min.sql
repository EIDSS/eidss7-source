-- ================================================================================================
-- Name: FN_GBL_Institution_Min
--
-- Description: Returns the minimum fields needed for organization details 
--          
-- Author: Mandar Kulkarni
--
-- Revision History:
-- Name               Date       Change Detail
-- ------------------ ---------- -----------------------------------------------------------------
-- Jeff Johnson       06/11/2018 Added OrganizationTypeID
-- RYM                06/19/2019 Added OwnershipForm, LegalForm, and MainFormofActivity 
-- RYM                09/13/2019 Added auditcreatedate field
-- Stephen Long       02/10/2022 Added site ID.
-- Mark Wilson        11/08/2022 Added strOrganizationID.
-- Stephen Long       05/05/2023 Added intHaCode and intOrder.
--
-- Testing code:
-- SELECT * FROM [dbo].[FN_GBL_Institution_Min]('en-US')
-- ================================================================================================
CREATE FUNCTION [dbo].[FN_GBL_Institution_Min] (@LangID NVARCHAR(50))
RETURNS TABLE
AS
RETURN
(
    SELECT Office.idfOffice,
           Org.[name] AS EnglishFullName,
           Org.strDefault AS EnglishName,
           Orgab.[name] AS AbbreviatedName,
           OrgAb.strDefault AS AbbreviatedEnglishName,
           Office.idfsOfficeName,
           Office.idfsOfficeAbbreviation,
           Office.idfsSite,
           Office.strOrganizationID,
           Office.intHACode,
           Office.intRowStatus,
           OrgAb.intOrder 
    FROM dbo.tlbOffice Office
        LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LangID, 19000046) Org
            ON Org.idfsReference = Office.idfsOfficeName
               AND Org.intRowStatus = 0
        LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LangID, 19000045) OrgAb
            ON OrgAb.idfsReference = Office.idfsOfficeAbbreviation
               AND Orgab.intRowStatus = 0
)