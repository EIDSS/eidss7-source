-- This script selects user group list
-- Script should be executed on the database with country-specific user-group list that should be selected.
--
-- Parameters:
--
-- @NumberOfLanguages 
-- (number of languages: 1 = only English, 2 = English + one national language, 3 = English + two national languages).
--
-- @LangID (national language), and @SecLangID (second national language) should be changed 
-- in the section "Set parameters' values" to required values.
--
-- If second national language is not applicable for your country, you should set the same values to both parameters.
-- 'ar' - Arabic (Iraqi) language
-- 'az-L' - Azerbaijani language
-- 'hy' - Armenian language
-- 'ka' - Georgian language
-- 'kk' - Kazakh Language
-- 'ru' - Russian language
-- 'uk' - Ukrainian language

-- Variables
declare @LangID nvarchar(50)
declare @SecLangID nvarchar(50)
declare @NumberOfLanguages int 

-- Set parameters' values
set @NumberOfLanguages = 3 -- 1 = only English, 2 = English + one national language, 3 = English + two national languages
set @LangID = 'ka'
set @SecLangID = 'ru'

-- Determine country
declare	@idfCustomizationPackage	bigint
set	@idfCustomizationPackage = null

select		@idfCustomizationPackage = CAST(gso.strValue as bigint)
from		tstGlobalSiteOptions gso
where		gso.strName = N'CustomizationPackage'
			and ISNUMERIC(gso.strValue) = 1

if	@idfCustomizationPackage is null
select		@idfCustomizationPackage = cp.idfCustomizationPackage
from		tstLocalSiteOptions lso
inner join	tstSite s
on			(cast(s.idfsSite as nvarchar(200)) = lso.strValue collate database_default)
			and s.intRowStatus = 0
inner join	tstCustomizationPackage cp
on			cp.idfCustomizationPackage = s.idfCustomizationPackage
inner join	gisCountry c
on			c.idfsCountry = cp.idfsCountry
			and c.intRowStatus = 0
inner join	gisBaseReference br_c
on			br_c.idfsGISBaseReference = c.idfsCountry
			and br_c.intRowStatus = 0
where		lso.strName = N'SiteID'

if	@NumberOfLanguages = 3
SELECT eg.idfEmployeeGroup AS 'User Group ID',
       IsNull (r_eg_en.[name], IsNull (eg.strName, N''))
          AS 'User Group (EN)',
       IsNull (r_eg_lng.strTextString, N'')
          AS 'User Group (national language)',
       IsNull (r_eg_sec_lng.strTextString, N'')
          AS 'User Group (second national language)',
       IsNull (eg.strDescription, N'') AS 'Description'
  FROM				-- Employee Group List
                   dbo.tlbEmployeeGroup eg
                   INNER JOIN
                   dbo.tlbEmployee e
                   ON e.idfEmployee = eg.idfEmployeeGroup
						and	e.idfEmployee <> -1	-- Default Group
						and e.intRowStatus = 0
					-- Translations Employee Group Name
                LEFT JOIN
                   fnReference ('en', 19000022) r_eg_en          -- Employee Group Name
                ON r_eg_en.idfsReference = eg.idfsEmployeeGroupName
             LEFT JOIN
                trtStringNameTranslation r_eg_lng		 -- Employee Group Name (national)
             ON r_eg_lng.idfsBaseReference = eg.idfsEmployeeGroupName
				and r_eg_lng.idfsLanguage = dbo.fnGetLanguageCode(@LangID)
          LEFT JOIN
                trtStringNameTranslation r_eg_sec_lng		 -- Employee Group Name ( second national)
             ON r_eg_sec_lng.idfsBaseReference = eg.idfsEmployeeGroupName
				and r_eg_sec_lng.idfsLanguage = dbo.fnGetLanguageCode(@SecLangID)
					-- Link To Country
       LEFT JOIN
          trtBaseReferenceToCP brc
       ON     brc.idfsBaseReference = eg.idfsEmployeeGroupName
          AND brc.idfCustomizationPackage = @idfCustomizationPackage
 WHERE eg.intRowStatus = 0
       and (eg.idfEmployeeGroup < -512 or eg.idfEmployeeGroup > 0)
       AND (@idfCustomizationPackage IS NULL
            OR (@idfCustomizationPackage IS NOT NULL
                AND (brc.idfsBaseReference IS NOT NULL
                     OR NOT EXISTS
                          (SELECT *
                             FROM       trtBaseReferenceToCP brc_ex
									inner join	tstCustomizationPackage cp_ex
									on			cp_ex.idfCustomizationPackage = brc_ex.idfCustomizationPackage
                                     INNER JOIN
                                        gisCountry c_ex
                                     ON c_ex.idfsCountry = brc_ex.idfCustomizationPackage
                                        AND c_ex.intRowStatus = 0
                                  INNER JOIN
                                     gisBaseReference br_c_ex
                                  ON br_c_ex.idfsGISBaseReference =
                                        c_ex.idfsCountry
                                     AND br_c_ex.intRowStatus = 0
                            WHERE brc_ex.idfsBaseReference =
                                     eg.idfsEmployeeGroupName))))
