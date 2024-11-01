--##SUMMARY Selects new events for passed client application.
--##SUMMARY Can be called by EIDSS, EIDSS Client Agent or by EIDSS Notification Service.

--##REMARKS Author: Zurin M.
--##REMARKS Create date: 17.12.2009

--##REMARKS UPDATED BY: Vorobiev E.
--##REMARKS Date: 14.07.2011

--##REMARKS UPDATED BY: Edgard Torres.
--##REMARKS Date: 17.04.2023
-- Commented 'and (trtEventType.blnSubscription  = 1 or @IsNotificationClient = 1)' it prevents returning client events
-- Commented union on tstEventActive which was causing strRayon, strSiteID and strHASCsiteID fields to be empty
-- Commented @idfUserID, it is not beging used in the code

--##RETURNS Doesn't use

/*
--Example of a call of procedure:
EXEC spEventLog_SelectNewEvents 'en', '00110A967B9A', 0
*/

CREATE            procedure [dbo].[spEventLog_SelectNewEvents](
	@LangID as nvarchar(50), --##PARAM @LangID - language ID
	@ClientID as nvarchar(50), --##PARAM @ClientID - client application ID, defined in application configuration file. If client ID is not defined there, client PC MAC addres is used as client ID.
	@IsNotificationClient as BIT --##PARAM @IsNotificationClient - bit flag that identifies was this procedure from EIDSS notification service or not
)
as

declare @LastEvent as bigint
declare @CurrLastEvent as bigint
--declare @idfUserID as bigint -- not used

--select	@idfUserID = idfUserID -- Not used
--from	tstUserTable /*RCSI instead of with(nolock)*/
--where	strAccountName = SYSTEM_USER

set @CurrLastEvent = 0

select top 1 @CurrLastEvent = isnull(idfEventID, 0) 
from		tstEventActive /*RCSI instead of with(nolock)*/
order by	idfEventID desc

print 'Last Reported Event = ' + convert(nvarchar(200), @CurrLastEvent)

declare @bExistEventClient bit

select
	@LastEvent = idfLastEvent,
	@bExistEventClient = 1
from tstEventClient /*RCSI instead of with(nolock)*/
where strClient = @ClientID
	
begin try
--begin tran T1

IF @IsNotificationClient = 1 
BEGIN
	declare	@now datetime = getdate()

	IF exists (select 1 from tstNotificationActivity /*RCSI instead of with(nolock)*/)
		UPDATE	tstNotificationActivity
		SET		datLastNotificationActivity = @now
	ELSE
		INSERT INTO tstNotificationActivity (datLastNotificationActivity)
		VALUES (@now)	
END

if @bExistEventClient is null
begin
	print 'insert new event num ' + @ClientID + ',' + convert(nvarchar(200), @CurrLastEvent)
	insert into tstEventClient (strClient, idfLastEvent)
	values (@ClientID, @CurrLastEvent)
	--commit tran T1
	return -1
end
else if @LastEvent is null
begin
	print 'update last event num ' + @ClientID + ',' + convert(nvarchar(200), @CurrLastEvent)
	update	tstEventClient
	set		idfLastEvent = @CurrLastEvent
	where	strClient = @ClientID collate Cyrillic_General_CI_AS
	--commit tran T1
	return -1
end

print 'update last event num 1 ' + @ClientID + ',' + convert(nvarchar(200), @CurrLastEvent)

update	tstEventClient
set		idfLastEvent = @CurrLastEvent
where	strClient = @ClientID collate Cyrillic_General_CI_AS

end try
begin catch
	print 'ERROR'
	return -1
--if @@ERROR <> 0
--begin
--	print 'ERROR'
--	if @@TRANCOUNT < 2
--		rollback tran T1
--	else
--		commit tran T1
--	return -1
--end

--commit tran T1

end catch

print 'select all events after ' + convert(nvarchar(200), @LastEvent)

