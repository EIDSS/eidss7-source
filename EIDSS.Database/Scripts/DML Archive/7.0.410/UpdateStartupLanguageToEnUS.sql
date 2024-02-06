set nocount on

declare @str nvarchar(200) = N'"StartupLanguage":"'
declare @len int = len(@str)
declare @lngAbbr nvarchar(50) = N'en-US'

update	sp
set		sp.PreferenceDetail =
			case
				when  sp.PreferenceDetail like N'%' + @str + '%"%' collate Cyrillic_General_CI_AS
					then	LEFT(sp.PreferenceDetail, CHARINDEX(@str, sp.PreferenceDetail, 0) + @len - 1) + @lngAbbr + RIGHT(sp.PreferenceDetail, LEN(sp.PreferenceDetail) - CHARINDEX(N'"', sp.PreferenceDetail, CHARINDEX(@str, sp.PreferenceDetail, 0) + @len) + 1)
				else sp.PreferenceDetail
			end
from	SystemPreference sp
where	sp.PreferenceDetail like N'%' + @str + '%"%' collate Cyrillic_General_CI_AS
print 'Startup Language updated to [' + @lngAbbr + '] in system preferences: ' + cast(@@rowcount as nvarchar(20))

set nocount off