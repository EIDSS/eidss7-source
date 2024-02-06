

GO

ALTER	FUNCTION [dbo].[FN_GBL_TriggersWork] ()
RETURNS BIT
AS
BEGIN
RETURN 1
--RETURN 0
END
GO
PRINT N'Altering Procedure [dbo].[USP_ADMIN_FF_ActivityParameters_SET]...';


GO
-- ================================================================================================
-- Name: USP_ADMIN_FF_ActivityParameters_SET
--
-- Description: Set the answers for a flex form AS an activity for that parameter
--          
-- Revision History:
-- Name             Date       Change
-- ---------------- ---------- --------------------------------------------------------------------
-- Doug Albanese	05/06/2020 Alteration to force supression in a different manner, AS a function
-- Doug Albanese	08/05/2021 Refactored to make a batch save, and to generate the observation, 
--                             if one doesn't exist
-- Doug Albanese	08/06/2021 Refactored again to work against a user defined table
-- Doug Albanese	08/06/2021 Can't use data tables with EF, so we will use a JSON object, 
--                             deciphered by OPENJSONL
-- Doug Albanese	08/11/2021 Removed a left-over debug statement.
-- Mark Wilson		09/30/2021 Added @User param, updated inserts and updates to include all columns
-- Doug Albanese	11/01/2021 Corrected a "Saving" issue with blank answers
-- Doug Albanese	08/19/2022 Corrected to give SQL Variant fields, a data type
-- Doug Albanese	08/23/2022 Changes to create variant declarations, before updating or 
--                             inserting
-- Stephen Long     11/29/2022 Added data audit logic for SAUC30 and 31.
-- Doug Albanese	04/11/2023 Answer, that were coming in blank, were not getting reset...so anything that is blank, I'm "Soft" deleting.
-- Doug Albanese	05/22/2023 Correction for answers disappearing on Matrix Grids
-- ================================================================================================
ALTER PROCEDURE [dbo].[USP_ADMIN_FF_ActivityParameters_SET]
(
    @idfObservation BIGINT = NULL,
    @idfsFormTemplate BIGINT,
    @answers NVARCHAR(MAX),
    @User NVARCHAR(200)
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @ReturnCode BIGINT = 0,
            @ReturnMessage NVARCHAR(MAX) = 'Success',
                                                                   -- added for case compares
            @TextBox BIGINT = 10067008,
            @TextBoxTotal BIGINT = 10067010,
            @TextBoxSum BIGINT = 10067011,
            @MemoBox BIGINT = 10067006,
            @DateControl BIGINT = 10067003,
            @DateTimeControl BIGINT = 10067004,
            @UpDown BIGINT = 10067009,
            @ComboBox BIGINT = 10067002,
            @RadioButton BIGINT = 217210000000,
            @CheckBoxDeclare BIGINT = 10067001,
            @AuditUserID BIGINT = NULL,
            @AuditSiteID BIGINT = NULL,
            @DataAuditEventID BIGINT = NULL,
            @DataAuditEventTypeID BIGINT = NULL,
            @ObjectID BIGINT = NULL,
            @ObjectObservationTableID BIGINT = 75640000000,        -- tlbObservation
            @ObjectActivityParametersTableID BIGINT = 75410000000; -- tlbActivityParameters
    DECLARE @SuppressSelect TABLE
    (
        ReturnCode INT,
        ReturnMessage VARCHAR(MAX)
    );
    DECLARE @ActivityParametersBeforeEdit TABLE
    (
        ActivityParametersID BIGINT,
        ParameterID BIGINT,
        ObservationID BIGINT,
        RowID BIGINT NULL,
        AnswerValue SQL_VARIANT NULL,
        RowStatus INT
    );
    DECLARE @ActivityParametersAfterEdit TABLE
    (
        ActivityParametersID BIGINT,
        ParameterID BIGINT,
        ObservationID BIGINT,
        RowID BIGINT NULL,
        AnswerValue SQL_VARIANT NULL,
        RowStatus INT
    );

    BEGIN TRY
        DECLARE @idfActivityParameters BIGINT,
                @idfsParameter BIGINT,
                @answer_SV SQL_VARIANT,
                @answer NVARCHAR(4000),
                @idfsEditor BIGINT,
                @idfRow BIGINT;
        DECLARE @tAnswers TABLE
        (
            idfsParameter BIGINT NULL,
            idfsEditor BIGINT NULL,
            answer NVARCHAR(4000),
            idfRow BIGINT NULL
        );

        INSERT INTO @tAnswers
        SELECT idfsParameter,
               idfsEditor,
               answer,
               idfRow
        FROM
            OPENJSON(@answers)
            WITH
            (
                idfsParameter BIGINT,
                idfsEditor BIGINT,
                answer NVARCHAR(4000),
                idfRow BIGINT
            );

        IF @idfObservation IS NULL
        BEGIN
            INSERT INTO @SuppressSelect
            EXEC USP_GBL_NEXTKEYID_GET 'tlbObservation', @idfObservation OUTPUT;
        END

        IF NOT EXISTS
        (
            SELECT 1
            FROM dbo.tlbObservation
            WHERE idfObservation = @idfObservation
        )
        BEGIN
            INSERT INTO dbo.tlbObservation
            (
                idfObservation,
                idfsFormTemplate,
                intRowStatus,
                rowguid,
                idfsSite,
                SourceSystemNameID,
                SourceSystemKeyValue,
                AuditCreateUser,
                AuditCreateDTM,
                AuditUpdateUser,
                AuditUpdateDTM
            )
            VALUES
            (@idfObservation,
             @idfsFormTemplate,
             0  ,
             NEWID(),
             dbo.FN_GBL_SITEID_GET(),
             10519001,
             '[{"idfObservation":' + CAST(@idfObservation AS NVARCHAR(100)) + '}]',
             @User,
             GETDATE(),
             @User,
             GETDATE()
            );

            -- Data audit
            INSERT INTO dbo.tauDataAuditDetailCreate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfObject,
                SourceSystemNameID,
                SourceSystemKeyValue,
                AuditCreateUser
            )
            VALUES
            (NULL,
             @ObjectObservationTableID,
             @idfObservation,
             10519001,
             '[{"idfDataAuditEvent":' + CAST(@DataAuditEventID AS NVARCHAR(300)) + ',"idfObjectTable":'
             + CAST(@ObjectObservationTableID AS NVARCHAR(300)) + '}]',
             @User
            );
        -- End data audit
        END

        WHILE EXISTS (SELECT * FROM @tAnswers)
        BEGIN
            SELECT TOP 1
                @idfsParameter = idfsParameter,
                @answer = answer,
                @idfsEditor = idfsEditor,
                @idfRow = idfRow
            FROM @tAnswers;

			if @answer = ''
			   BEGIN
				  UPDATE tlbActivityParameters
					 SET intRowStatus =1
				  WHERE 
					 idfsParameter = @idfsParameter AND
					 idfRow = @idfRow AND
					 idfObservation = @idfObservation
			   END
			ELSE
			   BEGIN

				  IF @idfsEditor = @TextBox
					  SET @answer_SV = CAST(@answer AS NVARCHAR);
				  IF @idfsEditor = @TextBoxTotal
					  SET @answer_SV = CAST(@answer AS NVARCHAR);
				  IF @idfsEditor = @TextBoxSum
					  SET @answer_SV = CAST(@answer AS NVARCHAR);
				  IF @idfsEditor = @MemoBox
					  SET @answer_SV = CAST(@answer AS NVARCHAR);
				  IF @idfsEditor = @DateControl
					  SET @answer_SV = CAST(@answer AS DATETIME);
				  IF @idfsEditor = @DateTimeControl
					  SET @answer_SV = CAST(@answer AS DATETIME);
				  IF @idfsEditor = @UpDown
					  SET @answer_SV = CAST(@answer AS BIGINT);
				  IF @idfsEditor = @ComboBox
					  SET @answer_SV = CAST(@answer AS BIGINT);
				  IF @idfsEditor = @RadioButton
					  SET @answer_SV = CAST(@answer AS BIGINT);
				  IF @idfsEditor = @CheckBoxDeclare
					  SET @answer_SV = CAST(@answer AS BIT);
			
				  IF @answer_SV <> ''
					 BEGIN
						 IF (
								(@answer_SV IS NULL)
								OR (LEN(CAST(@answer_SV AS NVARCHAR(4000))) = 0)
							)
							BEGIN
								INSERT INTO @SuppressSelect
								EXEC dbo.USP_ADMIN_FF_ActivityParameters_DEL @idfsParameter,
																			 @idfObservation,
																			 @idfRow;
							END
						 ELSE
							BEGIN
								IF NOT EXISTS
								(
									SELECT TOP 1 1
									FROM dbo.tlbActivityParameters
									WHERE idfsParameter = @idfsParameter
										  AND idfObservation = @idfObservation
										  AND idfRow = @idfRow
								)
								   BEGIN
									   INSERT INTO @SuppressSelect
									   EXEC USP_GBL_NEXTKEYID_GET 'tlbActivityParameters',
																  @idfActivityParameters OUTPUT;

									   INSERT INTO dbo.tlbActivityParameters
									   (
										   idfActivityParameters,
										   idfsParameter,
										   idfObservation,
										   idfRow,
										   varValue,
										   intRowStatus,
										   rowguid,
										   SourceSystemNameID,
										   SourceSystemKeyValue,
										   AuditCreateUser,
										   AuditCreateDTM,
										   AuditUpdateUser,
										   AuditUpdateDTM
									   )
									   VALUES
									   (@idfActivityParameters,
										@idfsParameter,
										@idfObservation,
										@idfRow,
										@answer_SV,
										0  ,
										NEWID(),
										10519001,
										'[{"idfActivityParameters":' + CAST(@idfActivityParameters AS NVARCHAR(100)) + '}]',
										@User,
										GETDATE(),
										@User,
										GETDATE()
									   );

									   -- Data audit
									   INSERT INTO dbo.tauDataAuditDetailCreate
									   (
										   idfDataAuditEvent,
										   idfObjectTable,
										   idfObject,
										   idfObjectDetail,
										   SourceSystemNameID,
										   SourceSystemKeyValue,
										   AuditCreateUser
									   )
									   VALUES
									   (NULL,
										@ObjectActivityParametersTableID,
										@idfActivityParameters,
										@idfObservation,
										10519001,
										'[{"idfDataAuditEvent":' + CAST(@DataAuditEventID AS NVARCHAR(300)) + ',"idfObjectTable":'
										+ CAST(@ObjectActivityParametersTableID AS NVARCHAR(300)) + '}]',
										@User
									   );
								   -- End data audit
								   END
								ELSE
								   BEGIN
									   SET @User = ISNULL(@User, 'System');

									   DELETE FROM @ActivityParametersAfterEdit;
									   DELETE FROM @ActivityParametersBeforeEdit;

									   -- Data audit
									   -- Get and set user and site identifiers
									   SELECT @AuditUserID = userInfo.UserId,
											  @AuditSiteID = userInfo.SiteId
									   FROM dbo.FN_UserSiteInformation(@User) userInfo;

									   INSERT INTO @ActivityParametersBeforeEdit
									   (
										   ActivityParametersID,
										   ParameterID,
										   ObservationID,
										   RowID,
										   AnswerValue,
										   RowStatus
									   )
									   SELECT idfActivityParameters,
											  idfsParameter,
											  idfObservation,
											  idfRow,
											  varValue,
											  intRowStatus
									   FROM dbo.tlbActivityParameters
									   WHERE idfsParameter = @idfsParameter
											 AND idfObservation = @idfObservation 
											 AND idfRow = @idfRow;

									   UPDATE dbo.tlbActivityParameters
									   SET varValue = @answer_SV,
										   intRowStatus = 0,
										   AuditUpdateUser = @User,
										   AuditUpdateDTM = GETDATE()
									   WHERE idfsParameter = @idfsParameter
											 AND idfObservation = @idfObservation
											 AND idfRow = @idfRow;

									   INSERT INTO @ActivityParametersAfterEdit
									   (
										   ActivityParametersID,
										   ParameterID,
										   ObservationID,
										   RowID,
										   AnswerValue,
										   RowStatus
									   )
									   SELECT idfActivityParameters,
											  idfsParameter,
											  idfObservation,
											  idfRow,
											  varValue,
											  intRowStatus
									   FROM dbo.tlbActivityParameters
									   WHERE idfsParameter = @idfsParameter
											 AND idfObservation = @idfObservation
											 AND idfRow = @idfRow;

									   INSERT INTO dbo.tauDataAuditDetailUpdate
									   (
										   idfDataAuditEvent,
										   idfObjectTable,
										   idfColumn,
										   idfObject,
										   idfObjectDetail,
										   strOldValue,
										   strNewValue,
										   AuditCreateUser
									   )
									   SELECT NULL,
											  @ObjectActivityParametersTableID,
											  78180000000,
											  a.ActivityParametersID,
											  @idfObservation,
											  b.ParameterID,
											  a.ParameterID,
											  @User
									   FROM @ActivityParametersAfterEdit AS a
										   FULL JOIN @ActivityParametersBeforeEdit AS b
											   ON a.ActivityParametersID = b.ActivityParametersID
									   WHERE (a.ParameterID <> b.ParameterID)
											 OR (
													a.ParameterID IS NOT NULL
													AND b.ParameterID IS NULL
												)
											 OR (
													a.ParameterID IS NULL
													AND b.ParameterID IS NOT NULL
												);

									   INSERT INTO dbo.tauDataAuditDetailUpdate
									   (
										   idfDataAuditEvent,
										   idfObjectTable,
										   idfColumn,
										   idfObject,
										   idfObjectDetail,
										   strOldValue,
										   strNewValue,
										   AuditCreateUser
									   )
									   SELECT NULL,
											  @ObjectActivityParametersTableID,
											  78170000000,
											  a.ActivityParametersID,
											  @idfObservation,
											  b.ObservationID,
											  a.ObservationID,
											  @User
									   FROM @ActivityParametersAfterEdit AS a
										   FULL JOIN @ActivityParametersBeforeEdit AS b
											   ON a.ActivityParametersID = b.ActivityParametersID
									   WHERE (a.ObservationID <> b.ObservationID)
											 OR (
													a.ObservationID IS NOT NULL
													AND b.ObservationID IS NULL
												)
											 OR (
													a.ObservationID IS NULL
													AND b.ObservationID IS NOT NULL
												);

									   INSERT INTO dbo.tauDataAuditDetailUpdate
									   (
										   idfDataAuditEvent,
										   idfObjectTable,
										   idfColumn,
										   idfObject,
										   idfObjectDetail,
										   strOldValue,
										   strNewValue,
										   AuditCreateUser
									   )
									   SELECT NULL,
											  @ObjectActivityParametersTableID,
											  4576590000000,
											  a.ActivityParametersID,
											  @idfObservation,
											  b.RowID,
											  a.RowID,
											  @User
									   FROM @ActivityParametersAfterEdit AS a
										   FULL JOIN @ActivityParametersBeforeEdit AS b
											   ON a.ActivityParametersID = b.ActivityParametersID
									   WHERE (a.RowID <> b.RowID)
											 OR (
													a.RowID IS NOT NULL
													AND b.RowID IS NULL
												)
											 OR (
													a.RowID IS NULL
													AND b.RowID IS NOT NULL
												);

									   INSERT INTO dbo.tauDataAuditDetailUpdate
									   (
										   idfDataAuditEvent,
										   idfObjectTable,
										   idfColumn,
										   idfObject,
										   idfObjectDetail,
										   strOldValue,
										   strNewValue,
										   AuditCreateUser
									   )
									   SELECT NULL,
											  @ObjectActivityParametersTableID,
											  78190000000,
											  a.ActivityParametersID,
											  @idfObservation,
											  b.AnswerValue,
											  a.AnswerValue,
											  @User
									   FROM @ActivityParametersAfterEdit AS a
										   FULL JOIN @ActivityParametersBeforeEdit AS b
											   ON a.ActivityParametersID = b.ActivityParametersID
									   WHERE (a.AnswerValue <> b.AnswerValue)
											 OR (
													a.AnswerValue IS NOT NULL
													AND b.AnswerValue IS NULL
												)
											 OR (
													a.AnswerValue IS NULL
													AND b.AnswerValue IS NOT NULL
												);

									   INSERT INTO dbo.tauDataAuditDetailRestore
									   (
										   idfDataAuditEvent,
										   idfObjectTable,
										   idfObject,
										   idfObjectDetail,
										   AuditCreateUser
									   )
									   SELECT NULL,
											  @ObjectActivityParametersTableID,
											  a.ActivityParametersID,
											  @idfObservation,
											  @User
									   FROM @ActivityParametersAfterEdit AS a
										   FULL JOIN @ActivityParametersBeforeEdit AS b
											   ON a.ActivityParametersID = b.ActivityParametersID
									   WHERE a.RowStatus = 0
											 AND b.RowStatus = 1;
								   END
							END
					 END
			   END

			   SET ROWCOUNT 1;
			   DELETE FROM @tAnswers;
			   SET ROWCOUNT 0;
        END

        SELECT @ReturnCode AS ReturnCode,
               @ReturnMessage AS ReturnMessage,
               @idfObservation AS idfObservation;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END
GO
PRINT N'Altering Procedure [dbo].[USP_ADMIN_FF_FlexForm_Get]...';


GO
-- ================================================================================================
-- Name: USP_ADMIN_FF_FlexForm_Get
-- Description: Gets list of the Parameters.
--          
-- Revision History:
-- Name				Date			Change
-- ---------------	----------	--------------------------------------------------------------------
-- Doug Albabese	01/06/2020	Initial release for new API.
-- Doug Albanese	07/02/2020	Added field blnGrid to denote the displaying of data in a table format
-- Doug Albanese	09/30/2020	Added filtering for language on the Design Option Tables
-- Doug Albanese	01/06/2021	Added idfsEditMode to clarify if the parameter is required or not.
-- Doug Albanese	02/02/2021	Found a static value for English in this procedure.
-- Doug Albanese	08/01/2021	Added idfsFormTemplate for ease of access
-- Mark Wilson		09/29/2021	Updated to remove E7 FN_FF_DesignLanguageForParameter_GET, 
--								removed unused parameters
-- Doug Albanese	03/17/2022	Added a "commented out" section to replace, when development is not happening during core hours
--	Doug Albanese	08/02/2022	Fix for IGAT #400. Extra parameters showing up that didn't belong to questionnnaire on matrix.
-- Doug Albanese	 01/0/2023	 Changed up a join to see if the displayed labeling will work better for the customer.
-- Doug Albanese	 02/06/2023	 Changed how Parameters, whith no sections, or ordered.
-- Doug Albanese	 02/28/2023	 Update for adding the Parent Section name
-- Doug Albanese	 03/01/2023	 Added the "Decore Element Text"
-- Doug Albnaese	04/13/2023	Added a "Coalesce" to make use of default data from the english side, when none exist for the selected language.
-- Doug Albanese	05/23/2023	Added a new parameter to obtain the Form Template via an observation
/*
DECLARE    @return_value int

 

EXEC    @return_value = [dbo].[USP_ADMIN_FF_FlexForm_Get]
        @LangID = N'en-US',
        @idfsDiagnosis = 7719020000000,
        @idfsFormType = 10034010,
        @idfsFormTemplate = NULL

*/
-- ================================================================================================
ALTER PROCEDURE [dbo].[USP_ADMIN_FF_FlexForm_Get] (
	@LangID						NVARCHAR(50) = NULL
	,@idfsDiagnosis				BIGINT = NULL
	,@idfsFormType				BIGINT = NULL
	,@idfsFormTemplate			BIGINT = NULL
	,@idfObservation			BIGINT = NULL
	)
AS
BEGIN
	DECLARE @idfsCountry AS BIGINT,
			@idfsLanguage BIGINT = dbo.FN_GBL_LanguageCode_GET(@LangID)
	DECLARE @tmpTemplate AS TABLE (
		idfsFormTemplate BIGINT
		,IsUNITemplate BIT
		)
	DECLARE @returnCode INT = 0;
	DECLARE @returnMsg NVARCHAR(MAX) = 'SUCCESS';

	BEGIN TRY
		IF @idfObservation IS NOT NULL
		 BEGIN
			SELECT
			   @idfsFormTemplate = idfsFormTemplate
			FROM
			   tlbObservation
			WHERE
			   idfObservation = @idfObservation
		 END

		IF @idfsFormTemplate IS NULL
			BEGIN
				--Obtain idfsFormTemplate, via given parameters of idfsDiagnosis and idfsFormType
				---------------------------------------------------------------------------------
				SET @idfsCountry = dbo.FN_GBL_CurrentCountry_GET()

				INSERT INTO @tmpTemplate
				EXECUTE dbo.USP_ADMIN_FF_ActualTemplate_GET 
					@idfsCountry,
					@idfsDiagnosis,
					@idfsFormType

				SELECT TOP 1 @idfsFormTemplate = idfsFormTemplate
				FROM @tmpTemplate

				IF @idfsFormTemplate = - 1
					SET @idfsFormTemplate = NULL

				---------------------------------------------------------------------------------
			END

		SELECT 
			s.idfsParentSection
			,COALESCE(p.idfsSection,0) AS idfsSection
			,p.idfsParameter
			,PS.name AS ParentSectionName
			,RF.Name AS SectionName
			,PN.Name AS ParameterName
			,PTR.Name AS parameterType
			,p.idfsParameterType
			,pt.idfsReferenceType
			,p.idfsEditor
			,COALESCE(sdo.intOrder,2147483646) AS SectionOrder
			,COALESCE(PDO.intOrder, PDO_C.intOrder) AS ParameterOrder
			,s.blnGrid
			,s.blnFixedRowSet
			,PFT.idfsEditMode
			,pft.idfsFormTemplate
			,DT.name AS DecoreElementText
		FROM dbo.ffParameter p
		LEFT JOIN dbo.ffParameterForTemplate PFT ON PFT.idfsParameter = p.idfsParameter AND PFT.intRowStatus = 0
		LEFT JOIN dbo.ffSection s ON s.idfsSection = p.idfsSection
		LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LangID, 19000101) PS ON S.idfsParentSection = PS.idfsReference
		LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LangID, 19000101) RF ON S.idfsSection = RF.idfsReference
		LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LangID, 19000071) PTR ON PTR.idfsReference = P.idfsParameterType
		LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LangID, 19000070) PN ON PN.idfsReference = P.idfsParameterCaption
		LEFT JOIN dbo.ffParameterDesignOption PDO ON PFT.idfsParameter = PDO.idfsParameter
			AND PDO.idfsFormTemplate = PFT.idfsFormTemplate
			AND PDO.idfsLanguage = @idfsLanguage
			AND PDO.intRowStatus = 0
		LEFT JOIN dbo.ffSectionDesignOption sdo ON sdo.idfsSection = s.idfsSection 
			AND sdo.idfsFormTemplate = @idfsFormTemplate 
			AND sdo.idfsLanguage = @idfsLanguage
			AND sdo.intRowStatus = 0
		LEFT JOIN dbo.ffParameterType PT
			ON pt.idfsParameterType = p.idfsParameterType
		LEFT JOIN ffDecorElement DE
			ON DE.idfsFormTemplate = @idfsFormTemplate AND DE.idfsSection = s.idfsParentSection AND DE.intRowStatus = 0
	    LEFT JOIN ffDecorElementText DET
			ON DET.idfDecorElement = DE.idfDecorElement
		LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LangID, 19000131) DT ON DT.idfsReference = DET.idfsBaseReference
		--------------------------------------------------------------------------------------------------------------------
		--Special join for coalescing design options that may not exist                                                   --
		--------------------------------------------------------------------------------------------------------------------
		LEFT JOIN dbo.ffParameterDesignOption PDO_C ON PFT.idfsParameter = PDO_C.idfsParameter
			AND PDO_C.idfsFormTemplate = PFT.idfsFormTemplate
			AND PDO_C.idfsLanguage = dbo.FN_GBL_LanguageCode_GET('en-us') --Default language, DO NOT REMOVE
			AND PDO_C.intRowStatus = 0
		--------------------------------------------------------------------------------------------------------------------

		WHERE PFT.idfsFormTemplate = @idfsFormTemplate
		ORDER BY  SectionOrder
			,ParameterOrder

	END TRY

	BEGIN CATCH
		IF @@TRANCOUNT = 1
			ROLLBACK;

		SET @returnCode = ERROR_NUMBER();
		SET @returnMsg = 'ErrorNumber: ' + CONVERT(VARCHAR, ERROR_NUMBER()) + ' ErrorSeverity: ' + CONVERT(VARCHAR, ERROR_SEVERITY()) + ' ErrorState: ' + CONVERT(VARCHAR, ERROR_STATE()) + ' ErrorProcedure: ' + ISNULL(ERROR_PROCEDURE(), '') + ' ErrorLine: ' + CONVERT(VARCHAR, ISNULL(ERROR_LINE(), '')) + ' ErrorMessage: ' + ERROR_MESSAGE();;

		THROW;
	END CATCH
END
GO
PRINT N'Altering Procedure [dbo].[USP_HUM_DISEASE_REPORT_GETList]...';


GO
-- ================================================================================================
-- Name: USP_HUM_DISEASE_REPORT_GETList
--
-- Description: Get a list of human disease reports for the human module.
--          
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Mandar Kulkarni             Initial release.
-- Stephen Long     03/26/2018 Added the person reported by name for the farm use case.
-- JWJ	            04/17/2018 Added extra col to return:  tlbHuman.idfHumanActual. Added alias 
--                             for region rayon to make them unique in results added report status 
--                             to results 
-- Harold Pryor     10/22/2018 Added input search parameters SearchStrPersonFirstName, 
--                             SearchStrPersonMiddleName, and SearchStrPersonLastName
-- Harold Pryor     10/31/2018 Added input search parameters SearchLegacyCaseID and	
--                             added strLocation (region, rayon) field to list result set
-- Harold Pryor     11/12/2018 Changed @SearchLegacyCaseID parameter from BIGINT to NVARCHAR(200)
-- Stephen Long     12/19/2018 Added pagination logic.
-- Stephen Long     07/07/2019 Added monitoring session ID to parameters and where clause.
-- Stephen Long     07/10/2019 Changed address join from exposure location to patient's current 
--                             residence address.
-- Stephen Long     07/19/2019 Corrected patient name and person entered by name ', '.
-- Stephen Long     02/26/2020 Added non-configurable site filtration rules.
-- Lamont Mitchell  03/03/2020 Modified all joins on human case and human to join on human actual.
-- Stephen Long     04/01/2020 Added if/else for first-level and second-level site types to bypass 
--                             non-configurable rules.
-- Stephen Long     05/18/2020 Added disease filtration rules from use case SAUC62.
-- Stephen Long     06/18/2020 Corrected the join on the rayon of the report current residence 
--                             address (human ID to human ID instead of human ID to human actual 
--                             ID).
-- Stephen Long     06/18/2020 Added where criteria to the query when no site filtration is 
--                             required.
-- Stephen Long     07/07/2020 Added trim to EIDSS identifier like criteria.
-- Doug Albanese	11/16/2020 Added Outbreak Tied filtering
-- Stephen Long     11/18/2020 Added site ID to the query.
-- Stephen Long     11/28/2020 Added configurable site filtration rules.
-- Stephen Long     12/13/2020 Added apply configurable filtration indicator parameter.
-- Stephen Long     12/24/2020 Modified join on disease filtration default role rule.
-- Stephen Long     12/29/2020 Changed function call on reference data for inactive records.
-- Stephen Long     01/04/2020 Added option recompile due to number of optional parameters for 
--                             better execution plan.
-- Stephen Long     04/04/2021 Added updated pagination and location hierarchy.
-- Mike Kornegay	09/23/2021 Added HospitalizationStatus field
-- Stephen Long     11/03/2021 Added disease ID field.
-- Mike Kornegay	11/16/2021 Fix hospitalization field for translations
-- Mike Kornegay	12/07/2021 Added back EnteredByPersonName 
-- Mike Kornegay	12/08/2021 Swapped out FN_GBL_GIS_ReferenceRepair for new flat hierarchy
-- Mike Kornegay	12/23/2021 Fixed YN hospitalization where clause
-- Manickandan Govindarajan 03/21/2022  Rename Param PageNumber to Page
-- Stephen Long     03/29/2022 Fix to site filtration to pull back a user's own site records.
-- Stephen Long     06/03/2022 Updated to point default access rules to base reference.
-- Mike Kornegay    06/06/2022 Added parameter OutcomeID.
-- Mike Kornegay	06/13/2022 Changed inner joins to left joins in final query because result set 
--                             was incorrect.
-- Stephen Long     08/14/2022 Added additional criteria for outbreak cases for laboratory module.
--                             TODO: replace filter outbreak cases parameter, and just filter in 
--                             the initial query to avoid getting extra unneeded records; also just 
--                             make it a boolean value.
-- Mark Wilson      09/01/2022 update to use denormalized locations to work with site filtration.
-- Stephen Long     09/22/2022 Add check for "0" page size.  If "0", then set to 1.
-- Mike Kornegay	10/11/2022 Move order by back to CTE row partition for performance and add 
--                             LanguageID to default filtration rule joins.
-- Stephen Long     11/02/2022 Fixes for 4599 - site filtration returning the wrong results.
-- Stephen Long     11/09/2022 Fix on where criteria when filtration is run; added groupings for 
--                             the user entered parameters from the search criteria page.
-- Ann Xiong		11/29/2022 Updated to return records correctly when filter by only 
--                             DateEnteredFrom or DateEnteredTo.
-- Ann Xiong		11/30/2022 Updated to return records including DateEnteredTo.
-- Stephen Long     01/09/2023 Updated for site filtration queries.
-- Stephen Long     04/21/2023 Changed employee default group logic on disease filtration.
-- Stephen Long     05/09/2023 Corrected exposure table alias on the where criteria, and removed
--                             unneeded gisLocation left join in the final query.  Added 
--                             record identifier search indicator logic.
-- Stephen Long     05/18/2023 Fix for item 5584.
--
-- Testing code:
-- EXEC USP_HUM_DISEASE_REPORT_GETList 'en-US'
-- EXEC USP_HUM_DISEASE_REPORT_GETList 'en-US', @EIDSSReportID = 'H'
-- ================================================================================================
ALTER PROCEDURE [dbo].[USP_HUM_DISEASE_REPORT_GETList]
    @LanguageID NVARCHAR(50),
    @ReportKey BIGINT = NULL,
    @ReportID NVARCHAR(200) = NULL,
    @LegacyReportID NVARCHAR(200) = NULL,
    @SessionKey BIGINT = NULL,
    @PatientID BIGINT = NULL,
    @PersonID NVARCHAR(200) = NULL,
    @DiseaseID BIGINT = NULL,
    @ReportStatusTypeID BIGINT = NULL,
    @AdministrativeLevelID BIGINT = NULL,
    @DateEnteredFrom DATETIME = NULL,
    @DateEnteredTo DATETIME = NULL,
    @ClassificationTypeID BIGINT = NULL,
    @HospitalizationYNID BIGINT = NULL,
    @PatientFirstName NVARCHAR(200) = NULL,
    @PatientMiddleName NVARCHAR(200) = NULL,
    @PatientLastName NVARCHAR(200) = NULL,
    @SentByFacilityID BIGINT = NULL,
    @ReceivedByFacilityID BIGINT = NULL,
    @DiagnosisDateFrom DATETIME = NULL,
    @DiagnosisDateTo DATETIME = NULL,
    @LocalOrFieldSampleID NVARCHAR(200) = NULL,
    @DataEntrySiteID BIGINT = NULL,
    @DateOfSymptomsOnsetFrom DATETIME = NULL,
    @DateOfSymptomsOnsetTo DATETIME = NULL,
    @NotificationDateFrom DATETIME = NULL,
    @NotificationDateTo DATETIME = NULL,
    @DateOfFinalCaseClassificationFrom DATETIME = NULL,
    @DateOfFinalCaseClassificationTo DATETIME = NULL,
    @LocationOfExposureAdministrativeLevelID BIGINT = NULL,
    @OutcomeID BIGINT = NULL,
    @FilterOutbreakTiedReports INT = 0,
    @OutbreakCasesIndicator BIT = 0,
    @RecordIdentifierSearchIndicator BIT = 0,
    @UserSiteID BIGINT,
    @UserOrganizationID BIGINT,
    @UserEmployeeID BIGINT,
    @ApplySiteFiltrationIndicator BIT = 0,
    @SortColumn NVARCHAR(30) = 'ReportID',
    @SortOrder NVARCHAR(4) = 'DESC',
    @Page INT = 1,
    @PageSize INT = 10
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @firstRec INT,
            @lastRec INT,
            @FiltrationSiteAdministrativeLevelID AS BIGINT,
            @LanguageCode AS BIGINT = dbo.FN_GBL_LanguageCode_GET(@LanguageID);
    SET @firstRec = (@Page - 1) * @PageSize
    SET @lastRec = (@Page * @PageSize + 1);

    DECLARE @Results TABLE
    (
        ID BIGINT NOT NULL INDEX IX1 CLUSTERED,
        ReadPermissionIndicator INT NOT NULL,
        AccessToPersonalDataPermissionIndicator INT NOT NULL,
        AccessToGenderAndAgeDataPermissionIndicator INT NOT NULL,
        WritePermissionIndicator INT NOT NULL,
        DeletePermissionIndicator INT NOT NULL
    );
    DECLARE @FinalResults TABLE
    (
        ID BIGINT NOT NULL INDEX IX1 CLUSTERED,
        ReadPermissionIndicator INT NOT NULL,
        AccessToPersonalDataPermissionIndicator INT NOT NULL,
        AccessToGenderAndAgeDataPermissionIndicator INT NOT NULL,
        WritePermissionIndicator INT NOT NULL,
        DeletePermissionIndicator INT NOT NULL
    );
    DECLARE @UserSitePermissions TABLE
    (
        SiteID BIGINT NOT NULL,
        PermissionTypeID BIGINT NOT NULL,
        Permission INT NOT NULL
    );
    DECLARE @UserGroupSitePermissions TABLE
    (
        SiteID BIGINT NOT NULL,
        PermissionTypeID BIGINT NOT NULL,
        Permission INT NOT NULL
    );

    BEGIN TRY
        INSERT INTO @UserGroupSitePermissions
        SELECT oa.idfsOnSite,
               oa.idfsObjectOperation,
               CASE
                   WHEN oa.intPermission = 2 THEN
                       3
                   ELSE
                       2
               END
        FROM dbo.tstObjectAccess oa
            INNER JOIN dbo.tlbEmployeeGroupMember egm
                ON egm.idfEmployee = @UserEmployeeID
                   AND egm.intRowStatus = 0
        WHERE oa.intRowStatus = 0
              AND oa.idfsObjectType = 10060011 -- Site
              AND oa.idfActor = egm.idfEmployeeGroup;

        INSERT INTO @UserSitePermissions
        SELECT oa.idfsOnSite,
               oa.idfsObjectOperation,
               CASE
                   WHEN oa.intPermission = 2 THEN
                       5
                   ELSE
                       4
               END
        FROM dbo.tstObjectAccess oa
        WHERE oa.intRowStatus = 0
              AND oa.idfsObjectType = 10060011 -- Site
              AND oa.idfActor = @UserEmployeeID;

        IF @PageSize = 0
        BEGIN
            SET @PageSize = 1;
        END

        -- ========================================================================================
        -- NO CONFIGURABLE FILTRATION RULES APPLIED
        --
        -- For first and second level sites, do not apply any site filtration rules.
        -- ========================================================================================
        IF @ApplySiteFiltrationIndicator = 0
        BEGIN
            IF @RecordIdentifierSearchIndicator = 1
            BEGIN
                INSERT INTO @Results
                SELECT idfHumanCase,
                       1,
                       1,
                       1,
                       1,
                       1
                FROM dbo.tlbHumanCase
                WHERE intRowStatus = 0
                      AND idfsFinalDiagnosis IS NOT NULL
                      AND (
                              strCaseID LIKE '%' + TRIM(@ReportID) + '%'
                              OR @ReportID IS NULL
                          )
                      AND (
                              LegacyCaseID LIKE '%' + TRIM(@LegacyReportID) + '%'
                              OR @LegacyReportID IS NULL
                          )
            END
            ELSE
            BEGIN
                INSERT INTO @Results
                SELECT hc.idfHumanCase,
                       1,
                       1,
                       1,
                       1,
                       1
                FROM dbo.tlbHumanCase hc
                    INNER JOIN dbo.tlbHuman h
                        ON h.idfHuman = hc.idfHuman
                           AND h.intRowStatus = 0
                    INNER JOIN dbo.tlbGeoLocation currentAddress
                        ON currentAddress.idfGeoLocation = h.idfCurrentResidenceAddress
                    LEFT JOIN dbo.gisLocationDenormalized g
                        ON g.idfsLocation = currentAddress.idfsLocation
                           AND g.idfsLanguage = @LanguageCode
                    LEFT JOIN dbo.tlbMaterial m
                        ON m.idfHumanCase = hc.idfHumanCase
                           AND m.intRowStatus = 0
                    LEFT JOIN dbo.tlbGeoLocation exposure
                        ON exposure.idfGeoLocation = hc.idfPointGeoLocation
                    LEFT JOIN dbo.gisLocationDenormalized gExposure
                        ON gExposure.idfsLocation = exposure.idfsLocation
                           AND gExposure.idfsLanguage = @LanguageCode
                WHERE hc.intRowStatus = 0
                      AND hc.idfsFinalDiagnosis IS NOT NULL
                      AND (
                              hc.idfHumanCase = @ReportKey
                              OR @ReportKey IS NULL
                          )
                      AND (
                              hc.idfParentMonitoringSession = @SessionKey
                              OR @SessionKey IS NULL
                          )
                      AND (
                              h.idfHumanActual = @PatientID
                              OR @PatientID IS NULL
                          )
                      AND (
                              h.strPersonId = @PersonID
                              OR @PersonID IS NULL
                          )
                      AND (
                              idfsFinalDiagnosis = @DiseaseID
                              OR @DiseaseID IS NULL
                          )
                      AND (
                              idfsCaseProgressStatus = @ReportStatusTypeID
                              OR @ReportStatusTypeID IS NULL
                          )
                      AND (
                              g.Level1ID = @AdministrativeLevelID
                              OR g.Level2ID = @AdministrativeLevelID
                              OR g.Level3ID = @AdministrativeLevelID
                              OR g.Level4ID = @AdministrativeLevelID
                              OR g.Level5ID = @AdministrativeLevelID
                              OR g.Level6ID = @AdministrativeLevelID
                              OR g.Level7ID = @AdministrativeLevelID
                              OR @AdministrativeLevelID IS NULL
                          )
                      AND (
                              hc.datEnteredDate >= @DateEnteredFrom
                              OR @DateEnteredFrom IS NULL
                          )
                      AND (
                              (CONVERT(DATE, hc.datEnteredDate, 102) <= @DateEnteredTo)
                              OR @DateEnteredTo IS NULL
                          )
                      AND (
                              (CAST(hc.datFinalDiagnosisDate AS DATE)
                      BETWEEN @DiagnosisDateFrom AND @DiagnosisDateTo
                              )
                              OR (
                                     @DiagnosisDateFrom IS NULL
                                     OR @DiagnosisDateTo IS NULL
                                 )
                          )
                      AND (
                              (CAST(hc.datNotificationDate AS DATE)
                      BETWEEN @NotificationDateFrom AND @NotificationDateTo
                              )
                              OR (
                                     @NotificationDateFrom IS NULL
                                     OR @NotificationDateTo IS NULL
                                 )
                          )
                      AND (
                              (CAST(hc.datOnSetDate AS DATE)
                      BETWEEN @DateOfSymptomsOnsetFrom AND @DateOfSymptomsOnsetTo
                              )
                              OR (
                                     @DateOfSymptomsOnsetFrom IS NULL
                                     OR @DateOfSymptomsOnsetTo IS NULL
                                 )
                          )
                      AND (
                              (CAST(hc.datFinalCaseClassificationDate AS DATE)
                      BETWEEN @DateOfFinalCaseClassificationFrom AND @DateOfFinalCaseClassificationTo
                              )
                              OR (
                                     @DateOfFinalCaseClassificationFrom IS NULL
                                     OR @DateOfFinalCaseClassificationTo IS NULL
                                 )
                          )
                      AND (
                              hc.idfReceivedByOffice = @ReceivedByFacilityID
                              OR @ReceivedByFacilityID IS NULL
                          )
                      AND (
                              hc.idfSentByOffice = @SentByFacilityID
                              OR @SentByFacilityID IS NULL
                          )
                      AND (
                              idfsFinalCaseStatus = @ClassificationTypeID
                              OR @ClassificationTypeID IS NULL
                          )
                      AND (
                              idfsYNHospitalization = @HospitalizationYNID
                              OR @HospitalizationYNID IS NULL
                          )
                      AND (
                              gExposure.Level1ID = @LocationOfExposureAdministrativeLevelID
                              OR gExposure.Level2ID = @LocationOfExposureAdministrativeLevelID
                              OR gExposure.Level3ID = @LocationOfExposureAdministrativeLevelID
                              OR gExposure.Level4ID = @LocationOfExposureAdministrativeLevelID
                              OR gExposure.Level5ID = @LocationOfExposureAdministrativeLevelID
                              OR gExposure.Level6ID = @LocationOfExposureAdministrativeLevelID
                              OR gExposure.Level7ID = @LocationOfExposureAdministrativeLevelID
                              OR @LocationOfExposureAdministrativeLevelID IS NULL
                          )
                      AND (
                              (ISNULL(h.strFirstName, '') = CASE ISNULL(@PatientFirstName, '')
                                                                WHEN '' THEN
                                                                    ISNULL(h.strFirstName, '')
                                                                ELSE
                                                                    @PatientFirstName
                                                            END
                              )
                              OR (CHARINDEX(@PatientFirstName, ISNULL(h.strFirstName, '')) > 0)
                          )
                      AND (
                              (ISNULL(h.strSecondName, '') = CASE ISNULL(@PatientMiddleName, '')
                                                                 WHEN '' THEN
                                                                     ISNULL(h.strSecondName, '')
                                                                 ELSE
                                                                     @PatientMiddleName
                                                             END
                              )
                              OR (CHARINDEX(@PatientMiddleName, ISNULL(h.strSecondName, '')) > 0)
                          )
                      AND (
                              (ISNULL(h.strLastName, '') = CASE ISNULL(@PatientLastName, '')
                                                               WHEN '' THEN
                                                                   ISNULL(h.strLastName, '')
                                                               ELSE
                                                                   @PatientLastName
                                                           END
                              )
                              OR (CHARINDEX(@PatientLastName, ISNULL(h.strLastName, '')) > 0)
                          )
                      AND (
                              hc.idfsSite = @DataEntrySiteID
                              OR @DataEntrySiteID IS NULL
                          )
                      AND (
                              (
                                  hc.idfOutbreak IS NULL
                                  AND @OutbreakCasesIndicator = 0
                              )
                              OR (
                                     hc.idfOutbreak IS NOT NULL
                                     AND @OutbreakCasesIndicator = 1
                                 )
                              OR (
                                  @OutbreakCasesIndicator IS NULL 
                                  AND 
                                  (
                                      hc.idfOutbreak IS NULL 
                                      OR (hc.idfOutbreak IS NOT NULL AND hc.strCaseID IS NOT NULL)
                                  )
                              )
                          )
                      AND (
                              hc.strCaseID LIKE '%' + TRIM(@ReportID) + '%'
                              OR @ReportID IS NULL
                          )
                      AND (
                              hc.LegacyCaseID LIKE '%' + TRIM(@LegacyReportID) + '%'
                              OR @LegacyReportID IS NULL
                          )
                      AND (
                              m.strFieldBarcode LIKE '%' + TRIM(@LocalOrFieldSampleID) + '%'
                              OR @LocalOrFieldSampleID IS NULL
                          )
                      AND (
                              hc.idfsOutcome = @OutcomeID
                              OR @OutcomeID IS NULL
                          )
                GROUP BY hc.idfHumanCase;
            END
        END
        ELSE
        BEGIN -- Configurable Filtration Rules
            DECLARE @InitialFilteredResults TABLE
            (
                ID BIGINT NOT NULL,
                ReadPermissionIndicator INT NOT NULL,
                AccessToPersonalDataPermissionIndicator INT NOT NULL,
                AccessToGenderAndAgeDataPermissionIndicator INT NOT NULL,
                WritePermissionIndicator INT NOT NULL,
                DeletePermissionIndicator INT NOT NULL, INDEX IDX_ID (ID
                                                                     ));

            INSERT INTO @InitialFilteredResults
            SELECT idfHumanCase,
                   1,
                   1,
                   1,
                   1,
                   1
            FROM dbo.tlbHumanCase
            WHERE intRowStatus = 0
                  AND idfsSite = @UserSiteID;

            IF @RecordIdentifierSearchIndicator = 1
            BEGIN
                INSERT INTO @Results
                SELECT idfHumanCase,
                       1,
                       1,
                       1,
                       1,
                       1
                FROM @InitialFilteredResults res
                    INNER JOIN dbo.tlbHumanCase hc
                        ON hc.idfHumanCase = res.ID
                WHERE intRowStatus = 0
                      AND idfsFinalDiagnosis IS NOT NULL
                      AND (
                              strCaseID LIKE '%' + TRIM(@ReportID) + '%'
                              OR @ReportID IS NULL
                          )
                      AND (
                              LegacyCaseID LIKE '%' + TRIM(@LegacyReportID) + '%'
                              OR @LegacyReportID IS NULL
                          )
            END
            ELSE
            BEGIN
                INSERT INTO @Results
                SELECT hc.idfHumanCase,
                       1,
                       1,
                       1,
                       1,
                       1
                FROM @InitialFilteredResults res
                    INNER JOIN dbo.tlbHumanCase hc
                        ON hc.idfHumanCase = res.ID
                    INNER JOIN dbo.tlbHuman h
                        ON h.idfHuman = hc.idfHuman
                           AND h.intRowStatus = 0
                    INNER JOIN dbo.tlbGeoLocation currentAddress
                        ON currentAddress.idfGeoLocation = h.idfCurrentResidenceAddress
                    LEFT JOIN dbo.gisLocationDenormalized g
                        ON g.idfsLocation = currentAddress.idfsLocation
                           AND g.idfsLanguage = @LanguageCode
                    LEFT JOIN dbo.tlbMaterial m
                        ON m.idfHumanCase = hc.idfHumanCase
                           AND m.intRowStatus = 0
                    LEFT JOIN dbo.tlbGeoLocation exposure
                        ON exposure.idfGeoLocation = hc.idfPointGeoLocation
                    LEFT JOIN dbo.gisLocationDenormalized gExposure
                        ON gExposure.idfsLocation = exposure.idfsLocation
                           AND gExposure.idfsLanguage = @LanguageCode
                WHERE hc.idfsFinalDiagnosis IS NOT NULL
                      AND (
                              hc.idfHumanCase = @ReportKey
                              OR @ReportKey IS NULL
                          )
                      AND (
                              hc.idfParentMonitoringSession = @SessionKey
                              OR @SessionKey IS NULL
                          )
                      AND (
                              h.idfHumanActual = @PatientID
                              OR @PatientID IS NULL
                          )
                      AND (
                              h.strPersonId = @PersonID
                              OR @PersonID IS NULL
                          )
                      AND (
                              idfsFinalDiagnosis = @DiseaseID
                              OR @DiseaseID IS NULL
                          )
                      AND (
                              idfsCaseProgressStatus = @ReportStatusTypeID
                              OR @ReportStatusTypeID IS NULL
                          )
                      AND (
                              g.Level1ID = @AdministrativeLevelID
                              OR g.Level2ID = @AdministrativeLevelID
                              OR g.Level3ID = @AdministrativeLevelID
                              OR g.Level4ID = @AdministrativeLevelID
                              OR g.Level5ID = @AdministrativeLevelID
                              OR g.Level6ID = @AdministrativeLevelID
                              OR g.Level7ID = @AdministrativeLevelID
                              OR @AdministrativeLevelID IS NULL
                          )
                      AND (
                              hc.datEnteredDate >= @DateEnteredFrom
                              OR @DateEnteredFrom IS NULL
                          )
                      AND (
                              (CONVERT(DATE, hc.datEnteredDate, 102) <= @DateEnteredTo)
                              OR @DateEnteredTo IS NULL
                          )
                      AND (
                              (CAST(hc.datFinalDiagnosisDate AS DATE)
                      BETWEEN @DiagnosisDateFrom AND @DiagnosisDateTo
                              )
                              OR (
                                     @DiagnosisDateFrom IS NULL
                                     OR @DiagnosisDateTo IS NULL
                                 )
                          )
                      AND (
                              (CAST(hc.datNotificationDate AS DATE)
                      BETWEEN @NotificationDateFrom AND @NotificationDateTo
                              )
                              OR (
                                     @NotificationDateFrom IS NULL
                                     OR @NotificationDateTo IS NULL
                                 )
                          )
                      AND (
                              (CAST(hc.datOnSetDate AS DATE)
                      BETWEEN @DateOfSymptomsOnsetFrom AND @DateOfSymptomsOnsetTo
                              )
                              OR (
                                     @DateOfSymptomsOnsetFrom IS NULL
                                     OR @DateOfSymptomsOnsetTo IS NULL
                                 )
                          )
                      AND (
                              (CAST(hc.datFinalCaseClassificationDate AS DATE)
                      BETWEEN @DateOfFinalCaseClassificationFrom AND @DateOfFinalCaseClassificationTo
                              )
                              OR (
                                     @DateOfFinalCaseClassificationFrom IS NULL
                                     OR @DateOfFinalCaseClassificationTo IS NULL
                                 )
                          )
                      AND (
                              hc.idfReceivedByOffice = @ReceivedByFacilityID
                              OR @ReceivedByFacilityID IS NULL
                          )
                      AND (
                              hc.idfSentByOffice = @SentByFacilityID
                              OR @SentByFacilityID IS NULL
                          )
                      AND (
                              idfsFinalCaseStatus = @ClassificationTypeID
                              OR @ClassificationTypeID IS NULL
                          )
                      AND (
                              idfsYNHospitalization = @HospitalizationYNID
                              OR @HospitalizationYNID IS NULL
                          )
                      AND (
                              gExposure.Level1ID = @LocationOfExposureAdministrativeLevelID
                              OR gExposure.Level2ID = @LocationOfExposureAdministrativeLevelID
                              OR gExposure.Level3ID = @LocationOfExposureAdministrativeLevelID
                              OR gExposure.Level4ID = @LocationOfExposureAdministrativeLevelID
                              OR gExposure.Level5ID = @LocationOfExposureAdministrativeLevelID
                              OR gExposure.Level6ID = @LocationOfExposureAdministrativeLevelID
                              OR gExposure.Level7ID = @LocationOfExposureAdministrativeLevelID
                              OR @LocationOfExposureAdministrativeLevelID IS NULL
                          )
                      AND (
                              (ISNULL(h.strFirstName, '') = CASE ISNULL(@PatientFirstName, '')
                                                                WHEN '' THEN
                                                                    ISNULL(h.strFirstName, '')
                                                                ELSE
                                                                    @PatientFirstName
                                                            END
                              )
                              OR (CHARINDEX(@PatientFirstName, ISNULL(h.strFirstName, '')) > 0)
                          )
                      AND (
                              (ISNULL(h.strSecondName, '') = CASE ISNULL(@PatientMiddleName, '')
                                                                 WHEN '' THEN
                                                                     ISNULL(h.strSecondName, '')
                                                                 ELSE
                                                                     @PatientMiddleName
                                                             END
                              )
                              OR (CHARINDEX(@PatientMiddleName, ISNULL(h.strSecondName, '')) > 0)
                          )
                      AND (
                              (ISNULL(h.strLastName, '') = CASE ISNULL(@PatientLastName, '')
                                                               WHEN '' THEN
                                                                   ISNULL(h.strLastName, '')
                                                               ELSE
                                                                   @PatientLastName
                                                           END
                              )
                              OR (CHARINDEX(@PatientLastName, ISNULL(h.strLastName, '')) > 0)
                          )
                      AND (
                              hc.idfsSite = @DataEntrySiteID
                              OR @DataEntrySiteID IS NULL
                          )
                      AND (
                              (
                                  hc.idfOutbreak IS NULL
                                  AND @OutbreakCasesIndicator = 0
                              )
                              OR (
                                     hc.idfOutbreak IS NOT NULL
                                     AND @OutbreakCasesIndicator = 1
                                 )
                              OR (@OutbreakCasesIndicator IS NULL)
                          )
                      AND (
                              hc.strCaseID LIKE '%' + TRIM(@ReportID) + '%'
                              OR @ReportID IS NULL
                          )
                      AND (
                              hc.LegacyCaseID LIKE '%' + TRIM(@LegacyReportID) + '%'
                              OR @LegacyReportID IS NULL
                          )
                      AND (
                              m.strFieldBarcode LIKE '%' + TRIM(@LocalOrFieldSampleID) + '%'
                              OR @LocalOrFieldSampleID IS NULL
                          )
                      AND (
                              hc.idfsOutcome = @OutcomeID
                              OR @OutcomeID IS NULL
                          )
                GROUP BY hc.idfHumanCase;
            END

            DECLARE @FilteredResults TABLE
            (
                ID BIGINT NOT NULL,
                ReadPermissionIndicator INT NOT NULL,
                AccessToPersonalDataPermissionIndicator INT NOT NULL,
                AccessToGenderAndAgeDataPermissionIndicator INT NOT NULL,
                WritePermissionIndicator INT NOT NULL,
                DeletePermissionIndicator INT NOT NULL, INDEX IDX_ID (ID
                                                                     ));

            -- =======================================================================================
            -- DEFAULT CONFIGURABLE FILTRATION RULES
            --
            -- Apply active default filtration rules for third level sites.
            -- =======================================================================================
            DECLARE @RuleActiveStatus INT = 0;
            DECLARE @AdministrativeLevelTypeID INT;
            DECLARE @DefaultAccessRules AS TABLE
            (
                AccessRuleID BIGINT NOT NULL,
                ActiveIndicator INT NOT NULL,
                ReadPermissionIndicator INT NOT NULL,
                AccessToPersonalDataPermissionIndicator INT NOT NULL,
                AccessToGenderAndAgeDataPermissionIndicator INT NOT NULL,
                WritePermissionIndicator INT NOT NULL,
                DeletePermissionIndicator INT NOT NULL,
                AdministrativeLevelTypeID INT NULL
            );

            INSERT INTO @DefaultAccessRules
            SELECT AccessRuleID,
                   a.intRowStatus,
                   a.ReadPermissionIndicator,
                   a.AccessToPersonalDataPermissionIndicator,
                   a.AccessToGenderAndAgeDataPermissionIndicator,
                   a.WritePermissionIndicator,
                   a.DeletePermissionIndicator,
                   a.AdministrativeLevelTypeID
            FROM dbo.AccessRule a
            WHERE DefaultRuleIndicator = 1;

            SELECT @RuleActiveStatus = ActiveIndicator
            FROM @DefaultAccessRules
            WHERE AccessRuleID = 10537000;

            IF @RuleActiveStatus = 0
            BEGIN
                SELECT @AdministrativeLevelTypeID = AdministrativeLevelTypeID
                FROM @DefaultAccessRules
                WHERE AccessRuleID = 10537000;

                SELECT @FiltrationSiteAdministrativeLevelID = CASE
                                                                  WHEN @AdministrativeLevelTypeID = 1 THEN
                                                                      g.Level1ID
                                                                  WHEN @AdministrativeLevelTypeID = 2 THEN
                                                                      g.Level2ID
                                                                  WHEN @AdministrativeLevelTypeID = 3 THEN
                                                                      g.Level3ID
                                                                  WHEN @AdministrativeLevelTypeID = 4 THEN
                                                                      g.Level4ID
                                                                  WHEN @AdministrativeLevelTypeID = 5 THEN
                                                                      g.Level5ID
                                                                  WHEN @AdministrativeLevelTypeID = 6 THEN
                                                                      g.Level6ID
                                                                  WHEN @AdministrativeLevelTypeID = 7 THEN
                                                                      g.Level7ID
                                                              END
                FROM dbo.tlbOffice o
                    INNER JOIN dbo.tlbGeoLocationShared l
                        ON l.idfGeoLocationShared = o.idfLocation
                           AND l.intRowStatus = 0
                    INNER JOIN dbo.gisLocationDenormalized g
                        ON g.idfsLocation = l.idfsLocation
                           AND g.idfsLanguage = @LanguageCode
                WHERE o.intRowStatus = 0
                      AND o.idfOffice = @UserOrganizationID;

                -- Administrative level specified in the rule of the site where the report was created.
                INSERT INTO @FilteredResults
                SELECT h.idfHumanCase,
                       a.ReadPermissionIndicator,
                       a.AccessToPersonalDataPermissionIndicator,
                       a.AccessToGenderAndAgeDataPermissionIndicator,
                       a.WritePermissionIndicator,
                       a.DeletePermissionIndicator
                FROM dbo.tlbHumanCase h
                    INNER JOIN dbo.tstSite s
                        ON h.idfsSite = s.idfsSite
                    INNER JOIN dbo.tlbOffice o
                        ON o.idfOffice = s.idfOffice
                           AND o.intRowStatus = 0
                    INNER JOIN dbo.tlbGeoLocationShared l
                        ON l.idfGeoLocationShared = o.idfLocation
                           AND l.intRowStatus = 0
                    INNER JOIN dbo.gisLocationDenormalized g
                        ON g.idfsLocation = l.idfsLocation
                           AND g.idfsLanguage = @LanguageCode
                    INNER JOIN @DefaultAccessRules a
                        ON a.AccessRuleID = 10537000
                WHERE h.intRowStatus = 0
                      AND (
                              g.Level1ID = @FiltrationSiteAdministrativeLevelID
                              AND @AdministrativeLevelTypeID = 1
                              OR g.Level2ID = @FiltrationSiteAdministrativeLevelID
                                 AND @AdministrativeLevelTypeID = 2
                              OR g.Level3ID = @FiltrationSiteAdministrativeLevelID
                                 AND @AdministrativeLevelTypeID = 3
                              OR g.Level4ID = @FiltrationSiteAdministrativeLevelID
                                 AND @AdministrativeLevelTypeID = 4
                              OR g.Level5ID = @FiltrationSiteAdministrativeLevelID
                                 AND @AdministrativeLevelTypeID = 5
                              OR g.Level6ID = @FiltrationSiteAdministrativeLevelID
                                 AND @AdministrativeLevelTypeID = 6
                              OR g.Level7ID = @FiltrationSiteAdministrativeLevelID
                                 AND @AdministrativeLevelTypeID = 7
                          )

                -- Administrative level specified in the rule of the report current residence address.
                INSERT INTO @FilteredResults
                SELECT h.idfHumanCase,
                       a.ReadPermissionIndicator,
                       a.AccessToPersonalDataPermissionIndicator,
                       a.AccessToGenderAndAgeDataPermissionIndicator,
                       a.WritePermissionIndicator,
                       a.DeletePermissionIndicator
                FROM dbo.tlbHumanCase h
                    INNER JOIN dbo.tlbHuman hu
                        ON hu.idfHuman = h.idfHuman
                           AND hu.intRowStatus = 0
                    INNER JOIN dbo.tlbGeoLocation l
                        ON l.idfGeoLocation = hu.idfCurrentResidenceAddress
                           AND l.intRowStatus = 0
                    INNER JOIN dbo.gisLocationDenormalized g
                        ON g.idfsLocation = l.idfsLocation
                           AND g.idfsLanguage = @LanguageCode
                    INNER JOIN @DefaultAccessRules a
                        ON a.AccessRuleID = 10537000
                WHERE h.intRowStatus = 0
                      AND (
                              g.Level1ID = @FiltrationSiteAdministrativeLevelID
                              AND @AdministrativeLevelTypeID = 1
                              OR g.Level2ID = @FiltrationSiteAdministrativeLevelID
                                 AND @AdministrativeLevelTypeID = 2
                              OR g.Level3ID = @FiltrationSiteAdministrativeLevelID
                                 AND @AdministrativeLevelTypeID = 3
                              OR g.Level4ID = @FiltrationSiteAdministrativeLevelID
                                 AND @AdministrativeLevelTypeID = 4
                              OR g.Level5ID = @FiltrationSiteAdministrativeLevelID
                                 AND @AdministrativeLevelTypeID = 5
                              OR g.Level6ID = @FiltrationSiteAdministrativeLevelID
                                 AND @AdministrativeLevelTypeID = 6
                              OR g.Level7ID = @FiltrationSiteAdministrativeLevelID
                                 AND @AdministrativeLevelTypeID = 7
                          )

                -- Administrative level specified in the rule of the report location of exposure, 
                -- if corresponding field was filled in.
                INSERT INTO @FilteredResults
                SELECT h.idfHumanCase,
                       a.ReadPermissionIndicator,
                       a.AccessToPersonalDataPermissionIndicator,
                       a.AccessToGenderAndAgeDataPermissionIndicator,
                       a.WritePermissionIndicator,
                       a.DeletePermissionIndicator
                FROM dbo.tlbHumanCase h
                    INNER JOIN dbo.tlbGeoLocation l
                        ON l.idfGeoLocation = h.idfPointGeoLocation
                           AND l.intRowStatus = 0
                    INNER JOIN dbo.gisLocationDenormalized g
                        ON g.idfsLocation = l.idfsLocation
                           AND g.idfsLanguage = @LanguageCode
                    INNER JOIN @DefaultAccessRules a
                        ON a.AccessRuleID = 10537000
                WHERE h.intRowStatus = 0
                      AND (
                              g.Level1ID = @FiltrationSiteAdministrativeLevelID
                              AND @AdministrativeLevelTypeID = 1
                              OR g.Level2ID = @FiltrationSiteAdministrativeLevelID
                                 AND @AdministrativeLevelTypeID = 2
                              OR g.Level3ID = @FiltrationSiteAdministrativeLevelID
                                 AND @AdministrativeLevelTypeID = 3
                              OR g.Level4ID = @FiltrationSiteAdministrativeLevelID
                                 AND @AdministrativeLevelTypeID = 4
                              OR g.Level5ID = @FiltrationSiteAdministrativeLevelID
                                 AND @AdministrativeLevelTypeID = 5
                              OR g.Level6ID = @FiltrationSiteAdministrativeLevelID
                                 AND @AdministrativeLevelTypeID = 6
                              OR g.Level7ID = @FiltrationSiteAdministrativeLevelID
                                 AND @AdministrativeLevelTypeID = 7
                          )
            END;

            -- Report data shall be available to all sites' organizations connected to the particular report.
            -- Notification sent by, notification received by, facility where the patient first sought 
            -- care, hospital, and the conducting investigation organizations.
            SELECT @RuleActiveStatus = intRowStatus
            FROM dbo.AccessRule
            WHERE AccessRuleID = 10537001;

            IF @RuleActiveStatus = 0
            BEGIN
                INSERT INTO @FilteredResults
                SELECT h.idfHumanCase,
                       a.ReadPermissionIndicator,
                       a.AccessToPersonalDataPermissionIndicator,
                       a.AccessToGenderAndAgeDataPermissionIndicator,
                       a.WritePermissionIndicator,
                       a.DeletePermissionIndicator
                FROM dbo.tlbHumanCase h
                    INNER JOIN @DefaultAccessRules a
                        ON a.AccessRuleID = 10537001
                WHERE h.intRowStatus = 0
                      AND (
                              h.idfSentByOffice = @UserOrganizationID
                              OR h.idfReceivedByOffice = @UserOrganizationID
                              OR h.idfSoughtCareFacility = @UserOrganizationID
                              OR h.idfHospital = @UserOrganizationID
                              OR h.idfInvestigatedByOffice = @UserOrganizationID
                          )
                ORDER BY h.idfHumanCase;

                -- Sample collected by and sent to organizations
                INSERT INTO @FilteredResults
                SELECT MAX(m.idfHumanCase),
                       a.ReadPermissionIndicator,
                       a.AccessToPersonalDataPermissionIndicator,
                       a.AccessToGenderAndAgeDataPermissionIndicator,
                       a.WritePermissionIndicator,
                       a.DeletePermissionIndicator
                FROM dbo.tlbMaterial m
                    INNER JOIN dbo.tlbHumanCase h
                        ON h.idfHumanCase = m.idfHumanCase
                           AND h.intRowStatus = 0
                    INNER JOIN @DefaultAccessRules a
                        ON a.AccessRuleID = 10537001
                WHERE m.intRowStatus = 0
                      AND (
                              m.idfFieldCollectedByOffice = @UserOrganizationID
                              OR m.idfSendToOffice = @UserOrganizationID
                          )
                GROUP BY m.idfHumanCase,
                         a.ReadPermissionIndicator,
                         a.AccessToPersonalDataPermissionIndicator,
                         a.AccessToGenderAndAgeDataPermissionIndicator,
                         a.WritePermissionIndicator,
                         a.DeletePermissionIndicator;

                -- Sample transferred to organizations
                INSERT INTO @FilteredResults
                SELECT MAX(m.idfHumanCase),
                       a.ReadPermissionIndicator,
                       a.AccessToPersonalDataPermissionIndicator,
                       a.AccessToGenderAndAgeDataPermissionIndicator,
                       a.WritePermissionIndicator,
                       a.DeletePermissionIndicator
                FROM dbo.tlbMaterial m
                    INNER JOIN dbo.tlbHumanCase h
                        ON h.idfHumanCase = m.idfHumanCase
                           AND h.intRowStatus = 0
                    INNER JOIN dbo.tlbTransferOutMaterial tom
                        ON m.idfMaterial = tom.idfMaterial
                           AND tom.intRowStatus = 0
                    INNER JOIN dbo.tlbTransferOUT t
                        ON tom.idfTransferOut = t.idfTransferOut
                           AND t.intRowStatus = 0
                    INNER JOIN @DefaultAccessRules a
                        ON a.AccessRuleID = 10537001
                WHERE m.intRowStatus = 0
                      AND t.idfSendToOffice = @UserOrganizationID
                GROUP BY m.idfHumanCase,
                         a.ReadPermissionIndicator,
                         a.AccessToPersonalDataPermissionIndicator,
                         a.AccessToGenderAndAgeDataPermissionIndicator,
                         a.WritePermissionIndicator,
                         a.DeletePermissionIndicator;
            END;

            --
            -- Report data shall be available to the sites with the connected outbreak, if the report 
            -- is the primary report/session for an outbreak.
            --
            SELECT @RuleActiveStatus = intRowStatus
            FROM dbo.AccessRule
            WHERE AccessRuleID = 10537002;

            IF @RuleActiveStatus = 0
            BEGIN
                INSERT INTO @FilteredResults
                SELECT h.idfHumanCase,
                       a.ReadPermissionIndicator,
                       a.AccessToPersonalDataPermissionIndicator,
                       a.AccessToGenderAndAgeDataPermissionIndicator,
                       a.WritePermissionIndicator,
                       a.DeletePermissionIndicator
                FROM dbo.tlbHumanCase h
                    INNER JOIN dbo.tlbOutbreak o
                        ON h.idfHumanCase = o.idfPrimaryCaseOrSession
                           AND o.intRowStatus = 0
                    INNER JOIN @DefaultAccessRules a
                        ON a.AccessRuleID = 10537002
                WHERE h.intRowStatus = 0
                      AND o.idfsSite = @UserSiteID;
            END;

            -- =======================================================================================
            -- CONFIGURABLE FILTRATION RULES
            -- 
            -- Apply configurable filtration rules for use case SAUC34. Some of these rules may 
            -- overlap the default rules.
            -- =======================================================================================
            --
            -- Apply at the user's site group level, granted by a site group.
            --
            INSERT INTO @FilteredResults
            SELECT h.idfHumanCase,
                   a.ReadPermissionIndicator,
                   a.AccessToPersonalDataPermissionIndicator,
                   a.AccessToGenderAndAgeDataPermissionIndicator,
                   a.WritePermissionIndicator,
                   a.DeletePermissionIndicator
            FROM dbo.tlbHumanCase h
                INNER JOIN dbo.tflSiteToSiteGroup grantingSGS
                    ON grantingSGS.idfsSite = h.idfsSite
                INNER JOIN dbo.tflSiteToSiteGroup userSiteGroup
                    ON userSiteGroup.idfsSite = @UserSiteID
                INNER JOIN dbo.AccessRuleActor ara
                    ON ara.ActorSiteGroupID = userSiteGroup.idfSiteGroup
                       AND ara.intRowStatus = 0
                INNER JOIN dbo.AccessRule a
                    ON a.AccessRuleID = ara.AccessRuleID
                       AND a.intRowStatus = 0
                       AND a.DefaultRuleIndicator = 0
            WHERE h.intRowStatus = 0
                  AND a.GrantingActorSiteGroupID = grantingSGS.idfSiteGroup;

            --
            -- Apply at the user's site level, granted by a site group.
            --
            INSERT INTO @FilteredResults
            SELECT h.idfHumanCase,
                   a.ReadPermissionIndicator,
                   a.AccessToPersonalDataPermissionIndicator,
                   a.AccessToGenderAndAgeDataPermissionIndicator,
                   a.WritePermissionIndicator,
                   a.DeletePermissionIndicator
            FROM dbo.tlbHumanCase h
                INNER JOIN dbo.tflSiteToSiteGroup grantingSGS
                    ON grantingSGS.idfsSite = h.idfsSite
                INNER JOIN dbo.AccessRuleActor ara
                    ON ara.ActorSiteID = @UserSiteID
                       AND ara.ActorEmployeeGroupID IS NULL
                       AND ara.intRowStatus = 0
                INNER JOIN dbo.AccessRule a
                    ON a.AccessRuleID = ara.AccessRuleID
                       AND a.intRowStatus = 0
                       AND a.DefaultRuleIndicator = 0
            WHERE h.intRowStatus = 0
                  AND a.GrantingActorSiteGroupID = grantingSGS.idfSiteGroup;

            -- 
            -- Apply at the user's employee group level, granted by a site group.
            --
            INSERT INTO @FilteredResults
            SELECT h.idfHumanCase,
                   a.ReadPermissionIndicator,
                   a.AccessToPersonalDataPermissionIndicator,
                   a.AccessToGenderAndAgeDataPermissionIndicator,
                   a.WritePermissionIndicator,
                   a.DeletePermissionIndicator
            FROM dbo.tlbHumanCase h
                INNER JOIN dbo.tflSiteToSiteGroup grantingSGS
                    ON grantingSGS.idfsSite = h.idfsSite
                INNER JOIN dbo.tlbEmployeeGroupMember egm
                    ON egm.idfEmployee = @UserEmployeeID
                       AND egm.intRowStatus = 0
                INNER JOIN dbo.AccessRuleActor ara
                    ON ara.ActorEmployeeGroupID = egm.idfEmployeeGroup
                       AND ara.intRowStatus = 0
                INNER JOIN dbo.AccessRule a
                    ON a.AccessRuleID = ara.AccessRuleID
                       AND a.intRowStatus = 0
                       AND a.DefaultRuleIndicator = 0
            WHERE h.intRowStatus = 0
                  AND a.GrantingActorSiteGroupID = grantingSGS.idfSiteGroup;

            -- 
            -- Apply at the user's ID level, granted by a site group.
            --
            INSERT INTO @FilteredResults
            SELECT h.idfHumanCase,
                   a.ReadPermissionIndicator,
                   a.AccessToPersonalDataPermissionIndicator,
                   a.AccessToGenderAndAgeDataPermissionIndicator,
                   a.WritePermissionIndicator,
                   a.DeletePermissionIndicator
            FROM dbo.tlbHumanCase h
                INNER JOIN dbo.tflSiteToSiteGroup grantingSGS
                    ON grantingSGS.idfsSite = h.idfsSite
                INNER JOIN dbo.tstUserTable u
                    ON u.idfPerson = @UserEmployeeID
                       AND u.intRowStatus = 0
                INNER JOIN dbo.AccessRuleActor ara
                    ON ara.ActorUserID = u.idfUserID
                       AND ara.intRowStatus = 0
                INNER JOIN dbo.AccessRule a
                    ON a.AccessRuleID = ara.AccessRuleID
                       AND a.intRowStatus = 0
                       AND a.DefaultRuleIndicator = 0
            WHERE h.intRowStatus = 0
                  AND a.GrantingActorSiteGroupID = grantingSGS.idfSiteGroup;

            --
            -- Apply at the user's site group level, granted by a site.
            --
            INSERT INTO @FilteredResults
            SELECT h.idfHumanCase,
                   a.ReadPermissionIndicator,
                   a.AccessToPersonalDataPermissionIndicator,
                   a.AccessToGenderAndAgeDataPermissionIndicator,
                   a.WritePermissionIndicator,
                   a.DeletePermissionIndicator
            FROM dbo.tlbHumanCase h
                INNER JOIN dbo.tflSiteToSiteGroup sgs
                    ON sgs.idfsSite = @UserSiteID
                INNER JOIN dbo.AccessRuleActor ara
                    ON ara.ActorSiteGroupID = sgs.idfSiteGroup
                       AND ara.intRowStatus = 0
                INNER JOIN dbo.AccessRule a
                    ON a.AccessRuleID = ara.AccessRuleID
                       AND a.intRowStatus = 0
                       AND a.DefaultRuleIndicator = 0
            WHERE h.intRowStatus = 0
                  AND sgs.idfsSite = h.idfsSite;

            -- 
            -- Apply at the user's site level, granted by a site.
            --
            INSERT INTO @FilteredResults
            SELECT h.idfHumanCase,
                   a.ReadPermissionIndicator,
                   a.AccessToPersonalDataPermissionIndicator,
                   a.AccessToGenderAndAgeDataPermissionIndicator,
                   a.WritePermissionIndicator,
                   a.DeletePermissionIndicator
            FROM dbo.tlbHumanCase h
                INNER JOIN dbo.AccessRuleActor ara
                    ON ara.ActorSiteID = @UserSiteID
                       AND ara.ActorEmployeeGroupID IS NULL
                       AND ara.intRowStatus = 0
                INNER JOIN dbo.AccessRule a
                    ON a.AccessRuleID = ara.AccessRuleID
                       AND a.intRowStatus = 0
                       AND a.DefaultRuleIndicator = 0
            WHERE h.intRowStatus = 0
                  AND a.GrantingActorSiteID = h.idfsSite;

            -- 
            -- Apply at the user's employee group level, granted by a site.
            --
            INSERT INTO @FilteredResults
            SELECT h.idfHumanCase,
                   a.ReadPermissionIndicator,
                   a.AccessToPersonalDataPermissionIndicator,
                   a.AccessToGenderAndAgeDataPermissionIndicator,
                   a.WritePermissionIndicator,
                   a.DeletePermissionIndicator
            FROM dbo.tlbHumanCase h
                INNER JOIN dbo.tlbEmployeeGroupMember egm
                    ON egm.idfEmployee = @UserEmployeeID
                       AND egm.intRowStatus = 0
                INNER JOIN dbo.AccessRuleActor ara
                    ON ara.ActorEmployeeGroupID = egm.idfEmployeeGroup
                       AND ara.intRowStatus = 0
                INNER JOIN dbo.AccessRule a
                    ON a.AccessRuleID = ara.AccessRuleID
                       AND a.intRowStatus = 0
                       AND a.DefaultRuleIndicator = 0
            WHERE h.intRowStatus = 0
                  AND a.GrantingActorSiteID = h.idfsSite;

            -- 
            -- Apply at the user's ID level, granted by a site.
            ----
            INSERT INTO @FilteredResults
            SELECT h.idfHumanCase,
                   a.ReadPermissionIndicator,
                   a.AccessToPersonalDataPermissionIndicator,
                   a.AccessToGenderAndAgeDataPermissionIndicator,
                   a.WritePermissionIndicator,
                   a.DeletePermissionIndicator
            FROM dbo.tlbHumanCase h
                INNER JOIN dbo.tstUserTable u
                    ON u.idfPerson = @UserEmployeeID
                       AND u.intRowStatus = 0
                INNER JOIN dbo.AccessRuleActor ara
                    ON ara.ActorUserID = u.idfUserID
                       AND ara.intRowStatus = 0
                INNER JOIN dbo.AccessRule a
                    ON a.AccessRuleID = ara.AccessRuleID
                       AND a.intRowStatus = 0
                       AND a.DefaultRuleIndicator = 0
            WHERE h.intRowStatus = 0
                  AND a.GrantingActorSiteID = h.idfsSite;

            -- Copy filtered results to results and use search criteria
            INSERT INTO @Results
            SELECT ID,
                   ReadPermissionIndicator,
                   AccessToPersonalDataPermissionIndicator,
                   AccessToGenderAndAgeDataPermissionIndicator,
                   WritePermissionIndicator,
                   DeletePermissionIndicator
            FROM @FilteredResults
                INNER JOIN dbo.tlbHumanCase hc
                    ON hc.idfHumanCase = ID
                INNER JOIN dbo.tlbHuman h
                    ON h.idfHuman = hc.idfHuman
                       AND h.intRowStatus = 0
                INNER JOIN dbo.tlbHumanActual ha
                    ON ha.idfHumanActual = h.idfHumanActual
                       AND ha.intRowStatus = 0
                INNER JOIN dbo.tlbGeoLocation currentAddress
                    ON currentAddress.idfGeoLocation = h.idfCurrentResidenceAddress
                LEFT JOIN dbo.gisLocationDenormalized g
                    ON g.idfsLocation = currentAddress.idfsLocation
                       AND g.idfsLanguage = @LanguageCode
                LEFT JOIN dbo.tlbMaterial m
                    ON m.idfHumanCase = hc.idfHumanCase
                       AND m.intRowStatus = 0
                LEFT JOIN dbo.tlbGeoLocation exposure
                    ON exposure.idfGeoLocation = hc.idfPointGeoLocation
                LEFT JOIN dbo.gisLocationDenormalized gExposure
                    ON gExposure.idfsLocation = exposure.idfsLocation
                       AND gExposure.idfsLanguage = @LanguageCode
            WHERE hc.intRowStatus = 0
                  AND hc.idfsFinalDiagnosis IS NOT NULL
                  AND (
                          hc.idfHumanCase = @ReportKey
                          OR @ReportKey IS NULL
                      )
                  AND (
                          hc.idfParentMonitoringSession = @SessionKey
                          OR @SessionKey IS NULL
                      )
                  AND (
                          ha.idfHumanActual = @PatientID
                          OR @PatientID IS NULL
                      )
                  AND (
                          h.strPersonId = @PersonID
                          OR @PersonID IS NULL
                      )
                  AND (
                          idfsFinalDiagnosis = @DiseaseID
                          OR @DiseaseID IS NULL
                      )
                  AND (
                          idfsCaseProgressStatus = @ReportStatusTypeID
                          OR @ReportStatusTypeID IS NULL
                      )
                  AND (
                          g.Level1ID = @AdministrativeLevelID
                          OR g.Level2ID = @AdministrativeLevelID
                          OR g.Level3ID = @AdministrativeLevelID
                          OR g.Level4ID = @AdministrativeLevelID
                          OR g.Level5ID = @AdministrativeLevelID
                          OR g.Level6ID = @AdministrativeLevelID
                          OR g.Level7ID = @AdministrativeLevelID
                          OR @AdministrativeLevelID IS NULL
                      )
                  AND (
                          hc.datEnteredDate >= @DateEnteredFrom
                          OR @DateEnteredFrom IS NULL
                      )
                  AND (
                          (CONVERT(DATE, hc.datEnteredDate, 102) <= @DateEnteredTo)
                          OR @DateEnteredTo IS NULL
                      )
                  AND (
                          (CAST(hc.datFinalDiagnosisDate AS DATE)
                  BETWEEN @DiagnosisDateFrom AND @DiagnosisDateTo
                          )
                          OR (
                                 @DiagnosisDateFrom IS NULL
                                 OR @DiagnosisDateTo IS NULL
                             )
                      )
                  AND (
                          (CAST(hc.datNotificationDate AS DATE)
                  BETWEEN @NotificationDateFrom AND @NotificationDateTo
                          )
                          OR (
                                 @NotificationDateFrom IS NULL
                                 OR @NotificationDateTo IS NULL
                             )
                      )
                  AND (
                          (CAST(hc.datOnSetDate AS DATE)
                  BETWEEN @DateOfSymptomsOnsetFrom AND @DateOfSymptomsOnsetTo
                          )
                          OR (
                                 @DateOfSymptomsOnsetFrom IS NULL
                                 OR @DateOfSymptomsOnsetTo IS NULL
                             )
                      )
                  AND (
                          (CAST(hc.datFinalCaseClassificationDate AS DATE)
                  BETWEEN @DateOfFinalCaseClassificationFrom AND @DateOfFinalCaseClassificationTo
                          )
                          OR (
                                 @DateOfFinalCaseClassificationFrom IS NULL
                                 OR @DateOfFinalCaseClassificationTo IS NULL
                             )
                      )
                  AND (
                          hc.idfReceivedByOffice = @ReceivedByFacilityID
                          OR @ReceivedByFacilityID IS NULL
                      )
                  AND (
                          hc.idfSentByOffice = @SentByFacilityID
                          OR @SentByFacilityID IS NULL
                      )
                  AND (
                          idfsFinalCaseStatus = @ClassificationTypeID
                          OR @ClassificationTypeID IS NULL
                      )
                  AND (
                          idfsYNHospitalization = @HospitalizationYNID
                          OR @HospitalizationYNID IS NULL
                      )
                  AND (
                          gExposure.Level1ID = @LocationOfExposureAdministrativeLevelID
                          OR gExposure.Level2ID = @LocationOfExposureAdministrativeLevelID
                          OR gExposure.Level3ID = @LocationOfExposureAdministrativeLevelID
                          OR gExposure.Level4ID = @LocationOfExposureAdministrativeLevelID
                          OR gExposure.Level5ID = @LocationOfExposureAdministrativeLevelID
                          OR gExposure.Level6ID = @LocationOfExposureAdministrativeLevelID
                          OR gExposure.Level7ID = @LocationOfExposureAdministrativeLevelID
                          OR @LocationOfExposureAdministrativeLevelID IS NULL
                      )
                  AND (
                          (ISNULL(h.strFirstName, '') = CASE ISNULL(@PatientFirstName, '')
                                                            WHEN '' THEN
                                                                ISNULL(h.strFirstName, '')
                                                            ELSE
                                                                @PatientFirstName
                                                        END
                          )
                          OR (CHARINDEX(@PatientFirstName, ISNULL(h.strFirstName, '')) > 0)
                      )
                  AND (
                          (ISNULL(h.strSecondName, '') = CASE ISNULL(@PatientMiddleName, '')
                                                             WHEN '' THEN
                                                                 ISNULL(h.strSecondName, '')
                                                             ELSE
                                                                 @PatientMiddleName
                                                         END
                          )
                          OR (CHARINDEX(@PatientMiddleName, ISNULL(h.strSecondName, '')) > 0)
                      )
                  AND (
                          (ISNULL(h.strLastName, '') = CASE ISNULL(@PatientLastName, '')
                                                           WHEN '' THEN
                                                               ISNULL(h.strLastName, '')
                                                           ELSE
                                                               @PatientLastName
                                                       END
                          )
                          OR (CHARINDEX(@PatientLastName, ISNULL(h.strLastName, '')) > 0)
                      )
                  AND (
                          hc.idfsSite = @DataEntrySiteID
                          OR @DataEntrySiteID IS NULL
                      )
                  AND (
                          (
                              hc.idfOutbreak IS NULL
                              AND @OutbreakCasesIndicator = 0
                          )
                          OR (
                                 hc.idfOutbreak IS NOT NULL 
                                 AND hc.strCaseID IS NOT NULL 
                                 AND @OutbreakCasesIndicator = 1
                             )
                          OR (
                              @OutbreakCasesIndicator IS NULL 
                              AND 
                              (
                                  hc.idfOutbreak IS NULL 
                                  OR (hc.idfOutbreak IS NOT NULL AND hc.strCaseID IS NOT NULL)
                              )
                          )
                      )
                  AND (
                          hc.strCaseID LIKE '%' + TRIM(@ReportID) + '%'
                          OR @ReportID IS NULL
                      )
                  AND (
                          hc.LegacyCaseID LIKE '%' + TRIM(@LegacyReportID) + '%'
                          OR @LegacyReportID IS NULL
                      )
                  AND (
                          m.strFieldBarcode LIKE '%' + TRIM(@LocalOrFieldSampleID) + '%'
                          OR @LocalOrFieldSampleID IS NULL
                      )
                  AND (
                          hc.idfsOutcome = @OutcomeID
                          OR @OutcomeID IS NULL
                      )
            GROUP BY ID,
                     ReadPermissionIndicator,
                     AccessToPersonalDataPermissionIndicator,
                     AccessToGenderAndAgeDataPermissionIndicator,
                     WritePermissionIndicator,
                     DeletePermissionIndicator;
        END;

        -- =======================================================================================
        -- Remove "Outbreak" tied disease reports, if filtering is needed
        -- =======================================================================================
        IF @FilterOutbreakTiedReports = 1
        BEGIN
            DELETE I
            FROM @Results I
                INNER JOIN dbo.tlbHumanCase hc
                    ON hc.idfHumanCase = I.ID
            WHERE hc.idfOutbreak IS NOT NULL;
        END;

        -- =======================================================================================
        -- DISEASE FILTRATION RULES
        --
        -- Apply disease filtration rules from use case SAUC62.
        -- =======================================================================================
        -- 
        -- Apply level 0 disease filtration rules for the employee default user group - Denies ONLY
        -- as all records have been pulled above with or without disease filtration rules applied.
        --
        DELETE FROM @Results
        WHERE EXISTS
        (
            SELECT hc.idfHumanCase
            FROM dbo.tlbHumanCase hc
                INNER JOIN dbo.tstObjectAccess oa
                    ON oa.idfsObjectID = hc.idfsFinalDiagnosis
                       AND oa.intRowStatus = 0
                INNER JOIN dbo.tlbEmployeeGroup eg
                    ON eg.idfsSite = @UserSiteID
                       AND eg.intRowStatus = 0
                INNER JOIN dbo.trtBaseReference br
                    ON br.idfsBaseReference = eg.idfEmployeeGroup
                       AND br.intRowStatus = 0
                       AND br.blnSystem = 1
            WHERE hc.intRowStatus = 0
                  AND oa.intPermission = 1 -- Deny permission
                  AND oa.idfsObjectType = 10060001 -- Disease
                  AND oa.idfActor = eg.idfEmployeeGroup
        );

        --
        -- Apply level 1 disease filtration rules for an employee's associated user group(s).  
        -- Allows and denies will supersede level 0.
        --
        INSERT INTO @Results
        SELECT hc.idfHumanCase,
               1,
               1,
               1,
               1,
               1
        FROM dbo.tlbHumanCase hc
            INNER JOIN dbo.tstObjectAccess oa
                ON oa.idfsObjectID = hc.idfsFinalDiagnosis
                   AND oa.intRowStatus = 0
            INNER JOIN dbo.tlbEmployeeGroupMember egm
                ON egm.idfEmployee = @UserEmployeeID
                   AND egm.intRowStatus = 0
        WHERE oa.intPermission = 2 -- Allow permission
              AND hc.intRowStatus = 0
              AND oa.idfsObjectType = 10060001 -- Disease
              AND oa.idfActor = egm.idfEmployeeGroup
              AND hc.idfsFinalDiagnosis IS NOT NULL
        GROUP BY hc.idfHumanCase;

        DELETE res
        FROM @Results res
            INNER JOIN dbo.tlbHumanCase hc
                ON hc.idfHumanCase = res.ID
            INNER JOIN dbo.tlbEmployeeGroupMember egm
                ON egm.idfEmployee = @UserEmployeeID
                   AND egm.intRowStatus = 0
            INNER JOIN dbo.tstObjectAccess oa
                ON oa.idfsObjectID = hc.idfsFinalDiagnosis
                   AND oa.intRowStatus = 0
        WHERE oa.intPermission = 1 -- Deny permission
              AND oa.idfsObjectType = 10060001 -- Disease
              AND oa.idfActor = egm.idfEmployeeGroup;

        --
        -- Apply level 2 disease filtration rules for the employee's identity.  Allows and denies 
        -- will supersede level 1.
        --
        INSERT INTO @Results
        SELECT hc.idfHumanCase,
               1,
               1,
               1,
               1,
               1
        FROM dbo.tlbHumanCase hc
            INNER JOIN dbo.tstObjectAccess oa
                ON oa.idfsObjectID = hc.idfsFinalDiagnosis
                   AND oa.intRowStatus = 0
        WHERE oa.intPermission = 2 -- Allow permission
              AND hc.intRowStatus = 0
              AND oa.idfsObjectType = 10060001 -- Disease
              AND oa.idfActor = @UserEmployeeID
              AND hc.idfsFinalDiagnosis IS NOT NULL
        GROUP BY hc.idfHumanCase;

        DELETE FROM @Results
        WHERE EXISTS
        (
            SELECT hc.idfHumanCase
            FROM dbo.tlbHumanCase hc
                INNER JOIN dbo.tstObjectAccess oa
                    ON oa.idfsObjectID = hc.idfsFinalDiagnosis
                       AND oa.intRowStatus = 0
            WHERE hc.intRowStatus = 0
                  AND oa.intPermission = 1 -- Deny permission
                  AND oa.idfsObjectType = 10060001 -- Disease
                  AND oa.idfActor = @UserEmployeeID
        );

        -- =======================================================================================
        -- SITE FILTRATION RULES
        --
        -- Apply site filtration rules from use case SAUC29.
        -- =======================================================================================
        -- 
        -- Apply level 0 site filtration rules for the employee default user group - Denies ONLY
        -- as all records have been pulled above with or without site filtration rules applied.
        --
        DELETE FROM @Results
        WHERE EXISTS
        (
            SELECT hc.idfHumanCase
            FROM dbo.tlbHumanCase hc
                INNER JOIN dbo.tstObjectAccess oa
                    ON oa.idfsObjectID = hc.idfsSite
                       AND oa.intRowStatus = 0
                INNER JOIN dbo.tlbEmployeeGroup eg
                    ON eg.idfsSite = @UserSiteID
                       AND eg.intRowStatus = 0
                INNER JOIN dbo.trtBaseReference br
                    ON br.idfsBaseReference = eg.idfEmployeeGroup
                       AND br.intRowStatus = 0
                       AND br.blnSystem = 1
            WHERE hc.intRowStatus = 0
                  AND oa.idfsObjectOperation = 10059003 -- Read permission
                  AND oa.intPermission = 1 -- Deny permission
                  AND oa.idfsObjectType = 10060011 -- Site
                  AND oa.idfActor = eg.idfEmployeeGroup
        );

        --
        -- Apply level 1 site filtration rules for an employee's associated user group(s).  
        -- Allows and denies will supersede level 0.
        --
        INSERT INTO @Results
        SELECT hc.idfHumanCase,
               (
                   SELECT Permission
                   FROM @UserGroupSitePermissions
                   WHERE SiteID = hc.idfsSite
                         AND PermissionTypeID = 10059003
               ),
               (
                   SELECT Permission
                   FROM @UserGroupSitePermissions
                   WHERE SiteID = hc.idfsSite
                         AND PermissionTypeID = 10059006
               ),
               (
                   SELECT Permission
                   FROM @UserGroupSitePermissions
                   WHERE SiteID = hc.idfsSite
                         AND PermissionTypeID = 10059007
               ),
               (
                   SELECT Permission
                   FROM @UserGroupSitePermissions
                   WHERE SiteID = hc.idfsSite
                         AND PermissionTypeID = 10059004
               ),
               (
                   SELECT Permission
                   FROM @UserGroupSitePermissions
                   WHERE SiteID = hc.idfsSite
                         AND PermissionTypeID = 10059002
               )
        FROM dbo.tlbHumanCase hc
        WHERE hc.intRowStatus = 0
              AND EXISTS
        (
            SELECT * FROM @UserGroupSitePermissions WHERE SiteID = hc.idfsSite
        );

        DELETE res
        FROM @Results res
            INNER JOIN dbo.tlbHumanCase hc
                ON hc.idfHumanCase = res.ID
            INNER JOIN @UserGroupSitePermissions ugsp
                ON ugsp.SiteID = hc.idfsSite
        WHERE ugsp.Permission = 2 -- Deny permission
              AND ugsp.PermissionTypeID = 10059003; -- Read permission

        --
        -- Apply level 2 site filtration rules for the employee's identity.  Allows and denies 
        -- will supersede level 1.
        --
        INSERT INTO @Results
        SELECT hc.idfHumanCase,
               (
                   SELECT Permission
                   FROM @UserSitePermissions
                   WHERE SiteID = hc.idfsSite
                         AND PermissionTypeID = 10059003
               ),
               (
                   SELECT Permission
                   FROM @UserSitePermissions
                   WHERE SiteID = hc.idfsSite
                         AND PermissionTypeID = 10059006
               ),
               (
                   SELECT Permission
                   FROM @UserSitePermissions
                   WHERE SiteID = hc.idfsSite
                         AND PermissionTypeID = 10059007
               ),
               (
                   SELECT Permission
                   FROM @UserSitePermissions
                   WHERE SiteID = hc.idfsSite
                         AND PermissionTypeID = 10059004
               ),
               (
                   SELECT Permission
                   FROM @UserSitePermissions
                   WHERE SiteID = hc.idfsSite
                         AND PermissionTypeID = 10059002
               )
        FROM dbo.tlbHumanCase hc
        WHERE hc.intRowStatus = 0
              AND EXISTS
        (
            SELECT * FROM @UserSitePermissions WHERE SiteID = hc.idfsSite
        );

        DELETE FROM @Results
        WHERE EXISTS
        (
            SELECT hc.idfHumanCase
            FROM dbo.tlbHumanCase hc
                INNER JOIN @UserSitePermissions usp
                    ON usp.SiteID = hc.idfsSite
            WHERE usp.Permission = 4 -- Deny permission
                  AND usp.PermissionTypeID = 10059003 -- Read permission
        );

        -- ========================================================================================
        -- FINAL QUERY, PAGINATION AND COUNTS
        -- ========================================================================================
        INSERT INTO @FinalResults
        SELECT ID,
               MAX(res.ReadPermissionIndicator),
               MAX(res.AccessToPersonalDataPermissionIndicator),
               MAX(res.AccessToGenderAndAgeDataPermissionIndicator),
               MAX(res.WritePermissionIndicator),
               MAX(res.DeletePermissionIndicator)
        FROM @Results res
            INNER JOIN dbo.tlbHumanCase hc
                ON hc.idfHumanCase = res.ID
            INNER JOIN dbo.tlbHuman h
                ON h.idfHuman = hc.idfHuman
                   AND h.intRowStatus = 0
            INNER JOIN dbo.tlbHumanActual ha
                ON ha.idfHumanActual = h.idfHumanActual
                   AND ha.intRowStatus = 0
            INNER JOIN dbo.tlbGeoLocation currentAddress
                ON currentAddress.idfGeoLocation = h.idfCurrentResidenceAddress
            LEFT JOIN dbo.gisLocationDenormalized g
                ON g.idfsLocation = currentAddress.idfsLocation
                   AND g.idfsLanguage = @LanguageCode
            LEFT JOIN dbo.tlbMaterial m
                ON m.idfHumanCase = hc.idfHumanCase
                   AND m.intRowStatus = 0
            LEFT JOIN dbo.tlbGeoLocation exposure
                ON exposure.idfGeoLocation = hc.idfPointGeoLocation
            LEFT JOIN dbo.gisLocationDenormalized gExposure
                ON gExposure.idfsLocation = exposure.idfsLocation
                   AND gExposure.idfsLanguage = @LanguageCode
        WHERE res.ReadPermissionIndicator IN ( 1, 3, 5 )
              AND hc.idfsFinalDiagnosis IS NOT NULL
              AND (
                      hc.idfHumanCase = @ReportKey
                      OR @ReportKey IS NULL
                  )
              AND (
                      hc.idfParentMonitoringSession = @SessionKey
                      OR @SessionKey IS NULL
                  )
              AND (
                      h.idfHumanActual = @PatientID
                      OR @PatientID IS NULL
                  )
              AND (
                      h.strPersonId = @PersonID
                      OR @PersonID IS NULL
                  )
              AND (
                      idfsFinalDiagnosis = @DiseaseID
                      OR @DiseaseID IS NULL
                  )
              AND (
                      idfsCaseProgressStatus = @ReportStatusTypeID
                      OR @ReportStatusTypeID IS NULL
                  )
              AND (
                      g.Level1ID = @AdministrativeLevelID
                      OR g.Level2ID = @AdministrativeLevelID
                      OR g.Level3ID = @AdministrativeLevelID
                      OR g.Level4ID = @AdministrativeLevelID
                      OR g.Level5ID = @AdministrativeLevelID
                      OR g.Level6ID = @AdministrativeLevelID
                      OR g.Level7ID = @AdministrativeLevelID
                      OR @AdministrativeLevelID IS NULL
                  )
              AND (
                      hc.datEnteredDate >= @DateEnteredFrom
                      OR @DateEnteredFrom IS NULL
                  )
              AND (
                      (CONVERT(date, hc.datEnteredDate, 102) <= @DateEnteredTo)
                      OR @DateEnteredTo IS NULL
                  )
              AND (
                      (CAST(hc.datFinalDiagnosisDate AS DATE)
              BETWEEN @DiagnosisDateFrom AND @DiagnosisDateTo
                      )
                      OR (
                             @DiagnosisDateFrom IS NULL
                             OR @DiagnosisDateTo IS NULL
                         )
                  )
              AND (
                      (CAST(hc.datNotificationDate AS DATE)
              BETWEEN @NotificationDateFrom AND @NotificationDateTo
                      )
                      OR (
                             @NotificationDateFrom IS NULL
                             OR @NotificationDateTo IS NULL
                         )
                  )
              AND (
                      (CAST(hc.datOnSetDate AS DATE)
              BETWEEN @DateOfSymptomsOnsetFrom AND @DateOfSymptomsOnsetTo
                      )
                      OR (
                             @DateOfSymptomsOnsetFrom IS NULL
                             OR @DateOfSymptomsOnsetTo IS NULL
                         )
                  )
              AND (
                      (CAST(hc.datFinalCaseClassificationDate AS DATE)
              BETWEEN @DateOfFinalCaseClassificationFrom AND @DateOfFinalCaseClassificationTo
                      )
                      OR (
                             @DateOfFinalCaseClassificationFrom IS NULL
                             OR @DateOfFinalCaseClassificationTo IS NULL
                         )
                  )
              AND (
                      hc.idfReceivedByOffice = @ReceivedByFacilityID
                      OR @ReceivedByFacilityID IS NULL
                  )
              AND (
                      hc.idfSentByOffice = @SentByFacilityID
                      OR @SentByFacilityID IS NULL
                  )
              AND (
                      idfsFinalCaseStatus = @ClassificationTypeID
                      OR @ClassificationTypeID IS NULL
                  )
              AND (
                      idfsYNHospitalization = @HospitalizationYNID
                      OR @HospitalizationYNID IS NULL
                  )
              AND (
                      gExposure.Level1ID = @LocationOfExposureAdministrativeLevelID
                      OR gExposure.Level2ID = @LocationOfExposureAdministrativeLevelID
                      OR gExposure.Level3ID = @LocationOfExposureAdministrativeLevelID
                      OR gExposure.Level4ID = @LocationOfExposureAdministrativeLevelID
                      OR gExposure.Level5ID = @LocationOfExposureAdministrativeLevelID
                      OR gExposure.Level6ID = @LocationOfExposureAdministrativeLevelID
                      OR gExposure.Level7ID = @LocationOfExposureAdministrativeLevelID
                      OR @LocationOfExposureAdministrativeLevelID IS NULL
                  )
              AND (
                      (ISNULL(h.strFirstName, '') = CASE ISNULL(@PatientFirstName, '')
                                                        WHEN '' THEN
                                                            ISNULL(h.strFirstName, '')
                                                        ELSE
                                                            @PatientFirstName
                                                    END
                      )
                      OR (CHARINDEX(@PatientFirstName, ISNULL(h.strFirstName, '')) > 0)
                  )
              AND (
                      (ISNULL(h.strSecondName, '') = CASE ISNULL(@PatientMiddleName, '')
                                                         WHEN '' THEN
                                                             ISNULL(h.strSecondName, '')
                                                         ELSE
                                                             @PatientMiddleName
                                                     END
                      )
                      OR (CHARINDEX(@PatientMiddleName, ISNULL(h.strSecondName, '')) > 0)
                  )
              AND (
                      (ISNULL(h.strLastName, '') = CASE ISNULL(@PatientLastName, '')
                                                       WHEN '' THEN
                                                           ISNULL(h.strLastName, '')
                                                       ELSE
                                                           @PatientLastName
                                                   END
                      )
                      OR (CHARINDEX(@PatientLastName, ISNULL(h.strLastName, '')) > 0)
                  )
              AND (
                      hc.idfsSite = @DataEntrySiteID
                      OR @DataEntrySiteID IS NULL
                  )
              AND (
                      (
                          hc.idfOutbreak IS NULL
                          AND @OutbreakCasesIndicator = 0
                      )
                      OR (
                             hc.idfOutbreak IS NOT NULL
                             AND @OutbreakCasesIndicator = 1
                         )
                      OR (@OutbreakCasesIndicator IS NULL)
                  )
              AND (
                      hc.strCaseID LIKE '%' + TRIM(@ReportID) + '%'
                      OR @ReportID IS NULL
                  )
              AND (
                      hc.LegacyCaseID LIKE '%' + TRIM(@LegacyReportID) + '%'
                      OR @LegacyReportID IS NULL
                  )
              AND (
                      m.strFieldBarcode LIKE '%' + TRIM(@LocalOrFieldSampleID) + '%'
                      OR @LocalOrFieldSampleID IS NULL
                  )
              AND (
                      hc.idfsOutcome = @OutcomeID
                      OR @OutcomeID IS NULL
                  )
        GROUP BY ID;

        WITH paging
        AS (SELECT ROW_NUMBER() OVER (ORDER BY CASE
                                                   WHEN @SortColumn = 'ReportID'
                                                        AND @SortOrder = 'ASC' THEN
                                                       hc.strCaseID
                                               END ASC,
                                               CASE
                                                   WHEN @SortColumn = 'ReportID'
                                                        AND @SortOrder = 'DESC' THEN
                                                       hc.strCaseID
                                               END DESC,
                                               CASE
                                                   WHEN @SortColumn = 'EnteredDate'
                                                        AND @SortOrder = 'ASC' THEN
                                                       hc.datEnteredDate
                                               END ASC,
                                               CASE
                                                   WHEN @SortColumn = 'EnteredDate'
                                                        AND @SortOrder = 'DESC' THEN
                                                       hc.datEnteredDate
                                               END DESC,
                                               CASE
                                                   WHEN @SortColumn = 'DiseaseName'
                                                        AND @SortOrder = 'ASC' THEN
                                                       disease.name
                                               END ASC,
                                               CASE
                                                   WHEN @SortColumn = 'DiseaseName'
                                                        AND @SortOrder = 'DESC' THEN
                                                       disease.name
                                               END DESC,
                                               CASE
                                                   WHEN @SortColumn = 'PersonName'
                                                        AND @SortOrder = 'ASC' THEN
                                                       ISNULL(h.strLastName, N'') + ISNULL(', ' + h.strFirstName, N'')
                                                       + ISNULL(' ' + h.strSecondName, N'')
                                               END ASC,
                                               CASE
                                                   WHEN @SortColumn = 'PersonName'
                                                        AND @SortOrder = 'DESC' THEN
                                                       ISNULL(h.strLastName, N'') + ISNULL(', ' + h.strFirstName, N'')
                                                       + ISNULL(' ' + h.strSecondName, N'')
                                               END DESC,
                                               CASE
                                                   WHEN @SortColumn = 'PersonLocation'
                                                        AND @SortOrder = 'ASC' THEN
                                               (LH.AdminLevel1Name + ', ' + LH.AdminLevel2Name)
                                               END ASC,
                                               CASE
                                                   WHEN @SortColumn = 'PersonLocation'
                                                        AND @SortOrder = 'DESC' THEN
                                               (LH.AdminLevel1Name + ', ' + LH.AdminLevel2Name)
                                               END DESC,
                                               CASE
                                                   WHEN @SortColumn = 'ClassificationTypeName'
                                                        AND @SortOrder = 'ASC' THEN
                                                       finalClassification.name
                                               END ASC,
                                               CASE
                                                   WHEN @SortColumn = 'ClassificationTypeName'
                                                        AND @SortOrder = 'DESC' THEN
                                                       finalClassification.name
                                               END DESC,
                                               CASE
                                                   WHEN @SortColumn = 'ReportStatusTypeName'
                                                        AND @SortOrder = 'ASC' THEN
                                                       reportStatus.name
                                               END ASC,
                                               CASE
                                                   WHEN @SortColumn = 'ReportStatusTypeName'
                                                        AND @SortOrder = 'DESC' THEN
                                                       reportStatus.name
                                               END DESC,
                                               CASE
                                                   WHEN @SortColumn = 'LegacyReportID'
                                                        AND @SortOrder = 'ASC' THEN
                                                       hc.LegacyCaseID
                                               END ASC,
                                               CASE
                                                   WHEN @SortColumn = 'LegacyReportID'
                                                        AND @SortOrder = 'DESC' THEN
                                                       hc.LegacyCaseID
                                               END DESC
                                     ) AS ROWNUM,
                   res.ID AS ReportKey,
                   CASE WHEN @OutbreakCasesIndicator = 1 AND hc.idfOutbreak IS NOT NULL THEN
                       ocr.strOutbreakCaseID
                   ELSE 
                       hc.strCaseId 
                   END AS ReportID,
                   hc.LegacyCaseID AS LegacyReportID,
                   reportStatus.name AS ReportStatusTypeName,
                   reportType.name AS ReportTypeName,
                   hc.datTentativeDiagnosisDate AS TentativeDiagnosisDate,
                   hc.datFinalDiagnosisDate AS FinalDiagnosisDate,
                   ISNULL(finalClassification.name, initialClassification.name) AS ClassificationTypeName,
                   finalClassification.name AS FinalClassificationTypeName,
                   hc.datOnSetDate AS DateOfOnset,
                   hc.idfsFinalDiagnosis AS DiseaseID,
                   disease.Name AS DiseaseName,
                   h.idfHumanActual AS PersonMasterID,
                   hc.idfHuman AS PersonKey,
                   haai.EIDSSPersonID AS PersonID,
                   h.strPersonID AS PersonalID,
                   dbo.FN_GBL_ConcatFullName(h.strLastName, h.strFirstName, h.strSecondName) AS PersonName,
                   ISNULL(LH.AdminLevel1Name, '') + IIF(LH.AdminLevel2Name IS NULL, '', ', ')
                   + ISNULL(LH.AdminLevel2Name, '') AS PersonLocation,
                   ha.strEmployerName AS EmployerName,
                   hc.datEnteredDate AS EnteredDate,
                   ISNULL(p.strFamilyName, N'') + ISNULL(', ' + p.strFirstName, N'')
                   + ISNULL(' ' + p.strSecondName, N'') AS EnteredByPersonName,
                   organization.AbbreviatedName AS EnteredByOrganizationName, 
                   hc.datModificationDate AS ModificationDate,
                   ISNULL(hospitalization.name, hospitalization.strDefault) AS HospitalizationStatus,
                   hc.idfsSite AS SiteID,
                   res.ReadPermissionIndicator AS ReadPermissionIndicator,
                   res.AccessToPersonalDataPermissionIndicator AS AccessToPersonalDataPermissionIndicator,
                   res.AccessToGenderAndAgeDataPermissionIndicator AS AccessToGenderAndAgeDataPermissionIndicator,
                   res.WritePermissionIndicator AS WritePermissionIndicator,
                   res.DeletePermissionIndicator AS DeletePermissionIndicator,
                   COUNT(*) OVER () AS RecordCount,
                   (
                       SELECT COUNT(*) FROM dbo.tlbHumanCase hc WHERE hc.intRowStatus = 0
                   ) AS TotalCount,
                   LH.AdminLevel2Name AS Region,
                   LH.AdminLevel3Name AS Rayon
            FROM @FinalResults res
                INNER JOIN dbo.tlbHumanCase hc
                    ON hc.idfHumanCase = res.ID
                INNER JOIN dbo.tlbHuman h
                    ON h.idfHuman = hc.idfHuman
                       AND h.intRowStatus = 0
                INNER JOIN dbo.tlbHumanActual ha
                    ON ha.idfHumanActual = h.idfHumanActual
                       AND ha.intRowStatus = 0
                LEFT JOIN dbo.tlbGeoLocation gl
                    ON gl.idfGeoLocation = h.idfCurrentResidenceAddress
                LEFT JOIN FN_GBL_LocationHierarchy_Flattened(@LanguageID) LH
                    ON LH.idfsLocation = gl.idfsLocation
                LEFT JOIN dbo.HumanActualAddlInfo haai
                    ON haai.HumanActualAddlInfoUID = ha.idfHumanActual
                       AND haai.intRowStatus = 0
                LEFT JOIN dbo.FN_GBL_Repair(@LanguageID, 19000019) disease
                    ON disease.idfsReference = hc.idfsFinalDiagnosis
                LEFT JOIN dbo.FN_GBL_Repair(@LanguageID, 19000011) initialClassification
                    ON initialClassification.idfsReference = hc.idfsInitialCaseStatus
                LEFT JOIN dbo.FN_GBL_Repair(@LanguageID, 19000011) finalClassification
                    ON finalClassification.idfsReference = hc.idfsFinalCaseStatus
                LEFT JOIN dbo.FN_GBL_Repair(@LanguageID, 19000111) reportStatus
                    ON reportStatus.idfsReference = hc.idfsCaseProgressStatus
                LEFT JOIN dbo.FN_GBL_Repair(@LanguageID, 19000144) reportType
                    ON reportType.idfsReference = hc.DiseaseReportTypeID
                LEFT JOIN dbo.FN_GBL_Repair(@LanguageID, 19000041) hospitalization
                    ON hospitalization.idfsReference = idfsHospitalizationStatus
                LEFT JOIN dbo.tlbPerson p
                    ON p.idfPerson = hc.idfPersonEnteredBy
                       AND p.intRowStatus = 0
                INNER JOIN dbo.tstSite s 
                    ON s.idfsSite = hc.idfsSite
                LEFT JOIN dbo.FN_GBL_Institution_Min(@LanguageID) organization
                    ON organization.idfOffice = p.idfInstitution
                LEFT JOIN dbo.OutbreakCaseReport ocr 
                    ON ocr.idfHumanCase = hc.idfHumanCase
           )
        SELECT ReportKey,
               ReportID,
               LegacyReportID,
               ReportStatusTypeName,
               ReportTypeName,
               TentativeDiagnosisDate,
               FinalDiagnosisDate,
               ClassificationTypeName,
               FinalClassificationTypeName,
               DateOfOnset,
               DiseaseID,
               DiseaseName,
               PersonMasterID,
               PersonKey,
               PersonID,
               PersonalID,
               PersonName,
               PersonLocation,
               EmployerName,
               EnteredDate,
               EnteredByPersonName,
               EnteredByOrganizationName, 
               ModificationDate,
               HospitalizationStatus,
               SiteID,
               CASE
                   WHEN ReadPermissionIndicator = 5 THEN
                       CONVERT(BIT, 1)
                   WHEN ReadPermissionIndicator = 4 THEN
                       CONVERT(BIT, 0)
                   WHEN ReadPermissionIndicator = 3 THEN
                       CONVERT(BIT, 1)
                   WHEN ReadPermissionIndicator = 2 THEN
                       CONVERT(BIT, 0)
                   ELSE
                       CONVERT(BIT, ReadPermissionIndicator)
               END AS ReadPermissionindicator,
               CASE
                   WHEN AccessToPersonalDataPermissionIndicator = 5 THEN
                       CONVERT(BIT, 1)
                   WHEN AccessToPersonalDataPermissionIndicator = 4 THEN
                       CONVERT(BIT, 0)
                   WHEN AccessToPersonalDataPermissionIndicator = 3 THEN
                       CONVERT(BIT, 1)
                   WHEN AccessToPersonalDataPermissionIndicator = 2 THEN
                       CONVERT(BIT, 0)
                   ELSE
                       CONVERT(BIT, AccessToPersonalDataPermissionIndicator)
               END AS AccessToPersonalDataPermissionIndicator,
               CASE
                   WHEN AccessToGenderAndAgeDataPermissionIndicator = 5 THEN
                       CONVERT(BIT, 1)
                   WHEN AccessToGenderAndAgeDataPermissionIndicator = 4 THEN
                       CONVERT(BIT, 0)
                   WHEN AccessToGenderAndAgeDataPermissionIndicator = 3 THEN
                       CONVERT(BIT, 1)
                   WHEN AccessToGenderAndAgeDataPermissionIndicator = 2 THEN
                       CONVERT(BIT, 0)
                   ELSE
                       CONVERT(BIT, AccessToGenderAndAgeDataPermissionIndicator)
               END AS AccessToGenderAndAgeDataPermissionIndicator,
               CASE
                   WHEN WritePermissionIndicator = 5 THEN
                       CONVERT(BIT, 1)
                   WHEN WritePermissionIndicator = 4 THEN
                       CONVERT(BIT, 0)
                   WHEN WritePermissionIndicator = 3 THEN
                       CONVERT(BIT, 1)
                   WHEN WritePermissionIndicator = 2 THEN
                       CONVERT(BIT, 0)
                   ELSE
                       CONVERT(BIT, WritePermissionIndicator)
               END AS WritePermissionIndicator,
               CASE
                   WHEN DeletePermissionIndicator = 5 THEN
                       CONVERT(BIT, 1)
                   WHEN DeletePermissionIndicator = 4 THEN
                       CONVERT(BIT, 0)
                   WHEN DeletePermissionIndicator = 3 THEN
                       CONVERT(BIT, 1)
                   WHEN DeletePermissionIndicator = 2 THEN
                       CONVERT(BIT, 0)
                   ELSE
                       CONVERT(BIT, DeletePermissionIndicator)
               END AS DeletePermissionIndicator,
               RecordCount,
               TotalCount,
               TotalPages = (RecordCount / @PageSize) + IIF(RecordCount % @PageSize > 0, 1, 0),
               CurrentPage = @Page,
               Region,
               Rayon
        FROM paging
        WHERE RowNum > @firstRec
              AND RowNum < @lastRec
        OPTION (RECOMPILE);
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH;
END
GO
PRINT N'Altering Procedure [dbo].[USP_HUM_HUMAN_MASTER_GETDetail]...';


GO
-- ================================================================================================
-- Name: USP_HUM_HUMAN_MASTER_GETDetail OLD
--
-- Description:	Get a human actual record
--          
-- Revision History:
-- Name				Date		Change Detail
-- ---------------	----------	--------------------------------------------------------------------
-- Mandar Kulkarni				Initial release.
-- Vilma Thomas		05/25/2018	Update the ReferenceType key from 19000167 to 19000500 for 'Contact 
--								Phone Type'
-- Stephen Long		11/26/2018	Update for the new API; remove returnCode and returnMsg.
-- Ann Xiong		08/30/2019	Added script to select PersonalIDTypeName, OccupationTypeName, 
--								SchoolCountry, 
--								SchoolRegion, SchoolRayon, SchoolSettlement for Person Deduplication.
-- Ann Xiong		09/09/2019	return haai.SchoolAddressID instead of haai.AltAddressID as 
--								SchoolGeoLocationID
-- Mark Wilson		10/29/2019	added Settlement Type to return
-- Ann Xiong		02/17/2020	Added IsAnotherPhone and Age to select
-- Ann Xiong		05/08/2020	Added YNAnotherAddress, YNHumanForeignAddress, 
--								YNEmployerForeignAddress, YNHumanAltForeignAddress, 
--								YNSchoolForeignAddress, YNWorkSameAddress to select
-- Stephen Long		07/07/2020	Changed v6.1 function call for create address string to v7 version.
-- Mark Wilson		09/20/2021	reworked the locations to use gisLocation and hierarchy
-- Mark Wilson		10/04/2021	Updated to pull location data from correct table
-- Mark Wilson		10/05/2021	Updated to use correct location references and udpate test code
-- Mark Wilson		10/06/2021	Added Alt Address fields
-- Mark Wilson		10/07/2021	Lat/Long only needed for Current Address and Foreign Address not needed for Permanent
-- Mark Wilson		10/12/2021  Added YNPermanentSameAddress, updated YNAnotherAddress
-- Leo Tracchia		05/13/2022	Added joins for Location hierachy
-- Ann Xiong		03/24/2020	Modified to return Age from DateofBirth for Person Deduplication when DateofBirth is not null but haai.ReportedAge and haai.ReportedAgeUOMID are null
--
/*Test Code

EXEC dbo.USP_HUM_HUMAN_MASTER_GETDetail
	@LangID = 'en-US',
	@HumanMasterID = 422849750000916


EXEC dbo.USP_HUM_HUMAN_MASTER_GETDetail
	@LangID = 'az-Latn-AZ',
	@HumanMasterID = 411420970000870


EXEC dbo.USP_HUM_HUMAN_MASTER_GETDetail
	@LangID = 'en-US',
	@HumanMasterID = 413771740000870

*/
-- ================================================================================================
ALTER PROCEDURE [dbo].[USP_HUM_HUMAN_MASTER_GETDetail] (
	@LangID NVARCHAR(20),
	@HumanMasterID BIGINT
	)
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		SELECT ISNULL(ha.strFirstName, '') + ' ' + ISNULL(ha.strLastName, '') AS PatientFarmOwnerName,
			haai.EIDSSPersonId AS EIDSSPersonID,
			ha.idfsOccupationType AS OccupationTypeID,
			ha.idfsNationality AS CitizenshipTypeID,
			citizenshipType.name AS CitizenshipTypeName,
			ha.idfsHumanGender AS GenderTypeID,
			tb.name AS GenderTypeName,

			-- Current Address
			ha.idfCurrentResidenceAddress AS HumanGeoLocationID,
			lhHuman.AdminLevel1ID AS HumanidfsCountry,
			lhHuman.AdminLevel1Name AS HumanCountry,
			lhHuman.AdminLevel2ID AS HumanidfsRegion,
			lhHuman.AdminLevel2Name AS HumanRegion,
			lhHuman.AdminLevel3ID AS HumanidfsRayon,
			lhHuman.AdminLevel3Name AS HumanRayon,
			lhHuman.AdminLevel4ID AS HumanidfsSettlement,
			lhHuman.AdminLevel4Name AS HumanSettlement,			
			HL.idfsType AS HumanidfsSettlementType,
			humanSettlementType.[name] AS HumanSettlementType,
			tglHuman.strPostCode AS HumanstrPostalCode,
			tglHuman.strStreetName AS HumanstrStreetName,
			tglHuman.strHouse AS HumanstrHouse,
			tglHuman.strBuilding AS HumanstrBuilding,
			tglHuman.strApartment AS HumanstrApartment,
			tglHuman.strDescription AS HumanDescription,
			tglHuman.dblLatitude AS HumanstrLatitude,
			tglHuman.dblLongitude AS HumanstrLongitude,
			tglHuman.blnForeignAddress AS HumanForeignAddressIndicator,
			tglHuman.strForeignAddress AS HumanForeignAddressString,

			-- Employer Address
			ha.idfEmployerAddress AS EmployerGeoLocationID,
			lhEmployer.AdminLevel1ID AS EmployeridfsCountry,
			lhEmployer.AdminLevel1Name AS EmployerCountry,
			lhEmployer.AdminLevel2ID AS EmployeridfsRegion,
			lhEmployer.AdminLevel2Name AS EmployerRegion,
			lhEmployer.AdminLevel3ID AS EmployeridfsRayon,
			lhEmployer.AdminLevel3Name AS EmployerRayon,
			lhEmployer.AdminLevel4ID AS EmployeridfsSettlement,
			lhEmployer.AdminLevel4Name AS EmployerSettlement,
			EA.idfsType AS EmployeridfsSettlementType,
			EmpSettlementType.strDefault AS EmployerSettlementType,
			tglEmployer.strPostCode AS EmployerstrPostalCode,
			tglEmployer.strStreetName AS EmployerstrStreetName,
			tglEmployer.strHouse AS EmployerstrHouse,
			tglEmployer.strBuilding AS EmployerstrBuilding,
			tglEmployer.strApartment AS EmployerstrApartment,
			tglEmployer.strDescription AS EmployerDescription,
			tglEmployer.blnForeignAddress AS EmployerForeignAddressIndicator,
			tglEmployer.strForeignAddress AS EmployerForeignAddressString,

			-- Permanent Address
			ha.idfRegistrationAddress AS HumanPermGeoLocationID,
			lhPerm.AdminLevel1ID AS HumanPermidfsCountry,
			lhPerm.AdminLevel1Name AS HumanPermCountry,
			lhPerm.AdminLevel2ID AS HumanPermidfsRegion,
			lhPerm.AdminLevel2Name AS HumanPermRegion,
			lhPerm.AdminLevel3ID AS HumanPermidfsRayon,
			lhPerm.AdminLevel3Name AS HumanPermRayon,
			lhPerm.AdminLevel4ID HumanPermidfsSettlement,
			lhPerm.AdminLevel4Name AS HumanPermSettlement,
			registrationLocation.idfsType AS HumanPermidfsSettlementType,
			registrationSettlementType.[name] AS HumanPermSettlementType,
			tglRegistrationAddress.strPostCode AS HumanPermstrPostalCode,
			tglRegistrationAddress.strStreetName AS HumanPermstrStreetName,
			tglRegistrationAddress.strHouse AS HumanPermstrHouse,
			tglRegistrationAddress.strBuilding AS HumanPermstrBuilding,
			tglRegistrationAddress.strApartment AS HumanPermstrApartment,
			tglRegistrationAddress.strDescription AS HumanPermDescription,

			-- Alternate Address
			haai.AltAddressID AS HumanAltGeoLocationID,
			lhAlt.AdminLevel1ID AS HumanAltidfsCountry,
			lhAlt.AdminLevel1Name AS HumanAltCountry,
			lhAlt.AdminLevel2ID AS HumanAltidfsRegion,
			lhAlt.AdminLevel2Name AS HumanAltRegion,
			lhAlt.AdminLevel3ID AS HumanAltidfsRayon,
			lhAlt.AdminLevel3Name AS HumanAltRayon,
			lhAlt.AdminLevel4ID HumanAltidfsSettlement,
			lhAlt.AdminLevel4Name AS HumanAltSettlement,
			AltLocation.idfsType AS HumanAltidfsSettlementType,
			AltSettlementType.[name] AS HumanAltSettlementType,
			tglAlt.strPostCode AS HumanAltstrPostalCode,
			tglAlt.strStreetName AS HumanAltstrStreetName,
			tglAlt.strHouse AS HumanAltstrHouse,
			tglAlt.strBuilding AS HumanAltstrBuilding,
			tglAlt.strApartment AS HumanAltstrApartment,
			tglAlt.strDescription AS HumanAltDescription,
			tglAlt.blnForeignAddress AS HumanAltForeignAddressIndicator,
			tglAlt.strForeignAddress AS HumanAltForeignAddressString,

			-- School Address
			haai.SchoolAddressID AS SchoolGeoLocationID,
			lhSchool.AdminLevel1ID AS SchoolidfsCountry,
			lhSchool.AdminLevel1Name AS SchoolCountry,
			lhSchool.AdminLevel2ID AS SchoolidfsRegion,
			lhSchool.AdminLevel2Name AS SchoolRegion,
			lhSchool.AdminLevel3ID AS SchoolidfsRayon,
			lhSchool.AdminLevel3Name AS SchoolRayon,
			lhSchool.AdminLevel4ID AS SchoolidfsSettlement,
			lhSchool.AdminLevel4Name AS SchoolSettlement,
			SchoolLocation.idfsType AS SchoolAltidfsSettlementType,
			SchoolSettlementType.strDefault AS SchoolAltSettlementType,
			tglSchool.strPostCode AS SchoolstrPostalCode,
			tglSchool.strStreetName AS SchoolstrStreetName,
			tglSchool.strHouse AS SchoolstrHouse,
			tglSchool.strBuilding AS SchoolstrBuilding,
			tglSchool.strApartment AS SchoolstrApartment,
			tglSchool.blnForeignAddress AS SchoolForeignAddressIndicator,
			tglSchool.strForeignAddress AS SchoolForeignAddressString,

			dbo.FN_GBL_FormatDate(ha.datDateofBirth, 'mm/dd/yyyy') AS DateOfBirth,
			dbo.FN_GBL_FormatDate(ha.datDateOfDeath, 'mm/dd/yyyy') AS DateOfDeath,
			dbo.FN_GBL_FormatDate(ha.datEnteredDate, 'mm/dd/yyyy') AS EnteredDate,
			dbo.FN_GBL_FormatDate(ha.datModificationDate, 'mm/dd/yyyy') AS ModificationDate,
			ha.strFirstName AS FirstOrGivenName,
			ha.strSecondName AS SecondName,
			ha.strLastName AS LastOrSurname,
			ha.strEmployerName AS EmployerName,
			ha.strHomePhone AS HomePhone,
			ha.strWorkPhone AS WorkPhone,
			ha.idfsPersonIDType AS PersonalIDType,
			ha.strPersonID AS PersonalID,
			haai.ReportedAge,
			haai.ReportedAgeUOMID,
			haai.PassportNbr AS PassportNumber,
			haai.IsEmployedID AS IsEmployedTypeID,
			isEmployed.name AS IsEmployedTypeName,
			haai.EmployerPhoneNbr AS EmployerPhone,
			haai.EmployedDTM AS EmployedDateLastPresent,
			haai.IsStudentID AS IsStudentTypeID,
			isStudent.name AS IsStudentTypeName,
			haai.SchoolName AS SchoolName,
			haai.SchoolLastAttendDTM AS SchoolDateLastAttended,
			haai.SchoolPhoneNbr AS SchoolPhone,
			haai.ContactPhoneCountryCode,
			haai.ContactPhoneNbr AS ContactPhone,
			haai.ContactPhoneNbrTypeID AS ContactPhoneTypeID,
			ContactPhoneNbrTypeID.name AS ContactPhoneTypeName,
			haai.ContactPhone2CountryCode,
			haai.ContactPhone2Nbr AS ContactPhone2,
			haai.ContactPhone2NbrTypeID AS ContactPhone2TypeID,
			ContactPhone2NbrTypeID.name AS ContactPhone2TypeName,
			personalIDType.name AS PersonalIDTypeName,
			occupationType.name AS OccupationTypeName,
			CASE 
				WHEN haai.ContactPhone2Nbr IS NULL
					AND haai.ContactPhone2NbrTypeID IS NULL
					THEN 'No'
				ELSE 'Yes'
				END AS IsAnotherPhone,
			--CAST(ISNULL(haai.ReportedAge, '') AS VARCHAR(3)) + ' ' + ISNULL(HumanAgeType.name, '') AS Age,
			CASE 
				WHEN haai.ReportedAge IS NULL AND haai.ReportedAgeUOMID IS NULL
					THEN (CASE 
							WHEN ha.datDateofBirth IS NOT NULL					
								THEN CAST(FLOOR(DATEDIFF(DAY, ha.datDateofBirth, GETDATE ())/365.242199) AS VARCHAR(3)) + ' ' + HumanAgeType.name
							ELSE ''
							END)
				ELSE CAST(ISNULL(haai.ReportedAge, '') AS VARCHAR(3)) + ' ' + ISNULL(HumanAgeType.name, '')
				END AS Age, 
			CASE 
				WHEN ((ha.idfRegistrationAddress IS NOT NULL AND ha.idfRegistrationAddress > 0) OR (haai.AltAddressID IS NOT NULL AND haai.AltAddressID > 0))
					THEN 'Yes'
				ELSE 'No'
				END AS YNAnotherAddress,
			CASE 
				WHEN tglHuman.blnForeignAddress IS NOT NULL
					AND tglHuman.blnForeignAddress = 1
					THEN 'Yes'
				ELSE 'No'
				END AS YNHumanForeignAddress,
			CASE 
				WHEN tglEmployer.blnForeignAddress IS NOT NULL
					AND tglEmployer.blnForeignAddress = 1
					THEN 'Yes'
				ELSE 'No'
				END AS YNEmployerForeignAddress,
			CASE 
				WHEN tglRegistrationAddress.blnForeignAddress IS NOT NULL
					AND tglRegistrationAddress.blnForeignAddress = 1
					THEN 'Yes'
				ELSE 'No'
				END AS YNHumPermForeignAddress,
			CASE 
				WHEN tglAlt.blnForeignAddress IS NOT NULL
					AND tglAlt.blnForeignAddress = 1
					THEN 'Yes'
				ELSE 'No'
				END AS YNHumanAltForeignAddress,
			CASE 
				WHEN tglSchool.blnForeignAddress IS NOT NULL
					AND tglSchool.blnForeignAddress = 1
					THEN 'Yes'
				ELSE 'No'
				END AS YNSchoolForeignAddress,
			CASE 
				WHEN dbo.FN_GBL_CreateAddressString(ISNULL(lhHuman.AdminLevel1Name, N''), ISNULL(lhHuman.AdminLevel2Name, N''), ISNULL(lhHuman.AdminLevel3Name, N''), ISNULL(tglHuman.strPostCode, N''), ISNULL(humanSettlementType.strDefault, N''), ISNULL(lhHuman.AdminLevel4Name, N''), ISNULL(tglHuman.strStreetName, N''), ISNULL(tglHuman.strHouse, N''), ISNULL(tglHuman.strBuilding, N''), ISNULL(tglHuman.strApartment, N''), ISNULL(tglHuman.blnForeignAddress, N''), ISNULL(tglHuman.strForeignAddress, N'')) = 
						dbo.FN_GBL_CreateAddressString(ISNULL(lhEmployer.AdminLevel1Name, N''), ISNULL(lhEmployer.AdminLevel2Name, N''), ISNULL(lhEmployer.AdminLevel3Name, N''), ISNULL(tglEmployer.strPostCode, N''), ISNULL(EmpSettlementType.strDefault, N''), ISNULL(lhEmployer.AdminLevel4Name, N''), ISNULL(tglEmployer.strStreetName, N''), ISNULL(tglEmployer.strHouse, N''), ISNULL(tglEmployer.strBuilding, N''), ISNULL(tglEmployer.strApartment, N''), ISNULL(tglEmployer.blnForeignAddress, N''), ISNULL(tglEmployer.strForeignAddress, N''))
					THEN 'Yes'
				ELSE 'No'
				END AS YNWorkSameAddress,
			CASE 
				WHEN dbo.FN_GBL_CreateAddressString(ISNULL(lhHuman.AdminLevel1Name, N''), ISNULL(lhHuman.AdminLevel2Name, N''), ISNULL(lhHuman.AdminLevel3Name, N''), ISNULL(tglHuman.strPostCode, N''), ISNULL(humanSettlementType.strDefault, N''), ISNULL(lhHuman.AdminLevel4Name, N''), ISNULL(tglHuman.strStreetName, N''), ISNULL(tglHuman.strHouse, N''), ISNULL(tglHuman.strBuilding, N''), ISNULL(tglHuman.strApartment, N''), ISNULL(tglHuman.blnForeignAddress, N''), ISNULL(tglHuman.strForeignAddress, N'')) = 
						dbo.FN_GBL_CreateAddressString(ISNULL(lhPerm.AdminLevel1Name, N''), ISNULL(lhPerm.AdminLevel2Name, N''), ISNULL(lhPerm.AdminLevel3Name, N''), ISNULL(tglRegistrationAddress.strPostCode, N''), ISNULL(registrationSettlementType.strDefault, N''), ISNULL(lhPerm.AdminLevel4Name, N''), ISNULL(tglRegistrationAddress.strStreetName, N''), ISNULL(tglRegistrationAddress.strHouse, N''), ISNULL(tglRegistrationAddress.strBuilding, N''), ISNULL(tglRegistrationAddress.strApartment, N''), ISNULL(tglRegistrationAddress.blnForeignAddress, N''), ISNULL(tglRegistrationAddress.strForeignAddress, N''))
					THEN 'Yes'
				ELSE 'No'
				END AS YNPermanentSameAddress 

		FROM dbo.tlbHumanActual ha

		LEFT JOIN dbo.HumanActualAddlinfo haai ON ha.idfHumanActual = haai.HumanActualAddlinfoUID
		LEFT JOIN dbo.tlbGeoLocationShared AS tglHuman ON ha.idfCurrentResidenceAddress = tglHuman.idfGeoLocationShared
		LEFT JOIN dbo.tlbGeoLocationShared AS tglEmployer ON ha.idfEmployerAddress = tglEmployer.idfGeoLocationShared
		LEFT JOIN dbo.tlbGeoLocationShared AS tglRegistrationAddress ON ha.idfRegistrationAddress = tglRegistrationAddress.idfGeoLocationShared
		LEFT JOIN dbo.tlbGeoLocationShared AS tglSchool ON haai.SchoolAddressID = tglSchool.idfGeoLocationShared
		LEFT JOIN dbo.tlbGeoLocationShared AS tglAlt ON haai.AltAddressID = tglAlt.idfGeoLocationShared
		LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LangID, 19000043) tb ON tb.idfsReference = ha.idfsHumanGender

		-- Current Address
		LEFT JOIN dbo.gisLocation HL ON HL.idfsLocation = tglHuman.idfsLocation	
		LEFT JOIN dbo.FN_GBL_LocationHierarchy_Flattened(@LangID) lhHuman ON lhHuman.idfsLocation = tglHuman.idfsLocation			
		--LEFT JOIN dbo.FN_GBL_GIS_ReferenceRepair_GET(@LangID, 19000001) AS humanCountry ON HL.node.IsDescendantOf(humanCountry.node) = 1
		--LEFT JOIN dbo.FN_GBL_GIS_ReferenceRepair_GET(@LangID, 19000003) AS humanRegion ON HL.node.IsDescendantOf(humanRegion.node) = 1
		--LEFT JOIN dbo.FN_GBL_GIS_ReferenceRepair_GET(@LangID, 19000002) AS humanRayon ON HL.node.IsDescendantOf(humanRayon.node) = 1
		--LEFT JOIN dbo.FN_GBL_GIS_ReferenceRepair_GET(@LangID, 19000004) AS humanSettlement ON HL.node.IsDescendantOf(humanSettlement.node) = 1
		LEFT JOIN dbo.FN_GBL_GIS_Reference(@LangID, 19000005) AS humanSettlementType ON humanSettlementType.idfsReference = HL.idfsType

		-- Employer address 
		LEFT JOIN dbo.gisLocation EA ON EA.idfsLocation = tglEmployer.idfsLocation
		LEFT JOIN dbo.FN_GBL_LocationHierarchy_Flattened(@LangID) lhEmployer ON lhEmployer.idfsLocation = tglEmployer.idfsLocation		
		--LEFT JOIN dbo.FN_GBL_GIS_ReferenceRepair_GET(@LangID, 19000001) AS ECountry ON EA.node.IsDescendantOf(Ecountry.node) = 1
		--LEFT JOIN dbo.FN_GBL_GIS_ReferenceRepair_GET(@LangID, 19000003) AS ERegion ON EA.node.IsDescendantOf(ERegion.node) = 1
		--LEFT JOIN dbo.FN_GBL_GIS_ReferenceRepair_GET(@LangID, 19000002) AS ERayon ON EA.node.IsDescendantOf(ERayon.node) = 1
		--LEFT JOIN dbo.FN_GBL_GIS_ReferenceRepair_GET(@LangID, 19000004) AS ESettlement ON EA.node.IsDescendantOf(ESettlement.node) = 1
		LEFT JOIN dbo.FN_GBL_GIS_Reference(@LangID, 19000005) AS EmpSettlementType ON EmpSettlementType.idfsReference = EA.idfsType

		-- Permanent address 
		LEFT JOIN dbo.gisLocation registrationLocation ON registrationLocation.idfsLocation = tglRegistrationAddress.idfsLocation
		LEFT JOIN dbo.FN_GBL_LocationHierarchy_Flattened(@LangID) lhPerm ON lhPerm.idfsLocation = tglRegistrationAddress.idfsLocation		
		--LEFT JOIN dbo.FN_GBL_GIS_ReferenceRepair_GET(@LangID, 19000001) AS registrationCountry ON registrationLocation.node.IsDescendantOf(registrationCountry.node) = 1
		--LEFT JOIN dbo.FN_GBL_GIS_ReferenceRepair_GET(@LangID, 19000003) AS registrationRegion ON registrationLocation.node.IsDescendantOf(registrationRegion.node) = 1
		--LEFT JOIN dbo.FN_GBL_GIS_ReferenceRepair_GET(@LangID, 19000002) AS registrationRayon ON registrationLocation.node.IsDescendantOf(registrationRayon.node) = 1
		--LEFT JOIN dbo.FN_GBL_GIS_ReferenceRepair_GET(@LangID, 19000004) AS registrationSettlement ON registrationLocation.node.IsDescendantOf(registrationSettlement.node) = 1
		LEFT JOIN dbo.FN_GBL_GIS_Reference(@LangID, 19000005) AS registrationSettlementType ON registrationSettlementType.idfsReference = registrationLocation.idfsType

		-- Alternate address - new for EIDSS7
		LEFT JOIN dbo.gisLocation AltLocation ON AltLocation.idfsLocation = tglAlt.idfsLocation
		LEFT JOIN dbo.FN_GBL_LocationHierarchy_Flattened(@LangID) lhAlt ON lhAlt.idfsLocation = tglAlt.idfsLocation		
		--LEFT JOIN dbo.FN_GBL_GIS_ReferenceRepair_GET(@LangID, 19000001) AS AltCountry ON AltLocation.node.IsDescendantOf(AltCountry.node) = 1
		--LEFT JOIN dbo.FN_GBL_GIS_ReferenceRepair_GET(@LangID, 19000003) AS AltRegion ON AltLocation.node.IsDescendantOf(AltRegion.node) = 1
		--LEFT JOIN dbo.FN_GBL_GIS_ReferenceRepair_GET(@LangID, 19000002) AS AltRayon ON AltLocation.node.IsDescendantOf(AltRayon.node) = 1
		--LEFT JOIN dbo.FN_GBL_GIS_ReferenceRepair_GET(@LangID, 19000004) AS AltSettlement ON AltLocation.node.IsDescendantOf(AltSettlement.node) = 1
		LEFT JOIN dbo.FN_GBL_GIS_Reference(@LangID, 19000005) AS AltSettlementType ON AltSettlementType.idfsReference = AltLocation.idfsType

		LEFT JOIN dbo.FN_GBL_Repair(@LangID, 19000100) isEmployed ON IsEmployed.idfsReference = haai.IsEmployedID
		LEFT JOIN dbo.FN_GBL_Repair(@LangID, 19000100) isStudent ON isStudent.idfsReference = haai.IsStudentID
		LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LangID, 19000054) AS citizenshipType ON ha.idfsNationality = citizenshipType.idfsReference
		LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LangID, 19000500) AS contactPhoneNbrTypeID ON contactPhoneNbrTypeID.idfsReference = haai.ContactPhoneNbrTypeID
		LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LangID, 19000500) AS contactPhone2NbrTypeID ON contactPhone2NbrTypeID.idfsReference = haai.ContactPhone2NbrTypeID
		LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LangID, 19000148) AS personalIDType ON ha.idfsPersonIDType = personalIDType.idfsReference
		LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LangID, 19000061) AS occupationType ON ha.idfsOccupationType = occupationType.idfsReference

		-- School address - E6 school address was originally stored in idfEmployerAddress with employment type = 'Student'
		LEFT JOIN dbo.gisLocation SchoolLocation ON SchoolLocation.idfsLocation = tglSchool.idfsLocation
		LEFT JOIN dbo.FN_GBL_LocationHierarchy_Flattened(@LangID) lhSchool ON lhSchool.idfsLocation = tglSchool.idfsLocation		
		--LEFT JOIN dbo.FN_GBL_GIS_ReferenceRepair_GET(@LangID, 19000001) AS schoolCountry ON SchoolLocation.node.IsDescendantOf(schoolCountry.node) = 1
		--LEFT JOIN dbo.FN_GBL_GIS_ReferenceRepair_GET(@LangID, 19000003) AS schoolRegion ON SchoolLocation.node.IsDescendantOf(schoolRegion.node) = 1
		--LEFT JOIN dbo.FN_GBL_GIS_ReferenceRepair_GET(@LangID, 19000002) AS schoolRayon ON SchoolLocation.node.IsDescendantOf(schoolRayon.node) = 1
		--LEFT JOIN dbo.FN_GBL_GIS_ReferenceRepair_GET(@LangID, 19000004) AS schoolSettlement ON SchoolLocation.node.IsDescendantOf(schoolSettlement.node) = 1
		LEFT JOIN dbo.FN_GBL_GIS_Reference(@LangID, 19000005) AS schoolSettlementType ON schoolSettlementType.idfsReference = SchoolLocation.idfsType


		LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LangID, 19000042) AS HumanAgeType	ON (haai.ReportedAgeUOMID = HumanAgeType.idfsReference Or HumanAgeType.idfsReference = 10042003)



		WHERE ha.idfHumanActual = @HumanMasterID;
	END TRY

	BEGIN CATCH
		THROW;
	END CATCH
END
GO
PRINT N'Altering Procedure [dbo].[USP_HUM_HUMAN_MASTER_GETList]...';


GO
-- ================================================================================================
-- Name: USP_HUM_HUMAN_MASTER_GETList
--
-- Description: Get human actual list for human, laboratory and veterinary modules.
--          
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Mandar Kulkarni             Initial release.
-- Stephen Long     03/13/2018 Added additional address fields.
-- Stephen Long     08/23/2018 Added EIDSS person ID to list.
-- Stephen Long     09/26/2018 Added wildcard to the front of fields using the wildcard symbol, as 
--                             per use case.
-- Stephen Long		09/28/2018 Added order by and total records, as per use case.
-- Stephen Long     11/26/2018 Updated for the new API; removed returnCode and returnMsg. Total 
--                             records will need to be handled differently.
-- Stephen Long     12/14/2018 Added pagination set, page size and max pages per fetch parameters
--                             and fetch portion.
-- Stephen Long     12/30/2018 Renamed to master so the human get list stored procedure can query 
--                             the human table which is needed for the lab module instead of human 
--                             actual.
-- Stephen Long     01/18/2019 Changed date of birth to date of birth range, and duplicate check.
-- Stephen Long     04/08/2019 Changed full name from first name last name second name to last 
--                             name ', ' first name and then second name.
-- Stephen Long     07/07/2019 Added settlement ID and settlement name to select.
-- Ann Xiong	    10/29/2019 added PassportNumber to return
-- Ann Xiong		01/15/2020 Used humanAddress.strAddressString instead of 
--                             humanAddress.strForeignAddress for AddressString
-- Stephen Long     01/28/2021 Added order by clause to handle user selected sorting across 
--                             pagination sets.
-- Doug Albanese	06/11/2021 Refactored to conform to the new filtering requirements and return structure for our gridview.
-- Mark Wilson		10/05/2021 updated for changes to DOB rules, location udpates, etc...
-- Mark Wilson		10/26/2021 changed to nolock...
-- Ann Xiong		12/03/2021 Changed ha.datDateofBirth AS DateOfBirth to CONVERT(char(10), ha.datDateofBirth,126) AS DateOfBirth
-- Mike Kornegay	12/10/2021 Changed procedure to use denormailized location table function.
-- Mike Kornegay	01/12/2022 Swapped where condition referring to gisLocation for new flat location hierarchy and corrected ISNULL
--							   check on PersonalTypeID and fixed where statements on left joins.
-- Mike Kornegay	04/27/2022 Added AddressID and ContactPhoneNbrTypeID to revert fields after accidental alter.
-- Mike Kornegay	05/06/2022 Changed inner join to left join on FN_GBL_LocationHierarchy_Flattened so results return if location is not
--								in FN_GBL_LocationHierarchy_Flattened.
-- Stephen Long     09/22/2022 Add check for "0" page size.  If "0", then set to 1.
-- Stephen Long     10/10/2022 Added monitoring session ID parameter and where criteria.
-- Ann Xiong		11/10/2022 Added SettlementTypeID parameter and where criteria.
-- Stephen Long     03/30/2023 Removed option recompile; performance improvement.
-- Ann Xiong		11/10/2022 Added SettlementTypeID parameter and where criteria. 
-- Stephen Long     03/30/2023 Removed option recompile; performance improvement.
-- Mani             03/31/2023 Changed the Location Joins to Inner Join as Location is a requied field
-- Stephen Long     05/08/2023 Added dbo prefix on flattened hierarchy.
-- Stephen Long     05/10/2023 Added record identifier search indicator logic.
--
/*Test Code

EXEC dbo.USP_HUM_HUMAN_MASTER_GETList
	@LangID = 'en-US',
	@FirstOrGivenName = 'a',
--	@idfsLocation = 1344330000000 -- region = Baku
	@idfsLocation = 4720500000000  -- Rayon = Pirallahi (Baku)

EXEC dbo.USP_HUM_HUMAN_MASTER_GETList
	@LangID = 'en-US',
	@FirstOrGivenName = 'a',
    @DateOfBirthFrom = '2010-12-30 00:00:00.000',
    @DateOfBirthTo = '2012-12-30 00:00:00.000',
	--@idfsLocation = 1344330000000, -- region = Baku
	@idfsLocation = 1344380000000, -- Rayon = Khatai (Baku)
	@pageSize = 50000 
---------

DECLARE @return_value int

EXEC    @return_value = [dbo].[USP_HUM_HUMAN_MASTER_GETList]
        @LangID = N'en-US',
        @EIDSSPersonID = NULL,
        @PersonalIDType = NULL,
        @PersonalID = NULL,
        @FirstOrGivenName = 'a',
        @SecondName = NULL,
        @LastOrSurname = NULL,
        @DateOfBirthFrom = '1976-02-04 00:00:00.000',
        @DateOfBirthTo = '1980-02-04 00:00:00.000',
        @GenderTypeID = NULL,
		@idfsLocation = 1344330000000, -- region = Baku
        @pageNo = 1,
        @pageSize = 10,
        @sortColumn = N'EIDSSPersonID',
        @sortOrder = N'asc'

SELECT  @return_value
*/
-- ================================================================================================
ALTER PROCEDURE [dbo].[USP_HUM_HUMAN_MASTER_GETList]
(
    @LangID NVARCHAR(50),
    @EIDSSPersonID NVARCHAR(200) = NULL,
    @PersonalIDType BIGINT = NULL,
    @PersonalID NVARCHAR(100) = NULL,
    @FirstOrGivenName NVARCHAR(200) = NULL,
    @SecondName NVARCHAR(200) = NULL,
    @LastOrSurname NVARCHAR(200) = NULL,
    @DateOfBirthFrom DATETIME = NULL,
    @DateOfBirthTo DATETIME = NULL,
    @GenderTypeID BIGINT = NULL,
    @idfsLocation BIGINT = NULL,
    @MonitoringSessionID BIGINT = NULL,
    @SettlementTypeID BIGINT = NULL,
    @RecordIdentifierSearchIndicator BIT = 0,
    @pageNo INT = 1,
    @pageSize INT = 10,
    @sortColumn NVARCHAR(30) = 'EIDSSPersonID',
    @sortOrder NVARCHAR(4) = 'DESC'
)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        DECLARE @firstRec INT
        DECLARE @lastRec INT

        IF @PageSize = 0
        BEGIN
            SET @PageSize = 1;
        END

        DECLARE @DOB DATETIME = NULL

        IF (@DateOfBirthTo IS NOT NULL AND @DateOfBirthTo = @DateOfBirthFrom)
            SET @DOB = @DateOfBirthFrom

        SET @firstRec = (@pageNo - 1) * @pagesize
        SET @lastRec = (@pageNo * @pageSize + 1);


        IF @RecordIdentifierSearchIndicator = 1
        BEGIN
            WITH CTEResults
            AS (SELECT ROW_NUMBER() OVER (ORDER BY CASE
                                                       WHEN @sortColumn = 'EIDSSPersonID'
                                                            AND @SortOrder = 'asc' THEN
                                                           hai.EIDSSPersonID
                                                   END ASC,
                                                   CASE
                                                       WHEN @sortColumn = 'EIDSSPersonID'
                                                            AND @SortOrder = 'desc' THEN
                                                           hai.EIDSSPersonID
                                                   END DESC,
                                                   CASE
                                                       WHEN @sortColumn = 'LastOrSurname'
                                                            AND @SortOrder = 'asc' THEN
                                                           ha.strLastName
                                                   END ASC,
                                                   CASE
                                                       WHEN @sortColumn = 'LastOrSurname'
                                                            AND @SortOrder = 'desc' THEN
                                                           ha.strLastName
                                                   END DESC,
                                                   CASE
                                                       WHEN @sortColumn = 'FirstOrGivenName'
                                                            AND @SortOrder = 'asc' THEN
                                                           ha.strFirstName
                                                   END ASC,
                                                   CASE
                                                       WHEN @sortColumn = 'FirstOrGivenName'
                                                            AND @SortOrder = 'desc' THEN
                                                           ha.strFirstName
                                                   END DESC,
                                                   CASE
                                                       WHEN @sortColumn = 'PersonalID'
                                                            AND @SortOrder = 'asc' THEN
                                                           ha.strPersonID
                                                   END ASC,
                                                   CASE
                                                       WHEN @sortColumn = 'PersonalID'
                                                            AND @SortOrder = 'desc' THEN
                                                           ha.strPersonID
                                                   END DESC,
                                                   CASE
                                                       WHEN @sortColumn = 'PersonIDTypeName'
                                                            AND @SortOrder = 'asc' THEN
                                                           idType.name
                                                   END ASC,
                                                   CASE
                                                       WHEN @sortColumn = 'PersonIDTypeName'
                                                            AND @SortOrder = 'desc' THEN
                                                           idType.name
                                                   END DESC,
                                                   CASE
                                                       WHEN @sortColumn = 'PassportNumber'
                                                            AND @SortOrder = 'asc' THEN
                                                           hai.PassportNbr
                                                   END ASC,
                                                   CASE
                                                       WHEN @sortColumn = 'PassportNumber'
                                                            AND @SortOrder = 'desc' THEN
                                                           hai.PassportNbr
                                                   END DESC,
                                                   CASE
                                                       WHEN @sortColumn = 'GenderTypeName'
                                                            AND @SortOrder = 'asc' THEN
                                                           genderType.name
                                                   END ASC,
                                                   CASE
                                                       WHEN @sortColumn = 'GenderTypeName'
                                                            AND @SortOrder = 'desc' THEN
                                                           genderType.name
                                                   END DESC,
                                                   CASE
                                                       WHEN @sortColumn = 'RayonName'
                                                            AND @SortOrder = 'asc' THEN
                                                           LH.AdminLevel3Name
                                                   END ASC,
                                                   CASE
                                                       WHEN @sortColumn = 'RayonName'
                                                            AND @SortOrder = 'desc' THEN
                                                           LH.AdminLevel3Name
                                                   END DESC,
                                                   CASE
                                                       WHEN @sortColumn = 'DateOfBirth'
                                                            AND @SortOrder = 'asc' THEN
                                                           ha.datDateofBirth
                                                   END ASC,
                                                   CASE
                                                       WHEN @sortColumn = 'DateOfBirth'
                                                            AND @SortOrder = 'desc' THEN
                                                           ha.datDateofBirth
                                                   END DESC
                                         ) AS ROWNUM,
                       COUNT(*) OVER () AS TotalRowCount,
                       ha.idfHumanActual AS HumanMasterID,
                       hai.EIDSSPersonID AS EIDSSPersonID,
                       ha.idfCurrentResidenceAddress AS AddressID,
                       ha.strFirstName AS FirstOrGivenName,
                       ha.strSecondName AS SecondName,
                       ha.strLastName AS LastOrSurname,
                       dbo.FN_GBL_ConcatFullName(ha.strLastName, ha.strFirstName, ha.strSecondName) AS FullName,
                       CONVERT(CHAR(10), ha.datDateofBirth, 126) AS DateOfBirth,
                       ha.strPersonID AS PersonalID,
                       ISNULL(idType.[name], idType.strDefault) AS PersonIDTypeName,
                       humanAddress.strStreetName AS StreetName,
                       dbo.FN_GBL_CreateAddressString(
                                                         LH.AdminLevel1Name,
                                                         LH.AdminLevel2Name,
                                                         LH.AdminLevel3Name,
                                                         humanAddress.strPostCode,
                                                         '',
                                                         LH.AdminLevel4Name,
                                                         humanAddress.strStreetName,
                                                         humanAddress.strHouse,
                                                         humanAddress.strBuilding,
                                                         humanAddress.strApartment,
                                                         humanAddress.blnForeignAddress,
                                                         ''
                                                     ) AS AddressString,
                       (CONVERT(NVARCHAR(100), humanAddress.dblLatitude) + ', '
                        + CONVERT(NVARCHAR(100), humanAddress.dblLongitude)
                       ) AS LongitudeLatitude,
                       hai.ContactPhoneCountryCode AS ContactPhoneCountryCode,
                       hai.ContactPhoneNbr AS ContactPhoneNumber,
                       hai.ContactPhoneNbrTypeID AS ContactPhoneNbrTypeID,
                       hai.ReportedAge AS Age,
                       hai.PassportNbr AS PassportNumber,
                       ha.idfsNationality AS CitizenshipTypeID,
                       citizenshipType.[name] AS CitizenshipTypeName,
                       ha.idfsHumanGender AS GenderTypeID,
                       genderType.[name] AS GenderTypeName,
                       humanAddress.idfsCountry AS CountryID,
                       LH.AdminLevel1Name AS CountryName,
                       LH.AdminLevel2ID AS RegionID,
                       LH.AdminLevel2Name AS RegionName,
                       LH.AdminLevel3ID AS RayonID,
                       LH.AdminLevel3Name AS RayonName,
                       humanAddress.idfsSettlement AS SettlementID,
                       LH.AdminLevel4Name AS SettlementName,
                       dbo.FN_GBL_CreateAddressString(
                                                         LH.AdminLevel1Name,
                                                         LH.AdminLevel2Name,
                                                         LH.AdminLevel3Name,
                                                         '',
                                                         '',
                                                         '',
                                                         '',
                                                         '',
                                                         '',
                                                         '',
                                                         humanAddress.blnForeignAddress,
                                                         humanAddress.strForeignAddress
                                                     ) AS FormattedAddressString
                FROM dbo.tlbHumanActual AS ha WITH (NOLOCK)
                    INNER JOIN dbo.HumanActualAddlInfo hai WITH (NOLOCK)
                        ON ha.idfHumanActual = hai.HumanActualAddlInfoUID
                           AND hai.intRowStatus = 0
                    LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LangID, 19000043) genderType
                        ON ha.idfsHumanGender = genderType.idfsReference
                           AND genderType.intRowStatus = 0
                    LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LangID, 19000148) idType
                        ON ha.idfsPersonIDType = idType.idfsReference
                           AND idType.intRowStatus = 0
                    LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LangID, 19000054) citizenshipType
                        ON ha.idfsNationality = citizenshipType.idfsReference
                           AND citizenshipType.intRowStatus = 0
                    INNER JOIN dbo.tlbGeoLocationShared humanAddress WITH (NOLOCK)
                        ON ha.idfCurrentResidenceAddress = humanAddress.idfGeoLocationShared
                           AND humanAddress.intRowStatus = 0
                    INNER JOIN dbo.gisLocation L WITH (NOLOCK)
                        ON L.idfsLocation = humanAddress.idfsLocation
                    INNER JOIN dbo.FN_GBL_LocationHierarchy_Flattened(@LangID) LH
                        ON LH.idfsLocation = humanAddress.idfsLocation
                WHERE (
                          ha.intRowStatus = 0
                          AND (
                                  (
                                      @EIDSSPersonID IS NOT NULL
                                      AND hai.EIDSSPersonID LIKE '%' + @EIDSSPersonID + '%'
                                  )
                                  OR @EIDSSPersonID IS NULL
                              )
                          AND (
                                  (
                                      @PersonalID IS NOT NULL
                                      AND ha.strPersonID LIKE '%' + @PersonalID + '%'
                                  )
                                  OR @PersonalID IS NULL
                              )
                      )
               )
            SELECT TotalRowCount,
                   HumanMasterID,
                   EIDSSPersonID,
                   AddressID,
                   FirstOrGivenName,
                   SecondName,
                   LastOrSurname,
                   FullName,
                   DateOfBirth,
                   PersonalID,
                   PersonIDTypeName,
                   StreetName,
                   AddressString,
                   LongitudeLatitude,
                   ContactPhoneCountryCode,
                   ContactPhoneNumber,
                   ContactPhoneNbrTypeID,
                   Age,
                   PassportNumber,
                   CitizenshipTypeID,
                   CitizenshipTypeName,
                   GenderTypeID,
                   GenderTypeName,
                   CountryID,
                   CountryName,
                   RegionID,
                   RegionName,
                   RayonID,
                   RayonName,
                   SettlementID,
                   SettlementName,
                   FormattedAddressString,
                   TotalPages = (TotalRowCount / @pageSize) + IIF(TotalRowCount % @pageSize > 0, 1, 0),
                   CurrentPage = @pageNo
            FROM CTEResults
            WHERE RowNum > @firstRec
                  AND RowNum < @lastRec;
        END
        ELSE
        BEGIN
            WITH CTEResults
            AS (SELECT ROW_NUMBER() OVER (ORDER BY CASE
                                                       WHEN @sortColumn = 'EIDSSPersonID'
                                                            AND @SortOrder = 'asc' THEN
                                                           hai.EIDSSPersonID
                                                   END ASC,
                                                   CASE
                                                       WHEN @sortColumn = 'EIDSSPersonID'
                                                            AND @SortOrder = 'desc' THEN
                                                           hai.EIDSSPersonID
                                                   END DESC,
                                                   CASE
                                                       WHEN @sortColumn = 'LastOrSurname'
                                                            AND @SortOrder = 'asc' THEN
                                                           ha.strLastName
                                                   END ASC,
                                                   CASE
                                                       WHEN @sortColumn = 'LastOrSurname'
                                                            AND @SortOrder = 'desc' THEN
                                                           ha.strLastName
                                                   END DESC,
                                                   CASE
                                                       WHEN @sortColumn = 'FirstOrGivenName'
                                                            AND @SortOrder = 'asc' THEN
                                                           ha.strFirstName
                                                   END ASC,
                                                   CASE
                                                       WHEN @sortColumn = 'FirstOrGivenName'
                                                            AND @SortOrder = 'desc' THEN
                                                           ha.strFirstName
                                                   END DESC,
                                                   CASE
                                                       WHEN @sortColumn = 'PersonalID'
                                                            AND @SortOrder = 'asc' THEN
                                                           ha.strPersonID
                                                   END ASC,
                                                   CASE
                                                       WHEN @sortColumn = 'PersonalID'
                                                            AND @SortOrder = 'desc' THEN
                                                           ha.strPersonID
                                                   END DESC,
                                                   CASE
                                                       WHEN @sortColumn = 'PersonIDTypeName'
                                                            AND @SortOrder = 'asc' THEN
                                                           idType.name
                                                   END ASC,
                                                   CASE
                                                       WHEN @sortColumn = 'PersonIDTypeName'
                                                            AND @SortOrder = 'desc' THEN
                                                           idType.name
                                                   END DESC,
                                                   CASE
                                                       WHEN @sortColumn = 'PassportNumber'
                                                            AND @SortOrder = 'asc' THEN
                                                           hai.PassportNbr
                                                   END ASC,
                                                   CASE
                                                       WHEN @sortColumn = 'PassportNumber'
                                                            AND @SortOrder = 'desc' THEN
                                                           hai.PassportNbr
                                                   END DESC,
                                                   CASE
                                                       WHEN @sortColumn = 'GenderTypeName'
                                                            AND @SortOrder = 'asc' THEN
                                                           genderType.name
                                                   END ASC,
                                                   CASE
                                                       WHEN @sortColumn = 'GenderTypeName'
                                                            AND @SortOrder = 'desc' THEN
                                                           genderType.name
                                                   END DESC,
                                                   CASE
                                                       WHEN @sortColumn = 'RayonName'
                                                            AND @SortOrder = 'asc' THEN
                                                           LH.AdminLevel3Name
                                                   END ASC,
                                                   CASE
                                                       WHEN @sortColumn = 'RayonName'
                                                            AND @SortOrder = 'desc' THEN
                                                           LH.AdminLevel3Name
                                                   END DESC,
                                                   CASE
                                                       WHEN @sortColumn = 'DateOfBirth'
                                                            AND @SortOrder = 'asc' THEN
                                                           ha.datDateofBirth
                                                   END ASC,
                                                   CASE
                                                       WHEN @sortColumn = 'DateOfBirth'
                                                            AND @SortOrder = 'desc' THEN
                                                           ha.datDateofBirth
                                                   END DESC
                                         ) AS ROWNUM,
                       COUNT(*) OVER () AS TotalRowCount,
                       ha.idfHumanActual AS HumanMasterID,
                       hai.EIDSSPersonID AS EIDSSPersonID,
                       ha.idfCurrentResidenceAddress AS AddressID,
                       ha.strFirstName AS FirstOrGivenName,
                       ha.strSecondName AS SecondName,
                       ha.strLastName AS LastOrSurname,
                       dbo.FN_GBL_ConcatFullName(ha.strLastName, ha.strFirstName, ha.strSecondName) AS FullName,
                       CONVERT(CHAR(10), ha.datDateofBirth, 126) AS DateOfBirth,
                       ha.strPersonID AS PersonalID,
                       ISNULL(idType.[name], idType.strDefault) AS PersonIDTypeName,
                       humanAddress.strStreetName AS StreetName,
                       dbo.FN_GBL_CreateAddressString(
                                                         LH.AdminLevel1Name,
                                                         LH.AdminLevel2Name,
                                                         LH.AdminLevel3Name,
                                                         humanAddress.strPostCode,
                                                         '',
                                                         LH.AdminLevel4Name,
                                                         humanAddress.strStreetName,
                                                         humanAddress.strHouse,
                                                         humanAddress.strBuilding,
                                                         humanAddress.strApartment,
                                                         humanAddress.blnForeignAddress,
                                                         ''
                                                     ) AS AddressString,
                       (CONVERT(NVARCHAR(100), humanAddress.dblLatitude) + ', '
                        + CONVERT(NVARCHAR(100), humanAddress.dblLongitude)
                       ) AS LongitudeLatitude,
                       hai.ContactPhoneCountryCode AS ContactPhoneCountryCode,
                       hai.ContactPhoneNbr AS ContactPhoneNumber,
                       hai.ContactPhoneNbrTypeID AS ContactPhoneNbrTypeID,
                       hai.ReportedAge AS Age,
                       hai.PassportNbr AS PassportNumber,
                       ha.idfsNationality AS CitizenshipTypeID,
                       citizenshipType.[name] AS CitizenshipTypeName,
                       ha.idfsHumanGender AS GenderTypeID,
                       genderType.[name] AS GenderTypeName,
                       humanAddress.idfsCountry AS CountryID,
                       LH.AdminLevel1Name AS CountryName,
                       LH.AdminLevel2ID AS RegionID,
                       LH.AdminLevel2Name AS RegionName,
                       LH.AdminLevel3ID AS RayonID,
                       LH.AdminLevel3Name AS RayonName,
                       humanAddress.idfsSettlement AS SettlementID,
                       LH.AdminLevel4Name AS SettlementName,
                       dbo.FN_GBL_CreateAddressString(
                                                         LH.AdminLevel1Name,
                                                         LH.AdminLevel2Name,
                                                         LH.AdminLevel3Name,
                                                         '',
                                                         '',
                                                         '',
                                                         '',
                                                         '',
                                                         '',
                                                         '',
                                                         humanAddress.blnForeignAddress,
                                                         humanAddress.strForeignAddress
                                                     ) AS FormattedAddressString
                FROM dbo.tlbHumanActual AS ha WITH (NOLOCK)
                    INNER JOIN dbo.HumanActualAddlInfo hai WITH (NOLOCK)
                        ON ha.idfHumanActual = hai.HumanActualAddlInfoUID
                           AND hai.intRowStatus = 0
                    LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LangID, 19000043) genderType
                        ON ha.idfsHumanGender = genderType.idfsReference
                           AND genderType.intRowStatus = 0
                    LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LangID, 19000148) idType
                        ON ha.idfsPersonIDType = idType.idfsReference
                           AND idType.intRowStatus = 0
                    LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LangID, 19000054) citizenshipType
                        ON ha.idfsNationality = citizenshipType.idfsReference
                           AND citizenshipType.intRowStatus = 0
                    INNER JOIN dbo.tlbGeoLocationShared humanAddress WITH (NOLOCK)
                        ON ha.idfCurrentResidenceAddress = humanAddress.idfGeoLocationShared
                           AND humanAddress.intRowStatus = 0
                    INNER JOIN dbo.gisLocation L WITH (NOLOCK)
                        ON L.idfsLocation = humanAddress.idfsLocation
                    INNER JOIN dbo.FN_GBL_LocationHierarchy_Flattened(@LangID) LH
                        ON LH.idfsLocation = humanAddress.idfsLocation
                WHERE (
                          ha.intRowStatus = 0
                          AND (
                                  (
                                      @idfsLocation IS NOT NULL
                                      AND (
                                              LH.AdminLevel1ID = @idfsLocation
                                              OR LH.AdminLevel2ID = @idfsLocation
                                              OR LH.AdminLevel3ID = @idfsLocation
                                              OR LH.AdminLevel4ID = @idfsLocation
                                              OR LH.AdminLevel5ID = @idfsLocation
                                              OR LH.AdminLevel6ID = @idfsLocation
                                              OR LH.AdminLevel7ID = @idfsLocation
                                          )
                                  )
                                  OR (@idfsLocation IS NULL)
                              )
                          AND (
                                  (
                                      @SettlementTypeID IS NOT NULL
                                      AND L.idfsType = @SettlementTypeID
                                  )
                                  OR (@SettlementTypeID IS NULL)
                              )
                          AND (
                                  @DOB = ha.datDateofBirth
                                  OR @DateOfBirthFrom IS NULL
                                  OR (ha.datDateofBirth
                      BETWEEN @DateOfBirthFrom AND @DateOfBirthTo
                                     )
                              )
                          AND (
                                  (
                                      @EIDSSPersonID IS NOT NULL
                                      AND hai.EIDSSPersonID LIKE '%' + @EIDSSPersonID + '%'
                                  )
                                  OR @EIDSSPersonID IS NULL
                              )
                          AND (
                                  (
                                      @PersonalID IS NOT NULL
                                      AND ha.strPersonID LIKE '%' + @PersonalID + '%'
                                  )
                                  OR @PersonalID IS NULL
                              )
                          AND (
                                  (
                                      @FirstOrGivenName IS NOT NULL
                                      AND ha.strFirstName LIKE '%' + @FirstOrGivenName + '%'
                                  )
                                  OR @FirstOrGivenName IS NULL
                              )
                          AND (
                                  (
                                      @SecondName IS NOT NULL
                                      AND ha.strSecondName LIKE '%' + @SecondName + '%'
                                  )
                                  OR @SecondName IS NULL
                              )
                          AND (
                                  (
                                      @LastOrSurname IS NOT NULL
                                      AND ha.strLastName LIKE '%' + @LastOrSurname + '%'
                                  )
                                  OR @LastOrSurname IS NULL
                              )
                          AND (
                                  (
                                      @PersonalIDType IS NOT NULL
                                      AND ha.idfsPersonIDType = @PersonalIDType
                                  )
                                  OR @PersonalIDType IS NULL
                              )
                          AND (
                                  (
                                      @GenderTypeID IS NOT NULL
                                      AND ha.idfsHumanGender = @GenderTypeID
                                  )
                                  OR @GenderTypeID IS NULL
                              )
                          AND (
                                  EXISTS
                (
                    SELECT h.idfHuman
                    FROM dbo.tlbHuman h
                        INNER JOIN dbo.tlbMaterial m
                            ON m.idfHuman = h.idfHuman
                    WHERE h.idfHumanActual = ha.idfHumanActual
                          AND m.idfMonitoringSession = @MonitoringSessionID
                )
                                  OR @MonitoringSessionID IS NULL
                              )
                      )
               )
            SELECT TotalRowCount,
                   HumanMasterID,
                   EIDSSPersonID,
                   AddressID,
                   FirstOrGivenName,
                   SecondName,
                   LastOrSurname,
                   FullName,
                   DateOfBirth,
                   PersonalID,
                   PersonIDTypeName,
                   StreetName,
                   AddressString,
                   LongitudeLatitude,
                   ContactPhoneCountryCode,
                   ContactPhoneNumber,
                   ContactPhoneNbrTypeID,
                   Age,
                   PassportNumber,
                   CitizenshipTypeID,
                   CitizenshipTypeName,
                   GenderTypeID,
                   GenderTypeName,
                   CountryID,
                   CountryName,
                   RegionID,
                   RegionName,
                   RayonID,
                   RayonName,
                   SettlementID,
                   SettlementName,
                   FormattedAddressString,
                   TotalPages = (TotalRowCount / @pageSize) + IIF(TotalRowCount % @pageSize > 0, 1, 0),
                   CurrentPage = @pageNo
            FROM CTEResults
            WHERE RowNum > @firstRec
                  AND RowNum < @lastRec;
        END
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH;
END;
GO
PRINT N'Altering Procedure [dbo].[USP_OMM_HUMAN_Case_GetDetail]...';


GO
-- ================================================================================================
-- Name: [USP_OMM_Case_GetDetail]
--
-- Description: Gets details on a human outbreak case record.
--
-- Author: Doug Albanese
--
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Doug Albanese	05/02/2022 New SP to separate request from common case details of 
--                             USP_OMM_Case_GetDetail
-- Doug Albanese	05/03/2022 Added disease id
-- Doug Albanese	05/04/2022 Adding "Text" version for Offices and Persons, for Select2 popuation
-- Doug Albanese	05/04/2022 Changed over to Location Hierarchy
-- Doug Albanese	05/04/2022 idfHumanCase added for reference within the shared HDR View Component
-- Doug Albanese	05/05/2022 Added Text for Select2 objects in Outbreak Investigation 
--                             (Organization/Person)
-- Doug Albanese	05/05/2022 Added Text for Outbreak Case Classification
-- Doug Albanese	05/05/2022 Corrected some Flex Form observations, and cleaned up output fields
-- Doug Albanese	05/06/2022 Added location information for Editing purposes
-- Doug Albanese	05/09/2022 Added OutbreakTypeId for Flex Form identification
-- Doug Albanese    10/25/2022 Swapped tlbHumanCase.idfEpiObservation with OutbreakCaseReport.
--                             OutbreakCaseObservationID
-- Stephen Long     05/17/2023 Fix for item 5584.
-- ================================================================================================
ALTER PROCEDURE [dbo].[USP_OMM_HUMAN_Case_GetDetail]
(
    @LangID NVARCHAR(50),
    @OutbreakCaseReportUID BIGINT = -1
)
AS
BEGIN
    DECLARE @returnCode INT = 0;
    DECLARE @returnMsg NVARCHAR(MAX) = 'SUCCESS';
    BEGIN TRY
        DECLARE @Antimicrobials NVARCHAR(MAX);
        DECLARE @Vaccinations NVARCHAR(MAX);
        DECLARE @Contacts NVARCHAR(MAX);
        DECLARE @Samples NVARCHAR(MAX);
        DECLARE @Tests NVARCHAR(MAX);
        DECLARE @CaseMonitorings NVARCHAR(MAX);
        DECLARE @idfHumanCase BIGINT;
        DECLARE @RelatedToIdentifiers TABLE
        (
            ID BIGINT NOT NULL,
            ReportID NVARCHAR(200) NOT NULL
        );
        SELECT @idfHumanCase = idfHumanCase
        FROM dbo.OutbreakCaseReport
        WHERE OutbreakCaseReportUID = @OutbreakCaseReportUID; --Obtain listing of Vaccinations for Json object

        DECLARE @CaseOutbreakSessionImportedIndicator INT = (
                                                                 SELECT CASE
                                                                            WHEN idfOutbreak IS NOT NULL
                                                                                 AND (strCaseID IS NOT NULL OR LegacyCaseID IS NOT NULL) THEN
                                                                                1
                                                                            ELSE
                                                                                0
                                                                        END
                                                                 FROM dbo.tlbHumanCase
                                                                 WHERE idfHumanCase = @idfHumanCase
                                                             );

        IF @CaseOutbreakSessionImportedIndicator = 1
        BEGIN
            DECLARE @RelatedToDiseaseReportID BIGINT = @idfHumanCase,
                    @ConnectedDiseaseReportID BIGINT;

            INSERT INTO @RelatedToIdentifiers
            SELECT idfHumanCase,
                   strCaseID
            FROM dbo.tlbHumanCase
            WHERE idfHumanCase = @idfHumanCase;

            WHILE EXISTS
        (
            SELECT *
            FROM dbo.HumanDiseaseReportRelationship
            WHERE HumanDiseaseReportID = @RelatedToDiseaseReportID
        )
            BEGIN
                INSERT INTO @RelatedToIdentifiers
                SELECT RelateToHumanDiseaseReportID,
                       strCaseID
                FROM dbo.HumanDiseaseReportRelationship
                    INNER JOIN dbo.tlbHumanCase
                        ON idfHumanCase = RelateToHumanDiseaseReportID
                WHERE HumanDiseaseReportID = @RelatedToDiseaseReportID;

                SET @RelatedToDiseaseReportID =
                (
                    SELECT RelateToHumanDiseaseReportID
                    FROM dbo.HumanDiseaseReportRelationship
                    WHERE HumanDiseaseReportID = @RelatedToDiseaseReportID
                );
            END
        END

        SET @Antimicrobials =
        (
            SELECT idfAntimicrobialTherapy,
                   datFirstAdministeredDate AS FirstAdministeredDate,
                   strAntimicrobialTherapyName AS AntimicrobialName,
                   strDosage AS AntimicrobialDose
            FROM dbo.tlbAntimicrobialTherapy
            WHERE intRowStatus = 0
                  AND idfHumanCase = @idfHumanCase
            FOR JSON PATH
        );

        --Obtain listing of Vaccinations for Json object
        SET @Vaccinations =
        (
            SELECT HumanDiseaseReportVaccinationUID,
                   VaccinationName,
                   VaccinationDate
            FROM dbo.HumanDiseaseReportVaccination
            WHERE intRowStatus = 0
                  AND idfHumanCase = @idfHumanCase
            FOR JSON PATH
        );

        --Obtain listing of Contacts for Json object
        SET @Contacts =
        (
            SELECT CCP.idfContactedCasePerson,                          --tlbContactedCasePerson Identity
                   OCC.OutbreakCaseContactUID,                          --OutbreakCaseContact Identity
                   OCC.OutBreakCaseReportUID,                           --(OutbreakCaseReport Identity) OutBreakCaseReport: OutBreakCaseReportUID
                   H.strFirstName + ' ' + H.strLastName AS ContactName, --tlbContactedCasePerson
                   OCC.ContactTypeID,                                   --"Contact Type" OutbreakCaseContact: ContactTypeID
                   CT.Name As ContactType,                              --"Contact Type" Text only for display
                   OCC.ContactRelationshipTypeID,                       --"Relation" OutbreakCaseContact: ContactRelationshipTypeID
                   CCP.idfsPersonContactType,                           --"Relation" tlbContactedCasePerson: idfsPersonContactType
                   Relation.Name AS Relation,                           --"Relation" Text only for display
                   OCC.DateOfLastContact AS datDateOfLastContact,       --"Date of Last Contact" OutbreakCaseContact: DateOfLastContact
                   OCC.PlaceOfLastContact AS strPlaceInfo,              --"Place of Last Contact" tlbContactedCasePerson: strPlaceInfo
                   OCC.ContactStatusID,                                 --"Contact Status" OutbreakCaseContact: ContactStatusID
                   CS.name AS ContactStatus,                            --"Contact Status" Text only for display
                   OCC.CommentText AS strComments,                      --"Comments" tlbContactedCasePerson: strComments
                   H.idfHumanActual,                                    --(Human Actual Identity) tlbHumanActual: idfHumanActual
                   OCC.ContactTracingObservationId AS idfObservation,   --Flex Form Observation Id
                   ft.idfsFormType
            FROM dbo.OutbreakCaseContact OCC
                LEFT JOIN dbo.tlbHuman H
                    ON H.idfHuman = OCC.idfHuman
                LEFT JOIN dbo.tlbContactedCasePerson CCP
                    ON CCP.idfContactedCasePerson = OCC.ContactedHumanCasePersonID
                LEFT JOIN dbo.FN_GBL_Reference_GETList(@langId, 19000014) Relation
                    ON Relation.idfsReference = OCC.ContactRelationshipTypeID
                LEFT JOIN dbo.FN_GBL_Reference_GETList(@langId, 19000517) CS
                    ON CS.idfsReference = OCC.ContactStatusID
                LEFT JOIN dbo.FN_GBL_Reference_GETList(@langId, 19000516) CT
                    ON CT.idfsReference = OCC.ContactTypeID
                LEFT JOIN dbo.tlbObservation o
                    ON o.idfObservation = occ.ContactTracingObservationID
                LEFT JOIN dbo.ffFormTemplate ft
                    ON ft.idfsFormTemplate = o.idfsFormTemplate
            WHERE OutBreakCaseReportUID = @OutbreakCaseReportUID
                  AND OCC.intRowStatus = 0
            FOR JSON PATH
        );

        --Obtain listing of Samples for Json Object
        SET @Samples =
        (
            SELECT m.idfMaterial,
                   m.idfsSampleType,
                   R.Name AS SampleType,
                   m.strFieldBarcode,
                   m.datFieldCollectionDate,
                   Coalesce(m.idfFieldCollectedByOffice, -1) AS idfFieldCollectedByOffice,
                   CO.name As CollectedByOffice,
                   --Coalesce(m.idfFieldCollectedByPerson,-1) AS idfFieldCollectedByPerson,
                   m.idfFieldCollectedByPerson,
                   Coalesce(prb.strFirstName + ' ' + prb.strFamilyName, '') As CollectedByPerson,
                   Coalesce(m.idfSendToOffice, -1) AS idfSendToOffice,
                   SO.name As SentToOffice,
                   Coalesce(m.strNote, '') AS strNote,
                   m.datFieldSentDate
            FROM dbo.OutbreakCaseReport ocr
                LEFT JOIN dbo.tlbHumanCase hc
                    ON hc.idfHumanCase = ocr.idfHumanCase
                LEFT JOIN dbo.tlbMaterial m
                    ON m.idfHumanCase = hc.idfHumanCase
                LEFT JOIN dbo.tlbOffice rbo
                    ON rbo.idfOffice = m.idfFieldCollectedByOffice
                LEFT JOIN dbo.tlbOffice rbo2
                    ON rbo2.idfOffice = m.idfSendToOffice
                LEFT JOIN dbo.tlbPerson prb
                    ON prb.idfPerson = m.idfFieldCollectedByPerson
                LEFT JOIN dbo.FN_GBL_Reference_GETList(@LangID, 19000046) CO
                    ON CO.idfsReference = rbo.idfsOfficeName
                LEFT JOIN dbo.FN_GBL_Reference_GETList(@LangID, 19000046) SO
                    ON SO.idfsReference = rbo2.idfsOfficeName
                LEFT JOIN dbo.FN_GBL_Reference_GETList(@LangID, 19000087) R
                    ON R.idfsReference = m.idfsSampleType
            WHERE ocr.OutBreakCaseReportUID = @OutbreakCaseReportUID
                  AND m.intRowStatus = 0
            FOR JSON PATH
        );

        SET @Tests =
        (
            SELECT t.idfTesting,
                   m.idfMaterial,
                   m.idfsSampleType,
                   m.strFieldBarcode,
                   m.strBarcode,
                   t.idfsTestName,
                   t.idfsTestResult,
                   t.idfsTestStatus,
                   t.datConcludedDate,
                   t.idfsTestCategory,
                   tv.idfsInterpretedStatus,
                   tv.strInterpretedComment,
                   tv.datInterpretationDate,
                   tv.idfInterpretedByPerson,
                   case tv.blnValidateStatus
                       when 1 then
                           1
                       else
                           0
                   end as blnValidateStatus,
                   tv.strValidateComment,
                   tv.datValidationDate,
                   tv.idfValidatedByPerson,
                   ST.name AS SampleType,
                   TN.name AS TestName,
                   TR.name AS TestResult,
                   TS.name AS TestStatus,
                   TC.name AS TestCategory,
                   ITS.name AS InterpretedStatus,
                   Coalesce(ibp.strFirstName + ' ' + ibp.strFamilyName, '') As InterpretedByPerson,
                   Coalesce(vbp.strFirstName + ' ' + vbp.strFamilyName, '') As ValidatedByPerson
            FROM dbo.OutbreakCaseReport OCR
                LEFT JOIN dbo.tlbHumanCase hc
                    ON hc.idfHumanCase = ocr.idfHumanCase
                LEFT JOIN dbo.tlbMaterial m
                    ON m.idfHumanCase = hc.idfHumanCase
                LEFT JOIN dbo.tlbTesting t
                    ON t.idfMaterial = m.idfMaterial
                LEFT JOIN dbo.tlbTestValidation tv
                    ON tv.idfTesting = t.idfTesting
                LEFT JOIN dbo.FN_GBL_Reference_GETList(@LangID, 19000087) ST
                    ON ST.idfsReference = m.idfsSampleType
                LEFT JOIN dbo.FN_GBL_Reference_GETList(@LangID, 19000097) TN
                    ON TN.idfsReference = t.idfsTestName
                LEFT JOIN dbo.FN_GBL_Reference_GETList(@LangID, 19000096) TR
                    ON TR.idfsReference = t.idfsTestResult
                LEFT JOIN dbo.FN_GBL_Reference_GETList(@LangID, 19000001) TS
                    ON TS.idfsReference = t.idfsTestStatus
                LEFT JOIN dbo.FN_GBL_Reference_GETList(@LangID, 19000095) TC
                    ON TC.idfsReference = t.idfsTestCategory
                LEFT JOIN dbo.FN_GBL_Reference_GETList(@LangID, 19000106) ITS
                    ON ITS.idfsReference = tv.idfsInterpretedStatus
                LEFT JOIN dbo.tlbPerson ibp
                    ON ibp.idfPerson = tv.idfInterpretedByPerson
                LEFT JOIN dbo.tlbPerson vbp
                    ON vbp.idfPerson = tv.idfValidatedByPerson
            WHERE OCR.OutBreakCaseReportUID = @OutBreakCaseReportUID
                  AND t.intRowStatus = 0
            FOR JSON PATH
        );

        SET @CaseMonitorings =
        (
            SELECT ocm.idfOutbreakCaseMonitoring,
                   ocm.idfObservation,
                   ocm.datMonitoringdate,
                   ocm.idfInvestigatedByOffice,
                   fcboName.name AS InvestigatedByOffice,
                   ocm.idfInvestigatedByPerson,
                   CONCAT(P.strFirstName, ' ', P.strFamilyName) AS InvestigatedByPerson,
                   ocm.strAdditionalComments,
                   ocm.intRowStatus,
                   ft.idfsFormType
            FROM dbo.tlbOutbreakCaseMonitoring ocm
                LEFT JOIN dbo.tlbOffice o
                    ON o.idfOffice = ocm.idfInvestigatedByOffice
                LEFT JOIN dbo.FN_GBL_Reference_GETList(@LangID, 19000045) fcboName
                    ON fcboName.idfsReference = o.idfsOfficeName
                LEFT JOIN dbo.tlbPerson P
                    ON P.idfPerson = ocm.idfInvestigatedByPerson
                LEFT JOIN dbo.tlbObservation OB
                    ON OB.idfObservation = ocm.idfObservation
                LEFT JOIN dbo.ffFormTemplate ft
                    ON ft.idfsFormTemplate = OB.idfsFormTemplate
            WHERE idfHumanCase = @idfHumanCase
                  AND ocm.intRowStatus = 0
            FOR JSON PATH
        );

        SELECT DISTINCT
            --General
            ocr.idfOutbreak,
            h.idfHumanActual,
            --Notification
            hc.datNotificationDate,
            hc.idfSentByOffice,
            SentByOffice.name AS SentByOffice,
            hc.idfSentByPerson,
            SentByPerson.strFirstName + ' ' + SentByPerson.strFamilyName AS SentByPerson,
            hc.idfReceivedByOffice,
            ReceivedByOffice.name AS ReceivedByOffice,
            hc.idfReceivedByPerson,
            ReceivedByPerson.strFirstName + ' ' + ReceivedByPerson.strFamilyName AS ReceivedByPerson,
            --Case Locatiton
            geo.idfGeoLocation,
            geo.idfsLocation,
            lh.AdminLevel1ID AS AdminLevel0Value,
            lh.AdminLevel2ID AS AdminLevel1Value,
            lh.AdminLevel2Name AS AdminLevel1Text,
            lh.AdminLevel3ID AS AdminLevel2Value,
            lh.AdminLevel3Name AS AdminLevel2Text,
            lh.AdminLevel4ID AS AdminLevel3Value,
            lh.AdminLevel4Name AS AdminLevel3Text,
            geo.strStreetName,
            geo.strPostCode,
            geo.strBuilding,
            geo.strHouse,
            geo.strApartment,
            geo.dblLatitude,
            geo.dblLongitude,
            --Clinical Information
            ocr.OutbreakCaseStatusID,
            OutbreakCaseStatus.Name AS OutbreakCaseStatusName,
            hc.datOnSetDate,
            hc.datFinalDiagnosisDate,
            hc.idfHospital,
            hc.datHospitalizationDate,
            hc.datDischargeDate,
            hc.strClinicalNotes,
            hc.strNote,
            @Antimicrobials AS Antimicrobials,
            @Vaccinations AS Vaccinations,
            --Outbreak Investigation
            hc.idfInvestigatedByOffice,
            InvestigatedByOffice.name AS InvestigatedByOffice,
            hc.idfInvestigatedByPerson,
            InvestigatedByPerson.strFirstName + ' ' + InvestigatedByPerson.strFamilyName AS InvestigatedByPerson,
            hc.datInvestigationStartDate,
            OCR.OutbreakCaseClassificationID,
            OutbreakClassification.name AS OutbreakCaseClassificationName,
            OCR.IsPrimaryCaseFlag,
            --Case Monitoring
            @CaseMonitorings AS CaseMonitorings,
            --Contacts
            @Contacts AS Contacts,
            --Samples
            hc.idfsYNSpecimenCollected,
            @Samples AS Samples,
            --Tests
            hc.idfsYNTestsConducted,
            @Tests AS Tests,
            hc.idfsYNAntimicrobialTherapy,
            hc.idfsYNHospitalization,
            hc.idfsYNSpecificVaccinationAdministered,
            --Outbreak Flex Forms
            OCR.OutbreakCaseObservationID,
            OCOFT.idfsFormType AS OutbreakCaseObservationFormType,
            OCR.CaseEPIObservationID,
            OCMFT.idfsFormType AS CaseEPIObservationFormType,
            ocr.OutbreakCaseObservationID AS idfEpiObservation,
            hc.idfCSObservation,
            o.idfsDiagnosisOrDiagnosisGroup,
            ocr.idfHumanCase,
            o.OutbreakTypeID,
            (SELECT STRING_AGG(ID, ', ') WITHIN GROUP (ORDER BY ReportID) AS Result
            FROM @RelatedToIdentifiers) AS RelatedToIdentifiers,
            (SELECT STRING_AGG(ReportID, ', ') WITHIN GROUP (ORDER BY ReportID) AS Result
            FROM @RelatedToIdentifiers) AS RelatedToReportIdentifiers
        FROM dbo.OutbreakCaseReport ocr
            LEFT JOIN dbo.tlbHumanCase hc
                ON hc.idfHumanCase = ocr.idfHumanCase
            LEFT JOIN dbo.tlbHuman h
                ON h.idfHuman = hc.idfHuman
            LEFT JOIN dbo.tlbHumanActual ha
                ON ha.idfHumanActual = h.idfHumanActual
            LEFT JOIN dbo.HumanActualAddlInfo haai
                ON haai.HumanActualAddlInfoUID = ha.idfHumanActual
            LEFT JOIN dbo.tlbOutbreak o
                ON o.idfOutbreak = OCR.idfOutbreak
            LEFT JOIN dbo.tlbGeoLocation geo
                ON h.idfCurrentResidenceAddress = geo.idfGeoLocation
            LEFT JOIN dbo.FN_GBL_LocationHierarchy_Flattened(@LangID) lh
                ON lh.idfsLocation = geo.idfsLocation
            LEFT JOIN dbo.tlbAntimicrobialTherapy amt
                ON amt.idfHumanCase = ocr.idfHumanCase
            LEFT JOIN dbo.HumanDiseaseReportVaccination hdrv
                ON hdrv.idfHumanCase = ocr.idfHumanCase
            LEFT JOIN dbo.tlbObservation OCO
                ON OCO.idfObservation = OCR.OutbreakCaseObservationID
            LEFT JOIN dbo.tlbObservation CMO
                ON CMO.idfObservation = OCR.CaseEPIObservationID
            LEFT JOIN dbo.ffFormTemplate OCOFT
                ON OCOFT.idfsFormTemplate = OCO.idfsFormTemplate
            LEFT JOIN dbo.ffFormTemplate OCMFT
                ON OCMFT.idfsFormTemplate = CMO.idfsFormTemplate
            LEFT JOIN dbo.tlbOffice SBO
                ON SBO.idfOffice = hc.idfSentByOffice
            LEFT JOIN dbo.FN_GBL_Reference_GETList(@LangID, 19000046) SentByOffice
                ON SentByOffice.idfsReference = SBO.idfsOfficeName
            LEFT JOIN dbo.tlbOffice RBO
                ON RBO.idfOffice = hc.idfReceivedByOffice
            LEFT JOIN dbo.FN_GBL_Reference_GETList(@LangID, 19000046) ReceivedByOffice
                ON ReceivedByOffice.idfsReference = RBO.idfsOfficeName
            LEFT JOIN dbo.tlbPerson SentByPerson
                ON SentByPerson.idfPerson = hc.idfSentByPerson
            LEFT JOIN dbo.tlbPerson ReceivedByPerson
                ON ReceivedByPerson.idfPerson = hc.idfReceivedByPerson
            LEFT JOIN dbo.tlbOffice IBO
                ON IBO.idfOffice = hc.idfInvestigatedByOffice
            LEFT JOIN dbo.FN_GBL_Reference_GETList(@LangID, 19000046) InvestigatedByOffice
                ON InvestigatedByOffice.idfsReference = IBO.idfsOfficeName
            LEFT JOIN dbo.tlbPerson InvestigatedByPerson
                ON InvestigatedByPerson.idfPerson = hc.idfInvestigatedByPerson
            LEFT JOIN dbo.FN_GBL_Reference_GETList(@langId, 19000011) OutbreakClassification
                ON OutbreakClassification.idfsReference = ocr.OutbreakCaseClassificationID
            LEFT JOIN dbo.FN_GBL_Reference_GETList(@langId, 19000520) OutbreakCaseStatus
                ON OutbreakCaseStatus.idfsReference = ocr.OutbreakCaseStatusID
        WHERE OCR.OutBreakCaseReportUID = @OutbreakCaseReportUID;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT = 1
            ROLLBACK;
        THROW;
    END CATCH
END
GO
PRINT N'Altering Procedure [dbo].[USP_OMM_HUMAN_DISEASE_SET]...';


GO
-- ================================================================================================
-- Name: USP_OMM_HUMAN_DISEASE_SET
--
-- Description:	Insert OR UPDATE human disease record
--          
-- Author: Doug Albanese
--
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Doug Albanese	02/2019    Created a shell of the Human Disease Report for Outbreak use only
-- Doug Albanese	05/21/2020 Removed the Case Monitoring SP call and moved it up to the parent 
--                             SP (USP_OMM_Case_Set)
-- Doug Albanese	10/12/2020 Corrected Audit information
-- Doug Albanese	04/19/2022 Refreshed this SP from the one used for "Human Disease Report". 
--                             This is a temporarly solution, until it is rewritten to use 
--                             Location Hierarchy
-- Doug Albanese	04/26/2022 Removed all supression, since the "INSERTS" of this SP are 3 levels 
--                             deep and only used by USP_OMM_Case_Set
-- Doug Albanese	05/06/2022 Added indicator for Tests conducted
-- Doug Albanese	03/10/2023 Added Data Auditing
-- Doug Albanese	04/28/2023 Removed suppression on USSP_GBL_DATA_AUDIT_EVENT_SET
-- Stephen Long     05/17/2023 Fix for item 5584.
-- ================================================================================================
ALTER PROCEDURE [dbo].[USP_OMM_HUMAN_DISEASE_SET]
(
    @idfHumanCase BIGINT = -1 OUTPUT,                     -- tlbHumanCase.idfHumanCase Primary Key`
    @idfHuman BIGINT = NULL,                              -- tlbHumanCase.idfHuman
    @strHumanCaseId NVARCHAR(200) = '(new)',
    @OutbreakCaseReportUID BIGINT = NULL,
    @idfHumanActual BIGINT,                               -- tlbHumanActual.idfHumanActual
    @idfsFinalDiagnosis BIGINT,                           -- tlbhumancase.idfsTentativeDiagnosis/idfsFinalDiagnosis
    @datDateOfDiagnosis DATETIME = NULL,                  --tlbHumanCase.datTentativeDiagnosisDate/datFinalDiagnosisDate
    @datNotificationDate DATETIME = NULL,                 --tlbHumanCase.DatNotIFicationDate
    @idfsFinalState BIGINT = NULL,                        --tlbHumanCase.idfsFinalState

    @idfSentByOffice BIGINT = NULL,                       -- tlbHumanCase.idfSentByOffice
    @strSentByFirstName NVARCHAR(200) = NULL,             --tlbHumanCase.strSentByFirstName
    @strSentByPatronymicName NVARCHAR(200) = NULL,        --tlbHumancase.strSentByPatronymicName
    @strSentByLastName NVARCHAR(200) = NULL,              --tlbHumanCase.strSentByLastName
    @idfSentByPerson BIGINT = NULL,                       --tlbHumcanCase.idfSentByPerson

    @idfReceivedByOffice BIGINT = NULL,                   -- tlbHumanCase.idfReceivedByOffice
    @strReceivedByFirstName NVARCHAR(200) = NULL,         --tlbHumanCase.strReceivedByFirstName
    @strReceivedByPatronymicName NVARCHAR(200) = NULL,    --tlbHumanCase.strReceivedByPatronymicName
    @strReceivedByLastName NVARCHAR(200) = NULL,          --tlbHuanCase.strReceivedByLastName
    @idfReceivedByPerson BIGINT = NULL,                   -- tlbHumanCase.idfReceivedByPerson

    @idfsHospitalizationStatus BIGINT = NULL,             -- tlbHumanCase.idfsHospitalizationStatus
    @idfHospital BIGINT = NULL,                           -- tlbHumanCase.idfHospital
    @strCurrentLocation NVARCHAR(200) = NULL,             -- tlbHumanCase.strCurrentLocation
    @datOnSetDate DATETIME = NULL,                        -- tlbHumanCase.datOnSetDate
    @idfsInitialCaseStatus BIGINT = NULL,                 -- tlbHumanCase.idfsInitialCaseStatus
    @idfsYNPreviouslySoughtCare BIGINT = NULL,            --idfsYNPreviouslySoughtCare
    @datFirstSoughtCareDate DATETIME = NULL,              --tlbHumanCase.datFirstSoughtCareDate
    @idfSoughtCareFacility BIGINT = NULL,                 --tlbHumanCase.idfSoughtCareFacility
    @idfsNonNotIFiableDiagnosis BIGINT = NULL,            --tlbHumanCase.idfsNonNotIFiableDiagnosis
    @idfsYNHospitalization BIGINT = NULL,                 -- tlbHumanCase.idfsYNHospitalization
    @datHospitalizationDate DATETIME = NULL,              --tlbHumanCase.datHospitalizationDate 
    @datDischargeDate DATETIME = NULL,                    -- tlbHumanCase.datDischargeDate
    @strHospitalName NVARCHAR(200) = NULL,                --tlbHumanCase.strHospitalizationPlace  
    @idfsYNAntimicrobialTherapy BIGINT = NULL,            --  tlbHumanCase.idfsYNAntimicrobialTherapy 
    @strAntibioticName NVARCHAR(200) = NULL,              -- tlbHumanCase.strAntimicrobialTherapyName
    @strDosage NVARCHAR(200) = NULL,                      --tlbHumanCase.strDosage
    @datFirstAdministeredDate DATETIME = NULL,            -- tlbHumanCase.datFirstAdministeredDate
    @strClinicalNotes NVARCHAR(500) = NULL,               -- tlbHumanCase.strClinicalNotes , or strSummaryNotes
    @strNote NVARCHAR(500) = NULL,                        -- tlbHumanCase.strNote
    @idfsYNSpecIFicVaccinationAdministered BIGINT = NULL, --  tlbHumanCase.idfsYNSpecIFicVaccinationAdministered
    @idfInvestigatedByOffice BIGINT = NULL,               -- tlbHumanCase.idfInvestigatedByOffice 
    @idfInvestigatedByPerson BIGINT = NULL,
    @StartDateofInvestigation DATETIME = NULL,            -- tlbHumanCase.datInvestigationStartDate
    @idfsYNRelatedToOutbreak BIGINT = NULL,               -- tlbHumanCase.idfsYNRelatedToOutbreak
    @idfOutbreak BIGINT = NULL,                           --idfOutbreak  
    @idfsYNExposureLocationKnown BIGINT = NULL,           --tlbHumanCase.idfsYNExposureLocationKnown
    @idfPointGeoLocation BIGINT = NULL,                   --tlbHumanCase.idfPointGeoLocation
    @datExposureDate DATETIME = NULL,                     -- tlbHumanCase.datExposureDate 
    @strLocationDescription NVARCHAR(MAX) = NULL,         --tlbGeolocation.Description

    @CaseGeoLocationID BIGINT = NULL,
    @CaseidfsLocation BIGINT = NULL,
    @CasestrStreetName NVARCHAR(200) = NULL,
    @CasestrApartment NVARCHAR(200) = NULL,
    @CasestrBuilding NVARCHAR(200) = NULL,
    @CasestrHouse NVARCHAR(200) = NULL,
    @CaseidfsPostalCode NVARCHAR(200) = NULL,
    @CasestrLatitude FLOAT = NULL,
    @CasestrLongitude FLOAT = NULL,
    @CasestrElevation FLOAT = NULL,
    @idfsLocationGroundType BIGINT = NULL,                --tlbGeolocation.GroundType
    @intLocationDistance FLOAT = NULL,                    --tlbGeolocation.Distance
    @idfsFinalCaseStatus BIGINT = NULL,                   --tlbHuanCase.idfsFinalCaseStatus 
    @idfsOutcome BIGINT = NULL,                           -- --tlbHumanCase.idfsOutcome 
    @datDateofDeath DATETIME = NULL,                      -- tlbHumanCase.datDateOfDeath 
    @idfsCaseProgressStatus BIGINT = 10109001,            --	tlbHumanCase.reportStatus, default = In-process
    @idfPersonEnteredBy BIGINT = NULL,
    @idfsYNSpecimenCollected BIGINT = NULL,
    @DiseaseReportTypeID BIGINT = NULL,
    @blnClinicalDiagBasis BIT = NULL,
    @blnLabDiagBasis BIT = NULL,
    @blnEpiDiagBasis BIT = NULL,
    @DateofClassification DATETIME = NULL,
    @strSummaryNotes NVARCHAR(MAX) = NULL,
    @idfEpiObservation BIGINT = NULL,
    @idfCSObservation BIGINT = NULL,
    @SamplesParameters NVARCHAR(MAX) = NULL,
    @TestsParameters NVARCHAR(MAX) = NULL,
    @idfsYNTestsConducted BIGINT = NULL,
    @AntiviralTherapiesParameters NVARCHAR(MAX) = NULL,
    @VaccinationsParameters NVARCHAR(MAX) = NULL,
    @CaseMonitoringsParameters NVARCHAR(MAX) = NULL,
    @ContactsParameters NVARCHAR(MAX) = NULL,
    @strStreetName NVARCHAR(200) = NULL,
    @strHouse NVARCHAR(200) = NULL,
    @strBuilding NVARCHAR(200) = NULL,
    @strApartment NVARCHAR(200) = NULL,
    @strPostalCode NVARCHAR(200) = NULL,
    @User NVARCHAR(100) = NULL
)
AS
DECLARE @returnCode INT = 0;
DECLARE @ReturnMessage NVARCHAR(MAX) = 'SUCCESS';

BEGIN
    BEGIN TRY
        BEGIN TRANSACTION
        -- Data audit Declarations (Start)
        DECLARE @AuditUserID BIGINT = NULL;
        DECLARE @AuditSiteID BIGINT = NULL;
        DECLARE @DataAuditEventID BIGINT = NULL;
        DECLARE @DataAuditEventTypeID BIGINT = NULL;
        DECLARE @ObjectTypeID BIGINT = 10017080;
        DECLARE @ObjectID BIGINT = @idfOutbreak;
        DECLARE @ObjectTableID BIGINT = 75610000000;
        -- Data audit Declarations (End)

        -- Data audit UserInfo (Start)
        -- Get and set user and site identifiers
        SELECT @AuditUserID = userInfo.UserId,
               @AuditSiteID = userInfo.SiteId
        FROM dbo.FN_UserSiteInformation(@User) userInfo;
        -- Data audit UserInfo (End)

        --Data Audit Before Edit Table (Start)
        DECLARE @HumanCaseBeforeEdit TABLE
        (
            blnClinicalDiagBasis BIT,
            blnEpiDiagBasis BIT,
            blnLabDiagBasis BIT,
            datCompletionPaperFormDate DATETIME,
            datDischargeDate DATETIME,
            datExposureDate DATETIME,
            datFacilityLastVisit DATETIME,
            datFinalDiagnosisDate DATETIME,
            datHospitalizationDate DATETIME,
            datInvestigationStartDate DATETIME,
            datModificationDate DATETIME,
            datTentativeDiagnosisDate DATETIME,
            idfHumanCase BIGINT,
            idfInvestigatedByOffice BIGINT,
            idfPointGeoLocation BIGINT,
            idfReceivedByOffice BIGINT,
            idfsFinalDiagnosis BIGINT,
            idfsFinalState BIGINT,
            idfsHospitalizationStatus BIGINT,
            idfsHumanAgeType BIGINT,
            idfsInitialCaseStatus BIGINT,
            idfsOutcome BIGINT,
            idfsTentativeDiagnosis BIGINT,
            idfsYNAntimicrobialTherapy BIGINT,
            idfsYNHospitalization BIGINT,
            idfsYNRelatedToOutbreak BIGINT,
            idfsYNSpecimenCollected BIGINT,
            intPatientAge INT,
            strClinicalDiagnosis NVARCHAR(2000),
            strCurrentLocation NVARCHAR(2000),
            strEpidemiologistsName NVARCHAR(2000),
            strHospitalizationPlace NVARCHAR(2000),
            strLocalIdentifier NVARCHAR(2000),
            strNotCollectedReason NVARCHAR(2000),
            strNote NVARCHAR(2000),
            strReceivedByFirstName NVARCHAR(2000),
            strReceivedByLastName NVARCHAR(2000),
            strReceivedByPatronymicName NVARCHAR(2000),
            strSentByFirstName NVARCHAR(2000),
            strSentByLastName NVARCHAR(2000),
            strSentByPatronymicName NVARCHAR(2000),
            strSoughtCareFacility NVARCHAR(2000),
            idfsFinalCaseStatus BIGINT,
            idfSentByOffice BIGINT,
            idfEpiObservation BIGINT,
            idfCSObservation BIGINT,
            idfDeduplicationResultCase BIGINT,
            datNotificationDate DATETIME,
            datFirstSoughtCareDate DATETIME,
            datOnSetDate DATETIME,
            strClinicalNotes NVARCHAR(2000),
            strSummaryNotes NVARCHAR(2000),
            idfHuman BIGINT,
            idfPersonEnteredBy BIGINT,
            idfSentByPerson BIGINT,
            idfReceivedByPerson BIGINT,
            idfInvestigatedByPerson BIGINT,
            idfsYNTestsConducted BIGINT,
            idfSoughtCareFacility BIGINT,
            idfsNonNotifiableDiagnosis BIGINT,
            idfsNotCollectedReason BIGINT,
            idfOutbreak BIGINT,
            datEnteredDate DATETIME,
            strCaseID NVARCHAR(200),
            idfsCaseProgressStatus BIGINT,
            strSampleNotes NVARCHAR(2000),
            uidOfflineCaseID UNIQUEIDENTIFIER,
            datFinalCaseClassificationDate DATETIME,
            idfHospital BIGINT
        );
        --Data Audit Before Edit Table (End)

        --Data Audit After Edit Table (Start)
        DECLARE @HumanCaseAfterEdit TABLE
        (
            blnClinicalDiagBasis BIT,
            blnEpiDiagBasis BIT,
            blnLabDiagBasis BIT,
            datCompletionPaperFormDate DATETIME,
            datDischargeDate DATETIME,
            datExposureDate DATETIME,
            datFacilityLastVisit DATETIME,
            datFinalDiagnosisDate DATETIME,
            datHospitalizationDate DATETIME,
            datInvestigationStartDate DATETIME,
            datModificationDate DATETIME,
            datTentativeDiagnosisDate DATETIME,
            idfHumanCase BIGINT,
            idfInvestigatedByOffice BIGINT,
            idfPointGeoLocation BIGINT,
            idfReceivedByOffice BIGINT,
            idfsFinalDiagnosis BIGINT,
            idfsFinalState BIGINT,
            idfsHospitalizationStatus BIGINT,
            idfsHumanAgeType BIGINT,
            idfsInitialCaseStatus BIGINT,
            idfsOutcome BIGINT,
            idfsTentativeDiagnosis BIGINT,
            idfsYNAntimicrobialTherapy BIGINT,
            idfsYNHospitalization BIGINT,
            idfsYNRelatedToOutbreak BIGINT,
            idfsYNSpecimenCollected BIGINT,
            intPatientAge INT,
            strClinicalDiagnosis NVARCHAR(2000),
            strCurrentLocation NVARCHAR(2000),
            strEpidemiologistsName NVARCHAR(2000),
            strHospitalizationPlace NVARCHAR(2000),
            strLocalIdentifier NVARCHAR(2000),
            strNotCollectedReason NVARCHAR(2000),
            strNote NVARCHAR(2000),
            strReceivedByFirstName NVARCHAR(2000),
            strReceivedByLastName NVARCHAR(2000),
            strReceivedByPatronymicName NVARCHAR(2000),
            strSentByFirstName NVARCHAR(2000),
            strSentByLastName NVARCHAR(2000),
            strSentByPatronymicName NVARCHAR(2000),
            strSoughtCareFacility NVARCHAR(2000),
            idfsFinalCaseStatus BIGINT,
            idfSentByOffice BIGINT,
            idfEpiObservation BIGINT,
            idfCSObservation BIGINT,
            idfDeduplicationResultCase BIGINT,
            datNotificationDate DATETIME,
            datFirstSoughtCareDate DATETIME,
            datOnSetDate DATETIME,
            strClinicalNotes NVARCHAR(2000),
            strSummaryNotes NVARCHAR(2000),
            idfHuman BIGINT,
            idfPersonEnteredBy BIGINT,
            idfSentByPerson BIGINT,
            idfReceivedByPerson BIGINT,
            idfInvestigatedByPerson BIGINT,
            idfsYNTestsConducted BIGINT,
            idfSoughtCareFacility BIGINT,
            idfsNonNotifiableDiagnosis BIGINT,
            idfsNotCollectedReason BIGINT,
            idfOutbreak BIGINT,
            datEnteredDate DATETIME,
            strCaseID NVARCHAR(200),
            idfsCaseProgressStatus BIGINT,
            strSampleNotes NVARCHAR(2000),
            uidOfflineCaseID UNIQUEIDENTIFIER,
            datFinalCaseClassificationDate DATETIME,
            idfHospital BIGINT
        );
        --Data Audit After Edit Table (End)

        DECLARE @SupressSelect TABLE
        (
            ReturnCode INT,
            ReturnMessage VARCHAR(200)
        );
        DECLARE @SupressSelectHumanCase TABLE
        (
            ReturnCode INT,
            ReturnMessage VARCHAR(200),
            idfHumanCase BIGINT
        );
        DECLARE @COPYHUMANACTUALTOHUMAN_ReturnCode INT = 0;

        EXECUTE dbo.USP_OMM_COPYHUMANACTUALTOHUMAN @idfHumanActual,
                                                   @idfHuman OUTPUT;

        EXECUTE dbo.USSP_GBL_ADDRESS_SET @GeolocationID = @CaseGeoLocationID OUTPUT,
                                         @ResidentTypeID = NULL,
                                         @GroundTypeID = NULL,
                                         @GeolocationTypeID = NULL,
                                         @LocationID = @CaseidfsLocation,
                                         @Apartment = @CasestrApartment,
                                         @Building = @CasestrBuilding,
                                         @StreetName = @CasestrStreetName,
                                         @House = @CasestrHouse,
                                         @PostalCodeString = @CaseidfsPostalCode,
                                         @DescriptionString = NULL,
                                         @Distance = NULL,
                                         @Latitude = @CasestrLatitude,
                                         @Longitude = @CasestrLongitude,
                                         @Elevation = @CasestrElevation,
                                         @Accuracy = NULL,
                                         @Alignment = NULL,
                                         @ForeignAddressIndicator = null,
                                         @ForeignAddressString = null,
                                         @GeolocationSharedIndicator = 0,
                                         @AuditUserName = @User,
                                         @ReturnCode = @ReturnCode OUTPUT,
                                         @ReturnMessage = @ReturnMessage OUTPUT;

        IF NOT EXISTS
        (
            SELECT idfHumanCase
            FROM dbo.tlbHumanCase
            WHERE idfHumanCase = @idfHumanCase
        )
        BEGIN
            -- Get next key value
            EXECUTE dbo.USP_GBL_NEXTKEYID_GET 'tlbHumanCase', @idfHumanCase OUTPUT;

            -- Data audit (Create)
            SET @DataAuditEventTypeID = 10016001; -- Data audit create event type

            EXECUTE dbo.USSP_GBL_DATA_AUDIT_EVENT_SET @AuditUserID,
                                                      @AuditSiteID,
                                                      @DataAuditEventTypeID,
                                                      @ObjectTypeID,
                                                      @idfHumanCase,
                                                      @ObjectTableID,
                                                      @strHumanCaseID,
                                                      @DataAuditEventID OUTPUT;

            -- Data audit (Create)
            INSERT INTO dbo.tlbHumanCase
            (
                idfHumanCase,
                idfHuman,
                strCaseId,
                idfsFinalDiagnosis,
                datFinalDiagnosisDate,
                datNotIFicationDate,
                idfsFinalState,
                idfSentByOffice,
                strSentByFirstName,
                strSentByPatronymicName,
                strSentByLastName,
                idfSentByPerson,
                idfReceivedByOffice,
                strReceivedByFirstName,
                strReceivedByPatronymicName,
                strReceivedByLastName,
                idfReceivedByPerson,
                idfsHospitalizationStatus,
                idfHospital,
                strCurrentLocation,
                datOnSetDate,
                idfsInitialCaseStatus,
                idfsYNPreviouslySoughtCare,
                datFirstSoughtCareDate,
                idfSoughtCareFacility,
                idfsNonNotIFiableDiagnosis,
                idfsYNHospitalization,
                datHospitalizationDate,
                datDischargeDate,
                strHospitalizationPlace,
                idfsYNAntimicrobialTherapy,
                strClinicalNotes,
                strNote,
                idfsYNSpecIFicVaccinationAdministered,
                idfInvestigatedByOffice,
                idfInvestigatedByPerson,
                datInvestigationStartDate,
                idfsYNRelatedToOutbreak,
                idfOutbreak,
                idfsYNExposureLocationKnown,
                datExposureDate,
                idfsFinalCaseStatus,
                idfsOutcome,
                intRowStatus,
                idfsCaseProgressStatus,
                datModificationDate,
                datEnteredDate,
                idfPersonEnteredBy,
                idfsYNSpecimenCollected,
                DiseaseReportTypeID,
                blnClinicalDiagBasis,
                blnLabDiagBasis,
                blnEpiDiagBasis,
                datFinalCaseClassificationDate,
                strsummarynotes,
                idfEpiObservation,
                idfCSObservation,
                idfsYNTestsConducted,
                AuditCreateUser,
                AuditCreateDTM
            )
            VALUES
            (@idfHumanCase,
             @idfHuman,
             @strHumanCaseId,
             @idfsFinalDiagnosis,
             @datDateOfDiagnosis,
             @datNotificationDate,
             @idfsFinalState,
             @idfSentByOffice,
             @strSentByFirstName,
             @strSentByPatronymicName,
             @strSentByLastName,
             @idfSentByPerson,
             @idfReceivedByOffice,
             @strReceivedByFirstName,
             @strReceivedByPatronymicName,
             @strReceivedByLastName,
             @idfReceivedByPerson,
             @idfsHospitalizationStatus,
             @idfHospital,
             @strCurrentLocation,
             @datOnSetDate,
             @idfsInitialCaseStatus,
             @idfsYNPreviouslySoughtCare,
             @datFirstSoughtCareDate,
             @idfSoughtCareFacility,
             @idfsNonNotIFiableDiagnosis,
             @idfsYNHospitalization,
             @datHospitalizationDate,
             @datDischargeDate,
             @strHospitalName,
             @idfsYNAntimicrobialTherapy,
             @strClinicalNotes,
             @strNote,
             @idfsYNSpecIFicVaccinationAdministered,
             @idfInvestigatedByOffice,
             @idfInvestigatedByPerson,
             @StartDateofInvestigation,
             @idfsYNRelatedToOutbreak,
             @idfOutbreak,
             @idfsYNExposureLocationKnown,
             @datExposureDate,
             @idfsFinalCaseStatus,
             @idfsOutcome,
             0  ,
             @idfsCaseProgressStatus,
             GETDATE(),
             GETDATE(),
             @idfPersonEnteredBy,
             @idfsYNSpecimenCollected,
             @DiseaseReportTypeID,
             @blnClinicalDiagBasis,
             @blnLabDiagBasis,
             @blnEpiDiagBasis,
             @DateofClassification,
             @strSummaryNotes,
             @idfEpiObservation,
             @idfCSObservation,
             @idfsYNTestsConducted,
             @User,
             GETDATE()
            );
        END
        ELSE
        BEGIN
            -- Data audit Edit (Start)
            SET @DataAuditEventTypeID = 10016003; -- Data audit edit event type
            SELECT @strHumanCaseId = strOutbreakCaseID
            FROM dbo.OutbreakCaseReport
            WHERE idfHumanCase = @idfHumanCase;

            EXECUTE dbo.USSP_GBL_DATA_AUDIT_EVENT_SET @AuditUserID,
                                                      @AuditSiteID,
                                                      @DataAuditEventTypeID,
                                                      @ObjectTypeID,
                                                      @idfHumanCase,
                                                      @ObjectTableID,
                                                      @strHumanCaseId,
                                                      @DataAuditEventID OUTPUT;
            -- Data audit Edit (End)

            --Date Audit Collect Record Details Before Update (Start)
            INSERT INTO @HumanCaseBeforeEdit
            (
                blnClinicalDiagBasis,
                blnEpiDiagBasis,
                blnLabDiagBasis,
                datCompletionPaperFormDate,
                datDischargeDate,
                datExposureDate,
                datFacilityLastVisit,
                datFinalDiagnosisDate,
                datHospitalizationDate,
                datInvestigationStartDate,
                datModificationDate,
                datTentativeDiagnosisDate,
                idfHumanCase,
                idfInvestigatedByOffice,
                idfPointGeoLocation,
                idfReceivedByOffice,
                idfsFinalDiagnosis,
                idfsFinalState,
                idfsHospitalizationStatus,
                idfsHumanAgeType,
                idfsInitialCaseStatus,
                idfsOutcome,
                idfsTentativeDiagnosis,
                idfsYNAntimicrobialTherapy,
                idfsYNHospitalization,
                idfsYNRelatedToOutbreak,
                idfsYNSpecimenCollected,
                intPatientAge,
                strClinicalDiagnosis,
                strCurrentLocation,
                strEpidemiologistsName,
                strHospitalizationPlace,
                strLocalIdentifier,
                strNotCollectedReason,
                strNote,
                strReceivedByFirstName,
                strReceivedByLastName,
                strReceivedByPatronymicName,
                strSentByFirstName,
                strSentByLastName,
                strSentByPatronymicName,
                strSoughtCareFacility,
                idfsFinalCaseStatus,
                idfSentByOffice,
                idfEpiObservation,
                idfCSObservation,
                idfDeduplicationResultCase,
                datNotificationDate,
                datFirstSoughtCareDate,
                datOnSetDate,
                strClinicalNotes,
                strSummaryNotes,
                idfHuman,
                idfPersonEnteredBy,
                idfSentByPerson,
                idfReceivedByPerson,
                idfInvestigatedByPerson,
                idfsYNTestsConducted,
                idfSoughtCareFacility,
                idfsNonNotifiableDiagnosis,
                idfsNotCollectedReason,
                idfOutbreak,
                datEnteredDate,
                strCaseID,
                idfsCaseProgressStatus,
                strSampleNotes,
                uidOfflineCaseID,
                datFinalCaseClassificationDate,
                idfHospital
            )
            SELECT blnClinicalDiagBasis,
                   blnEpiDiagBasis,
                   blnLabDiagBasis,
                   datCompletionPaperFormDate,
                   datDischargeDate,
                   datExposureDate,
                   datFacilityLastVisit,
                   datFinalDiagnosisDate,
                   datHospitalizationDate,
                   datInvestigationStartDate,
                   datModificationDate,
                   datTentativeDiagnosisDate,
                   idfHumanCase,
                   idfInvestigatedByOffice,
                   idfPointGeoLocation,
                   idfReceivedByOffice,
                   idfsFinalDiagnosis,
                   idfsFinalState,
                   idfsHospitalizationStatus,
                   idfsHumanAgeType,
                   idfsInitialCaseStatus,
                   idfsOutcome,
                   idfsTentativeDiagnosis,
                   idfsYNAntimicrobialTherapy,
                   idfsYNHospitalization,
                   idfsYNRelatedToOutbreak,
                   idfsYNSpecimenCollected,
                   intPatientAge,
                   strClinicalDiagnosis,
                   strCurrentLocation,
                   strEpidemiologistsName,
                   strHospitalizationPlace,
                   strLocalIdentifier,
                   strNotCollectedReason,
                   strNote,
                   strReceivedByFirstName,
                   strReceivedByLastName,
                   strReceivedByPatronymicName,
                   strSentByFirstName,
                   strSentByLastName,
                   strSentByPatronymicName,
                   strSoughtCareFacility,
                   idfsFinalCaseStatus,
                   idfSentByOffice,
                   idfEpiObservation,
                   idfCSObservation,
                   idfDeduplicationResultCase,
                   datNotificationDate,
                   datFirstSoughtCareDate,
                   datOnSetDate,
                   strClinicalNotes,
                   strSummaryNotes,
                   idfHuman,
                   idfPersonEnteredBy,
                   idfSentByPerson,
                   idfReceivedByPerson,
                   idfInvestigatedByPerson,
                   idfsYNTestsConducted,
                   idfSoughtCareFacility,
                   idfsNonNotifiableDiagnosis,
                   idfsNotCollectedReason,
                   idfOutbreak,
                   datEnteredDate,
                   strCaseID,
                   idfsCaseProgressStatus,
                   strSampleNotes,
                   uidOfflineCaseID,
                   datFinalCaseClassificationDate,
                   idfHospital
            FROM dbo.tlbHumanCase
            WHERE idfHumanCase = @idfHumanCase;
            --Date Audit Collect Record Details Before Update (End)

            UPDATE dbo.tlbHumanCase
            SET idfsTentativeDiagnosis = @idfsFinalDiagnosis,
                idfsFinalDiagnosis = @idfsFinalDiagnosis,
                datFinalDiagnosisDate = @datDateOfDiagnosis,
                datNotIFicationDate = @datNotificationDate,
                idfsFinalState = @idfsFinalState,
                idfSentByOffice = @idfSentByOffice,
                strSentByFirstName = @strSentByFirstName,
                strSentByPatronymicName = @strSentByPatronymicName,
                strSentByLastName = @strSentByLastName,
                idfSentByPerson = @idfSentByPerson,
                idfReceivedByOffice = @idfReceivedByOffice,
                strReceivedByFirstName = @strReceivedByFirstName,
                strReceivedByPatronymicName = @strReceivedByPatronymicName,
                strReceivedByLastName = @strReceivedByLastName,
                idfReceivedByPerson = @idfReceivedByPerson,
                idfsHospitalizationStatus = @idfsHospitalizationStatus,
                idfHospital = @idfHospital,
                strCurrentLocation = @strCurrentLocation,
                datOnSetDate = @datOnSetDate,
                idfsInitialCaseStatus = @idfsInitialCaseStatus,
                idfsYNPreviouslySoughtCare = @idfsYNPreviouslySoughtCare,
                datFirstSoughtCareDate = @datFirstSoughtCareDate,
                idfSoughtCareFacility = @idfSoughtCareFacility,
                idfsNonNotIFiableDiagnosis = @idfsNonNotIFiableDiagnosis,
                idfsYNHospitalization = @idfsYNHospitalization,
                datHospitalizationDate = @datHospitalizationDate,
                datDischargeDate = @datDischargeDate,
                strHospitalizationPlace = @strHospitalName,
                idfsYNAntimicrobialTherapy = @idfsYNAntimicrobialTherapy,
                strClinicalNotes = @strClinicalNotes,
                strNote = @strNote,
                idfsYNSpecIFicVaccinationAdministered = @idfsYNSpecIFicVaccinationAdministered,
                idfInvestigatedByOffice = @idfInvestigatedByOffice,
                idfInvestigatedByPerson = @idfInvestigatedByPerson,
                datInvestigationStartDate = @StartDateofInvestigation,
                idfsYNRelatedToOutbreak = @idfsYNRelatedToOutbreak,
                idfOutbreak = @idfOutbreak,
                idfsYNExposureLocationKnown = @idfsYNExposureLocationKnown,
                datExposureDate = @datExposureDate,
                idfsFinalCaseStatus = @idfsFinalCaseStatus,
                idfsOutcome = @idfsOutcome,
                idfsCaseProgressStatus = @idfsCaseProgressStatus,
                datModificationDate = GETDATE(),
                idfsYNSpecimenCollected = @idfsYNSpecimenCollected,
                idfsYNTestsConducted = @idfsYNTestsConducted,
                DiseaseReportTypeID = @DiseaseReportTypeID,
                blnClinicalDiagBasis = @blnClinicalDiagBasis,
                blnLabDiagBasis = @blnLabDiagBasis,
                blnEpiDiagBasis = @blnEpiDiagBasis,
                datFinalCaseClassificationDate = @DateofClassification,
                strsummarynotes = @strSummaryNotes,
                idfEpiObservation = @idfEpiObservation,
                idfCSObservation = @idfCSObservation,
                idfHuman = @idfHuman,
                AuditUpdateUser = @User,
                AuditUpdateDTM = GETDATE()
            WHERE idfHumanCase = @idfHumanCase;

            --Date Audit Collect Record Details After Update (Start)
            INSERT INTO @HumanCaseAfterEdit
            (
                blnClinicalDiagBasis,
                blnEpiDiagBasis,
                blnLabDiagBasis,
                datCompletionPaperFormDate,
                datDischargeDate,
                datExposureDate,
                datFacilityLastVisit,
                datFinalDiagnosisDate,
                datHospitalizationDate,
                datInvestigationStartDate,
                datModificationDate,
                datTentativeDiagnosisDate,
                idfHumanCase,
                idfInvestigatedByOffice,
                idfPointGeoLocation,
                idfReceivedByOffice,
                idfsFinalDiagnosis,
                idfsFinalState,
                idfsHospitalizationStatus,
                idfsHumanAgeType,
                idfsInitialCaseStatus,
                idfsOutcome,
                idfsTentativeDiagnosis,
                idfsYNAntimicrobialTherapy,
                idfsYNHospitalization,
                idfsYNRelatedToOutbreak,
                idfsYNSpecimenCollected,
                intPatientAge,
                strClinicalDiagnosis,
                strCurrentLocation,
                strEpidemiologistsName,
                strHospitalizationPlace,
                strLocalIdentifier,
                strNotCollectedReason,
                strNote,
                strReceivedByFirstName,
                strReceivedByLastName,
                strReceivedByPatronymicName,
                strSentByFirstName,
                strSentByLastName,
                strSentByPatronymicName,
                strSoughtCareFacility,
                idfsFinalCaseStatus,
                idfSentByOffice,
                idfEpiObservation,
                idfCSObservation,
                idfDeduplicationResultCase,
                datNotificationDate,
                datFirstSoughtCareDate,
                datOnSetDate,
                strClinicalNotes,
                strSummaryNotes,
                idfHuman,
                idfPersonEnteredBy,
                idfSentByPerson,
                idfReceivedByPerson,
                idfInvestigatedByPerson,
                idfsYNTestsConducted,
                idfSoughtCareFacility,
                idfsNonNotifiableDiagnosis,
                idfsNotCollectedReason,
                idfOutbreak,
                datEnteredDate,
                strCaseID,
                idfsCaseProgressStatus,
                strSampleNotes,
                uidOfflineCaseID,
                datFinalCaseClassificationDate,
                idfHospital
            )
            SELECT blnClinicalDiagBasis,
                   blnEpiDiagBasis,
                   blnLabDiagBasis,
                   datCompletionPaperFormDate,
                   datDischargeDate,
                   datExposureDate,
                   datFacilityLastVisit,
                   datFinalDiagnosisDate,
                   datHospitalizationDate,
                   datInvestigationStartDate,
                   datModificationDate,
                   datTentativeDiagnosisDate,
                   idfHumanCase,
                   idfInvestigatedByOffice,
                   idfPointGeoLocation,
                   idfReceivedByOffice,
                   idfsFinalDiagnosis,
                   idfsFinalState,
                   idfsHospitalizationStatus,
                   idfsHumanAgeType,
                   idfsInitialCaseStatus,
                   idfsOutcome,
                   idfsTentativeDiagnosis,
                   idfsYNAntimicrobialTherapy,
                   idfsYNHospitalization,
                   idfsYNRelatedToOutbreak,
                   idfsYNSpecimenCollected,
                   intPatientAge,
                   strClinicalDiagnosis,
                   strCurrentLocation,
                   strEpidemiologistsName,
                   strHospitalizationPlace,
                   strLocalIdentifier,
                   strNotCollectedReason,
                   strNote,
                   strReceivedByFirstName,
                   strReceivedByLastName,
                   strReceivedByPatronymicName,
                   strSentByFirstName,
                   strSentByLastName,
                   strSentByPatronymicName,
                   strSoughtCareFacility,
                   idfsFinalCaseStatus,
                   idfSentByOffice,
                   idfEpiObservation,
                   idfCSObservation,
                   idfDeduplicationResultCase,
                   datNotificationDate,
                   datFirstSoughtCareDate,
                   datOnSetDate,
                   strClinicalNotes,
                   strSummaryNotes,
                   idfHuman,
                   idfPersonEnteredBy,
                   idfSentByPerson,
                   idfReceivedByPerson,
                   idfInvestigatedByPerson,
                   idfsYNTestsConducted,
                   idfSoughtCareFacility,
                   idfsNonNotifiableDiagnosis,
                   idfsNotCollectedReason,
                   idfOutbreak,
                   datEnteredDate,
                   strCaseID,
                   idfsCaseProgressStatus,
                   strSampleNotes,
                   uidOfflineCaseID,
                   datFinalCaseClassificationDate,
                   idfHospital
            FROM dbo.tlbHumanCase
            WHERE idfHumanCase = @idfHumanCase;
            --Date Audit Collect Record Details After Update (End)

            --Date Audit Create Entry For Any Changes Made (Start)
            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue,
                AuditCreateUser,
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   79490000000, --blnClinicalDiagBasis
                   a.idfHumanCase,
                   NULL,
                   b.blnClinicalDiagBasis,
                   a.blnClinicalDiagBasis,
                   @User,
                   @idfHumanCase
            FROM @HumanCaseAfterEdit AS a
                FULL JOIN @HumanCaseBeforeEdit AS b
                    ON a.idfHumanCase = b.idfHumanCase
            WHERE (a.blnClinicalDiagBasis <> b.blnClinicalDiagBasis)
                  OR (
                         a.blnClinicalDiagBasis IS NOT NULL
                         AND b.blnClinicalDiagBasis IS NULL
                     )
                  OR (
                         a.blnClinicalDiagBasis IS NULL
                         AND b.blnClinicalDiagBasis IS NOT NULL
                     );

            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue,
                AuditCreateUser,
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   79500000000, --blnEpiDiagBasis
                   a.idfHumanCase,
                   NULL,
                   b.blnEpiDiagBasis,
                   a.blnEpiDiagBasis,
                   @User,
                   @idfHumanCase
            FROM @HumanCaseAfterEdit AS a
                FULL JOIN @HumanCaseBeforeEdit AS b
                    ON a.idfHumanCase = b.idfHumanCase
            WHERE (a.blnEpiDiagBasis <> b.blnEpiDiagBasis)
                  OR (
                         a.blnEpiDiagBasis IS NOT NULL
                         AND b.blnEpiDiagBasis IS NULL
                     )
                  OR (
                         a.blnEpiDiagBasis IS NULL
                         AND b.blnEpiDiagBasis IS NOT NULL
                     );

            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue,
                AuditCreateUser,
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   79510000000, --blnLabDiagBasis
                   a.idfHumanCase,
                   NULL,
                   b.blnLabDiagBasis,
                   a.blnLabDiagBasis,
                   @User,
                   @idfHumanCase
            FROM @HumanCaseAfterEdit AS a
                FULL JOIN @HumanCaseBeforeEdit AS b
                    ON a.idfHumanCase = b.idfHumanCase
            WHERE (a.blnLabDiagBasis <> b.blnLabDiagBasis)
                  OR (
                         a.blnLabDiagBasis IS NOT NULL
                         AND b.blnLabDiagBasis IS NULL
                     )
                  OR (
                         a.blnLabDiagBasis IS NULL
                         AND b.blnLabDiagBasis IS NOT NULL
                     );

            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue,
                AuditCreateUser,
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   79520000000, --datCompletionPaperFormDate
                   a.idfHumanCase,
                   NULL,
                   b.datCompletionPaperFormDate,
                   a.datCompletionPaperFormDate,
                   @User,
                   @idfHumanCase
            FROM @HumanCaseAfterEdit AS a
                FULL JOIN @HumanCaseBeforeEdit AS b
                    ON a.idfHumanCase = b.idfHumanCase
            WHERE (a.datCompletionPaperFormDate <> b.datCompletionPaperFormDate)
                  OR (
                         a.datCompletionPaperFormDate IS NOT NULL
                         AND b.datCompletionPaperFormDate IS NULL
                     )
                  OR (
                         a.datCompletionPaperFormDate IS NULL
                         AND b.datCompletionPaperFormDate IS NOT NULL
                     );

            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue,
                AuditCreateUser,
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   79530000000, --datDischargeDate
                   a.idfHumanCase,
                   NULL,
                   b.datDischargeDate,
                   a.datDischargeDate,
                   @User,
                   @idfHumanCase
            FROM @HumanCaseAfterEdit AS a
                FULL JOIN @HumanCaseBeforeEdit AS b
                    ON a.idfHumanCase = b.idfHumanCase
            WHERE (a.datDischargeDate <> b.datDischargeDate)
                  OR (
                         a.datDischargeDate IS NOT NULL
                         AND b.datDischargeDate IS NULL
                     )
                  OR (
                         a.datDischargeDate IS NULL
                         AND b.datDischargeDate IS NOT NULL
                     );

            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue,
                AuditCreateUser,
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   79540000000, --datExposureDate
                   a.idfHumanCase,
                   NULL,
                   b.datExposureDate,
                   a.datExposureDate,
                   @User,
                   @idfHumanCase
            FROM @HumanCaseAfterEdit AS a
                FULL JOIN @HumanCaseBeforeEdit AS b
                    ON a.idfHumanCase = b.idfHumanCase
            WHERE (a.datExposureDate <> b.datExposureDate)
                  OR (
                         a.datExposureDate IS NOT NULL
                         AND b.datExposureDate IS NULL
                     )
                  OR (
                         a.datExposureDate IS NULL
                         AND b.datExposureDate IS NOT NULL
                     );

            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue,
                AuditCreateUser,
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   79550000000, --datFacilityLastVisit
                   a.idfHumanCase,
                   NULL,
                   b.datFacilityLastVisit,
                   a.datFacilityLastVisit,
                   @User,
                   @idfHumanCase
            FROM @HumanCaseAfterEdit AS a
                FULL JOIN @HumanCaseBeforeEdit AS b
                    ON a.idfHumanCase = b.idfHumanCase
            WHERE (a.datFacilityLastVisit <> b.datFacilityLastVisit)
                  OR (
                         a.datFacilityLastVisit IS NOT NULL
                         AND b.datFacilityLastVisit IS NULL
                     )
                  OR (
                         a.datFacilityLastVisit IS NULL
                         AND b.datFacilityLastVisit IS NOT NULL
                     );

            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue,
                AuditCreateUser,
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   79560000000, --datFinalDiagnosisDate
                   a.idfHumanCase,
                   NULL,
                   b.datFinalDiagnosisDate,
                   a.datFinalDiagnosisDate,
                   @User,
                   @idfHumanCase
            FROM @HumanCaseAfterEdit AS a
                FULL JOIN @HumanCaseBeforeEdit AS b
                    ON a.idfHumanCase = b.idfHumanCase
            WHERE (a.datFinalDiagnosisDate <> b.datFinalDiagnosisDate)
                  OR (
                         a.datFinalDiagnosisDate IS NOT NULL
                         AND b.datFinalDiagnosisDate IS NULL
                     )
                  OR (
                         a.datFinalDiagnosisDate IS NULL
                         AND b.datFinalDiagnosisDate IS NOT NULL
                     );

            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue,
                AuditCreateUser,
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   79570000000, --datHospitalizationDate
                   a.idfHumanCase,
                   NULL,
                   b.datHospitalizationDate,
                   a.datHospitalizationDate,
                   @User,
                   @idfHumanCase
            FROM @HumanCaseAfterEdit AS a
                FULL JOIN @HumanCaseBeforeEdit AS b
                    ON a.idfHumanCase = b.idfHumanCase
            WHERE (a.datHospitalizationDate <> b.datHospitalizationDate)
                  OR (
                         a.datHospitalizationDate IS NOT NULL
                         AND b.datHospitalizationDate IS NULL
                     )
                  OR (
                         a.datHospitalizationDate IS NULL
                         AND b.datHospitalizationDate IS NOT NULL
                     );

            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue,
                AuditCreateUser,
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   79580000000, --datInvestigationStartDate
                   a.idfHumanCase,
                   NULL,
                   b.datInvestigationStartDate,
                   a.datInvestigationStartDate,
                   @User,
                   @idfHumanCase
            FROM @HumanCaseAfterEdit AS a
                FULL JOIN @HumanCaseBeforeEdit AS b
                    ON a.idfHumanCase = b.idfHumanCase
            WHERE (a.datInvestigationStartDate <> b.datInvestigationStartDate)
                  OR (
                         a.datInvestigationStartDate IS NOT NULL
                         AND b.datInvestigationStartDate IS NULL
                     )
                  OR (
                         a.datInvestigationStartDate IS NULL
                         AND b.datInvestigationStartDate IS NOT NULL
                     );

            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue,
                AuditCreateUser,
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   79590000000, --datModificationDate
                   a.idfHumanCase,
                   NULL,
                   b.datModificationDate,
                   a.datModificationDate,
                   @User,
                   @idfHumanCase
            FROM @HumanCaseAfterEdit AS a
                FULL JOIN @HumanCaseBeforeEdit AS b
                    ON a.idfHumanCase = b.idfHumanCase
            WHERE (a.datModificationDate <> b.datModificationDate)
                  OR (
                         a.datModificationDate IS NOT NULL
                         AND b.datModificationDate IS NULL
                     )
                  OR (
                         a.datModificationDate IS NULL
                         AND b.datModificationDate IS NOT NULL
                     );

            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue,
                AuditCreateUser,
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   79600000000, --datTentativeDiagnosisDate
                   a.idfHumanCase,
                   NULL,
                   b.datTentativeDiagnosisDate,
                   a.datTentativeDiagnosisDate,
                   @User,
                   @idfHumanCase
            FROM @HumanCaseAfterEdit AS a
                FULL JOIN @HumanCaseBeforeEdit AS b
                    ON a.idfHumanCase = b.idfHumanCase
            WHERE (a.datTentativeDiagnosisDate <> b.datTentativeDiagnosisDate)
                  OR (
                         a.datTentativeDiagnosisDate IS NOT NULL
                         AND b.datTentativeDiagnosisDate IS NULL
                     )
                  OR (
                         a.datTentativeDiagnosisDate IS NULL
                         AND b.datTentativeDiagnosisDate IS NOT NULL
                     );

            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue,
                AuditCreateUser,
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   79610000000, --idfHumanCase
                   a.idfHumanCase,
                   NULL,
                   b.idfHumanCase,
                   a.idfHumanCase,
                   @User,
                   @idfHumanCase
            FROM @HumanCaseAfterEdit AS a
                FULL JOIN @HumanCaseBeforeEdit AS b
                    ON a.idfHumanCase = b.idfHumanCase
            WHERE (a.idfHumanCase <> b.idfHumanCase)
                  OR (
                         a.idfHumanCase IS NOT NULL
                         AND b.idfHumanCase IS NULL
                     )
                  OR (
                         a.idfHumanCase IS NULL
                         AND b.idfHumanCase IS NOT NULL
                     );

            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue,
                AuditCreateUser,
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   79620000000, --idfInvestigatedByOffice
                   a.idfHumanCase,
                   NULL,
                   b.idfInvestigatedByOffice,
                   a.idfInvestigatedByOffice,
                   @User,
                   @idfHumanCase
            FROM @HumanCaseAfterEdit AS a
                FULL JOIN @HumanCaseBeforeEdit AS b
                    ON a.idfHumanCase = b.idfHumanCase
            WHERE (a.idfInvestigatedByOffice <> b.idfInvestigatedByOffice)
                  OR (
                         a.idfInvestigatedByOffice IS NOT NULL
                         AND b.idfInvestigatedByOffice IS NULL
                     )
                  OR (
                         a.idfInvestigatedByOffice IS NULL
                         AND b.idfInvestigatedByOffice IS NOT NULL
                     );

            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue,
                AuditCreateUser,
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   79630000000, --idfPointGeoLocation
                   a.idfHumanCase,
                   NULL,
                   b.idfPointGeoLocation,
                   a.idfPointGeoLocation,
                   @User,
                   @idfHumanCase
            FROM @HumanCaseAfterEdit AS a
                FULL JOIN @HumanCaseBeforeEdit AS b
                    ON a.idfHumanCase = b.idfHumanCase
            WHERE (a.idfPointGeoLocation <> b.idfPointGeoLocation)
                  OR (
                         a.idfPointGeoLocation IS NOT NULL
                         AND b.idfPointGeoLocation IS NULL
                     )
                  OR (
                         a.idfPointGeoLocation IS NULL
                         AND b.idfPointGeoLocation IS NOT NULL
                     );

            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue,
                AuditCreateUser,
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   79640000000, --idfReceivedByOffice
                   a.idfHumanCase,
                   NULL,
                   b.idfReceivedByOffice,
                   a.idfReceivedByOffice,
                   @User,
                   @idfHumanCase
            FROM @HumanCaseAfterEdit AS a
                FULL JOIN @HumanCaseBeforeEdit AS b
                    ON a.idfHumanCase = b.idfHumanCase
            WHERE (a.idfReceivedByOffice <> b.idfReceivedByOffice)
                  OR (
                         a.idfReceivedByOffice IS NOT NULL
                         AND b.idfReceivedByOffice IS NULL
                     )
                  OR (
                         a.idfReceivedByOffice IS NULL
                         AND b.idfReceivedByOffice IS NOT NULL
                     );

            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue,
                AuditCreateUser,
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   79660000000, --idfsFinalDiagnosis
                   a.idfHumanCase,
                   NULL,
                   b.idfsFinalDiagnosis,
                   a.idfsFinalDiagnosis,
                   @User,
                   @idfHumanCase
            FROM @HumanCaseAfterEdit AS a
                FULL JOIN @HumanCaseBeforeEdit AS b
                    ON a.idfHumanCase = b.idfHumanCase
            WHERE (a.idfsFinalDiagnosis <> b.idfsFinalDiagnosis)
                  OR (
                         a.idfsFinalDiagnosis IS NOT NULL
                         AND b.idfsFinalDiagnosis IS NULL
                     )
                  OR (
                         a.idfsFinalDiagnosis IS NULL
                         AND b.idfsFinalDiagnosis IS NOT NULL
                     );

            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue,
                AuditCreateUser,
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   79670000000, --idfsFinalState
                   a.idfHumanCase,
                   NULL,
                   b.idfsFinalState,
                   a.idfsFinalState,
                   @User,
                   @idfHumanCase
            FROM @HumanCaseAfterEdit AS a
                FULL JOIN @HumanCaseBeforeEdit AS b
                    ON a.idfHumanCase = b.idfHumanCase
            WHERE (a.idfsFinalState <> b.idfsFinalState)
                  OR (
                         a.idfsFinalState IS NOT NULL
                         AND b.idfsFinalState IS NULL
                     )
                  OR (
                         a.idfsFinalState IS NULL
                         AND b.idfsFinalState IS NOT NULL
                     );

            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue,
                AuditCreateUser,
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   79680000000, --idfsHospitalizationStatus
                   a.idfHumanCase,
                   NULL,
                   b.idfsHospitalizationStatus,
                   a.idfsHospitalizationStatus,
                   @User,
                   @idfHumanCase
            FROM @HumanCaseAfterEdit AS a
                FULL JOIN @HumanCaseBeforeEdit AS b
                    ON a.idfHumanCase = b.idfHumanCase
            WHERE (a.idfsHospitalizationStatus <> b.idfsHospitalizationStatus)
                  OR (
                         a.idfsHospitalizationStatus IS NOT NULL
                         AND b.idfsHospitalizationStatus IS NULL
                     )
                  OR (
                         a.idfsHospitalizationStatus IS NULL
                         AND b.idfsHospitalizationStatus IS NOT NULL
                     );

            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue,
                AuditCreateUser,
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   79690000000, --idfsHumanAgeType
                   a.idfHumanCase,
                   NULL,
                   b.idfsHumanAgeType,
                   a.idfsHumanAgeType,
                   @User,
                   @idfHumanCase
            FROM @HumanCaseAfterEdit AS a
                FULL JOIN @HumanCaseBeforeEdit AS b
                    ON a.idfHumanCase = b.idfHumanCase
            WHERE (a.idfsHumanAgeType <> b.idfsHumanAgeType)
                  OR (
                         a.idfsHumanAgeType IS NOT NULL
                         AND b.idfsHumanAgeType IS NULL
                     )
                  OR (
                         a.idfsHumanAgeType IS NULL
                         AND b.idfsHumanAgeType IS NOT NULL
                     );

            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue,
                AuditCreateUser,
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   79700000000, --idfsInitialCaseStatus
                   a.idfHumanCase,
                   NULL,
                   b.idfsInitialCaseStatus,
                   a.idfsInitialCaseStatus,
                   @User,
                   @idfHumanCase
            FROM @HumanCaseAfterEdit AS a
                FULL JOIN @HumanCaseBeforeEdit AS b
                    ON a.idfHumanCase = b.idfHumanCase
            WHERE (a.idfsInitialCaseStatus <> b.idfsInitialCaseStatus)
                  OR (
                         a.idfsInitialCaseStatus IS NOT NULL
                         AND b.idfsInitialCaseStatus IS NULL
                     )
                  OR (
                         a.idfsInitialCaseStatus IS NULL
                         AND b.idfsInitialCaseStatus IS NOT NULL
                     );

            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue,
                AuditCreateUser,
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   79710000000, --idfsOutcome
                   a.idfHumanCase,
                   NULL,
                   b.idfsOutcome,
                   a.idfsOutcome,
                   @User,
                   @idfHumanCase
            FROM @HumanCaseAfterEdit AS a
                FULL JOIN @HumanCaseBeforeEdit AS b
                    ON a.idfHumanCase = b.idfHumanCase
            WHERE (a.idfsOutcome <> b.idfsOutcome)
                  OR (
                         a.idfsOutcome IS NOT NULL
                         AND b.idfsOutcome IS NULL
                     )
                  OR (
                         a.idfsOutcome IS NULL
                         AND b.idfsOutcome IS NOT NULL
                     );

            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue,
                AuditCreateUser,
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   79720000000, --idfsTentativeDiagnosis
                   a.idfHumanCase,
                   NULL,
                   b.idfsTentativeDiagnosis,
                   a.idfsTentativeDiagnosis,
                   @User,
                   @idfHumanCase
            FROM @HumanCaseAfterEdit AS a
                FULL JOIN @HumanCaseBeforeEdit AS b
                    ON a.idfHumanCase = b.idfHumanCase
            WHERE (a.idfsTentativeDiagnosis <> b.idfsTentativeDiagnosis)
                  OR (
                         a.idfsTentativeDiagnosis IS NOT NULL
                         AND b.idfsTentativeDiagnosis IS NULL
                     )
                  OR (
                         a.idfsTentativeDiagnosis IS NULL
                         AND b.idfsTentativeDiagnosis IS NOT NULL
                     );

            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue,
                AuditCreateUser,
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   79730000000, --idfsYNAntimicrobialTherapy
                   a.idfHumanCase,
                   NULL,
                   b.idfsYNAntimicrobialTherapy,
                   a.idfsYNAntimicrobialTherapy,
                   @User,
                   @idfHumanCase
            FROM @HumanCaseAfterEdit AS a
                FULL JOIN @HumanCaseBeforeEdit AS b
                    ON a.idfHumanCase = b.idfHumanCase
            WHERE (a.idfsYNAntimicrobialTherapy <> b.idfsYNAntimicrobialTherapy)
                  OR (
                         a.idfsYNAntimicrobialTherapy IS NOT NULL
                         AND b.idfsYNAntimicrobialTherapy IS NULL
                     )
                  OR (
                         a.idfsYNAntimicrobialTherapy IS NULL
                         AND b.idfsYNAntimicrobialTherapy IS NOT NULL
                     );

            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue,
                AuditCreateUser,
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   79740000000, --idfsYNHospitalization
                   a.idfHumanCase,
                   NULL,
                   b.idfsYNHospitalization,
                   a.idfsYNHospitalization,
                   @User,
                   @idfHumanCase
            FROM @HumanCaseAfterEdit AS a
                FULL JOIN @HumanCaseBeforeEdit AS b
                    ON a.idfHumanCase = b.idfHumanCase
            WHERE (a.idfsYNHospitalization <> b.idfsYNHospitalization)
                  OR (
                         a.idfsYNHospitalization IS NOT NULL
                         AND b.idfsYNHospitalization IS NULL
                     )
                  OR (
                         a.idfsYNHospitalization IS NULL
                         AND b.idfsYNHospitalization IS NOT NULL
                     );

            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue,
                AuditCreateUser,
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   79750000000, --idfsYNRelatedToOutbreak
                   a.idfHumanCase,
                   NULL,
                   b.idfsYNRelatedToOutbreak,
                   a.idfsYNRelatedToOutbreak,
                   @User,
                   @idfHumanCase
            FROM @HumanCaseAfterEdit AS a
                FULL JOIN @HumanCaseBeforeEdit AS b
                    ON a.idfHumanCase = b.idfHumanCase
            WHERE (a.idfsYNRelatedToOutbreak <> b.idfsYNRelatedToOutbreak)
                  OR (
                         a.idfsYNRelatedToOutbreak IS NOT NULL
                         AND b.idfsYNRelatedToOutbreak IS NULL
                     )
                  OR (
                         a.idfsYNRelatedToOutbreak IS NULL
                         AND b.idfsYNRelatedToOutbreak IS NOT NULL
                     );

            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue,
                AuditCreateUser,
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   79760000000, --idfsYNSpecimenCollected
                   a.idfHumanCase,
                   NULL,
                   b.idfsYNSpecimenCollected,
                   a.idfsYNSpecimenCollected,
                   @User,
                   @idfHumanCase
            FROM @HumanCaseAfterEdit AS a
                FULL JOIN @HumanCaseBeforeEdit AS b
                    ON a.idfHumanCase = b.idfHumanCase
            WHERE (a.idfsYNSpecimenCollected <> b.idfsYNSpecimenCollected)
                  OR (
                         a.idfsYNSpecimenCollected IS NOT NULL
                         AND b.idfsYNSpecimenCollected IS NULL
                     )
                  OR (
                         a.idfsYNSpecimenCollected IS NULL
                         AND b.idfsYNSpecimenCollected IS NOT NULL
                     );

            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue,
                AuditCreateUser,
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   79770000000, --intPatientAge
                   a.idfHumanCase,
                   NULL,
                   b.intPatientAge,
                   a.intPatientAge,
                   @User,
                   @idfHumanCase
            FROM @HumanCaseAfterEdit AS a
                FULL JOIN @HumanCaseBeforeEdit AS b
                    ON a.idfHumanCase = b.idfHumanCase
            WHERE (a.intPatientAge <> b.intPatientAge)
                  OR (
                         a.intPatientAge IS NOT NULL
                         AND b.intPatientAge IS NULL
                     )
                  OR (
                         a.intPatientAge IS NULL
                         AND b.intPatientAge IS NOT NULL
                     );

            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue,
                AuditCreateUser,
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   79780000000, --strClinicalDiagnosis
                   a.idfHumanCase,
                   NULL,
                   b.strClinicalDiagnosis,
                   a.strClinicalDiagnosis,
                   @User,
                   @idfHumanCase
            FROM @HumanCaseAfterEdit AS a
                FULL JOIN @HumanCaseBeforeEdit AS b
                    ON a.idfHumanCase = b.idfHumanCase
            WHERE (a.strClinicalDiagnosis <> b.strClinicalDiagnosis)
                  OR (
                         a.strClinicalDiagnosis IS NOT NULL
                         AND b.strClinicalDiagnosis IS NULL
                     )
                  OR (
                         a.strClinicalDiagnosis IS NULL
                         AND b.strClinicalDiagnosis IS NOT NULL
                     );

            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue,
                AuditCreateUser,
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   79790000000, --strCurrentLocation
                   a.idfHumanCase,
                   NULL,
                   b.strCurrentLocation,
                   a.strCurrentLocation,
                   @User,
                   @idfHumanCase
            FROM @HumanCaseAfterEdit AS a
                FULL JOIN @HumanCaseBeforeEdit AS b
                    ON a.idfHumanCase = b.idfHumanCase
            WHERE (a.strCurrentLocation <> b.strCurrentLocation)
                  OR (
                         a.strCurrentLocation IS NOT NULL
                         AND b.strCurrentLocation IS NULL
                     )
                  OR (
                         a.strCurrentLocation IS NULL
                         AND b.strCurrentLocation IS NOT NULL
                     );

            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue,
                AuditCreateUser,
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   79800000000, --strEpidemiologistsName
                   a.idfHumanCase,
                   NULL,
                   b.strEpidemiologistsName,
                   a.strEpidemiologistsName,
                   @User,
                   @idfHumanCase
            FROM @HumanCaseAfterEdit AS a
                FULL JOIN @HumanCaseBeforeEdit AS b
                    ON a.idfHumanCase = b.idfHumanCase
            WHERE (a.strEpidemiologistsName <> b.strEpidemiologistsName)
                  OR (
                         a.strEpidemiologistsName IS NOT NULL
                         AND b.strEpidemiologistsName IS NULL
                     )
                  OR (
                         a.strEpidemiologistsName IS NULL
                         AND b.strEpidemiologistsName IS NOT NULL
                     );

            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue,
                AuditCreateUser,
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   79810000000, --strHospitalizationPlace
                   a.idfHumanCase,
                   NULL,
                   b.strHospitalizationPlace,
                   a.strHospitalizationPlace,
                   @User,
                   @idfHumanCase
            FROM @HumanCaseAfterEdit AS a
                FULL JOIN @HumanCaseBeforeEdit AS b
                    ON a.idfHumanCase = b.idfHumanCase
            WHERE (a.strHospitalizationPlace <> b.strHospitalizationPlace)
                  OR (
                         a.strHospitalizationPlace IS NOT NULL
                         AND b.strHospitalizationPlace IS NULL
                     )
                  OR (
                         a.strHospitalizationPlace IS NULL
                         AND b.strHospitalizationPlace IS NOT NULL
                     );

            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue,
                AuditCreateUser,
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   79820000000, --strLocalIdentifier
                   a.idfHumanCase,
                   NULL,
                   b.strLocalIdentifier,
                   a.strLocalIdentifier,
                   @User,
                   @idfHumanCase
            FROM @HumanCaseAfterEdit AS a
                FULL JOIN @HumanCaseBeforeEdit AS b
                    ON a.idfHumanCase = b.idfHumanCase
            WHERE (a.strLocalIdentifier <> b.strLocalIdentifier)
                  OR (
                         a.strLocalIdentifier IS NOT NULL
                         AND b.strLocalIdentifier IS NULL
                     )
                  OR (
                         a.strLocalIdentifier IS NULL
                         AND b.strLocalIdentifier IS NOT NULL
                     );

            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue,
                AuditCreateUser,
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   79830000000, --strNotCollectedReason
                   a.idfHumanCase,
                   NULL,
                   b.strNotCollectedReason,
                   a.strNotCollectedReason,
                   @User,
                   @idfHumanCase
            FROM @HumanCaseAfterEdit AS a
                FULL JOIN @HumanCaseBeforeEdit AS b
                    ON a.idfHumanCase = b.idfHumanCase
            WHERE (a.strNotCollectedReason <> b.strNotCollectedReason)
                  OR (
                         a.strNotCollectedReason IS NOT NULL
                         AND b.strNotCollectedReason IS NULL
                     )
                  OR (
                         a.strNotCollectedReason IS NULL
                         AND b.strNotCollectedReason IS NOT NULL
                     );

            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue,
                AuditCreateUser,
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   79840000000, --strNote
                   a.idfHumanCase,
                   NULL,
                   b.strNote,
                   a.strNote,
                   @User,
                   @idfHumanCase
            FROM @HumanCaseAfterEdit AS a
                FULL JOIN @HumanCaseBeforeEdit AS b
                    ON a.idfHumanCase = b.idfHumanCase
            WHERE (a.strNote <> b.strNote)
                  OR (
                         a.strNote IS NOT NULL
                         AND b.strNote IS NULL
                     )
                  OR (
                         a.strNote IS NULL
                         AND b.strNote IS NOT NULL
                     );

            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue,
                AuditCreateUser,
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   79850000000, --strReceivedByFirstName
                   a.idfHumanCase,
                   NULL,
                   b.strReceivedByFirstName,
                   a.strReceivedByFirstName,
                   @User,
                   @idfHumanCase
            FROM @HumanCaseAfterEdit AS a
                FULL JOIN @HumanCaseBeforeEdit AS b
                    ON a.idfHumanCase = b.idfHumanCase
            WHERE (a.strReceivedByFirstName <> b.strReceivedByFirstName)
                  OR (
                         a.strReceivedByFirstName IS NOT NULL
                         AND b.strReceivedByFirstName IS NULL
                     )
                  OR (
                         a.strReceivedByFirstName IS NULL
                         AND b.strReceivedByFirstName IS NOT NULL
                     );

            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue,
                AuditCreateUser,
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   79860000000, --strReceivedByLastName
                   a.idfHumanCase,
                   NULL,
                   b.strReceivedByLastName,
                   a.strReceivedByLastName,
                   @User,
                   @idfHumanCase
            FROM @HumanCaseAfterEdit AS a
                FULL JOIN @HumanCaseBeforeEdit AS b
                    ON a.idfHumanCase = b.idfHumanCase
            WHERE (a.strReceivedByLastName <> b.strReceivedByLastName)
                  OR (
                         a.strReceivedByLastName IS NOT NULL
                         AND b.strReceivedByLastName IS NULL
                     )
                  OR (
                         a.strReceivedByLastName IS NULL
                         AND b.strReceivedByLastName IS NOT NULL
                     );

            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue,
                AuditCreateUser,
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   79870000000, --strReceivedByPatronymicName
                   a.idfHumanCase,
                   NULL,
                   b.strReceivedByPatronymicName,
                   a.strReceivedByPatronymicName,
                   @User,
                   @idfHumanCase
            FROM @HumanCaseAfterEdit AS a
                FULL JOIN @HumanCaseBeforeEdit AS b
                    ON a.idfHumanCase = b.idfHumanCase
            WHERE (a.strReceivedByPatronymicName <> b.strReceivedByPatronymicName)
                  OR (
                         a.strReceivedByPatronymicName IS NOT NULL
                         AND b.strReceivedByPatronymicName IS NULL
                     )
                  OR (
                         a.strReceivedByPatronymicName IS NULL
                         AND b.strReceivedByPatronymicName IS NOT NULL
                     );

            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue,
                AuditCreateUser,
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   79880000000, --strSentByFirstName
                   a.idfHumanCase,
                   NULL,
                   b.strSentByFirstName,
                   a.strSentByFirstName,
                   @User,
                   @idfHumanCase
            FROM @HumanCaseAfterEdit AS a
                FULL JOIN @HumanCaseBeforeEdit AS b
                    ON a.idfHumanCase = b.idfHumanCase
            WHERE (a.strSentByFirstName <> b.strSentByFirstName)
                  OR (
                         a.strSentByFirstName IS NOT NULL
                         AND b.strSentByFirstName IS NULL
                     )
                  OR (
                         a.strSentByFirstName IS NULL
                         AND b.strSentByFirstName IS NOT NULL
                     );

            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue,
                AuditCreateUser,
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   79890000000, --strSentByLastName
                   a.idfHumanCase,
                   NULL,
                   b.strSentByLastName,
                   a.strSentByLastName,
                   @User,
                   @idfHumanCase
            FROM @HumanCaseAfterEdit AS a
                FULL JOIN @HumanCaseBeforeEdit AS b
                    ON a.idfHumanCase = b.idfHumanCase
            WHERE (a.strSentByLastName <> b.strSentByLastName)
                  OR (
                         a.strSentByLastName IS NOT NULL
                         AND b.strSentByLastName IS NULL
                     )
                  OR (
                         a.strSentByLastName IS NULL
                         AND b.strSentByLastName IS NOT NULL
                     );

            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue,
                AuditCreateUser,
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   79900000000, --strSentByPatronymicName
                   a.idfHumanCase,
                   NULL,
                   b.strSentByPatronymicName,
                   a.strSentByPatronymicName,
                   @User,
                   @idfHumanCase
            FROM @HumanCaseAfterEdit AS a
                FULL JOIN @HumanCaseBeforeEdit AS b
                    ON a.idfHumanCase = b.idfHumanCase
            WHERE (a.strSentByPatronymicName <> b.strSentByPatronymicName)
                  OR (
                         a.strSentByPatronymicName IS NOT NULL
                         AND b.strSentByPatronymicName IS NULL
                     )
                  OR (
                         a.strSentByPatronymicName IS NULL
                         AND b.strSentByPatronymicName IS NOT NULL
                     );

            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue,
                AuditCreateUser,
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   79910000000, --strSoughtCareFacility
                   a.idfHumanCase,
                   NULL,
                   b.strSoughtCareFacility,
                   a.strSoughtCareFacility,
                   @User,
                   @idfHumanCase
            FROM @HumanCaseAfterEdit AS a
                FULL JOIN @HumanCaseBeforeEdit AS b
                    ON a.idfHumanCase = b.idfHumanCase
            WHERE (a.strSoughtCareFacility <> b.strSoughtCareFacility)
                  OR (
                         a.strSoughtCareFacility IS NOT NULL
                         AND b.strSoughtCareFacility IS NULL
                     )
                  OR (
                         a.strSoughtCareFacility IS NULL
                         AND b.strSoughtCareFacility IS NOT NULL
                     );

            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue,
                AuditCreateUser,
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   855690000000, --idfsFinalCaseStatus
                   a.idfHumanCase,
                   NULL,
                   b.idfsFinalCaseStatus,
                   a.idfsFinalCaseStatus,
                   @User,
                   @idfHumanCase
            FROM @HumanCaseAfterEdit AS a
                FULL JOIN @HumanCaseBeforeEdit AS b
                    ON a.idfHumanCase = b.idfHumanCase
            WHERE (a.idfsFinalCaseStatus <> b.idfsFinalCaseStatus)
                  OR (
                         a.idfsFinalCaseStatus IS NOT NULL
                         AND b.idfsFinalCaseStatus IS NULL
                     )
                  OR (
                         a.idfsFinalCaseStatus IS NULL
                         AND b.idfsFinalCaseStatus IS NOT NULL
                     );

            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue,
                AuditCreateUser,
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   855700000000, --idfSentByOffice
                   a.idfHumanCase,
                   NULL,
                   b.idfSentByOffice,
                   a.idfSentByOffice,
                   @User,
                   @idfHumanCase
            FROM @HumanCaseAfterEdit AS a
                FULL JOIN @HumanCaseBeforeEdit AS b
                    ON a.idfHumanCase = b.idfHumanCase
            WHERE (a.idfSentByOffice <> b.idfSentByOffice)
                  OR (
                         a.idfSentByOffice IS NOT NULL
                         AND b.idfSentByOffice IS NULL
                     )
                  OR (
                         a.idfSentByOffice IS NULL
                         AND b.idfSentByOffice IS NOT NULL
                     );

            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue,
                AuditCreateUser,
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   855710000000, --idfEpiObservation
                   a.idfHumanCase,
                   NULL,
                   b.idfEpiObservation,
                   a.idfEpiObservation,
                   @User,
                   @idfHumanCase
            FROM @HumanCaseAfterEdit AS a
                FULL JOIN @HumanCaseBeforeEdit AS b
                    ON a.idfHumanCase = b.idfHumanCase
            WHERE (a.idfEpiObservation <> b.idfEpiObservation)
                  OR (
                         a.idfEpiObservation IS NOT NULL
                         AND b.idfEpiObservation IS NULL
                     )
                  OR (
                         a.idfEpiObservation IS NULL
                         AND b.idfEpiObservation IS NOT NULL
                     );

            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue,
                AuditCreateUser,
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   855720000000, --idfCSObservation
                   a.idfHumanCase,
                   NULL,
                   b.idfCSObservation,
                   a.idfCSObservation,
                   @User,
                   @idfHumanCase
            FROM @HumanCaseAfterEdit AS a
                FULL JOIN @HumanCaseBeforeEdit AS b
                    ON a.idfHumanCase = b.idfHumanCase
            WHERE (a.idfCSObservation <> b.idfCSObservation)
                  OR (
                         a.idfCSObservation IS NOT NULL
                         AND b.idfCSObservation IS NULL
                     )
                  OR (
                         a.idfCSObservation IS NULL
                         AND b.idfCSObservation IS NOT NULL
                     );

            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue,
                AuditCreateUser,
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   855730000000, --idfDeduplicationResultCase
                   a.idfHumanCase,
                   NULL,
                   b.idfDeduplicationResultCase,
                   a.idfDeduplicationResultCase,
                   @User,
                   @idfHumanCase
            FROM @HumanCaseAfterEdit AS a
                FULL JOIN @HumanCaseBeforeEdit AS b
                    ON a.idfHumanCase = b.idfHumanCase
            WHERE (a.idfDeduplicationResultCase <> b.idfDeduplicationResultCase)
                  OR (
                         a.idfDeduplicationResultCase IS NOT NULL
                         AND b.idfDeduplicationResultCase IS NULL
                     )
                  OR (
                         a.idfDeduplicationResultCase IS NULL
                         AND b.idfDeduplicationResultCase IS NOT NULL
                     );

            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue,
                AuditCreateUser,
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   855740000000, --datNotificationDate
                   a.idfHumanCase,
                   NULL,
                   b.datNotificationDate,
                   a.datNotificationDate,
                   @User,
                   @idfHumanCase
            FROM @HumanCaseAfterEdit AS a
                FULL JOIN @HumanCaseBeforeEdit AS b
                    ON a.idfHumanCase = b.idfHumanCase
            WHERE (a.datNotificationDate <> b.datNotificationDate)
                  OR (
                         a.datNotificationDate IS NOT NULL
                         AND b.datNotificationDate IS NULL
                     )
                  OR (
                         a.datNotificationDate IS NULL
                         AND b.datNotificationDate IS NOT NULL
                     );

            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue,
                AuditCreateUser,
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   855750000000, --datFirstSoughtCareDate
                   a.idfHumanCase,
                   NULL,
                   b.datFirstSoughtCareDate,
                   a.datFirstSoughtCareDate,
                   @User,
                   @idfHumanCase
            FROM @HumanCaseAfterEdit AS a
                FULL JOIN @HumanCaseBeforeEdit AS b
                    ON a.idfHumanCase = b.idfHumanCase
            WHERE (a.datFirstSoughtCareDate <> b.datFirstSoughtCareDate)
                  OR (
                         a.datFirstSoughtCareDate IS NOT NULL
                         AND b.datFirstSoughtCareDate IS NULL
                     )
                  OR (
                         a.datFirstSoughtCareDate IS NULL
                         AND b.datFirstSoughtCareDate IS NOT NULL
                     );

            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue,
                AuditCreateUser,
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   855760000000, --datOnSetDate
                   a.idfHumanCase,
                   NULL,
                   b.datOnSetDate,
                   a.datOnSetDate,
                   @User,
                   @idfHumanCase
            FROM @HumanCaseAfterEdit AS a
                FULL JOIN @HumanCaseBeforeEdit AS b
                    ON a.idfHumanCase = b.idfHumanCase
            WHERE (a.datOnSetDate <> b.datOnSetDate)
                  OR (
                         a.datOnSetDate IS NOT NULL
                         AND b.datOnSetDate IS NULL
                     )
                  OR (
                         a.datOnSetDate IS NULL
                         AND b.datOnSetDate IS NOT NULL
                     );

            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue,
                AuditCreateUser,
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   855770000000, --strClinicalNotes
                   a.idfHumanCase,
                   NULL,
                   b.strClinicalNotes,
                   a.strClinicalNotes,
                   @User,
                   @idfHumanCase
            FROM @HumanCaseAfterEdit AS a
                FULL JOIN @HumanCaseBeforeEdit AS b
                    ON a.idfHumanCase = b.idfHumanCase
            WHERE (a.strClinicalNotes <> b.strClinicalNotes)
                  OR (
                         a.strClinicalNotes IS NOT NULL
                         AND b.strClinicalNotes IS NULL
                     )
                  OR (
                         a.strClinicalNotes IS NULL
                         AND b.strClinicalNotes IS NOT NULL
                     );

            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue,
                AuditCreateUser,
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   855780000000, --strSummaryNotes
                   a.idfHumanCase,
                   NULL,
                   b.strSummaryNotes,
                   a.strSummaryNotes,
                   @User,
                   @idfHumanCase
            FROM @HumanCaseAfterEdit AS a
                FULL JOIN @HumanCaseBeforeEdit AS b
                    ON a.idfHumanCase = b.idfHumanCase
            WHERE (a.strSummaryNotes <> b.strSummaryNotes)
                  OR (
                         a.strSummaryNotes IS NOT NULL
                         AND b.strSummaryNotes IS NULL
                     )
                  OR (
                         a.strSummaryNotes IS NULL
                         AND b.strSummaryNotes IS NOT NULL
                     );

            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue,
                AuditCreateUser,
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   4577900000000, --idfHuman
                   a.idfHumanCase,
                   NULL,
                   b.idfHuman,
                   a.idfHuman,
                   @User,
                   @idfHumanCase
            FROM @HumanCaseAfterEdit AS a
                FULL JOIN @HumanCaseBeforeEdit AS b
                    ON a.idfHumanCase = b.idfHumanCase
            WHERE (a.idfHuman <> b.idfHuman)
                  OR (
                         a.idfHuman IS NOT NULL
                         AND b.idfHuman IS NULL
                     )
                  OR (
                         a.idfHuman IS NULL
                         AND b.idfHuman IS NOT NULL
                     );

            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue,
                AuditCreateUser,
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   4577910000000, --idfPersonEnteredBy
                   a.idfHumanCase,
                   NULL,
                   b.idfPersonEnteredBy,
                   a.idfPersonEnteredBy,
                   @User,
                   @idfHumanCase
            FROM @HumanCaseAfterEdit AS a
                FULL JOIN @HumanCaseBeforeEdit AS b
                    ON a.idfHumanCase = b.idfHumanCase
            WHERE (a.idfPersonEnteredBy <> b.idfPersonEnteredBy)
                  OR (
                         a.idfPersonEnteredBy IS NOT NULL
                         AND b.idfPersonEnteredBy IS NULL
                     )
                  OR (
                         a.idfPersonEnteredBy IS NULL
                         AND b.idfPersonEnteredBy IS NOT NULL
                     );

            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue,
                AuditCreateUser,
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   4578390000000, --idfSentByPerson
                   a.idfHumanCase,
                   NULL,
                   b.idfSentByPerson,
                   a.idfSentByPerson,
                   @User,
                   @idfHumanCase
            FROM @HumanCaseAfterEdit AS a
                FULL JOIN @HumanCaseBeforeEdit AS b
                    ON a.idfHumanCase = b.idfHumanCase
            WHERE (a.idfSentByPerson <> b.idfSentByPerson)
                  OR (
                         a.idfSentByPerson IS NOT NULL
                         AND b.idfSentByPerson IS NULL
                     )
                  OR (
                         a.idfSentByPerson IS NULL
                         AND b.idfSentByPerson IS NOT NULL
                     );

            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue,
                AuditCreateUser,
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   4578400000000, --idfReceivedByPerson
                   a.idfHumanCase,
                   NULL,
                   b.idfReceivedByPerson,
                   a.idfReceivedByPerson,
                   @User,
                   @idfHumanCase
            FROM @HumanCaseAfterEdit AS a
                FULL JOIN @HumanCaseBeforeEdit AS b
                    ON a.idfHumanCase = b.idfHumanCase
            WHERE (a.idfReceivedByPerson <> b.idfReceivedByPerson)
                  OR (
                         a.idfReceivedByPerson IS NOT NULL
                         AND b.idfReceivedByPerson IS NULL
                     )
                  OR (
                         a.idfReceivedByPerson IS NULL
                         AND b.idfReceivedByPerson IS NOT NULL
                     );

            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue,
                AuditCreateUser,
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   4578410000000, --idfInvestigatedByPerson
                   a.idfHumanCase,
                   NULL,
                   b.idfInvestigatedByPerson,
                   a.idfInvestigatedByPerson,
                   @User,
                   @idfHumanCase
            FROM @HumanCaseAfterEdit AS a
                FULL JOIN @HumanCaseBeforeEdit AS b
                    ON a.idfHumanCase = b.idfHumanCase
            WHERE (a.idfInvestigatedByPerson <> b.idfInvestigatedByPerson)
                  OR (
                         a.idfInvestigatedByPerson IS NOT NULL
                         AND b.idfInvestigatedByPerson IS NULL
                     )
                  OR (
                         a.idfInvestigatedByPerson IS NULL
                         AND b.idfInvestigatedByPerson IS NOT NULL
                     );

            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue,
                AuditCreateUser,
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   4578420000000, --idfsYNTestsConducted
                   a.idfHumanCase,
                   NULL,
                   b.idfsYNTestsConducted,
                   a.idfsYNTestsConducted,
                   @User,
                   @idfHumanCase
            FROM @HumanCaseAfterEdit AS a
                FULL JOIN @HumanCaseBeforeEdit AS b
                    ON a.idfHumanCase = b.idfHumanCase
            WHERE (a.idfsYNTestsConducted <> b.idfsYNTestsConducted)
                  OR (
                         a.idfsYNTestsConducted IS NOT NULL
                         AND b.idfsYNTestsConducted IS NULL
                     )
                  OR (
                         a.idfsYNTestsConducted IS NULL
                         AND b.idfsYNTestsConducted IS NOT NULL
                     );

            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue,
                AuditCreateUser,
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   12014650000000, --idfSoughtCareFacility
                   a.idfHumanCase,
                   NULL,
                   b.idfSoughtCareFacility,
                   a.idfSoughtCareFacility,
                   @User,
                   @idfHumanCase
            FROM @HumanCaseAfterEdit AS a
                FULL JOIN @HumanCaseBeforeEdit AS b
                    ON a.idfHumanCase = b.idfHumanCase
            WHERE (a.idfSoughtCareFacility <> b.idfSoughtCareFacility)
                  OR (
                         a.idfSoughtCareFacility IS NOT NULL
                         AND b.idfSoughtCareFacility IS NULL
                     )
                  OR (
                         a.idfSoughtCareFacility IS NULL
                         AND b.idfSoughtCareFacility IS NOT NULL
                     );

            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue,
                AuditCreateUser,
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   12014660000000, --idfsNonNotifiableDiagnosis
                   a.idfHumanCase,
                   NULL,
                   b.idfsNonNotifiableDiagnosis,
                   a.idfsNonNotifiableDiagnosis,
                   @User,
                   @idfHumanCase
            FROM @HumanCaseAfterEdit AS a
                FULL JOIN @HumanCaseBeforeEdit AS b
                    ON a.idfHumanCase = b.idfHumanCase
            WHERE (a.idfsNonNotifiableDiagnosis <> b.idfsNonNotifiableDiagnosis)
                  OR (
                         a.idfsNonNotifiableDiagnosis IS NOT NULL
                         AND b.idfsNonNotifiableDiagnosis IS NULL
                     )
                  OR (
                         a.idfsNonNotifiableDiagnosis IS NULL
                         AND b.idfsNonNotifiableDiagnosis IS NOT NULL
                     );

            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue,
                AuditCreateUser,
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   12014670000000, --idfsNotCollectedReason
                   a.idfHumanCase,
                   NULL,
                   b.idfsNotCollectedReason,
                   a.idfsNotCollectedReason,
                   @User,
                   @idfHumanCase
            FROM @HumanCaseAfterEdit AS a
                FULL JOIN @HumanCaseBeforeEdit AS b
                    ON a.idfHumanCase = b.idfHumanCase
            WHERE (a.idfsNotCollectedReason <> b.idfsNotCollectedReason)
                  OR (
                         a.idfsNotCollectedReason IS NOT NULL
                         AND b.idfsNotCollectedReason IS NULL
                     )
                  OR (
                         a.idfsNotCollectedReason IS NULL
                         AND b.idfsNotCollectedReason IS NOT NULL
                     );

            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue,
                AuditCreateUser,
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   12665410000000, --idfHumanCase
                   a.idfHumanCase,
                   NULL,
                   b.idfHumanCase,
                   a.idfHumanCase,
                   @User,
                   @idfHumanCase
            FROM @HumanCaseAfterEdit AS a
                FULL JOIN @HumanCaseBeforeEdit AS b
                    ON a.idfHumanCase = b.idfHumanCase
            WHERE (a.idfHumanCase <> b.idfHumanCase)
                  OR (
                         a.idfHumanCase IS NOT NULL
                         AND b.idfHumanCase IS NULL
                     )
                  OR (
                         a.idfHumanCase IS NULL
                         AND b.idfHumanCase IS NOT NULL
                     );

            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue,
                AuditCreateUser,
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   12665420000000, --datEnteredDate
                   a.idfHumanCase,
                   NULL,
                   b.datEnteredDate,
                   a.datEnteredDate,
                   @User,
                   @idfHumanCase
            FROM @HumanCaseAfterEdit AS a
                FULL JOIN @HumanCaseBeforeEdit AS b
                    ON a.idfHumanCase = b.idfHumanCase
            WHERE (a.datEnteredDate <> b.datEnteredDate)
                  OR (
                         a.datEnteredDate IS NOT NULL
                         AND b.datEnteredDate IS NULL
                     )
                  OR (
                         a.datEnteredDate IS NULL
                         AND b.datEnteredDate IS NOT NULL
                     );

            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue,
                AuditCreateUser,
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   12665430000000, --strCaseID
                   a.idfHumanCase,
                   NULL,
                   b.strCaseID,
                   a.strCaseID,
                   @User,
                   @idfHumanCase
            FROM @HumanCaseAfterEdit AS a
                FULL JOIN @HumanCaseBeforeEdit AS b
                    ON a.idfHumanCase = b.idfHumanCase
            WHERE (a.strCaseID <> b.strCaseID)
                  OR (
                         a.strCaseID IS NOT NULL
                         AND b.strCaseID IS NULL
                     )
                  OR (
                         a.strCaseID IS NULL
                         AND b.strCaseID IS NOT NULL
                     );

            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue,
                AuditCreateUser,
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   12665440000000, --idfsCaseProgressStatus
                   a.idfHumanCase,
                   NULL,
                   b.idfsCaseProgressStatus,
                   a.idfsCaseProgressStatus,
                   @User,
                   @idfHumanCase
            FROM @HumanCaseAfterEdit AS a
                FULL JOIN @HumanCaseBeforeEdit AS b
                    ON a.idfHumanCase = b.idfHumanCase
            WHERE (a.idfsCaseProgressStatus <> b.idfsCaseProgressStatus)
                  OR (
                         a.idfsCaseProgressStatus IS NOT NULL
                         AND b.idfsCaseProgressStatus IS NULL
                     )
                  OR (
                         a.idfsCaseProgressStatus IS NULL
                         AND b.idfsCaseProgressStatus IS NOT NULL
                     );

            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue,
                AuditCreateUser,
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   12665450000000, --strSampleNotes
                   a.idfHumanCase,
                   NULL,
                   b.strSampleNotes,
                   a.strSampleNotes,
                   @User,
                   @idfHumanCase
            FROM @HumanCaseAfterEdit AS a
                FULL JOIN @HumanCaseBeforeEdit AS b
                    ON a.idfHumanCase = b.idfHumanCase
            WHERE (a.strSampleNotes <> b.strSampleNotes)
                  OR (
                         a.strSampleNotes IS NOT NULL
                         AND b.strSampleNotes IS NULL
                     )
                  OR (
                         a.strSampleNotes IS NULL
                         AND b.strSampleNotes IS NOT NULL
                     );

            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue,
                AuditCreateUser,
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   12665460000000, --uidOfflineCaseID
                   a.idfHumanCase,
                   NULL,
                   b.uidOfflineCaseID,
                   a.uidOfflineCaseID,
                   @User,
                   @idfHumanCase
            FROM @HumanCaseAfterEdit AS a
                FULL JOIN @HumanCaseBeforeEdit AS b
                    ON a.idfHumanCase = b.idfHumanCase
            WHERE (a.uidOfflineCaseID <> b.uidOfflineCaseID)
                  OR (
                         a.uidOfflineCaseID IS NOT NULL
                         AND b.uidOfflineCaseID IS NULL
                     )
                  OR (
                         a.uidOfflineCaseID IS NULL
                         AND b.uidOfflineCaseID IS NOT NULL
                     );

            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue,
                AuditCreateUser,
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   51389570000000, --datFinalCaseClassificationDate
                   a.idfHumanCase,
                   NULL,
                   b.datFinalCaseClassificationDate,
                   a.datFinalCaseClassificationDate,
                   @User,
                   @idfHumanCase
            FROM @HumanCaseAfterEdit AS a
                FULL JOIN @HumanCaseBeforeEdit AS b
                    ON a.idfHumanCase = b.idfHumanCase
            WHERE (a.datFinalCaseClassificationDate <> b.datFinalCaseClassificationDate)
                  OR (
                         a.datFinalCaseClassificationDate IS NOT NULL
                         AND b.datFinalCaseClassificationDate IS NULL
                     )
                  OR (
                         a.datFinalCaseClassificationDate IS NULL
                         AND b.datFinalCaseClassificationDate IS NOT NULL
                     );

            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue,
                AuditCreateUser,
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   51523420000000, --idfHospital
                   a.idfHumanCase,
                   NULL,
                   b.idfHospital,
                   a.idfHospital,
                   @User,
                   @idfHumanCase
            FROM @HumanCaseAfterEdit AS a
                FULL JOIN @HumanCaseBeforeEdit AS b
                    ON a.idfHumanCase = b.idfHumanCase
            WHERE (a.idfHospital <> b.idfHospital)
                  OR (
                         a.idfHospital IS NOT NULL
                         AND b.idfHospital IS NULL
                     )
                  OR (
                         a.idfHospital IS NULL
                         AND b.idfHospital IS NOT NULL
                     );

        --Date Audit Create Entry For Any Changes Made (End)
        END

        UPDATE dbo.tlbHuman
        SET idfCurrentResidenceAddress = @CaseGeoLocationID
        WHERE idfHuman = @idfHuman;

        --Temp solution for correct DateTime2 json dates, when they are coming in at Min value
        SET @SamplesParameters = REPLACE(@SamplesParameters, '"0001-01-01T00:00:00"', 'null');
        SET @TestsParameters = REPLACE(@TestsParameters, '"0001-01-01T00:00:00"', 'null');
        SET @AntiviralTherapiesParameters = REPLACE(@AntiviralTherapiesParameters, '"0001-01-01T00:00:00"', 'null');
        SET @VaccinationsParameters = REPLACE(@VaccinationsParameters, '"0001-01-01T00:00:00"', 'null');

        ----set AntiviralTherapies for this idfHumanCase
        If @AntiviralTherapiesParameters IS NOT NULL
        BEGIN
            DECLARE @OutbreakAntimicrobialTemp TABLE
            (
                antibioticID BIGINT NULL,
                idfHumanCase BIGINT NULL,
                idfAntimicrobialTherapy BIGINT NULL,
                strAntimicrobialTherapyName NVARCHAR(200) NULL,
                strDosage NVARCHAR(200) NULL,
                datFirstAdministeredDate DATETIME2 NULL,
                rowAction CHAR(1) NULL
            );

            INSERT INTO @OutbreakAntimicrobialTemp
            SELECT *
            FROM
                OPENJSON(@AntiviralTherapiesParameters)
                WITH
                (
                    antibioticID BIGINT,
                    idfHumanCase BIGINT,
                    idfAntimicrobialTherapy BIGINT,
                    strAntimicrobialTherapyName NVARCHAR(200),
                    strDosage NVARCHAR(200),
                    datFirstAdministeredDate DATETIME2,
                    rowAction CHAR(1)
                );

            DECLARE @Antimicrobials NVARCHAR(MAX) = NULL;

            SET @Antimicrobials =
            (
                SELECT idfAntimicrobialTherapy,
                       @idfHumanCase AS idfHumanCase,
                       datFirstAdministeredDate,
                       strAntimicrobialTherapyName,
                       strDosage,
                       rowAction
                FROM @OutbreakAntimicrobialTemp
                FOR JSON PATH
            );

            EXECUTE dbo.USSP_HUMAN_DISEASE_ANTIVIRALTHERAPIES_SET @idfHumanCase,
                                                                  @Antimicrobials,
                                                                  @outbreakCall = 1,
                                                                  @User = @User;
        END

        If @VaccinationsParameters IS NOT NULL
        BEGIN
            DECLARE @VaccinationsParametersTemp TABLE
            (
                vaccinationID BIGINT NULL,
                humanDiseaseReportVaccinationUID BIGINT NULL,
                idfHumanCase BIGINT NULL,
                vaccinationName NVARCHAR(200) NULL,
                vaccinationDate DATETIME2 NULL,
                rowAction CHAR(1) NULL,
                intRowStatus INT NULL
            );

            INSERT INTO @VaccinationsParametersTemp
            SELECT *
            FROM
                OPENJSON(@VaccinationsParameters)
                WITH
                (
                    vaccinationID BIGINT,
                    humanDiseaseReportVaccinationUID BIGINT,
                    idfHumanCase BIGINT,
                    vaccinationName NVARCHAR(200),
                    vaccinationDate DATETIME2,
                    rowAction NVARCHAR(1),
                    intRowStatus INT
                );

            DECLARE @Vaccinations NVARCHAR(MAX) = NULL
            SET @Vaccinations =
            (
                SELECT vaccinationID,
                       humanDiseaseReportVaccinationUID,
                       @idfHumanCase AS idfHumanCase,
                       vaccinationName,
                       vaccinationDate,
                       rowAction,
                       intRowStatus
                FROM @VaccinationsParametersTemp
                FOR JSON PATH
            );

            EXECUTE dbo.USSP_HUMAN_DISEASE_VACCINATIONS_SET @idfHumanCase,
                                                            @Vaccinations,
                                                            @outbreakCall = 1,
                                                            @User = @User;
        END


        --set Samples for this idfHumanCase	
        If @SamplesParameters IS NOT NULL
        BEGIN
            EXECUTE dbo.USSP_OMM_HUMAN_SAMPLES_SET @idfHumanActual,
                                                   @idfHumanCase = @idfHumanCase,
                                                   @SamplesParameters = @SamplesParameters,
                                                   @User = @User,
                                                   @TestsParameters = @TestsParameters,
                                                   @idfsFinalDiagnosis = @idfsFinalDiagnosis;
        END

        -- update tlbHuman IF datDateofDeath is provided.
        IF @datDateofDeath IS NOT NULL
        BEGIN
            UPDATE dbo.tlbHuman
            SET datDateofDeath = @datDateofDeath
            WHERE idfHuman = @idfHuman;
        END

        IF @@TRANCOUNT > 0
            COMMIT;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT = 1
            ROLLBACK;

        THROW;
    END CATCH
END
GO
PRINT N'Altering Procedure [dbo].[USP_VET_DISEASE_REPORT_GETDetail]...';


GO
-- ================================================================================================
-- Name: USP_VET_DISEASE_REPORT_GETDetail
--
-- Description:	Get disease detail (one record) for the veterinary edit/enter and other use cases.
--                      
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Stephen Long     04/18/2019 Initial release.
-- Stephen Long     04/29/2019 Added connected disease report fields for use case VUC11 and VUC12.
-- Stephen Long     05/26/2019 Added farm epidemiological observation ID to select list.
-- Stephen Long     10/02/2019 Adjusted for changes to the person select list function.
-- Ann Xiong		12/05/2019 Added YNTestConducted, OIECode, ReportCategoryTypeID, 
--                             ReportCategoryTypeName to select list.
-- Stephen Long     02/14/2020 Added connected disease report ID and EIDSS report ID to the query.
-- Stephen Long     11/29/2021 Removed return code and message for POCO.
-- Stephen Long     12/07/2021 Added farm and farm owner fields.
-- Stephen Long     01/12/2022 Added street and postal code ID's to the query.
-- Stephen Long     01/19/2022 Added farm master ID and farm owner ID to the query.
-- Stephen Long     01/24/2022 Changed country ID and name to administrative level 0 to match use 
--                             case.
-- Stephen Long     04/28/2022 Added received by organization and person identifiers.
-- Doug Albanese    07/26/2022 Add field FarmEpidemiologicalTemplateID, to correctly identify a 
--                             form that has been answered
-- Stephen Long     05/16/2023 Fix for item 5584.
-- ================================================================================================
ALTER PROCEDURE [dbo].[USP_VET_DISEASE_REPORT_GETDetail]
(
    @LanguageID AS NVARCHAR(50),
    @DiseaseReportID AS BIGINT
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @RelatedToIdentifiers TABLE 
    (
        ID BIGINT NOT NULL, 
        ReportID NVARCHAR(200) NOT NULL
    );
    DECLARE @CaseOutbreakSessionImportedIndicator INT = (
                                                            SELECT CASE
                                                                       WHEN idfOutbreak IS NOT NULL
                                                                            AND (strCaseID IS NOT NULL OR LegacyCaseID IS NOT NULL) THEN
                                                                           1
                                                                       ELSE
                                                                           0
                                                                   END
                                                            FROM dbo.tlbVetCase
                                                            WHERE idfVetCase = @DiseaseReportID
                                                        );

    BEGIN TRY
        IF @CaseOutbreakSessionImportedIndicator = 1
        BEGIN
            DECLARE @RelatedToDiseaseReportID BIGINT = @DiseaseReportID,
                    @ConnectedDiseaseReportID BIGINT;

            INSERT INTO @RelatedToIdentifiers
            SELECT idfVetCase, 
                   strCaseID
            FROM dbo.tlbVetCase 
            WHERE idfVetCase = @DiseaseReportID;

            WHILE EXISTS (SELECT * FROM dbo.VetDiseaseReportRelationship WHERE VetDiseaseReportID = @RelatedToDiseaseReportID)
            BEGIN
                INSERT INTO @RelatedToIdentifiers
                SELECT RelatedToVetDiseaseReportID, 
                       strCaseID
                FROM dbo.VetDiseaseReportRelationship  
                     INNER JOIN dbo.tlbVetCase ON idfVetCase = RelatedToVetDiseaseReportID
                WHERE VetDiseaseReportID = @RelatedToDiseaseReportID;

                SET @RelatedToDiseaseReportID = (SELECT RelatedToVetDiseaseReportID FROM dbo.VetDiseaseReportRelationship WHERE VetDiseaseReportID = @RelatedToDiseaseReportID);
            END
        END

        SELECT vc.idfVetCase AS DiseaseReportID,
               vc.idfFarm AS FarmID,
               f.idfFarmActual AS FarmMasterID,
               f.strFarmCode AS EIDSSFarmID,
               CASE
                   WHEN f.strNationalName IS NULL THEN
                       f.strInternationalName
                   WHEN f.strNationalName = '' THEN
                       f.strInternationalName
                   ELSE
                       f.strNationalName
               END AS FarmName,
               lh.AdminLevel1ID AS FarmAddressAdministrativeLevel0ID,
               lh.AdminLevel1Name AS FarmAddressAdministrativeLevel0Name,
               lh.AdminLevel2ID AS FarmAddressAdministrativeLevel1ID,
               lh.AdminLevel2Name AS FarmAddressAdministrativeLevel1Name,
               lh.AdminLevel3ID AS FarmAddressAdministrativeLevel2ID,
               lh.AdminLevel3Name AS FarmAddressAdministrativeLevel2Name,
               lh.AdminLevel4ID AS FarmAddressAdministrativeLevel3ID,
               lh.AdminLevel4Name AS FarmAddressAdministrativeLevel3Name,
               farmSettlementType.idfsReference AS FarmAddressSettlementTypeID,
               farmSettlementType.name AS FarmAddressSettlementTypeName,
               farmSettlement.idfsReference AS FarmAddressSettlementID,
               farmSettlement.name AS FarmAddressSettlementName,
               st.idfStreet AS FarmAddressStreetID,
               glFarm.strStreetName AS FarmAddressStreetName,
               glFarm.strBuilding AS FarmAddressBuilding,
               glFarm.strApartment AS FarmAddressApartment,
               glFarm.strHouse AS FarmAddressHouse,
               pc.idfPostalCode AS FarmAddressPostalCodeID,
               glFarm.strPostCode AS FarmAddressPostalCode,
               glFarm.dblLatitude AS FarmAddressLatitude,
               glFarm.dblLongitude AS FarmAddressLongitude,
               h.idfHuman AS FarmOwnerID,
               h.strPersonID AS EIDSSFarmOwnerID,
               h.strFirstName AS FarmOwnerFirstName,
               h.strLastName AS FarmOwnerLastName,
               h.strSecondName AS FarmOwnerSecondName,
               f.strContactPhone AS Phone,
               f.strEmail AS Email,
               vc.idfsFinalDiagnosis AS DiseaseID,
               disease.name AS DiseaseName,
               vc.idfPersonEnteredBy AS EnteredByPersonID,
               dbo.FN_GBL_ConcatFullName(
                                            personEnteredBy.strFamilyName,
                                            personEnteredBy.strFirstName,
                                            personEnteredBy.strSecondName
                                        ) AS EnteredByPersonName,
               vc.idfPersonReportedBy AS ReportedByPersonID,
               dbo.FN_GBL_ConcatFullName(
                                            personReportedBy.strFamilyName,
                                            personReportedBy.strFirstName,
                                            personReportedBy.strSecondName
                                        ) AS ReportedByPersonName,
               vc.idfPersonInvestigatedBy AS InvestigatedByPersonID,
               dbo.FN_GBL_ConcatFullName(
                                            personInvestigatedBy.strFamilyName,
                                            personInvestigatedBy.strFirstName,
                                            personInvestigatedBy.strSecondName
                                        ) AS InvestigatedByPersonName,
               f.idfObservation AS FarmEpidemiologicalObservationID,
               vc.idfObservation AS ControlMeasuresObservationID,
               vc.idfsSite AS SiteID,
               s.strSiteName AS SiteName,
               vc.datReportDate AS ReportDate,
               vc.datAssignedDate AS AssignedDate,
               vc.datInvestigationDate AS InvestigationDate,
               vc.datFinalDiagnosisDate AS DiagnosisDate,
               vc.strFieldAccessionID AS EIDSSFieldAccessionID,
               vc.idfsYNTestsConducted AS TestsConductedIndicator,
               vc.intRowStatus AS RowStatus,
               vc.idfReportedByOffice AS ReportedByOrganizationID,
               reportedByOrganization.name AS ReportedByOrganizationName,
               vc.idfInvestigatedByOffice AS InvestigatedByOrganizationID,
               investigatedByOrganization.name AS InvestigatedByOrganizationName,
               vc.idfReceivedByOffice AS ReceivedByOrganizationID, 
               vc.idfReceivedByPerson AS ReceivedByPersonID, 
               vc.idfsCaseReportType AS ReportTypeID,
               reportType.name AS ReportTypeName,
               vc.idfsCaseClassification AS ClassificationTypeID,
               classificationType.name AS ClassificationTypeName,
               vc.idfOutbreak AS OutbreakID,
               o.strOutbreakID AS EIDSSOutbreakID,
               vc.datEnteredDate AS EnteredDate,
               vc.strCaseID AS EIDSSReportID,
               vc.LegacyCaseID AS LegacyID,
               vc.idfsCaseProgressStatus AS ReportStatusTypeID,
               reportStatusType.name AS ReportStatusTypeName,
               vc.datModificationForArchiveDate AS ModifiedDate,
               vc.idfParentMonitoringSession AS ParentMonitoringSessionID,
               ms.strMonitoringSessionID AS EIDSSParentMonitoringSessionID,
               relatedTo.RelatedToVetDiseaseReportID AS RelatedToVeterinaryDiseaseReportID,
               relatedToReport.strCaseID AS RelatedToVeterinaryDiseaseEIDSSReportID,
               connectedTo.VetDiseaseReportID AS ConnectedDiseaseReportID,
               connectedToReport.strCaseID AS ConnectedDiseaseEIDSSReportID,
               testConductedType.name AS YNTestConducted,
               d.strOIECode AS OIECode,
               vc.idfsCaseType AS ReportCategoryTypeID,
               caseType.name AS ReportCategoryTypeName,
			   ffo.idfsFormTemplate AS FarmEpidemiologicalTemplateID, 
               (SELECT STRING_AGG(ID, ', ') WITHIN GROUP (ORDER BY ReportID) AS Result
               FROM @RelatedToIdentifiers) AS RelatedToIdentifiers,
               (SELECT STRING_AGG(ReportID, ', ') WITHIN GROUP (ORDER BY ReportID) AS Result
               FROM @RelatedToIdentifiers) AS RelatedToReportIdentifiers
        FROM dbo.tlbVetCase vc
            INNER JOIN dbo.tlbFarm f
                ON f.idfFarm = vc.idfFarm
            INNER JOIN dbo.tstSite s
                ON s.idfsSite = vc.idfsSite
            INNER JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000012) caseType
                ON caseType.idfsReference = vc.idfsCaseType
            LEFT JOIN dbo.tlbHuman h
                ON h.idfHuman = f.idfHuman
                   AND h.intRowStatus = 0
            LEFT JOIN dbo.tlbGeoLocation glFarm
                ON glFarm.idfGeoLocation = f.idfFarmAddress
                   AND glFarm.intRowStatus = 0
            LEFT JOIN dbo.gisLocation g
                ON g.idfsLocation = glFarm.idfsLocation
            LEFT JOIN dbo.FN_GBL_LocationHierarchy_Flattened(@LanguageID) lh
                ON lh.idfsLocation = g.idfsLocation
            LEFT JOIN dbo.FN_GBL_GIS_ReferenceRepair_GET(@LanguageID, 19000004) AS farmSettlement
                ON g.node.IsDescendantOf(farmSettlement.node) = 1
            LEFT JOIN dbo.FN_GBL_GIS_Reference(@LanguageID, 19000005) farmSettlementType
                ON farmSettlementType.idfsReference = farmSettlement.idfsType
            LEFT JOIN dbo.tlbStreet st
                ON st.strStreetName = glFarm.strStreetName
            LEFT JOIN dbo.tlbPostalCode pc
                ON pc.strPostCode = glFarm.strPostCode
            LEFT JOIN dbo.tlbPerson personInvestigatedBy
                ON personInvestigatedBy.idfPerson = vc.idfPersonInvestigatedBy
            LEFT JOIN dbo.tlbPerson personEnteredBy
                ON personEnteredBy.idfPerson = vc.idfPersonEnteredBy
            LEFT JOIN dbo.tlbPerson personReportedBy
                ON personReportedBy.idfPerson = vc.idfPersonReportedBy
            LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000019) disease
                ON disease.idfsReference = vc.idfsFinalDiagnosis
            LEFT JOIN dbo.trtDiagnosis d
                ON d.idfsDiagnosis = vc.idfsFinalDiagnosis
                   AND d.intRowStatus = 0
            LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000011) classificationType
                ON classificationType.idfsReference = vc.idfsCaseClassification
            LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000111) reportStatusType
                ON reportStatusType.idfsReference = vc.idfsCaseProgressStatus
            LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000144) reportType
                ON reportType.idfsReference = vc.idfsCaseReportType
            LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000100) testConductedType
                ON testConductedType.idfsReference = vc.idfsYNTestsConducted
            LEFT JOIN dbo.FN_GBL_Institution(@LanguageID) reportedByOrganization
                ON reportedByOrganization.idfOffice = vc.idfReportedByOffice
            LEFT JOIN dbo.FN_GBL_Institution(@LanguageID) investigatedByOrganization
                ON investigatedByOrganization.idfOffice = vc.idfInvestigatedByOffice
            LEFT JOIN dbo.tlbOutbreak o
                ON o.idfOutbreak = vc.idfOutbreak
                   AND o.intRowStatus = 0
            LEFT JOIN dbo.tlbMonitoringSession ms
                ON ms.idfMonitoringSession = vc.idfParentMonitoringSession
                   AND ms.intRowStatus = 0
            LEFT JOIN dbo.VetDiseaseReportRelationship relatedTo
                ON relatedTo.VetDiseaseReportID = vc.idfVetCase
                   AND relatedTo.intRowStatus = 0
                   AND relatedTo.RelationshipTypeID = 10503001
            LEFT JOIN dbo.tlbVetCase relatedToReport
                ON relatedToReport.idfVetCase = relatedTo.RelatedToVetDiseaseReportID
                   AND relatedToReport.intRowStatus = 0
            LEFT JOIN dbo.VetDiseaseReportRelationship connectedTo
                ON connectedTo.RelatedToVetDiseaseReportID = vc.idfVetCase
                   AND connectedTo.intRowStatus = 0
                   AND connectedTo.RelationshipTypeID = 10503001
            LEFT JOIN dbo.tlbVetCase connectedToReport
                ON connectedToReport.idfVetCase = connectedTo.VetDiseaseReportID
                   AND connectedToReport.intRowStatus = 0
			LEFT JOIN dbo.tlbObservation ffo
				ON ffo.idfObservation = f.idfObservation
        WHERE vc.idfVetCase = @DiseaseReportID;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH;
END
GO
PRINT N'Altering Procedure [dbo].[USP_VET_DISEASE_REPORT_GETList]...';


GO
-- ================================================================================================
-- Name: USP_VET_DISEASE_REPORT_GETList
--
-- Description:	Get disease list for the farm edit/enter and other use cases.
--                      
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Stephen Long     03/25/2018 Initial release.
-- Stephen Long     11/09/2018 Added FarmOwnerID and FarmOwnerName for lab use case 10.
-- Stephen Long     11/25/2018 Updated for the new API.
-- Stephen Long     12/31/2018 Added pagination logic.
-- Stephen Long     04/24/2019 Added advanced search parameters to sync up with use case VUC10.
-- Stephen Long     04/29/2019 Added related to veterinary disease report fields for use case VUC11 
--                             and VUC12.
-- Stephen Long     06/14/2019 Adjusted date from's and to's to be cast as just dates with no time.
-- Stephen Long     06/22/2019 Fix to the farm address logic (building, apartment, house IIF's 
--                             to case statements).
-- Stephen Long     06/25/2019 Add group by for joins with multiple records (such as samples).
-- Stephen Long     07/20/2019 Changed farm inventory counts to ISNULL.
-- Stephen Long     09/03/2019 Add active status check on species list.
-- Ann Xiong		12/05/2019 Added EIDSSPersonID to select list and replaced "ON 
--                             caseType.idfsReference = vc.idfsCaseReportType" with 
--                             "caseType.idfsReference = vc.idfsCaseType".
-- Ann Xiong		12/10/2019 Added a parameter @PersonID NVARCHAR(200) = NULL.
-- Ann Xiong		12/19/2019 Added EIDSSFarmID to select list
-- Stephen Long     01/22/2020 Added site list parameter for site filtration.
-- Stephen Long     01/28/2020 Added non-configurable filtration rules, and legacy report ID.
-- Stephen Long     02/03/2020 Added dbo prefix and changed non-configurable filtration comments.
-- Stephen Long     02/16/2020 Removed group by and pagination applied on final query.
-- Stephen Long     02/26/2020 Added data entry site ID parameter and where clause.
-- Stephen Long     03/04/2020 Corrected where clause on total count for null species type.
-- Stephen Long     03/17/2020 Corrected farm owner ID to use idfHuman instead of idfHumanActual.
-- Stephen Long     03/25/2020 Added if/else for first-level and second-level site types to bypass 
--                             non-configurable rules.
-- Stephen Long     05/18/2020 Added disease filtration rules from use case SAUC62.
-- Stephen Long     06/18/2020 Added where criteria to the query when no site filtration is 
--                             required.
-- Stephen Long     07/07/2020 Added trim to the EIDSS identifier like criteria.
-- Stephen Long     07/08/2020 Replaced common table experssion; was not working well with POCO.
-- Stephen Long     09/24/2020 Update address fields returned (settlement, rayon and region only).
-- Stephen Long     11/18/2020 Added site ID to the query.
-- Stephen Long     11/23/2020 Added configurable site filtration rules.
-- Stephen Long     11/25/2020 Modified for new permission fields on the AccessRule table.
-- Stephen Long     11/28/2020 Add index to table variable primary key.
-- Stephen Long     12/02/2020 Remove primary key from table variable IDs.
-- Stephen Long     12/13/2020 Added apply configurable filtration indicator parameter.
-- Stephen Long     12/23/2020 Added EIDSS session ID parameter and where clause criteria.
-- Stephen Long     12/24/2020 Modified join on disease filtration default role rule.
-- Stephen Long     12/29/2020 Changed function call on reference data for inactive records.
-- Stephen Long     01/04/2021 Added option recompile due to number of optional parameters for 
--                             better execution plan.
-- Stephen Long     01/05/2021 Removed species list sub-query due to performance.  New stored 
--                             procedure added to get species list when user expands disease 
--                             report row in search.
-- Stephen Long     01/06/2021 Added string aggregate function on species list and parameter to 
--                             include.
-- Stephen Long     01/25/2021 Added order by parameter to handle when a user selected a specific 
--                             column to sort by.
-- Stephen Long     01/27/2021 Fix for order by; alias will not work on order by with case.
-- Stephen Long     04/02/2021 Added updated pagination and location hierarchy.
-- Stephen Long     01/11/2022 Added farm owner (idfHuman) ID to the query and updated location 
--                             hierarchy.
-- Mike Kornegay	01/26/2022 Changed RecordCount to TotalRowCount to match BaseModel.
-- Stephen Long     03/29/2022 Added disease ID to the model for laboratory module, and corrected 
--                             site filtration.
-- Ann Xiong		04/25/2022 Added f.idfFarm to select list for Veterinary Disease Report 
--                             Deduplication.
-- Stephen Long     05/10/2022 Added report category type ID to the query.
-- Stephen Long     06/03/2022 Updated to point default access rules to base reference.
-- Mike Kornegay	08/28/2022 Changed FarmAddress to FarmLocation and added FarmLocation.
-- Mike Kornegay    08/31/2022 Corrected sort by adding order by to final query.
-- Stephen Long     09/22/2022 Add check for "0" page size.  If "0", then set to 1.
-- Doug Albanese    01/11/2023 Modifying so that the same SP can bring back Ou
-- Stephen Long     01/13/2023 Updated for site filtration queries.
-- Stephen Long     05/11/2023 Replaced gisLocation left joins.  Added record identifier search 
--                             indicator logic.
-- ================================================================================================
ALTER PROCEDURE [dbo].[USP_VET_DISEASE_REPORT_GETList]
    @LanguageID NVARCHAR(50),
    @ReportKey BIGINT = NULL,
    @ReportID NVARCHAR(200) = NULL,
    @LegacyReportID NVARCHAR(200) = NULL,
    @SessionKey BIGINT = NULL,
    @FarmMasterID BIGINT = NULL,
    @DiseaseID BIGINT = NULL,
    @ReportStatusTypeID BIGINT = NULL,
    @AdministrativeLevelID BIGINT = NULL,
    @DateEnteredFrom DATE = NULL,
    @DateEnteredTo DATE = NULL,
    @ClassificationTypeID BIGINT = NULL,
    @PersonID NVARCHAR(200) = NULL,
    @ReportTypeID BIGINT = NULL,
    @SpeciesTypeID BIGINT = NULL,
    @OutbreakCasesIndicator BIT = 0,
    @DiagnosisDateFrom DATE = NULL,
    @DiagnosisDateTo DATE = NULL,
    @InvestigationDateFrom DATE = NULL,
    @InvestigationDateTo DATE = NULL,
    @LocalOrFieldSampleID NVARCHAR(200) = NULL,
    @TotalAnimalQuantityFrom INT = NULL,
    @TotalAnimalQuantityTo INT = NULL,
    @SessionID NVARCHAR(200) = NULL,
    @DataEntrySiteID BIGINT = NULL,
    @RecordIdentifierSearchIndicator BIT = 0,
    @UserSiteID BIGINT,
    @UserOrganizationID BIGINT,
    @UserEmployeeID BIGINT,
    @ApplySiteFiltrationIndicator BIT = 0,
    @IncludeSpeciesListIndicator BIT = 0,
    @SortColumn NVARCHAR(30) = 'ReportID',
    @SortOrder NVARCHAR(4) = 'DESC',
    @PageNumber INT = 1,
    @PageSize INT = 10,
    @OutbreakCaseReportOnly INT = 0
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @firstRec INT;
    DECLARE @lastRec INT;

    SET @firstRec = (@PageNumber - 1) * @PageSize;
    SET @lastRec = (@PageNumber * @PageSize + 1);

    DECLARE @Results TABLE
    (
        ID BIGINT NOT NULL INDEX IX1 CLUSTERED,
        ReadPermissionIndicator INT NOT NULL,
        AccessToPersonalDataPermissionIndicator INT NOT NULL,
        AccessToGenderAndAgeDataPermissionIndicator INT NOT NULL,
        WritePermissionIndicator INT NOT NULL,
        DeletePermissionIndicator INT NOT NULL
    );
    DECLARE @FinalResults TABLE
    (
        ID BIGINT NOT NULL INDEX IX1 CLUSTERED,
        ReadPermissionIndicator INT NOT NULL,
        AccessToPersonalDataPermissionIndicator INT NOT NULL,
        AccessToGenderAndAgeDataPermissionIndicator INT NOT NULL,
        WritePermissionIndicator INT NOT NULL,
        DeletePermissionIndicator INT NOT NULL
    );
    DECLARE @UserSitePermissions TABLE
    (
        SiteID BIGINT NOT NULL,
        PermissionTypeID BIGINT NOT NULL,
        Permission INT NOT NULL
    );
    DECLARE @UserGroupSitePermissions TABLE
    (
        SiteID BIGINT NOT NULL,
        PermissionTypeID BIGINT NOT NULL,
        Permission INT NOT NULL
    );

    BEGIN TRY
        INSERT INTO @UserGroupSitePermissions
        SELECT oa.idfsOnSite,
               oa.idfsObjectOperation,
               CASE
                   WHEN oa.intPermission = 2 THEN
                       3
                   ELSE
                       2
               END
        FROM dbo.tstObjectAccess oa
            INNER JOIN dbo.tlbEmployeeGroupMember egm
                ON egm.idfEmployee = @UserEmployeeID
                   AND egm.intRowStatus = 0
        WHERE oa.intRowStatus = 0
              AND oa.idfsObjectType = 10060011 -- Site
              AND oa.idfActor = egm.idfEmployeeGroup;

        INSERT INTO @UserSitePermissions
        SELECT oa.idfsOnSite,
               oa.idfsObjectOperation,
               CASE
                   WHEN oa.intPermission = 2 THEN
                       5
                   ELSE
                       4
               END
        FROM dbo.tstObjectAccess oa
        WHERE oa.intRowStatus = 0
              AND oa.idfsObjectType = 10060011 -- Site
              AND oa.idfActor = @UserEmployeeID;

        IF @PageSize = 0
        BEGIN
            SET @PageSize = 1;
        END

        -- ========================================================================================
        -- NO CONFIGURABLE FILTRATION RULES APPLIED
        --
        -- For first and second level sites, do not apply any site filtration rules.
        -- ========================================================================================
        IF @ApplySiteFiltrationIndicator = 0
        BEGIN
            IF @RecordIdentifierSearchIndicator = 1
            BEGIN
                INSERT INTO @Results
                SELECT v.idfVetCase,
                       1,
                       1,
                       1,
                       1,
                       1
                FROM dbo.tlbVetCase v
                WHERE v.intRowStatus = 0
                      AND (
                              v.strCaseID LIKE '%' + TRIM(@ReportID) + '%'
                              OR @ReportID IS NULL
                          )
                      AND (
                              v.LegacyCaseID LIKE '%' + TRIM(@LegacyReportID) + '%'
                              OR @LegacyReportID IS NULL
                          )
                GROUP BY v.idfVetCase;
            END
            ELSE
            BEGIN
                INSERT INTO @Results
                SELECT v.idfVetCase,
                       1,
                       1,
                       1,
                       1,
                       1
                FROM dbo.tlbVetCase v
                    INNER JOIN dbo.tlbFarm f
                        ON f.idfFarm = v.idfFarm
                    LEFT JOIN dbo.tlbHuman h
                        ON h.idfHuman = f.idfHuman
                    LEFT JOIN dbo.HumanActualAddlInfo haai
                        ON haai.HumanActualAddlInfoUID = h.idfHumanActual
                    LEFT JOIN dbo.tlbGeoLocation gl
                        ON gl.idfGeoLocation = f.idfFarmAddress
                    LEFT JOIN dbo.FN_GBL_LocationHierarchy_Flattened(@LanguageID) lh
                        ON lh.idfsLocation = gl.idfsLocation
                    LEFT JOIN dbo.tlbMaterial m
                        ON m.idfVetCase = v.idfVetCase
                    LEFT JOIN dbo.tlbMonitoringSession ms
                        ON ms.idfMonitoringSession = v.idfParentMonitoringSession
                WHERE v.intRowStatus = 0
                      AND (
                              f.idfFarmActual = @FarmMasterID
                              OR @FarmMasterID IS NULL
                          )
                      AND (
                              v.idfVetCase = @ReportKey
                              OR @ReportKey IS NULL
                          )
                      AND (
                              v.idfParentMonitoringSession = @SessionKey
                              OR @SessionKey IS NULL
                          )
                      AND (
                              lh.AdminLevel1ID = @AdministrativeLevelID
                              OR lh.AdminLevel2ID = @AdministrativeLevelID
                              OR lh.AdminLevel3ID = @AdministrativeLevelID
                              OR lh.AdminLevel4ID = @AdministrativeLevelID
                              OR lh.AdminLevel5ID = @AdministrativeLevelID
                              OR lh.AdminLevel6ID = @AdministrativeLevelID
                              OR lh.AdminLevel7ID = @AdministrativeLevelID
                              OR @AdministrativeLevelID IS NULL
                          )
                      AND (
                              v.idfsFinalDiagnosis = @DiseaseID
                              OR @DiseaseID IS NULL
                          )
                      AND (
                              v.idfsCaseClassification = @ClassificationTypeID
                              OR @ClassificationTypeID IS NULL
                          )
                      AND (
                              v.idfsCaseProgressStatus = @ReportStatusTypeID
                              OR @ReportStatusTypeID IS NULL
                          )
                      AND (
                              (CAST(v.datEnteredDate AS DATE)
                      BETWEEN @DateEnteredFrom AND @DateEnteredTo
                              )
                              OR (
                                     @DateEnteredFrom IS NULL
                                     OR @DateEnteredTo IS NULL
                                 )
                          )
                      AND (
                              v.idfsCaseReportType = @ReportTypeID
                              OR @ReportTypeID IS NULL
                          )
                      AND (
                              v.idfsCaseType = @SpeciesTypeID
                              OR @SpeciesTypeID IS NULL
                          )
                      AND (
                              (CAST(v.datFinalDiagnosisDate AS DATE)
                      BETWEEN @DiagnosisDateFrom AND @DiagnosisDateTo
                              )
                              OR (
                                     @DiagnosisDateFrom IS NULL
                                     OR @DiagnosisDateTo IS NULL
                                 )
                          )
                      AND (
                              (CAST(v.datInvestigationDate AS DATE)
                      BETWEEN @InvestigationDateFrom AND @InvestigationDateTo
                              )
                              OR (
                                     @InvestigationDateFrom IS NULL
                                     OR @InvestigationDateTo IS NULL
                                 )
                          )
                      AND (
                              (
                                  (f.intAvianTotalAnimalQty
                      BETWEEN @TotalAnimalQuantityFrom AND @TotalAnimalQuantityTo
                                  )
                                  OR (f.intLivestockTotalAnimalQty
                      BETWEEN @TotalAnimalQuantityFrom AND @TotalAnimalQuantityTo
                                     )
                              )
                              OR (
                                     @TotalAnimalQuantityFrom IS NULL
                                     OR @TotalAnimalQuantityTo IS NULL
                                 )
                          )
                      AND (
                              (
                                  v.idfOutbreak IS NULL
                                  AND @OutbreakCasesIndicator = 0
                              )
                              OR (
                                     v.idfOutbreak IS NOT NULL
                                     AND @OutbreakCasesIndicator = 1
                                 )
                              OR (@OutbreakCasesIndicator IS NULL)
                          )
                      AND (
                              v.idfsSite = @DataEntrySiteID
                              OR @DataEntrySiteID IS NULL
                          )
                      AND (
                              v.strCaseID LIKE '%' + TRIM(@ReportID) + '%'
                              OR @ReportID IS NULL
                          )
                      AND (
                              v.LegacyCaseID LIKE '%' + TRIM(@LegacyReportID) + '%'
                              OR @LegacyReportID IS NULL
                          )
                      AND (
                              haai.EIDSSPersonID LIKE '%' + TRIM(@PersonID) + '%'
                              OR @PersonID IS NULL
                          )
                      AND (
                              m.strFieldBarcode LIKE '%' + TRIM(@LocalOrFieldSampleID) + '%'
                              OR @LocalOrFieldSampleID IS NULL
                          )
                      AND (
                              ms.strMonitoringSessionID LIKE '%' + TRIM(@SessionID) + '%'
                              OR @SessionID IS NULL
                          )
                GROUP BY v.idfVetCase;
            END
        END
        ELSE
        BEGIN
            IF @RecordIdentifierSearchIndicator = 1
            BEGIN
                INSERT INTO @Results
                SELECT v.idfVetCase,
                       1,
                       1,
                       1,
                       1,
                       1
                FROM dbo.tlbVetCase v
                WHERE v.intRowStatus = 0
                      AND (
                              v.strCaseID LIKE '%' + TRIM(@ReportID) + '%'
                              OR @ReportID IS NULL
                          )
                      AND (
                              v.LegacyCaseID LIKE '%' + TRIM(@LegacyReportID) + '%'
                              OR @LegacyReportID IS NULL
                          )
                GROUP BY v.idfVetCase;
            END
            ELSE
            BEGIN
                INSERT INTO @Results
                SELECT v.idfVetCase,
                       1,
                       1,
                       1,
                       1,
                       1
                FROM dbo.tlbVetCase v
                    INNER JOIN dbo.tlbFarm f
                        ON f.idfFarm = v.idfFarm
                    LEFT JOIN dbo.tlbHuman h
                        ON h.idfHuman = f.idfHuman
                    LEFT JOIN dbo.HumanActualAddlInfo haai
                        ON haai.HumanActualAddlInfoUID = h.idfHumanActual
                    LEFT JOIN dbo.tlbGeoLocation gl
                        ON gl.idfGeoLocation = f.idfFarmAddress
                    LEFT JOIN dbo.FN_GBL_LocationHierarchy_Flattened(@LanguageID) lh
                        ON lh.idfsLocation = gl.idfsLocation
                    LEFT JOIN dbo.tlbMaterial m
                        ON m.idfVetCase = v.idfVetCase
                    LEFT JOIN dbo.tlbMonitoringSession ms
                        ON ms.idfMonitoringSession = v.idfParentMonitoringSession
                WHERE v.intRowStatus = 0
                      AND v.idfsSite = @UserSiteID
                      AND (
                              f.idfFarmActual = @FarmMasterID
                              OR @FarmMasterID IS NULL
                          )
                      AND (
                              v.idfVetCase = @ReportKey
                              OR @ReportKey IS NULL
                          )
                      AND (
                              v.idfParentMonitoringSession = @SessionKey
                              OR @SessionKey IS NULL
                          )
                      AND (
                              lh.AdminLevel1ID = @AdministrativeLevelID
                              OR lh.AdminLevel2ID = @AdministrativeLevelID
                              OR lh.AdminLevel3ID = @AdministrativeLevelID
                              OR lh.AdminLevel4ID = @AdministrativeLevelID
                              OR lh.AdminLevel5ID = @AdministrativeLevelID
                              OR lh.AdminLevel6ID = @AdministrativeLevelID
                              OR lh.AdminLevel7ID = @AdministrativeLevelID
                              OR @AdministrativeLevelID IS NULL
                          )
                      AND (
                              v.idfsFinalDiagnosis = @DiseaseID
                              OR @DiseaseID IS NULL
                          )
                      AND (
                              v.idfsCaseClassification = @ClassificationTypeID
                              OR @ClassificationTypeID IS NULL
                          )
                      AND (
                              v.idfsCaseProgressStatus = @ReportStatusTypeID
                              OR @ReportStatusTypeID IS NULL
                          )
                      AND (
                              (CAST(v.datEnteredDate AS DATE)
                      BETWEEN @DateEnteredFrom AND @DateEnteredTo
                              )
                              OR (
                                     @DateEnteredFrom IS NULL
                                     OR @DateEnteredTo IS NULL
                                 )
                          )
                      AND (
                              v.idfsCaseReportType = @ReportTypeID
                              OR @ReportTypeID IS NULL
                          )
                      AND (
                              v.idfsCaseType = @SpeciesTypeID
                              OR @SpeciesTypeID IS NULL
                          )
                      AND (
                              (CAST(v.datFinalDiagnosisDate AS DATE)
                      BETWEEN @DiagnosisDateFrom AND @DiagnosisDateTo
                              )
                              OR (
                                     @DiagnosisDateFrom IS NULL
                                     OR @DiagnosisDateTo IS NULL
                                 )
                          )
                      AND (
                              (CAST(v.datInvestigationDate AS DATE)
                      BETWEEN @InvestigationDateFrom AND @InvestigationDateTo
                              )
                              OR (
                                     @InvestigationDateFrom IS NULL
                                     OR @InvestigationDateTo IS NULL
                                 )
                          )
                      AND (
                              (
                                  (f.intAvianTotalAnimalQty
                      BETWEEN @TotalAnimalQuantityFrom AND @TotalAnimalQuantityTo
                                  )
                                  OR (f.intLivestockTotalAnimalQty
                      BETWEEN @TotalAnimalQuantityFrom AND @TotalAnimalQuantityTo
                                     )
                              )
                              OR (
                                     @TotalAnimalQuantityFrom IS NULL
                                     OR @TotalAnimalQuantityTo IS NULL
                                 )
                          )
                      AND (
                              (
                                  v.idfOutbreak IS NULL
                                  AND @OutbreakCasesIndicator = 0
                              )
                              OR (
                                     v.idfOutbreak IS NOT NULL
                                     AND @OutbreakCasesIndicator = 1
                                 )
                              OR (@OutbreakCasesIndicator IS NULL)
                          )
                      AND (
                              v.idfsSite = @DataEntrySiteID
                              OR @DataEntrySiteID IS NULL
                          )
                      AND (
                              v.strCaseID LIKE '%' + TRIM(@ReportID) + '%'
                              OR @ReportID IS NULL
                          )
                      AND (
                              v.LegacyCaseID LIKE '%' + TRIM(@LegacyReportID) + '%'
                              OR @LegacyReportID IS NULL
                          )
                      AND (
                              haai.EIDSSPersonID LIKE '%' + TRIM(@PersonID) + '%'
                              OR @PersonID IS NULL
                          )
                      AND (
                              m.strFieldBarcode LIKE '%' + TRIM(@LocalOrFieldSampleID) + '%'
                              OR @LocalOrFieldSampleID IS NULL
                          )
                      AND (
                              ms.strMonitoringSessionID LIKE '%' + TRIM(@SessionID) + '%'
                              OR @SessionID IS NULL
                          )
                GROUP BY v.idfVetCase;
            END

            DECLARE @FilteredResults TABLE
            (
                ID BIGINT NOT NULL INDEX IX1 CLUSTERED,
                ReadPermissionIndicator INT NOT NULL,
                AccessToPersonalDataPermissionIndicator INT NOT NULL,
                AccessToGenderAndAgeDataPermissionIndicator INT NOT NULL,
                WritePermissionIndicator INT NOT NULL,
                DeletePermissionIndicator INT NOT NULL
            );

            -- =======================================================================================
            -- DEFAULT CONFIGURABLE FILTRATION RULES
            --
            -- Apply active default filtration rules for third level sites.
            -- =======================================================================================
            DECLARE @RuleActiveStatus INT = 0,
                    @AdministrativeLevelTypeID INT,
                    @OrganizationAdministrativeLevelID BIGINT,
                    @LanguageCode BIGINT = dbo.FN_GBL_LanguageCode_GET(@LanguageID);
            DECLARE @DefaultAccessRules TABLE
            (
                AccessRuleID BIGINT NOT NULL,
                ActiveIndicator INT NOT NULL,
                ReadPermissionIndicator INT NOT NULL,
                AccessToPersonalDataPermissionIndicator INT NOT NULL,
                AccessToGenderAndAgeDataPermissionIndicator INT NOT NULL,
                WritePermissionIndicator INT NOT NULL,
                DeletePermissionIndicator INT NOT NULL,
                AdministrativeLevelTypeID INT NULL
            );

            INSERT INTO @DefaultAccessRules
            SELECT AccessRuleID,
                   a.intRowStatus,
                   a.ReadPermissionIndicator,
                   a.AccessToPersonalDataPermissionIndicator,
                   a.AccessToGenderAndAgeDataPermissionIndicator,
                   a.WritePermissionIndicator,
                   a.DeletePermissionIndicator,
                   a.AdministrativeLevelTypeID
            FROM dbo.AccessRule a
            WHERE DefaultRuleIndicator = 1;

            --
            -- Report data shall be available to all sites of the same administrative level 
            -- specified in the rule.
            --
            SELECT @RuleActiveStatus = ActiveIndicator
            FROM @DefaultAccessRules
            WHERE AccessRuleID = 10537009;

            IF @RuleActiveStatus = 0
            BEGIN
                SELECT @AdministrativeLevelTypeID = AdministrativeLevelTypeID
                FROM @DefaultAccessRules
                WHERE AccessRuleID = 10537009;

                SELECT @OrganizationAdministrativeLevelID = CASE
                                                                WHEN @AdministrativeLevelTypeID = 1 THEN
                                                                    g.Level1ID
                                                                WHEN @AdministrativeLevelTypeID = 2 THEN
                                                                    g.Level2ID
                                                                WHEN @AdministrativeLevelTypeID = 3 THEN
                                                                    g.Level3ID
                                                                WHEN @AdministrativeLevelTypeID = 4 THEN
                                                                    g.Level4ID
                                                                WHEN @AdministrativeLevelTypeID = 5 THEN
                                                                    g.Level5ID
                                                                WHEN @AdministrativeLevelTypeID = 6 THEN
                                                                    g.Level6ID
                                                                WHEN @AdministrativeLevelTypeID = 7 THEN
                                                                    g.Level7ID
                                                            END
                FROM dbo.tlbOffice o
                    INNER JOIN dbo.tlbGeoLocationShared l
                        ON l.idfGeoLocationShared = o.idfLocation
                    INNER JOIN dbo.gisLocationDenormalized g
                        ON g.idfsLocation = l.idfsLocation
                           AND g.idfsLanguage = @LanguageCode
                WHERE o.idfOffice = @UserOrganizationID
                      AND g.node.GetLevel() >= @AdministrativeLevelTypeID;

                -- Administrative level specified in the rule of the site where the report was created.
                INSERT INTO @FilteredResults
                SELECT v.idfVetCase,
                       a.ReadPermissionIndicator,
                       a.AccessToPersonalDataPermissionIndicator,
                       a.AccessToGenderAndAgeDataPermissionIndicator,
                       a.WritePermissionIndicator,
                       a.DeletePermissionIndicator
                FROM dbo.tlbVetCase v
                    INNER JOIN dbo.tstSite s
                        ON v.idfsSite = s.idfsSite
                    INNER JOIN dbo.tlbOffice o
                        ON o.idfOffice = s.idfOffice
                    INNER JOIN dbo.tlbGeoLocationShared l
                        ON l.idfGeoLocationShared = o.idfLocation
                    INNER JOIN dbo.gisLocationDenormalized g
                        ON g.idfsLocation = l.idfsLocation
                           AND g.idfsLanguage = @LanguageCode
                    INNER JOIN @DefaultAccessRules a
                        ON a.AccessRuleID = 10537009
                WHERE v.intRowStatus = 0
                      AND (
                              v.idfsCaseType = @SpeciesTypeID
                              OR @SpeciesTypeID IS NULL
                          )
                      AND (
                              (CAST(v.datEnteredDate AS DATE)
                      BETWEEN @DateEnteredFrom AND @DateEnteredTo
                              )
                              OR (
                                     @DateEnteredFrom IS NULL
                                     OR @DateEnteredTo IS NULL
                                 )
                          )
                      AND (
                              g.Level1ID = @OrganizationAdministrativeLevelID
                              AND @AdministrativeLevelTypeID = 1
                              OR g.Level2ID = @OrganizationAdministrativeLevelID
                                 AND @AdministrativeLevelTypeID = 2
                              OR g.Level3ID = @OrganizationAdministrativeLevelID
                                 AND @AdministrativeLevelTypeID = 3
                              OR g.Level4ID = @OrganizationAdministrativeLevelID
                                 AND @AdministrativeLevelTypeID = 4
                              OR g.Level5ID = @OrganizationAdministrativeLevelID
                                 AND @AdministrativeLevelTypeID = 5
                              OR g.Level6ID = @OrganizationAdministrativeLevelID
                                 AND @AdministrativeLevelTypeID = 6
                              OR g.Level7ID = @OrganizationAdministrativeLevelID
                                 AND @AdministrativeLevelTypeID = 7
                          );

                -- Administrative level specified in the rule of the farm address.
                INSERT INTO @FilteredResults
                SELECT v.idfVetCase,
                       a.ReadPermissionIndicator,
                       a.AccessToPersonalDataPermissionIndicator,
                       a.AccessToGenderAndAgeDataPermissionIndicator,
                       a.WritePermissionIndicator,
                       a.DeletePermissionIndicator
                FROM dbo.tlbVetCase v
                    INNER JOIN dbo.tlbFarm f
                        ON f.idfFarm = v.idfFarm
                    INNER JOIN dbo.tlbGeoLocation l
                        ON l.idfGeoLocation = f.idfFarmAddress
                    INNER JOIN dbo.gisLocationDenormalized g
                        ON g.idfsLocation = l.idfsLocation
                           AND g.idfsLanguage = @LanguageCode
                    INNER JOIN @DefaultAccessRules a
                        ON a.AccessRuleID = 10537009
                WHERE v.intRowStatus = 0
                      AND (
                              v.idfsCaseType = @SpeciesTypeID
                              OR @SpeciesTypeID IS NULL
                          )
                      AND (
                              (CAST(v.datEnteredDate AS DATE)
                      BETWEEN @DateEnteredFrom AND @DateEnteredTo
                              )
                              OR (
                                     @DateEnteredFrom IS NULL
                                     OR @DateEnteredTo IS NULL
                                 )
                          )
                      AND (
                              g.Level1ID = @OrganizationAdministrativeLevelID
                              AND @AdministrativeLevelTypeID = 1
                              OR g.Level2ID = @OrganizationAdministrativeLevelID
                                 AND @AdministrativeLevelTypeID = 2
                              OR g.Level3ID = @OrganizationAdministrativeLevelID
                                 AND @AdministrativeLevelTypeID = 3
                              OR g.Level4ID = @OrganizationAdministrativeLevelID
                                 AND @AdministrativeLevelTypeID = 4
                              OR g.Level5ID = @OrganizationAdministrativeLevelID
                                 AND @AdministrativeLevelTypeID = 5
                              OR g.Level6ID = @OrganizationAdministrativeLevelID
                                 AND @AdministrativeLevelTypeID = 6
                              OR g.Level7ID = @OrganizationAdministrativeLevelID
                                 AND @AdministrativeLevelTypeID = 7
                          );
            END;

            --
            -- Report data shall be available to all sites' organizations connected to the particular report.
            --
            SELECT @RuleActiveStatus = ActiveIndicator
            FROM @DefaultAccessRules
            WHERE AccessRuleID = 10537010;

            IF @RuleActiveStatus = 0
            BEGIN
                -- Investigated and reported by organizations
                INSERT INTO @FilteredResults
                SELECT v.idfVetCase,
                       a.ReadPermissionIndicator,
                       a.AccessToPersonalDataPermissionIndicator,
                       a.AccessToGenderAndAgeDataPermissionIndicator,
                       a.WritePermissionIndicator,
                       a.DeletePermissionIndicator
                FROM dbo.tlbVetCase v
                    INNER JOIN @DefaultAccessRules a
                        ON a.AccessRuleID = 10537010
                WHERE (v.intRowStatus = 0)
                      AND (
                              v.idfInvestigatedByOffice = @UserOrganizationID
                              OR v.idfReportedByOffice = @UserOrganizationID
                          );

                -- Sample collected by and sent to organizations
                INSERT INTO @FilteredResults
                SELECT MAX(m.idfVetCase),
                       a.ReadPermissionIndicator,
                       a.AccessToPersonalDataPermissionIndicator,
                       a.AccessToGenderAndAgeDataPermissionIndicator,
                       a.WritePermissionIndicator,
                       a.DeletePermissionIndicator
                FROM dbo.tlbMaterial m
                    INNER JOIN dbo.tlbVetCase v
                        ON v.idfVetCase = m.idfVetCase
                           AND v.intRowStatus = 0
                    INNER JOIN @DefaultAccessRules a
                        ON a.AccessRuleID = 10537010
                WHERE m.intRowStatus = 0
                      AND (
                              m.idfFieldCollectedByOffice = @UserOrganizationID
                              OR m.idfSendToOffice = @UserOrganizationID
                          )
                GROUP BY m.idfVetCase,
                         a.ReadPermissionIndicator,
                         a.AccessToPersonalDataPermissionIndicator,
                         a.AccessToGenderAndAgeDataPermissionIndicator,
                         a.WritePermissionIndicator,
                         a.DeletePermissionIndicator;

                -- Sample transferred to organizations
                INSERT INTO @FilteredResults
                SELECT MAX(m.idfVetCase),
                       a.ReadPermissionIndicator,
                       a.AccessToPersonalDataPermissionIndicator,
                       a.AccessToGenderAndAgeDataPermissionIndicator,
                       a.WritePermissionIndicator,
                       a.DeletePermissionIndicator
                FROM dbo.tlbMaterial m
                    INNER JOIN dbo.tlbVetCase v
                        ON v.idfVetCase = m.idfVetCase
                           AND v.intRowStatus = 0
                    INNER JOIN dbo.tlbTransferOutMaterial tom
                        ON m.idfMaterial = tom.idfMaterial
                           AND tom.intRowStatus = 0
                    INNER JOIN dbo.tlbTransferOUT t
                        ON tom.idfTransferOut = t.idfTransferOut
                           AND t.intRowStatus = 0
                    INNER JOIN @DefaultAccessRules a
                        ON a.AccessRuleID = 10537010
                WHERE m.intRowStatus = 0
                      AND t.idfSendToOffice = @UserOrganizationID
                GROUP BY m.idfVetCase,
                         a.ReadPermissionIndicator,
                         a.AccessToPersonalDataPermissionIndicator,
                         a.AccessToGenderAndAgeDataPermissionIndicator,
                         a.WritePermissionIndicator,
                         a.DeletePermissionIndicator;
            END;

            --
            -- Report data shall be available to the sites with the connected outbreak, if the report 
            -- is the primary report/session for an outbreak.
            --
            SELECT @RuleActiveStatus = ActiveIndicator
            FROM @DefaultAccessRules
            WHERE AccessRuleID = 10537011;

            IF @RuleActiveStatus = 0
            BEGIN
                INSERT INTO @FilteredResults
                SELECT v.idfVetCase,
                       a.ReadPermissionIndicator,
                       a.AccessToPersonalDataPermissionIndicator,
                       a.AccessToGenderAndAgeDataPermissionIndicator,
                       a.WritePermissionIndicator,
                       a.DeletePermissionIndicator
                FROM dbo.tlbVetCase v
                    INNER JOIN dbo.tlbOutbreak o
                        ON v.idfVetCase = o.idfPrimaryCaseOrSession
                           AND o.intRowStatus = 0
                    INNER JOIN @DefaultAccessRules a
                        ON a.AccessRuleID = 10537011
                WHERE v.intRowStatus = 0
                      AND o.idfsSite = @UserSiteID
            END;

            -- =======================================================================================
            -- CONFIGURABLE FILTRATION RULES
            -- 
            -- Apply configurable filtration rules for use case SAUC34. Some of these rules may 
            -- overlap the default rules.
            -- =======================================================================================
            --
            -- Apply at the user's site group level, granted by a site group.
            --
            INSERT INTO @FilteredResults
            SELECT v.idfVetCase,
                   a.ReadPermissionIndicator,
                   a.AccessToPersonalDataPermissionIndicator,
                   a.AccessToGenderAndAgeDataPermissionIndicator,
                   a.WritePermissionIndicator,
                   a.DeletePermissionIndicator
            FROM dbo.tlbVetCase v
                INNER JOIN dbo.tflSiteToSiteGroup grantingSGS
                    ON grantingSGS.idfsSite = v.idfsSite
                INNER JOIN dbo.tflSiteToSiteGroup userSiteGroup
                    ON userSiteGroup.idfsSite = @UserSiteID
                INNER JOIN dbo.AccessRuleActor ara
                    ON ara.ActorSiteGroupID = userSiteGroup.idfSiteGroup
                       AND ara.intRowStatus = 0
                INNER JOIN dbo.AccessRule a
                    ON a.AccessRuleID = ara.AccessRuleID
                       AND a.intRowStatus = 0
                       AND a.DefaultRuleIndicator = 0
            WHERE v.intRowStatus = 0
                  AND a.GrantingActorSiteGroupID = grantingSGS.idfSiteGroup;

            --
            -- Apply at the user's site level, granted by a site group.
            --
            INSERT INTO @FilteredResults
            SELECT v.idfVetCase,
                   a.ReadPermissionIndicator,
                   a.AccessToPersonalDataPermissionIndicator,
                   a.AccessToGenderAndAgeDataPermissionIndicator,
                   a.WritePermissionIndicator,
                   a.DeletePermissionIndicator
            FROM dbo.tlbVetCase v
                INNER JOIN dbo.tflSiteToSiteGroup grantingSGS
                    ON grantingSGS.idfsSite = v.idfsSite
                INNER JOIN dbo.AccessRuleActor ara
                    ON ara.ActorSiteID = @UserSiteID
                       AND ara.ActorEmployeeGroupID IS NULL
                       AND ara.intRowStatus = 0
                INNER JOIN dbo.AccessRule a
                    ON a.AccessRuleID = ara.AccessRuleID
                       AND a.intRowStatus = 0
                       AND a.DefaultRuleIndicator = 0
            WHERE v.intRowStatus = 0
                  AND a.GrantingActorSiteGroupID = grantingSGS.idfSiteGroup;

            -- 
            -- Apply at the user's employee group level, granted by a site group.
            --
            INSERT INTO @FilteredResults
            SELECT v.idfVetCase,
                   a.ReadPermissionIndicator,
                   a.AccessToPersonalDataPermissionIndicator,
                   a.AccessToGenderAndAgeDataPermissionIndicator,
                   a.WritePermissionIndicator,
                   a.DeletePermissionIndicator
            FROM dbo.tlbVetCase v
                INNER JOIN dbo.tflSiteToSiteGroup grantingSGS
                    ON grantingSGS.idfsSite = v.idfsSite
                INNER JOIN dbo.tlbEmployeeGroupMember egm
                    ON egm.idfEmployee = @UserEmployeeID
                       AND egm.intRowStatus = 0
                INNER JOIN dbo.AccessRuleActor ara
                    ON ara.ActorEmployeeGroupID = egm.idfEmployeeGroup
                       AND ara.intRowStatus = 0
                INNER JOIN dbo.AccessRule a
                    ON a.AccessRuleID = ara.AccessRuleID
                       AND a.intRowStatus = 0
                       AND a.DefaultRuleIndicator = 0
            WHERE v.intRowStatus = 0
                  AND a.GrantingActorSiteGroupID = grantingSGS.idfSiteGroup;

            -- 
            -- Apply at the user's ID level, granted by a site group.
            --
            INSERT INTO @FilteredResults
            SELECT v.idfVetCase,
                   a.ReadPermissionIndicator,
                   a.AccessToPersonalDataPermissionIndicator,
                   a.AccessToGenderAndAgeDataPermissionIndicator,
                   a.WritePermissionIndicator,
                   a.DeletePermissionIndicator
            FROM dbo.tlbVetCase v
                INNER JOIN dbo.tflSiteToSiteGroup grantingSGS
                    ON grantingSGS.idfsSite = v.idfsSite
                INNER JOIN dbo.tstUserTable u
                    ON u.idfPerson = @UserEmployeeID
                       AND u.intRowStatus = 0
                INNER JOIN dbo.AccessRuleActor ara
                    ON ara.ActorUserID = u.idfUserID
                       AND ara.intRowStatus = 0
                INNER JOIN dbo.AccessRule a
                    ON a.AccessRuleID = ara.AccessRuleID
                       AND a.intRowStatus = 0
                       AND a.DefaultRuleIndicator = 0
            WHERE v.intRowStatus = 0
                  AND a.GrantingActorSiteGroupID = grantingSGS.idfSiteGroup;

            --
            -- Apply at the user's site group level, granted by a site.
            --
            INSERT INTO @FilteredResults
            SELECT v.idfVetCase,
                   a.ReadPermissionIndicator,
                   a.AccessToPersonalDataPermissionIndicator,
                   a.AccessToGenderAndAgeDataPermissionIndicator,
                   a.WritePermissionIndicator,
                   a.DeletePermissionIndicator
            FROM dbo.tlbVetCase v
                INNER JOIN dbo.tflSiteToSiteGroup sgs
                    ON sgs.idfsSite = @UserSiteID
                INNER JOIN dbo.AccessRuleActor ara
                    ON ara.ActorSiteGroupID = sgs.idfSiteGroup
                       AND ara.intRowStatus = 0
                INNER JOIN dbo.AccessRule a
                    ON a.AccessRuleID = ara.AccessRuleID
                       AND a.intRowStatus = 0
                       AND a.DefaultRuleIndicator = 0
            WHERE v.intRowStatus = 0
                  AND sgs.idfsSite = v.idfsSite;

            -- 
            -- Apply at the user's site level, granted by a site.
            --
            INSERT INTO @FilteredResults
            SELECT v.idfVetCase,
                   a.ReadPermissionIndicator,
                   a.AccessToPersonalDataPermissionIndicator,
                   a.AccessToGenderAndAgeDataPermissionIndicator,
                   a.WritePermissionIndicator,
                   a.DeletePermissionIndicator
            FROM dbo.tlbVetCase v
                INNER JOIN dbo.AccessRuleActor ara
                    ON ara.ActorSiteID = @UserSiteID
                       AND ara.ActorEmployeeGroupID IS NULL
                       AND ara.intRowStatus = 0
                INNER JOIN dbo.AccessRule a
                    ON a.AccessRuleID = ara.AccessRuleID
                       AND a.intRowStatus = 0
                       AND a.DefaultRuleIndicator = 0
            WHERE v.intRowStatus = 0
                  AND a.GrantingActorSiteID = v.idfsSite;

            -- 
            -- Apply at the user's employee group level, granted by a site.
            --
            INSERT INTO @FilteredResults
            SELECT v.idfVetCase,
                   a.ReadPermissionIndicator,
                   a.AccessToPersonalDataPermissionIndicator,
                   a.AccessToGenderAndAgeDataPermissionIndicator,
                   a.WritePermissionIndicator,
                   a.DeletePermissionIndicator
            FROM dbo.tlbVetCase v
                INNER JOIN dbo.tlbEmployeeGroupMember egm
                    ON egm.idfEmployee = @UserEmployeeID
                       AND egm.intRowStatus = 0
                INNER JOIN dbo.AccessRuleActor ara
                    ON ara.ActorEmployeeGroupID = egm.idfEmployeeGroup
                       AND ara.intRowStatus = 0
                INNER JOIN dbo.AccessRule a
                    ON a.AccessRuleID = ara.AccessRuleID
                       AND a.intRowStatus = 0
                       AND a.DefaultRuleIndicator = 0
            WHERE v.intRowStatus = 0
                  AND a.GrantingActorSiteID = v.idfsSite;

            -- 
            -- Apply at the user's ID level, granted by a site.
            --
            INSERT INTO @FilteredResults
            SELECT v.idfVetCase,
                   a.ReadPermissionIndicator,
                   a.AccessToPersonalDataPermissionIndicator,
                   a.AccessToGenderAndAgeDataPermissionIndicator,
                   a.WritePermissionIndicator,
                   a.DeletePermissionIndicator
            FROM dbo.tlbVetCase v
                INNER JOIN dbo.tstUserTable u
                    ON u.idfPerson = @UserEmployeeID
                       AND u.intRowStatus = 0
                INNER JOIN dbo.AccessRuleActor ara
                    ON ara.ActorUserID = u.idfUserID
                       AND ara.intRowStatus = 0
                INNER JOIN dbo.AccessRule a
                    ON a.AccessRuleID = ara.AccessRuleID
                       AND a.intRowStatus = 0
                       AND a.DefaultRuleIndicator = 0
            WHERE v.intRowStatus = 0
                  AND a.GrantingActorSiteID = v.idfsSite;

            -- Copy filtered results to results and use search criteria
            INSERT INTO @Results
            SELECT ID,
                   ReadPermissionIndicator,
                   AccessToPersonalDataPermissionIndicator,
                   AccessToGenderAndAgeDataPermissionIndicator,
                   WritePermissionIndicator,
                   DeletePermissionIndicator
            FROM @FilteredResults
                INNER JOIN dbo.tlbVetCase v
                    ON v.idfVetCase = ID
                INNER JOIN dbo.tlbFarm f
                    ON f.idfFarm = v.idfFarm
                LEFT JOIN dbo.tlbHuman h
                    ON h.idfHuman = f.idfHuman
                LEFT JOIN dbo.HumanActualAddlInfo haai
                    ON haai.HumanActualAddlInfoUID = h.idfHumanActual
                LEFT JOIN dbo.tlbGeoLocation gl
                    ON gl.idfGeoLocation = f.idfFarmAddress
                LEFT JOIN dbo.FN_GBL_LocationHierarchy_Flattened(@LanguageID) lh
                    ON lh.idfsLocation = gl.idfsLocation
                LEFT JOIN dbo.tlbMaterial m
                    ON m.idfVetCase = v.idfVetCase
                LEFT JOIN dbo.tlbMonitoringSession ms
                    ON ms.idfMonitoringSession = v.idfParentMonitoringSession
            WHERE v.intRowStatus = 0
                  AND (
                          f.idfFarmActual = @FarmMasterID
                          OR @FarmMasterID IS NULL
                      )
                  AND (
                          v.idfVetCase = @ReportKey
                          OR @ReportKey IS NULL
                      )
                  AND (
                          v.idfParentMonitoringSession = @SessionKey
                          OR @SessionKey IS NULL
                      )
                  AND (
                          lh.AdminLevel1ID = @AdministrativeLevelID
                          OR lh.AdminLevel2ID = @AdministrativeLevelID
                          OR lh.AdminLevel3ID = @AdministrativeLevelID
                          OR lh.AdminLevel4ID = @AdministrativeLevelID
                          OR lh.AdminLevel5ID = @AdministrativeLevelID
                          OR lh.AdminLevel6ID = @AdministrativeLevelID
                          OR lh.AdminLevel7ID = @AdministrativeLevelID
                          OR @AdministrativeLevelID IS NULL
                      )
                  AND (
                          v.idfsFinalDiagnosis = @DiseaseID
                          OR @DiseaseID IS NULL
                      )
                  AND (
                          v.idfsCaseClassification = @ClassificationTypeID
                          OR @ClassificationTypeID IS NULL
                      )
                  AND (
                          v.idfsCaseProgressStatus = @ReportStatusTypeID
                          OR @ReportStatusTypeID IS NULL
                      )
                  AND (
                          (CAST(v.datEnteredDate AS DATE)
                  BETWEEN @DateEnteredFrom AND @DateEnteredTo
                          )
                          OR (
                                 @DateEnteredFrom IS NULL
                                 OR @DateEnteredTo IS NULL
                             )
                      )
                  AND (
                          v.idfsCaseReportType = @ReportTypeID
                          OR @ReportTypeID IS NULL
                      )
                  AND (
                          v.idfsCaseType = @SpeciesTypeID
                          OR @SpeciesTypeID IS NULL
                      )
                  AND (
                          (CAST(v.datFinalDiagnosisDate AS DATE)
                  BETWEEN @DiagnosisDateFrom AND @DiagnosisDateTo
                          )
                          OR (
                                 @DiagnosisDateFrom IS NULL
                                 OR @DiagnosisDateTo IS NULL
                             )
                      )
                  AND (
                          (CAST(v.datInvestigationDate AS DATE)
                  BETWEEN @InvestigationDateFrom AND @InvestigationDateTo
                          )
                          OR (
                                 @InvestigationDateFrom IS NULL
                                 OR @InvestigationDateTo IS NULL
                             )
                      )
                  AND (
                          (
                              (f.intAvianTotalAnimalQty
                  BETWEEN @TotalAnimalQuantityFrom AND @TotalAnimalQuantityTo
                              )
                              OR (f.intLivestockTotalAnimalQty
                  BETWEEN @TotalAnimalQuantityFrom AND @TotalAnimalQuantityTo
                                 )
                          )
                          OR (
                                 @TotalAnimalQuantityFrom IS NULL
                                 OR @TotalAnimalQuantityTo IS NULL
                             )
                      )
                  AND (
                          (
                              v.idfOutbreak IS NULL
                              AND @OutbreakCasesIndicator = 0
                          )
                          OR (
                                 v.idfOutbreak IS NOT NULL
                                 AND @OutbreakCasesIndicator = 1
                             )
                          OR (@OutbreakCasesIndicator IS NULL)
                      )
                  AND (
                          v.idfsSite = @DataEntrySiteID
                          OR @DataEntrySiteID IS NULL
                      )
                  AND (
                          v.strCaseID LIKE '%' + TRIM(@ReportID) + '%'
                          OR @ReportID IS NULL
                      )
                  AND (
                          v.LegacyCaseID LIKE '%' + TRIM(@LegacyReportID) + '%'
                          OR @LegacyReportID IS NULL
                      )
                  AND (
                          haai.EIDSSPersonID LIKE '%' + TRIM(@PersonID) + '%'
                          OR @PersonID IS NULL
                      )
                  AND (
                          m.strFieldBarcode LIKE '%' + TRIM(@LocalOrFieldSampleID) + '%'
                          OR @LocalOrFieldSampleID IS NULL
                      )
                  AND (
                          ms.strMonitoringSessionID LIKE '%' + TRIM(@SessionID) + '%'
                          OR @SessionID IS NULL
                      )
            GROUP BY ID,
                     ReadPermissionIndicator,
                     AccessToPersonalDataPermissionIndicator,
                     AccessToGenderAndAgeDataPermissionIndicator,
                     WritePermissionIndicator,
                     DeletePermissionIndicator;
        END;

        -- =======================================================================================
        -- DISEASE FILTRATION RULES
        --
        -- Apply disease filtration rules from use case SAUC62.
        -- =======================================================================================
        -- 
        -- Apply level 0 disease filtration rules for the employee default user group - Denies ONLY
        -- as all records have been pulled above with or without site filtration rules applied.
        --
        DELETE FROM @Results
        WHERE ID IN (
                        SELECT v.idfVetCase
                        FROM dbo.tlbVetCase v
                            INNER JOIN dbo.tstObjectAccess oa
                                ON oa.idfsObjectID = v.idfsFinalDiagnosis
                                   AND oa.intRowStatus = 0
                        WHERE oa.intPermission = 1
                              AND oa.idfActor = -506 -- Default role
                    );

        --
        -- Apply level 1 disease filtration rules for an employee's associated user group(s).  
        -- Allows and denies will supersede level 0.
        --
        INSERT INTO @Results
        SELECT v.idfVetCase,
               1,
               1,
               1,
               1,
               1
        FROM dbo.tlbVetCase v
            INNER JOIN dbo.tstObjectAccess oa
                ON oa.idfsObjectID = v.idfsFinalDiagnosis
                   AND oa.intRowStatus = 0
            INNER JOIN dbo.tlbEmployeeGroupMember egm
                ON egm.idfEmployee = @UserEmployeeID
                   AND egm.intRowStatus = 0
            INNER JOIN dbo.tlbFarm f
                ON f.idfFarm = v.idfFarm
            LEFT JOIN dbo.tlbHuman h
                ON h.idfHuman = f.idfHuman
            LEFT JOIN dbo.HumanActualAddlInfo haai
                ON haai.HumanActualAddlInfoUID = h.idfHumanActual
            LEFT JOIN dbo.tlbGeoLocation gl
                ON gl.idfGeoLocation = f.idfFarmAddress
            LEFT JOIN dbo.FN_GBL_LocationHierarchy_Flattened(@LanguageID) lh
                ON lh.idfsLocation = gl.idfsLocation
            LEFT JOIN dbo.tlbMaterial m
                ON m.idfVetCase = v.idfVetCase
                   AND m.intRowStatus = 0
            LEFT JOIN dbo.tlbMonitoringSession ms
                ON ms.idfMonitoringSession = v.idfParentMonitoringSession
                   AND ms.intRowStatus = 0
        WHERE oa.intPermission = 2 -- Allow permission
              AND v.intRowStatus = 0
              AND oa.idfActor = egm.idfEmployeeGroup
              AND (
                      f.idfFarmActual = @FarmMasterID
                      OR @FarmMasterID IS NULL
                  )
              AND (
                      v.idfVetCase = @ReportKey
                      OR @ReportKey IS NULL
                  )
              AND (
                      v.idfParentMonitoringSession = @SessionKey
                      OR @SessionKey IS NULL
                  )
              AND (
                      lh.AdminLevel1ID = @AdministrativeLevelID
                      OR lh.AdminLevel2ID = @AdministrativeLevelID
                      OR lh.AdminLevel3ID = @AdministrativeLevelID
                      OR lh.AdminLevel4ID = @AdministrativeLevelID
                      OR lh.AdminLevel5ID = @AdministrativeLevelID
                      OR lh.AdminLevel6ID = @AdministrativeLevelID
                      OR lh.AdminLevel7ID = @AdministrativeLevelID
                      OR @AdministrativeLevelID IS NULL
                  )
              AND (
                      v.idfsFinalDiagnosis = @DiseaseID
                      OR @DiseaseID IS NULL
                  )
              AND (
                      v.idfsCaseClassification = @ClassificationTypeID
                      OR @ClassificationTypeID IS NULL
                  )
              AND (
                      v.idfsCaseProgressStatus = @ReportStatusTypeID
                      OR @ReportStatusTypeID IS NULL
                  )
              AND (
                      (CAST(v.datEnteredDate AS DATE)
              BETWEEN @DateEnteredFrom AND @DateEnteredTo
                      )
                      OR (
                             @DateEnteredFrom IS NULL
                             OR @DateEnteredTo IS NULL
                         )
                  )
              AND (
                      v.idfsCaseReportType = @ReportTypeID
                      OR @ReportTypeID IS NULL
                  )
              AND (
                      v.idfsCaseType = @SpeciesTypeID
                      OR @SpeciesTypeID IS NULL
                  )
              AND (
                      (CAST(v.datFinalDiagnosisDate AS DATE)
              BETWEEN @DiagnosisDateFrom AND @DiagnosisDateTo
                      )
                      OR (
                             @DiagnosisDateFrom IS NULL
                             OR @DiagnosisDateTo IS NULL
                         )
                  )
              AND (
                      (CAST(v.datInvestigationDate AS DATE)
              BETWEEN @InvestigationDateFrom AND @InvestigationDateTo
                      )
                      OR (
                             @InvestigationDateFrom IS NULL
                             OR @InvestigationDateTo IS NULL
                         )
                  )
              AND (
                      (
                          (f.intAvianTotalAnimalQty
              BETWEEN @TotalAnimalQuantityFrom AND @TotalAnimalQuantityTo
                          )
                          OR (f.intLivestockTotalAnimalQty
              BETWEEN @TotalAnimalQuantityFrom AND @TotalAnimalQuantityTo
                             )
                      )
                      OR (
                             @TotalAnimalQuantityFrom IS NULL
                             OR @TotalAnimalQuantityTo IS NULL
                         )
                  )
              AND (
                      (
                          v.idfOutbreak IS NULL
                          AND @OutbreakCasesIndicator = 0
                      )
                      OR (
                             v.idfOutbreak IS NOT NULL
                             AND @OutbreakCasesIndicator = 1
                         )
                      OR (@OutbreakCasesIndicator IS NULL)
                  )
              AND (
                      v.idfsSite = @DataEntrySiteID
                      OR @DataEntrySiteID IS NULL
                  )
              AND (
                      v.strCaseID LIKE '%' + TRIM(@ReportID) + '%'
                      OR @ReportID IS NULL
                  )
              AND (
                      v.LegacyCaseID LIKE '%' + TRIM(@LegacyReportID) + '%'
                      OR @LegacyReportID IS NULL
                  )
              AND (
                      haai.EIDSSPersonID LIKE '%' + TRIM(@PersonID) + '%'
                      OR @PersonID IS NULL
                  )
              AND (
                      m.strFieldBarcode LIKE '%' + TRIM(@LocalOrFieldSampleID) + '%'
                      OR @LocalOrFieldSampleID IS NULL
                  )
              AND (
                      ms.strMonitoringSessionID LIKE '%' + TRIM(@SessionID) + '%'
                      OR @SessionID IS NULL
                  )
        GROUP BY v.idfVetCase;

        DELETE res
        FROM @Results res
            INNER JOIN dbo.tlbVetCase v
                ON v.idfVetCase = res.ID
            INNER JOIN dbo.tlbEmployeeGroupMember egm
                ON egm.idfEmployee = @UserEmployeeID
                   AND egm.intRowStatus = 0
            INNER JOIN dbo.tstObjectAccess oa
                ON oa.idfsObjectID = v.idfsFinalDiagnosis
                   AND oa.intRowStatus = 0
        WHERE oa.intPermission = 1
              AND oa.idfsObjectType = 10060001 -- Disease
              AND oa.idfActor = egm.idfEmployeeGroup;

        --
        -- Apply level 2 disease filtration rules for the employee's identity.  Allows and denies 
        -- will supersede level 1.
        --
        INSERT INTO @Results
        SELECT v.idfVetCase,
               1,
               1,
               1,
               1,
               1
        FROM dbo.tlbVetCase v
            INNER JOIN dbo.tstObjectAccess oa
                ON oa.idfsObjectID = v.idfsFinalDiagnosis
                   AND oa.intRowStatus = 0
            INNER JOIN dbo.tlbFarm f
                ON f.idfFarm = v.idfFarm
            LEFT JOIN dbo.tlbHuman h
                ON h.idfHuman = f.idfHuman
            LEFT JOIN dbo.HumanActualAddlInfo haai
                ON haai.HumanActualAddlInfoUID = h.idfHumanActual
            LEFT JOIN dbo.tlbGeoLocation gl
                ON gl.idfGeoLocation = f.idfFarmAddress
            LEFT JOIN dbo.FN_GBL_LocationHierarchy_Flattened(@LanguageID) lh
                ON lh.idfsLocation = gl.idfsLocation
            LEFT JOIN dbo.tlbMaterial m
                ON m.idfVetCase = v.idfVetCase
                   AND m.intRowStatus = 0
            LEFT JOIN dbo.tlbMonitoringSession ms
                ON ms.idfMonitoringSession = v.idfParentMonitoringSession
                   AND ms.intRowStatus = 0
        WHERE oa.intPermission = 2 -- Allow permission
              AND v.intRowStatus = 0
              AND oa.idfsObjectType = 10060001 -- Disease
              AND oa.idfActor = @UserEmployeeID
              AND (
                      f.idfFarmActual = @FarmMasterID
                      OR @FarmMasterID IS NULL
                  )
              AND (
                      v.idfVetCase = @ReportKey
                      OR @ReportKey IS NULL
                  )
              AND (
                      v.idfParentMonitoringSession = @SessionKey
                      OR @SessionKey IS NULL
                  )
              AND (
                      lh.AdminLevel1ID = @AdministrativeLevelID
                      OR lh.AdminLevel2ID = @AdministrativeLevelID
                      OR lh.AdminLevel3ID = @AdministrativeLevelID
                      OR lh.AdminLevel4ID = @AdministrativeLevelID
                      OR lh.AdminLevel5ID = @AdministrativeLevelID
                      OR lh.AdminLevel6ID = @AdministrativeLevelID
                      OR lh.AdminLevel7ID = @AdministrativeLevelID
                      OR @AdministrativeLevelID IS NULL
                  )
              AND (
                      v.idfsFinalDiagnosis = @DiseaseID
                      OR @DiseaseID IS NULL
                  )
              AND (
                      v.idfsCaseClassification = @ClassificationTypeID
                      OR @ClassificationTypeID IS NULL
                  )
              AND (
                      v.idfsCaseProgressStatus = @ReportStatusTypeID
                      OR @ReportStatusTypeID IS NULL
                  )
              AND (
                      (CAST(v.datEnteredDate AS DATE)
              BETWEEN @DateEnteredFrom AND @DateEnteredTo
                      )
                      OR (
                             @DateEnteredFrom IS NULL
                             OR @DateEnteredTo IS NULL
                         )
                  )
              AND (
                      v.idfsCaseReportType = @ReportTypeID
                      OR @ReportTypeID IS NULL
                  )
              AND (
                      v.idfsCaseType = @SpeciesTypeID
                      OR @SpeciesTypeID IS NULL
                  )
              AND (
                      (CAST(v.datFinalDiagnosisDate AS DATE)
              BETWEEN @DiagnosisDateFrom AND @DiagnosisDateTo
                      )
                      OR (
                             @DiagnosisDateFrom IS NULL
                             OR @DiagnosisDateTo IS NULL
                         )
                  )
              AND (
                      (CAST(v.datInvestigationDate AS DATE)
              BETWEEN @InvestigationDateFrom AND @InvestigationDateTo
                      )
                      OR (
                             @InvestigationDateFrom IS NULL
                             OR @InvestigationDateTo IS NULL
                         )
                  )
              AND (
                      (
                          (f.intAvianTotalAnimalQty
              BETWEEN @TotalAnimalQuantityFrom AND @TotalAnimalQuantityTo
                          )
                          OR (f.intLivestockTotalAnimalQty
              BETWEEN @TotalAnimalQuantityFrom AND @TotalAnimalQuantityTo
                             )
                      )
                      OR (
                             @TotalAnimalQuantityFrom IS NULL
                             OR @TotalAnimalQuantityTo IS NULL
                         )
                  )
              AND (
                      (
                          v.idfOutbreak IS NULL
                          AND @OutbreakCasesIndicator = 0
                      )
                      OR (
                             v.idfOutbreak IS NOT NULL
                             AND @OutbreakCasesIndicator = 1
                         )
                      OR (@OutbreakCasesIndicator IS NULL)
                  )
              AND (
                      v.idfsSite = @DataEntrySiteID
                      OR @DataEntrySiteID IS NULL
                  )
              AND (
                      v.strCaseID LIKE '%' + TRIM(@ReportID) + '%'
                      OR @ReportID IS NULL
                  )
              AND (
                      v.LegacyCaseID LIKE '%' + TRIM(@LegacyReportID) + '%'
                      OR @LegacyReportID IS NULL
                  )
              AND (
                      haai.EIDSSPersonID LIKE '%' + TRIM(@PersonID) + '%'
                      OR @PersonID IS NULL
                  )
              AND (
                      m.strFieldBarcode LIKE '%' + TRIM(@LocalOrFieldSampleID) + '%'
                      OR @LocalOrFieldSampleID IS NULL
                  )
              AND (
                      ms.strMonitoringSessionID LIKE '%' + TRIM(@SessionID) + '%'
                      OR @SessionID IS NULL
                  )
        GROUP BY v.idfVetCase;

        DELETE FROM @Results
        WHERE ID IN (
                        SELECT v.idfVetCase
                        FROM dbo.tlbVetCase v
                            INNER JOIN dbo.tstObjectAccess oa
                                ON oa.idfsObjectID = v.idfsFinalDiagnosis
                                   AND oa.intRowStatus = 0
                        WHERE oa.intPermission = 1 -- Deny permission
                              AND oa.idfsObjectType = 10060001 -- Disease
                              AND oa.idfActor = @UserEmployeeID
                    );

        -- =======================================================================================
        -- SITE FILTRATION RULES
        --
        -- Apply site filtration rules from use case SAUC29.
        -- =======================================================================================
        -- 
        -- Apply level 0 site filtration rules for the employee default user group - Denies ONLY
        -- as all records have been pulled above with or without site filtration rules applied.
        --
        DELETE FROM @Results
        WHERE EXISTS
        (
            SELECT vc.idfVetCase
            FROM dbo.tlbVetCase vc
                INNER JOIN dbo.tstObjectAccess oa
                    ON oa.idfsObjectID = vc.idfsSite
                       AND oa.intRowStatus = 0
                INNER JOIN dbo.tlbEmployeeGroup eg
                    ON eg.idfsSite = @UserSiteID
                       AND eg.intRowStatus = 0
                INNER JOIN dbo.trtBaseReference br
                    ON br.idfsBaseReference = eg.idfEmployeeGroup
                       AND br.intRowStatus = 0
                       AND br.blnSystem = 1
            WHERE vc.intRowStatus = 0
                  AND oa.idfsObjectOperation = 10059003 -- Read permission
                  AND oa.intPermission = 1 -- Deny permission
                  AND oa.idfsObjectType = 10060011 -- Site
                  AND oa.idfActor = eg.idfEmployeeGroup
        );

        --
        -- Apply level 1 site filtration rules for an employee's associated user group(s).  
        -- Allows and denies will supersede level 0.
        --
        INSERT INTO @Results
        SELECT vc.idfVetCase,
               (
                   SELECT Permission
                   FROM @UserGroupSitePermissions
                   WHERE SiteID = vc.idfsSite
                         AND PermissionTypeID = 10059003
               ),
               (
                   SELECT Permission
                   FROM @UserGroupSitePermissions
                   WHERE SiteID = vc.idfsSite
                         AND PermissionTypeID = 10059006
               ),
               (
                   SELECT Permission
                   FROM @UserGroupSitePermissions
                   WHERE SiteID = vc.idfsSite
                         AND PermissionTypeID = 10059007
               ),
               (
                   SELECT Permission
                   FROM @UserGroupSitePermissions
                   WHERE SiteID = vc.idfsSite
                         AND PermissionTypeID = 10059004
               ),
               (
                   SELECT Permission
                   FROM @UserGroupSitePermissions
                   WHERE SiteID = vc.idfsSite
                         AND PermissionTypeID = 10059002
               )
        FROM dbo.tlbVetCase vc
            INNER JOIN dbo.tstObjectAccess oa
                ON oa.idfsObjectID = vc.idfsSite
                   AND oa.intRowStatus = 0
            INNER JOIN dbo.tlbEmployeeGroupMember egm
                ON egm.idfEmployee = @UserEmployeeID
                   AND egm.intRowStatus = 0
        WHERE vc.intRowStatus = 0
              AND EXISTS
        (
            SELECT * FROM @UserGroupSitePermissions WHERE SiteID = vc.idfsSite
        );

        DELETE res
        FROM @Results res
            INNER JOIN dbo.tlbVetCase vc
                ON vc.idfVetCase = res.ID
            INNER JOIN @UserGroupSitePermissions ugsp
                ON ugsp.SiteID = vc.idfsSite
        WHERE ugsp.Permission = 2 -- Deny permission
              AND ugsp.PermissionTypeID = 10059003; -- Read permission

        --
        -- Apply level 2 site filtration rules for the employee's identity.  Allows and denies 
        -- will supersede level 1.
        --
        INSERT INTO @Results
        SELECT vc.idfVetCase,
               (
                   SELECT Permission
                   FROM @UserSitePermissions
                   WHERE SiteID = vc.idfsSite
                         AND PermissionTypeID = 10059003
               ),
               (
                   SELECT Permission
                   FROM @UserSitePermissions
                   WHERE SiteID = vc.idfsSite
                         AND PermissionTypeID = 10059006
               ),
               (
                   SELECT Permission
                   FROM @UserSitePermissions
                   WHERE SiteID = vc.idfsSite
                         AND PermissionTypeID = 10059007
               ),
               (
                   SELECT Permission
                   FROM @UserSitePermissions
                   WHERE SiteID = vc.idfsSite
                         AND PermissionTypeID = 10059004
               ),
               (
                   SELECT Permission
                   FROM @UserSitePermissions
                   WHERE SiteID = vc.idfsSite
                         AND PermissionTypeID = 10059002
               )
        FROM dbo.tlbVetCase vc
        WHERE vc.intRowStatus = 0
              AND EXISTS
        (
            SELECT * FROM @UserSitePermissions WHERE SiteID = vc.idfsSite
        );

        DELETE FROM @Results
        WHERE EXISTS
        (
            SELECT vc.idfVetCase
            FROM dbo.tlbVetCase vc
                INNER JOIN @UserSitePermissions usp
                    ON usp.SiteID = vc.idfsSite
            WHERE usp.Permission = 4 -- Deny permission
                  AND usp.PermissionTypeID = 10059003 -- Read permission
        );

        -- ========================================================================================
        -- FINAL QUERY, PAGINATION AND COUNTS
        -- ========================================================================================
        INSERT INTO @FinalResults
        SELECT ID,
               MAX(res.ReadPermissionIndicator),
               MAX(res.AccessToPersonalDataPermissionIndicator),
               MAX(res.AccessToGenderAndAgeDataPermissionIndicator),
               MAX(res.WritePermissionIndicator),
               MAX(res.DeletePermissionIndicator)
        FROM @Results res
            INNER JOIN dbo.tlbVetCase v
                ON v.idfVetCase = res.ID
            INNER JOIN dbo.tlbFarm f
                ON f.idfFarm = v.idfFarm
            LEFT JOIN dbo.tlbHuman h
                ON h.idfHuman = f.idfHuman
            LEFT JOIN dbo.HumanActualAddlInfo haai
                ON haai.HumanActualAddlInfoUID = h.idfHumanActual
            LEFT JOIN dbo.tlbGeoLocation gl
                ON gl.idfGeoLocation = f.idfFarmAddress
            LEFT JOIN dbo.FN_GBL_LocationHierarchy_Flattened(@LanguageID) lh
                ON lh.idfsLocation = gl.idfsLocation
            LEFT JOIN dbo.tlbMaterial m
                ON m.idfVetCase = v.idfVetCase
                   AND m.intRowStatus = 0
            LEFT JOIN dbo.tlbMonitoringSession ms
                ON ms.idfMonitoringSession = v.idfParentMonitoringSession
                   AND ms.intRowStatus = 0
            --LEFT JOIN dbo.OutbreakCaseReport ocr
            --    ON ocr.idfOutbreak = v.idfOutbreak
            --       AND ocr.idfVetCase = v.idfVetCase 
        WHERE res.ReadPermissionIndicator IN ( 1, 3, 5 )
              AND (
                      f.idfFarmActual = @FarmMasterID
                      OR @FarmMasterID IS NULL
                  )
              AND (
                      v.idfVetCase = @ReportKey
                      OR @ReportKey IS NULL
                  )
              AND (
                      v.idfParentMonitoringSession = @SessionKey
                      OR @SessionKey IS NULL
                  )
              AND (
                      lh.AdminLevel1ID = @AdministrativeLevelID
                      OR lh.AdminLevel2ID = @AdministrativeLevelID
                      OR lh.AdminLevel3ID = @AdministrativeLevelID
                      OR lh.AdminLevel4ID = @AdministrativeLevelID
                      OR lh.AdminLevel5ID = @AdministrativeLevelID
                      OR lh.AdminLevel6ID = @AdministrativeLevelID
                      OR lh.AdminLevel7ID = @AdministrativeLevelID
                      OR @AdministrativeLevelID IS NULL
                  )
              AND (
                      v.idfsFinalDiagnosis = @DiseaseID
                      OR @DiseaseID IS NULL
                  )
              AND (
                      v.idfsCaseClassification = @ClassificationTypeID
                      OR @ClassificationTypeID IS NULL
                  )
              AND (
                      v.idfsCaseProgressStatus = @ReportStatusTypeID
                      OR @ReportStatusTypeID IS NULL
                  )
              AND (
                      (CAST(v.datEnteredDate AS DATE)
              BETWEEN @DateEnteredFrom AND @DateEnteredTo
                      )
                      OR (
                             @DateEnteredFrom IS NULL
                             OR @DateEnteredTo IS NULL
                         )
                  )
              AND (
                      v.idfsCaseReportType = @ReportTypeID
                      OR @ReportTypeID IS NULL
                  )
              AND (
                      v.idfsCaseType = @SpeciesTypeID
                      OR @SpeciesTypeID IS NULL
                  )
              AND (
                      (CAST(v.datFinalDiagnosisDate AS DATE)
              BETWEEN @DiagnosisDateFrom AND @DiagnosisDateTo
                      )
                      OR (
                             @DiagnosisDateFrom IS NULL
                             OR @DiagnosisDateTo IS NULL
                         )
                  )
              AND (
                      (CAST(v.datInvestigationDate AS DATE)
              BETWEEN @InvestigationDateFrom AND @InvestigationDateTo
                      )
                      OR (
                             @InvestigationDateFrom IS NULL
                             OR @InvestigationDateTo IS NULL
                         )
                  )
              AND (
                      (
                          (f.intAvianTotalAnimalQty
              BETWEEN @TotalAnimalQuantityFrom AND @TotalAnimalQuantityTo
                          )
                          OR (f.intLivestockTotalAnimalQty
              BETWEEN @TotalAnimalQuantityFrom AND @TotalAnimalQuantityTo
                             )
                      )
                      OR (
                             @TotalAnimalQuantityFrom IS NULL
                             OR @TotalAnimalQuantityTo IS NULL
                         )
                  )
              AND (
                      (
                          v.idfOutbreak IS NULL
                          AND @OutbreakCasesIndicator = 0
                      )
                      OR (
                             v.idfOutbreak IS NOT NULL
                             AND @OutbreakCasesIndicator = 1
                         )
                      OR (@OutbreakCasesIndicator IS NULL)
                  )
              AND (
                      v.idfsSite = @DataEntrySiteID
                      OR @DataEntrySiteID IS NULL
                  )
              AND (
                      v.strCaseID LIKE '%' + TRIM(@ReportID) + '%'
                      OR @ReportID IS NULL
                  )
              AND (
                      v.LegacyCaseID LIKE '%' + TRIM(@LegacyReportID) + '%'
                      OR @LegacyReportID IS NULL
                  )
              AND (
                      haai.EIDSSPersonID LIKE '%' + TRIM(@PersonID) + '%'
                      OR @PersonID IS NULL
                  )
              AND (
                      m.strFieldBarcode LIKE '%' + TRIM(@LocalOrFieldSampleID) + '%'
                      OR @LocalOrFieldSampleID IS NULL
                  )
              AND (
                      ms.strMonitoringSessionID LIKE '%' + TRIM(@SessionID) + '%'
                      OR @SessionID IS NULL
                  )
              AND 
              (
                  (
                      v.idfOutbreak IS NULL
                      AND @OutbreakCaseReportOnly = 0
                  )
                  OR 
                  (
                      v.idfOutbreak IS NOT NULL
                      AND @OutbreakCaseReportOnly = 1
                  )
              )
        GROUP BY ID
        OPTION (RECOMPILE);

        DECLARE @TotalCount INT = (
                       SELECT COUNT(*)
                       FROM dbo.tlbVetCase v
                           INNER JOIN dbo.tlbFarm f
                               ON f.idfFarm = v.idfFarm
                                  AND f.intRowStatus = 0
                       WHERE v.intRowStatus = 0
                             AND (
                                     (v.idfsCaseType = @SpeciesTypeID)
                                     OR @SpeciesTypeID IS NULL
                                 )
        );

        WITH paging
        AS (SELECT ROW_NUMBER() OVER (ORDER BY CASE
                                                   WHEN @SortColumn = 'ReportID'
                                                        AND @SortOrder = 'ASC' THEN
                                                       v.strCaseID
                                               END ASC,
                                               CASE
                                                   WHEN @SortColumn = 'ReportID'
                                                        AND @SortOrder = 'DESC' THEN
                                                       v.strCaseID
                                               END DESC,
                                               CASE
                                                   WHEN @SortColumn = 'EnteredDate'
                                                        AND @SortOrder = 'ASC' THEN
                                                       v.datEnteredDate
                                               END ASC,
                                               CASE
                                                   WHEN @SortColumn = 'EnteredDate'
                                                        AND @SortOrder = 'DESC' THEN
                                                       v.datEnteredDate
                                               END DESC,
                                               CASE
                                                   WHEN @SortColumn = 'DiseaseName'
                                                        AND @SortOrder = 'ASC' THEN
                                                       disease.name
                                               END ASC,
                                               CASE
                                                   WHEN @SortColumn = 'DiseaseName'
                                                        AND @SortOrder = 'DESC' THEN
                                                       disease.name
                                               END DESC,
                                               CASE
                                                   WHEN @SortColumn = 'FarmName'
                                                        AND @SortOrder = 'ASC' THEN
                                                       f.strNationalName
                                               END ASC,
                                               CASE
                                                   WHEN @SortColumn = 'FarmName'
                                                        AND @SortOrder = 'DESC' THEN
                                                       f.strNationalName
                                               END DESC,
                                               CASE
                                                   WHEN @SortColumn = 'FarmAddress'
                                                        AND @SortOrder = 'ASC' THEN
                                               (lh.AdminLevel1Name + ', ' + lh.AdminLevel2Name)
                                               END ASC,
                                               CASE
                                                   WHEN @SortColumn = 'FarmAddress'
                                                        AND @SortOrder = 'DESC' THEN
                                               (lh.AdminLevel1Name + ', ' + lh.AdminLevel2Name)
                                               END DESC,
                                               CASE
                                                   WHEN @SortColumn = 'ClassificationTypeName'
                                                        AND @SortOrder = 'ASC' THEN
                                                       caseClassification.name
                                               END ASC,
                                               CASE
                                                   WHEN @SortColumn = 'ClassificationTypeName'
                                                        AND @SortOrder = 'DESC' THEN
                                                       caseClassification.name
                                               END DESC,
                                               CASE
                                                   WHEN @SortColumn = 'ReportStatusTypeName'
                                                        AND @SortOrder = 'ASC' THEN
                                                       reportStatus.name
                                               END ASC,
                                               CASE
                                                   WHEN @SortColumn = 'ReportStatusTypeName'
                                                        AND @SortOrder = 'DESC' THEN
                                                       reportStatus.name
                                               END DESC,
                                               CASE
                                                   WHEN @SortColumn = 'ReportTypeName'
                                                        AND @SortOrder = 'ASC' THEN
                                                       reportType.name
                                               END ASC,
                                               CASE
                                                   WHEN @SortColumn = 'ReportTypeName'
                                                        AND @SortOrder = 'DESC' THEN
                                                       reportType.name
                                               END DESC
                                     ) AS ROWNUM,
                   res.ID AS ReportKey,
                   CASE @OutbreakCaseReportOnly
                       WHEN 0 THEN
                           v.strCaseID
                       WHEN 1 THEN
                           ocr.strOutbreakCaseID
                   END AS ReportID,
                   v.idfOutbreak AS OutbreakKey,
                   o.strOutbreakID AS OutbreakID,
                   v.idfsCaseType AS ReportCategoryTypeID,
                   reportStatus.name AS ReportStatusTypeName,
                   reportType.name AS ReportTypeName,
                   caseType.name AS SpeciesTypeName,
                   caseClassification.name AS ClassificationTypeName,
                   v.datReportDate AS ReportDate,
                   v.datInvestigationDate AS InvestigationDate,
                   v.idfsFinalDiagnosis AS DiseaseID,
                   disease.name AS DiseaseName,
                   v.datFinalDiagnosisDate AS FinalDiagnosisDate,
                   ISNULL(personInvestigatedBy.strFamilyName, N'')
                   + ISNULL(', ' + personInvestigatedBy.strFirstName, '')
                   + ISNULL(' ' + personInvestigatedBy.strSecondName, '') AS InvestigatedByPersonName,
                   ISNULL(personReportedBy.strFamilyName, N'') + ISNULL(', ' + personReportedBy.strFirstName, '')
                   + ISNULL(' ' + personReportedBy.strSecondName, '') AS ReportedByPersonName,
                   (CASE
                        WHEN v.idfsCaseType = 10012003 THEN
                            ISNULL(f.intLivestockSickAnimalQty, '0')
                        ELSE
                            ISNULL(f.intAvianSickAnimalQty, '0')
                    END
                   ) AS TotalSickAnimalQuantity,
                   (CASE
                        WHEN v.idfsCaseType = 10012003 THEN
                            ISNULL(f.intLivestockTotalAnimalQty, '0')
                        ELSE
                            ISNULL(f.intAvianTotalAnimalQty, '0')
                    END
                   ) AS TotalAnimalQuantity,
                   (CASE
                        WHEN v.idfsCaseType = 10012003 THEN
                            ISNULL(f.intLivestockDeadAnimalQty, '0')
                        ELSE
                            ISNULL(f.intAvianDeadAnimalQty, '0')
                    END
                   ) AS TotalDeadAnimalQuantity,
                   (
				   CASE 
				       WHEN @IncludeSpeciesListIndicator = 1 THEN 
                       (
                           SELECT STRING_AGG(speciesType.name, ', ') WITHIN GROUP (ORDER BY speciesType.name) AS Result
                           FROM dbo.tlbSpecies s
                                INNER JOIN dbo.FN_GBL_Repair(@LanguageID, 19000086) speciesType 
                                    ON speciesType.idfsReference = s.idfsSpeciesType
                                INNER JOIN dbo.tlbHerd h 
                                    ON h.idfHerd = s.idfHerd
                                        AND h.intRowStatus = 0
                                        AND h.idfFarm = v.idfFarm
                           WHERE s.intRowStatus = 0
                       )
                       ELSE ''
                   END
                   ) AS SpeciesList,
                   f.strFarmCode AS FarmID,
                   f.idfFarmActual AS FarmMasterKey,
                   f.strNationalName AS FarmName,
                   f.idfHuman AS FarmOwnerKey,
                   haai.EIDSSPersonID AS FarmOwnerID,
                   ISNULL(h.strLastName, N'') + ISNULL(', ' + h.strFirstName, '') + ISNULL(' ' + h.strSecondName, '') AS FarmOwnerName,
                   (lh.AdminLevel1Name + ', ' + lh.AdminLevel2Name) AS FarmLocation,
                   dbo.FN_GBL_CreateAddressString(
                                                     ISNULL(lh.AdminLevel4Name, N''),
                                                     ISNULL(lh.AdminLevel3Name, N''),
                                                     ISNULL(lh.AdminLevel2Name, N''),
                                                     '',
                                                     '',
                                                     '',
                                                     '',
                                                     '',
                                                     '',
                                                     '',
                                                     0,
                                                     ''
                                                 ) AS FarmAddress,
                   v.datEnteredDate AS EnteredDate,
                   ISNULL(personEnteredBy.strFamilyName, N'') + ISNULL(', ' + personEnteredBy.strFirstName, '')
                   + ISNULL(' ' + personEnteredBy.strSecondName, '') AS EnteredByPersonName,
                   v.idfsSite AS SiteKey,
                   f.idfFarm,
                   res.ReadPermissionIndicator AS ReadPermissionIndicator,
                   res.AccessToPersonalDataPermissionIndicator AS AccessToPersonalDataPermissionIndicator,
                   res.AccessToGenderAndAgeDataPermissionIndicator AS AccessToGenderAndAgeDataPermissionIndicator,
                   res.WritePermissionIndicator AS WritePermissionIndicator,
                   res.DeletePermissionIndicator AS DeletePermissionIndicator,
                   COUNT(*) OVER () AS TotalRowCount,
                   @TotalCount AS TotalCount
            FROM @FinalResults res
                INNER JOIN dbo.tlbVetCase v
                    ON v.idfVetCase = res.ID
                INNER JOIN dbo.tlbFarm f
                    ON f.idfFarm = v.idfFarm
                LEFT JOIN dbo.tlbHuman h
                    ON h.idfHuman = f.idfHuman
                LEFT JOIN dbo.HumanActualAddlInfo haai
                    ON haai.HumanActualAddlInfoUID = h.idfHumanActual
                LEFT JOIN dbo.tlbPerson personInvestigatedBy
                    ON personInvestigatedBy.idfPerson = v.idfPersonInvestigatedBy
                LEFT JOIN dbo.tlbPerson personEnteredBy
                    ON personEnteredBy.idfPerson = v.idfPersonEnteredBy
                LEFT JOIN dbo.tlbPerson personReportedBy
                    ON personReportedBy.idfPerson = v.idfPersonReportedBy
                LEFT JOIN dbo.tlbGeoLocation gl
                    ON gl.idfGeoLocation = f.idfFarmAddress
                LEFT JOIN dbo.tlbOutbreak o
                    ON o.idfOutbreak = v.idfOutbreak
                       AND o.intRowStatus = 0
                LEFT JOIN dbo.OutbreakCaseReport ocr
                    ON ocr.idfVetCase = v.idfVetCase
                LEFT JOIN dbo.FN_GBL_LocationHierarchy_Flattened(@LanguageID) lh
                    ON lh.idfsLocation = gl.idfsLocation
                LEFT JOIN dbo.FN_GBL_Repair(@LanguageID, 19000019) disease
                    ON disease.idfsReference = v.idfsFinalDiagnosis
                LEFT JOIN dbo.FN_GBL_Repair(@LanguageID, 19000011) caseClassification
                    ON caseClassification.idfsReference = v.idfsCaseClassification
                LEFT JOIN dbo.FN_GBL_Repair(@LanguageID, 19000111) reportStatus
                    ON reportStatus.idfsReference = v.idfsCaseProgressStatus
                LEFT JOIN dbo.FN_GBL_Repair(@LanguageID, 19000144) reportType
                    ON reportType.idfsReference = v.idfsCaseReportType
                LEFT JOIN dbo.FN_GBL_Repair(@LanguageID, 19000012) caseType
                    ON caseType.idfsReference = v.idfsCaseType
           )
        SELECT ReportKey,
               ReportID,
               OutbreakKey,
               OutbreakID,
               ReportCategoryTypeID,
               ReportStatusTypeName,
               ReportTypeName,
               SpeciesTypeName,
               ClassificationTypeName,
               ReportDate,
               InvestigationDate,
               DiseaseID,
               DiseaseName,
               FinalDiagnosisDate,
               InvestigatedByPersonName,
               ReportedByPersonName,
               TotalSickAnimalQuantity,
               TotalAnimalQuantity,
               TotalDeadAnimalQuantity,
               SpeciesList,
               FarmID,
               FarmMasterKey,
               FarmName,
               FarmOwnerKey,
               FarmOwnerID,
               FarmOwnerName,
               FarmLocation,
               FarmAddress,
               EnteredDate,
               EnteredByPersonName,
               SiteKey,
               idfFarm,
               CASE
                   WHEN ReadPermissionIndicator = 5 THEN
                       CONVERT(BIT, 1)
                   WHEN ReadPermissionIndicator = 4 THEN
                       CONVERT(BIT, 0)
                   WHEN ReadPermissionIndicator = 3 THEN
                       CONVERT(BIT, 1)
                   WHEN ReadPermissionIndicator = 2 THEN
                       CONVERT(BIT, 0)
                   ELSE
                       CONVERT(BIT, ReadPermissionIndicator)
               END AS ReadPermissionindicator,
               CASE
                   WHEN AccessToPersonalDataPermissionIndicator = 5 THEN
                       CONVERT(BIT, 1)
                   WHEN AccessToPersonalDataPermissionIndicator = 4 THEN
                       CONVERT(BIT, 0)
                   WHEN AccessToPersonalDataPermissionIndicator = 3 THEN
                       CONVERT(BIT, 1)
                   WHEN AccessToPersonalDataPermissionIndicator = 2 THEN
                       CONVERT(BIT, 0)
                   ELSE
                       CONVERT(BIT, AccessToPersonalDataPermissionIndicator)
               END AS AccessToPersonalDataPermissionIndicator,
               CASE
                   WHEN AccessToGenderAndAgeDataPermissionIndicator = 5 THEN
                       CONVERT(BIT, 1)
                   WHEN AccessToGenderAndAgeDataPermissionIndicator = 4 THEN
                       CONVERT(BIT, 0)
                   WHEN AccessToGenderAndAgeDataPermissionIndicator = 3 THEN
                       CONVERT(BIT, 1)
                   WHEN AccessToGenderAndAgeDataPermissionIndicator = 2 THEN
                       CONVERT(BIT, 0)
                   ELSE
                       CONVERT(BIT, AccessToGenderAndAgeDataPermissionIndicator)
               END AS AccessToGenderAndAgeDataPermissionIndicator,
               CASE
                   WHEN WritePermissionIndicator = 5 THEN
                       CONVERT(BIT, 1)
                   WHEN WritePermissionIndicator = 4 THEN
                       CONVERT(BIT, 0)
                   WHEN WritePermissionIndicator = 3 THEN
                       CONVERT(BIT, 1)
                   WHEN WritePermissionIndicator = 2 THEN
                       CONVERT(BIT, 0)
                   ELSE
                       CONVERT(BIT, WritePermissionIndicator)
               END AS WritePermissionIndicator,
               CASE
                   WHEN DeletePermissionIndicator = 5 THEN
                       CONVERT(BIT, 1)
                   WHEN DeletePermissionIndicator = 4 THEN
                       CONVERT(BIT, 0)
                   WHEN DeletePermissionIndicator = 3 THEN
                       CONVERT(BIT, 1)
                   WHEN DeletePermissionIndicator = 2 THEN
                       CONVERT(BIT, 0)
                   ELSE
                       CONVERT(BIT, DeletePermissionIndicator)
               END AS DeletePermissionIndicator,
               TotalRowCount,
               TotalCount,
               TotalPages = (TotalRowCount / @PageSize) + IIF(TotalRowCount % @PageSize > 0, 1, 0),
               CurrentPage = @PageNumber
        FROM paging
        WHERE RowNum > @firstRec
              AND RowNum < @lastRec;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH;
END;
GO
PRINT N'Altering Procedure [dbo].[USP_VET_DISEASE_REPORT_SET]...';


GO
-- ================================================================================================
-- Name: USP_VET_DISEASE_REPORT_SET
--
-- Description:	Inserts or updates veterinary "case" for the avian and livestock veterinary disease 
-- report use cases.
--                      
-- Revision History:
-- Name            Date       Change Detail
-- --------------- ---------- -------------------------------------------------------------------
-- Stephen Long    04/02/2018 Initial release.
-- Stephen Long    04/17/2019 Updated for API; use case updates.
-- Stephen Long    04/23/2019 Added updates for herd master and species master if new ones are 
--                            added to the farm during disease report creation.
-- Stephen Long    04/29/2019 Added related to veterinary disease report fields for use case VUC11 
--                            and VUC12.
-- Stephen Long    05/26/2019 Made corrections to farm copy observation ID and species table 
--                            observation ID for flexible form saving.
-- Stephen Long    06/01/2019 Made corrections to JSON for herds and species parameters.
-- Stephen Long    06/10/2019 Added farm owner ID output parameter to USSP_VET_FARM_COPY call.
-- Stephen Long    06/19/2019 Added diagnosis date and tests conducted indicator parameters.
-- Stephen Long    06/22/2019 Added read only indicator parameter for sample set - sample import.
-- Stephen Long    06/24/2019 Update to match new parameter for USSP_VET_FARM_COPY call.
-- Stephen Long    07/26/2019 Corrected farm counts (total, sick and dead).
-- Stephen Long    09/14/2019 Corrected root sample ID/parent sample ID on sample update call.
-- Stephen Long    10/01/2019 Added monitoring session ID parameter to farm copy for the sceanrio 
--                            where a disease report is tied to a monitoring session.
-- Stephen Long    12/23/2019 Added farm latitude and longitude parameters.
-- Stephen Long    02/05/2020 Updated sample set to account for the current site ID when samples 
--                            are imported from the laboratory module.
-- Stephen Long    02/16/2020 Add logic to copy activity parameters, and add observation record for 
--                            connected disease reports.
-- Stephen Long    04/21/2020 Added additional check on clinical signs when related disease report.
-- Stephen Long    04/24/2020 Added clinical signs indicator for the animal set call.
-- Stephen Long    08/12/2020 Corrected status on report log from status type to log status type.
-- Stephen Long    08/25/2020 Added observation ID set for the update of the vet case table.
-- Stephen Long    09/18/2020 Check for null related to observation ID
-- Stephen Long    12/20/2020 Updated USSP_GBL_TEST_SET call with four new parameters.
-- Stephen Long    11/29/2021 Removed language ID and added audit user name to USSP calls.
-- Stephen Long    01/19/2022 Added missing audit user name on ussp calls, and added events.
-- Stephen Long    01/22/2022 Made disease ID nullable on SamplesTemp table variable.
-- Stephen Long    01/24/2022 Added link local or field sample ID to report ID parameter.
-- Stephen Long    01/28/2022 Removed herd actual and species actual, no longer used.
-- Stephen Long    02/18/2022 Added lab module source indicator check on sample set.
-- Stephen Long    03/08/2022 Set notification object ID after saving disease report.
-- Stephen Long    04/12/2022 Added outbreak veterinary case parameters and logic.
-- Stephen Long    04/27/2022 Added additional outbreak case parameters: status type and case 
--                            questionnaire observation ID.
-- Stephen Long    05/09/2022 Bug fix on item 4199 - local/field sample ID iteration.
-- Stephen Long    06/16/2022 Added status type ID to species set.
-- Stephen Long    07/06/2022 Updates for site alerts to call new stored procedure.
-- Stephen Long    09/15/2022 Added note parameter to event set call.  Temporarily removed!
-- Stephen Long    12/07/2022 Added data audit logic for SAUC30 and 31.
-- Stephen Long    12/09/2022 Changed object type ID reference for veterinary disease report, 
--                            and added EIDSS object ID to samples, tests and test 
--                            interpretations calls.
-- Stephen Long    12/14/2022 Fix to observation ID when adding a connected disease report; site 
--                            identifier was not picked up from the original record.
-- Stephen Long    12/17/2022 Fix to importing sample when the disease report has not been saved.
-- Stephwn Long    12/19/2022 Added connected disease laboratory test ID to the list of output.
-- Stephen Long    02/03/2023 Changed to data audit call with strMainObject.
-- Stephen Long    03/08/2023 Fix to call data audit set and pass EIDSS report ID.
-- Ann Xiong	   03/09/2023 Added @DataAuditEventID parameter
-- Stephen Long    05/16/2023 Fix for item 5584.
-- ================================================================================================
ALTER PROCEDURE [dbo].[USP_VET_DISEASE_REPORT_SET]
(
    @DiseaseReportID BIGINT,
    @EIDSSReportID NVARCHAR(200) = NULL,
    @FarmID BIGINT,
    @FarmMasterID BIGINT,
    @FarmOwnerID BIGINT = NULL,
    @MonitoringSessionID BIGINT = NULL,
    @OutbreakID BIGINT = NULL,
    @RelatedToDiseaseReportID BIGINT = NULL,
    @EIDSSFieldAccessionID NVARCHAR(200) = NULL,
    @DiseaseID BIGINT,
    @EnteredByPersonID BIGINT = NULL,
    @ReportedByOrganizationID BIGINT = NULL,
    @ReportedByPersonID BIGINT = NULL,
    @InvestigatedByOrganizationID BIGINT = NULL,
    @InvestigatedByPersonID BIGINT = NULL,
    @ReceivedByOrganizationID BIGINT = NULL,
    @ReceivedByPersonID BIGINT = NULL,
    @SiteID BIGINT,
    @DiagnosisDate DATETIME = NULL,
    @EnteredDate DATETIME = NULL,
    @ReportDate DATETIME = NULL,
    @AssignedDate DATETIME = NULL,
    @InvestigationDate DATETIME = NULL,
    @RowStatus INT,
    @ReportTypeID BIGINT = NULL,
    @ClassificationTypeID BIGINT = NULL,
    @StatusTypeID BIGINT = NULL,
    @ReportCategoryTypeID BIGINT,
    @FarmTotalAnimalQuantity INT = NULL,
    @FarmSickAnimalQuantity INT = NULL,
    @FarmDeadAnimalQuantity INT = NULL,
    @FarmLatitude FLOAT = NULL,
    @FarmLongitude FLOAT = NULL,
    @FarmEpidemiologicalObservationID BIGINT = NULL,
    @ControlMeasuresObservationID BIGINT = NULL,
    @TestsConductedIndicator BIGINT = NULL,
    @DataAuditEventID BIGINT = NULL,
    @AuditUserName NVARCHAR(200),
    @FlocksOrHerds NVARCHAR(MAX) = NULL,
    @Species NVARCHAR(MAX) = NULL,
    @Animals NVARCHAR(MAX) = NULL,
    @Vaccinations NVARCHAR(MAX) = NULL,
    @Samples NVARCHAR(MAX) = NULL,
    @PensideTests NVARCHAR(MAX) = NULL,
    @LaboratoryTests NVARCHAR(MAX) = NULL,
    @LaboratoryTestInterpretations NVARCHAR(MAX) = NULL,
    @CaseLogs NVARCHAR(MAX) = NULL,
    @ClinicalInformation NVARCHAR(MAX) = NULL,
    @Contacts NVARCHAR(MAX) = NULL,
    @CaseMonitorings NVARCHAR(MAX) = NULL,
    @Events NVARCHAR(MAX) = NULL,
    @UserID BIGINT,
    @LinkLocalOrFieldSampleIDToReportID BIT = 0,
    @OutbreakCaseIndicator BIT = 0,
    @OutbreakCaseReportUID BIGINT = NULL,
    @OutbreakCaseStatusTypeID BIGINT = NULL,
    @OutbreakCaseQuestionnaireObservationID BIGINT = NULL,
    @PrimaryCaseIndicator BIT = 0
)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        DECLARE @ReturnCode INT
            = 0,
                @ReturnMessage NVARCHAR(MAX) = N'SUCCESS',
                @ConnectedDiseaseReportLaboratoryTestID BIGINT = NULL,
                @RowAction INT = NULL,
                @RowID BIGINT,
                @Iteration INT = 0,
                @NewFarmOwnerID BIGINT = NULL,
                @FlockOrHerdID BIGINT = NULL,
                @FlockOrHerdMasterID BIGINT = NULL,
                @EIDSSFlockOrHerdID NVARCHAR(200) = NULL,
                @SickAnimalQuantity INT = NULL,
                @TotalAnimalQuantity INT = NULL,
                @DeadAnimalQuantity INT = NULL,
                @Comments NVARCHAR(2000) = NULL,
                @SpeciesID BIGINT = NULL,
                @SpeciesMasterID BIGINT = NULL,
                @SpeciesTypeID BIGINT = NULL,
                @StartOfSignsDate DATETIME = NULL,
                @AverageAge NVARCHAR(200) = NULL,
                @ObservationID BIGINT = NULL,
                @OutbreakSpeciesCaseStatusTypeID BIGINT = NULL,
                @AnimalID BIGINT = NULL,
                @SexTypeID BIGINT = NULL,
                @ConditionTypeID BIGINT = NULL,
                @AgeTypeID BIGINT = NULL,
                @EIDSSAnimalID NVARCHAR(200) = NULL,
                @AnimalName NVARCHAR(200) = NULL,
                @Color NVARCHAR(200) = NULL,
                @AnimalDescription NVARCHAR(200) = NULL,
                @ClinicalSignsIndicator BIGINT = NULL,
                @VaccinationID BIGINT,
                @VaccinationTypeID BIGINT = NULL,
                @RouteTypeID BIGINT = NULL,
                @VaccinationDate DATETIME = NULL,
                @Manufacturer NVARCHAR(200) = NULL,
                @LotNumber NVARCHAR(200) = NULL,
                @NumberVaccinated INT = NULL,
                @SampleID BIGINT,
                @SampleTypeID BIGINT = NULL,
                @RootSampleID BIGINT = NULL,
                @ParentSampleID BIGINT = NULL,
                @CollectedByPersonID BIGINT = NULL,
                @CollectedByOrganizationID BIGINT = NULL,
                @CollectionDate DATETIME = NULL,
                @SentDate DATETIME = NULL,
                @EIDSSLocalOrFieldSampleID NVARCHAR(200) = NULL,
                @SampleStatusTypeID BIGINT = NULL,
                @EIDSSLaboratorySampleID NVARCHAR(200) = NULL,
                @SentToOrganizationID BIGINT = NULL,
                @ReadOnlyIndicator BIT = NULL,
                @CurrentSiteID BIGINT = NULL,
                @BirdStatusTypeID BIGINT = NULL,
                @PensideTestID BIGINT = NULL,
                @PensideTestResultTypeID BIGINT = NULL,
                @PensideTestNameTypeID BIGINT = NULL,
                @TestedByPersonID BIGINT = NULL,
                @TestedByOrganizationID BIGINT = NULL,
                @TestDate DATETIME = NULL,
                @PensideTestCategoryTypeID BIGINT = NULL,
                @TestID BIGINT = NULL,
                @TestNameTypeID BIGINT = NULL,
                @TestCategoryTypeID BIGINT = NULL,
                @TestResultTypeID BIGINT = NULL,
                @TestStatusTypeID BIGINT,
                @BatchTestID BIGINT = NULL,
                @StartedDate DATETIME = NULL,
                @ResultDate DATETIME = NULL,
                @ResultEnteredByOrganizationID BIGINT = NULL,
                @ResultEnteredByPersonID BIGINT = NULL,
                @ValidatedByOrganizationID BIGINT = NULL,
                @ValidatedByPersonID BIGINT = NULL,
                @NonLaboratoryTestIndicator BIT,
                @ExternalTestIndicator BIT = NULL,
                @PerformedByOrganizationID BIGINT = NULL,
                @ReceivedDate DATETIME = NULL,
                @ContactPersonName NVARCHAR(200) = NULL,
                @TestDiseaseReportID BIGINT = NULL,
                @TestInterpretationID BIGINT,
                @InterpretedStatusTypeID BIGINT = NULL,
                @InterpretedByOrganizationID BIGINT = NULL,
                @InterpretedByPersonID BIGINT = NULL,
                @TestingInterpretations BIGINT,
                @ValidatedStatusIndicator BIT = NULL,
                @ReportSessionCreatedIndicator BIT = NULL,
                @ValidatedComment NVARCHAR(200) = NULL,
                @InterpretedComment NVARCHAR(200) = NULL,
                @ValidatedDate DATETIME = NULL,
                @InterpretedDate DATETIME = NULL,
                @CaseLogID BIGINT,
                @LogStatusTypeID BIGINT = NULL,
                @LoggedByPersonID BIGINT = NULL,
                @LogDate DATETIME = NULL,
                @ActionRequired NVARCHAR(200) = NULL,
                @VeterinaryDiseaseReportRelationshipID BIGINT = NULL,
                @RelatedToSpeciesID BIGINT = NULL,
                @RelatedToAnimalID BIGINT = NULL,
                @RelatedToObservationID BIGINT = NULL,
                @FormTemplateID BIGINT,
                @ObservationSiteID BIGINT,
                @ActivityID BIGINT = NULL,
                @ActivityIDNew BIGINT = NULL,
                @ParameterID BIGINT = NULL,
                @ParameterValue SQL_VARIANT = NULL,
                @ParameterRowID BIGINT = NULL,
                @EventId BIGINT,
                @EventTypeId BIGINT = NULL,
                @EventSiteId BIGINT = NULL,
                @EventObjectId BIGINT = NULL,
                @EventUserId BIGINT = NULL,
                @EventDiseaseId BIGINT = NULL,
                @EventLocationId BIGINT = NULL,
                @EventInformationString NVARCHAR(MAX) = NULL,
                @EventNote NVARCHAR(MAX) = NULL,
                @EventLoginSiteId BIGINT = NULL,
                                                                                           -- Data audit
                @AuditUserID BIGINT = NULL,
                @AuditSiteID BIGINT = NULL,
                --@DataAuditEventID BIGINT = NULL,
                @DataAuditEventTypeID BIGINT = NULL,
                @ObjectTypeID BIGINT = 10017085,                                           -- Veterinary disease report
                @ObjectID BIGINT = @DiseaseReportID,
                @ObjectTableID BIGINT = 75800000000,                                       -- tlbVetCase
                @ObjectVeterinaryDiseaseReportRelationshipTableID BIGINT = 53577790000004, -- VetDiseaseReportRelationship
                @ObjectObservationTableID BIGINT = 75640000000,                            -- tlbObservation
                @ObjectActivityParametersTableID BIGINT = 75410000000,                     -- tlbActivityParameters
                                                                                           -- End data audit
                @LabModuleSourceIndicator INT = 0,
                @SampleDiseaseReportID BIGINT = NULL,
                @EIDSSCaseID NVARCHAR(200) = NULL;
        DECLARE @SuppressSelect TABLE
        (
            ReturnCode INT,
            ReturnMessage NVARCHAR(MAX)
        );
        DECLARE @FlocksOrHerdsTemp TABLE
        (
            FlockOrHerdID BIGINT NOT NULL,
            FarmID BIGINT NULL,
            FlockOrHerdMasterID BIGINT NULL,
            EIDSSFlockOrHerdID NVARCHAR(200) NULL,
            SickAnimalQuantity INT NULL,
            TotalAnimalQuantity INT NULL,
            DeadAnimalQuantity INT NULL,
            RowStatus INT NULL,
            RowAction INT NULL
        );
        DECLARE @SpeciesTemp TABLE
        (
            SpeciesID BIGINT NOT NULL,
            SpeciesMasterID BIGINT NULL,
            FlockOrHerdID BIGINT NOT NULL,
            SpeciesTypeID BIGINT NOT NULL,
            SickAnimalQuantity INT NULL,
            TotalAnimalQuantity INT NULL,
            DeadAnimalQuantity INT NULL,
            StartOfSignsDate DATETIME NULL,
            AverageAge NVARCHAR(200) NULL,
            ObservationID BIGINT NULL,
            Comments NVARCHAR(2000) NULL,
            RowStatus INT NOT NULL,
            RowAction INT NULL,
            RelatedToSpeciesID BIGINT NULL,
            RelatedToObservationID BIGINT NULL,
            OutbreakCaseStatusTypeID BIGINT NULL
        );
        DECLARE @AnimalsTemp TABLE
        (
            AnimalID BIGINT NOT NULL,
            SexTypeID BIGINT NULL,
            ConditionTypeID BIGINT NULL,
            AgeTypeID BIGINT NULL,
            SpeciesID BIGINT NULL,
            ObservationID BIGINT NULL,
            EIDSSAnimalID NVARCHAR(200) NULL,
            AnimalName NVARCHAR(200) NULL,
            Color NVARCHAR(200) NULL,
            AnimalDescription NVARCHAR(200) NULL,
            ClinicalSignsIndicator BIGINT NULL,
            RowStatus INT NOT NULL,
            RowAction INT NULL,
            RelatedToAnimalID BIGINT NULL,
            RelatedToObservationID BIGINT NULL
        );
        DECLARE @VaccinationsTemp TABLE
        (
            VaccinationID BIGINT NOT NULL,
            SpeciesID BIGINT NULL,
            VaccinationTypeID BIGINT NULL,
            RouteTypeID BIGINT NULL,
            DiseaseID BIGINT NULL,
            VaccinationDate DATETIME NULL,
            Manufacturer NVARCHAR(200) NULL,
            LotNumber NVARCHAR(200) NULL,
            NumberVaccinated INT NULL,
            Comments NVARCHAR(2000) NULL,
            RowStatus INT NOT NULL,
            RowAction INT NULL
        );
        DECLARE @SamplesTemp TABLE
        (
            SampleID BIGINT NOT NULL,
            SampleTypeID BIGINT NULL,
            RootSampleID BIGINT NULL,
            ParentSampleID BIGINT NULL,
            SpeciesID BIGINT NULL,
            AnimalID BIGINT NULL,
            VeterinaryDiseaseReportID BIGINT NULL,
            MonitoringSessionID BIGINT NULL,
            SampleStatusTypeID BIGINT NULL,
            CollectionDate DATETIME NULL,
            CollectedByOrganizationID BIGINT NULL,
            CollectedByPersonID BIGINT NULL,
            SentDate DATETIME NULL,
            SentToOrganizationID BIGINT NULL,
            EIDSSLocalOrFieldSampleID NVARCHAR(200) NULL,
            Comments NVARCHAR(200) NULL,
            SiteID BIGINT NOT NULL,
            CurrentSiteID BIGINT NULL,
            EnteredDate DATETIME NULL,
            DiseaseID BIGINT NULL,
            BirdStatusTypeID BIGINT NULL,
            ReadOnlyIndicator BIT NULL,
            LabModuleSourceIndicator INT NOT NULL,
            FarmID BIGINT NULL,
            FarmOwnerID BIGINT NULL,
            RowStatus INT NOT NULL,
            RowAction INT NULL
        );
        DECLARE @PensideTestsTemp TABLE
        (
            PensideTestID BIGINT NOT NULL,
            SampleID BIGINT NOT NULL,
            PensideTestNameTypeID BIGINT NULL,
            PensideTestResultTypeID BIGINT NULL,
            PensideTestCategoryTypeID BIGINT NULL,
            TestedByPersonID BIGINT NULL,
            TestedByOrganizationID BIGINT NULL,
            DiseaseID BIGINT NULL,
            TestDate DATETIME NULL,
            RowStatus INT NOT NULL,
            RowAction INT NULL
        );
        DECLARE @LaboratoryTestsTemp TABLE
        (
            TestID BIGINT NOT NULL,
            TestNameTypeID BIGINT NULL,
            TestCategoryTypeID BIGINT NULL,
            TestResultTypeID BIGINT NULL,
            TestStatusTypeID BIGINT NOT NULL,
            DiseaseID BIGINT NOT NULL,
            SampleID BIGINT NULL,
            BatchTestID BIGINT NULL,
            ObservationID BIGINT NULL,
            TestNumber INT NULL,
            Comments NVARCHAR NULL,
            StartedDate DATETIME NULL,
            ResultDate DATETIME NULL,
            TestedByOrganizationID BIGINT NULL,
            TestedByPersonID BIGINT NULL,
            ResultEnteredByOrganizationID BIGINT NULL,
            ResultEnteredByPersonID BIGINT NULL,
            ValidatedByOrganizationID BIGINT NULL,
            ValidatedByPersonID BIGINT NULL,
            ReadOnlyIndicator BIT NOT NULL,
            NonLaboratoryTestIndicator BIT NOT NULL,
            ExternalTestIndicator BIT NULL,
            PerformedByOrganizationID BIGINT NULL,
            ReceivedDate DATETIME NULL,
            ContactPersonName NVARCHAR(200) NULL,
            RowStatus INT NOT NULL,
            RowAction INT NULL
        );
        DECLARE @LaboratoryTestInterpretationsTemp TABLE
        (
            TestInterpretationID BIGINT NOT NULL,
            DiseaseID BIGINT NULL,
            InterpretedStatusTypeID BIGINT NULL,
            ValidatedByOrganizationID BIGINT NULL,
            ValidatedByPersonID BIGINT NULL,
            InterpretedByOrganizationID BIGINT NULL,
            InterpretedByPersonID BIGINT NULL,
            TestID BIGINT NOT NULL,
            ValidatedStatusIndicator BIT NULL,
            ReportSessionCreatedIndicator BIT NULL,
            ValidatedComment NVARCHAR(200) NULL,
            InterpretedComment NVARCHAR(200) NULL,
            ValidatedDate DATETIME NULL,
            InterpretedDate DATETIME NULL,
            ReadOnlyIndicator BIT NOT NULL,
            RowStatus INT NOT NULL,
            RowAction INT NULL
        );
        DECLARE @CaseLogsTemp TABLE
        (
            CaseLogID BIGINT NOT NULL,
            LogStatusTypeID BIGINT NULL,
            LoggedByPersonID BIGINT NULL,
            LogDate DATETIME NULL,
            ActionRequired NVARCHAR(200) NULL,
            Comments NVARCHAR(1000) NULL,
            RowStatus INT NOT NULL,
            RowAction INT NULL
        );
        DECLARE @ClinicalInformationTemp TABLE
        (
            langId NVARCHAR(200) NULL,
            HerdID BIGINT NOT NULL,
            Herd NVARCHAR(200) NULL,
            ClinicalSignsIndicator BIGINT NOT NULL,
            SpeciesTypeID BIGINT NULL,
            SpeciesTypeName NVARCHAR(200) NULL,
            StatusTypeID BIGINT NULL,
            InvestigationPerformedTypeID BIGINT NULL
        );
        DECLARE @ActivityParametersTemp TABLE
        (
            ActivityID BIGINT NOT NULL,
            ParameterID BIGINT NOT NULL,
            ParameterValue SQL_VARIANT NULL,
            ParameterRowID BIGINT NOT NULL
        );
        DECLARE @EventsTemp TABLE
        (
            EventId BIGINT NOT NULL,
            EventTypeId BIGINT NULL,
            UserId BIGINT NULL,
            SiteId BIGINT NULL,
            LoginSiteId BIGINT NULL,
            ObjectId BIGINT NULL,
            DiseaseId BIGINT NULL,
            LocationId BIGINT NULL,
            InformationString NVARCHAR(MAX) NULL,
            Note NVARCHAR(MAX) NULL
        );
        DECLARE @VeterinaryDiseaseReportAfterEdit TABLE
        (
            DiseaseReportID BIGINT,
            FarmID BIGINT,
            DiseaseID BIGINT,
            PersonEnteredByID BIGINT,
            PersonReportedByID BIGINT,
            PersonInvestigatedByID BIGINT,
            ObservationID BIGINT,
            ReportDate DATETIME,
            AssignedDate DATETIME,
            InvestigationDate DATETIME,
            FinalDiagnosisDate DATETIME,
            FieldAccessionID NVARCHAR(200),
            YNTestsConductedTypeID BIGINT,
            ReportedByOfficeID BIGINT,
            InvestigatedByOfficeID BIGINT,
            CaseReportTypeID BIGINT,
            CaseClassificationTypeID BIGINT,
            OutbreakID BIGINT,
            EnteredDate DATETIME,
            EIDSSReportID NVARCHAR(200),
            CaseProgressStatusTypeID BIGINT,
            ParentMonitoringSessionID BIGINT,
            CaseTypeID BIGINT,
            ReceivedByOfficeID BIGINT,
            ReceivedByPersonID BIGINT
        );
        DECLARE @VeterinaryDiseaseReportBeforeEdit TABLE
        (
            DiseaseReportID BIGINT,
            FarmID BIGINT,
            DiseaseID BIGINT,
            PersonEnteredByID BIGINT,
            PersonReportedByID BIGINT,
            PersonInvestigatedByID BIGINT,
            ObservationID BIGINT,
            ReportDate DATETIME,
            AssignedDate DATETIME,
            InvestigationDate DATETIME,
            FinalDiagnosisDate DATETIME,
            FieldAccessionID NVARCHAR(200),
            YNTestsConductedTypeID BIGINT,
            ReportedByOfficeID BIGINT,
            InvestigatedByOfficeID BIGINT,
            CaseReportTypeID BIGINT,
            CaseClassificationTypeID BIGINT,
            OutbreakID BIGINT,
            EnteredDate DATETIME,
            EIDSSReportID NVARCHAR(200),
            CaseProgressStatusTypeID BIGINT,
            ParentMonitoringSessionID BIGINT,
            CaseTypeID BIGINT,
            ReceivedByOfficeID BIGINT,
            ReceivedByPersonID BIGINT
        );

        BEGIN TRANSACTION;

        SET @AuditUserName = ISNULL(@AuditUserName, '');

        -- Data audit
        -- Get and set user and site identifiers
        SELECT @AuditUserID = userInfo.UserId,
               @AuditSiteID = userInfo.SiteId
        FROM dbo.FN_UserSiteInformation(@AuditUserName) userInfo;
        -- End data audit

        -- Predetermine the outbreak report ID for the upcoming section
        SELECT @OutbreakCaseReportUID = OutbreakCaseReportUID
        FROM dbo.OutbreakCaseReport
        WHERE idfVetCase = @DiseaseReportID;

        INSERT INTO @FlocksOrHerdsTemp
        SELECT *
        FROM
            OPENJSON(@FlocksOrHerds)
            WITH
            (
                FlockOrHerdID BIGINT,
                FarmID BIGINT,
                FlockOrHerdMasterID BIGINT,
                EIDSSFlockOrHerdID NVARCHAR(200),
                SickAnimalQuantity INT,
                TotalAnimalQuantity INT,
                DeadAnimalQuantity INT,
                RowStatus INT,
                RowAction INT
            );

        INSERT INTO @SpeciesTemp
        SELECT *
        FROM
            OPENJSON(@Species)
            WITH
            (
                SpeciesID BIGINT,
                SpeciesMasterID BIGINT,
                FlockOrHerdID BIGINT,
                SpeciesTypeID BIGINT,
                SickAnimalQuantity INT,
                TotalAnimalQuantity INT,
                DeadAnimalQuantity INT,
                StartOfSignsDate DATETIME,
                AverageAge NVARCHAR(200),
                ObservationID BIGINT,
                Comments NVARCHAR(2000),
                RowStatus INT,
                RowAction INT,
                RelatedToSpeciesID BIGINT,
                RelatedToObservationID BIGINT,
                OutbreakCaseStatusTypeID BIGINT
            );

        INSERT INTO @AnimalsTemp
        SELECT *
        FROM
            OPENJSON(@Animals)
            WITH
            (
                AnimalID BIGINT,
                SexTypeID BIGINT,
                ConditionTypeID BIGINT,
                AgeTypeID BIGINT,
                SpeciesID BIGINT,
                ObservationID BIGINT,
                EIDSSAnimalID NVARCHAR(200),
                AnimalName NVARCHAR(200),
                Color NVARCHAR(200),
                AnimalDescription NVARCHAR(200),
                ClinicalSignsIndicator BIGINT,
                RowStatus INT,
                RowAction INT,
                RelatedToAnimalID BIGINT,
                RelatedToObservationID BIGINT
            );

        INSERT INTO @VaccinationsTemp
        SELECT *
        FROM
            OPENJSON(@Vaccinations)
            WITH
            (
                VaccinationID BIGINT,
                SpeciesID BIGINT,
                VaccinationTypeID BIGINT,
                RouteTypeID BIGINT,
                DiseaseID BIGINT,
                VaccinationDate DATETIME2,
                Manufacturer NVARCHAR(200),
                LotNumber NVARCHAR(200),
                NumberVaccinated INT,
                Comments NVARCHAR(2000),
                RowStatus INT,
                RowAction INT
            );

        INSERT INTO @SamplesTemp
        SELECT *
        FROM
            OPENJSON(@Samples)
            WITH
            (
                SampleID BIGINT,
                SampleTypeID BIGINT,
                RootSampleID BIGINT,
                ParentSampleID BIGINT,
                SpeciesID BIGINT,
                AnimalID BIGINT,
                VeterinaryDiseaseReportID BIGINT,
                MonitoringSessionID BIGINT,
                SampleStatusTypeID BIGINT,
                CollectionDate DATETIME2,
                CollectedByOrganizationID BIGINT,
                CollectedByPersonID BIGINT,
                SentDate DATETIME2,
                SentToOrganizationID BIGINT,
                EIDSSLocalOrFieldSampleID NVARCHAR(200),
                Comments NVARCHAR(200),
                SiteID BIGINT,
                CurrentSiteID BIGINT,
                EnteredDate DATETIME2,
                DiseaseID BIGINT,
                BirdStatusTypeID BIGINT,
                ReadOnlyIndicator BIT,
                LabModuleSourceIndicator INT,
                FarmID BIGINT,
                FarmOwnerID BIGINT,
                RowStatus INT,
                RowAction INT
            );

        SET @Iteration =
        (
            SELECT COUNT(*) FROM dbo.tlbMaterial WHERE idfVetCase = @DiseaseReportID
        );

        INSERT INTO @PensideTestsTemp
        SELECT *
        FROM
            OPENJSON(@PensideTests)
            WITH
            (
                PensideTestID BIGINT,
                SampleID BIGINT,
                PensideTestNameTypeID BIGINT,
                PensideTestResultTypeID BIGINT,
                PensideTestCategoryTypeID BIGINT,
                TestedByPersonID BIGINT,
                TestedByOrganizationID BIGINT,
                DiseaseID BIGINT,
                TestDate DATETIME2,
                RowStatus INT,
                RowAction INT
            );

        INSERT INTO @LaboratoryTestsTemp
        SELECT *
        FROM
            OPENJSON(@LaboratoryTests)
            WITH
            (
                TestID BIGINT,
                TestNameTypeID BIGINT,
                TestCategoryTypeID BIGINT,
                TestResultTypeID BIGINT,
                TestStatusTypeID BIGINT,
                DiseaseID BIGINT,
                SampleID BIGINT,
                BatchTestID BIGINT,
                ObservationID BIGINT,
                TestNumber INT,
                Comments NVARCHAR(500),
                StartedDate DATETIME2,
                ResultDate DATETIME2,
                TestedByOrganizationID BIGINT,
                TestedByPersonID BIGINT,
                ResultEnteredByOrganizationID BIGINT,
                ResultEnteredByPersonID BIGINT,
                ValidatedByOrganizationID BIGINT,
                ValidatedByPersonID BIGINT,
                ReadOnlyIndicator BIT,
                NonLaboratoryTestIndicator BIT,
                ExternalTestIndicator BIT,
                PerformedByOrganizationID BIGINT,
                ReceivedDate DATETIME2,
                ContactPersonName NVARCHAR(200),
                RowStatus INT,
                RowAction INT
            );

        INSERT INTO @LaboratoryTestInterpretationsTemp
        SELECT *
        FROM
            OPENJSON(@LaboratoryTestInterpretations)
            WITH
            (
                TestInterpretationID BIGINT,
                DiseaseID BIGINT,
                InterpretedStatusTypeID BIGINT,
                ValidatedByOrganizationID BIGINT,
                ValidatedByPersonID BIGINT,
                InterpretedByOrganizationID BIGINT,
                InterpretedByPersonID BIGINT,
                TestID BIGINT,
                ValidatedStatusIndicator BIT,
                ReportSessionCreatedIndicator BIT,
                ValidatedComment NVARCHAR(200),
                InterpretedComment NVARCHAR(200),
                ValidatedDate DATETIME2,
                InterpretedDate DATETIME2,
                ReadOnlyIndicator BIT,
                RowStatus INT,
                RowAction INT
            );

        INSERT INTO @CaseLogsTemp
        SELECT *
        FROM
            OPENJSON(@CaseLogs)
            WITH
            (
                CaseLogID BIGINT,
                LogStatusTypeID BIGINT,
                LoggedByPersonID BIGINT,
                LogDate DATETIME2,
                ActionRequired NVARCHAR(200),
                Comments NVARCHAR(1000),
                RowStatus INT,
                RowAction INT
            );

        INSERT INTO @ClinicalInformationTemp
        SELECT *
        FROM
            OPENJSON(@ClinicalInformation)
            WITH
            (
                langId NVARCHAR(200),
                HerdID BIGINT,
                Herd NVARCHAR(200),
                ClinicalSignsTypeID BIGINT,
                SpeciesTypeID BIGINT,
                SpeciesTypeName NVARCHAR(200),
                StatusTypeID BIGINT,
                InvestigationPerformedTypeID BIGINT
            );

        INSERT INTO @EventsTemp
        SELECT *
        FROM
            OPENJSON(@Events)
            WITH
            (
                EventId BIGINT,
                EventTypeId BIGINT,
                UserId BIGINT,
                SiteId BIGINT,
                LoginSiteId BIGINT,
                ObjectId BIGINT,
                DiseaseId BIGINT,
                LocationId BIGINT,
                InformationString NVARCHAR(MAX),
                Note NVARCHAR(MAX)
            );

        IF NOT EXISTS
        (
            SELECT *
            FROM dbo.tlbVetCase
            WHERE idfVetCase = @DiseaseReportID
                  AND intRowStatus = 0
        )
        BEGIN
            -- Get next key value
            INSERT INTO @SuppressSelect
            EXECUTE dbo.USP_GBL_NEXTKEYID_GET 'tlbVetCase', @DiseaseReportID OUTPUT;

            INSERT INTO @SuppressSelect
            EXECUTE dbo.USP_GBL_NextNumber_GET 'Vet Disease Report',
                                               @EIDSSReportID OUTPUT,
                                               NULL;

            -- Data audit
        	IF @DataAuditEventID IS NULL
        	BEGIN 
				SET @DataAuditEventTypeID = 10016001; -- Data audit create event type

				INSERT INTO @SuppressSelect
				EXECUTE dbo.USSP_GBL_DATA_AUDIT_EVENT_SET @AuditUserID,
                                                      @AuditSiteID,
                                                      @DataAuditEventTypeID,
                                                      @ObjectTypeID,
                                                      @DiseaseReportID,
                                                      @ObjectTableID,
                                                      @EIDSSReportID, 
                                                      @DataAuditEventID OUTPUT;
            END
            -- End data audit

            IF @ReportCategoryTypeID = 10012004 --Avian
            BEGIN
                UPDATE dbo.tlbFarmActual
                SET intAvianTotalAnimalQty = @FarmTotalAnimalQuantity,
                    intAvianSickAnimalQty = @FarmSickAnimalQuantity,
                    intAvianDeadAnimalQty = @FarmDeadAnimalQuantity,
                    AuditUpdateUser = @AuditUserName
                WHERE idfFarmActual = @FarmMasterID;

                INSERT INTO @SuppressSelect
                EXECUTE dbo.USSP_VET_COPY_FARM_SET @AuditUserName,
                                                   @DataAuditEventID,
                                                   @EIDSSReportID,
                                                   @FarmMasterID,
                                                   @FarmTotalAnimalQuantity,
                                                   @FarmSickAnimalQuantity,
                                                   @FarmDeadAnimalQuantity,
                                                   NULL,
                                                   NULL,
                                                   NULL,
                                                   @FarmLatitude,
                                                   @FarmLongitude,
                                                   NULL,
                                                   @FarmEpidemiologicalObservationID,
                                                   @FarmOwnerID,
                                                   @FarmID OUTPUT,
                                                   @NewFarmOwnerID OUTPUT;

                IF @NewFarmOwnerID IS NOT NULL
                BEGIN
                    SET @FarmOwnerID = @NewFarmOwnerID;
                END;
            END
            ELSE --Livestock
            BEGIN
                UPDATE dbo.tlbFarmActual
                SET intLivestockTotalAnimalQty = @FarmTotalAnimalQuantity,
                    intLivestockSickAnimalQty = @FarmSickAnimalQuantity,
                    intLivestockDeadAnimalQty = @FarmDeadAnimalQuantity,
                    AuditUpdateUser = @AuditUserName
                WHERE idfFarmActual = @FarmMasterID;

                INSERT INTO @SuppressSelect
                EXECUTE dbo.USSP_VET_COPY_FARM_SET @AuditUserName,
                                                   @DataAuditEventID,
                                                   @EIDSSReportID,
                                                   @FarmMasterID,
                                                   NULL,
                                                   NULL,
                                                   NULL,
                                                   @FarmTotalAnimalQuantity,
                                                   @FarmSickAnimalQuantity,
                                                   @FarmDeadAnimalQuantity,
                                                   @FarmLatitude,
                                                   @FarmLongitude,
                                                   NULL,
                                                   @FarmEpidemiologicalObservationID,
                                                   @FarmOwnerID,
                                                   @FarmID OUTPUT,
                                                   @NewFarmOwnerID OUTPUT;

                IF @NewFarmOwnerID IS NOT NULL
                BEGIN
                    SET @FarmOwnerID = @NewFarmOwnerID;
                END;
            END

            IF @OutbreakCaseIndicator = 1 AND @OutbreakCaseReportUID IS NULL
            BEGIN
               SET @EIDSSReportID = NULL; -- Do not set an EIDSS report identifier when the case is created in the outbreak session instead of imported.
            END

            INSERT INTO dbo.tlbVetCase
            (
                idfVetCase,
                idfFarm,
                idfsFinalDiagnosis,
                idfPersonEnteredBy,
                idfPersonReportedBy,
                idfPersonInvestigatedBy,
                idfObservation,
                idfsSite,
                datReportDate,
                datAssignedDate,
                datInvestigationDate,
                datFinalDiagnosisDate,
                strTestNotes,
                strSummaryNotes,
                strClinicalNotes,
                strFieldAccessionID,
                idfsYNTestsConducted,
                intRowStatus,
                idfReportedByOffice,
                idfInvestigatedByOffice,
                idfsCaseReportType,
                strDefaultDisplayDiagnosis,
                idfsCaseClassification,
                idfOutbreak,
                datEnteredDate,
                strCaseID,
                idfsCaseProgressStatus,
                strSampleNotes,
                datModificationForArchiveDate,
                idfParentMonitoringSession,
                idfsCaseType,
                idfReceivedByOffice,
                idfReceivedByPerson,
                AuditCreateUser,
                SourceSystemNameID,
                SourceSystemKeyValue
            )
            VALUES
            (@DiseaseReportID,
             @FarmID,
             @DiseaseID,
             @EnteredByPersonID,
             @ReportedByPersonID,
             @InvestigatedByPersonID,
             @ControlMeasuresObservationID,
             @SiteID,
             @ReportDate,
             @AssignedDate,
             @InvestigationDate,
             @DiagnosisDate,
             NULL,
             NULL,
             NULL,
             @EIDSSFieldAccessionID,
             @TestsConductedIndicator,
             @RowStatus,
             @ReportedByOrganizationID,
             @InvestigatedByOrganizationID,
             @ReportTypeID,
             NULL,
             @ClassificationTypeID,
             @OutbreakID,
             @EnteredDate,
             @EIDSSReportID,
             @StatusTypeID,
             NULL,
             NULL,
             @MonitoringSessionID,
             @ReportCategoryTypeID,
             @ReceivedByOrganizationID,
             @ReceivedByPersonID,
             @AuditUserName,
             10519001,
             '[{"idfVetCase":' + CAST(@DiseaseReportID AS NVARCHAR(300)) + '}]'
            );

            -- Data audit
            INSERT INTO dbo.tauDataAuditDetailCreate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfObject,
                SourceSystemNameID,
                SourceSystemKeyValue,
                AuditCreateUser,
                strObject
            )
            VALUES
            (@DataAuditEventID,
             @ObjectTableID,
             @DiseaseReportID,
             10519001,
             '[{"idfDataAuditEvent":' + CAST(@DataAuditEventID AS NVARCHAR(300)) + ',"idfObjectTable":'
             + CAST(@ObjectTableID AS NVARCHAR(300)) + '}]',
             @AuditUserName,
             @EIDSSReportID
            );

            -- Update data audit event ID on tlbObservation and tlbActivityParameters
            -- for flexible forms saved outside this DB transaction.
            UPDATE dbo.tauDataAuditDetailCreate
            SET idfDataAuditEvent = @DataAuditEventID,
                strObject = @EIDSSReportID
            WHERE idfObject = @FarmEpidemiologicalObservationID
                  AND idfDataAuditEvent IS NULL;

            UPDATE dbo.tauDataAuditDetailCreate
            SET idfDataAuditEvent = @DataAuditEventID,
                strObject = @EIDSSReportID
            WHERE idfObject = @ControlMeasuresObservationID
                  AND idfDataAuditEvent IS NULL;
            -- End data audit

            UPDATE @EventsTemp
            SET ObjectId = @DiseaseReportID,
                Note = REPLACE(Note, 'diseaseReportID=0', 'diseaseReportID=' + CAST(@DiseaseReportID AS NVARCHAR(300)))
            WHERE ObjectId = 0;

            -- Update imported samples from laboratory
            UPDATE @SamplesTemp 
            SET VeterinaryDiseaseReportID = @DiseaseReportID
            WHERE VeterinaryDiseaseReportID = 0
                  AND LabModuleSourceIndicator = 1;
        END
        ELSE
        BEGIN
            -- Data audit
        	IF @DataAuditEventID IS NULL
        	BEGIN 
				SET @DataAuditEventTypeID = 10016003; -- Data audit edit event type

				INSERT INTO @SuppressSelect
				EXECUTE dbo.USSP_GBL_DATA_AUDIT_EVENT_SET @AuditUserID,
                                                      @AuditSiteID,
                                                      @DataAuditEventTypeID,
                                                      @ObjectTypeID,
                                                      @DiseaseReportID,
                                                      @ObjectTableID,
                                                      @EIDSSReportID, 
                                                      @DataAuditEventID OUTPUT;
            END
            -- End data audit

            IF @ReportCategoryTypeID = 10012004 --Avian
            BEGIN
                INSERT INTO @SuppressSelect
                EXECUTE dbo.USSP_VET_COPY_FARM_SET @AuditUserName,
                                                   @DataAuditEventID,
                                                   @EIDSSReportID,
                                                   @FarmMasterID,
                                                   @FarmTotalAnimalQuantity,
                                                   @FarmSickAnimalQuantity,
                                                   @FarmDeadAnimalQuantity,
                                                   NULL,
                                                   NULL,
                                                   NULL,
                                                   @FarmLatitude,
                                                   @FarmLongitude,
                                                   @MonitoringSessionID,
                                                   @FarmEpidemiologicalObservationID,
                                                   @FarmOwnerID,
                                                   @FarmID OUTPUT,
                                                   @NewFarmOwnerID OUTPUT;

                IF @NewFarmOwnerID IS NOT NULL
                BEGIN
                    SET @FarmOwnerID = @NewFarmOwnerID;
                END;
            END
            ELSE --Livestock
            BEGIN
                INSERT INTO @SuppressSelect
                EXECUTE dbo.USSP_VET_COPY_FARM_SET @AuditUserName,
                                                   @DataAuditEventID,
                                                   @EIDSSReportID,
                                                   @FarmMasterID,
                                                   NULL,
                                                   NULL,
                                                   NULL,
                                                   @FarmTotalAnimalQuantity,
                                                   @FarmSickAnimalQuantity,
                                                   @FarmDeadAnimalQuantity,
                                                   @FarmLatitude,
                                                   @FarmLongitude,
                                                   @MonitoringSessionID,
                                                   @FarmEpidemiologicalObservationID,
                                                   @FarmOwnerID,
                                                   @FarmID OUTPUT,
                                                   @NewFarmOwnerID OUTPUT;

                IF @NewFarmOwnerID IS NOT NULL
                BEGIN
                    SET @FarmOwnerID = @NewFarmOwnerID;
                END;
            END
            -- Data audit
            INSERT INTO @VeterinaryDiseaseReportBeforeEdit
            (
                DiseaseReportID,
                FarmID,
                DiseaseID,
                PersonEnteredByID,
                PersonReportedByID,
                PersonInvestigatedByID,
                ObservationID,
                ReportDate,
                AssignedDate,
                InvestigationDate,
                FinalDiagnosisDate,
                FieldAccessionID,
                YNTestsConductedTypeID,
                ReportedByOfficeID,
                InvestigatedByOfficeID,
                CaseReportTypeID,
                CaseClassificationTypeID,
                OutbreakID,
                EnteredDate,
                EIDSSReportID,
                CaseProgressStatusTypeID,
                ParentMonitoringSessionID,
                CaseTypeID,
                ReceivedByOfficeID,
                ReceivedByPersonID
            )
            SELECT idfVetCase,
                   idfFarm,
                   idfsFinalDiagnosis,
                   idfPersonEnteredBy,
                   idfPersonReportedBy,
                   idfPersonInvestigatedBy,
                   idfObservation,
                   datReportDate,
                   datAssignedDate,
                   datInvestigationDate,
                   datFinalDiagnosisDate,
                   strFieldAccessionID,
                   idfsYNTestsConducted,
                   idfReportedByOffice,
                   idfInvestigatedByOffice,
                   idfsCaseReportType,
                   idfsCaseClassification,
                   idfOutbreak,
                   datEnteredDate,
                   strCaseID,
                   idfsCaseProgressStatus,
                   idfParentMonitoringSession,
                   idfsCaseType,
                   idfReceivedByOffice,
                   idfReceivedByPerson
            FROM dbo.tlbVetCase
            WHERE idfVetCase = @DiseaseReportID;
            -- End data audit

            UPDATE dbo.tlbVetCase
            SET idfFarm = @FarmID,
                idfsFinalDiagnosis = @DiseaseID,
                idfPersonEnteredBy = @EnteredByPersonID,
                idfPersonReportedBy = @ReportedByPersonID,
                idfPersonInvestigatedBy = @InvestigatedByPersonID,
                idfReceivedByPerson = @ReceivedByPersonID,
                idfObservation = @ControlMeasuresObservationID,
                idfsSite = @SiteID,
                datReportDate = @ReportDate,
                datAssignedDate = @AssignedDate,
                datInvestigationDate = @InvestigationDate,
                datFinalDiagnosisDate = @DiagnosisDate,
                strTestNotes = NULL,
                strSummaryNotes = NULL,
                strClinicalNotes = NULL,
                strFieldAccessionID = @EIDSSFieldAccessionID,
                idfsYNTestsConducted = @TestsConductedIndicator,
                intRowStatus = @RowStatus,
                idfReportedByOffice = @ReportedByOrganizationID,
                idfInvestigatedByOffice = @InvestigatedByOrganizationID,
                idfReceivedByOffice = @ReceivedByOrganizationID,
                idfsCaseReportType = @ReportTypeID,
                idfsCaseClassification = @ClassificationTypeID,
                idfOutbreak = @OutbreakID,
                datEnteredDate = @EnteredDate,
                strCaseID = @EIDSSReportID,
                idfsCaseProgressStatus = @StatusTypeID,
                strSampleNotes = NULL,
                idfParentMonitoringSession = @MonitoringSessionID,
                idfsCaseType = @ReportCategoryTypeID,
                AuditUpdateUser = @AuditUserName
            WHERE idfVetCase = @DiseaseReportID;

            -- Data audit
            INSERT INTO @VeterinaryDiseaseReportAfterEdit
            (
                DiseaseReportID,
                FarmID,
                DiseaseID,
                PersonEnteredByID,
                PersonReportedByID,
                PersonInvestigatedByID,
                ObservationID,
                ReportDate,
                AssignedDate,
                InvestigationDate,
                FinalDiagnosisDate,
                FieldAccessionID,
                YNTestsConductedTypeID,
                ReportedByOfficeID,
                InvestigatedByOfficeID,
                CaseReportTypeID,
                CaseClassificationTypeID,
                OutbreakID,
                EnteredDate,
                EIDSSReportID,
                CaseProgressStatusTypeID,
                ParentMonitoringSessionID,
                CaseTypeID,
                ReceivedByOfficeID,
                ReceivedByPersonID
            )
            SELECT idfVetCase,
                   idfFarm,
                   idfsFinalDiagnosis,
                   idfPersonEnteredBy,
                   idfPersonReportedBy,
                   idfPersonInvestigatedBy,
                   idfObservation,
                   datReportDate,
                   datAssignedDate,
                   datInvestigationDate,
                   datFinalDiagnosisDate,
                   strFieldAccessionID,
                   idfsYNTestsConducted,
                   idfReportedByOffice,
                   idfInvestigatedByOffice,
                   idfsCaseReportType,
                   idfsCaseClassification,
                   idfOutbreak,
                   datEnteredDate,
                   strCaseID,
                   idfsCaseProgressStatus,
                   idfParentMonitoringSession,
                   idfsCaseType,
                   idfReceivedByOffice,
                   idfReceivedByPerson
            FROM dbo.tlbVetCase
            WHERE idfVetCase = @DiseaseReportID;

            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue,
                AuditCreateUser,
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   4575810000000,
                   a.DiseaseReportID,
                   NULL,
                   b.FarmID,
                   a.FarmID,
                   @AuditUserName,
                   @EIDSSReportID
            FROM @VeterinaryDiseaseReportAfterEdit AS a
                FULL JOIN @VeterinaryDiseaseReportBeforeEdit AS b
                    ON a.DiseaseReportID = b.DiseaseReportID
            WHERE (a.FarmID <> b.FarmID)
                  OR (
                         a.FarmID IS NOT NULL
                         AND b.FarmID IS NULL
                     )
                  OR (
                         a.FarmID IS NULL
                         AND b.FarmID IS NOT NULL
                     );

            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue,
                AuditCreateUser,
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   80940000000,
                   a.DiseaseReportID,
                   NULL,
                   b.DiseaseID,
                   a.DiseaseID,
                   @AuditUserName,
                   @EIDSSReportID
            FROM @VeterinaryDiseaseReportAfterEdit AS a
                FULL JOIN @VeterinaryDiseaseReportBeforeEdit AS b
                    ON a.DiseaseReportID = b.DiseaseReportID
            WHERE (a.DiseaseID <> b.DiseaseID)
                  OR (
                         a.DiseaseID IS NOT NULL
                         AND b.DiseaseID IS NULL
                     )
                  OR (
                         a.DiseaseID IS NULL
                         AND b.DiseaseID IS NOT NULL
                     );

            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue,
                AuditCreateUser,
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   80910000000,
                   a.DiseaseReportID,
                   NULL,
                   b.PersonEnteredByID,
                   a.PersonEnteredByID,
                   @AuditUserName,
                   @EIDSSReportID
            FROM @VeterinaryDiseaseReportAfterEdit AS a
                FULL JOIN @VeterinaryDiseaseReportBeforeEdit AS b
                    ON a.DiseaseReportID = b.DiseaseReportID
            WHERE (a.PersonEnteredByID <> b.PersonEnteredByID)
                  OR (
                         a.PersonEnteredByID IS NOT NULL
                         AND b.PersonEnteredByID IS NULL
                     )
                  OR (
                         a.PersonEnteredByID IS NULL
                         AND b.PersonEnteredByID IS NOT NULL
                     );

            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue,
                AuditCreateUser,
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   80930000000,
                   a.DiseaseReportID,
                   NULL,
                   b.PersonReportedByID,
                   a.PersonReportedByID,
                   @AuditUserName,
                   @EIDSSReportID
            FROM @VeterinaryDiseaseReportAfterEdit AS a
                FULL JOIN @VeterinaryDiseaseReportBeforeEdit AS b
                    ON a.DiseaseReportID = b.DiseaseReportID
            WHERE (a.PersonReportedByID <> b.PersonReportedByID)
                  OR (
                         a.PersonReportedByID IS NOT NULL
                         AND b.PersonReportedByID IS NULL
                     )
                  OR (
                         a.PersonReportedByID IS NULL
                         AND b.PersonReportedByID IS NOT NULL
                     );

            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue,
                AuditCreateUser,
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   80920000000,
                   a.DiseaseReportID,
                   NULL,
                   b.PersonInvestigatedByID,
                   a.PersonInvestigatedByID,
                   @AuditUserName,
                   @EIDSSReportID
            FROM @VeterinaryDiseaseReportAfterEdit AS a
                FULL JOIN @VeterinaryDiseaseReportBeforeEdit AS b
                    ON a.DiseaseReportID = b.DiseaseReportID
            WHERE (a.PersonInvestigatedByID <> b.PersonInvestigatedByID)
                  OR (
                         a.PersonInvestigatedByID IS NOT NULL
                         AND b.PersonInvestigatedByID IS NULL
                     )
                  OR (
                         a.PersonInvestigatedByID IS NULL
                         AND b.PersonInvestigatedByID IS NOT NULL
                     );

            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue,
                AuditCreateUser,
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   4566320000000,
                   a.DiseaseReportID,
                   NULL,
                   b.ObservationID,
                   a.ObservationID,
                   @AuditUserName,
                   @EIDSSReportID
            FROM @VeterinaryDiseaseReportAfterEdit AS a
                FULL JOIN @VeterinaryDiseaseReportBeforeEdit AS b
                    ON a.DiseaseReportID = b.DiseaseReportID
            WHERE (a.ObservationID <> b.ObservationID)
                  OR (
                         a.ObservationID IS NOT NULL
                         AND b.ObservationID IS NULL
                     )
                  OR (
                         a.ObservationID IS NULL
                         AND b.ObservationID IS NOT NULL
                     )

            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue,
                AuditCreateUser,
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   80870000000,
                   a.DiseaseReportID,
                   NULL,
                   b.ReportDate,
                   a.ReportDate,
                   @AuditUserName,
                   @EIDSSReportID
            FROM @VeterinaryDiseaseReportAfterEdit AS a
                FULL JOIN @VeterinaryDiseaseReportBeforeEdit AS b
                    ON a.DiseaseReportID = b.DiseaseReportID
            WHERE (a.ReportDate <> b.ReportDate)
                  OR (
                         a.ReportDate IS NOT NULL
                         AND b.ReportDate IS NULL
                     )
                  OR (
                         a.ReportDate IS NULL
                         AND b.ReportDate IS NOT NULL
                     );

            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue,
                AuditCreateUser,
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   80850000000,
                   a.DiseaseReportID,
                   NULL,
                   b.AssignedDate,
                   a.AssignedDate,
                   @AuditUserName,
                   @EIDSSReportID
            FROM @VeterinaryDiseaseReportAfterEdit AS a
                FULL JOIN @VeterinaryDiseaseReportBeforeEdit AS b
                    ON a.DiseaseReportID = b.DiseaseReportID
            WHERE (a.AssignedDate <> b.AssignedDate)
                  OR (
                         a.AssignedDate IS NOT NULL
                         AND b.AssignedDate IS NULL
                     )
                  OR (
                         a.AssignedDate IS NULL
                         AND b.AssignedDate IS NOT NULL
                     );

            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue,
                AuditCreateUser,
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   4566330000000,
                   a.DiseaseReportID,
                   NULL,
                   b.InvestigationDate,
                   a.InvestigationDate,
                   @AuditUserName,
                   @EIDSSReportID
            FROM @VeterinaryDiseaseReportAfterEdit AS a
                FULL JOIN @VeterinaryDiseaseReportBeforeEdit AS b
                    ON a.DiseaseReportID = b.DiseaseReportID
            WHERE (a.InvestigationDate <> b.InvestigationDate)
                  OR (
                         a.InvestigationDate IS NOT NULL
                         AND b.InvestigationDate IS NULL
                     )
                  OR (
                         a.InvestigationDate IS NULL
                         AND b.InvestigationDate IS NOT NULL
                     );

            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue,
                AuditCreateUser,
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   80860000000,
                   a.DiseaseReportID,
                   NULL,
                   b.FinalDiagnosisDate,
                   a.FinalDiagnosisDate,
                   @AuditUserName,
                   @EIDSSReportID
            FROM @VeterinaryDiseaseReportAfterEdit AS a
                FULL JOIN @VeterinaryDiseaseReportBeforeEdit AS b
                    ON a.DiseaseReportID = b.DiseaseReportID
            WHERE (a.FinalDiagnosisDate <> b.FinalDiagnosisDate)
                  OR (
                         a.FinalDiagnosisDate IS NOT NULL
                         AND b.FinalDiagnosisDate IS NULL
                     )
                  OR (
                         a.FinalDiagnosisDate IS NULL
                         AND b.FinalDiagnosisDate IS NOT NULL
                     );

            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue,
                AuditCreateUser,
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   4566340000000,
                   a.DiseaseReportID,
                   NULL,
                   b.FieldAccessionID,
                   a.FieldAccessionID,
                   @AuditUserName,
                   @EIDSSReportID
            FROM @VeterinaryDiseaseReportAfterEdit AS a
                FULL JOIN @VeterinaryDiseaseReportBeforeEdit AS b
                    ON a.DiseaseReportID = b.DiseaseReportID
            WHERE (a.FieldAccessionID <> b.FieldAccessionID)
                  OR (
                         a.FieldAccessionID IS NOT NULL
                         AND b.FieldAccessionID IS NULL
                     )
                  OR (
                         a.FieldAccessionID IS NULL
                         AND b.FieldAccessionID IS NOT NULL
                     );

            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue,
                AuditCreateUser,
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   4578870000000,
                   a.DiseaseReportID,
                   NULL,
                   b.YNTestsConductedTypeID,
                   a.YNTestsConductedTypeID,
                   @AuditUserName,
                   @EIDSSReportID
            FROM @VeterinaryDiseaseReportAfterEdit AS a
                FULL JOIN @VeterinaryDiseaseReportBeforeEdit AS b
                    ON a.DiseaseReportID = b.DiseaseReportID
            WHERE (a.YNTestsConductedTypeID <> b.YNTestsConductedTypeID)
                  OR (
                         a.YNTestsConductedTypeID IS NOT NULL
                         AND b.YNTestsConductedTypeID IS NULL
                     )
                  OR (
                         a.YNTestsConductedTypeID IS NULL
                         AND b.YNTestsConductedTypeID IS NOT NULL
                     );

            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue,
                AuditCreateUser,
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   6618090000000,
                   a.DiseaseReportID,
                   NULL,
                   b.ReportedByOfficeID,
                   a.ReportedByOfficeID,
                   @AuditUserName,
                   @EIDSSReportID
            FROM @VeterinaryDiseaseReportAfterEdit AS a
                FULL JOIN @VeterinaryDiseaseReportBeforeEdit AS b
                    ON a.DiseaseReportID = b.DiseaseReportID
            WHERE (a.ReportedByOfficeID <> b.ReportedByOfficeID)
                  OR (
                         a.ReportedByOfficeID IS NOT NULL
                         AND b.ReportedByOfficeID IS NULL
                     )
                  OR (
                         a.ReportedByOfficeID IS NULL
                         AND b.ReportedByOfficeID IS NOT NULL
                     );

            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue,
                AuditCreateUser,
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   6618100000000,
                   a.DiseaseReportID,
                   NULL,
                   b.InvestigatedByOfficeID,
                   a.InvestigatedByOfficeID,
                   @AuditUserName,
                   @EIDSSReportID
            FROM @VeterinaryDiseaseReportAfterEdit AS a
                FULL JOIN @VeterinaryDiseaseReportBeforeEdit AS b
                    ON a.DiseaseReportID = b.DiseaseReportID
            WHERE (a.InvestigatedByOfficeID <> b.InvestigatedByOfficeID)
                  OR (
                         a.InvestigatedByOfficeID IS NOT NULL
                         AND b.InvestigatedByOfficeID IS NULL
                     )
                  OR (
                         a.InvestigatedByOfficeID IS NULL
                         AND b.InvestigatedByOfficeID IS NOT NULL
                     );

            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue,
                AuditCreateUser,
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   6618120000000,
                   a.DiseaseReportID,
                   NULL,
                   b.CaseReportTypeID,
                   a.CaseReportTypeID,
                   @AuditUserName,
                   @EIDSSReportID
            FROM @VeterinaryDiseaseReportAfterEdit AS a
                FULL JOIN @VeterinaryDiseaseReportBeforeEdit AS b
                    ON a.DiseaseReportID = b.DiseaseReportID
            WHERE (a.CaseReportTypeID <> b.CaseReportTypeID)
                  OR (
                         a.CaseReportTypeID IS NOT NULL
                         AND b.CaseReportTypeID IS NULL
                     )
                  OR (
                         a.CaseReportTypeID IS NULL
                         AND b.CaseReportTypeID IS NOT NULL
                     );

            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue,
                AuditCreateUser,
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   12665470000000,
                   a.DiseaseReportID,
                   NULL,
                   b.CaseClassificationTypeID,
                   a.CaseClassificationTypeID,
                   @AuditUserName,
                   @EIDSSReportID
            FROM @VeterinaryDiseaseReportAfterEdit AS a
                FULL JOIN @VeterinaryDiseaseReportBeforeEdit AS b
                    ON a.DiseaseReportID = b.DiseaseReportID
            WHERE (a.CaseClassificationTypeID <> b.CaseClassificationTypeID)
                  OR (
                         a.CaseClassificationTypeID IS NOT NULL
                         AND b.CaseClassificationTypeID IS NULL
                     )
                  OR (
                         a.CaseClassificationTypeID IS NULL
                         AND b.CaseClassificationTypeID IS NOT NULL
                     );

            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue,
                AuditCreateUser,
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   12665490000000,
                   a.DiseaseReportID,
                   NULL,
                   b.OutbreakID,
                   a.OutbreakID,
                   @AuditUserName,
                   @EIDSSReportID
            FROM @VeterinaryDiseaseReportAfterEdit AS a
                FULL JOIN @VeterinaryDiseaseReportBeforeEdit AS b
                    ON a.DiseaseReportID = b.DiseaseReportID
            WHERE (a.OutbreakID <> b.OutbreakID)
                  OR (
                         a.OutbreakID IS NOT NULL
                         AND b.OutbreakID IS NULL
                     )
                  OR (
                         a.OutbreakID IS NULL
                         AND b.OutbreakID IS NOT NULL
                     );

            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue,
                AuditCreateUser,
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   12665500000000,
                   a.DiseaseReportID,
                   NULL,
                   b.EnteredDate,
                   a.EnteredDate,
                   @AuditUserName,
                   @EIDSSReportID
            FROM @VeterinaryDiseaseReportAfterEdit AS a
                FULL JOIN @VeterinaryDiseaseReportBeforeEdit AS b
                    ON a.DiseaseReportID = b.DiseaseReportID
            WHERE (a.EnteredDate <> b.EnteredDate)
                  OR (
                         a.EnteredDate IS NOT NULL
                         AND b.EnteredDate IS NULL
                     )
                  OR (
                         a.EnteredDate IS NULL
                         AND b.EnteredDate IS NOT NULL
                     );

            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue,
                AuditCreateUser,
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   12665510000000,
                   a.DiseaseReportID,
                   NULL,
                   b.EIDSSReportID,
                   a.EIDSSReportID,
                   @AuditUserName,
                   @EIDSSReportID
            FROM @VeterinaryDiseaseReportAfterEdit AS a
                FULL JOIN @VeterinaryDiseaseReportBeforeEdit AS b
                    ON a.DiseaseReportID = b.DiseaseReportID
            WHERE (a.EIDSSReportID <> b.EIDSSReportID)
                  OR (
                         a.EIDSSReportID IS NOT NULL
                         AND b.EIDSSReportID IS NULL
                     )
                  OR (
                         a.EIDSSReportID IS NULL
                         AND b.EIDSSReportID IS NOT NULL
                     );

            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue,
                AuditCreateUser,
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   12665520000000,
                   a.DiseaseReportID,
                   NULL,
                   b.CaseProgressStatusTypeID,
                   a.CaseProgressStatusTypeID,
                   @AuditUserName,
                   @EIDSSReportID
            FROM @VeterinaryDiseaseReportAfterEdit AS a
                FULL JOIN @VeterinaryDiseaseReportBeforeEdit AS b
                    ON a.DiseaseReportID = b.DiseaseReportID
            WHERE (a.CaseProgressStatusTypeID <> b.CaseProgressStatusTypeID)
                  OR (
                         a.CaseProgressStatusTypeID IS NOT NULL
                         AND b.CaseProgressStatusTypeID IS NULL
                     )
                  OR (
                         a.CaseProgressStatusTypeID IS NULL
                         AND b.CaseProgressStatusTypeID IS NOT NULL
                     );

            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue,
                AuditCreateUser,
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   12665540000000,
                   a.DiseaseReportID,
                   NULL,
                   b.ParentMonitoringSessionID,
                   a.ParentMonitoringSessionID,
                   @AuditUserName,
                   @EIDSSReportID
            FROM @VeterinaryDiseaseReportAfterEdit AS a
                FULL JOIN @VeterinaryDiseaseReportBeforeEdit AS b
                    ON a.DiseaseReportID = b.DiseaseReportID
            WHERE (a.ParentMonitoringSessionID <> b.ParentMonitoringSessionID)
                  OR (
                         a.ParentMonitoringSessionID IS NOT NULL
                         AND b.ParentMonitoringSessionID IS NULL
                     )
                  OR (
                         a.ParentMonitoringSessionID IS NULL
                         AND b.ParentMonitoringSessionID IS NOT NULL
                     );

            INSERT INTO dbo.tauDataAuditDetailUpdate
            (
                idfDataAuditEvent,
                idfObjectTable,
                idfColumn,
                idfObject,
                idfObjectDetail,
                strOldValue,
                strNewValue,
                AuditCreateUser,
                strObject
            )
            SELECT @DataAuditEventID,
                   @ObjectTableID,
                   12665560000000,
                   a.DiseaseReportID,
                   NULL,
                   b.CaseTypeID,
                   a.CaseTypeID,
                   @AuditUserName,
                   @EIDSSReportID
            FROM @VeterinaryDiseaseReportAfterEdit AS a
                FULL JOIN @VeterinaryDiseaseReportBeforeEdit AS b
                    ON a.DiseaseReportID = b.DiseaseReportID
            WHERE (a.CaseTypeID <> b.CaseTypeID)
                  OR (
                         a.CaseTypeID IS NOT NULL
                         AND b.CaseTypeID IS NULL
                     )
                  OR (
                         a.CaseTypeID IS NULL
                         AND b.CaseTypeID IS NOT NULL
                     );
        END;

        -- VUC11 and VUC12 - connected disease report logic.
        IF @RelatedToDiseaseReportID IS NOT NULL
        BEGIN
            IF NOT EXISTS
            (
                SELECT *
                FROM dbo.VetDiseaseReportRelationship
                WHERE VetDiseaseReportID = @DiseaseReportID
                      AND intRowStatus = 0
            )
            BEGIN
                INSERT INTO @SuppressSelect
                EXECUTE dbo.USP_GBL_NEXTKEYID_GET 'VetDiseaseReportRelationship',
                                                  @VeterinaryDiseaseReportRelationshipID OUTPUT;

                INSERT INTO dbo.VetDiseaseReportRelationship
                (
                    VetDiseaseReportRelnUID,
                    VetDiseaseReportID,
                    RelatedToVetDiseaseReportID,
                    RelationshipTypeID,
                    intRowStatus,
                    SourceSystemNameID,
                    SourceSystemKeyValue,
                    AuditCreateUser
                )
                VALUES
                (@VeterinaryDiseaseReportRelationshipID,
                 @DiseaseReportID,
                 @RelatedToDiseaseReportID,
                 10503001,
                 0  ,
                 10519001,
                 '[{"VetDiseaseReportRelnUID":' + CAST(@VeterinaryDiseaseReportRelationshipID AS NVARCHAR(300))
                 + ',"VetDiseaseReportID":' + CAST(@DiseaseReportID AS NVARCHAR(300)) + '}]',
                 @AuditUserName
                );

                -- Data audit
                INSERT INTO dbo.tauDataAuditDetailCreate
                (
                    idfDataAuditEvent,
                    idfObjectTable,
                    idfObject,
                    SourceSystemNameID,
                    SourceSystemKeyValue,
                    AuditCreateUser,
                    strObject
                )
                VALUES
                (@DataAuditEventID,
                 @ObjectVeterinaryDiseaseReportRelationshipTableID,
                 @VeterinaryDiseaseReportRelationshipID,
                 10519001,
                 '[{"idfDataAuditEvent":' + CAST(@DataAuditEventID AS NVARCHAR(300)) + ',"idfObjectTable":'
                 + CAST(@ObjectVeterinaryDiseaseReportRelationshipTableID AS NVARCHAR(300)) + '}]',
                 @AuditUserName,
                 @EIDSSReportID
                );
            -- End data audit
            END;
        END;

        -- An outbreak reference via a case must be created in order to tie the disease report to the outbreak session.
        IF @OutbreakCaseIndicator = 1
        BEGIN
            IF @OutbreakCaseReportUID IS NULL
            BEGIN
                INSERT INTO @SuppressSelect
                EXEC dbo.USP_GBL_NEXTKEYID_GET 'OutbreakCaseReport',
                                               @OutbreakCaseReportUID OUTPUT;

                INSERT INTO @SuppressSelect
                EXEC dbo.USP_GBL_NextNumber_GET 'Vet Outbreak Case',
                                                @EIDSSCaseID OUTPUT,
                                                NULL;

                INSERT INTO dbo.OutbreakCaseReport
                (
                    OutbreakCaseReportUID,
                    idfOutbreak,
                    strOutbreakCaseID,
                    idfHumanCase,
                    idfVetCase,
                    OutbreakCaseObservationId,
                    OutbreakCaseStatusId,
                    OutbreakCaseClassificationID,
                    IsPrimaryCaseFlag,
                    intRowStatus,
                    SourceSystemNameID,
                    SourceSystemKeyValue,
                    AuditCreateUser,
                    AuditCreateDTM,
                    AuditUpdateUser,
                    AuditUpdateDTM
                )
                VALUES
                (@OutbreakCaseReportUID,
                 @OutbreakID,
                 @EIDSSCaseID,
                 NULL,
                 @DiseaseReportID,
                 @OutbreakCaseQuestionnaireObservationID,
                 @OutbreakCaseStatusTypeID,
                 @ClassificationTypeID,
                 @PrimaryCaseIndicator,
                 0  ,
                 10519001,
                 '[{"OutBreakCaseReportUID":' + CAST(@OutbreakCaseReportUID AS NVARCHAR(300)) + ',"idfOutbreak":'
                 + CAST(@OutbreakID AS NVARCHAR(300)) + '}]',
                 @AuditUserName,
                 GETDATE(),
                 @AuditUserName,
                 GETDATE()
                );
            END
            ELSE
            BEGIN
                UPDATE dbo.OutbreakCaseReport
                SET OutbreakCaseStatusId = @OutbreakCaseStatusTypeID,
                    OutbreakCaseClassificationID = @ClassificationTypeID,
                    IsPrimaryCaseFlag = @PrimaryCaseIndicator,
                    intRowStatus = 0,
                    AuditUpdateUser = @AuditUserName,
                    AuditUpdateDTM = GETDATE(),
                    OutbreakCaseObservationID = @OutbreakCaseQuestionnaireObservationID
                WHERE OutbreakCaseReportUID = @OutbreakCaseReportUID;
            END
        END

        WHILE EXISTS (SELECT * FROM @FlocksOrHerdsTemp)
        BEGIN
            SELECT TOP 1
                @RowID = FlockOrHerdID,
                @FlockOrHerdID = FlockOrHerdID,
                @FlockOrHerdMasterID = FlockOrHerdMasterID,
                @EIDSSFlockOrHerdID = EIDSSFlockOrHerdID,
                @SickAnimalQuantity = SickAnimalQuantity,
                @TotalAnimalQuantity = TotalAnimalQuantity,
                @DeadAnimalQuantity = DeadAnimalQuantity,
                @RowStatus = RowStatus,
                @RowAction = RowAction
            FROM @FlocksOrHerdsTemp;

            INSERT INTO @SuppressSelect
            EXECUTE dbo.USSP_VET_FLOCK_HERD_SET @AuditUserName,
                                                @DataAuditEventID,
                                                @EIDSSReportID,
                                                @FlockOrHerdID OUTPUT,
                                                @FlockOrHerdMasterID,
                                                @FarmID,
                                                @EIDSSFlockOrHerdID,
                                                @SickAnimalQuantity,
                                                @TotalAnimalQuantity,
                                                @DeadAnimalQuantity,
                                                NULL,
                                                @RowStatus,
                                                @RowAction;

            UPDATE @SpeciesTemp
            SET FlockOrHerdID = @FlockOrHerdID
            WHERE FlockOrHerdID = @RowID;

            DELETE FROM @FlocksOrHerdsTemp
            WHERE FLockOrHerdID = @RowID;
        END;

        WHILE EXISTS (SELECT * FROM @SpeciesTemp)
        BEGIN
            SELECT TOP 1
                @RowID = SpeciesID,
                @SpeciesID = SpeciesID,
                @SpeciesMasterID = SpeciesMasterID,
                @SpeciesTypeID = SpeciesTypeID,
                @FlockOrHerdID = FlockOrHerdID,
                @StartOfSignsDate = StartOfSignsDate,
                @AverageAge = AverageAge,
                @SickAnimalQuantity = SickAnimalQuantity,
                @TotalAnimalQuantity = TotalAnimalQuantity,
                @DeadAnimalQuantity = DeadAnimalQuantity,
                @Comments = Comments,
                @ObservationID = ObservationID,
                @RowStatus = RowStatus,
                @RowAction = RowAction,
                @RelatedToSpeciesID = RelatedToSpeciesID,
                @RelatedToObservationID = RelatedToObservationID,
                @OutbreakSpeciesCaseStatusTypeID = OutbreakCaseStatusTypeID
            FROM @SpeciesTemp;

            -- VUC11 and VUC12 - connected disease report logic for clinical species investigations.
            IF @RelatedToDiseaseReportID IS NOT NULL
               AND @RowAction = 1 -- Insert
            BEGIN
                IF @RelatedToObservationID IS NOT NULL
                BEGIN
                    SELECT @FormTemplateID = idfsFormTemplate,
                           @ObservationSiteID = idfsSite
                    FROM dbo.tlbObservation
                    WHERE idfObservation = @RelatedToObservationID;

                    SET @ObservationID = -1;

                    INSERT INTO @SuppressSelect
                    EXECUTE dbo.USSP_GBL_OBSERVATION_SET @ObservationID OUTPUT,
                                                         @FormTemplateID,
                                                         @ObservationSiteID,
                                                         0,
                                                         1, 
                                                         @AuditUserName, 
                                                         @DataAuditEventID, 
                                                         @EIDSSReportID;

                    UPDATE @SpeciesTemp
                    SET ObservationID = @ObservationID
                    WHERE SpeciesMasterID = @SpeciesMasterID;

                    INSERT INTO @ActivityParametersTemp
                    SELECT idfActivityParameters,
                           idfsParameter,
                           varValue,
                           idfRow
                    FROM dbo.tlbActivityParameters
                    WHERE idfObservation = @RelatedToObservationID;

                    WHILE EXISTS (SELECT * FROM @ActivityParametersTemp)
                    BEGIN
                        SELECT TOP 1
                            @ActivityID = ActivityID,
                            @ParameterID = ParameterID,
                            @ParameterValue = ParameterValue,
                            @ParameterRowID = ParameterRowID
                        FROM @ActivityParametersTemp;

                        INSERT INTO @SuppressSelect
                        EXECUTE dbo.USP_GBL_NEXTKEYID_GET 'tlbActivityParameters',
                                                          @ActivityIDNew OUTPUT;

                        INSERT INTO dbo.tlbActivityParameters
                        (
                            idfActivityParameters,
                            idfsParameter,
                            idfObservation,
                            varValue,
                            idfRow,
                            intRowStatus,
                            SourceSystemNameID,
                            SourceSystemKeyValue,
                            AuditCreateUser,
                            AuditCreateDTM
                        )
                        VALUES
                        (@ActivityIDNew,
                         @ParameterID,
                         @ObservationID,
                         @ParameterValue,
                         @ParameterRowID,
                         0  ,
                         10519001,
                         '[{"idfActivityParameters":' + CAST(@ActivityIDNew AS NVARCHAR(300)) + '}]',
                         @AuditUserName,
                         GETDATE()
                        );

                        -- Data audit
                        INSERT INTO dbo.tauDataAuditDetailCreate
                        (
                            idfDataAuditEvent,
                            idfObjectTable,
                            idfObject,
                            idfObjectDetail,
                            SourceSystemNameID,
                            SourceSystemKeyValue,
                            AuditCreateUser
                        )
                        VALUES
                        (@DataAuditEventID,
                         @ObjectActivityParametersTableID,
                         @ActivityIDNew,
                         @ObservationID,
                         10519001,
                         '[{"idfDataAuditEvent":' + CAST(@DataAuditEventID AS NVARCHAR(300)) + ',"idfObjectTable":'
                         + CAST(@ObjectActivityParametersTableID AS NVARCHAR(300)) + '}]',
                         @AuditUserName
                        );
                        -- End data audit

                        DELETE FROM @ActivityParametersTemp
                        WHERE ActivityID = @ActivityID;
                    END;
                END;
            END;

            INSERT INTO @SuppressSelect
            EXECUTE dbo.USSP_VET_SPECIES_WITH_AUDITING_SET @AuditUserName,
                                                           @DataAuditEventID,
                                                           @EIDSSReportID,
                                                           @SpeciesID OUTPUT,
                                                           @SpeciesMasterID,
                                                           @SpeciesTypeID,
                                                           @FlockOrHerdID,
                                                           @ObservationID,
                                                           @StartOfSignsDate,
                                                           @AverageAge,
                                                           @SickAnimalQuantity,
                                                           @TotalAnimalQuantity,
                                                           @DeadAnimalQuantity,
                                                           @Comments,
                                                           @RowStatus,
                                                           @RowAction,
                                                           @OutbreakSpeciesCaseStatusTypeID;

            UPDATE @AnimalsTemp
            SET SpeciesID = @SpeciesID
            WHERE SpeciesID = @RowID;

            UPDATE @VaccinationsTemp
            SET SpeciesID = @SpeciesID
            WHERE SpeciesID = @RowID;

            UPDATE @SamplesTemp
            SET SpeciesID = @SpeciesID
            WHERE SpeciesID = @RowID;

            DELETE FROM @SpeciesTemp
            WHERE SpeciesID = @RowID;
        END;

        WHILE EXISTS (SELECT * FROM @AnimalsTemp)
        BEGIN
            SELECT TOP 1
                @RowID = AnimalID,
                @AnimalID = AnimalID,
                @SexTypeID = SexTypeID,
                @ConditionTypeID = ConditionTypeID,
                @AgeTypeID = AgeTypeID,
                @SpeciesID = SpeciesID,
                @ObservationID = ObservationID,
                @AnimalDescription = AnimalDescription,
                @EIDSSAnimalID = EIDSSAnimalID,
                @AnimalName = AnimalName,
                @Color = Color,
                @ClinicalSignsIndicator = ClinicalSignsIndicator,
                @RowStatus = RowStatus,
                @RowAction = RowAction
            FROM @AnimalsTemp;

            -- VUC11 and VUC12 - connected disease report logic for clinical signs.
            IF @RelatedToDiseaseReportID IS NOT NULL
               AND @RowAction = 1 -- Insert
               AND @ObservationID IS NOT NULL
            BEGIN
                SELECT @FormTemplateID = idfsFormTemplate,
                       @ObservationSiteID = idfsSite
                FROM dbo.tlbObservation
                WHERE idfObservation = @ObservationID;

                DELETE FROM @ActivityParametersTemp;

                INSERT INTO @ActivityParametersTemp
                SELECT idfActivityParameters,
                       idfsParameter,
                       varValue,
                       idfRow
                FROM dbo.tlbActivityParameters
                WHERE idfObservation = @ObservationID;

                SET @ObservationID = -1;

                INSERT INTO @SuppressSelect
                EXECUTE dbo.USSP_GBL_OBSERVATION_SET @ObservationID OUTPUT,
                                                     @FormTemplateID,
                                                     @ObservationSiteID,
                                                     0,
                                                     1, 
                                                     @AuditUserName, 
                                                     @DataAuditEventID, 
                                                     @EIDSSReportID;

                UPDATE @AnimalsTemp
                SET ObservationID = @ObservationID
                WHERE AnimalID = @RowID;


                WHILE EXISTS (SELECT * FROM @ActivityParametersTemp)
                BEGIN
                    SELECT TOP 1
                        @ActivityID = ActivityID,
                        @ParameterID = ParameterID,
                        @ParameterValue = ParameterValue,
                        @ParameterRowID = ParameterRowID
                    FROM @ActivityParametersTemp;

                    INSERT INTO @SuppressSelect
                    EXECUTE dbo.USP_GBL_NEXTKEYID_GET 'tlbActivityParameters',
                                                      @ActivityIDNew OUTPUT;

                    INSERT INTO dbo.tlbActivityParameters
                    (
                        idfActivityParameters,
                        idfsParameter,
                        idfObservation,
                        varValue,
                        idfRow,
                        intRowStatus,
                        SourceSystemNameID,
                        SourceSystemKeyValue,
                        AuditCreateUser,
                        AuditCreateDTM
                    )
                    VALUES
                    (@ActivityIDNew,
                     @ParameterID,
                     @ObservationID,
                     @ParameterValue,
                     @ParameterRowID,
                     0  ,
                     10519001,
                     '[{"idfActivityParameters":' + CAST(@ActivityIDNew AS NVARCHAR(300)) + '}]',
                     @AuditUserName,
                     GETDATE()
                    );

                    -- Data audit
                    INSERT INTO dbo.tauDataAuditDetailCreate
                    (
                        idfDataAuditEvent,
                        idfObjectTable,
                        idfObject,
                        idfObjectDetail,
                        SourceSystemNameID,
                        SourceSystemKeyValue,
                        AuditCreateUser
                    )
                    VALUES
                    (@DataAuditEventID,
                     @ObjectActivityParametersTableID,
                     @ActivityIDNew,
                     @ObservationID,
                     10519001,
                     '[{"idfDataAuditEvent":' + CAST(@DataAuditEventID AS NVARCHAR(300)) + ',"idfObjectTable":'
                     + CAST(@ObjectActivityParametersTableID AS NVARCHAR(300)) + '}]',
                     @AuditUserName
                    );
                    -- End data audit

                    DELETE FROM @ActivityParametersTemp
                    WHERE ActivityID = @ActivityID;
                END;
            END;

            INSERT INTO @SuppressSelect
            EXECUTE dbo.USSP_VET_ANIMALS_SET @AuditUserName,
                                             @DataAuditEventID,
                                             @EIDSSReportID,
                                             @AnimalID OUTPUT,
                                             @SexTypeID,
                                             @ConditionTypeID,
                                             @AgeTypeID,
                                             @SpeciesID,
                                             @ObservationID,
                                             @AnimalDescription,
                                             @EIDSSAnimalID,
                                             @AnimalName,
                                             @Color,
                                             @ClinicalSignsIndicator,
                                             @RowStatus,
                                             @RowAction;

            UPDATE @SamplesTemp
            SET AnimalID = @AnimalID
            WHERE AnimalID = @RowID;

            DELETE FROM @AnimalsTemp
            WHERE AnimalID = @RowID;
        END;

        WHILE EXISTS (SELECT * FROM @VaccinationsTemp)
        BEGIN
            SELECT TOP 1
                @RowID = VaccinationID,
                @VaccinationID = VaccinationID,
                @SpeciesID = SpeciesID,
                @VaccinationTypeID = VaccinationTypeID,
                @RouteTypeID = RouteTypeID,
                @DiseaseID = DiseaseID,
                @VaccinationDate = VaccinationDate,
                @Manufacturer = Manufacturer,
                @LotNumber = LotNumber,
                @NumberVaccinated = NumberVaccinated,
                @Comments = Comments,
                @RowStatus = RowStatus,
                @RowAction = RowAction
            FROM @VaccinationsTemp;

            INSERT INTO @SuppressSelect
            EXECUTE dbo.USSP_VET_VACCINATIONS_SET @AuditUserName,
                                                  @DataAuditEventID,
                                                  @EIDSSReportID,
                                                  @VaccinationID OUTPUT,
                                                  @DiseaseReportID,
                                                  @SpeciesID,
                                                  @VaccinationTypeID,
                                                  @RouteTypeID,
                                                  @DiseaseID,
                                                  @VaccinationDate,
                                                  @Manufacturer,
                                                  @LotNumber,
                                                  @NumberVaccinated,
                                                  @Comments,
                                                  @RowStatus,
                                                  @RowAction;

            DELETE FROM @VaccinationsTemp
            WHERE VaccinationID = @RowID;
        END;

        IF @Contacts IS NOT NULL
            EXEC dbo.USSP_OMM_CONTACT_SET NULL,
                                          @Contacts,
                                          @User = @AuditUserName,
                                          @OutBreakCaseReportUID = @OutbreakCaseReportUID,
                                          @FunctionCall = 1;

        WHILE EXISTS (SELECT * FROM @SamplesTemp)
        BEGIN
            SELECT TOP 1
                @RowID = SampleID,
                @SampleID = SampleID,
                @SampleTypeID = SampleTypeID,
                @RootSampleID = RootSampleID,
                @ParentSampleID = ParentSampleID,
                @SpeciesID = SpeciesID,
                @AnimalID = AnimalID,
                @SampleDiseaseReportID = VeterinaryDiseaseReportID,
                @MonitoringSessionID = MonitoringSessionID,
                @CollectedByPersonID = CollectedByPersonID,
                @CollectedByOrganizationID = CollectedByOrganizationID,
                @CollectionDate = CollectionDate,
                @SentDate = SentDate,
                @EIDSSLocalOrFieldSampleID = EIDSSLocalOrFieldSampleID,
                @SampleStatusTypeID = SampleStatusTypeID,
                @EnteredDate = EnteredDate,
                @Comments = Comments,
                @SiteID = SiteID,
                @CurrentSiteID = CurrentSiteID,
                @RowStatus = RowStatus,
                @SentToOrganizationID = SentToOrganizationID,
                @BirdStatusTypeID = BirdStatusTypeID,
                @ReadOnlyIndicator = ReadOnlyIndicator,
                @LabModuleSourceIndicator = LabModuleSourceIndicator,
                @RowAction = RowAction
            FROM @SamplesTemp;

            IF (
                   @EIDSSLocalOrFieldSampleID IS NULL
                   OR @EIDSSLocalOrFieldSampleID = ''
               )
               AND @LinkLocalOrFieldSampleIDToReportID = 1
            BEGIN
                SET @Iteration = @Iteration + 1;
                IF @Iteration < 10
                BEGIN
                    SET @EIDSSLocalOrFieldSampleID = @EIDSSReportID + '-0' + CONVERT(NVARCHAR(4), @Iteration);
                END
                ELSE
                BEGIN
                    SET @EIDSSLocalOrFieldSampleID = @EIDSSReportID + '-' + CONVERT(NVARCHAR(4), @Iteration);
                END;
            END;

            -- Check if sample is being de-linked, so use sample disease report ID passed in from 
            -- sample record instead of parent disease report ID.
            IF @LabModuleSourceIndicator = 0
            BEGIN
                SET @SampleDiseaseReportID = @DiseaseReportID;
            END

            INSERT INTO @SuppressSelect
            EXECUTE dbo.USSP_GBL_SAMPLES_SET @AuditUserName,
                                             @DataAuditEventID,
                                             @EIDSSReportID,
                                             @SampleID OUTPUT,
                                             @SampleTypeID,
                                             @RootSampleID,
                                             @ParentSampleID,
                                             @FarmOwnerID,
                                             @SpeciesID,
                                             @AnimalID,
                                             NULL,
                                             @MonitoringSessionID,
                                             NULL,
                                             NULL,
                                             @SampleDiseaseReportID,
                                             @CollectionDate,
                                             @CollectedByPersonID,
                                             @CollectedByOrganizationID,
                                             @SentDate,
                                             @SentToOrganizationID,
                                             @EIDSSLocalOrFieldSampleID,
                                             @SiteID,
                                             @EnteredDate,
                                             @ReadOnlyIndicator,
                                             @SampleStatusTypeID,
                                             @Comments,
                                             @CurrentSiteID,
                                             @DiseaseID,
                                             @BirdStatusTypeID,
                                             @RowStatus,
                                             @RowAction;

            UPDATE @PensideTestsTemp
            SET SampleID = @SampleID
            WHERE SampleID = @RowID;

            UPDATE @LaboratoryTestsTemp
            SET SampleID = @SampleID
            WHERE SampleID = @RowID;

            DELETE FROM @SamplesTemp
            WHERE SampleID = @RowID;
        END;

        WHILE EXISTS (SELECT * FROM @PensideTestsTemp)
        BEGIN
            SELECT TOP 1
                @RowID = PensideTestID,
                @PensideTestID = PensideTestID,
                @SampleID = SampleID,
                @PensideTestResultTypeID = PensideTestResultTypeID,
                @PensideTestNameTypeID = PensideTestNameTypeID,
                @RowStatus = RowStatus,
                @TestedByPersonID = TestedByPersonID,
                @TestedByOrganizationID = TestedByOrganizationID,
                @DiseaseID = DiseaseID,
                @TestDate = TestDate,
                @PensideTestCategoryTypeID = PensideTestCategoryTypeID,
                @RowAction = RowAction
            FROM @PensideTestsTemp;

            INSERT INTO @SuppressSelect
            EXECUTE dbo.USSP_VET_PENSIDE_TESTS_SET @AuditUserName,
                                                   @DataAuditEventID,
                                                   @EIDSSReportID,
                                                   @PensideTestID OUTPUT,
                                                   @SampleID,
                                                   @PensideTestResultTypeID,
                                                   @PensideTestNameTypeID,
                                                   @TestedByPersonID,
                                                   @TestedByOrganizationID,
                                                   @DiseaseID,
                                                   @TestDate,
                                                   @PensideTestCategoryTypeID,
                                                   @RowStatus,
                                                   @RowAction;

            DELETE FROM @PensideTestsTemp
            WHERE PensideTestID = @RowID;
        END;

        WHILE EXISTS (SELECT * FROM @LaboratoryTestsTemp)
        BEGIN
            SELECT TOP 1
                @RowID = TestID,
                @TestID = TestID,
                @TestNameTypeID = TestNameTypeID,
                @TestCategoryTypeID = TestCategoryTypeID,
                @TestResultTypeID = TestResultTypeID,
                @TestStatusTypeID = TestStatusTypeID,
                @DiseaseID = DiseaseID,
                @SampleID = SampleID,
                @Comments = Comments,
                @RowStatus = RowStatus,
                @StartedDate = StartedDate,
                @ResultDate = ResultDate,
                @TestedByOrganizationID = TestedByOrganizationID,
                @TestedByPersonID = TestedByPersonID,
                @ResultEnteredByOrganizationID = ResultEnteredByOrganizationID,
                @ResultEnteredByPersonID = ResultEnteredByPersonID,
                @ValidatedByOrganizationID = ValidatedByOrganizationID,
                @ValidatedByPersonID = ValidatedByPersonID,
                @ReadOnlyIndicator = ReadOnlyIndicator,
                @NonLaboratoryTestIndicator = NonLaboratoryTestIndicator,
                @ExternalTestIndicator = ExternalTestIndicator,
                @PerformedByOrganizationID = PerformedByOrganizationID,
                @ReceivedDate = ReceivedDate,
                @ContactPersonName = ContactPersonName,
                @RowAction = RowAction
            FROM @LaboratoryTestsTemp;

            --If record is being soft-deleted, then check if the test record was originally created 
            --in the laboaratory module.  If it was, then disassociate the test record from the 
            --veterinary disease report, so that the test record remains in the laboratory module 
            --for further action.
            IF @RowStatus = 1
               AND @NonLaboratoryTestIndicator = 0
            BEGIN
                SET @RowStatus = 0;
                SET @TestDiseaseReportID = NULL;
            END
            ELSE
            BEGIN
                SET @TestDiseaseReportID = @DiseaseReportID;
            END;

            INSERT INTO @SuppressSelect
            EXECUTE dbo.USSP_GBL_TESTS_SET @TestID OUTPUT,
                                           @TestNameTypeID,
                                           @TestCategoryTypeID,
                                           @TestResultTypeID,
                                           @TestStatusTypeID,
                                           @DiseaseID,
                                           @SampleID,
                                           NULL,
                                           NULL,
                                           NULL,
                                           @Comments,
                                           @RowStatus,
                                           @StartedDate,
                                           @ResultDate,
                                           @TestedByOrganizationID,
                                           @TestedByPersonID,
                                           @ResultEnteredByOrganizationID,
                                           @ResultEnteredByPersonID,
                                           @ValidatedByOrganizationID,
                                           @ValidatedByPersonID,
                                           @ReadOnlyIndicator,
                                           @NonLaboratoryTestIndicator,
                                           @ExternalTestIndicator,
                                           @PerformedByOrganizationID,
                                           @ReceivedDate,
                                           @ContactPersonName,
                                           NULL,
                                           NULL,
                                           NULL,
                                           @TestDiseaseReportID,
                                           @AuditUserName,
                                           @DataAuditEventID,
                                           @EIDSSReportID,
                                           @RowAction;

            UPDATE @LaboratoryTestInterpretationsTemp
            SET TestID = @TestID
            WHERE TestID = @RowID;

            DELETE FROM @LaboratoryTestsTemp
            WHERE TestID = @RowID;
        END;

        WHILE EXISTS (SELECT * FROM @LaboratoryTestInterpretationsTemp)
        BEGIN
            SELECT TOP 1
                @RowID = TestInterpretationID,
                @TestInterpretationID = TestInterpretationID,
                @DiseaseID = DiseaseID,
                @InterpretedStatusTypeID = InterpretedStatusTypeID,
                @ValidatedByOrganizationID = ValidatedByOrganizationID,
                @ValidatedByPersonID = ValidatedByPersonID,
                @InterpretedByOrganizationID = InterpretedByOrganizationID,
                @InterpretedByPersonID = InterpretedByPersonID,
                @TestID = TestID,
                @ValidatedStatusIndicator = ValidatedStatusIndicator,
                @ReportSessionCreatedIndicator = ReportSessionCreatedIndicator,
                @ValidatedComment = ValidatedComment,
                @InterpretedComment = InterpretedComment,
                @ValidatedDate = ValidatedDate,
                @InterpretedDate = InterpretedDate,
                @RowStatus = RowStatus,
                @ReadOnlyIndicator = ReadOnlyIndicator,
                @RowAction = RowAction
            FROM @LaboratoryTestInterpretationsTemp;

            INSERT INTO @SuppressSelect
            EXECUTE dbo.USSP_GBL_TEST_INTERPRETATIONS_SET @AuditUserName,
                                                          @DataAuditEventID,
                                                          @EIDSSReportID, 
                                                          @TestInterpretationID OUTPUT,
                                                          @DiseaseID,
                                                          @InterpretedStatusTypeID,
                                                          @ValidatedByOrganizationID,
                                                          @ValidatedByPersonID,
                                                          @InterpretedByOrganizationID,
                                                          @InterpretedByPersonID,
                                                          @TestID,
                                                          @ValidatedStatusIndicator,
                                                          @ReportSessionCreatedIndicator,
                                                          @ValidatedComment,
                                                          @InterpretedComment,
                                                          @ValidatedDate,
                                                          @InterpretedDate,
                                                          @RowStatus,
                                                          @ReadOnlyIndicator,
                                                          @RowAction;

            IF @ReportSessionCreatedIndicator = 1 AND @RowAction = 1
            BEGIN
                SET @ConnectedDiseaseReportLaboratoryTestID = @TestID;
            END

            DELETE FROM @LaboratoryTestInterpretationsTemp
            WHERE TestInterpretationID = @RowID;
        END;

        WHILE EXISTS (SELECT * FROM @CaseLogsTemp)
        BEGIN
            SELECT TOP 1
                @RowID = CaseLogID,
                @CaseLogID = CaseLogID,
                @LogStatusTypeID = LogStatusTypeID,
                @LoggedByPersonID = LoggedByPersonID,
                @LogDate = LogDate,
                @ActionRequired = ActionRequired,
                @Comments = Comments,
                @RowStatus = RowStatus,
                @RowAction = RowAction
            FROM @CaseLogsTemp;

            INSERT INTO @SuppressSelect
            EXECUTE dbo.USSP_VET_DISEASE_REPORT_LOG_SET @AuditUserName,
                                                        @DataAuditEventID,
                                                        @EIDSSReportID,
                                                        @CaseLogID,
                                                        @LogStatusTypeID,
                                                        @DiseaseReportID,
                                                        @LoggedByPersonID,
                                                        @LogDate,
                                                        @ActionRequired,
                                                        @Comments,
                                                        @RowStatus,
                                                        @RowAction;

            DELETE FROM @CaseLogsTemp
            WHERE CaseLogID = @RowID;
        END;

        IF @CaseMonitorings IS NOT NULL
        BEGIN
            EXEC dbo.USSP_OMM_CASE_MONITORING_SET @CaseMonitorings = @CaseMonitorings,
                                                  @VeterinaryDiseaseReportID = @DiseaseReportID,
                                                  @User = @AuditUserName;
        END

        WHILE EXISTS (SELECT * FROM @EventsTemp)
        BEGIN
            SELECT TOP 1
                @EventId = EventId,
                @EventTypeId = EventTypeId,
                @EventUserId = UserId,
                @EventObjectId = ObjectId,
                @EventSiteId = SiteId,
                @EventDiseaseId = DiseaseId,
                @EventLocationId = LocationId,
                @EventInformationString = InformationString,
                @EventNote = Note,
                @EventLoginSiteId = LoginSiteId
            FROM @EventsTemp;

            INSERT INTO @SuppressSelect
            EXECUTE dbo.USSP_ADMIN_EVENT_SET @EventId,
                                             @EventTypeId,
                                             @EventUserId,
                                             @EventObjectId,
                                             @EventDiseaseId,
                                             @EventSiteId,
                                             @EventInformationString,
                                             @EventLoginSiteId,
                                             @EventLocationId,
                                             @AuditUserName,
                                             @DataAuditEventID,
                                             @EIDSSReportID;

            DELETE FROM @EventsTemp
            WHERE EventId = @EventId;
        END;

        IF @@TRANCOUNT > 0
            COMMIT TRANSACTION;

        SELECT @ReturnCode ReturnCode,
               @ReturnMessage ReturnMessage,
               @DiseaseReportID DiseaseReportID,
               @EIDSSReportID EIDSSReportID,
               @OutbreakCaseReportUID CaseID,
               @EIDSSCaseID EIDSSCaseID, 
               @ConnectedDiseaseReportLaboratoryTestID ConnectedDiseaseReportLaboratoryTestID;
    END TRY
    BEGIN CATCH
        IF @@Trancount > 0
            ROLLBACK TRANSACTION;

        THROW;
    END CATCH
END
GO
PRINT N'Altering Procedure [dbo].[USP_VET_FARM_MASTER_GETList]...';


GO
-- ================================================================================================
-- Name: USP_VET_FARM_MASTER_GETList
--
-- Description:	Get farm actual list for farm search and other use cases.
--                      
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Stephen Long     04/05/2019 Initial release.
-- Stephen Long     04/27/2019 Correction to where clause; added row status check.
-- Stephen Long     05/22/2019 Added additional farm address fields to the select.
-- Stephen Long     06/22/2019 Fix to the farm address logic (building, apartment, house IIF's 
--                             to case statements).
-- Stephen Long     07/18/2019 Added check for farms marked as both avian and livestock to return 
--                             when avian or livestock are sent in as criteria.
-- Ann Xiong        10/17/2019 Added one additional field and modified one field to the select, 
--                             added a parameter @EIDSSFarmOwnerID NVARCHAR(100) = NULL.
-- Mandar Kulkarni  06/18/2020 Since the data for idfsCategory in 6.1 is not populated, added code 
--                             to determine farm type based on intHACode.
-- Stephen Long     07/06/2020 Added leading wildcard character on like criteria.
-- Stephen Long     08/03/2020 Added EIDSS legacy ID to the parameters and where criteria.
-- Stephen Long     09/16/2020 Changed default sort order to descending.
-- Stephen Long     10/12/2020 Added elevation to the query.
-- Stephen Long     12/23/2020 Corrected where criteria for farm type when both avian and 
--                             livestock.
-- Stephen Long     01/25/2021 Added order by parameter to handle when a user selected a specific 
--                             column to sort by.
-- Stephen Long     01/27/2021 Fix for order by; alias will not work on order by with case.
-- Mike Kornegay	02/17/2022 Changed paging to match standard CTE paging structure and added various
--							   sorting options.
-- Mike Kornegay	02/18/2022 Improvement recommendations from Mandar Kulkarni - remove left join 
--							   to gisSettlement and replace with sub query.
-- Mike Kornegay	03/10/2022 Added subquery to get the FarmId from tlbFarm if it exists.
-- Michael Brown    03/27/2022 Added parameter @FarmTypesName to filter based on the actual FarmTypeID 
--							   of the farm (LiceStock, Avian, or All (both). The assumption is that we 
--							   we will only get the values 10040007, 10040003, or 10040001.
-- Michael Brown    03/30/2022 Had to change SP because a NULL value could be passed for the 
--							   FarmTypeID. Also the @FarmName, @FarmOwnerFirstName, and 
--							   @FarmOwnerLastName were changed to NULL as opposed to '' empty strings.
-- Stephen Long     05/11/2022 Corrected farm type ID and to use translated value.  Set farm ID 
--                             to null instead of sub-query; field no longer needed.
-- Stephen Long     09/22/2022 Add check for "0" page size.  If "0", then set to 1.  Removed farm 
--                             ID field.
-- Stephen Long     10/10/2022 Added monitoring session ID parameter and where criteria.
-- Stephen Long     05/11/2023 Added record identifier search indicator logic.
-- ================================================================================================
ALTER PROCEDURE [dbo].[USP_VET_FARM_MASTER_GETList]
(
    @LanguageID NVARCHAR(20),
    @FarmMasterID BIGINT = NULL,
    @EIDSSFarmID NVARCHAR(200) = NULL,
    @LegacyFarmID NVARCHAR(200) = NULL,
    @FarmTypeID BIGINT = NULL,
    @FarmName NVARCHAR(200) = NULL,
    @FarmOwnerFirstName NVARCHAR(200) = NULL,
    @FarmOwnerLastName NVARCHAR(200) = NULL,
    @EIDSSPersonID NVARCHAR(100) = NULL,
    @EIDSSFarmOwnerID NVARCHAR(100) = NULL,
    @FarmOwnerID BIGINT = NULL,
    @idfsLocation BIGINT = NULL,
    @SettlementTypeID BIGINT = NULL,
    @MonitoringSessionID BIGINT = NULL,
    @RecordIdentifierSearchIndicator BIT = 0,
    @sortColumn NVARCHAR(100) = 'EIDSSFarmID',
    @sortOrder NVARCHAR(4) = 'DESC',
    @pageNo INT = 1,
    @pageSize INT = 10
)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        DECLARE @FarmTypesName NVARCHAR(200) = NULL;
        DECLARE @ReturnMessage VARCHAR(MAX) = 'SUCCESS';
        DECLARE @ReturnCode BIGINT = 0;
        DECLARE @FarmTypes TABLE
        (
            FarmTypeID BIGINT,
            FarmTypeName NVARCHAR(200)
        );

        -- 06/18/2020 - Based on the parameter value passed farm type field, set the intHACode value to look for in v6.1 data
        DECLARE @AccessoryCode INT,
                @LanguageCode BIGINT = dbo.FN_GBL_LanguageCode_Get(@LanguageID);
        DECLARE @firstRec INT;
        DECLARE @lastRec INT;

        IF @PageSize = 0
        BEGIN
            SET @PageSize = 1;
        END

        SET @firstRec = (@pageNo - 1) * @pagesize;
        SET @lastRec = (@pageNo * @pageSize + 1);

        INSERT INTO @FarmTypes
        SELECT snt.idfsBaseReference,
               snt.strTextString
        FROM dbo.trtStringNameTranslation snt
            INNER JOIN dbo.trtBaseReference br
                ON br.idfsBaseReference = snt.idfsBaseReference
        WHERE idfsReferenceType = 19000040
              AND idfsLanguage = @LanguageCode
              AND br.intRowStatus = 0;

        IF @FarmTypeID = 10040007 -- Livestock
        BEGIN
            SET @AccessoryCode = 32;
            SET @FarmTypesName =
            (
                SELECT FarmTypeName FROM @FarmTypes WHERE FarmTypeID = 10040007
            );
        END;
        ELSE IF @FarmTypeID = 10040003 -- Avian
        BEGIN
            SET @AccessoryCode = 64;
            SET @FarmTypesName =
            (
                SELECT FarmTypeName FROM @FarmTypes WHERE FarmTypeID = 10040003
            );
        END;
        ELSE IF @FarmTypeID = 10040001 -- All (both)
        BEGIN
            SET @AccessoryCode = NULL;
            --SET @FarmTypeID = NULL;	
            SET @FarmTypesName =
            (
                SELECT FarmTypeName FROM @FarmTypes WHERE FarmTypeID = 10040001
            );
        END;
        ELSE
        BEGIN
            SET @AccessoryCode = NULL;
            SET @FarmTypeID = NULL;
            SET @FarmTypesName = '';
        END;

        IF @RecordIdentifierSearchIndicator = 1
        BEGIN
            ;WITH CTEIntermediate
             AS (SELECT fa.idfFarmActual AS FarmMasterID,

                        -- 06/18/2020 - Made changes to look for intHACode if idfsCategory column is not populated for v6.1 data.
                        --			fa.idfsFarmCategory AS FarmTypeID,
                        --			farmType.name AS FarmTypeName,
                        (CASE
                             WHEN idfsFarmCategory = 10040007
                                  OR (
                                         fa.intHACode = 32
                                         AND fa.idfsFarmCategory IS NULL
                                     ) THEN
                                 10040007
                             WHEN idfsFarmCategory = 10040003
                                  OR (
                                         fa.intHACode = 64
                                         AND fa.idfsFarmCategory IS NULL
                                     ) THEN
                                 10040003
                             ELSE
                                 10040001
                         END
                        ) AS FarmTypeID,
                        (CASE
                             WHEN idfsFarmCategory = 10040007
                                  OR (
                                         fa.intHACode = 32
                                         AND fa.idfsFarmCategory IS NULL
                                     ) THEN
                             (
                                 SELECT FarmTypeName FROM @FarmTypes WHERE FarmTypeID = 10040007
                             )
                             WHEN idfsFarmCategory = 10040003
                                  OR (
                                         fa.intHACode = 64
                                         AND fa.idfsFarmCategory IS NULL
                                     ) THEN
                             (
                                 SELECT FarmTypeName FROM @FarmTypes WHERE FarmTypeID = 10040003
                             )
                             ELSE
                         (
                             SELECT FarmTypeName FROM @FarmTypes WHERE FarmTypeID = 10040001
                         )
                         END
                        ) AS FarmTypeName,
                        fa.idfHumanActual AS FarmOwnerID,
                        fa.idfFarmAddress AS FarmAddressID,
                        fa.strNationalName AS FarmName,
                        fa.strFarmCode AS EIDSSFarmID,
                        fa.strFax AS Fax,
                        fa.strEmail AS Email,
                        fa.strContactPhone AS Phone,
                        fa.intLivestockTotalAnimalQty AS TotalLivestockAnimalQuantity,
                        fa.intAvianTotalAnimalQty AS TotalAvianAnimalQuantity,
                        fa.intLivestockSickAnimalQty AS SickLivestockAnimalQuantity,
                        fa.intAvianSickAnimalQty AS SickAvianAnimalQuantity,
                        fa.intLivestockDeadAnimalQty AS DeadLivestockAnimalQuantity,
                        fa.intAvianDeadAnimalQty AS DeadAvianAnimalQuantity,
                        fa.intRowStatus AS RowStatus,
                        lh.AdminLevel1ID AS CountryID,
                        lh.AdminLevel2ID AS RegionID,
                        lh.AdminLevel2Name AS RegionName,
                        lh.AdminLevel3ID AS RayonID,
                        lh.AdminLevel3Name AS RayonName,
                        settlement.idfsLocation AS SettlementID,
                        settlementName.name AS SettlementName,
                        gls.strApartment AS Apartment,
                        gls.strBuilding AS Building,
                        gls.strHouse AS House,
                        gls.strPostCode AS PostalCode,
                        gls.strStreetName AS Street,
                        gls.dblLatitude AS Latitude,
                        gls.dblLongitude AS Longitude,
                        gls.dblElevation AS Elevation,
                        ha.strPersonID AS EIDSSFarmOwnerID,
                        haai.EIDSSPersonID,
                        (CASE
                             WHEN ha.strFirstName IS NULL THEN
                                 ''
                             WHEN ha.strFirstName = '' THEN
                                 ''
                             ELSE
                                 ha.strFirstName
                         END + CASE
                                   WHEN ha.strSecondName IS NULL THEN
                                       ''
                                   WHEN ha.strSecondName = '' THEN
                                       ''
                                   ELSE
                                       ' ' + ha.strSecondName
                               END + CASE
                                         WHEN ha.strLastName IS NULL THEN
                                             ''
                                         WHEN ha.strLastName = '' THEN
                                             ''
                                         ELSE
                                             ' ' + ha.strLastName
                                     END
                        ) AS FarmOwnerName,
                        ha.strFirstName AS FarmOwnerFirstName,
                        ha.strLastName AS FarmOwnerLastName,
                        ha.strSecondName AS FarmOwnerSecondName
                 FROM dbo.tlbFarmActual fa
                     LEFT JOIN dbo.tlbHumanActual ha
                         ON ha.idfHumanActual = fa.idfHumanActual
                     LEFT JOIN dbo.HumanActualAddlInfo haai
                         ON haai.HumanActualAddlInfoUID = ha.idfHumanActual
                     LEFT JOIN dbo.tlbGeoLocationShared gls
                         ON gls.idfGeoLocationShared = fa.idfFarmAddress
                            AND gls.intRowStatus = 0
                     INNER JOIN dbo.FN_GBL_LocationHierarchy_Flattened(@LanguageID) lh
                         ON lh.idfsLocation = gls.idfsLocation
                     LEFT JOIN dbo.gisLocation settlement
                         ON settlement.idfsLocation = gls.idfsLocation
                            AND settlement.idfsType IS NOT NULL
                     LEFT JOIN dbo.FN_GBL_GIS_ReferenceRepair_GET(@LanguageID, 19000004) settlementName
                         ON settlementName.idfsReference = settlement.idfsLocation
                 WHERE fa.intRowStatus = 0
                       AND (
                               fa.strFarmCode LIKE '%' + TRIM(@EIDSSFarmID) + '%'
                               OR @EIDSSFarmID IS NULL
                           )
                       AND (
                               (
                                   fa.strFarmCode LIKE '%' + TRIM(@LegacyFarmID) + '%'
                                   AND fa.SourceSystemNameID = 10519002
                               ) --EIDSS version 6.1 record source (migrated record)
                               OR @LegacyFarmID IS NULL
                           )
                ),
                  CTEResults
             AS (SELECT ROW_NUMBER() OVER (ORDER BY CASE
                                                        WHEN @sortColumn = 'FarmMasterID'
                                                             AND @SortOrder = 'asc' THEN
                                                            FarmMasterID
                                                    END ASC,
                                                    CASE
                                                        WHEN @sortColumn = 'FarmMasterID'
                                                             AND @SortOrder = 'desc' THEN
                                                            FarmMasterID
                                                    END DESC,
                                                    CASE
                                                        WHEN @sortColumn = 'FarmTypeID'
                                                             AND @SortOrder = 'asc' THEN
                                                            FarmTypeID
                                                    END ASC,
                                                    CASE
                                                        WHEN @sortColumn = 'FarmTypeID'
                                                             AND @SortOrder = 'desc' THEN
                                                            FarmTypeID
                                                    END DESC,
                                                    CASE
                                                        WHEN @sortColumn = 'FarmTypeName'
                                                             AND @SortOrder = 'asc' THEN
                                                            FarmTypeName
                                                    END ASC,
                                                    CASE
                                                        WHEN @sortColumn = 'FarmTypeName'
                                                             AND @SortOrder = 'desc' THEN
                                                            FarmTypeName
                                                    END DESC,
                                                    CASE
                                                        WHEN @sortColumn = 'FarmOwnerID'
                                                             AND @SortOrder = 'asc' THEN
                                                            FarmOwnerID
                                                    END ASC,
                                                    CASE
                                                        WHEN @sortColumn = 'FarmOwnerID'
                                                             AND @SortOrder = 'desc' THEN
                                                            FarmOwnerID
                                                    END DESC,
                                                    CASE
                                                        WHEN @sortColumn = 'FarmAddressID'
                                                             AND @SortOrder = 'asc' THEN
                                                            FarmAddressID
                                                    END ASC,
                                                    CASE
                                                        WHEN @sortColumn = 'FarmAddressID'
                                                             AND @SortOrder = 'desc' THEN
                                                            FarmAddressID
                                                    END DESC,
                                                    CASE
                                                        WHEN @sortColumn = 'FarmName'
                                                             AND @SortOrder = 'asc' THEN
                                                            FarmName
                                                    END ASC,
                                                    CASE
                                                        WHEN @sortColumn = 'FarmName'
                                                             AND @SortOrder = 'desc' THEN
                                                            FarmName
                                                    END DESC,
                                                    CASE
                                                        WHEN @sortColumn = 'EIDSSFarmID'
                                                             AND @SortOrder = 'asc' THEN
                                                            EIDSSFarmID
                                                    END ASC,
                                                    CASE
                                                        WHEN @sortColumn = 'EIDSSFarmID'
                                                             AND @SortOrder = 'desc' THEN
                                                            EIDSSFarmID
                                                    END DESC,
                                                    CASE
                                                        WHEN @sortColumn = 'Fax'
                                                             AND @SortOrder = 'asc' THEN
                                                            Fax
                                                    END ASC,
                                                    CASE
                                                        WHEN @sortColumn = 'Fax'
                                                             AND @SortOrder = 'desc' THEN
                                                            Fax
                                                    END DESC,
                                                    CASE
                                                        WHEN @sortColumn = 'Email'
                                                             AND @SortOrder = 'asc' THEN
                                                            Email
                                                    END ASC,
                                                    CASE
                                                        WHEN @sortColumn = 'Email'
                                                             AND @SortOrder = 'desc' THEN
                                                            Email
                                                    END DESC,
                                                    CASE
                                                        WHEN @sortColumn = 'Phone'
                                                             AND @SortOrder = 'asc' THEN
                                                            Phone
                                                    END ASC,
                                                    CASE
                                                        WHEN @sortColumn = 'Phone'
                                                             AND @SortOrder = 'desc' THEN
                                                            Phone
                                                    END DESC,
                                                    CASE
                                                        WHEN @sortColumn = 'TotalLivestockAnimalQuantity'
                                                             AND @SortOrder = 'asc' THEN
                                                            TotalLivestockAnimalQuantity
                                                    END ASC,
                                                    CASE
                                                        WHEN @sortColumn = 'TotalLivestockAnimalQuantity'
                                                             AND @SortOrder = 'desc' THEN
                                                            TotalLivestockAnimalQuantity
                                                    END DESC,
                                                    CASE
                                                        WHEN @sortColumn = 'TotalAvianAnimalQuantity'
                                                             AND @SortOrder = 'asc' THEN
                                                            TotalAvianAnimalQuantity
                                                    END ASC,
                                                    CASE
                                                        WHEN @sortColumn = 'TotalAvianAnimalQuantity'
                                                             AND @SortOrder = 'desc' THEN
                                                            TotalAvianAnimalQuantity
                                                    END DESC,
                                                    CASE
                                                        WHEN @sortColumn = 'SickLivestockAnimalQuantity'
                                                             AND @SortOrder = 'asc' THEN
                                                            SickLivestockAnimalQuantity
                                                    END ASC,
                                                    CASE
                                                        WHEN @sortColumn = 'SickLivestockAnimalQuantity'
                                                             AND @SortOrder = 'desc' THEN
                                                            SickLivestockAnimalQuantity
                                                    END DESC,
                                                    CASE
                                                        WHEN @sortColumn = 'SickAvianAnimalQuantity'
                                                             AND @SortOrder = 'asc' THEN
                                                            SickAvianAnimalQuantity
                                                    END ASC,
                                                    CASE
                                                        WHEN @sortColumn = 'SickAvianAnimalQuantity'
                                                             AND @SortOrder = 'desc' THEN
                                                            SickAvianAnimalQuantity
                                                    END DESC,
                                                    CASE
                                                        WHEN @sortColumn = 'DeadLivestockAnimalQuantity'
                                                             AND @SortOrder = 'asc' THEN
                                                            DeadLivestockAnimalQuantity
                                                    END ASC,
                                                    CASE
                                                        WHEN @sortColumn = 'DeadLivestockAnimalQuantity'
                                                             AND @SortOrder = 'desc' THEN
                                                            DeadLivestockAnimalQuantity
                                                    END DESC,
                                                    CASE
                                                        WHEN @sortColumn = 'DeadAvianAnimalQuantity'
                                                             AND @SortOrder = 'asc' THEN
                                                            DeadAvianAnimalQuantity
                                                    END ASC,
                                                    CASE
                                                        WHEN @sortColumn = 'DeadAvianAnimalQuantity'
                                                             AND @SortOrder = 'desc' THEN
                                                            DeadAvianAnimalQuantity
                                                    END DESC,
                                                    CASE
                                                        WHEN @sortColumn = 'RowStatus'
                                                             AND @SortOrder = 'asc' THEN
                                                            RowStatus
                                                    END ASC,
                                                    CASE
                                                        WHEN @sortColumn = 'RowStatus'
                                                             AND @SortOrder = 'desc' THEN
                                                            RowStatus
                                                    END DESC,
                                                    CASE
                                                        WHEN @sortColumn = 'CountryID'
                                                             AND @SortOrder = 'asc' THEN
                                                            CountryID
                                                    END ASC,
                                                    CASE
                                                        WHEN @sortColumn = 'CountryID'
                                                             AND @SortOrder = 'desc' THEN
                                                            CountryID
                                                    END DESC,
                                                    CASE
                                                        WHEN @sortColumn = 'RegionID'
                                                             AND @SortOrder = 'asc' THEN
                                                            RegionID
                                                    END ASC,
                                                    CASE
                                                        WHEN @sortColumn = 'RegionID'
                                                             AND @SortOrder = 'desc' THEN
                                                            RegionID
                                                    END DESC,
                                                    CASE
                                                        WHEN @sortColumn = 'RegionName'
                                                             AND @SortOrder = 'asc' THEN
                                                            RegionName
                                                    END ASC,
                                                    CASE
                                                        WHEN @sortColumn = 'RegionName'
                                                             AND @SortOrder = 'desc' THEN
                                                            RegionName
                                                    END DESC,
                                                    CASE
                                                        WHEN @sortColumn = 'RayonName'
                                                             AND @SortOrder = 'asc' THEN
                                                            RayonName
                                                    END ASC,
                                                    CASE
                                                        WHEN @sortColumn = 'RayonName'
                                                             AND @SortOrder = 'desc' THEN
                                                            RayonName
                                                    END DESC,
                                                    CASE
                                                        WHEN @sortColumn = 'SettlementID'
                                                             AND @SortOrder = 'asc' THEN
                                                            SettlementID
                                                    END ASC,
                                                    CASE
                                                        WHEN @sortColumn = 'SettlementID'
                                                             AND @SortOrder = 'desc' THEN
                                                            SettlementID
                                                    END DESC,
                                                    CASE
                                                        WHEN @sortColumn = 'SettlementName'
                                                             AND @SortOrder = 'asc' THEN
                                                            SettlementName
                                                    END ASC,
                                                    CASE
                                                        WHEN @sortColumn = 'SettlementName'
                                                             AND @SortOrder = 'desc' THEN
                                                            SettlementName
                                                    END DESC,
                                                    CASE
                                                        WHEN @sortColumn = 'Apartment'
                                                             AND @SortOrder = 'asc' THEN
                                                            Apartment
                                                    END ASC,
                                                    CASE
                                                        WHEN @sortColumn = 'Apartment'
                                                             AND @SortOrder = 'desc' THEN
                                                            Apartment
                                                    END DESC,
                                                    CASE
                                                        WHEN @sortColumn = 'Building'
                                                             AND @SortOrder = 'asc' THEN
                                                            Building
                                                    END ASC,
                                                    CASE
                                                        WHEN @sortColumn = 'Building'
                                                             AND @SortOrder = 'desc' THEN
                                                            Building
                                                    END DESC,
                                                    CASE
                                                        WHEN @sortColumn = 'House'
                                                             AND @SortOrder = 'asc' THEN
                                                            House
                                                    END ASC,
                                                    CASE
                                                        WHEN @sortColumn = 'House'
                                                             AND @SortOrder = 'desc' THEN
                                                            House
                                                    END DESC,
                                                    CASE
                                                        WHEN @sortColumn = 'PostalCode'
                                                             AND @SortOrder = 'asc' THEN
                                                            PostalCode
                                                    END ASC,
                                                    CASE
                                                        WHEN @sortColumn = 'PostalCode'
                                                             AND @SortOrder = 'desc' THEN
                                                            PostalCode
                                                    END DESC,
                                                    CASE
                                                        WHEN @sortColumn = 'Street'
                                                             AND @SortOrder = 'asc' THEN
                                                            Street
                                                    END ASC,
                                                    CASE
                                                        WHEN @sortColumn = 'Street'
                                                             AND @SortOrder = 'desc' THEN
                                                            Street
                                                    END DESC,
                                                    CASE
                                                        WHEN @sortColumn = 'Latitude'
                                                             AND @SortOrder = 'asc' THEN
                                                            Latitude
                                                    END ASC,
                                                    CASE
                                                        WHEN @sortColumn = 'Latitude'
                                                             AND @SortOrder = 'desc' THEN
                                                            Latitude
                                                    END DESC,
                                                    CASE
                                                        WHEN @sortColumn = 'Longitude'
                                                             AND @SortOrder = 'asc' THEN
                                                            Longitude
                                                    END ASC,
                                                    CASE
                                                        WHEN @sortColumn = 'Longitude'
                                                             AND @SortOrder = 'desc' THEN
                                                            Longitude
                                                    END DESC,
                                                    CASE
                                                        WHEN @sortColumn = 'EIDSSPersonID'
                                                             AND @SortOrder = 'asc' THEN
                                                            EIDSSPersonID
                                                    END ASC,
                                                    CASE
                                                        WHEN @sortColumn = 'EIDSSPersonID'
                                                             AND @SortOrder = 'desc' THEN
                                                            EIDSSPersonID
                                                    END DESC,
                                                    CASE
                                                        WHEN @sortColumn = 'EIDSSFarmOwnerID'
                                                             AND @SortOrder = 'asc' THEN
                                                            EIDSSFarmOwnerID
                                                    END ASC,
                                                    CASE
                                                        WHEN @sortColumn = 'EIDSSFarmOwnerID'
                                                             AND @SortOrder = 'desc' THEN
                                                            EIDSSFarmOwnerID
                                                    END DESC,
                                                    CASE
                                                        WHEN @sortColumn = 'FarmOwnerName'
                                                             AND @SortOrder = 'asc' THEN
                                                            FarmOwnerID
                                                    END ASC,
                                                    CASE
                                                        WHEN @sortColumn = 'FarmOwnerName'
                                                             AND @SortOrder = 'desc' THEN
                                                            FarmOwnerID
                                                    END DESC,
                                                    CASE
                                                        WHEN @sortColumn = 'FarmOwnerFirstName'
                                                             AND @SortOrder = 'asc' THEN
                                                            FarmOwnerFirstName
                                                    END ASC,
                                                    CASE
                                                        WHEN @sortColumn = 'FarmOwnerFirstName'
                                                             AND @SortOrder = 'desc' THEN
                                                            FarmOwnerFirstName
                                                    END DESC,
                                                    CASE
                                                        WHEN @sortColumn = 'FarmOwnerLastName'
                                                             AND @SortOrder = 'asc' THEN
                                                            FarmOwnerLastName
                                                    END ASC,
                                                    CASE
                                                        WHEN @sortColumn = 'FarmOwnerLastName'
                                                             AND @SortOrder = 'desc' THEN
                                                            FarmOwnerLastName
                                                    END DESC,
                                                    CASE
                                                        WHEN @sortColumn = 'FarmOwnerSecondName'
                                                             AND @SortOrder = 'asc' THEN
                                                            FarmOwnerSecondName
                                                    END ASC,
                                                    CASE
                                                        WHEN @sortColumn = 'FarmOwnerSecondName'
                                                             AND @SortOrder = 'desc' THEN
                                                            FarmOwnerSecondName
                                                    END DESC
                                          ) AS ROWNUM,
                        COUNT(*) OVER () AS RecordCount,
                        FarmMasterID,
                        FarmTypeID,
                        FarmTypeName,
                        FarmOwnerID,
                        FarmAddressID,
                        FarmName,
                        EIDSSFarmID,
                        Fax,
                        Email,
                        Phone,
                        TotalLivestockAnimalQuantity,
                        TotalAvianAnimalQuantity,
                        SickLivestockAnimalQuantity,
                        SickAvianAnimalQuantity,
                        DeadLivestockAnimalQuantity,
                        DeadAvianAnimalQuantity,
                        RowStatus,
                        CountryID,
                        RegionID,
                        RegionName,
                        RayonID,
                        RayonName,
                        SettlementID,
                        SettlementName,
                        Apartment,
                        Building,
                        House,
                        PostalCode,
                        Street,
                        Latitude,
                        Longitude,
                        Elevation,
                        EIDSSPersonID,
                        EIDSSFarmOwnerID,
                        FarmOwnerName,
                        FarmOwnerFirstName,
                        FarmOwnerLastName,
                        FarmOwnerSecondName
                 FROM CTEIntermediate
                )
            SELECT RecordCount,
                   FarmMasterID,
                   FarmTypeID,
                   FarmTypeName,
                   FarmOwnerID,
                   FarmAddressID,
                   FarmName,
                   EIDSSFarmID,
                   Fax,
                   Email,
                   Phone,
                   TotalLivestockAnimalQuantity,
                   TotalAvianAnimalQuantity,
                   SickLivestockAnimalQuantity,
                   SickAvianAnimalQuantity,
                   DeadLivestockAnimalQuantity,
                   DeadAvianAnimalQuantity,
                   RowStatus,
                   CountryID,
                   RegionID,
                   RegionName,
                   RayonID,
                   RayonName,
                   SettlementID,
                   SettlementName,
                   Apartment,
                   Building,
                   House,
                   PostalCode,
                   Street,
                   Latitude,
                   Longitude,
                   Elevation,
                   EIDSSPersonID,
                   EIDSSFarmOwnerID,
                   FarmOwnerName,
                   FarmOwnerFirstName,
                   FarmOwnerLastName,
                   FarmOwnerSecondName,
                   TotalPages = (RecordCount / @pageSize) + IIF(RecordCount % @pageSize > 0, 1, 0),
                   CurrentPage = @pageNo
            FROM CTEResults
            WHERE RowNum > @firstRec
                  AND RowNum < @lastRec;
        END
        ELSE
        BEGIN
                DECLARE @LocationNode HIERARCHYID = (
                                                SELECT node FROM dbo.gisLocation WHERE idfsLocation = @idfsLocation
                                            );

            ;WITH CTEIntermediate
             AS (SELECT fa.idfFarmActual AS FarmMasterID,

                        -- 06/18/2020 - Made changes to look for intHACode if idfsCategory column is not populated for v6.1 data.
                        --			fa.idfsFarmCategory AS FarmTypeID,
                        --			farmType.name AS FarmTypeName,
                        (CASE
                             WHEN idfsFarmCategory = 10040007
                                  OR (
                                         fa.intHACode = 32
                                         AND fa.idfsFarmCategory IS NULL
                                     ) THEN
                                 10040007
                             WHEN idfsFarmCategory = 10040003
                                  OR (
                                         fa.intHACode = 64
                                         AND fa.idfsFarmCategory IS NULL
                                     ) THEN
                                 10040003
                             ELSE
                                 10040001
                         END
                        ) AS FarmTypeID,
                        (CASE
                             WHEN idfsFarmCategory = 10040007
                                  OR (
                                         fa.intHACode = 32
                                         AND fa.idfsFarmCategory IS NULL
                                     ) THEN
                             (
                                 SELECT FarmTypeName FROM @FarmTypes WHERE FarmTypeID = 10040007
                             )
                             WHEN idfsFarmCategory = 10040003
                                  OR (
                                         fa.intHACode = 64
                                         AND fa.idfsFarmCategory IS NULL
                                     ) THEN
                             (
                                 SELECT FarmTypeName FROM @FarmTypes WHERE FarmTypeID = 10040003
                             )
                             ELSE
                         (
                             SELECT FarmTypeName FROM @FarmTypes WHERE FarmTypeID = 10040001
                         )
                         END
                        ) AS FarmTypeName,
                        fa.idfHumanActual AS FarmOwnerID,
                        fa.idfFarmAddress AS FarmAddressID,
                        fa.strNationalName AS FarmName,
                        fa.strFarmCode AS EIDSSFarmID,
                        fa.strFax AS Fax,
                        fa.strEmail AS Email,
                        fa.strContactPhone AS Phone,
                        fa.intLivestockTotalAnimalQty AS TotalLivestockAnimalQuantity,
                        fa.intAvianTotalAnimalQty AS TotalAvianAnimalQuantity,
                        fa.intLivestockSickAnimalQty AS SickLivestockAnimalQuantity,
                        fa.intAvianSickAnimalQty AS SickAvianAnimalQuantity,
                        fa.intLivestockDeadAnimalQty AS DeadLivestockAnimalQuantity,
                        fa.intAvianDeadAnimalQty AS DeadAvianAnimalQuantity,
                        fa.intRowStatus AS RowStatus,
                        lh.AdminLevel1ID AS CountryID,
                        lh.AdminLevel2ID AS RegionID,
                        lh.AdminLevel2Name AS RegionName,
                        lh.AdminLevel3ID AS RayonID,
                        lh.AdminLevel3Name AS RayonName,
                        settlement.idfsLocation AS SettlementID,
                        settlementName.name AS SettlementName,
                        gls.strApartment AS Apartment,
                        gls.strBuilding AS Building,
                        gls.strHouse AS House,
                        gls.strPostCode AS PostalCode,
                        gls.strStreetName AS Street,
                        gls.dblLatitude AS Latitude,
                        gls.dblLongitude AS Longitude,
                        gls.dblElevation AS Elevation,
                        ha.strPersonID AS EIDSSFarmOwnerID,
                        haai.EIDSSPersonID,
                        (CASE
                             WHEN ha.strFirstName IS NULL THEN
                                 ''
                             WHEN ha.strFirstName = '' THEN
                                 ''
                             ELSE
                                 ha.strFirstName
                         END + CASE
                                   WHEN ha.strSecondName IS NULL THEN
                                       ''
                                   WHEN ha.strSecondName = '' THEN
                                       ''
                                   ELSE
                                       ' ' + ha.strSecondName
                               END + CASE
                                         WHEN ha.strLastName IS NULL THEN
                                             ''
                                         WHEN ha.strLastName = '' THEN
                                             ''
                                         ELSE
                                             ' ' + ha.strLastName
                                     END
                        ) AS FarmOwnerName,
                        ha.strFirstName AS FarmOwnerFirstName,
                        ha.strLastName AS FarmOwnerLastName,
                        ha.strSecondName AS FarmOwnerSecondName
                 FROM dbo.tlbFarmActual fa
                     LEFT JOIN dbo.tlbHumanActual ha
                         ON ha.idfHumanActual = fa.idfHumanActual
                     LEFT JOIN dbo.HumanActualAddlInfo haai
                         ON haai.HumanActualAddlInfoUID = ha.idfHumanActual
                     LEFT JOIN dbo.tlbGeoLocationShared gls
                         ON gls.idfGeoLocationShared = fa.idfFarmAddress
                            AND gls.intRowStatus = 0
                     INNER JOIN dbo.FN_GBL_LocationHierarchy_Flattened(@LanguageID) lh
                         ON lh.idfsLocation = gls.idfsLocation
                     LEFT JOIN dbo.gisLocation settlement
                         ON settlement.idfsLocation = gls.idfsLocation
                            AND settlement.idfsType IS NOT NULL
                     LEFT JOIN dbo.FN_GBL_GIS_ReferenceRepair_GET(@LanguageID, 19000004) settlementName
                         ON settlementName.idfsReference = settlement.idfsLocation
                 WHERE fa.intRowStatus = 0
                       AND (
                               (fa.idfFarmActual = @FarmMasterID)
                               OR (@FarmMasterID IS NULL)
                           )
                       AND (
                               -- 06/18/2020 - Added condition also to look for intHACode values as idfsCategory column is not populated in v6.1 data.
                               (
                                   fa.idfsFarmCategory = @FarmTypeID
                                   OR fa.idfsFarmCategory = 10040001
                               ) --10040001 = both avian and livestock
                               OR (@FarmTypeID IS NULL)
                               OR (fa.intHACode = @AccessoryCode)
                               OR (@AccessoryCode IS NULL)
                           )
                       AND (
                               (ha.idfHumanActual = @FarmOwnerID)
                               OR (@FarmOwnerID IS NULL)
                           )
                       AND (
                               lh.AdminLevel2ID = @idfsLocation
                               OR @LocationNode.IsDescendantOf(lh.Node) = 1
                               OR lh.Node.IsDescendantOf(@LocationNode) = 1
                               OR @idfsLocation IS NULL
                           )
                       AND (
                               lh.AdminLevel3ID = @idfsLocation
                               OR @LocationNode.IsDescendantOf(lh.Node) = 1
                               OR lh.Node.IsDescendantOf(@LocationNode) = 1
                               OR @idfsLocation IS NULL
                           )
                       AND (
                               lh.AdminLevel4ID = @idfsLocation
                               OR @LocationNode.IsDescendantOf(lh.Node) = 1
                               OR lh.Node.IsDescendantOf(@LocationNode) = 1
                               OR @idfsLocation IS NULL
                           )
                       AND (
                               @SettlementTypeID IS NOT NULL
                               AND EXISTS
                 (
                     SELECT idfsSettlementType
                     FROM dbo.gisSettlement
                     WHERE idfsSettlementType = @SettlementTypeID
                 )
                               OR @SettlementTypeID IS NULL
                           )
                       AND (
                               (fa.strFarmCode LIKE '%' + TRIM(@EIDSSFarmID) + '%')
                               OR (@EIDSSFarmID IS NULL)
                           )
                       AND (
                               (
                                   fa.strFarmCode LIKE '%' + TRIM(@LegacyFarmID) + '%'
                                   AND fa.SourceSystemNameID = 10519002
                               ) --EIDSS version 6.1 record source (migrated record)
                               OR (@LegacyFarmID IS NULL)
                           )
                       AND (
                               (fa.strNationalName LIKE '%' + @FarmName + '%')
                               OR (@FarmName IS NULL)
                           )
                       AND (
                               (ha.strFirstName LIKE '%' + @FarmOwnerFirstName + '%')
                               OR (@FarmOwnerFirstName IS NULL)
                           )
                       AND (
                               (ha.strLastName LIKE '%' + @FarmOwnerLastName + '%')
                               OR (@FarmOwnerLastName IS NULL)
                           )
                       AND (
                               (haai.EIDSSPersonID LIKE '%' + TRIM(@EIDSSPersonID) + '%')
                               OR (@EIDSSPersonID IS NULL)
                           )
                       AND (
                               (ha.strPersonID LIKE '%' + TRIM(@EIDSSFarmOwnerID) + '%')
                               OR (@EIDSSFarmOwnerID IS NULL)
                           )
                       AND (
                               EXISTS
                 (
                     SELECT idfFarm
                     FROM dbo.tlbFarm
                     WHERE idfFarmActual = fa.idfFarmActual
                           AND idfMonitoringSession = @MonitoringSessionID
                 )
                               OR @MonitoringSessionID IS NULL
                           )
                ),
                  CTEResults
             AS (SELECT ROW_NUMBER() OVER (ORDER BY CASE
                                                        WHEN @sortColumn = 'FarmMasterID'
                                                             AND @SortOrder = 'asc' THEN
                                                            FarmMasterID
                                                    END ASC,
                                                    CASE
                                                        WHEN @sortColumn = 'FarmMasterID'
                                                             AND @SortOrder = 'desc' THEN
                                                            FarmMasterID
                                                    END DESC,
                                                    CASE
                                                        WHEN @sortColumn = 'FarmTypeID'
                                                             AND @SortOrder = 'asc' THEN
                                                            FarmTypeID
                                                    END ASC,
                                                    CASE
                                                        WHEN @sortColumn = 'FarmTypeID'
                                                             AND @SortOrder = 'desc' THEN
                                                            FarmTypeID
                                                    END DESC,
                                                    CASE
                                                        WHEN @sortColumn = 'FarmTypeName'
                                                             AND @SortOrder = 'asc' THEN
                                                            FarmTypeName
                                                    END ASC,
                                                    CASE
                                                        WHEN @sortColumn = 'FarmTypeName'
                                                             AND @SortOrder = 'desc' THEN
                                                            FarmTypeName
                                                    END DESC,
                                                    CASE
                                                        WHEN @sortColumn = 'FarmOwnerID'
                                                             AND @SortOrder = 'asc' THEN
                                                            FarmOwnerID
                                                    END ASC,
                                                    CASE
                                                        WHEN @sortColumn = 'FarmOwnerID'
                                                             AND @SortOrder = 'desc' THEN
                                                            FarmOwnerID
                                                    END DESC,
                                                    CASE
                                                        WHEN @sortColumn = 'FarmAddressID'
                                                             AND @SortOrder = 'asc' THEN
                                                            FarmAddressID
                                                    END ASC,
                                                    CASE
                                                        WHEN @sortColumn = 'FarmAddressID'
                                                             AND @SortOrder = 'desc' THEN
                                                            FarmAddressID
                                                    END DESC,
                                                    CASE
                                                        WHEN @sortColumn = 'FarmName'
                                                             AND @SortOrder = 'asc' THEN
                                                            FarmName
                                                    END ASC,
                                                    CASE
                                                        WHEN @sortColumn = 'FarmName'
                                                             AND @SortOrder = 'desc' THEN
                                                            FarmName
                                                    END DESC,
                                                    CASE
                                                        WHEN @sortColumn = 'EIDSSFarmID'
                                                             AND @SortOrder = 'asc' THEN
                                                            EIDSSFarmID
                                                    END ASC,
                                                    CASE
                                                        WHEN @sortColumn = 'EIDSSFarmID'
                                                             AND @SortOrder = 'desc' THEN
                                                            EIDSSFarmID
                                                    END DESC,
                                                    CASE
                                                        WHEN @sortColumn = 'Fax'
                                                             AND @SortOrder = 'asc' THEN
                                                            Fax
                                                    END ASC,
                                                    CASE
                                                        WHEN @sortColumn = 'Fax'
                                                             AND @SortOrder = 'desc' THEN
                                                            Fax
                                                    END DESC,
                                                    CASE
                                                        WHEN @sortColumn = 'Email'
                                                             AND @SortOrder = 'asc' THEN
                                                            Email
                                                    END ASC,
                                                    CASE
                                                        WHEN @sortColumn = 'Email'
                                                             AND @SortOrder = 'desc' THEN
                                                            Email
                                                    END DESC,
                                                    CASE
                                                        WHEN @sortColumn = 'Phone'
                                                             AND @SortOrder = 'asc' THEN
                                                            Phone
                                                    END ASC,
                                                    CASE
                                                        WHEN @sortColumn = 'Phone'
                                                             AND @SortOrder = 'desc' THEN
                                                            Phone
                                                    END DESC,
                                                    CASE
                                                        WHEN @sortColumn = 'TotalLivestockAnimalQuantity'
                                                             AND @SortOrder = 'asc' THEN
                                                            TotalLivestockAnimalQuantity
                                                    END ASC,
                                                    CASE
                                                        WHEN @sortColumn = 'TotalLivestockAnimalQuantity'
                                                             AND @SortOrder = 'desc' THEN
                                                            TotalLivestockAnimalQuantity
                                                    END DESC,
                                                    CASE
                                                        WHEN @sortColumn = 'TotalAvianAnimalQuantity'
                                                             AND @SortOrder = 'asc' THEN
                                                            TotalAvianAnimalQuantity
                                                    END ASC,
                                                    CASE
                                                        WHEN @sortColumn = 'TotalAvianAnimalQuantity'
                                                             AND @SortOrder = 'desc' THEN
                                                            TotalAvianAnimalQuantity
                                                    END DESC,
                                                    CASE
                                                        WHEN @sortColumn = 'SickLivestockAnimalQuantity'
                                                             AND @SortOrder = 'asc' THEN
                                                            SickLivestockAnimalQuantity
                                                    END ASC,
                                                    CASE
                                                        WHEN @sortColumn = 'SickLivestockAnimalQuantity'
                                                             AND @SortOrder = 'desc' THEN
                                                            SickLivestockAnimalQuantity
                                                    END DESC,
                                                    CASE
                                                        WHEN @sortColumn = 'SickAvianAnimalQuantity'
                                                             AND @SortOrder = 'asc' THEN
                                                            SickAvianAnimalQuantity
                                                    END ASC,
                                                    CASE
                                                        WHEN @sortColumn = 'SickAvianAnimalQuantity'
                                                             AND @SortOrder = 'desc' THEN
                                                            SickAvianAnimalQuantity
                                                    END DESC,
                                                    CASE
                                                        WHEN @sortColumn = 'DeadLivestockAnimalQuantity'
                                                             AND @SortOrder = 'asc' THEN
                                                            DeadLivestockAnimalQuantity
                                                    END ASC,
                                                    CASE
                                                        WHEN @sortColumn = 'DeadLivestockAnimalQuantity'
                                                             AND @SortOrder = 'desc' THEN
                                                            DeadLivestockAnimalQuantity
                                                    END DESC,
                                                    CASE
                                                        WHEN @sortColumn = 'DeadAvianAnimalQuantity'
                                                             AND @SortOrder = 'asc' THEN
                                                            DeadAvianAnimalQuantity
                                                    END ASC,
                                                    CASE
                                                        WHEN @sortColumn = 'DeadAvianAnimalQuantity'
                                                             AND @SortOrder = 'desc' THEN
                                                            DeadAvianAnimalQuantity
                                                    END DESC,
                                                    CASE
                                                        WHEN @sortColumn = 'RowStatus'
                                                             AND @SortOrder = 'asc' THEN
                                                            RowStatus
                                                    END ASC,
                                                    CASE
                                                        WHEN @sortColumn = 'RowStatus'
                                                             AND @SortOrder = 'desc' THEN
                                                            RowStatus
                                                    END DESC,
                                                    CASE
                                                        WHEN @sortColumn = 'CountryID'
                                                             AND @SortOrder = 'asc' THEN
                                                            CountryID
                                                    END ASC,
                                                    CASE
                                                        WHEN @sortColumn = 'CountryID'
                                                             AND @SortOrder = 'desc' THEN
                                                            CountryID
                                                    END DESC,
                                                    CASE
                                                        WHEN @sortColumn = 'RegionID'
                                                             AND @SortOrder = 'asc' THEN
                                                            RegionID
                                                    END ASC,
                                                    CASE
                                                        WHEN @sortColumn = 'RegionID'
                                                             AND @SortOrder = 'desc' THEN
                                                            RegionID
                                                    END DESC,
                                                    CASE
                                                        WHEN @sortColumn = 'RegionName'
                                                             AND @SortOrder = 'asc' THEN
                                                            RegionName
                                                    END ASC,
                                                    CASE
                                                        WHEN @sortColumn = 'RegionName'
                                                             AND @SortOrder = 'desc' THEN
                                                            RegionName
                                                    END DESC,
                                                    CASE
                                                        WHEN @sortColumn = 'RayonName'
                                                             AND @SortOrder = 'asc' THEN
                                                            RayonName
                                                    END ASC,
                                                    CASE
                                                        WHEN @sortColumn = 'RayonName'
                                                             AND @SortOrder = 'desc' THEN
                                                            RayonName
                                                    END DESC,
                                                    CASE
                                                        WHEN @sortColumn = 'SettlementID'
                                                             AND @SortOrder = 'asc' THEN
                                                            SettlementID
                                                    END ASC,
                                                    CASE
                                                        WHEN @sortColumn = 'SettlementID'
                                                             AND @SortOrder = 'desc' THEN
                                                            SettlementID
                                                    END DESC,
                                                    CASE
                                                        WHEN @sortColumn = 'SettlementName'
                                                             AND @SortOrder = 'asc' THEN
                                                            SettlementName
                                                    END ASC,
                                                    CASE
                                                        WHEN @sortColumn = 'SettlementName'
                                                             AND @SortOrder = 'desc' THEN
                                                            SettlementName
                                                    END DESC,
                                                    CASE
                                                        WHEN @sortColumn = 'Apartment'
                                                             AND @SortOrder = 'asc' THEN
                                                            Apartment
                                                    END ASC,
                                                    CASE
                                                        WHEN @sortColumn = 'Apartment'
                                                             AND @SortOrder = 'desc' THEN
                                                            Apartment
                                                    END DESC,
                                                    CASE
                                                        WHEN @sortColumn = 'Building'
                                                             AND @SortOrder = 'asc' THEN
                                                            Building
                                                    END ASC,
                                                    CASE
                                                        WHEN @sortColumn = 'Building'
                                                             AND @SortOrder = 'desc' THEN
                                                            Building
                                                    END DESC,
                                                    CASE
                                                        WHEN @sortColumn = 'House'
                                                             AND @SortOrder = 'asc' THEN
                                                            House
                                                    END ASC,
                                                    CASE
                                                        WHEN @sortColumn = 'House'
                                                             AND @SortOrder = 'desc' THEN
                                                            House
                                                    END DESC,
                                                    CASE
                                                        WHEN @sortColumn = 'PostalCode'
                                                             AND @SortOrder = 'asc' THEN
                                                            PostalCode
                                                    END ASC,
                                                    CASE
                                                        WHEN @sortColumn = 'PostalCode'
                                                             AND @SortOrder = 'desc' THEN
                                                            PostalCode
                                                    END DESC,
                                                    CASE
                                                        WHEN @sortColumn = 'Street'
                                                             AND @SortOrder = 'asc' THEN
                                                            Street
                                                    END ASC,
                                                    CASE
                                                        WHEN @sortColumn = 'Street'
                                                             AND @SortOrder = 'desc' THEN
                                                            Street
                                                    END DESC,
                                                    CASE
                                                        WHEN @sortColumn = 'Latitude'
                                                             AND @SortOrder = 'asc' THEN
                                                            Latitude
                                                    END ASC,
                                                    CASE
                                                        WHEN @sortColumn = 'Latitude'
                                                             AND @SortOrder = 'desc' THEN
                                                            Latitude
                                                    END DESC,
                                                    CASE
                                                        WHEN @sortColumn = 'Longitude'
                                                             AND @SortOrder = 'asc' THEN
                                                            Longitude
                                                    END ASC,
                                                    CASE
                                                        WHEN @sortColumn = 'Longitude'
                                                             AND @SortOrder = 'desc' THEN
                                                            Longitude
                                                    END DESC,
                                                    CASE
                                                        WHEN @sortColumn = 'EIDSSPersonID'
                                                             AND @SortOrder = 'asc' THEN
                                                            EIDSSPersonID
                                                    END ASC,
                                                    CASE
                                                        WHEN @sortColumn = 'EIDSSPersonID'
                                                             AND @SortOrder = 'desc' THEN
                                                            EIDSSPersonID
                                                    END DESC,
                                                    CASE
                                                        WHEN @sortColumn = 'EIDSSFarmOwnerID'
                                                             AND @SortOrder = 'asc' THEN
                                                            EIDSSFarmOwnerID
                                                    END ASC,
                                                    CASE
                                                        WHEN @sortColumn = 'EIDSSFarmOwnerID'
                                                             AND @SortOrder = 'desc' THEN
                                                            EIDSSFarmOwnerID
                                                    END DESC,
                                                    CASE
                                                        WHEN @sortColumn = 'FarmOwnerName'
                                                             AND @SortOrder = 'asc' THEN
                                                            FarmOwnerID
                                                    END ASC,
                                                    CASE
                                                        WHEN @sortColumn = 'FarmOwnerName'
                                                             AND @SortOrder = 'desc' THEN
                                                            FarmOwnerID
                                                    END DESC,
                                                    CASE
                                                        WHEN @sortColumn = 'FarmOwnerFirstName'
                                                             AND @SortOrder = 'asc' THEN
                                                            FarmOwnerFirstName
                                                    END ASC,
                                                    CASE
                                                        WHEN @sortColumn = 'FarmOwnerFirstName'
                                                             AND @SortOrder = 'desc' THEN
                                                            FarmOwnerFirstName
                                                    END DESC,
                                                    CASE
                                                        WHEN @sortColumn = 'FarmOwnerLastName'
                                                             AND @SortOrder = 'asc' THEN
                                                            FarmOwnerLastName
                                                    END ASC,
                                                    CASE
                                                        WHEN @sortColumn = 'FarmOwnerLastName'
                                                             AND @SortOrder = 'desc' THEN
                                                            FarmOwnerLastName
                                                    END DESC,
                                                    CASE
                                                        WHEN @sortColumn = 'FarmOwnerSecondName'
                                                             AND @SortOrder = 'asc' THEN
                                                            FarmOwnerSecondName
                                                    END ASC,
                                                    CASE
                                                        WHEN @sortColumn = 'FarmOwnerSecondName'
                                                             AND @SortOrder = 'desc' THEN
                                                            FarmOwnerSecondName
                                                    END DESC
                                          ) AS ROWNUM,
                        COUNT(*) OVER () AS RecordCount,
                        FarmMasterID,
                        FarmTypeID,
                        FarmTypeName,
                        FarmOwnerID,
                        FarmAddressID,
                        FarmName,
                        EIDSSFarmID,
                        Fax,
                        Email,
                        Phone,
                        TotalLivestockAnimalQuantity,
                        TotalAvianAnimalQuantity,
                        SickLivestockAnimalQuantity,
                        SickAvianAnimalQuantity,
                        DeadLivestockAnimalQuantity,
                        DeadAvianAnimalQuantity,
                        RowStatus,
                        CountryID,
                        RegionID,
                        RegionName,
                        RayonID,
                        RayonName,
                        SettlementID,
                        SettlementName,
                        Apartment,
                        Building,
                        House,
                        PostalCode,
                        Street,
                        Latitude,
                        Longitude,
                        Elevation,
                        EIDSSPersonID,
                        EIDSSFarmOwnerID,
                        FarmOwnerName,
                        FarmOwnerFirstName,
                        FarmOwnerLastName,
                        FarmOwnerSecondName
                 FROM CTEIntermediate
                 WHERE (@FarmTypeID IS NULL)
                       OR FarmTypeName = @FarmTypesName
                )
            SELECT RecordCount,
                   FarmMasterID,
                   FarmTypeID,
                   FarmTypeName,
                   FarmOwnerID,
                   FarmAddressID,
                   FarmName,
                   EIDSSFarmID,
                   Fax,
                   Email,
                   Phone,
                   TotalLivestockAnimalQuantity,
                   TotalAvianAnimalQuantity,
                   SickLivestockAnimalQuantity,
                   SickAvianAnimalQuantity,
                   DeadLivestockAnimalQuantity,
                   DeadAvianAnimalQuantity,
                   RowStatus,
                   CountryID,
                   RegionID,
                   RegionName,
                   RayonID,
                   RayonName,
                   SettlementID,
                   SettlementName,
                   Apartment,
                   Building,
                   House,
                   PostalCode,
                   Street,
                   Latitude,
                   Longitude,
                   Elevation,
                   EIDSSPersonID,
                   EIDSSFarmOwnerID,
                   FarmOwnerName,
                   FarmOwnerFirstName,
                   FarmOwnerLastName,
                   FarmOwnerSecondName,
                   TotalPages = (RecordCount / @pageSize) + IIF(RecordCount % @pageSize > 0, 1, 0),
                   CurrentPage = @pageNo
            FROM CTEResults
            WHERE RowNum > @firstRec
                  AND RowNum < @lastRec
            OPTION (RECOMPILE);
        END
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH;
END;
GO
PRINT N'Creating Procedure [dbo].[USP_HUM_DISEASE_REPORT_PERMISSION_GETDetail]...';


GO
-- ================================================================================================
-- Name: USP_HUM_DISEASE_REPORT_PERMISSIONS_GETDetail
--
-- Description: List Human Disease Report
--          
-- Author: Stephen Long
--
-- Revision History:
-- Name                    Date       Change Detail
-- ----------------------- ---------- ------------------------------------------------------------
--
-- Testing code:
-- 
/* 
EXEC USP_HUM_DISEASE_GETDetail 'en-US', 71413
*/
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_HUM_DISEASE_REPORT_PERMISSION_GETDetail]
(
    @LanguageID NVARCHAR(50),
    @RecordID BIGINT,
    @UserSiteID BIGINT,
    @UserOrganizationID BIGINT,
    @UserEmployeeID BIGINT
)
AS
BEGIN
    BEGIN TRY
        SET NOCOUNT ON;

        DECLARE @ReturnMessage VARCHAR(MAX) = 'Success',
                @ReturnCode INT = 0,
                @FiltrationSiteAdministrativeLevelID AS BIGINT,
                @SiteID BIGINT = (
                                     SELECT idfsSite
                                     FROM dbo.tlbHumanCase
                                     WHERE idfHumanCase = @RecordID
                                 );


        DECLARE @UserSitePermissions TABLE
        (
            SiteID BIGINT NOT NULL,
            PermissionTypeID BIGINT NOT NULL,
            Permission INT NOT NULL
        );
        DECLARE @UserGroupSitePermissions TABLE
        (
            SiteID BIGINT NOT NULL,
            PermissionTypeID BIGINT NOT NULL,
            Permission INT NOT NULL
        );
        DECLARE @Results TABLE
        (
            ID BIGINT NOT NULL,
            ReadPermissionIndicator INT NOT NULL,
            AccessToPersonalDataPermissionIndicator INT NOT NULL,
            AccessToGenderAndAgeDataPermissionIndicator INT NOT NULL,
            WritePermissionIndicator INT NOT NULL,
            DeletePermissionIndicator INT NOT NULL
        );
        DECLARE @FinalResults TABLE
        (
            ID BIGINT NOT NULL,
            ReadPermissionIndicator INT NOT NULL,
            AccessToPersonalDataPermissionIndicator INT NOT NULL,
            AccessToGenderAndAgeDataPermissionIndicator INT NOT NULL,
            WritePermissionIndicator INT NOT NULL,
            DeletePermissionIndicator INT NOT NULL
        );

        IF @UserSiteID <> @SiteID
        BEGIN
            INSERT INTO @UserGroupSitePermissions
            SELECT oa.idfsOnSite,
                   oa.idfsObjectOperation,
                   CASE
                       WHEN oa.intPermission = 2 THEN
                           3
                       ELSE
                           2
                   END
            FROM dbo.tstObjectAccess oa
                INNER JOIN dbo.tlbEmployeeGroupMember egm
                    ON egm.idfEmployee = @UserEmployeeID
                       AND egm.intRowStatus = 0
            WHERE oa.intRowStatus = 0
                  AND oa.idfsObjectType = 10060011 -- Site
                  AND oa.idfActor = egm.idfEmployeeGroup;

            INSERT INTO @UserSitePermissions
            SELECT oa.idfsOnSite,
                   oa.idfsObjectOperation,
                   CASE
                       WHEN oa.intPermission = 2 THEN
                           5
                       ELSE
                           4
                   END
            FROM dbo.tstObjectAccess oa
            WHERE oa.intRowStatus = 0
                  AND oa.idfsObjectType = 10060011 -- Site
                  AND oa.idfActor = @UserEmployeeID;

            -- =======================================================================================
            -- DEFAULT CONFIGURABLE FILTRATION RULES
            --
            -- Apply active default filtration rules for third level sites.
            -- =======================================================================================
            DECLARE @RuleActiveStatus INT = 0;
            DECLARE @AdministrativeLevelTypeID INT;
            DECLARE @DefaultAccessRules AS TABLE
            (
                AccessRuleID BIGINT NOT NULL,
                ActiveIndicator INT NOT NULL,
                ReadPermissionIndicator INT NOT NULL,
                AccessToPersonalDataPermissionIndicator INT NOT NULL,
                AccessToGenderAndAgeDataPermissionIndicator INT NOT NULL,
                WritePermissionIndicator INT NOT NULL,
                DeletePermissionIndicator INT NOT NULL,
                AdministrativeLevelTypeID INT NULL
            );

            INSERT INTO @DefaultAccessRules
            SELECT AccessRuleID,
                   a.intRowStatus,
                   a.ReadPermissionIndicator,
                   a.AccessToPersonalDataPermissionIndicator,
                   a.AccessToGenderAndAgeDataPermissionIndicator,
                   a.WritePermissionIndicator,
                   a.DeletePermissionIndicator,
                   a.AdministrativeLevelTypeID
            FROM dbo.AccessRule a
            WHERE DefaultRuleIndicator = 1;

            SELECT @RuleActiveStatus = ActiveIndicator
            FROM @DefaultAccessRules
            WHERE AccessRuleID = 10537000;

            IF @RuleActiveStatus = 0
            BEGIN
                SELECT @AdministrativeLevelTypeID = AdministrativeLevelTypeID
                FROM @DefaultAccessRules
                WHERE AccessRuleID = 10537000;

                SELECT @FiltrationSiteAdministrativeLevelID = CASE
                                                                  WHEN @AdministrativeLevelTypeID = 1 THEN
                                                                      g.Level1ID
                                                                  WHEN @AdministrativeLevelTypeID = 2 THEN
                                                                      g.Level2ID
                                                                  WHEN @AdministrativeLevelTypeID = 3 THEN
                                                                      g.Level3ID
                                                                  WHEN @AdministrativeLevelTypeID = 4 THEN
                                                                      g.Level4ID
                                                                  WHEN @AdministrativeLevelTypeID = 5 THEN
                                                                      g.Level5ID
                                                                  WHEN @AdministrativeLevelTypeID = 6 THEN
                                                                      g.Level6ID
                                                                  WHEN @AdministrativeLevelTypeID = 7 THEN
                                                                      g.Level7ID
                                                              END
                FROM dbo.tlbOffice o
                    INNER JOIN dbo.tlbGeoLocationShared l
                        ON l.idfGeoLocationShared = o.idfLocation
                           AND l.intRowStatus = 0
                    INNER JOIN dbo.gisLocationDenormalized g
                        ON g.idfsLocation = l.idfsLocation
                           AND g.idfsLanguage = dbo.FN_GBL_LanguageCode_GET(@LanguageID)
                WHERE o.intRowStatus = 0
                      AND o.idfOffice = @UserOrganizationID;

                -- Administrative level specified in the rule of the site where the report was created.
                INSERT INTO @Results
                SELECT h.idfHumanCase,
                       a.ReadPermissionIndicator,
                       a.AccessToPersonalDataPermissionIndicator,
                       a.AccessToGenderAndAgeDataPermissionIndicator,
                       a.WritePermissionIndicator,
                       a.DeletePermissionIndicator
                FROM dbo.tlbHumanCase h
                    INNER JOIN dbo.tstSite s
                        ON h.idfsSite = s.idfsSite
                    INNER JOIN dbo.tlbOffice o
                        ON o.idfOffice = s.idfOffice
                           AND o.intRowStatus = 0
                    INNER JOIN dbo.tlbGeoLocationShared l
                        ON l.idfGeoLocationShared = o.idfLocation
                           AND l.intRowStatus = 0
                    INNER JOIN dbo.gisLocationDenormalized g
                        ON g.idfsLocation = l.idfsLocation
                           AND g.idfsLanguage = dbo.FN_GBL_LanguageCode_GET(@LanguageID)
                    INNER JOIN @DefaultAccessRules a
                        ON a.AccessRuleID = 10537000
                WHERE h.idfHumanCase = @RecordID
                      AND (
                              g.Level1ID = @FiltrationSiteAdministrativeLevelID
                              AND @AdministrativeLevelTypeID = 1
                              OR g.Level2ID = @FiltrationSiteAdministrativeLevelID
                                 AND @AdministrativeLevelTypeID = 2
                              OR g.Level3ID = @FiltrationSiteAdministrativeLevelID
                                 AND @AdministrativeLevelTypeID = 3
                              OR g.Level4ID = @FiltrationSiteAdministrativeLevelID
                                 AND @AdministrativeLevelTypeID = 4
                              OR g.Level5ID = @FiltrationSiteAdministrativeLevelID
                                 AND @AdministrativeLevelTypeID = 5
                              OR g.Level6ID = @FiltrationSiteAdministrativeLevelID
                                 AND @AdministrativeLevelTypeID = 6
                              OR g.Level7ID = @FiltrationSiteAdministrativeLevelID
                                 AND @AdministrativeLevelTypeID = 7
                          )

                -- Administrative level specified in the rule of the report current residence address.
                INSERT INTO @Results
                SELECT h.idfHumanCase,
                       a.ReadPermissionIndicator,
                       a.AccessToPersonalDataPermissionIndicator,
                       a.AccessToGenderAndAgeDataPermissionIndicator,
                       a.WritePermissionIndicator,
                       a.DeletePermissionIndicator
                FROM dbo.tlbHumanCase h
                    INNER JOIN dbo.tlbHuman hu
                        ON hu.idfHuman = h.idfHuman
                           AND hu.intRowStatus = 0
                    INNER JOIN dbo.tlbGeoLocation l
                        ON l.idfGeoLocation = hu.idfCurrentResidenceAddress
                           AND l.intRowStatus = 0
                    INNER JOIN dbo.gisLocationDenormalized g
                        ON g.idfsLocation = l.idfsLocation
                           AND g.idfsLanguage = dbo.FN_GBL_LanguageCode_GET(@LanguageID)
                    INNER JOIN @DefaultAccessRules a
                        ON a.AccessRuleID = 10537000
                WHERE h.idfHumanCase = @RecordID
                      AND (
                              g.Level1ID = @FiltrationSiteAdministrativeLevelID
                              AND @AdministrativeLevelTypeID = 1
                              OR g.Level2ID = @FiltrationSiteAdministrativeLevelID
                                 AND @AdministrativeLevelTypeID = 2
                              OR g.Level3ID = @FiltrationSiteAdministrativeLevelID
                                 AND @AdministrativeLevelTypeID = 3
                              OR g.Level4ID = @FiltrationSiteAdministrativeLevelID
                                 AND @AdministrativeLevelTypeID = 4
                              OR g.Level5ID = @FiltrationSiteAdministrativeLevelID
                                 AND @AdministrativeLevelTypeID = 5
                              OR g.Level6ID = @FiltrationSiteAdministrativeLevelID
                                 AND @AdministrativeLevelTypeID = 6
                              OR g.Level7ID = @FiltrationSiteAdministrativeLevelID
                                 AND @AdministrativeLevelTypeID = 7
                          )

                -- Administrative level specified in the rule of the report location of exposure, 
                -- if corresponding field was filled in.
                INSERT INTO @Results
                SELECT h.idfHumanCase,
                       a.ReadPermissionIndicator,
                       a.AccessToPersonalDataPermissionIndicator,
                       a.AccessToGenderAndAgeDataPermissionIndicator,
                       a.WritePermissionIndicator,
                       a.DeletePermissionIndicator
                FROM dbo.tlbHumanCase h
                    INNER JOIN dbo.tlbGeoLocation l
                        ON l.idfGeoLocation = h.idfPointGeoLocation
                           AND l.intRowStatus = 0
                    INNER JOIN dbo.gisLocationDenormalized g
                        ON g.idfsLocation = l.idfsLocation
                           AND g.idfsLanguage = dbo.FN_GBL_LanguageCode_GET(@LanguageID)
                    INNER JOIN @DefaultAccessRules a
                        ON a.AccessRuleID = 10537000
                WHERE h.idfHumanCase = @RecordID
                      AND (
                              g.Level1ID = @FiltrationSiteAdministrativeLevelID
                              AND @AdministrativeLevelTypeID = 1
                              OR g.Level2ID = @FiltrationSiteAdministrativeLevelID
                                 AND @AdministrativeLevelTypeID = 2
                              OR g.Level3ID = @FiltrationSiteAdministrativeLevelID
                                 AND @AdministrativeLevelTypeID = 3
                              OR g.Level4ID = @FiltrationSiteAdministrativeLevelID
                                 AND @AdministrativeLevelTypeID = 4
                              OR g.Level5ID = @FiltrationSiteAdministrativeLevelID
                                 AND @AdministrativeLevelTypeID = 5
                              OR g.Level6ID = @FiltrationSiteAdministrativeLevelID
                                 AND @AdministrativeLevelTypeID = 6
                              OR g.Level7ID = @FiltrationSiteAdministrativeLevelID
                                 AND @AdministrativeLevelTypeID = 7
                          )
            END;

            -- Report data shall be available to all sites' organizations connected to the particular report.
            -- Notification sent by, notification received by, facility where the patient first sought 
            -- care, hospital, and the conducting investigation organizations.
            SELECT @RuleActiveStatus = intRowStatus
            FROM dbo.AccessRule
            WHERE AccessRuleID = 10537001;

            IF @RuleActiveStatus = 0
            BEGIN
                INSERT INTO @Results
                SELECT h.idfHumanCase,
                       a.ReadPermissionIndicator,
                       a.AccessToPersonalDataPermissionIndicator,
                       a.AccessToGenderAndAgeDataPermissionIndicator,
                       a.WritePermissionIndicator,
                       a.DeletePermissionIndicator
                FROM dbo.tlbHumanCase h
                    INNER JOIN @DefaultAccessRules a
                        ON a.AccessRuleID = 10537001
                WHERE h.idfHumanCase = @RecordID
                      AND (
                              h.idfSentByOffice = @UserOrganizationID
                              OR h.idfReceivedByOffice = @UserOrganizationID
                              OR h.idfSoughtCareFacility = @UserOrganizationID
                              OR h.idfHospital = @UserOrganizationID
                              OR h.idfInvestigatedByOffice = @UserOrganizationID
                          );

                -- Sample collected by and sent to organizations
                INSERT INTO @Results
                SELECT MAX(m.idfHumanCase),
                       a.ReadPermissionIndicator,
                       a.AccessToPersonalDataPermissionIndicator,
                       a.AccessToGenderAndAgeDataPermissionIndicator,
                       a.WritePermissionIndicator,
                       a.DeletePermissionIndicator
                FROM dbo.tlbMaterial m
                    INNER JOIN dbo.tlbHumanCase h
                        ON h.idfHumanCase = m.idfHumanCase
                           AND h.idfHumanCase = @RecordID
                    INNER JOIN @DefaultAccessRules a
                        ON a.AccessRuleID = 10537001
                WHERE m.intRowStatus = 0
                      AND (
                              m.idfFieldCollectedByOffice = @UserOrganizationID
                              OR m.idfSendToOffice = @UserOrganizationID
                          )
                GROUP BY m.idfHumanCase,
                         a.ReadPermissionIndicator,
                         a.AccessToPersonalDataPermissionIndicator,
                         a.AccessToGenderAndAgeDataPermissionIndicator,
                         a.WritePermissionIndicator,
                         a.DeletePermissionIndicator;

                -- Sample transferred to organizations
                INSERT INTO @Results
                SELECT MAX(m.idfHumanCase),
                       a.ReadPermissionIndicator,
                       a.AccessToPersonalDataPermissionIndicator,
                       a.AccessToGenderAndAgeDataPermissionIndicator,
                       a.WritePermissionIndicator,
                       a.DeletePermissionIndicator
                FROM dbo.tlbMaterial m
                    INNER JOIN dbo.tlbHumanCase h
                        ON h.idfHumanCase = m.idfHumanCase
                           AND h.idfHumanCase = @RecordID
                    INNER JOIN dbo.tlbTransferOutMaterial tom
                        ON m.idfMaterial = tom.idfMaterial
                           AND tom.intRowStatus = 0
                    INNER JOIN dbo.tlbTransferOUT t
                        ON tom.idfTransferOut = t.idfTransferOut
                           AND t.intRowStatus = 0
                    INNER JOIN @DefaultAccessRules a
                        ON a.AccessRuleID = 10537001
                WHERE m.intRowStatus = 0
                      AND t.idfSendToOffice = @UserOrganizationID
                GROUP BY m.idfHumanCase,
                         a.ReadPermissionIndicator,
                         a.AccessToPersonalDataPermissionIndicator,
                         a.AccessToGenderAndAgeDataPermissionIndicator,
                         a.WritePermissionIndicator,
                         a.DeletePermissionIndicator;
            END;

            --
            -- Report data shall be available to the sites with the connected outbreak, if the report 
            -- is the primary report/session for an outbreak.
            --
            SELECT @RuleActiveStatus = intRowStatus
            FROM dbo.AccessRule
            WHERE AccessRuleID = 10537002;

            IF @RuleActiveStatus = 0
            BEGIN
                INSERT INTO @Results
                SELECT h.idfHumanCase,
                       a.ReadPermissionIndicator,
                       a.AccessToPersonalDataPermissionIndicator,
                       a.AccessToGenderAndAgeDataPermissionIndicator,
                       a.WritePermissionIndicator,
                       a.DeletePermissionIndicator
                FROM dbo.tlbHumanCase h
                    INNER JOIN dbo.tlbOutbreak o
                        ON h.idfHumanCase = o.idfPrimaryCaseOrSession
                           AND o.intRowStatus = 0
                    INNER JOIN @DefaultAccessRules a
                        ON a.AccessRuleID = 10537002
                WHERE h.idfHumanCase = @RecordID
                      AND o.idfsSite = @UserSiteID;
            END;

            -- =======================================================================================
            -- CONFIGURABLE FILTRATION RULES
            -- 
            -- Apply configurable filtration rules for use case SAUC34. Some of these rules may 
            -- overlap the default rules.
            -- =======================================================================================
            --
            -- Apply at the user's site group level, granted by a site group.
            --
            INSERT INTO @Results
            SELECT h.idfHumanCase,
                   a.ReadPermissionIndicator,
                   a.AccessToPersonalDataPermissionIndicator,
                   a.AccessToGenderAndAgeDataPermissionIndicator,
                   a.WritePermissionIndicator,
                   a.DeletePermissionIndicator
            FROM dbo.tlbHumanCase h
                INNER JOIN dbo.tflSiteToSiteGroup grantingSGS
                    ON grantingSGS.idfsSite = h.idfsSite
                INNER JOIN dbo.tflSiteToSiteGroup userSiteGroup
                    ON userSiteGroup.idfsSite = @UserSiteID
                INNER JOIN dbo.AccessRuleActor ara
                    ON ara.ActorSiteGroupID = userSiteGroup.idfSiteGroup
                       AND ara.intRowStatus = 0
                INNER JOIN dbo.AccessRule a
                    ON a.AccessRuleID = ara.AccessRuleID
                       AND a.intRowStatus = 0
                       AND a.DefaultRuleIndicator = 0
            WHERE h.idfHumanCase = @RecordID
                  AND a.GrantingActorSiteGroupID = grantingSGS.idfSiteGroup;

            --
            -- Apply at the user's site level, granted by a site group.
            --
            INSERT INTO @Results
            SELECT h.idfHumanCase,
                   a.ReadPermissionIndicator,
                   a.AccessToPersonalDataPermissionIndicator,
                   a.AccessToGenderAndAgeDataPermissionIndicator,
                   a.WritePermissionIndicator,
                   a.DeletePermissionIndicator
            FROM dbo.tlbHumanCase h
                INNER JOIN dbo.tflSiteToSiteGroup grantingSGS
                    ON grantingSGS.idfsSite = h.idfsSite
                INNER JOIN dbo.AccessRuleActor ara
                    ON ara.ActorSiteID = @UserSiteID
                       AND ara.ActorEmployeeGroupID IS NULL
                       AND ara.intRowStatus = 0
                INNER JOIN dbo.AccessRule a
                    ON a.AccessRuleID = ara.AccessRuleID
                       AND a.intRowStatus = 0
                       AND a.DefaultRuleIndicator = 0
            WHERE h.idfHumanCase = @RecordID
                  AND a.GrantingActorSiteGroupID = grantingSGS.idfSiteGroup;

            -- 
            -- Apply at the user's employee group level, granted by a site group.
            --
            INSERT INTO @Results
            SELECT h.idfHumanCase,
                   a.ReadPermissionIndicator,
                   a.AccessToPersonalDataPermissionIndicator,
                   a.AccessToGenderAndAgeDataPermissionIndicator,
                   a.WritePermissionIndicator,
                   a.DeletePermissionIndicator
            FROM dbo.tlbHumanCase h
                INNER JOIN dbo.tflSiteToSiteGroup grantingSGS
                    ON grantingSGS.idfsSite = h.idfsSite
                INNER JOIN dbo.tlbEmployeeGroupMember egm
                    ON egm.idfEmployee = @UserEmployeeID
                       AND egm.intRowStatus = 0
                INNER JOIN dbo.AccessRuleActor ara
                    ON ara.ActorEmployeeGroupID = egm.idfEmployeeGroup
                       AND ara.intRowStatus = 0
                INNER JOIN dbo.AccessRule a
                    ON a.AccessRuleID = ara.AccessRuleID
                       AND a.intRowStatus = 0
                       AND a.DefaultRuleIndicator = 0
            WHERE h.idfHumanCase = @RecordID
                  AND a.GrantingActorSiteGroupID = grantingSGS.idfSiteGroup;

            -- 
            -- Apply at the user's ID level, granted by a site group.
            --
            INSERT INTO @Results
            SELECT h.idfHumanCase,
                   a.ReadPermissionIndicator,
                   a.AccessToPersonalDataPermissionIndicator,
                   a.AccessToGenderAndAgeDataPermissionIndicator,
                   a.WritePermissionIndicator,
                   a.DeletePermissionIndicator
            FROM dbo.tlbHumanCase h
                INNER JOIN dbo.tflSiteToSiteGroup grantingSGS
                    ON grantingSGS.idfsSite = h.idfsSite
                INNER JOIN dbo.tstUserTable u
                    ON u.idfPerson = @UserEmployeeID
                       AND u.intRowStatus = 0
                INNER JOIN dbo.AccessRuleActor ara
                    ON ara.ActorUserID = u.idfUserID
                       AND ara.intRowStatus = 0
                INNER JOIN dbo.AccessRule a
                    ON a.AccessRuleID = ara.AccessRuleID
                       AND a.intRowStatus = 0
                       AND a.DefaultRuleIndicator = 0
            WHERE h.idfHumanCase = @RecordID
                  AND a.GrantingActorSiteGroupID = grantingSGS.idfSiteGroup;

            --
            -- Apply at the user's site group level, granted by a site.
            --
            INSERT INTO @Results
            SELECT h.idfHumanCase,
                   a.ReadPermissionIndicator,
                   a.AccessToPersonalDataPermissionIndicator,
                   a.AccessToGenderAndAgeDataPermissionIndicator,
                   a.WritePermissionIndicator,
                   a.DeletePermissionIndicator
            FROM dbo.tlbHumanCase h
                INNER JOIN dbo.tflSiteToSiteGroup sgs
                    ON sgs.idfsSite = @UserSiteID
                INNER JOIN dbo.AccessRuleActor ara
                    ON ara.ActorSiteGroupID = sgs.idfSiteGroup
                       AND ara.intRowStatus = 0
                INNER JOIN dbo.AccessRule a
                    ON a.AccessRuleID = ara.AccessRuleID
                       AND a.intRowStatus = 0
                       AND a.DefaultRuleIndicator = 0
            WHERE h.idfHumanCase = @RecordID
                  AND sgs.idfsSite = h.idfsSite;

            -- 
            -- Apply at the user's site level, granted by a site.
            --
            INSERT INTO @Results
            SELECT h.idfHumanCase,
                   a.ReadPermissionIndicator,
                   a.AccessToPersonalDataPermissionIndicator,
                   a.AccessToGenderAndAgeDataPermissionIndicator,
                   a.WritePermissionIndicator,
                   a.DeletePermissionIndicator
            FROM dbo.tlbHumanCase h
                INNER JOIN dbo.AccessRuleActor ara
                    ON ara.ActorSiteID = @UserSiteID
                       AND ara.ActorEmployeeGroupID IS NULL
                       AND ara.intRowStatus = 0
                INNER JOIN dbo.AccessRule a
                    ON a.AccessRuleID = ara.AccessRuleID
                       AND a.intRowStatus = 0
                       AND a.DefaultRuleIndicator = 0
            WHERE h.idfHumanCase = @RecordID
                  AND a.GrantingActorSiteID = h.idfsSite;

            -- 
            -- Apply at the user's employee group level, granted by a site.
            --
            INSERT INTO @Results
            SELECT h.idfHumanCase,
                   a.ReadPermissionIndicator,
                   a.AccessToPersonalDataPermissionIndicator,
                   a.AccessToGenderAndAgeDataPermissionIndicator,
                   a.WritePermissionIndicator,
                   a.DeletePermissionIndicator
            FROM dbo.tlbHumanCase h
                INNER JOIN dbo.tlbEmployeeGroupMember egm
                    ON egm.idfEmployee = @UserEmployeeID
                       AND egm.intRowStatus = 0
                INNER JOIN dbo.AccessRuleActor ara
                    ON ara.ActorEmployeeGroupID = egm.idfEmployeeGroup
                       AND ara.intRowStatus = 0
                INNER JOIN dbo.AccessRule a
                    ON a.AccessRuleID = ara.AccessRuleID
                       AND a.intRowStatus = 0
                       AND a.DefaultRuleIndicator = 0
            WHERE h.idfHumanCase = @RecordID
                  AND a.GrantingActorSiteID = h.idfsSite;

            -- 
            -- Apply at the user's ID level, granted by a site.
            ----
            INSERT INTO @Results
            SELECT h.idfHumanCase,
                   a.ReadPermissionIndicator,
                   a.AccessToPersonalDataPermissionIndicator,
                   a.AccessToGenderAndAgeDataPermissionIndicator,
                   a.WritePermissionIndicator,
                   a.DeletePermissionIndicator
            FROM dbo.tlbHumanCase h
                INNER JOIN dbo.tstUserTable u
                    ON u.idfPerson = @UserEmployeeID
                       AND u.intRowStatus = 0
                INNER JOIN dbo.AccessRuleActor ara
                    ON ara.ActorUserID = u.idfUserID
                       AND ara.intRowStatus = 0
                INNER JOIN dbo.AccessRule a
                    ON a.AccessRuleID = ara.AccessRuleID
                       AND a.intRowStatus = 0
                       AND a.DefaultRuleIndicator = 0
            WHERE h.idfHumanCase = @RecordID
                  AND a.GrantingActorSiteID = h.idfsSite;

        -- =======================================================================================
        -- SITE FILTRATION RULES
        --
        -- Apply site filtration rules from use case SAUC29.
        -- =======================================================================================
        -- 
        -- Apply level 0 site filtration rules for the employee default user group - Denies ONLY
        -- as all records have been pulled above with or without site filtration rules applied.
        --
        DELETE FROM @Results
        WHERE EXISTS
        (
            SELECT hc.idfHumanCase
            FROM dbo.tlbHumanCase hc
                INNER JOIN dbo.tstObjectAccess oa
                    ON oa.idfsObjectID = hc.idfsSite
                       AND oa.intRowStatus = 0
                INNER JOIN dbo.tlbEmployeeGroup eg
                    ON eg.idfsSite = @UserSiteID
                       AND eg.intRowStatus = 0
                INNER JOIN dbo.trtBaseReference br
                    ON br.idfsBaseReference = eg.idfEmployeeGroup
                       AND br.intRowStatus = 0
                       AND br.blnSystem = 1
            WHERE hc.idfHumanCase = @RecordID
                  AND oa.idfsObjectOperation = 10059003 -- Read permission
                  AND oa.intPermission = 1 -- Deny permission
                  AND oa.idfsObjectType = 10060011 -- Site
                  AND oa.idfActor = eg.idfEmployeeGroup
        );

        --
        -- Apply level 1 site filtration rules for an employee's associated user group(s).  
        -- Allows and denies will supersede level 0.
        --
        INSERT INTO @Results
        SELECT hc.idfHumanCase,
               (
                   SELECT Permission
                   FROM @UserGroupSitePermissions
                   WHERE SiteID = hc.idfsSite
                         AND PermissionTypeID = 10059003
               ),
               (
                   SELECT Permission
                   FROM @UserGroupSitePermissions
                   WHERE SiteID = hc.idfsSite
                         AND PermissionTypeID = 10059006
               ),
               (
                   SELECT Permission
                   FROM @UserGroupSitePermissions
                   WHERE SiteID = hc.idfsSite
                         AND PermissionTypeID = 10059007
               ),
               (
                   SELECT Permission
                   FROM @UserGroupSitePermissions
                   WHERE SiteID = hc.idfsSite
                         AND PermissionTypeID = 10059004
               ),
               (
                   SELECT Permission
                   FROM @UserGroupSitePermissions
                   WHERE SiteID = hc.idfsSite
                         AND PermissionTypeID = 10059002
               )
        FROM dbo.tlbHumanCase hc
        WHERE hc.idfHumanCase = @RecordID
              AND EXISTS
        (
            SELECT * FROM @UserGroupSitePermissions WHERE SiteID = hc.idfsSite
        );

        DELETE res
        FROM @Results res
            INNER JOIN dbo.tlbHumanCase hc
                ON hc.idfHumanCase = res.ID
            INNER JOIN @UserGroupSitePermissions ugsp
                ON ugsp.SiteID = hc.idfsSite
        WHERE ugsp.Permission = 2 -- Deny permission
              AND ugsp.PermissionTypeID = 10059003; -- Read permission

        --
        -- Apply level 2 site filtration rules for the employee's identity.  Allows and denies 
        -- will supersede level 1.
        --
        INSERT INTO @Results
        SELECT hc.idfHumanCase,
               (
                   SELECT Permission
                   FROM @UserSitePermissions
                   WHERE SiteID = hc.idfsSite
                         AND PermissionTypeID = 10059003
               ),
               (
                   SELECT Permission
                   FROM @UserSitePermissions
                   WHERE SiteID = hc.idfsSite
                         AND PermissionTypeID = 10059006
               ),
               (
                   SELECT Permission
                   FROM @UserSitePermissions
                   WHERE SiteID = hc.idfsSite
                         AND PermissionTypeID = 10059007
               ),
               (
                   SELECT Permission
                   FROM @UserSitePermissions
                   WHERE SiteID = hc.idfsSite
                         AND PermissionTypeID = 10059004
               ),
               (
                   SELECT Permission
                   FROM @UserSitePermissions
                   WHERE SiteID = hc.idfsSite
                         AND PermissionTypeID = 10059002
               )
        FROM dbo.tlbHumanCase hc
        WHERE hc.idfHumanCase = @RecordID
              AND EXISTS
        (
            SELECT * FROM @UserSitePermissions WHERE SiteID = hc.idfsSite
        );

        DELETE FROM @Results
        WHERE EXISTS
        (
            SELECT hc.idfHumanCase
            FROM dbo.tlbHumanCase hc
                INNER JOIN @UserSitePermissions usp
                    ON usp.SiteID = hc.idfsSite
            WHERE usp.Permission = 4 -- Deny permission
                  AND usp.PermissionTypeID = 10059003 -- Read permission
        );
        END
        ELSE
        BEGIN
            INSERT INTO @Results 
            SELECT @RecordID, 
                   1,
                   1,
                   1,
                   1,
                   1;
        END

        -- Copy filtered results to final results
        INSERT INTO @FinalResults
        SELECT ID,
               MAX(res.ReadPermissionIndicator),
               MAX(res.AccessToPersonalDataPermissionIndicator),
               MAX(res.AccessToGenderAndAgeDataPermissionIndicator),
               MAX(res.WritePermissionIndicator),
               MAX(res.DeletePermissionIndicator)
        FROM @Results res
        GROUP BY ID;

        SELECT @RecordID AS RecordID,
               @SiteID AS SiteID,
               CASE
                   WHEN ReadPermissionIndicator = 5 THEN
                       CONVERT(BIT, 1)
                   WHEN ReadPermissionIndicator = 4 THEN
                       CONVERT(BIT, 0)
                   WHEN ReadPermissionIndicator = 3 THEN
                       CONVERT(BIT, 1)
                   WHEN ReadPermissionIndicator = 2 THEN
                       CONVERT(BIT, 0)
                   ELSE
                       CONVERT(BIT, ReadPermissionIndicator)
               END AS ReadPermissionindicator,
               CASE
                   WHEN AccessToPersonalDataPermissionIndicator = 5 THEN
                       CONVERT(BIT, 1)
                   WHEN AccessToPersonalDataPermissionIndicator = 4 THEN
                       CONVERT(BIT, 0)
                   WHEN AccessToPersonalDataPermissionIndicator = 3 THEN
                       CONVERT(BIT, 1)
                   WHEN AccessToPersonalDataPermissionIndicator = 2 THEN
                       CONVERT(BIT, 0)
                   ELSE
                       CONVERT(BIT, AccessToPersonalDataPermissionIndicator)
               END AS AccessToPersonalDataPermissionIndicator,
               CASE
                   WHEN AccessToGenderAndAgeDataPermissionIndicator = 5 THEN
                       CONVERT(BIT, 1)
                   WHEN AccessToGenderAndAgeDataPermissionIndicator = 4 THEN
                       CONVERT(BIT, 0)
                   WHEN AccessToGenderAndAgeDataPermissionIndicator = 3 THEN
                       CONVERT(BIT, 1)
                   WHEN AccessToGenderAndAgeDataPermissionIndicator = 2 THEN
                       CONVERT(BIT, 0)
                   ELSE
                       CONVERT(BIT, AccessToGenderAndAgeDataPermissionIndicator)
               END AS AccessToGenderAndAgeDataPermissionIndicator,
               CASE
                   WHEN WritePermissionIndicator = 5 THEN
                       CONVERT(BIT, 1)
                   WHEN WritePermissionIndicator = 4 THEN
                       CONVERT(BIT, 0)
                   WHEN WritePermissionIndicator = 3 THEN
                       CONVERT(BIT, 1)
                   WHEN WritePermissionIndicator = 2 THEN
                       CONVERT(BIT, 0)
                   ELSE
                       CONVERT(BIT, WritePermissionIndicator)
               END AS WritePermissionIndicator,
               CASE
                   WHEN DeletePermissionIndicator = 5 THEN
                       CONVERT(BIT, 1)
                   WHEN DeletePermissionIndicator = 4 THEN
                       CONVERT(BIT, 0)
                   WHEN DeletePermissionIndicator = 3 THEN
                       CONVERT(BIT, 1)
                   WHEN DeletePermissionIndicator = 2 THEN
                       CONVERT(BIT, 0)
                   ELSE
                       CONVERT(BIT, DeletePermissionIndicator)
               END AS DeletePermissionIndicator
        FROM @FinalResults res;
    END TRY
    BEGIN CATCH
        SET @ReturnCode = ERROR_NUMBER();
        SET @ReturnMessage = ERROR_MESSAGE();

        THROW;
    END CATCH
END
GO
