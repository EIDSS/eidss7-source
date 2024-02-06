/*
	Mark Wilson
	12/14/2022
	Update menu option for WHO Export
*/
UPDATE [dbo].[LkupEIDSSAppObject] 
SET [strAction]=N'Index', [Controller]=N'WHOExport', [Area]=N'Human' 
WHERE [AppObjectNameID] = 10506022 AND (AppObjectNameID = 10506022)