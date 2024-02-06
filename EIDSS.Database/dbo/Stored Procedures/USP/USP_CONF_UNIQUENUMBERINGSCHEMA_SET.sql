/*
--Lamont Mitchell	3/36/22		Added new column intPreviousNumberValue to store previous values in uniquenumberingschema
-- Ann Xiong		03/14/2023	Implemented Data Audit

*/
-- exec USP_CONF_UNIQUENUMBERINGSCHEMA_SET 10057013,'Animal Group','Animal Group','AGP',null,'-',343,'en'
CREATE PROCEDURE [dbo].[USP_CONF_UNIQUENUMBERINGSCHEMA_SET]
(
	@idfsNumberName BIGINT,
	--@strDefault NVARCHAR(400),
	@strName NVARCHAR(400),
	--@strPrefix NVARCHAR(10),
	@strSuffix NVARCHAR(10),
	@strSpecialCharacter NVARCHAR(10),
	@intNumberValue INT,
	@langId NVARCHAR(50),
	@intNextNumberValue INT=NULL

)
AS
	DECLARE @returnCode INT = 0 
	DECLARE @returnMsg NVARCHAR(50) = 'SUCCESS' 

	--Data Audit--
	declare @idfsDataAuditEventType bigint = NULL;
	declare @idfsObjectType bigint = 10017019;                         -- Object Numbering Scheme
	declare @idfObject bigint = @idfsNumberName;
	declare @idfObjectTable_trtStringNameTranslation  bigint = 75990000000;
	declare @idfObjectTable_tstNextNumbers bigint = 76130000000;
	declare @idfDataAuditEvent bigint= NULL;
	declare @idfUserID bigint;
	declare @idfSiteId bigint;

	DECLARE @trtStringNameTranslation_BeforeEdit TABLE
	(
        		BaseReferenceID BIGINT,
        		LanguageID BIGINT,
        		strTextString varchar(2000)
	);
	DECLARE @trtStringNameTranslation_AfterEdit TABLE
	(
        		BaseReferenceID BIGINT,
        		LanguageID BIGINT,
        		strTextString varchar(2000)
	);

	DECLARE @tstNextNumbers_BeforeEdit TABLE
	(
        		NumberNameID BIGINT,
        		intNumberValue BIGINT,
        		strSpecialChar varchar(2),
        		strSuffix varchar(50),
        		intPreviousNumberValue BIGINT
	);
	DECLARE @tstNextNumbers_AfterEdit TABLE
	(
        		NumberNameID BIGINT,
        		intNumberValue BIGINT,
        		strSpecialChar varchar(2),
        		strSuffix varchar(50),
        		intPreviousNumberValue BIGINT
	);

	-- Get and Set UserId and SiteId
	select @idfUserId =userInfo.UserId, @idfSiteId=UserInfo.SiteId from dbo.FN_UserSiteInformation('Administrator') userInfo

	--Data Audit--
