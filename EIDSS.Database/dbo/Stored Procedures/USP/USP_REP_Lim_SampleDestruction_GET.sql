﻿


-- ================================================================================================
-- Name: USP_REP_Lim_SampleDestruction_GET
--
-- Description:	Select data for Sample destruction report.
--                      
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Mark Wilson		12132021	Initial Version, converted to E7 standards

/*
--Example of a call of procedure:

exec dbo.USP_REP_Lim_SampleDestruction_GET 
@LangID=N'en-US',
@SampleIDXml=
N'<ItemList>
	<Item idfMaterial="267406140000870"/>
	<Item idfMaterial="363892560000870"/>
</ItemList>'

exec dbo.USP_REP_Lim_SampleDestruction_GET @LangID=N'en-US',@SampleIDXml=N'<ItemList>
<Item idfMaterial="267406140000870" />
</ItemList>'

*/


CREATE PROCEDURE [dbo].[USP_REP_Lim_SampleDestruction_GET]
    (
        @LangID			AS NVARCHAR(10), 
        @SampleIDXml	AS NVARCHAR(MAX)
    )
AS
BEGIN
	
	
	DECLARE @MaterialTable	TABLE
	(
		 idfMaterial BIGINT			
	)	
	
	DECLARE @iMaterial	INT
	EXEC sp_xml_preparedocument @iMaterial OUTPUT, @SampleIDXml
	
	INSERT INTO @MaterialTable 
	(
		 idfMaterial	
	) 
	SELECT * 
	FROM OPENXML (@iMaterial, '/ItemList/Item')
	WITH 
	( 
		 idfMaterial BIGINT '@idfMaterial'
	)												 

	EXEC sp_xml_removedocument @iMaterial
	
	;WITH SentForDestructionBy AS (
		SELECT
			dbo.FN_GBL_ConcatFullName(tp.strFamilyName, tp.strFirstName, tp.strSecondName) AS strSentForDestructionBy
			, ROW_NUMBER () OVER (ORDER BY tp.idfPerson) rn
		FROM (SELECT DISTINCT tm.idfMarkedForDispositionByPerson
			  FROM dbo.tlbMaterial tm
			  JOIN @MaterialTable mt ON mt.idfMaterial = tm.idfMaterial
		      WHERE tm.intRowStatus = 0
		) AS m
		JOIN dbo.tlbPerson tp ON tp.idfPerson = m.idfMarkedForDispositionByPerson 
		
	),
	DestructionApprovedBy AS (
		SELECT
			ISNULL(tp.strFamilyName, '') 
				+ CASE WHEN ISNULL(tp.strFamilyName, '') <> '' THEN ' ' ELSE '' END
				+ ISNULL(tp.strFirstName, '') 
				+ CASE WHEN ISNULL(tp.strSecondName, '') <> '' THEN ' ' ELSE '' END
				+ ISNULL(tp.strSecondName, '') AS strDestructionApprovedBy
			, ROW_NUMBER () OVER (ORDER BY tp.idfPerson) rn
		FROM (SELECT DISTINCT tm.idfDestroyedByPerson
		      FROM dbo.tlbMaterial tm
			  JOIN @MaterialTable mt ON mt.idfMaterial = tm.idfMaterial
		      WHERE tm.intRowStatus = 0
		) AS m
		JOIN dbo.tlbPerson tp ON
			tp.idfPerson = m.idfDestroyedByPerson 

		--	AND tm.idfsSampleStatus in (10015003,10015002) --cotDestroy,cotDelete
	)
	
	SELECT
		tm.idfMaterial,
		tm.strBarcode AS strLabSampleID,
		tm.strBarcode AS strLabSampleIDBarcode,
		frr_SampleType.name AS strSampleType,
		frr_Status.name AS strCondition, -- it's not condition, its's status, but i don't want to change binding in the application code
		frr_DestructionMethod.name	AS strDestructionMethod,
		REPLACE((
				 SELECT
					   CASE WHEN t2.rn > 1 THEN ', ' ELSE '' END + strSentForDestructionBy AS 'data()'  
				 FROM SentForDestructionBy t2
				 FOR XML PATH ('')
				), ' , ', ', ') strSentForDestructionBy,
		REPLACE(
			(
				 SELECT
					   CASE WHEN t2.rn > 1 THEN ', ' ELSE '' END + strDestructionApprovedBy AS 'data()'  
				 FROM DestructionApprovedBy t2
				 FOR XML PATH ('')
			), ' , ', ', ') strDestructionApprovedBy
	FROM dbo.tlbMaterial tm
	JOIN dbo.FN_GBL_ReferenceRepair_GET(@LangID, 19000087) frr_SampleType ON frr_SampleType.idfsReference = tm.idfsSampleType
	LEFT JOIN dbo.FN_GBL_ReferenceRepair_GET(@LangID, 19000157) frr_DestructionMethod ON frr_DestructionMethod.idfsReference = tm.idfsDestructionMethod	
	LEFT JOIN dbo.FN_GBL_ReferenceRepair_GET(@LangID, 19000015) frr_Status ON frr_Status.idfsReference = tm.idfsSampleStatus
	JOIN @MaterialTable mt ON mt.idfMaterial = tm.idfMaterial
	WHERE tm.intRowStatus = 0
		
END

