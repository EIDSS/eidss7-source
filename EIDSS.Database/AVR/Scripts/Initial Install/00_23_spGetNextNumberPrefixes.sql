/****** Object:  StoredProcedure [dbo].[spGetNextNumberPrefixes]    Script Date: 1/27/2023 7:51:26 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[spGetNextNumberPrefixes]
AS

	
SELECT  
	nn.idfsNumberName,
	nn.strPrefix
FROM 
	dbo.tstNextNumbers nn
	

GO