---------------------------------------------------------------------------------

/**************************************************************************************************************************************
* Post Data Migration script from EIDSSv6.1 to EIDSSv7 for applying modifications in migrated data.
* Execute script on any database, e.g. master, on the server, where both databases of EIDSS v6.1 and v7 ("empty DB") are located.
* By default, in the script EIDSSv6.1 database has the name Falcon_Archive and EIDSSv7 database has the name Giraffe_Archive.
**************************************************************************************************************************************/

use [Giraffe_Archive]
GO


---------------------------------

/**************************************************************************************************************************************
* Disable Triggers
**************************************************************************************************************************************/
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER	FUNCTION [dbo].[FN_GBL_TriggersWork] ()
RETURNS BIT
AS
BEGIN
RETURN 0
--RETURN 1
END

GO

-------


SET XACT_ABORT ON 
SET NOCOUNT ON 


declare	@Error	int
set	@Error = 0

declare	@ErrorMsg	nvarchar(MAX)
set	@ErrorMsg = N''

declare	@cmd	nvarchar(4000)
set	@cmd = N''


BEGIN TRAN

BEGIN TRY


---------------------------------------------------------------------------------------------------

/**************************************************************************************************************************************
* SetContext
**************************************************************************************************************************************/
DECLARE @Context VARBINARY(128)
SET @Context = CAST('DataMigration' AS VARBINARY(128))
SET CONTEXT_INFO @Context

IF NOT EXISTS (SELECT * FROM [Giraffe_Archive].[dbo].tstLocalSiteOptions WHERE strName = 'Context' collate Cyrillic_General_CI_AS)
INSERT INTO [Giraffe_Archive].[dbo].tstLocalSiteOptions 
(strName, strValue)
VALUES
('Context', 'DataMigration')

/**************************************************************************************************************************************
* Insert/Update records to the tables
**************************************************************************************************************************************/


DECLARE @idfCustomizationPackage BIGINT
	, @idfsCountry BIGINT
	, @CDRSite BIGINT

SELECT @idfCustomizationPackage = [Falcon_Archive].[dbo].fnCustomizationPackage()
SELECT @idfsCountry = [Falcon_Archive].[dbo].fnCustomizationCountry()
SELECT 
	@CDRSite = ts.idfsSite
FROM	[Falcon_Archive].[dbo].tstSite ts
WHERE	ts.intRowStatus = 0
		and ts.idfCustomizationPackage = @idfCustomizationPackage
		and ts.idfsSiteType = 10085001 /*CDR*/




/**************************************************************************************************************************************
* Restore applicable languages - start
**************************************************************************************************************************************/
update [Giraffe_Archive].[dbo].trtBaseReference
set intRowStatus = 0
where	idfsReferenceType = 19000049
		and intRowStatus <> 0
		and idfsBaseReference in
			(	10049001,--az-Latn-AZ
				10049003,--en-US
				10049004,--ka-GE
				10049006,--ru-RU
				10049011,--ar-JO
				10049014,--th-TH
				10049015,--ar-IQ
				10049005,--kk-KZ
				10049009,--uk-UA
				10049010 --hy-AM
			)
/**************************************************************************************************************************************
* Restore applicable languages - end
**************************************************************************************************************************************/


/**************************************************************************************************************************************
* BV BUG 98331, 98330 - start
**************************************************************************************************************************************/
update	[Giraffe_Archive].[dbo].trtBaseReference
set		blnSystem = 1
where	idfsBaseReference in 
		(	19000144 /*Reference Type Name "Case Report Type"*/,
			350000000 /*Case Classification "Confirmed"*/
		)
		and (blnSystem is null or blnSystem <> 1)
/**************************************************************************************************************************************
* BV BUG 98331, 98330 - end
**************************************************************************************************************************************/


/**************************************************************************************************************************************
* BV BUG 102293 - start
**************************************************************************************************************************************/
update	[Giraffe_Archive].[dbo].ffParameterType
set		idfsReferenceType = 19000069 /*Flexible Form Parameter Value*/
where	idfsParameterType = 217140000000 /*Y_N_Unk*/
		and (idfsReferenceType is null or idfsReferenceType <> 19000069 /*Flexible Form Parameter Value*/)
/**************************************************************************************************************************************
* BV BUG 102293 - end
**************************************************************************************************************************************/


/**************************************************************************************************************************************
* BV BUG 91691 - start
* The following site types shall be available in the ADM -> Sites -> ‘Site Type’ list: CDR, SLVL, SS.
* Where SLVL is renamed from EMS, and SS is renamed from TLVL.
**************************************************************************************************************************************/
update	trtBaseReference
set		intRowStatus =
			case
				when	idfsBaseReference in
						(	10085001	/*CDR*/,
							10085002	/*SLVL*/,
							10085007	/*TLVL*/
						)
					then	0
				else	1
			end,
		strDefault =
			case
				when	idfsBaseReference = 10085001	/*CDR*/
					then	N'CDR'
				when	idfsBaseReference = 10085002	/*SLVL*/
					then	N'SLVL'
				when	idfsBaseReference = 10085007	/*TLVL*/
					then	N'TLVL'
				else	strDefault
			end
