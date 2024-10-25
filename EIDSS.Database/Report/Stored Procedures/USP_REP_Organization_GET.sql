--*************************************************************************
-- Name 				: report.USP_REP_Organization_GET
-- Description			: returns the user's organization
--          
-- Author               : Mark Wilson
-- Revision History
-- Name			       Date       Change Detail
-- ------------------- ---------- ----------------------------------------
-- Stephen Long        05/08/2023 Changed from institution repair to min.
--
-- Testing code:
--
-- EXEC report.USP_REP_Organization_GET -498, 'ka'
-- EXEC report.USP_REP_Organization_GET -498
--*************************************************************************
CREATE PROCEDURE  [Report].[USP_REP_Organization_GET]
(
	@idfPerson BIGINT,
	@LangID NVARCHAR(50) = NULL
)
AS
BEGIN
	SELECT 
		P.idfInstitution,
		I.EnglishFullName AS OrganizationName
	FROM  dbo.tlbPerson P
	LEFT JOIN dbo.FN_GBL_Institution_Min(@LangID) I ON I.idfOffice = P.idfInstitution
	WHERE P.idfPerson = @idfPerson;
END