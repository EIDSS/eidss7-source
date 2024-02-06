-- ================================================================================================
-- Name: USP_ADMIN_OBJECT_ACCESS_GETList
--
-- Description: Gets data for an actor's permissions for diseases for use case SAUC62.
--          
-- Revision History:
-- Name               Date       Change Detail
-- ------------------ ---------- -----------------------------------------------------------------
-- Stephen Long       05/16/2020 Initial release.
-- Ann Xiong          01/28/2021 Modified to INNER JOIN 
--                               dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000060) instead of 
--                               dbo.FN_GBL_ReferenceRepair('en', 19000094) and ON 
--                               oa.idfsObjectType = objectType.idfsReference instead of ON 
--                               oa.idfsObjectID = objectType.idfsReference.
-- Stephen Long       05/15/2021 Added pagination and sorting.
-- Stephen Long       05/28/2021 Removed allow and deny permission indicators and added read 
--                               permission indicator.
-- Stephen Long       12/22/2022 Removed join to trtObjectTypeToObjectOperation.
-- Stephen Long       01/31/2023 Changed to ensure employee groups are active.
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_ADMIN_OBJECT_ACCESS_GETList]
(
    @LanguageID AS NVARCHAR(50),
    @ActorID AS BIGINT = NULL,
    @SiteID AS BIGINT = NULL,
    @ObjectID AS BIGINT = NULL
)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        SELECT oa.idfObjectAccess AS ObjectAccessID,
               oa.idfsObjectType AS ObjectTypeID,
               objectType.name AS ObjectTypeName,
               oa.idfsObjectOperation AS ObjectOperationTypeID,
               objectOperationType.name AS ObjectOperationTypeName,
               idfsObjectID AS ObjectID,
               oa.idfActor AS ActorID,
               oa.idfsOnSite AS SiteID,
               oa.intPermission AS PermissionTypeID,
               CAST(CASE oa.intPermission
                        WHEN 2 THEN
                            1
                        WHEN 1 THEN
                            0
                    END AS BIT) AS ReadPermissionIndicator,
               oa.intRowStatus AS RowStatus,
               'R' AS RowAction
        FROM dbo.tstObjectAccess oa
            INNER JOIN dbo.tlbEmployee e
                ON e.idfEmployee = oa.idfActor
                   AND e.intRowStatus = 0
            LEFT JOIN dbo.tlbEmployeeGroup eg
                ON eg.idfEmployeeGroup = e.idfEmployee
            INNER JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000060) objectType
                ON oa.idfsObjectType = objectType.idfsReference
            INNER JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000059) objectOperationType
                ON oa.idfsObjectOperation = objectOperationType.idfsReference
        WHERE oa.intRowStatus = 0
              AND (
                      (
                          -- User
                          e.idfsEmployeeCategory = 10526001 -- User
                          AND e.idfsEmployeeType = 10023002 -- User
                      )
                      OR (
                             -- User Group
                             e.idfsEmployeeCategory = 10526002 -- User
                             AND e.idfsEmployeeType = 10023001 -- User Group
                             AND eg.intRowStatus = 0
                         )
                  )
              AND (
                      (oa.idfActor = @ActorID)
                      OR (@ActorID IS NULL)
                  )
              AND (
                      (oa.idfsOnSite = @SiteID)
                      OR (@SiteID IS NULL)
                  )
              AND (
                      (oa.idfsObjectID = @ObjectID)
                      OR (@ObjectID IS NULL)
                  );
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH;
END