where	idfsReferenceType = 19000085 /*Sity Type*/
		and (	(	intRowStatus <> 1 
					and idfsBaseReference in 
						(	10085003	/*GDR*/,
							10085004	/*MORU*/,
							10085005	/*PACS*/,
							10085006	/*ProxyEMS*/
						)
				)
				or	(	intRowStatus <> 0
						and idfsBaseReference in
							(	10085001	/*CDR*/,
								10085002	/*SLVL*/,
								10085007	/*TLVL*/
							)
					)
				or	(	idfsBaseReference = 10085001	/*CDR*/
						and (strDefault is null or strDefault <> N'CDR' collate Cyrillic_General_CS_AS)
					)
				or	(	idfsBaseReference = 10085002	/*SLVL*/
						and (strDefault is null or strDefault <> N'SLVL' collate Cyrillic_General_CS_AS)
					)
				or	(	idfsBaseReference = 10085007	/*TLVL*/
						and (strDefault is null or strDefault <> N'TLVL' collate Cyrillic_General_CS_AS)
					)
			)

update		snt
set			snt.strTextString = 
			case
				when	snt.idfsBaseReference = 10085001	/*CDR*/
					then	N'CDR'
				when	snt.idfsBaseReference = 10085002	/*SLVL*/
					then	N'SLVL'
				when	snt.idfsBaseReference = 10085007	/*TLVL*/
					then	N'TLVL'
				else	snt.strTextString
			end,
			snt.intRowStatus = 0
from		trtBaseReference br
join		trtStringNameTranslation snt
on			snt.idfsBaseReference = br.idfsBaseReference
			and snt.idfsLanguage = 10049003 /*en-US*/
where		br.idfsReferenceType = 19000085 /*Sity Type*/
			and br.idfsBaseReference in
					(	10085001	/*CDR*/,
						10085002	/*SLVL*/,
						10085007	/*TLVL*/
					)
			and br.intRowStatus = 0
			and	(	(	snt.idfsBaseReference = 10085001	/*CDR*/
						and (snt.strTextString is null or snt.strTextString <> N'CDR' collate Cyrillic_General_CS_AS)
					)
				or	(	snt.idfsBaseReference = 10085002	/*SLVL*/
						and (snt.strTextString is null or snt.strTextString <> N'SLVL' collate Cyrillic_General_CS_AS)
					)
				or	(	snt.idfsBaseReference = 10085007	/*TLVL*/
						and (snt.strTextString is null or snt.strTextString <> N'TLVL' collate Cyrillic_General_CS_AS)
					)
				or	(	snt.idfsBaseReference in
						(	10085001	/*CDR*/,
							10085002	/*SLVL*/,
							10085007	/*TLVL*/
						)
						and snt.intRowStatus <> 0
					)
				)
/**************************************************************************************************************************************
* BV BUG 91691 - end
**************************************************************************************************************************************/



END TRY
BEGIN CATCH
    set @Error = ERROR_NUMBER()
	set	@ErrorMsg = /*N'ErrorNumber: ' + CONVERT(NVARCHAR, ERROR_NUMBER()) 
		+*/ N' ErrorSeverity: ' + CONVERT(NVARCHAR, ERROR_SEVERITY())
		+ N' ErrorState: ' + CONVERT(NVARCHAR, ERROR_STATE())
		+ N' ErrorProcedure: ' + ISNULL(ERROR_PROCEDURE(), N'')
		+ N' ErrorLine: ' +  CONVERT(NVARCHAR, ISNULL(ERROR_LINE(), N''))
		+ N' ErrorMessage: ' + ERROR_MESSAGE();
	
	if	@Error <> 0
	begin
			
		RAISERROR (N'Error %d: %s.', -- Message text.
			   16, -- Severity,
			   1, -- State,
			   @Error,
			   @ErrorMsg) WITH SETERROR; -- Second argument.
	end
    
END CATCH;


IF @@ERROR <> 0
	ROLLBACK TRAN
ELSE
	COMMIT TRAN

SET NOCOUNT OFF 
SET XACT_ABORT OFF 
GO


/**************************************************************************************************************************************
* ClearContext
**************************************************************************************************************************************/
SET NOCOUNT ON 

DELETE FROM [Giraffe_Archive].dbo.tstLocalSiteOptions WHERE strName = 'Context' collate Cyrillic_General_CI_AS and strValue = 'DataMigration' collate Cyrillic_General_CI_AS

DELETE FROM [Giraffe_Archive].dbo.tstLocalConnectionContext WHERE strConnectionContext = 'DataMigration' collate Cyrillic_General_CI_AS

SET NOCOUNT OFF 



--------------------------------

/**************************************************************************************************************************************
* Enable Triggers
**************************************************************************************************************************************/
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER	FUNCTION [dbo].[FN_GBL_TriggersWork] ()
RETURNS BIT
AS
BEGIN
RETURN 1
--RETURN 0
END



