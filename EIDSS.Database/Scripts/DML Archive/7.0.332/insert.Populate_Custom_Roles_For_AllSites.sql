
DECLARE @SiteList TABLE (siteId bigint);
DECLARE @siteId bigint;

insert into @SiteList
select idfsSite from tstSite where idfsSite not in (
select   distinct s.idfsSite from tstSite s join  tlbEmployeeGroup eg  on s.idfsSite = eg.idfsSite
join LkupRoleSystemFunctionAccess lr on eg.idfEmployeeGroup=  lr.idfEmployee 
WHERE eg.idfsEmployeeGroupName  BETWEEN -529 AND -501
AND eg.idfsEmployeeGroupName NOT BETWEEN -512 AND -502)


dECLARE db_cursor CURSOR FOR  
SELECT siteId FROM @SiteList
OPEN db_cursor   
FETCH NEXT FROM db_cursor INTO @siteId   

BEGIN TRANSACTION;
WHILE @@FETCH_STATUS = 0   
BEGIN   

       -- PUT YOUR LOGIC HERE
       -- MAKE USE OR VARIABLE @value wich is Data1, Data2, etc...

	   EXEC dbo.USSP_GBL_SITE_CUSTOMUSERGROUP_SET @siteId

       FETCH NEXT FROM db_cursor INTO @siteId   
END   
COMMIT;

CLOSE db_cursor   
DEALLOCATE db_cursor

