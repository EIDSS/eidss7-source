 /*
	Mike Kornegay
	12/15/2022
	Update menu option for Security Event Log and System Event Log
*/
UPDATE [dbo].[LkupEIDSSAppObject] 
SET [strAction]=N'Index', [Controller]=N'SecurityEventLog', [Area]=N'Administration', [SubArea]=N'Security' 
WHERE [AppObjectNameID] = 10506062

UPDATE [dbo].[LkupEIDSSAppObject] 
SET [strAction]=N'Index', [Controller]=N'SystemEventLog', [Area]=N'Administration', [SubArea]=N'Security' 
WHERE [AppObjectNameID] = 10506063