BEGIN
	BEGIN TRY
		
		Declare @intPreviousNumberValue BIGINT;
		SELECT @intPreviousNumberValue = intNumberValue from tstNextNumbers where idfsNumberName = @idfsNumberName		

		if (@intNextNumberValue IS NULL)
				SELECT @intNextNumberValue = intNumberValue+1 from tstNextNumbers where idfsNumberName = @idfsNumberName		

		--DECLARE @count INT = 0;
		--SET @count = (SELECT count(*) FROM tstNextNumbers WHERE (strDocumentName = @strName OR intNumberValue = @intNumberValue) AND idfsNumberName <> @idfsNumberName)
		----print @count

		--IF @count > 0
		--	BEGIN
		--		SET @returnMsg = 'DOES EXIST'
		--	END
		--ELSE
			--BEGIN
			 
				--UPDATE trtBaseReference set strDefault = @strDefault where idfsBaseReference = @idfsNumberName

           -- Data audit
		   --  tauDataAuditEvent  Event Type- Edit 
		   set @idfsDataAuditEventType =10016003;
		   -- insert record into tauDataAuditEvent - 
		   EXEC USSP_GBL_DataAuditEvent_GET @idfUserId, @idfSiteId, @idfsDataAuditEventType,@idfsObjectType,@idfsNumberName, @idfObjectTable_tstNextNumbers, @idfDataAuditEvent OUTPUT

           INSERT INTO @trtStringNameTranslation_BeforeEdit
           (
                    BaseReferenceID,
        			LanguageID,
        			strTextString
            )
            SELECT 	idfsBaseReference,
                    idfsLanguage,
					strTextString
            FROM	dbo.trtStringNameTranslation
            WHERE 	idfsBaseReference = @idfsNumberName AND idfsLanguage = dbo.FN_GBL_LanguageCode_GET(@langId);

            -- End data audit

			UPDATE trtStringNameTranslation set strTextString = @strName where idfsBaseReference = @idfsNumberName AND idfsLanguage = dbo.FN_GBL_LanguageCode_GET(@langId)

            -- Data audit
            INSERT INTO @trtStringNameTranslation_AfterEdit
            (
                    BaseReferenceID,
        			LanguageID,
        			strTextString
             )
             SELECT 	idfsBaseReference,
                    	idfsLanguage,
						strTextString
             FROM		dbo.trtStringNameTranslation
             WHERE 		idfsBaseReference = @idfsNumberName AND idfsLanguage = dbo.FN_GBL_LanguageCode_GET(@langId);

             INSERT INTO dbo.tauDataAuditDetailUpdate
             (
                        idfDataAuditEvent,
                        idfObjectTable,
                        idfColumn,
                        idfObject,
                        idfObjectDetail,
                        strOldValue,
                        strNewValue
           )
           SELECT		@idfDataAuditEvent,
                           @idfObjectTable_trtStringNameTranslation,
                           4578140000000,
                           a.BaseReferenceID,
                           a.LanguageID,
                           b.strTextString,
                           a.strTextString
            FROM	@trtStringNameTranslation_AfterEdit AS a
                        FULL JOIN @trtStringNameTranslation_BeforeEdit AS b
                            ON a.BaseReferenceID = b.BaseReferenceID AND a.LanguageID = b.LanguageID
            WHERE (a.strTextString <> b.strTextString)
                          OR (
                                 a.strTextString IS NOT NULL
                                 AND b.strTextString IS NULL
                             )
                          OR (
                                 a.strTextString IS NULL
                                 AND b.strTextString IS NOT NULL
                             );

            INSERT INTO @tstNextNumbers_BeforeEdit
            (
                    NumberNameID,
        			intNumberValue,
        			strSpecialChar,
        			strSuffix,
        			intPreviousNumberValue
            )
            SELECT 	idfsNumberName,
                    intNumberValue,
					strSpecialChar,
					strSuffix,
					intPreviousNumberValue
            FROM	dbo.tstNextNumbers
            WHERE 	idfsNumberName = @idfsNumberName;

            -- End data audit
			
			UPDATE tstNextNumbers 
			SET 
				intNumberValue = @intNumberValue, 
				strSpecialChar = @strSpecialCharacter,
				strSuffix = @strSuffix, 
				intPreviousNumberValue = @intNextNumberValue
			WHERE idfsNumberName = @idfsNumberName

            -- Data audit
            INSERT INTO @tstNextNumbers_AfterEdit
            (
                    NumberNameID,
        			intNumberValue,
        			strSpecialChar,
        			strSuffix,
        			intPreviousNumberValue
             )
             SELECT 	idfsNumberName,
                    	intNumberValue,
						strSpecialChar,
						strSuffix,
						intPreviousNumberValue
             FROM		dbo.tstNextNumbers
             WHERE 		idfsNumberName = @idfsNumberName;

			insert into dbo.tauDataAuditDetailUpdate(
					idfDataAuditEvent, idfObjectTable, idfColumn, 
					idfObject, idfObjectDetail, 
					strOldValue, strNewValue)
			select	@idfDataAuditEvent,@idfObjectTable_tstNextNumbers, 81810000000,
					a.NumberNameID,NULL,
					a.intNumberValue,b.intNumberValue
			from	@tstNextNumbers_BeforeEdit a  inner join @tstNextNumbers_AfterEdit b 
					on a.NumberNameID = b.NumberNameID
			where	(a.intNumberValue <> b.intNumberValue) 
					or(a.intNumberValue is not null and b.intNumberValue is null)
					or(a.intNumberValue is null and b.intNumberValue is not null)

			insert into dbo.tauDataAuditDetailUpdate(
					idfDataAuditEvent, idfObjectTable, idfColumn, 
					idfObject, idfObjectDetail, 
					strOldValue, strNewValue)
			select @idfDataAuditEvent,@idfObjectTable_tstNextNumbers, 51586990000097,
					a.NumberNameID,NULL,
					a.strSpecialChar,b.strSpecialChar
			from @tstNextNumbers_BeforeEdit a  inner join @tstNextNumbers_AfterEdit b 
					on a.NumberNameID = b.NumberNameID
			where (a.strSpecialChar <> b.strSpecialChar) 
					or(a.strSpecialChar is not null and b.strSpecialChar is null)
					or(a.strSpecialChar is null and b.strSpecialChar is not null)

			insert into dbo.tauDataAuditDetailUpdate(
					idfDataAuditEvent, idfObjectTable, idfColumn, 
					idfObject, idfObjectDetail, 
					strOldValue, strNewValue)
			select @idfDataAuditEvent,@idfObjectTable_tstNextNumbers, 81860000000,
					a.NumberNameID,NULL,
					a.strSuffix,b.strSuffix
			from @tstNextNumbers_BeforeEdit a  inner join @tstNextNumbers_AfterEdit b 
					on a.NumberNameID = b.NumberNameID
			where (a.strSuffix <> b.strSuffix) 
					or(a.strSuffix is not null and b.strSuffix is null)
					or(a.strSuffix is null and b.strSuffix is not null)

			insert into dbo.tauDataAuditDetailUpdate(
					idfDataAuditEvent, idfObjectTable, idfColumn, 
					idfObject, idfObjectDetail, 
					strOldValue, strNewValue)
			select @idfDataAuditEvent,@idfObjectTable_tstNextNumbers, 51586990000098,
					a.NumberNameID,NULL,
					a.intPreviousNumberValue,b.intPreviousNumberValue
			from @tstNextNumbers_BeforeEdit a  inner join @tstNextNumbers_AfterEdit b 
					on a.NumberNameID = b.NumberNameID
			where (a.intPreviousNumberValue <> b.intPreviousNumberValue) 
					or(a.intPreviousNumberValue is not null and b.intPreviousNumberValue is null)
					or(a.intPreviousNumberValue is null and b.intPreviousNumberValue is not null)
            -- End data audit
			--END
		SELECT @returnCode 'returnCode', @returnMsg 'returnMessage'

	END TRY

	BEGIN CATCH
		
		THROW

	END CATCH
END