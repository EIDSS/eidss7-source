CREATE PROCEDURE [dbo].[spGetNextNumberPrefixes]
AS

	
SELECT  
	nn.idfsNumberName,
	nn.strPrefix
FROM 
	dbo.tstNextNumbers nn
	

GO