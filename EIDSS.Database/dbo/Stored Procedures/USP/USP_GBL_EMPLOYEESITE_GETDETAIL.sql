--   ==================================================================================================--
--    Name: USP_GBL_EMPLOYEESITE_GETDETAIL
--    Description: Input: personid, languageid; Output: person list, group list
--          
--    Author: Ricky Moss
--
--    Revision History
--    Name            Date            Change Detail
--    Ricky Moss        11/14/2019        Initial Release
--  Ricky Moss        01/15/2020        Updated strAccountName field to use aspnetuser UserName field
--    Ricky Moss        01/28/2020        Added strIdentity field
--    Ann Xiong         09/24/2020        Added Locked, blnDisabled, strDisabledReason, strLockoutReason to the select
--    Ann Xiong         09/29/2020        Added UserGroupID and UserGroup to the select
--  Mani Govindarajan 10/18/2022    used SecurityPolicyConfiguration table to get passwordAge and lockTreshold.



--    exec USP_GBL_EMPLOYEESITE_GETDETAIL -447, 'en'
--====================================================================================================



--IF OBJECT_ID('[dbo].[USP_GBL_EMPLOYEESITE_GETDETAIL]', 'P') IS NOT NULL
--DROP PROC [dbo].[USP_GBL_EMPLOYEESITE_GETDETAIL]
--GO



--IF EXISTS ( SELECT *
--            FROM   sysobjects
--            WHERE  id = object_id(N'[dbo].[USP_GBL_EMPLOYEESITE_GETDETAIL]')
--                   and OBJECTPROPERTY(id, N'IsProcedure') = 1 )
--BEGIN
--    DROP PROCEDURE [dbo].[USP_GBL_EMPLOYEESITE_GETDETAIL]
--END
--GO
CREATE PROCEDURE [dbo].[USP_GBL_EMPLOYEESITE_GETDETAIL]
(
    @idfPerson AS BIGINT, --##PARAM @idfPerson - person ID
    @LangID NVARCHAR(50) --##PARAM @LangID - language ID
)
AS
BEGIN
    BEGIN TRY        



       DECLARE @lockTreshold int  
        DECLARE @passwordAge int  
        --SELECT @lockTreshold = intAccountTryCount, @passwordAge = intPasswordAge from dbo.fnPolicyValue()  



       select  @lockTreshold=LockoutThld ,  @passwordAge=MinPasswordAgeDays from SecurityPolicyConfiguration



       SELECT    UT.idfUserID,
                CAST(u.Id AS NVARCHAR(100)) as strIdentity,
                UT.idfPerson,
                UT.idfsSite,
                u.UserName as strAccountName,
                S.strSiteID,
                S.strSiteName,
                S.idfsSiteType,
                ISNULL(Rf.name, Rf.strDefault) AS strSiteType
                ,CASE WHEN u.LockoutEnabled = 1 and u.LockoutEnd IS Not NULL THEN 1 ELSE 0 END AS Locked
                ,u.blnDisabled
                ,u.strDisabledReason
                ,CASE    WHEN (u.LockoutEnabled = 1 and u.LockoutEnd IS Not NULL) AND (u.AccessFailedCount >= @lockTreshold ) THEN 'Locked'
                        WHEN (u.LockoutEnabled = 1 and u.LockoutEnd IS Not NULL) AND (datediff(d,isnull(u.datPasswordLastChanged,'2000-01-01T00:00:00'),getutcdate()) >= @passwordAge ) THEN 'Account is Locked'
                        WHEN (u.LockoutEnabled = 1 and u.LockoutEnd IS NULL) OR (u.LockoutEnabled = 0 ) THEN ''
                END AS 'strLockoutReason'
                ,STRING_AGG(g.idfEmployeeGroup, ', ') WITHIN GROUP (ORDER BY g.idfEmployeeGroup DESC ) AS UserGroupID
                ,STRING_AGG(g.strName, ', ') as UserGroup
                ,u.PasswordResetRequired
                ,u.DateDisabled
        FROM    dbo.tstUserTable UT
                INNER JOIN dbo.tstSite S ON
                    S.idfsSite = UT.idfsSite And S.intRowStatus = 0
                INNER JOIN AspNetUsers u ON
                    ut.idfUserID = u.idfUserID
                INNER JOIN dbo.fnReference(@LangID, 19000085/*Site Type*/) Rf ON
                    S.idfsSiteType = Rf.idfsReference
                LEFT JOIN    dbo.tlbEmployeeGroupMember m     
                    ON    m.idfEmployee = ut.idfPerson
                    AND    m.intRowStatus = 0
                LEFT JOIN    dbo.tlbEmployeeGroup g
                    ON    m.idfEmployeeGroup = g.idfEmployeeGroup
        WHERE    UT.idfPerson = @idfPerson    
                AND        UT.intRowStatus = 0
        GROUP BY UT.idfUserID, u.Id, UT.idfPerson, UT.idfsSite, u.UserName, S.strSiteID, S.strSiteName, S.idfsSiteType, (ISNULL(Rf.name, Rf.strDefault)),
                (CASE WHEN u.LockoutEnabled = 1 and u.LockoutEnd IS Not NULL THEN 1 ELSE 0 END), u.blnDisabled, u.strDisabledReason,
                (CASE    WHEN (u.LockoutEnabled = 1 and u.LockoutEnd IS Not NULL) AND (u.AccessFailedCount >= @lockTreshold ) THEN 'Locked'
                        WHEN (u.LockoutEnabled = 1 and u.LockoutEnd IS Not NULL) AND (datediff(d,isnull(u.datPasswordLastChanged,'2000-01-01T00:00:00'),getutcdate()) >= @passwordAge ) THEN 'Account is Locked'
                        WHEN (u.LockoutEnabled = 1 and u.LockoutEnd IS NULL) OR (u.LockoutEnabled = 0 ) THEN ''
                END),u.PasswordResetRequired,u.DateDisabled



   END TRY
    BEGIN CATCH
        THROW
    END CATCH
END

