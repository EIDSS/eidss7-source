-- ================================================================================================
-- Name: USP_HAS_DISEASE_REPORT_GETList
--
-- Description: Get a list of human disease reports for the Human Active Surveillance module.
--          
-- Revision History:
-- Name				 Date		 Change Detail
-- ----------------	 ----------	 -------------------------------------------------------------------
-- Doug Albanese	 09/28/2022  Initial release.
-- Mike Kornegay	 01/23/2022	 Changed FETCH NEXT to record paging.
--
-- Testing code:
-- EXEC USP_HUM_DISEASE_REPORT_GETList 'en-US'
-- EXEC USP_HUM_DISEASE_REPORT_GETList 'en-US', @EIDSSReportID = 'H'
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_HAS_DISEASE_REPORT_GETList]
   @LanguageID NVARCHAR(50),
   @SessionKey BIGINT = NULL,
   @ApplySiteFiltrationIndicator BIT = 0,
   @UserSiteID BIGINT,
   @UserOrganizationID BIGINT,
   @UserEmployeeID BIGINT,
   @SortColumn NVARCHAR(30) = 'ReportID',
   @SortOrder NVARCHAR(4) = 'DESC',
   @Page INT = 1,
   @PageSize INT = 10
AS
BEGIN
    SET NOCOUNT ON;

	DECLARE @firstRec INT;
    DECLARE @lastRec INT;
    SET @firstRec = (@Page - 1) * @PageSize
    SET @lastRec = (@Page * @PageSize + 1);

    DECLARE @AdministrativeLevelNode AS HIERARCHYID,
            @LocationOfExposureLevelNode AS HIERARCHYID;
    DECLARE @Results TABLE
    (
        ID BIGINT NOT NULL,
        ReadPermissionIndicator BIT NOT NULL,
        AccessToPersonalDataPermissionIndicator BIT NOT NULL,
        AccessToGenderAndAgeDataPermissionIndicator BIT NOT NULL,
        WritePermissionIndicator BIT NOT NULL,
        DeletePermissionIndicator BIT NOT NULL, INDEX IDX_ID (ID)
   );

    DECLARE @FinalResults TABLE
    (
        ID BIGINT NOT NULL,
        ReadPermissionIndicator BIT NOT NULL,
        AccessToPersonalDataPermissionIndicator BIT NOT NULL,
        AccessToGenderAndAgeDataPermissionIndicator BIT NOT NULL,
        WritePermissionIndicator BIT NOT NULL,
        DeletePermissionIndicator BIT NOT NULL
    );

    BEGIN TRY
        IF @PageSize = 0
        BEGIN
            SET @PageSize = 1;
        END

        -- ========================================================================================
        -- NO SITE FILTRATION RULES APPLIED
        --
        -- For first and second level sites, do not apply any site filtration rules.
        -- ========================================================================================
        IF @ApplySiteFiltrationIndicator = 0
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
   --------------------------------------------------------------------------------------------------------------------
				   LEFT JOIN dbo.gisLocationDenormalized g
					   ON g.idfsLocation = currentAddress.idfsLocation
				   LEFT JOIN dbo.tlbMaterial m
					   ON m.idfHumanCase = hc.idfHumanCase
						  AND m.intRowStatus = 0
				   LEFT JOIN dbo.tlbGeoLocation exposure
					   ON exposure.idfGeoLocation = hc.idfPointGeoLocation
				   LEFT JOIN dbo.gisLocationDenormalized gExposure
					   ON gExposure.idfsLocation = exposure.idfsLocation
			   WHERE hc.intRowStatus = 0
					 AND hc.idfsFinalDiagnosis IS NOT NULL
					 AND (
							 hc.idfParentMonitoringSession = @SessionKey
							 OR @SessionKey IS NULL
						 )
			   GROUP BY hc.idfHumanCase
			   OPTION (RECOMPILE);
		   END
        ELSE
		   BEGIN -- Site Filtration
			   
			   INSERT INTO @Results
			   SELECT hc.idfHumanCase,
				  1,
				  1,
				  1,
				  1,
				  1
			   FROM dbo.tlbHumanCase hc
			   INNER JOIN dbo.tlbHuman h ON h.idfHuman = hc.idfHuman AND h.intRowStatus = 0
			   INNER JOIN dbo.tlbGeoLocation currentAddress ON currentAddress.idfGeoLocation = h.idfCurrentResidenceAddress
			   LEFT JOIN dbo.gisLocationDenormalized g ON g.idfsLocation = currentAddress.idfsLocation
			   LEFT JOIN dbo.tlbMaterial m ON m.idfHumanCase = hc.idfHumanCase AND m.intRowStatus = 0
			   LEFT JOIN dbo.tlbGeoLocation exposure ON exposure.idfGeoLocation = hc.idfPointGeoLocation
			   LEFT JOIN dbo.gisLocationDenormalized gExposure ON gExposure.idfsLocation = exposure.idfsLocation
            
			   WHERE hc.intRowStatus = 0
			   AND hc.idfsSite = @UserSiteID
			   AND hc.idfsFinalDiagnosis IS NOT NULL
			   AND (hc.idfParentMonitoringSession = @SessionKey OR @SessionKey IS NULL)
			   GROUP BY hc.idfHumanCase
			   OPTION (RECOMPILE);

			   DECLARE @FilteredResults TABLE
			   (
				   ID BIGINT NOT NULL,
				   ReadPermissionIndicator BIT NOT NULL,
				   AccessToPersonalDataPermissionIndicator BIT NOT NULL,
				   AccessToGenderAndAgeDataPermissionIndicator BIT NOT NULL,
				   WritePermissionIndicator BIT NOT NULL,
				   DeletePermissionIndicator BIT NOT NULL, INDEX IDX_ID (ID)
			   );

			   -- =======================================================================================
			   -- DEFAULT SITE FILTRATION RULES
			   --
			   -- Apply active default site filtration rules for third level sites.
			   -- =======================================================================================
			   DECLARE @RuleActiveStatus INT = 0;
			   DECLARE @AdministrativeLevelTypeID INT;
			   DECLARE @OrganizationAdministrativeLevelNode HIERARCHYID;
			   DECLARE @DefaultAccessRules AS TABLE
			   (
				   AccessRuleID BIGINT NOT NULL,
				   ActiveIndicator INT NOT NULL,
				   ReadPermissionIndicator BIT NOT NULL,
				   AccessToPersonalDataPermissionIndicator BIT NOT NULL,
				   AccessToGenderAndAgeDataPermissionIndicator BIT NOT NULL,
				   WritePermissionIndicator BIT NOT NULL,
				   DeletePermissionIndicator BIT NOT NULL,
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
				
				   SELECT @AdministrativeLevelNode = g.node.GetAncestor(g.node.GetLevel() - @AdministrativeLevelTypeID)
				   FROM dbo.tlbOffice o
					   INNER JOIN dbo.tlbGeoLocationShared AS l
						   ON l.idfGeoLocationShared = o.idfLocation
					   INNER JOIN dbo.gisLocationDenormalized g
						   ON g.idfsLocation = l.idfsLocation
				   WHERE o.idfOffice = @UserOrganizationID

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
					   INNER JOIN dbo.gisLocationDenormalized g ON g.idfsLocation = l.idfsLocation
					   INNER JOIN @DefaultAccessRules a
						   ON a.AccessRuleID = 10537000
				   WHERE h.intRowStatus = 0 and h.idfParentMonitoringSession = @SessionKey

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
					   INNER JOIN @DefaultAccessRules a
						   ON a.AccessRuleID = 10537000
				   WHERE h.intRowStatus = 0 and h.idfParentMonitoringSession = @SessionKey

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
					   INNER JOIN @DefaultAccessRules a
						   ON a.AccessRuleID = 10537000
				   WHERE h.intRowStatus = 0 and h.idfParentMonitoringSession = @SessionKey
				  
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

            -- Report data shall be available to the sites with the connected outbreak, if the report 
            -- is the primary report/session for an outbreak.
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
            -- CONFIGURABLE SITE FILTRATION RULES
            -- 
            -- Apply configurable site filtration rules for use case SAUC34. Some of these rules may 
            -- overlap the default rules.
            -- =======================================================================================
            -- Apply at the user's site group level, granted by a site group.
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

            -- Apply at the user's site level, granted by a site group.
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

            -- Apply at the user's employee group level, granted by a site group.
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

            -- Apply at the user's ID level, granted by a site group.
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

            -- Apply at the user's site group level, granted by a site.
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

            -- Apply at the user's site level, granted by a site.
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

            -- Apply at the user's employee group level, granted by a site.
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

            -- Apply at the user's ID level, granted by a site.
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
                LEFT JOIN dbo.tlbMaterial m
                    ON m.idfHumanCase = hc.idfHumanCase
                       AND m.intRowStatus = 0
                LEFT JOIN dbo.tlbGeoLocation exposure
                    ON exposure.idfGeoLocation = hc.idfPointGeoLocation
                LEFT JOIN dbo.gisLocationDenormalized gExposure
                    ON gExposure.idfsLocation = exposure.idfsLocation
            WHERE hc.intRowStatus = 0
                  AND hc.idfsFinalDiagnosis IS NOT NULL
                  AND (
                          hc.idfParentMonitoringSession = @SessionKey
                          OR @SessionKey IS NULL
                      )
            GROUP BY ID,
                     ReadPermissionIndicator,
                     AccessToPersonalDataPermissionIndicator,
                     AccessToGenderAndAgeDataPermissionIndicator,
                     WritePermissionIndicator,
                     DeletePermissionIndicator
            OPTION (RECOMPILE);
			
        END;


        -- =======================================================================================
        -- Remove "Outbreak" tied disease reports, if filtering is needed
        -- =======================================================================================
        --IF @FilterOutbreakTiedReports = 1
        --BEGIN
        --    DELETE I
        --    FROM @Results I
        --        INNER JOIN dbo.tlbHumanCase hc
        --            ON hc.idfHumanCase = I.ID
        --    WHERE hc.idfOutbreak IS NOT NULL;
        --END;

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
        WHERE EXISTS
        (
            SELECT h.idfHumanCase
            FROM dbo.tlbHumanCase h
                INNER JOIN dbo.tstObjectAccess oa
                    ON oa.idfsObjectID = h.idfsFinalDiagnosis
                       AND oa.intRowStatus = 0
            WHERE oa.intPermission = 1
                  AND oa.idfsObjectType = 10060001 -- Disease
                  AND oa.idfActor = -506 -- Default role
        );

        -- Apply level 1 disease filtration rules for an employee's associated user group(s).  
        -- Allows and denies will supersede level 0.
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
            INNER JOIN dbo.tlbHuman h
                ON h.idfHuman = hc.idfHuman
                   AND h.intRowStatus = 0
            INNER JOIN dbo.tlbGeoLocation currentAddress
                ON currentAddress.idfGeoLocation = h.idfCurrentResidenceAddress
            LEFT JOIN dbo.gisLocationDenormalized g
                ON g.idfsLocation = currentAddress.idfsLocation
            LEFT JOIN dbo.tlbMaterial m
                ON m.idfHumanCase = hc.idfHumanCase
                   AND m.intRowStatus = 0
            LEFT JOIN dbo.tlbGeoLocation exposure
                ON exposure.idfGeoLocation = hc.idfPointGeoLocation
            LEFT JOIN dbo.gisLocationDenormalized gExposure
                ON gExposure.idfsLocation = exposure.idfsLocation
        WHERE oa.intPermission = 2 -- Allow permission
              AND hc.intRowStatus = 0
              AND oa.idfsObjectType = 10060001 -- Disease
              AND oa.idfActor = egm.idfEmployeeGroup
              AND hc.idfsFinalDiagnosis IS NOT NULL
              AND (
                      hc.idfParentMonitoringSession = @SessionKey
                      OR @SessionKey IS NULL
                  )
        GROUP BY hc.idfHumanCase
        OPTION (RECOMPILE);

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
        WHERE oa.intPermission = 1
              AND oa.idfsObjectType = 10060001 -- Disease
              AND oa.idfActor = egm.idfEmployeeGroup;

        -- Apply level 2 disease filtration rules for the employee's identity.  Allows and denies 
        -- will supersede level 1.
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
            INNER JOIN dbo.tlbHuman h
                ON h.idfHuman = hc.idfHuman
                   AND h.intRowStatus = 0
            INNER JOIN dbo.tlbGeoLocation currentAddress
                ON currentAddress.idfGeoLocation = h.idfCurrentResidenceAddress
            LEFT JOIN dbo.gisLocationDenormalized g
                ON g.idfsLocation = currentAddress.idfsLocation
            LEFT JOIN dbo.tlbMaterial m
                ON m.idfHumanCase = hc.idfHumanCase
                   AND m.intRowStatus = 0
            LEFT JOIN dbo.tlbGeoLocation exposure
                ON exposure.idfGeoLocation = hc.idfPointGeoLocation
            LEFT JOIN dbo.gisLocationDenormalized gExposure
                ON gExposure.idfsLocation = exposure.idfsLocation
        WHERE oa.intPermission = 2 -- Allow permission
              AND hc.intRowStatus = 0
              AND oa.idfsObjectType = 10060001 -- Disease
              AND oa.idfActor = @UserEmployeeID
              AND hc.idfsFinalDiagnosis IS NOT NULL
              AND (
                      hc.idfParentMonitoringSession = @SessionKey
                      OR @SessionKey IS NULL
                  )
        GROUP BY hc.idfHumanCase
        OPTION (RECOMPILE);

        DELETE FROM @Results
        WHERE EXISTS
        (
            SELECT hc.idfHumanCase
            FROM dbo.tlbHumanCase hc
                INNER JOIN dbo.tstObjectAccess oa
                    ON oa.idfsObjectID = hc.idfsFinalDiagnosis
                       AND oa.intRowStatus = 0
            WHERE intPermission = 1 -- Deny permission
                  AND oa.idfsObjectType = 10060001 -- Disease
                  AND idfActor = @UserEmployeeID
        );
		
        -- ========================================================================================
        -- FINAL QUERY, PAGINATION AND COUNTS
        -- ========================================================================================
        INSERT INTO @FinalResults
        SELECT ID,
               ReadPermissionIndicator,
               AccessToPersonalDataPermissionIndicator,
               AccessToGenderAndAgeDataPermissionIndicator,
               WritePermissionIndicator,
               DeletePermissionIndicator
        FROM @Results res
        WHERE res.ReadPermissionIndicator = 1
        GROUP BY ID,
                 ReadPermissionIndicator,
                 AccessToPersonalDataPermissionIndicator,
                 AccessToGenderAndAgeDataPermissionIndicator,
                 WritePermissionIndicator,
                 DeletePermissionIndicator;

		
     --   WITH paging
     --   AS (SELECT ID,
     --              c = COUNT(*) OVER ()
     --       FROM @FinalResults res
     --           INNER JOIN dbo.tlbHumanCase hc
     --               ON hc.idfHumanCase = res.ID
     --           INNER JOIN dbo.tlbHuman h
     --               ON h.idfHuman = hc.idfHuman
     --                  AND h.intRowStatus = 0
     --           LEFT JOIN dbo.tlbGeoLocation gl
     --               ON gl.idfGeoLocation = h.idfCurrentResidenceAddress
     --           LEFT JOIN dbo.gisLocation g
     --               ON g.idfsLocation = gl.idfsLocation
     --           LEFT JOIN FN_GBL_LocationHierarchy_Flattened(@LanguageID) LH
     --               ON LH.idfsLocation = gl.idfsLocation
     --           LEFT JOIN dbo.FN_GBL_Repair(@LanguageID, 19000019) disease
     --               ON disease.idfsReference = hc.idfsFinalDiagnosis
     --           LEFT JOIN dbo.FN_GBL_Repair(@LanguageID, 19000011) finalClassification
     --               ON finalClassification.idfsReference = hc.idfsFinalCaseStatus
     --           LEFT JOIN dbo.FN_GBL_Repair(@LanguageID, 19000111) reportStatus
     --               ON reportStatus.idfsReference = hc.idfsCaseProgressStatus
     --       ORDER BY CASE
     --                    WHEN @SortColumn = 'ReportID'
     --                         AND @SortOrder = 'ASC' THEN
     --                        hc.strCaseID
     --                END ASC,
     --                CASE
     --                    WHEN @SortColumn = 'ReportID'
     --                         AND @SortOrder = 'DESC' THEN
     --                        hc.strCaseID
     --                END DESC,
     --                CASE
     --                    WHEN @SortColumn = 'EnteredDate'
     --                         AND @SortOrder = 'ASC' THEN
     --                        hc.datEnteredDate
     --                END ASC,
     --                CASE
     --                    WHEN @SortColumn = 'EnteredDate'
     --                         AND @SortOrder = 'DESC' THEN
     --                        hc.datEnteredDate
     --                END DESC,
     --                CASE
     --                    WHEN @SortColumn = 'DiseaseName'
     --                         AND @SortOrder = 'ASC' THEN
     --                        disease.name
     --                END ASC,
     --                CASE
     --                    WHEN @SortColumn = 'DiseaseName'
     --                         AND @SortOrder = 'DESC' THEN
     --                        disease.name
     --                END DESC,
     --                CASE
     --                    WHEN @SortColumn = 'PersonLocation'
     --                         AND @SortOrder = 'ASC' THEN
     --                (LH.AdminLevel1Name + ', ' + LH.AdminLevel2Name)
     --                END ASC,
     --                CASE
     --                    WHEN @SortColumn = 'PersonLocation'
     --                         AND @SortOrder = 'DESC' THEN
     --                (LH.AdminLevel1Name + ', ' + LH.AdminLevel2Name)
     --                END DESC,
     --                CASE
     --                    WHEN @SortColumn = 'ClassificationTypeName'
     --                         AND @SortOrder = 'ASC' THEN
     --                        finalClassification.name
     --                END ASC,
     --                CASE
     --                    WHEN @SortColumn = 'ClassificationTypeName'
     --                         AND @SortOrder = 'DESC' THEN
     --                        finalClassification.name
					--END DESC
					--OFFSET CAST((@PageSize * (@Page - 1)) AS INT) ROWS FETCH NEXT CAST(@PageSize AS INT) ROWS ONLY)
     --   SELECT res.ID AS ReportKey,
     --          hc.strCaseId AS ReportID,
     --          ISNULL(finalClassification.name, initialClassification.name) AS ClassificationTypeName,
     --          disease.Name AS DiseaseName,
     --          ISNULL(LH.AdminLevel1Name, '') + IIF(LH.AdminLevel2Name IS NULL, '', ', ')
     --          + ISNULL(LH.AdminLevel2Name, '') AS PersonLocation,
     --          res.AccessToPersonalDataPermissionIndicator,
     --          res.AccessToGenderAndAgeDataPermissionIndicator,
     --          res.WritePermissionIndicator,
     --          res.DeletePermissionIndicator,
     --          c AS RecordCount,
     --          (
     --              SELECT COUNT(*) FROM dbo.tlbHumanCase hc WHERE hc.intRowStatus = 0
     --          ) AS TotalCount,
     --          TotalPages = (c / @PageSize) + IIF(c % @PageSize > 0, 1, 0),
     --          CurrentPage = @Page
     --   FROM @FinalResults res
     --       INNER JOIN paging
     --           ON paging.ID = res.ID
     --       INNER JOIN dbo.tlbHumanCase hc
     --           ON hc.idfHumanCase = res.ID
     --       INNER JOIN dbo.tlbHuman h
     --           ON h.idfHuman = hc.idfHuman
     --              AND h.intRowStatus = 0
     --       INNER JOIN dbo.tlbHumanActual ha
     --           ON ha.idfHumanActual = h.idfHumanActual
     --              AND ha.intRowStatus = 0
     --       LEFT JOIN dbo.tlbGeoLocation gl
     --           ON gl.idfGeoLocation = h.idfCurrentResidenceAddress
     --       LEFT JOIN dbo.gisLocation g
     --           ON g.idfsLocation = gl.idfsLocation
     --       LEFT JOIN FN_GBL_LocationHierarchy_Flattened(@LanguageID) LH
     --           ON LH.idfsLocation = gl.idfsLocation
     --       LEFT JOIN dbo.HumanActualAddlInfo haai
     --           ON haai.HumanActualAddlInfoUID = ha.idfHumanActual
     --              AND haai.intRowStatus = 0
     --       LEFT JOIN dbo.FN_GBL_Repair(@LanguageID, 19000019) disease
     --           ON disease.idfsReference = hc.idfsFinalDiagnosis
     --       LEFT JOIN dbo.FN_GBL_Repair(@LanguageID, 19000011) initialClassification
     --           ON initialClassification.idfsReference = hc.idfsInitialCaseStatus
     --       LEFT JOIN dbo.FN_GBL_Repair(@LanguageID, 19000011) finalClassification
     --           ON finalClassification.idfsReference = hc.idfsFinalCaseStatus
     --       LEFT JOIN dbo.tlbPerson p
     --           ON p.idfPerson = hc.idfPersonEnteredBy
     --              AND p.intRowStatus = 0
     --   OPTION (RECOMPILE);

	    WITH paging
        AS (SELECT ROW_NUMBER() OVER (
		    ORDER BY CASE
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
					END DESC
		) AS ROWNUM,
        COUNT(*) OVER () AS RecordCount,
		res.ID AS ReportKey,
        hc.strCaseId AS ReportID,
		hc.datEnteredDate as EnteredDate,
        ISNULL(finalClassification.name, initialClassification.name) AS ClassificationTypeName,
        disease.Name AS DiseaseName,
        ISNULL(LH.AdminLevel1Name, '') + IIF(LH.AdminLevel2Name IS NULL, '', ', ')
        + ISNULL(LH.AdminLevel2Name, '') AS PersonLocation,
        res.AccessToPersonalDataPermissionIndicator AS AccessToPersonalDataPermissionIndicator,
        res.AccessToGenderAndAgeDataPermissionIndicator AS AccessToGenderAndAgeDataPermissionIndicator,
        res.WritePermissionIndicator AS WritePermissionIndicator,
        res.DeletePermissionIndicator AS DeletePermissionIndicator,
        (
            SELECT COUNT(*) FROM dbo.tlbHumanCase hc WHERE hc.intRowStatus = 0
        ) AS TotalCount
        FROM @FinalResults res
                INNER JOIN dbo.tlbHumanCase hc
                    ON hc.idfHumanCase = res.ID
                INNER JOIN dbo.tlbHuman h
                    ON h.idfHuman = hc.idfHuman
                       AND h.intRowStatus = 0
                LEFT JOIN dbo.tlbGeoLocation gl
                    ON gl.idfGeoLocation = h.idfCurrentResidenceAddress
                LEFT JOIN dbo.gisLocation g
                    ON g.idfsLocation = gl.idfsLocation
                LEFT JOIN FN_GBL_LocationHierarchy_Flattened(@LanguageID) LH
                    ON LH.idfsLocation = gl.idfsLocation
                LEFT JOIN dbo.FN_GBL_Repair(@LanguageID, 19000019) disease
                    ON disease.idfsReference = hc.idfsFinalDiagnosis
				LEFT JOIN dbo.FN_GBL_Repair(@LanguageID, 19000011) initialClassification
					ON initialClassification.idfsReference = hc.idfsInitialCaseStatus
				LEFT JOIN dbo.FN_GBL_Repair(@LanguageID, 19000011) finalClassification
                    ON finalClassification.idfsReference = hc.idfsFinalCaseStatus
                LEFT JOIN dbo.FN_GBL_Repair(@LanguageID, 19000111) reportStatus
                    ON reportStatus.idfsReference = hc.idfsCaseProgressStatus
		)
        SELECT ReportKey,
               ReportID,
			   EnteredDate,
               ClassificationTypeName,
               DiseaseName,
               PersonLocation,
               AccessToPersonalDataPermissionIndicator,
               AccessToGenderAndAgeDataPermissionIndicator,
               WritePermissionIndicator,
               DeletePermissionIndicator,
               RecordCount,
               (
                   SELECT COUNT(*) FROM dbo.tlbHumanCase hc WHERE hc.intRowStatus = 0
               ) AS TotalCount,
               TotalPages = (RecordCount / @PageSize) + IIF(RecordCount % @PageSize > 0, 1, 0),
               CurrentPage = @Page
        FROM paging
		WHERE RowNum > @firstRec
            AND RowNum < @lastRec
		ORDER BY CASE
						WHEN @SortColumn = 'ReportID'
							AND @SortOrder = 'ASC' THEN
							ReportID
					END ASC,
					CASE
						WHEN @SortColumn = 'ReportID'
							AND @SortOrder = 'DESC' THEN
							ReportID
					END DESC,
					CASE
						WHEN @SortColumn = 'EnteredDate'
							AND @SortOrder = 'ASC' THEN
							EnteredDate
					END ASC,
					CASE
						WHEN @SortColumn = 'EnteredDate'
							AND @SortOrder = 'DESC' THEN
							EnteredDate
					END DESC,
					CASE
						WHEN @SortColumn = 'DiseaseName'
							AND @SortOrder = 'ASC' THEN
							DiseaseName
					END ASC,
					CASE
						WHEN @SortColumn = 'DiseaseName'
							AND @SortOrder = 'DESC' THEN
							DiseaseName
					END DESC,
					CASE
						WHEN @SortColumn = 'PersonLocation'
							AND @SortOrder = 'ASC' THEN
							PersonLocation
					END ASC,
					CASE
						WHEN @SortColumn = 'PersonLocation'
							AND @SortOrder = 'DESC' THEN
							PersonLocation
					END DESC,
					CASE
						WHEN @SortColumn = 'ClassificationTypeName'
							AND @SortOrder = 'ASC' THEN
							ClassificationTypeName
					END ASC,
					CASE
						WHEN @SortColumn = 'ClassificationTypeName'
							AND @SortOrder = 'DESC' THEN
							ClassificationTypeName
				END DESC

   

    END TRY
    BEGIN CATCH
        THROW;
    END CATCH;
END