order by	IsNull (r_eg_en.[name], IsNull (eg.strName, N'')), eg.idfEmployeeGroup

if	@NumberOfLanguages = 2
SELECT eg.idfEmployeeGroup AS 'User Group ID',
       IsNull (r_eg_en.[name], IsNull (eg.strName, N''))
          AS 'User Group (EN)',
       IsNull (r_eg_lng.strTextString, N'')
          AS 'User Group (national language)',
       IsNull (eg.strDescription, N'') AS 'Description'
  FROM				-- Employee Group List
                   dbo.tlbEmployeeGroup eg
                   INNER JOIN
                   dbo.tlbEmployee e
                   ON e.idfEmployee = eg.idfEmployeeGroup
						and	e.idfEmployee <> -1	-- Default Group
						and e.intRowStatus = 0
					-- Translations Employee Group Name
                LEFT JOIN
                   fnReference ('en', 19000022) r_eg_en          -- Employee Group Name
                ON r_eg_en.idfsReference = eg.idfsEmployeeGroupName
             LEFT JOIN
                trtStringNameTranslation r_eg_lng		 -- Employee Group Name (national)
             ON r_eg_lng.idfsBaseReference = eg.idfsEmployeeGroupName
				and r_eg_lng.idfsLanguage = dbo.fnGetLanguageCode(@LangID)
					-- Link To Country
       LEFT JOIN
          trtBaseReferenceToCP brc
       ON     brc.idfsBaseReference = eg.idfsEmployeeGroupName
          AND brc.idfCustomizationPackage = @idfCustomizationPackage
 WHERE eg.intRowStatus = 0
       and (eg.idfEmployeeGroup < -512 or eg.idfEmployeeGroup > 0)
       AND (@idfCustomizationPackage IS NULL
            OR (@idfCustomizationPackage IS NOT NULL
                AND (brc.idfsBaseReference IS NOT NULL
                     OR NOT EXISTS
                          (SELECT *
                             FROM       trtBaseReferenceToCP brc_ex
									inner join	tstCustomizationPackage cp_ex
									on			cp_ex.idfCustomizationPackage = brc_ex.idfCustomizationPackage
									 INNER JOIN
										gisCountry c_ex
									 ON c_ex.idfsCountry = brc_ex.idfCustomizationPackage
										AND c_ex.intRowStatus = 0
                                  INNER JOIN
                                     gisBaseReference br_c_ex
                                  ON br_c_ex.idfsGISBaseReference =
                                        c_ex.idfsCountry
                                     AND br_c_ex.intRowStatus = 0
                            WHERE brc_ex.idfsBaseReference =
                                     eg.idfsEmployeeGroupName))))
order by	IsNull (r_eg_en.[name], IsNull (eg.strName, N'')), eg.idfEmployeeGroup

if	@NumberOfLanguages = 1
SELECT eg.idfEmployeeGroup AS 'User Group ID',
       IsNull (r_eg_en.[name], IsNull (eg.strName, N''))
          AS 'User Group (EN)',
       IsNull (eg.strDescription, N'') AS 'Description'
  FROM				-- Employee Group List
                   dbo.tlbEmployeeGroup eg
                   INNER JOIN
                   dbo.tlbEmployee e
                   ON e.idfEmployee = eg.idfEmployeeGroup
						and	e.idfEmployee <> -1	-- Default Group
						and e.intRowStatus = 0
					-- Translations Employee Group Name
                LEFT JOIN
                   fnReference ('en', 19000022) r_eg_en          -- Employee Group Name
                ON r_eg_en.idfsReference = eg.idfsEmployeeGroupName
					-- Link To Country
       LEFT JOIN
          trtBaseReferenceToCP brc
       ON     brc.idfsBaseReference = eg.idfsEmployeeGroupName
          AND brc.idfCustomizationPackage = @idfCustomizationPackage
 WHERE eg.intRowStatus = 0
       and (eg.idfEmployeeGroup < -512 or eg.idfEmployeeGroup > 0)
       AND (@idfCustomizationPackage IS NULL
            OR (@idfCustomizationPackage IS NOT NULL
                AND (brc.idfsBaseReference IS NOT NULL
                     OR NOT EXISTS
                          (SELECT *
                             FROM       trtBaseReferenceToCP brc_ex
 									inner join	tstCustomizationPackage cp_ex
									on			cp_ex.idfCustomizationPackage = brc_ex.idfCustomizationPackage
                                    INNER JOIN
                                        gisCountry c_ex
                                     ON c_ex.idfsCountry = brc_ex.idfCustomizationPackage
                                        AND c_ex.intRowStatus = 0
                                  INNER JOIN
                                     gisBaseReference br_c_ex
                                  ON br_c_ex.idfsGISBaseReference =
                                        c_ex.idfsCountry
                                     AND br_c_ex.intRowStatus = 0
                            WHERE brc_ex.idfsBaseReference =
                                     eg.idfsEmployeeGroupName))))
order by	IsNull (r_eg_en.[name], IsNull (eg.strName, N'')), eg.idfEmployeeGroup
