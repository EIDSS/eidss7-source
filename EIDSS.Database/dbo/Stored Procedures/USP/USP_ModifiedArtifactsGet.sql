-- =============================================
-- Author:		Steven Verner
-- Create date: 10/27/2020
-- Description:	Fetches modified artifacts
-- =============================================
CREATE PROCEDURE [dbo].[USP_ModifiedArtifactsGet] 
	 @showPreviousSprints bit = 0
	,@dayslide int = -14
AS
BEGIN
	SET NOCOUNT ON;

	declare @lastDeployedSprint int = 0
	declare @currentSprint int = 0
	declare @sprint int = 60
	declare @today date = GetDate()

	--DECLARE @dateSlide int = -14

	-- Last deployed sprint...
	select @lastDeployedSprint = Max(SprintNo) from ArtifactDeploymentLog

	-- Table Variables...
	--declare @currentSprintDeployment table( ArtifactName nvarchar(255), DateDeployed DateTime )

	-- test....
	declare @currentUpdates table( idfsDeploymentArtifact int IDENTITY( 100000,1 ), Artifactname nvarchar(255), ArtifactType nvarchar(50), DateLastModified DateTime, UpdateType nvarchar(10))

	-- Get the current sprint number...
	SELECT @currentSprint = SprintNo
	FROM SprintCycles
	WHERE @Today >= SprintStart and @Today <= SprintEnd ;

	WITH Artifacts ( 
		 idfsDeploymentArtifact
		,ArtifactName
		,DateLastModified )
	AS
	(
		SELECT 
		 idfsDeploymentArtifact
		,ArtifactName
		,DateDeployed
		FROM ArtifactDeploymentLog
		--WHERE DateDeployed IS NOT NULL 
	)

	-- Get the updated artifacts from the database... 
	INSERT INTO @currentUpdates
	SELECT 
		 Upper(name) as ArtifactName
		,Case Type 
			when 'AF' then 'Aggregate Function'
			when 'X' then 'Extended Stored Procedure'
			when 'IF' then 'Table-valued Function'
			when 'FN' then 'SQL Scalar Function'
			when 'P' then 'Stored Procedure'
			when 'TF' then 'SQL Table-valued Function'
			when 'V' then 'View'
			when 'U' then 'Table'
		 END as ArtifactType
		,modify_date as DateLastModified
		,UpdateType = iif( Create_Date=Modify_Date,'New','Update')
	FROM sys.all_objects x
	WHERE [type] IN( 'AF', 'X', 'IF', 'FN','P','TF', 'V', 'U' )
	AND [is_ms_shipped] = 0 AND MODIFY_DATE > dateadd( day,@daySlide,@today) AND 

	-- Only get those artifacts that have been updated since the last deployment...
	NOT EXISTS( 
		SELECT ArtifactName FROM Artifacts a WHERE a.ArtifactName = x.name and a.DateLastModified > x.modify_date )
	order by 1

	-- If we're not displaying previous sprints, then display current updates and exit...
	IF( @showPreviousSprints = 0 ) 
			SELECT 
			 idfsDeploymentArtifact
			,Upper( c.ArtifactName ) ArtifactName
			,c.ArtifactType  
			,Cast('--' as nvarchar(1000)) DeploymentComments
			,c.DateLastModified
			,c.UpdateType
			,Cast('?' as nvarchar(50)) Developer
			,Cast(0 as bit) ReadyForDeployment
			,Cast('?.?.?' as nvarchar(15)) ApplicationVersion
			,@currentSprint SprintNo
			,Cast(null as DateTime) DateDeployed
			,Cast('not deployed' as nvarchar(50)) DeployedBy
		FROM @currentUpdates c
		ORDER BY ArtifactName 
	ELSE 
	BEGIN
		SELECT	
			 a.idfsDeploymentArtifact
			,Upper( ArtifactName ) ArtifactName
			,ArtifactType
			,DeploymentComments
			,DateLastModified
			,UpdateType
			,Developer
			,ReadyForDeployment
			,ApplicationVersion
			,SprintNo
			,DateDeployed 
			,DeployedBy
		FROM ArtifactDeploymentLog a

		UNION ALL

		SELECT 
			 idfsDeploymentArtifact
			,Upper( c.ArtifactName )
			,c.ArtifactType
			,'--'
			,c.DateLastModified
			,c.UpdateType
			,'?'
			,0
			,'?.?.?'
			,0
			,null
			,'not deployed'
		FROM @currentUpdates c
		ORDER BY DateLastModified desc, SprintNo Desc, ApplicationVersion Desc, ArtifactName
	END
END
