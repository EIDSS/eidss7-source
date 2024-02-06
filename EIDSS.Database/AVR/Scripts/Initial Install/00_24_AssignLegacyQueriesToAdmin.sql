----------------------------------------------------------------------------------
-------------------------------- Begin -------------------------------------------
-- Please change 'administrator' to desired user who should own the legacy queries
declare @userName as nvarchar(256) = N'administrator' -- login user name
declare @idfOffice as bigint = 
( select top 1 
	EmployeeToInstitution.idfInstitution
from 
	EmployeeToInstitution 
	inner join AspNetUsers on EmployeeToInstitution.aspNetUserId = AspNetUsers.Id 
where 
	AspNetUsers.UserName = @userName )
  
declare @idfEmployee as bigint = 
( select top 1
  tlbEmployee.idfEmployee
from 
  AspNetUsers 
  inner join tstUserTable ON AspNetUsers.idfUserID = tstUserTable.idfUserID 
  inner join tlbEmployee ON tstUserTable.idfPerson = tlbEmployee.idfEmployee 
where 
  AspNetUsers.UserName = @userName )

print N'UserName: ' + @userName
print N'idfOffice: ' + cast(@idfOffice as nvarchar(20))
print N'idfEmployee: ' + cast(@idfEmployee as nvarchar(20))

-- Share layouts, update layouts first so we will know which layouts to update
update l
set blnShareLayout = 1 
from tasLayout as l
left join tasQuery as q 
	on q.idflQuery = l.idflQuery
where q.idfEmployee is null and q.idfOffice is null and q.blnReadOnly = 0

-- update queries
update tasQuery 
set 
	idfOffice = @idfOffice,
	idfEmployee = @idfEmployee
where 
	idfOffice is null and idfEmployee is null

--select * from tasQuery
--where idfOffice is null and idfEmployee is null

print N'Legacy AVR custom queries were assigned to: '
print N'UserName: ' + @userName
print N'idfOffice: ' + cast(@idfOffice as nvarchar(20))
print N'idfEmployee: ' + cast(@idfEmployee as nvarchar(20))

-------------------------------- End ---------------------------------------------
----------------------------------------------------------------------------------

GO