if @LastEvent <> @CurrLastEvent
begin
	declare	@idfsLanguage bigint
	set	@idfsLanguage = dbo.fnGetLanguageCode(@LangID)
	select		idfEventID, 
				tstEventActive.idfsEventTypeID, 
				ISNULL(snt_EventType.strTextString, br_EventType.strDefault) as EventName, 
				idfObjectID, 
				strInformationString, 
				strNote, 
				datEventDatatime, 
				N'Any User' as TargetUser,
				tstEventActive.strClient,
				tstEventActive.idfUserID,
				IsNull(tstEventActive.intProcessed, 0) as intProcessed,
				ISNULL(snt_Diagnosis.strTextString, br_Diagnosis.strDefault) as strDiagnosis,
				tstEventActive.idfsDiagnosis,
				ISNULL(gsnt_Region.strTextString, gbr_Region.strDefault) as strRegion,
				idfsRegion,
				ISNULL(gsnt_Rayon.strTextString, gbr_Rayon.strDefault) as strRayon,
				idfsRayon,
				tstSite.strSiteID as strSiteID,
				tstEventActive.idfsSite,
				tstSite.strHASCsiteID as strHASCsiteID,
				idfsLoginSite
	from		tstEventActive /*RCSI instead of with(nolock)*/
	
	inner join	tstEventSubscription /*RCSI instead of with(nolock)*/ 
	on			tstEventSubscription.idfsEventTypeID = tstEventActive.idfsEventTypeID
	
	inner join	trtEventType /*RCSI instead of with(nolock)*/
	on			trtEventType.idfsEventTypeID = tstEventActive.idfsEventTypeID
				and trtEventType.intRowStatus=0

	inner join	trtBaseReference br_EventType /*RCSI instead of with(nolock)*/
		left join	trtStringNameTranslation snt_EventType /*RCSI instead of with(nolock)*/
		on			snt_EventType.idfsBaseReference = br_EventType.idfsBaseReference
					and snt_EventType.idfsLanguage = @idfsLanguage
	on			br_EventType.idfsBaseReference = tstEventActive.idfsEventTypeID
				and br_EventType.idfsReferenceType = 19000025 /*Event Type*/

	left join	trtBaseReference br_Diagnosis /*RCSI instead of with(nolock)*/
		left join	trtStringNameTranslation snt_Diagnosis /*RCSI instead of with(nolock)*/
		on			snt_Diagnosis.idfsBaseReference = br_Diagnosis.idfsBaseReference
					and snt_Diagnosis.idfsLanguage = @idfsLanguage
	on			br_Diagnosis.idfsBaseReference = tstEventActive.idfsDiagnosis
				and br_Diagnosis.idfsReferenceType = 19000019 /*Diagnosis*/

	left join	gisBaseReference gbr_Rayon /*RCSI instead of with(nolock)*/
		left join	gisStringNameTranslation gsnt_Rayon /*RCSI instead of with(nolock)*/
		on			gsnt_Rayon.idfsGISBaseReference = gbr_Rayon.idfsGISBaseReference
					and gsnt_Rayon.idfsLanguage = @idfsLanguage
	on			gbr_Rayon.idfsGISBaseReference = tstEventActive.idfsRayon
				and gbr_Rayon.idfsGISReferenceType = 19000002 /*Rayon*/

	left join	gisBaseReference gbr_Region /*RCSI instead of with(nolock)*/
		left join	gisStringNameTranslation gsnt_Region /*RCSI instead of with(nolock)*/
		on			gsnt_Region.idfsGISBaseReference = gbr_Region.idfsGISBaseReference
					and gsnt_Region.idfsLanguage = @idfsLanguage
	on			gbr_Region.idfsGISBaseReference = tstEventActive.idfsRegion
				and gbr_Region.idfsGISReferenceType = 19000003 /*Region*/

	left join	tstSite /*RCSI instead of with(nolock)*/ 
	on			tstSite.idfsSite = tstEventActive.idfsSite

	where		tstEventSubscription.strClient = @ClientID collate Cyrillic_General_CI_AS
				and tstEventActive.idfEventID > @LastEvent
				and tstEventActive.idfEventID <= @CurrLastEvent
	--			and (trtEventType.blnSubscription  = 1 or @IsNotificationClient = 1)
	--UNION
	--select		idfEventID, 
	--			tstEventActive.idfsEventTypeID, 
	--			ISNULL(snt_EventType.strTextString, br_EventType.strDefault) as EventName, 
	--			idfObjectID, 
	--			strInformationString, 
	--			strNote, 
	--			datEventDatatime, 
	--			N'Any User' as TargetUser,
	--			tstEventActive.strClient,
	--			idfUserID,
	--			IsNull(tstEventActive.intProcessed, 0) as intProcessed,
	--			N'' as strDiagnosis,
	--			idfsDiagnosis,
	--			N'' as strRegion,
	--			idfsRegion,
	--			N'' as strRayon,
	--			idfsRayon,
	--			N'' as strSiteID,
	--			CAST(NULL as bigint) as idfsSite,
	--			N'' as strHASCsiteID,
	--			CAST(NULL as bigint) as idfsLoginSite
	--from		tstEventActive /*RCSI instead of with(nolock)*/

	--inner join	trtBaseReference br_EventType /*RCSI instead of with(nolock)*/
	--	left join	trtStringNameTranslation snt_EventType /*RCSI instead of with(nolock)*/
	--	on			snt_EventType.idfsBaseReference = br_EventType.idfsBaseReference
	--				and snt_EventType.idfsLanguage = @idfsLanguage
	--on			br_EventType.idfsBaseReference = tstEventActive.idfsEventTypeID
	--			and br_EventType.idfsReferenceType = 19000025 /*Event Type*/

	--WHERE 
	--			tstEventActive.idfsEventTypeID = 10025001 and --'evtLanguageChanged'
	--			tstEventActive.idfEventID > @LastEvent
	--			and tstEventActive.idfEventID <= @CurrLastEvent
	--			AND tstEventActive.strClient = @ClientID collate Cyrillic_General_CI_AS
	order by	tstEventActive.idfEventID desc
end
else
	select		idfEventID, 
				tstEventActive.idfsEventTypeID, 
				CAST(NULL AS NVARCHAR(200)) as EventName, 
				idfObjectID, 
				strInformationString, 
				strNote, 
				datEventDatatime, 
				N'Any User' as TargetUser,
				tstEventActive.strClient,
				idfUserID,
				IsNull(tstEventActive.intProcessed, 0) as intProcessed,
				CAST(NULL AS NVARCHAR(200)) as strDiagnosis,
				tstEventActive.idfsDiagnosis,
				CAST(NULL AS NVARCHAR(200)) as strRegion,
				idfsRegion,
				CAST(NULL AS NVARCHAR(200)) as strRayon,
				idfsRayon,
				CAST(NULL AS NVARCHAR(200)) as strSiteID,
				tstEventActive.idfsSite,
				CAST(NULL AS NVARCHAR(200)) as strHASCsiteID,
				tstEventActive.idfsLoginSite
	from		tstEventActive /*RCSI instead of with(nolock)*/
				where idfEventID IS NULL


GO
