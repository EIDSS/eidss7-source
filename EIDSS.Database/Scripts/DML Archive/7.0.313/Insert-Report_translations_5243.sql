/*
Author:			Srini Goli
Date:			10/31/2022
Description:	Report labels Inserts.
*/
INSERT INTO [report].[tlbReportStringNameTranslation]([idfsLanguage],[idfsReportID],[idfsReportTextID],[strTextString],[Comments])
VALUES(10049003,61,97,N'Vaccination Info',N'Page1-table1')
INSERT INTO [report].[tlbReportStringNameTranslation]([idfsLanguage],[idfsReportID],[idfsReportTextID],[strTextString],[Comments])
VALUES(10049004,61,97,N'ინფორმაცია ვაქცინაციის შესახებ',N'')
INSERT INTO [report].[tlbReportStringNameTranslation]([idfsLanguage],[idfsReportID],[idfsReportTextID],[strTextString],[Comments])
VALUES(10049006,61,97,N'Информация о вакцинации',N'')

--REPORTS TEXTS
DROP TABLE IF EXISTS #idfsResource
SELECT		(SELECT MAX([idfsResource]) FROM [dbo].[trtResource])+ROW_NUMBER() OVER(ORDER BY rs.idfsReportID ASC,rs.idfsReportTextID ASC) as [idfsResource],
			rs.strTextString,
			'Common - Reports' as [strReservedAttribute]
			,800061 as [idfsResourceSet],rs.idfsReportID,rs.idfsReportTextID,rs.idfsLanguage
			INTO #idfsResource	
FROM		report.tlbReports r
INNER JOIN  report.tlbReportStringNameTranslation rs 
ON r.idfsLanguage=rs.idfsLanguage and r.idfsReportID=rs.idfsReportID AND rs.idfsLanguage=10049003
WHERE r.idfsReportID=61 and rs.[idfsReportTextID]=97


--SELECT * FROM  #idfsResource
INSERT INTO [dbo].[trtResource]
           ([idfsResource]
           ,[strResourceName]
           ,[strReservedAttribute]
           )
SELECT [idfsResource],strTextString,[strReservedAttribute]
FROM #idfsResource WHERE idfsLanguage=10049003
--DELETE FROM [dbo].[trtResource] WHERE [idfsResource]>=900000

--SELECT MAX(idfsResource) FROM [dbo].[trtResourceTranslation]
INSERT INTO [dbo].[trtResourceTranslation]
           ([idfsResource]
           ,[idfsLanguage]
           ,[strResourceString]
           ,[strReservedAttribute]
)
SELECT r.[idfsResource],rsl.idfsLanguage,rsl.strTextString,r.[strReservedAttribute]
FROM		#idfsResource r
INNER JOIN  report.tlbReportStringNameTranslation rs 
ON  r.idfsReportID=rs.idfsReportID AND r.idfsReportTextID=rs.idfsReportTextID AND r.idfsLanguage=rs.idfsLanguage
INNER JOIN  report.tlbReportStringNameTranslation rsl ON  rsl.idfsReportID=rs.idfsReportID AND rsl.idfsReportTextID=rs.idfsReportTextID


INSERT INTO [dbo].[trtResourceSetToResource]
           ([idfsResourceSet]
           ,[idfsResource]
           ,idfsReportTextID
          )
SELECT r.idfsResourceSet,r.[idfsResource],r.idfsReportTextID
FROM		#idfsResource r
INNER JOIN  report.tlbReportStringNameTranslation rs 
ON  r.idfsReportID=rs.idfsReportID AND r.idfsReportTextID=rs.idfsReportTextID AND r.idfsLanguage=rs.idfsLanguage

GO

