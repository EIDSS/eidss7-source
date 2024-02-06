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
* Restore applicable languages
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


------=================
--------E7DB_Bref_0033 v6 soft delete 2 records
------=================
/*
SELECT * FROM dbo.trtReferenceType WHERE strReferenceTypeName IN ('Case Classification')----19000011
SELECT * FROM dbo.trtBaseReference WHERE idfsReferenceType IN (19000011) AND strDefault IN ('Confirmed','Probable')
*/

	--------UPDATE [Giraffe_Archive].[dbo].trtBaseReference 
	--------SET intRowStatus=1 
	--------,strMaintenanceFlag=@strMaintenanceFlag
	--------,strReservedAttribute=@strReservedAttibute
	--------WHERE idfsReferenceType IN (19000011) AND  strDefault IN ('Confirmed','Probable')

--========================================================================================
--end of DML update reference code
--========================================================================================


----------

------=================
--------BV BUG 98331 - start
------=================
update	[Giraffe_Archive].[dbo].trtBaseReference
set	blnSystem = 1
where idfsBaseReference = 19000144 /*Reference Type Name "Case Report Type"*/
------=================
--------BV BUG 98331 - end
------=================


------=================
--------BV BUG 102293 - start
------=================

update [Giraffe_Archive].[dbo].ffParameterType
set idfsReferenceType = 19000069 /*Flexible Form Parameter Value*/
where idfsParameterType = 217140000000 /*Y_N_Unk*/
		and idfsReferenceType is null or idfsReferenceType <> 19000069 /*Flexible Form Parameter Value*/
------=================
--------BV BUG 102293 - end
------=================


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



