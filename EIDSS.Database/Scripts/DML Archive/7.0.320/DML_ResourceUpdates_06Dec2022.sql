/*
Run this script on:

100.104.1.189,57355\NGSQLTEST1.EIDSS7_GG    -  This database will be modified

to synchronize it with:

100.104.1.167,49501\NGSQLDEV1.EIDSS7_GG_DT

You are recommended to back up your database before running this script

Script created by SQL Data Compare version 14.4.4.16824 from Red Gate Software Ltd at 12/6/2022 4:39:03 PM

*/
		
SET NUMERIC_ROUNDABORT OFF
GO
SET ANSI_PADDING, ANSI_WARNINGS, CONCAT_NULL_YIELDS_NULL, ARITHABORT, QUOTED_IDENTIFIER, ANSI_NULLS, NOCOUNT ON
GO
SET DATEFORMAT YMD
GO
--SET XACT_ABORT ON
--GO
--SET TRANSACTION ISOLATION LEVEL Serializable
--GO
--BEGIN TRANSACTION

PRINT(N'Drop constraints from [dbo].[trtResourceTranslation]')
ALTER TABLE [dbo].[trtResourceTranslation] NOCHECK CONSTRAINT [FK_trtResourceTranslation_idfsLanguage]
ALTER TABLE [dbo].[trtResourceTranslation] NOCHECK CONSTRAINT [FK_trtResourceTranslation_SourceSystemNameID]
ALTER TABLE [dbo].[trtResourceTranslation] NOCHECK CONSTRAINT [FK_trtResourceTranslation_trtResource]

PRINT(N'Drop constraints from [dbo].[trtResource]')
ALTER TABLE [dbo].[trtResource] NOCHECK CONSTRAINT [FK_trtResource_idfsResourceType]
ALTER TABLE [dbo].[trtResource] NOCHECK CONSTRAINT [FK_trtResource_SourceSystemNameID]

PRINT(N'Drop constraint FK_trtResourceSetToResource_trtResource from [dbo].[trtResourceSetToResource]')
ALTER TABLE [dbo].[trtResourceSetToResource] NOCHECK CONSTRAINT [FK_trtResourceSetToResource_trtResource]

PRINT(N'Delete rows from [dbo].[trtResourceTranslation]')
DELETE FROM [dbo].[trtResourceTranslation] WHERE [idfsResource] = 3027 AND [idfsLanguage] = 10049004 AND (idfsLanguage = 10049004)
DELETE FROM [dbo].[trtResourceTranslation] WHERE [idfsResource] = 3028 AND [idfsLanguage] = 10049004 AND (idfsLanguage = 10049004)
DELETE FROM [dbo].[trtResourceTranslation] WHERE [idfsResource] = 3029 AND [idfsLanguage] = 10049004 AND (idfsLanguage = 10049004)
DELETE FROM [dbo].[trtResourceTranslation] WHERE [idfsResource] = 3030 AND [idfsLanguage] = 10049004 AND (idfsLanguage = 10049004)
DELETE FROM [dbo].[trtResourceTranslation] WHERE [idfsResource] = 3031 AND [idfsLanguage] = 10049004 AND (idfsLanguage = 10049004)
DELETE FROM [dbo].[trtResourceTranslation] WHERE [idfsResource] = 3032 AND [idfsLanguage] = 10049004 AND (idfsLanguage = 10049004)
DELETE FROM [dbo].[trtResourceTranslation] WHERE [idfsResource] = 3033 AND [idfsLanguage] = 10049004 AND (idfsLanguage = 10049004)
DELETE FROM [dbo].[trtResourceTranslation] WHERE [idfsResource] = 3034 AND [idfsLanguage] = 10049004 AND (idfsLanguage = 10049004)
DELETE FROM [dbo].[trtResourceTranslation] WHERE [idfsResource] = 3035 AND [idfsLanguage] = 10049004 AND (idfsLanguage = 10049004)
DELETE FROM [dbo].[trtResourceTranslation] WHERE [idfsResource] = 3036 AND [idfsLanguage] = 10049004 AND (idfsLanguage = 10049004)
DELETE FROM [dbo].[trtResourceTranslation] WHERE [idfsResource] = 3037 AND [idfsLanguage] = 10049004 AND (idfsLanguage = 10049004)
DELETE FROM [dbo].[trtResourceTranslation] WHERE [idfsResource] = 3038 AND [idfsLanguage] = 10049004 AND (idfsLanguage = 10049004)
DELETE FROM [dbo].[trtResourceTranslation] WHERE [idfsResource] = 3039 AND [idfsLanguage] = 10049004 AND (idfsLanguage = 10049004)
DELETE FROM [dbo].[trtResourceTranslation] WHERE [idfsResource] = 3040 AND [idfsLanguage] = 10049004 AND (idfsLanguage = 10049004)
DELETE FROM [dbo].[trtResourceTranslation] WHERE [idfsResource] = 3041 AND [idfsLanguage] = 10049004 AND (idfsLanguage = 10049004)
DELETE FROM [dbo].[trtResourceTranslation] WHERE [idfsResource] = 3042 AND [idfsLanguage] = 10049004 AND (idfsLanguage = 10049004)
DELETE FROM [dbo].[trtResourceTranslation] WHERE [idfsResource] = 3043 AND [idfsLanguage] = 10049004 AND (idfsLanguage = 10049004)
DELETE FROM [dbo].[trtResourceTranslation] WHERE [idfsResource] = 3044 AND [idfsLanguage] = 10049004 AND (idfsLanguage = 10049004)
DELETE FROM [dbo].[trtResourceTranslation] WHERE [idfsResource] = 3045 AND [idfsLanguage] = 10049004 AND (idfsLanguage = 10049004)
DELETE FROM [dbo].[trtResourceTranslation] WHERE [idfsResource] = 3046 AND [idfsLanguage] = 10049004 AND (idfsLanguage = 10049004)
DELETE FROM [dbo].[trtResourceTranslation] WHERE [idfsResource] = 3047 AND [idfsLanguage] = 10049004 AND (idfsLanguage = 10049004)
DELETE FROM [dbo].[trtResourceTranslation] WHERE [idfsResource] = 3048 AND [idfsLanguage] = 10049004 AND (idfsLanguage = 10049004)
DELETE FROM [dbo].[trtResourceTranslation] WHERE [idfsResource] = 3049 AND [idfsLanguage] = 10049004 AND (idfsLanguage = 10049004)
DELETE FROM [dbo].[trtResourceTranslation] WHERE [idfsResource] = 3050 AND [idfsLanguage] = 10049004 AND (idfsLanguage = 10049004)
DELETE FROM [dbo].[trtResourceTranslation] WHERE [idfsResource] = 3051 AND [idfsLanguage] = 10049004 AND (idfsLanguage = 10049004)
DELETE FROM [dbo].[trtResourceTranslation] WHERE [idfsResource] = 3052 AND [idfsLanguage] = 10049004 AND (idfsLanguage = 10049004)
DELETE FROM [dbo].[trtResourceTranslation] WHERE [idfsResource] = 3053 AND [idfsLanguage] = 10049004 AND (idfsLanguage = 10049004)
DELETE FROM [dbo].[trtResourceTranslation] WHERE [idfsResource] = 3054 AND [idfsLanguage] = 10049004 AND (idfsLanguage = 10049004)
DELETE FROM [dbo].[trtResourceTranslation] WHERE [idfsResource] = 3055 AND [idfsLanguage] = 10049004 AND (idfsLanguage = 10049004)
DELETE FROM [dbo].[trtResourceTranslation] WHERE [idfsResource] = 3056 AND [idfsLanguage] = 10049004 AND (idfsLanguage = 10049004)
DELETE FROM [dbo].[trtResourceTranslation] WHERE [idfsResource] = 3057 AND [idfsLanguage] = 10049004 AND (idfsLanguage = 10049004)
DELETE FROM [dbo].[trtResourceTranslation] WHERE [idfsResource] = 3058 AND [idfsLanguage] = 10049004 AND (idfsLanguage = 10049004)
DELETE FROM [dbo].[trtResourceTranslation] WHERE [idfsResource] = 3059 AND [idfsLanguage] = 10049004 AND (idfsLanguage = 10049004)
DELETE FROM [dbo].[trtResourceTranslation] WHERE [idfsResource] = 3060 AND [idfsLanguage] = 10049004 AND (idfsLanguage = 10049004)
DELETE FROM [dbo].[trtResourceTranslation] WHERE [idfsResource] = 3061 AND [idfsLanguage] = 10049004 AND (idfsLanguage = 10049004)
DELETE FROM [dbo].[trtResourceTranslation] WHERE [idfsResource] = 3062 AND [idfsLanguage] = 10049004 AND (idfsLanguage = 10049004)
DELETE FROM [dbo].[trtResourceTranslation] WHERE [idfsResource] = 3063 AND [idfsLanguage] = 10049004 AND (idfsLanguage = 10049004)
DELETE FROM [dbo].[trtResourceTranslation] WHERE [idfsResource] = 3064 AND [idfsLanguage] = 10049004 AND (idfsLanguage = 10049004)
DELETE FROM [dbo].[trtResourceTranslation] WHERE [idfsResource] = 3065 AND [idfsLanguage] = 10049004 AND (idfsLanguage = 10049004)
DELETE FROM [dbo].[trtResourceTranslation] WHERE [idfsResource] = 3066 AND [idfsLanguage] = 10049004 AND (idfsLanguage = 10049004)
DELETE FROM [dbo].[trtResourceTranslation] WHERE [idfsResource] = 3067 AND [idfsLanguage] = 10049004 AND (idfsLanguage = 10049004)
DELETE FROM [dbo].[trtResourceTranslation] WHERE [idfsResource] = 3068 AND [idfsLanguage] = 10049004 AND (idfsLanguage = 10049004)
DELETE FROM [dbo].[trtResourceTranslation] WHERE [idfsResource] = 3069 AND [idfsLanguage] = 10049004 AND (idfsLanguage = 10049004)
DELETE FROM [dbo].[trtResourceTranslation] WHERE [idfsResource] = 3070 AND [idfsLanguage] = 10049004 AND (idfsLanguage = 10049004)
DELETE FROM [dbo].[trtResourceTranslation] WHERE [idfsResource] = 3071 AND [idfsLanguage] = 10049004 AND (idfsLanguage = 10049004)
DELETE FROM [dbo].[trtResourceTranslation] WHERE [idfsResource] = 3072 AND [idfsLanguage] = 10049004 AND (idfsLanguage = 10049004)
DELETE FROM [dbo].[trtResourceTranslation] WHERE [idfsResource] = 3073 AND [idfsLanguage] = 10049004 AND (idfsLanguage = 10049004)
DELETE FROM [dbo].[trtResourceTranslation] WHERE [idfsResource] = 3074 AND [idfsLanguage] = 10049004 AND (idfsLanguage = 10049004)
DELETE FROM [dbo].[trtResourceTranslation] WHERE [idfsResource] = 3075 AND [idfsLanguage] = 10049004 AND (idfsLanguage = 10049004)
DELETE FROM [dbo].[trtResourceTranslation] WHERE [idfsResource] = 3076 AND [idfsLanguage] = 10049004 AND (idfsLanguage = 10049004)
DELETE FROM [dbo].[trtResourceTranslation] WHERE [idfsResource] = 3077 AND [idfsLanguage] = 10049004 AND (idfsLanguage = 10049004)
DELETE FROM [dbo].[trtResourceTranslation] WHERE [idfsResource] = 3078 AND [idfsLanguage] = 10049004 AND (idfsLanguage = 10049004)
DELETE FROM [dbo].[trtResourceTranslation] WHERE [idfsResource] = 3079 AND [idfsLanguage] = 10049004 AND (idfsLanguage = 10049004)
DELETE FROM [dbo].[trtResourceTranslation] WHERE [idfsResource] = 3080 AND [idfsLanguage] = 10049004 AND (idfsLanguage = 10049004)
DELETE FROM [dbo].[trtResourceTranslation] WHERE [idfsResource] = 3081 AND [idfsLanguage] = 10049004 AND (idfsLanguage = 10049004)
DELETE FROM [dbo].[trtResourceTranslation] WHERE [idfsResource] = 3082 AND [idfsLanguage] = 10049004 AND (idfsLanguage = 10049004)
DELETE FROM [dbo].[trtResourceTranslation] WHERE [idfsResource] = 3083 AND [idfsLanguage] = 10049004 AND (idfsLanguage = 10049004)
DELETE FROM [dbo].[trtResourceTranslation] WHERE [idfsResource] = 3084 AND [idfsLanguage] = 10049004 AND (idfsLanguage = 10049004)
DELETE FROM [dbo].[trtResourceTranslation] WHERE [idfsResource] = 3085 AND [idfsLanguage] = 10049004 AND (idfsLanguage = 10049004)
DELETE FROM [dbo].[trtResourceTranslation] WHERE [idfsResource] = 3086 AND [idfsLanguage] = 10049004 AND (idfsLanguage = 10049004)
DELETE FROM [dbo].[trtResourceTranslation] WHERE [idfsResource] = 3087 AND [idfsLanguage] = 10049004 AND (idfsLanguage = 10049004)
DELETE FROM [dbo].[trtResourceTranslation] WHERE [idfsResource] = 3088 AND [idfsLanguage] = 10049004 AND (idfsLanguage = 10049004)
DELETE FROM [dbo].[trtResourceTranslation] WHERE [idfsResource] = 3089 AND [idfsLanguage] = 10049004 AND (idfsLanguage = 10049004)
DELETE FROM [dbo].[trtResourceTranslation] WHERE [idfsResource] = 3090 AND [idfsLanguage] = 10049004 AND (idfsLanguage = 10049004)
DELETE FROM [dbo].[trtResourceTranslation] WHERE [idfsResource] = 3357 AND [idfsLanguage] = 10049004 AND (idfsLanguage = 10049004)
DELETE FROM [dbo].[trtResourceTranslation] WHERE [idfsResource] = 3358 AND [idfsLanguage] = 10049004 AND (idfsLanguage = 10049004)
DELETE FROM [dbo].[trtResourceTranslation] WHERE [idfsResource] = 3359 AND [idfsLanguage] = 10049004 AND (idfsLanguage = 10049004)
DELETE FROM [dbo].[trtResourceTranslation] WHERE [idfsResource] = 3360 AND [idfsLanguage] = 10049004 AND (idfsLanguage = 10049004)
DELETE FROM [dbo].[trtResourceTranslation] WHERE [idfsResource] = 3361 AND [idfsLanguage] = 10049004 AND (idfsLanguage = 10049004)
DELETE FROM [dbo].[trtResourceTranslation] WHERE [idfsResource] = 3362 AND [idfsLanguage] = 10049004 AND (idfsLanguage = 10049004)
DELETE FROM [dbo].[trtResourceTranslation] WHERE [idfsResource] = 3363 AND [idfsLanguage] = 10049004 AND (idfsLanguage = 10049004)
DELETE FROM [dbo].[trtResourceTranslation] WHERE [idfsResource] = 3365 AND [idfsLanguage] = 10049004 AND (idfsLanguage = 10049004)
DELETE FROM [dbo].[trtResourceTranslation] WHERE [idfsResource] = 3395 AND [idfsLanguage] = 10049004 AND (idfsLanguage = 10049004)
DELETE FROM [dbo].[trtResourceTranslation] WHERE [idfsResource] = 3396 AND [idfsLanguage] = 10049004 AND (idfsLanguage = 10049004)
DELETE FROM [dbo].[trtResourceTranslation] WHERE [idfsResource] = 3397 AND [idfsLanguage] = 10049004 AND (idfsLanguage = 10049004)
DELETE FROM [dbo].[trtResourceTranslation] WHERE [idfsResource] = 3398 AND [idfsLanguage] = 10049004 AND (idfsLanguage = 10049004)
DELETE FROM [dbo].[trtResourceTranslation] WHERE [idfsResource] = 3399 AND [idfsLanguage] = 10049004 AND (idfsLanguage = 10049004)
DELETE FROM [dbo].[trtResourceTranslation] WHERE [idfsResource] = 3400 AND [idfsLanguage] = 10049004 AND (idfsLanguage = 10049004)
DELETE FROM [dbo].[trtResourceTranslation] WHERE [idfsResource] = 3401 AND [idfsLanguage] = 10049004 AND (idfsLanguage = 10049004)
DELETE FROM [dbo].[trtResourceTranslation] WHERE [idfsResource] = 3402 AND [idfsLanguage] = 10049004 AND (idfsLanguage = 10049004)
PRINT(N'Operation applied to 80 rows out of 80')

PRINT(N'Update rows in [dbo].[trtResourceTranslation]')
UPDATE [dbo].[trtResourceTranslation] SET [strResourceString]=N'სულ' WHERE [idfsResource] = 765 AND [idfsLanguage] = 10049004 AND (idfsLanguage = 10049004)
UPDATE [dbo].[trtResourceTranslation] SET [strResourceString]=N'სულ' WHERE [idfsResource] = 782 AND [idfsLanguage] = 10049004 AND (idfsLanguage = 10049004)
UPDATE [dbo].[trtResourceTranslation] SET [strResourceString]=N'სულ' WHERE [idfsResource] = 783 AND [idfsLanguage] = 10049004 AND (idfsLanguage = 10049004)
UPDATE [dbo].[trtResourceTranslation] SET [strResourceString]=N'ანგარიშის ID' WHERE [idfsResource] = 3928 AND [idfsLanguage] = 10049004 AND (idfsLanguage = 10049004)
UPDATE [dbo].[trtResourceTranslation] SET [strResourceString]=N'დაავადება' WHERE [idfsResource] = 3930 AND [idfsLanguage] = 10049004 AND (idfsLanguage = 10049004)
UPDATE [dbo].[trtResourceTranslation] SET [strResourceString]=N'ანგარიშის სტატუსი' WHERE [idfsResource] = 3931 AND [idfsLanguage] = 10049004 AND (idfsLanguage = 10049004)
UPDATE [dbo].[trtResourceTranslation] SET [strResourceString]=N'გადადით დეტალურ ინფორმაციაზე' WHERE [idfsResource] = 4158 AND [idfsLanguage] = 10049004 AND (idfsLanguage = 10049004)
UPDATE [dbo].[trtResourceTranslation] SET [strResourceString]=N'აგრეგირებული ინფორმაცია' WHERE [idfsResource] = 4171 AND [idfsLanguage] = 10049004 AND (idfsLanguage = 10049004)
UPDATE [dbo].[trtResourceTranslation] SET [strResourceString]=N'დაავადება' WHERE [idfsResource] = 4175 AND [idfsLanguage] = 10049004 AND (idfsLanguage = 10049004)
UPDATE [dbo].[trtResourceTranslation] SET [strResourceString]=N'დაავადების ანგარიშები' WHERE [idfsResource] = 4185 AND [idfsLanguage] = 10049004 AND (idfsLanguage = 10049004)
UPDATE [dbo].[trtResourceTranslation] SET [strResourceString]=N'ანგარიშის ID' WHERE [idfsResource] = 4186 AND [idfsLanguage] = 10049004 AND (idfsLanguage = 10049004)
UPDATE [dbo].[trtResourceTranslation] SET [strResourceString]=N'Outbreak Case ID' WHERE [idfsResource] = 4507 AND [idfsLanguage] = 10049004 AND (idfsLanguage = 10049004)
UPDATE [dbo].[trtResourceTranslation] SET [strResourceString]=N'Date of Symptom Onset' WHERE [idfsResource] = 4539 AND [idfsLanguage] = 10049004 AND (idfsLanguage = 10049004)
UPDATE [dbo].[trtResourceTranslation] SET [strResourceString]=N'Contact Type' WHERE [idfsResource] = 4558 AND [idfsLanguage] = 10049004 AND (idfsLanguage = 10049004)
UPDATE [dbo].[trtResourceTranslation] SET [strResourceString]=N'' WHERE [idfsResource] = 4594 AND [idfsLanguage] = 10049004 AND (idfsLanguage = 10049004)
PRINT(N'Operation applied to 15 rows out of 15')

PRINT(N'Update rows in [dbo].[trtResource]')
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 1877
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 1878
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 1879
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 1880
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 1881
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 1882
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 1883
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 1884
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 1885
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 1886
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 1887
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 1888
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 1889
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 1890
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 1891
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 1892
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 1893
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 1894
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 1895
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 1896
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 1897
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 1898
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 1899
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 1900
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 1901
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 1902
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 1903
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 1904
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 1905
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 1906
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 1907
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 1908
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 1909
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 1910
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 1911
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 1912
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 1913
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 1914
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 1915
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 1916
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 1917
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 1918
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 1919
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 1920
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 1921
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 1922
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 1923
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 1924
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 1925
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 1926
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 1927
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 1928
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 1929
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 1930
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 1931
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 1932
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 1933
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 1934
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 1935
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 1936
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 1937
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 1938
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 1939
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 1940
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 1941
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 1942
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 1943
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 1944
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 1945
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 1946
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 1947
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 1948
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 1949
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 1950
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 1951
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 1952
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 1953
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 1954
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 1955
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 1956
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 1957
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 1958
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 1959
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 1960
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 1961
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 1962
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 1963
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 1964
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 1965
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 1966
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 1967
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 1968
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 1969
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 1970
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 1971
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 1972
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 1973
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 1974
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 1975
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 1976
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 1977
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 1978
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 1979
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 1980
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 1981
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 1982
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 1983
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 1984
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 1985
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 1986
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 1987
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 1988
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 1989
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 1990
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 1991
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 1992
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 1993
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 1994
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 1995
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 1996
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 1997
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 1998
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 1999
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2000
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2001
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2002
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2003
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2004
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2005
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2006
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2007
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2008
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2009
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2010
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2011
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2012
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2013
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2014
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2015
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2016
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2017
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2018
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2019
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2020
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2021
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2022
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2023
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2024
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2025
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2026
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2027
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2028
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2029
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2030
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2031
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2032
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2033
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2034
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2035
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2036
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2037
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2038
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2039
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2040
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2041
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2042
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2043
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2044
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2045
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2046
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2047
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2048
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2049
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2050
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2051
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2052
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2053
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2054
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2055
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2056
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2057
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2058
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2059
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2060
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2061
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2062
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2063
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2064
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2065
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2066
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2067
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2068
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2069
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2070
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2071
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2072
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2073
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2074
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2075
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2076
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2077
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2078
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2079
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2080
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2081
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2082
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2083
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2084
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2085
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2086
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2087
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2088
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2089
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2090
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2091
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2092
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2093
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2094
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2095
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2096
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2097
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2098
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2099
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2100
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2101
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2102
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2103
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2104
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2105
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2106
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2107
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2108
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2109
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2110
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2111
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2112
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2113
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2114
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2115
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2116
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2117
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2118
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2119
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2120
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2121
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2122
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2123
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2124
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2125
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2126
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2127
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2128
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2129
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2130
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2131
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2132
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2133
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2134
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2135
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2136
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2137
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2138
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2139
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2140
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2141
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2142
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2143
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2144
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2145
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2146
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2147
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2148
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2149
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2150
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2151
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2152
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2153
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2154
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2155
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2156
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2157
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2158
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2159
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2160
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2161
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2162
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2163
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2164
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2165
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2166
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2167
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2168
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2169
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2170
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2171
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2172
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2173
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2174
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2175
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2176
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2177
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2178
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2179
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2180
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2181
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2182
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2183
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2184
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2185
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2186
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2187
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2188
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2189
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2190
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2191
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2192
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2193
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2194
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2195
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2196
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2197
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2198
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2199
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2200
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2201
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2202
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2203
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2204
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2205
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2206
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2207
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2208
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2209
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2210
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2211
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2212
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2213
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2214
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2215
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2216
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2217
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2218
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2219
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2220
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2221
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2222
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2223
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2224
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2225
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2226
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2227
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2228
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2229
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2230
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2231
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2232
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2233
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2234
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2235
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2236
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2237
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2238
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2239
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2240
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2241
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2242
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2243
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2244
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2245
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2246
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2247
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2248
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2249
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2250
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2251
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2252
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2253
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2254
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2255
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2256
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2257
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2258
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2259
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2260
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2261
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2262
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2263
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2264
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2265
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2266
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2267
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2268
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2269
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2270
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2271
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2272
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2273
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2274
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2275
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2276
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2277
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2278
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2279
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2280
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2281
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2282
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2283
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2284
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2285
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2286
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2287
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2288
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2289
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2290
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2291
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2292
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2293
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2294
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2295
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2296
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2297
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2298
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2299
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2300
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2301
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2302
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2303
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2304
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2305
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2306
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2307
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2308
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2309
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2310
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2311
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2312
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2313
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2314
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2315
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2316
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2317
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2318
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2319
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2320
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2321
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2322
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2323
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2324
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2325
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2326
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2327
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2328
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2329
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2330
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2331
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2332
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2333
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2334
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2335
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2336
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2337
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2338
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2339
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2340
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2341
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2342
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2343
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2344
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2345
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2346
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2347
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2348
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2349
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2350
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2351
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2352
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2353
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2354
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2355
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2356
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2357
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2358
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2359
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2360
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2361
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2362
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2363
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2364
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2365
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2366
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2367
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2368
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2369
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2370
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2371
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2372
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2373
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2374
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2375
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2376
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2377
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2378
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2379
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2380
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2381
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2382
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2383
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2384
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2385
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2386
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2387
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2388
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2389
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2390
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2391
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2392
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2393
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2394
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2395
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2396
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2397
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2398
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2399
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2400
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2813
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2814
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2815
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2816
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2817
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2818
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2819
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2820
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2821
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2822
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2823
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2824
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2825
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2826
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2827
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2828
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2829
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2830
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2831
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2832
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2833
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2834
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2835
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2836
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2837
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2838
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2839
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2840
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2841
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2842
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2843
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2844
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2845
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2846
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2848
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2849
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2850
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2851
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2852
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2853
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2854
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2855
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2856
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2857
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2858
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2859
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2860
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2861
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2862
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2863
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2864
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2865
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2866
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2869
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2878
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2879
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2880
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2881
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2882
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2883
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2884
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2885
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2886
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2887
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2888
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2889
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2890
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2891
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2892
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2893
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2894
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2895
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2896
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2897
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2898
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2899
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2900
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2901
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2902
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2903
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2904
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2905
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2908
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2909
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2910
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2911
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2912
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2913
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2914
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2916
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2917
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2918
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2919
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2920
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2921
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2922
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2923
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2924
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2925
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2928
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2929
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2930
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2931
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2932
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2933
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2934
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2935
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2936
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2937
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2938
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2939
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2940
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2941
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2942
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2943
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2944
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2945
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2946
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2947
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2948
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2949
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2950
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2951
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2952
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2953
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2954
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2955
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2956
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2957
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2958
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2959
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2960
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2961
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2962
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2963
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2964
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2965
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2966
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2967
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2968
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2969
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2970
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2971
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2972
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 2973
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3027
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3028
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3029
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3030
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3031
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3032
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3033
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3034
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3035
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3036
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3037
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3038
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3039
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3040
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3041
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3042
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3043
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3044
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3045
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3046
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3047
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3048
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3049
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3050
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3051
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3052
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3053
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3054
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3055
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3056
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3057
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3058
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3059
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3060
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3061
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3062
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3063
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3064
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3065
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3066
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3067
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3068
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3069
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3070
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3071
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3072
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3073
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3074
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3075
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3076
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3077
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3078
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3079
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3080
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3081
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3082
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3083
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3084
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3085
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3086
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3087
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3088
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3089
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3090
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3092
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3093
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3094
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3095
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3096
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3097
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3098
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3099
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3100
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3101
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3102
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3103
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3104
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3105
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3106
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3107
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3108
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3109
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3110
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3111
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3112
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3113
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3114
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3115
UPDATE [dbo].[trtResource] SET [strResourceName]=N'Collection Date shall be on or after than the Session Start Date.' WHERE [idfsResource] = 3120
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3124
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3125
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3126
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3127
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3128
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3129
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3130
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3131
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3132
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3133
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3134
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3135
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3136
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3137
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3138
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3139
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3140
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3141
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3142
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3143
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3144
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3145
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3146
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3147
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3151
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3152
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3153
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3154
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3155
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3156
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3157
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3158
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3159
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3160
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3161
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3162
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3163
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3164
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3165
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3166
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3167
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3168
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3169
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3170
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3171
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3172
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3175
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3176
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3177
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3178
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3179
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3180
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3181
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3182
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3183
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3184
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3215
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3216
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3217
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3218
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3219
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3220
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3221
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3222
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3223
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3224
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3225
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3226
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3227
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3228
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3229
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3230
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3231
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3232
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3233
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3234
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3235
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3236
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3237
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3238
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3239
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3240
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3241
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3242
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3243
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3244
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3245
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3246
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3247
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3248
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3249
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3250
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3251
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3252
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3253
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3254
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3255
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3256
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3257
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3258
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3261
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3262
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3263
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3264
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3265
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3266
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3267
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3268
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3269
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3270
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3271
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3272
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3273
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3274
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3275
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3276
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3277
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3278
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3279
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3280
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3281
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3282
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3283
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3284
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3285
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3286
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3287
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3288
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3289
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3290
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3291
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3292
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3293
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3294
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3295
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3296
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3297
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3298
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3299
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3300
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3301
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3302
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3303
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3304
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3305
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3306
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3307
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3308
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3309
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3310
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3311
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3312
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3313
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3314
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3315
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3316
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3317
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3318
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3319
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3320
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3321
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3322
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3323
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3324
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3325
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3326
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3327
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3328
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3329
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3330
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3331
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3332
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3333
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3334
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3335
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3336
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3337
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3338
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3339
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3340
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3341
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3342
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3343
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3344
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3345
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3346
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3347
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3348
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3349
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3350
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3351
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3352
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3353
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3354
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3355
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3356
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3357
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3358
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3359
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3360
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3361
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3362
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3363
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3364
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3365
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3366
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3367
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3368
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3369
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3370
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3373
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3376
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3377
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3378
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3379
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3380
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3381
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3382
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3383
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3384
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3385
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3386
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3395
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3396
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3397
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3398
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3399
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3400
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3401
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3402
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3403
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3409
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3410
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3411
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3412
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3413
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3414
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3415
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3416
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3417
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3418
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3419
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3420
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3421
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3422
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3423
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3424
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3425
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3426
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3427
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3428
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3429
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3430
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3431
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3432
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3433
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3434
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3437
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3438
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3439
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3440
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3441
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3442
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3443
UPDATE [dbo].[trtResource] SET [strResourceName]=N'DiseaseTest', [idfsResourceType]=10540003 WHERE [idfsResource] = 3444
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3445
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3446
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3447
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3448
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3474
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3475
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3476
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3477
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3478
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3479
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3480
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3481
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3482
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3483
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3484
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3485
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3486
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3487
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3488
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3489
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3490
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3491
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3492
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3493
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3494
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3495
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3496
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3497
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3498
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3499
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3500
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3501
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3502
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3503
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3504
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3505
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3506
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3507
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3508
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3509
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3510
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3511
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3512
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3513
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3514
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3515
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3517
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3518
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3519
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3520
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3521
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3522
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3523
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3524
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3525
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3526
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3527
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3543
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3544
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3545
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3546
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3547
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3548
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3549
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3550
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3551
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3552
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3553
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3554
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3555
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3556
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3557
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3558
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3559
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3560
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3561
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3562
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3563
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3564
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3565
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3566
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3567
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3568
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3569
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3570
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3571
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3572
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3573
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3574
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3575
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3576
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3577
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3578
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3579
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3580
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3581
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3582
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3583
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3584
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3585
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3605
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3606
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3607
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3608
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3609
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3610
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3611
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3612
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3613
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3614
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3615
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3616
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3624
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3625
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3626
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3627
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3628
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3629
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3630
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3631
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3632
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3633
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3634
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3635
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3636
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3637
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3638
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3639
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3640
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3641
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3642
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3643
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3644
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3645
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3646
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3647
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3648
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3649
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3650
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3651
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3657
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3658
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3659
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3660
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3661
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3662
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3663
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3664
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3665
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3666
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3667
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3668
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3671
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3672
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3673
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3674
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3675
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3676
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3677
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3678
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3679
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3680
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3681
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3682
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3683
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3684
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3685
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3686
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3687
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3688
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3689
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3690
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3691
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3692
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3693
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3694
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3697
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3698
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3699
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3700
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3701
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3702
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3703
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3704
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3705
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3706
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3707
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3708
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3709
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3710
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3711
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3712
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3713
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3714
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3715
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3716
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3717
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3718
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3719
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3720
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3721
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3722
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3723
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3724
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3725
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3726
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3727
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3728
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3729
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3730
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3731
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3732
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3733
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3734
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3735
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3736
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3737
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3738
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3740
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3741
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3742
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3743
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3744
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3745
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3746
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3747
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3748
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3749
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3750
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3751
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3753
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3754
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3755
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3756
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3757
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3758
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3759
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3760
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3761
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3762
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3763
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3764
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3765
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3766
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3767
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3768
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3769
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3770
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3771
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3772
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3773
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3774
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3775
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3776
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3777
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3778
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3779
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3780
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3781
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3782
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3783
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3784
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3785
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3786
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3787
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3788
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3789
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3790
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3791
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3792
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3793
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3794
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3795
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3796
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3797
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3798
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3799
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3800
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3801
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3802
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3803
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3804
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3805
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3806
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3807
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3808
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3809
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3810
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3811
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3812
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3813
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3814
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3815
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3816
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3817
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3818
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3819
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3820
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3821
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3822
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3823
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3824
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3825
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3826
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3827
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3828
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3829
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3830
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3831
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3832
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3833
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3834
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3835
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3836
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3837
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3838
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3839
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3840
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3841
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3842
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3843
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3844
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3845
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3846
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3847
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3848
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3849
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3850
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3851
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3852
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3853
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3854
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3855
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3856
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3857
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3858
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3859
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3860
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3861
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3862
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3863
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3864
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3865
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3866
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3867
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3868
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3869
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3870
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3871
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3872
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3873
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3874
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3875
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3876
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3877
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3878
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3879
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3880
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3881
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3882
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3883
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3884
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3885
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3886
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3887
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3888
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3889
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3890
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3891
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3892
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3893
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3894
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3895
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3896
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3897
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3898
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3899
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3900
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3901
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3902
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3903
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3904
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3905
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3906
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3907
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3908
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3909
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3910
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3911
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3912
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3913
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3924
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3925
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3926
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3927
UPDATE [dbo].[trtResource] SET [strResourceName]=N'Report ID', [idfsResourceType]=10540003 WHERE [idfsResource] = 3928
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3929
UPDATE [dbo].[trtResource] SET [strResourceName]=N'Disease', [idfsResourceType]=10540003 WHERE [idfsResource] = 3930
UPDATE [dbo].[trtResource] SET [strResourceName]=N'Report Status', [idfsResourceType]=10540003 WHERE [idfsResource] = 3931
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3932
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3933
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3934
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3935
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3936
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3937
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3938
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3939
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3940
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3941
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3942
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3943
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3944
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3945
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3946
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3947
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3948
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3949
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3950
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3951
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3952
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3953
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3954
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3955
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3956
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3957
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3958
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3959
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3960
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3961
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3962
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3963
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3964
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3965
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3966
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3967
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3968
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3969
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3970
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3971
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3972
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3973
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3974
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3975
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3976
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3977
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3978
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3979
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3980
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3981
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3982
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3983
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3984
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3985
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3986
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3987
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3988
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3989
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3990
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3991
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3992
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3993
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3994
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3995
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3996
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3997
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3998
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 3999
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4000
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4001
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4002
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4003
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4004
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4005
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4006
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4007
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4008
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4009
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4010
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4011
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4012
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4013
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4014
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4015
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4016
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4017
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4018
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4019
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4020
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4021
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4022
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4023
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4024
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4025
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4026
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4027
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4028
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4029
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4030
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4031
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4032
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4033
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4034
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4035
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4036
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4037
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4038
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4039
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4040
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4041
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4042
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4043
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4044
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4045
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4046
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4047
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4048
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4049
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4050
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4051
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4052
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4053
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4054
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4055
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4056
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4057
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4058
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4059
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4060
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4061
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4062
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4063
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4064
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4065
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4066
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4067
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4068
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4069
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4070
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4071
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4072
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4073
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4074
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4075
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4076
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4077
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4078
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4079
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4080
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4081
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4082
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4083
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4084
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4085
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4086
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4087
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4088
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4089
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4090
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4091
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4092
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4093
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4094
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4095
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4096
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4097
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4098
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4099
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4100
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4101
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4102
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4103
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4104
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4105
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4106
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4107
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4108
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4109
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4110
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4111
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4112
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4113
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4114
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4115
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4116
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4117
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4118
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4119
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4120
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4121
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4122
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4123
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4124
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4125
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4126
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4127
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4128
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4129
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4130
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4131
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4132
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4133
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4134
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4135
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4137
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4138
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4139
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4140
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4141
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4142
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4143
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4144
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4145
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4146
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4147
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4148
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4149
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4150
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4151
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4152
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4153
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4154
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4155
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4156
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4157
UPDATE [dbo].[trtResource] SET [strResourceName]=N'Detailed Information', [idfsResourceType]=10540003 WHERE [idfsResource] = 4158
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4159
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4160
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4161
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4162
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4163
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4164
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4165
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4166
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4167
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4168
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4169
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4170
UPDATE [dbo].[trtResource] SET [strResourceName]=N'Aggregate Information', [idfsResourceType]=10540003 WHERE [idfsResource] = 4171
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4172
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4173
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4174
UPDATE [dbo].[trtResource] SET [strResourceName]=N'Disease', [idfsResourceType]=10540003 WHERE [idfsResource] = 4175
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4176
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4177
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4178
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4179
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4180
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4181
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4182
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4183
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4184
UPDATE [dbo].[trtResource] SET [strResourceName]=N'Disease Reports', [idfsResourceType]=10540003 WHERE [idfsResource] = 4185
UPDATE [dbo].[trtResource] SET [strResourceName]=N'Report ID', [idfsResourceType]=10540003 WHERE [idfsResource] = 4186
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4187
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4188
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4189
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4190
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4191
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4192
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4193
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4194
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4195
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4196
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4197
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4198
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4199
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4200
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4201
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4202
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4203
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4204
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4205
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4206
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4207
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4208
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4209
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4210
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4211
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4212
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4213
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4214
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4215
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4216
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4217
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4218
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4219
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4220
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4221
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4222
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4223
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4224
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4225
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4226
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4227
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4228
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4229
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4230
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4231
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4248
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4249
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4250
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4251
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4252
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4253
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4254
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4255
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4256
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4257
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4258
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4259
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4260
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4261
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4262
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4263
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4264
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4265
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4266
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4267
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4268
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4269
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4270
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4271
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4272
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4273
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4274
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4275
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4276
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4277
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4278
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4279
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4280
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4281
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4282
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4283
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4284
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4285
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4286
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4287
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4288
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4289
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4290
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4291
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4292
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4293
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4294
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4295
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4296
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4297
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4298
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4299
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4300
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4301
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4302
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4303
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4304
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4305
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4306
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4307
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4308
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4309
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4310
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4311
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4312
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4313
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4314
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4315
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4316
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4317
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4318
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4319
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4320
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4321
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4322
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4323
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4324
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4325
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4326
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4327
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4328
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4329
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4330
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4331
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4332
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4333
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4334
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4335
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4336
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4337
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4338
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4339
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4340
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4341
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4342
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4343
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4344
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4345
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4346
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4347
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4348
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4349
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4350
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4351
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4352
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4353
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4354
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4355
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4356
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4357
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4358
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4359
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4360
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4361
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4362
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4363
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4364
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4365
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4366
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4367
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4368
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4370
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4371
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4372
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4373
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4374
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4375
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4376
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4377
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4378
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4379
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4380
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4381
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4382
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4383
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4384
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4385
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4386
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4387
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4390
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4391
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4392
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4393
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4394
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4395
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4396
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4397
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4398
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4399
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4400
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4401
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4402
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4403
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4404
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4405
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4406
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4407
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4408
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4409
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4410
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4411
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4412
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4414
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4415
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4416
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4417
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4418
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4419
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4420
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4421
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4422
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4423
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4424
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4425
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4426
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4427
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4428
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4429
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4430
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4431
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4432
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4433
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4434
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4435
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4436
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4437
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4438
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4439
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4440
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4441
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4442
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4443
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4444
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4445
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4446
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4447
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4448
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4449
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4450
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4451
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4452
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4453
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4454
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4455
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4456
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4457
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4458
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4459
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4460
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4461
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4462
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4467
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4468
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4469
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4470
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4472
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4473
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4474
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4475
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4476
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4477
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4478
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4479
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4480
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4481
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4482
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4483
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4484
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4485
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4486
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4487
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4488
UPDATE [dbo].[trtResource] SET [idfsResourceType]=10540003 WHERE [idfsResource] = 4489
UPDATE [dbo].[trtResource] SET [strResourceName]=N'Date of rash onset' WHERE [idfsResource] = 4614
UPDATE [dbo].[trtResource] SET [strResourceName]=N'Number of vaccines' WHERE [idfsResource] = 4616
UPDATE [dbo].[trtResource] SET [strResourceName]=N'Date of last vaccination' WHERE [idfsResource] = 4617
PRINT(N'Operation applied to 1957 rows out of 1957')

PRINT(N'Add row to [dbo].[trtResource]')
INSERT INTO [dbo].[trtResource] ([idfsResource], [strResourceName], [intRowStatus], [idfsResourceType]) VALUES (4642, N'Generate', 1, 10540000)

PRINT(N'Add rows to [dbo].[trtResourceTranslation]')
INSERT INTO [dbo].[trtResourceTranslation] ([idfsResource], [idfsLanguage], [strResourceString], [intRowStatus]) VALUES (42, 10049004, N'დააწკაპუნეთ მოსაძებნად', 0)
INSERT INTO [dbo].[trtResourceTranslation] ([idfsResource], [idfsLanguage], [strResourceString], [intRowStatus]) VALUES (123, 10049004, N'დაავადების ჯგუფი - დაავადების დეტალები', 0)
INSERT INTO [dbo].[trtResourceTranslation] ([idfsResource], [idfsLanguage], [strResourceString], [intRowStatus]) VALUES (126, 10049004, N'დეტალები პერსონალური იდენტიფიკაციის ტიპის შესახებ', 0)
INSERT INTO [dbo].[trtResourceTranslation] ([idfsResource], [idfsLanguage], [strResourceString], [intRowStatus]) VALUES (127, 10049004, N' ანგარიშის დეტალები დაავადების ჯგუფი - დაავადების შესახებ', 0)
INSERT INTO [dbo].[trtResourceTranslation] ([idfsResource], [idfsLanguage], [strResourceString], [intRowStatus]) VALUES (133, 10049004, N'ვექტორის ტიპი - აღების მეთოდის დეტალები', 0)
INSERT INTO [dbo].[trtResourceTranslation] ([idfsResource], [idfsLanguage], [strResourceString], [intRowStatus]) VALUES (134, 10049004, N'ვექტორის ტიპი- საველე ტესტის დეტალები', 0)
INSERT INTO [dbo].[trtResourceTranslation] ([idfsResource], [idfsLanguage], [strResourceString], [intRowStatus]) VALUES (135, 10049004, N'ვექტორის ტიპი- ნიმუშის ტიპის დეტალები', 0)
INSERT INTO [dbo].[trtResourceTranslation] ([idfsResource], [idfsLanguage], [strResourceString], [intRowStatus]) VALUES (710, 10049004, N'პაროლის მინიმალური ხანგრძლივობა (დღეები)', 0)
INSERT INTO [dbo].[trtResourceTranslation] ([idfsResource], [idfsLanguage], [strResourceString], [intRowStatus]) VALUES (711, 10049004, N'გამოიყენეთ დიდი ასოები', 0)
INSERT INTO [dbo].[trtResourceTranslation] ([idfsResource], [idfsLanguage], [strResourceString], [intRowStatus]) VALUES (712, 10049004, N'გამოიყენეთ რიცხვები', 0)
INSERT INTO [dbo].[trtResourceTranslation] ([idfsResource], [idfsLanguage], [strResourceString], [intRowStatus]) VALUES (713, 10049004, N'გამოიყენეთ პატარა ასოები', 0)
INSERT INTO [dbo].[trtResourceTranslation] ([idfsResource], [idfsLanguage], [strResourceString], [intRowStatus]) VALUES (714, 10049004, N'გამოიყენეთ განსაკუთრებული სიმბოლოები', 0)
INSERT INTO [dbo].[trtResourceTranslation] ([idfsResource], [idfsLanguage], [strResourceString], [intRowStatus]) VALUES (715, 10049004, N'გამოიყენეთ "სივრცე"', 0)
INSERT INTO [dbo].[trtResourceTranslation] ([idfsResource], [idfsLanguage], [strResourceString], [intRowStatus]) VALUES (716, 10049004, N'ერიდეთ თანმიმდევრულ სიმბოლოებს', 0)
INSERT INTO [dbo].[trtResourceTranslation] ([idfsResource], [idfsLanguage], [strResourceString], [intRowStatus]) VALUES (717, 10049004, N'არ გამოიყენოთ მომხმარებლის სახელი როგორც პაროლი', 0)
INSERT INTO [dbo].[trtResourceTranslation] ([idfsResource], [idfsLanguage], [strResourceString], [intRowStatus]) VALUES (721, 10049004, N'სესიის მაქსიმალური ხანგრძლივობა საათებში', 0)
INSERT INTO [dbo].[trtResourceTranslation] ([idfsResource], [idfsLanguage], [strResourceString], [intRowStatus]) VALUES (722, 10049004, N'გაფრთხილება დისპლეის სესიის დახურვის შესახებ არააქტიურობის გამო ( წუთები)', 0)
INSERT INTO [dbo].[trtResourceTranslation] ([idfsResource], [idfsLanguage], [strResourceString], [intRowStatus]) VALUES (723, 10049004, N'გაფრთხილება დისპლეის სესიის დახურვის შესახებ ( წუთები)', 0)
INSERT INTO [dbo].[trtResourceTranslation] ([idfsResource], [idfsLanguage], [strResourceString], [intRowStatus]) VALUES (919, 10049004, N'ფარული', 0)
INSERT INTO [dbo].[trtResourceTranslation] ([idfsResource], [idfsLanguage], [strResourceString], [intRowStatus]) VALUES (920, 10049004, N'ენის ფაილის დამატება', 0)
INSERT INTO [dbo].[trtResourceTranslation] ([idfsResource], [idfsLanguage], [strResourceString], [intRowStatus]) VALUES (922, 10049004, N'შეიყვანეთ ენის დასახელება', 0)
INSERT INTO [dbo].[trtResourceTranslation] ([idfsResource], [idfsLanguage], [strResourceString], [intRowStatus]) VALUES (923, 10049004, N'აირჩიეთ ფაილი', 0)
INSERT INTO [dbo].[trtResourceTranslation] ([idfsResource], [idfsLanguage], [strResourceString], [intRowStatus]) VALUES (925, 10049004, N'ყველა მოდული', 0)
INSERT INTO [dbo].[trtResourceTranslation] ([idfsResource], [idfsLanguage], [strResourceString], [intRowStatus]) VALUES (926, 10049004, N'ძებნა მოდულის ფარგლებში', 0)
INSERT INTO [dbo].[trtResourceTranslation] ([idfsResource], [idfsLanguage], [strResourceString], [intRowStatus]) VALUES (2801, 10049004, N' ძებნის შემდეგ მივიღეთ მეტისმეტად ბევრი შედეგი. ', 0)
INSERT INTO [dbo].[trtResourceTranslation] ([idfsResource], [idfsLanguage], [strResourceString], [intRowStatus]) VALUES (2803, 10049004, N'გაფრთხილება', 0)
INSERT INTO [dbo].[trtResourceTranslation] ([idfsResource], [idfsLanguage], [strResourceString], [intRowStatus]) VALUES (2915, 10049004, N'ლაბორატორიული ნიმუში # {3} - ისათვის # 2 ზე შესრულებული {0} - სა და {1} - ის დამტკიცება ვერ მოხერხდა. ', 0)
INSERT INTO [dbo].[trtResourceTranslation] ([idfsResource], [idfsLanguage], [strResourceString], [intRowStatus]) VALUES (3020, 10049004, N'შერჩეული დაავადების ანგარიში უკვე დაკავშირებულია აფეთქების სესიასთან.', 0)
INSERT INTO [dbo].[trtResourceTranslation] ([idfsResource], [idfsLanguage], [strResourceString], [intRowStatus]) VALUES (3021, 10049004, N'სიმპტომების გამოვლენის თარიღი  არ შეიძლება იყოს აფეთქების დაწყების თარიღზე ადრე.', 0)
INSERT INTO [dbo].[trtResourceTranslation] ([idfsResource], [idfsLanguage], [strResourceString], [intRowStatus]) VALUES (3022, 10049004, N'ანგარიშში შერჩეული დაავადება არ ემთხვევა აფეთქების დაავადებას.', 0)
INSERT INTO [dbo].[trtResourceTranslation] ([idfsResource], [idfsLanguage], [strResourceString], [intRowStatus]) VALUES (3174, 10049004, N'შემთხვევის საბოლოო კლასიფიკაცია არ ემთხვევა დიაგნოზის საფუძველს', 0)
INSERT INTO [dbo].[trtResourceTranslation] ([idfsResource], [idfsLanguage], [strResourceString], [intRowStatus]) VALUES (3187, 10049004, N'ყველა წაშალეთ', 0)
INSERT INTO [dbo].[trtResourceTranslation] ([idfsResource], [idfsLanguage], [strResourceString], [intRowStatus]) VALUES (3374, 10049004, N'{0}''- ის მნიშვნელობა  არ უნდა აღემატებოდეს  ცხოველებიდან შენარჩევი ნიმუშების მნიშვნელობას ''{1}'' გსურთ მნიშვნელობის შესწორება?', 0)
INSERT INTO [dbo].[trtResourceTranslation] ([idfsResource], [idfsLanguage], [strResourceString], [intRowStatus]) VALUES (3393, 10049004, N'შეყვანილი თარიღი უნდა იყოს უფრო ადრე ვიდრე "სტატისტიკური მონაცემის პერიოდი- მდე"', 0)
INSERT INTO [dbo].[trtResourceTranslation] ([idfsResource], [idfsLanguage], [strResourceString], [intRowStatus]) VALUES (3394, 10049004, N'„დაწყების თარიღი - მდე პერიოდისათვის უნდა იყოს - სტატისტიკური მონაცემების პერიოდის - დან შემდეგ.', 0)
INSERT INTO [dbo].[trtResourceTranslation] ([idfsResource], [idfsLanguage], [strResourceString], [intRowStatus]) VALUES (3404, 10049004, N' დაავადების შერჩეული მნიშვნელობა არ ემთხვევა პირის სქესს.', 0)
INSERT INTO [dbo].[trtResourceTranslation] ([idfsResource], [idfsLanguage], [strResourceString], [intRowStatus]) VALUES (3405, 10049004, N'დაავადების შერჩეული მნიშვნელობა არ ემთხვევა პირის ასაკს.', 0)
INSERT INTO [dbo].[trtResourceTranslation] ([idfsResource], [idfsLanguage], [strResourceString], [intRowStatus]) VALUES (3407, 10049004, N'ჩანაწერი შენახულია წარმატებით. ჩანაწერი ID არის {0}', 0)
INSERT INTO [dbo].[trtResourceTranslation] ([idfsResource], [idfsLanguage], [strResourceString], [intRowStatus]) VALUES (3408, 10049004, N'დაავადების მნიშვნელობა და მასთან დაკავშირებული დაავადების ანგარიშები არ შეიძლება იყოს ერთი და იგივე', 0)
INSERT INTO [dbo].[trtResourceTranslation] ([idfsResource], [idfsLanguage], [strResourceString], [intRowStatus]) VALUES (3449, 10049004, N'ხაზებში ველების რაოდენობა არასწორია.  ხაზი უნდა მოიცავდეს 12 ველს, რომლებიც ერთმანეთისაგან განცალკევებული იქნება მძიმეთი. ', 0)
INSERT INTO [dbo].[trtResourceTranslation] ([idfsResource], [idfsLanguage], [strResourceString], [intRowStatus]) VALUES (3450, 10049004, N'სტატისტიკური მონაცემის ტიპი არასწორია.  ''{0}'' მნიშვნელობა ან ცარიელია ან რეფერენტულ ცხრილში მისი პოვნა შესაძლებელი არ არის.', 0)
INSERT INTO [dbo].[trtResourceTranslation] ([idfsResource], [idfsLanguage], [strResourceString], [intRowStatus]) VALUES (3451, 10049004, N'სტატისტიკური მნიშვნელობა არასწორია.   ''{0}''- ის მთელ რიცხვად გადაკეთება შესაძლებელი არ არის.', 0)
INSERT INTO [dbo].[trtResourceTranslation] ([idfsResource], [idfsLanguage], [strResourceString], [intRowStatus]) VALUES (3452, 10049004, N'თარიღის ფორმატი არასწორია.  ''{0}'' - ის თარიღად გადაკეთება შესაძლებელი არ არის.  ყველა თარიღი წარმოდგენილი უნდა იყოს შემდეგ ფორმატში. ''დღე.თვე.წელიწადი''.', 0)
INSERT INTO [dbo].[trtResourceTranslation] ([idfsResource], [idfsLanguage], [strResourceString], [intRowStatus]) VALUES (3453, 10049004, N'{0}'' თარიღი არ არის  თვის დაწყების სწორი თარიღი', 0)
INSERT INTO [dbo].[trtResourceTranslation] ([idfsResource], [idfsLanguage], [strResourceString], [intRowStatus]) VALUES (3454, 10049004, N'{0}'' თარიღი არ არის კვარტალის  დაწყების  სწორი თარიღი', 0)
INSERT INTO [dbo].[trtResourceTranslation] ([idfsResource], [idfsLanguage], [strResourceString], [intRowStatus]) VALUES (3455, 10049004, N'{0}'' თარიღი არ არის კვირის დაწყების სწორი თარიღი ', 0)
INSERT INTO [dbo].[trtResourceTranslation] ([idfsResource], [idfsLanguage], [strResourceString], [intRowStatus]) VALUES (3456, 10049004, N'{0}'' თარიღი არ არის წლის დაწყების სწორი  თარიღი', 0)
INSERT INTO [dbo].[trtResourceTranslation] ([idfsResource], [idfsLanguage], [strResourceString], [intRowStatus]) VALUES (3457, 10049004, N'ქვეყნის დასახელება არასწორია.  ''{0}'' მნიშვნელობა ან ცარიელია ან რეფერენტულ ცხრილში მისი პოვნა შესაძლებელი არ არის. ', 0)
INSERT INTO [dbo].[trtResourceTranslation] ([idfsResource], [idfsLanguage], [strResourceString], [intRowStatus]) VALUES (3458, 10049004, N'რეგიონის დასახელება არასწორია. ''{0}'' მნიშვნელობა ან ცარიელია ან რეფერენტულ ცხრილში მისი პოვნა შესაძლებელი არ არის.', 0)
INSERT INTO [dbo].[trtResourceTranslation] ([idfsResource], [idfsLanguage], [strResourceString], [intRowStatus]) VALUES (3459, 10049004, N'რაიონის დასახელება არასწორია. ''{0}'' მნიშვნელობა ან ცარიელია ან რეფერენტულ ცხრილში მისი პოვნა შესაძლებელი არ არის.', 0)
INSERT INTO [dbo].[trtResourceTranslation] ([idfsResource], [idfsLanguage], [strResourceString], [intRowStatus]) VALUES (3460, 10049004, N'დასახლების დასახელება არასწორია. ''{0}'' მნიშვნელობა ან ცარიელია ან რეფერენტულ ცხრილში მისი პოვნა შესაძლებელი არ არის.', 0)
INSERT INTO [dbo].[trtResourceTranslation] ([idfsResource], [idfsLanguage], [strResourceString], [intRowStatus]) VALUES (3461, 10049004, N'პარამეტრის დასახელება არასწორია. ''{0}'' მნიშვნელობა ან ცარიელია  ან რეფერენტულ ცხრილში მისი პოვნა შესაძლებელი არ არის.', 0)
INSERT INTO [dbo].[trtResourceTranslation] ([idfsResource], [idfsLanguage], [strResourceString], [intRowStatus]) VALUES (3462, 10049004, N'აკლია ველი', 0)
INSERT INTO [dbo].[trtResourceTranslation] ([idfsResource], [idfsLanguage], [strResourceString], [intRowStatus]) VALUES (3463, 10049004, N'ჩანს რომ  {0} ადგილის მონაცემები დამახინჯებულია.', 0)
INSERT INTO [dbo].[trtResourceTranslation] ([idfsResource], [idfsLanguage], [strResourceString], [intRowStatus]) VALUES (3464, 10049004, N'მონაცემების იმპორტირების თარიღი', 0)
INSERT INTO [dbo].[trtResourceTranslation] ([idfsResource], [idfsLanguage], [strResourceString], [intRowStatus]) VALUES (3465, 10049004, N'იმ მომხმარებლის სახელი, რომელმაც დაიწყო  მონაცემთა იმპორტირება', 0)
INSERT INTO [dbo].[trtResourceTranslation] ([idfsResource], [idfsLanguage], [strResourceString], [intRowStatus]) VALUES (3466, 10049004, N'< იმპორტირებული ჩანაწერების რეალური რაოდენობა > <იმპორტირებულ ფაილში ჩანაწერების რაოდენობაზე> ჩანაწერები იმპორტირებულია', 0)
INSERT INTO [dbo].[trtResourceTranslation] ([idfsResource], [idfsLanguage], [strResourceString], [intRowStatus]) VALUES (3467, 10049004, N'სტატისტიკურ მონაცემთა იმპორტირების აღწერა', 0)
INSERT INTO [dbo].[trtResourceTranslation] ([idfsResource], [idfsLanguage], [strResourceString], [intRowStatus]) VALUES (3469, 10049004, N'ვეტერინარული დაავადების აგრეგირებული ქმედებების ანგარიშზე დაბრუნება', 0)
INSERT INTO [dbo].[trtResourceTranslation] ([idfsResource], [idfsLanguage], [strResourceString], [intRowStatus]) VALUES (3473, 10049004, N'ხაზი {0}, სვეტი {1}', 0)
INSERT INTO [dbo].[trtResourceTranslation] ([idfsResource], [idfsLanguage], [strResourceString], [intRowStatus]) VALUES (3529, 10049004, N'მონაცემების იმპორტირების დროს დაშვებული იქნა შეცდომები.  მომდევნო ხაზების იმპორტირება არ მოხდა ვინაიდან შეიცავდა შეცდომებს.', 0)
INSERT INTO [dbo].[trtResourceTranslation] ([idfsResource], [idfsLanguage], [strResourceString], [intRowStatus]) VALUES (3531, 10049004, N'ფაილის ფორმატი არასწორია.  გთხოვთ შეარჩიეთ  ფაილის სათანადო ფორმატი', 0)
INSERT INTO [dbo].[trtResourceTranslation] ([idfsResource], [idfsLanguage], [strResourceString], [intRowStatus]) VALUES (3533, 10049004, N'შემთხვევის კითხვარი', 0)
INSERT INTO [dbo].[trtResourceTranslation] ([idfsResource], [idfsLanguage], [strResourceString], [intRowStatus]) VALUES (3591, 10049004, N'არ არის შესაძლებელი დასრულდეს დედუბლიკაცია თუკი ჩანაწერი მოიცავს ერთ ჯოგზე მეტს', 0)
INSERT INTO [dbo].[trtResourceTranslation] ([idfsResource], [idfsLanguage], [strResourceString], [intRowStatus]) VALUES (3592, 10049004, N'არ არის შესაძლებელი დასრულდეს დედუბლიკაცია თუკი ჩანაწერი მოიცავს ერთ სახეობაზე მეტს', 0)
INSERT INTO [dbo].[trtResourceTranslation] ([idfsResource], [idfsLanguage], [strResourceString], [intRowStatus]) VALUES (3593, 10049004, N'არ არის შესაძლებელი სხვადასხვა სახეობების მქონე ჩანაწერების დედუბლიკაციის დასრულება', 0)
INSERT INTO [dbo].[trtResourceTranslation] ([idfsResource], [idfsLanguage], [strResourceString], [intRowStatus]) VALUES (3594, 10049004, N'დეტალები მონაცემთა აუდიტის ტრანსაქციის შესახებ', 0)
INSERT INTO [dbo].[trtResourceTranslation] ([idfsResource], [idfsLanguage], [strResourceString], [intRowStatus]) VALUES (3600, 10049004, N'გადარჩენილთა/შეცვლილთა (ანგარიში/ჩანაწერის იდენტიფიკატორი)', 0)
INSERT INTO [dbo].[trtResourceTranslation] ([idfsResource], [idfsLanguage], [strResourceString], [intRowStatus]) VALUES (3601, 10049004, N'ველის შერჩევის იდენტიფიკატორი', 0)
INSERT INTO [dbo].[trtResourceTranslation] ([idfsResource], [idfsLanguage], [strResourceString], [intRowStatus]) VALUES (3618, 10049004, N'დაუკავშირდით დაწესებულებას', 0)
INSERT INTO [dbo].[trtResourceTranslation] ([idfsResource], [idfsLanguage], [strResourceString], [intRowStatus]) VALUES (3623, 10049004, N'არქივიდან გათიშვა', 0)
INSERT INTO [dbo].[trtResourceTranslation] ([idfsResource], [idfsLanguage], [strResourceString], [intRowStatus]) VALUES (3652, 10049004, N'აფეთქებაში ჩართული პირის ძებნა', 0)
INSERT INTO [dbo].[trtResourceTranslation] ([idfsResource], [idfsLanguage], [strResourceString], [intRowStatus]) VALUES (3653, 10049004, N'ფერმის ძიება, სადაც მოხდა აფეთქება', 0)
INSERT INTO [dbo].[trtResourceTranslation] ([idfsResource], [idfsLanguage], [strResourceString], [intRowStatus]) VALUES (3654, 10049004, N'ადამიანის  დაავადების ანგარიშის იმპორტირება', 0)
INSERT INTO [dbo].[trtResourceTranslation] ([idfsResource], [idfsLanguage], [strResourceString], [intRowStatus]) VALUES (3655, 10049004, N'ვეტერინარული დაავადების ანგარიშის იმპორტირება', 0)
INSERT INTO [dbo].[trtResourceTranslation] ([idfsResource], [idfsLanguage], [strResourceString], [intRowStatus]) VALUES (3656, 10049004, N'ადამიანის დაავადების შემთხვევა შენახულია წარმატებით. ახალი შემთხვევის  ID: {0}', 0)
INSERT INTO [dbo].[trtResourceTranslation] ([idfsResource], [idfsLanguage], [strResourceString], [intRowStatus]) VALUES (3662, 10049004, N'შემთხვევა/ფერმის მესაკუთრე', 0)
INSERT INTO [dbo].[trtResourceTranslation] ([idfsResource], [idfsLanguage], [strResourceString], [intRowStatus]) VALUES (3665, 10049004, N'შემთხვევა/ფერმის სტატუსი', 0)
INSERT INTO [dbo].[trtResourceTranslation] ([idfsResource], [idfsLanguage], [strResourceString], [intRowStatus]) VALUES (3669, 10049004, N' ბადის კონფიგურაციის შენახვა', 0)
INSERT INTO [dbo].[trtResourceTranslation] ([idfsResource], [idfsLanguage], [strResourceString], [intRowStatus]) VALUES (3695, 10049004, N'აფეთქების პარამეტრებზე დაბრუნება', 0)
INSERT INTO [dbo].[trtResourceTranslation] ([idfsResource], [idfsLanguage], [strResourceString], [intRowStatus]) VALUES (3696, 10049004, N'გადადით აფეთქების სესიაზე', 0)
INSERT INTO [dbo].[trtResourceTranslation] ([idfsResource], [idfsLanguage], [strResourceString], [intRowStatus]) VALUES (3706, 10049004, N'თაროს დასახელება', 0)
INSERT INTO [dbo].[trtResourceTranslation] ([idfsResource], [idfsLanguage], [strResourceString], [intRowStatus]) VALUES (3708, 10049004, N'სტელაჟის დასახელება', 0)
INSERT INTO [dbo].[trtResourceTranslation] ([idfsResource], [idfsLanguage], [strResourceString], [intRowStatus]) VALUES (3709, 10049004, N'ბოქსის დასახელება', 0)
INSERT INTO [dbo].[trtResourceTranslation] ([idfsResource], [idfsLanguage], [strResourceString], [intRowStatus]) VALUES (3720, 10049004, N'თაროს დასახელება', 0)
INSERT INTO [dbo].[trtResourceTranslation] ([idfsResource], [idfsLanguage], [strResourceString], [intRowStatus]) VALUES (3722, 10049004, N'სტელაჟის დასახელება', 0)
INSERT INTO [dbo].[trtResourceTranslation] ([idfsResource], [idfsLanguage], [strResourceString], [intRowStatus]) VALUES (3723, 10049004, N'ბოქსის დასახელება', 0)
INSERT INTO [dbo].[trtResourceTranslation] ([idfsResource], [idfsLanguage], [strResourceString], [intRowStatus]) VALUES (3734, 10049004, N'თაროს დასახელება', 0)
INSERT INTO [dbo].[trtResourceTranslation] ([idfsResource], [idfsLanguage], [strResourceString], [intRowStatus]) VALUES (3736, 10049004, N'სტელაჟის დასახელება', 0)
INSERT INTO [dbo].[trtResourceTranslation] ([idfsResource], [idfsLanguage], [strResourceString], [intRowStatus]) VALUES (3737, 10049004, N'ბოქსის დასახელება', 0)
INSERT INTO [dbo].[trtResourceTranslation] ([idfsResource], [idfsLanguage], [strResourceString], [intRowStatus]) VALUES (3739, 10049004, N'მონაცემთა ბაზაში ნაპოვნია ჩანაწერი იგივე ფერმის მისამართითა და  იგივე ფერმის მესაკუთრით. გსურთ ფერმის ჩანაწერის შექმნა?', 0)
INSERT INTO [dbo].[trtResourceTranslation] ([idfsResource], [idfsLanguage], [strResourceString], [intRowStatus]) VALUES (3915, 10049004, N'გსურთ ამ პარამეტრის წაშლა?', 0)
INSERT INTO [dbo].[trtResourceTranslation] ([idfsResource], [idfsLanguage], [strResourceString], [intRowStatus]) VALUES (3922, 10049004, N'არ არის შესაძლებელი სხვადასხვა ფერმებიდან  ჩანაწერების დედუბლიკაციის დასრულება', 0)
INSERT INTO [dbo].[trtResourceTranslation] ([idfsResource], [idfsLanguage], [strResourceString], [intRowStatus]) VALUES (3923, 10049004, N'ფუნქციები', 0)
INSERT INTO [dbo].[trtResourceTranslation] ([idfsResource], [idfsLanguage], [strResourceString], [intRowStatus]) VALUES (4232, 10049004, N'დეტალები ანგარიშის რიგის შესახებ', 0)
INSERT INTO [dbo].[trtResourceTranslation] ([idfsResource], [idfsLanguage], [strResourceString], [intRowStatus]) VALUES (4233, 10049004, N'სავალდებულოა სულ მცირე ერთი დაავადება/ნიმუშის კომბინაცია', 0)
INSERT INTO [dbo].[trtResourceTranslation] ([idfsResource], [idfsLanguage], [strResourceString], [intRowStatus]) VALUES (4234, 10049004, N'სავალდებულოა სულ მცირე ერთი დაავადება/სახეობა/ნიმუშის კომბინაცია', 0)
INSERT INTO [dbo].[trtResourceTranslation] ([idfsResource], [idfsLanguage], [strResourceString], [intRowStatus]) VALUES (4238, 10049004, N'პროცესის ტიპი', 0)
INSERT INTO [dbo].[trtResourceTranslation] ([idfsResource], [idfsLanguage], [strResourceString], [intRowStatus]) VALUES (4239, 10049004, N'ტექსტში შეცდომაა', 0)
INSERT INTO [dbo].[trtResourceTranslation] ([idfsResource], [idfsLanguage], [strResourceString], [intRowStatus]) VALUES (4240, 10049004, N'პროცესის ID', 0)
INSERT INTO [dbo].[trtResourceTranslation] ([idfsResource], [idfsLanguage], [strResourceString], [intRowStatus]) VALUES (4241, 10049004, N'ქმედების თარიღი', 0)
INSERT INTO [dbo].[trtResourceTranslation] ([idfsResource], [idfsLanguage], [strResourceString], [intRowStatus]) VALUES (4244, 10049004, N'ობიექტის ID', 0)
INSERT INTO [dbo].[trtResourceTranslation] ([idfsResource], [idfsLanguage], [strResourceString], [intRowStatus]) VALUES (4245, 10049004, N'ტექსტში შეცდომაა', 0)
INSERT INTO [dbo].[trtResourceTranslation] ([idfsResource], [idfsLanguage], [strResourceString], [intRowStatus]) VALUES (4246, 10049004, N'პროცესის ID', 0)
INSERT INTO [dbo].[trtResourceTranslation] ([idfsResource], [idfsLanguage], [strResourceString], [intRowStatus]) VALUES (4247, 10049004, N'პროცესის ტიპი', 0)
INSERT INTO [dbo].[trtResourceTranslation] ([idfsResource], [idfsLanguage], [strResourceString], [intRowStatus]) VALUES (4369, 10049004, N'თარიღი უნდა იყოს იგივე რაც  სიმპტომების გამოვლენის  თარიღი ან მის შემდეგ და არ უნდა იყოს დიაგნოზის დასმის თარიღის შემდეგ', 0)
INSERT INTO [dbo].[trtResourceTranslation] ([idfsResource], [idfsLanguage], [strResourceString], [intRowStatus]) VALUES (4413, 10049004, N'შედეგის თარიღი უნდა იყოს იგივე ან ტესტის დაწყების თარიღის შემდეგ', 0)
INSERT INTO [dbo].[trtResourceTranslation] ([idfsResource], [idfsLanguage], [strResourceString], [intRowStatus]) VALUES (4465, 10049004, N'არ არის შესაძლებელი  შეიქმნას ორი აგრეგირებული ანგარიში  ერთი და იგივე {0} - {1}  პერიოდში და ადმინისტრაციული ერთეულით.  დაავადების ასეთი აგრეგირებული ანგარიში უკვე არსებობს.  გსურთ ჩანაწერის გახსნა?', 0)
INSERT INTO [dbo].[trtResourceTranslation] ([idfsResource], [idfsLanguage], [strResourceString], [intRowStatus]) VALUES (4466, 10049004, N'ტესტის დაწყების თარიღი უნდა იყოს იგივე რაც ნიმუშის მიღების თარიღი ან მის შემდეგ', 0)
INSERT INTO [dbo].[trtResourceTranslation] ([idfsResource], [idfsLanguage], [strResourceString], [intRowStatus]) VALUES (4471, 10049004, N'ვექტორული ზედამხედველობის სესიების ჩამონათვალი', 0)
INSERT INTO [dbo].[trtResourceTranslation] ([idfsResource], [idfsLanguage], [strResourceString], [intRowStatus]) VALUES (4491, 10049004, N'უსაფრთხოების მოვლენათა აღრიცხვის ჟურნალი', 0)
INSERT INTO [dbo].[trtResourceTranslation] ([idfsResource], [idfsLanguage], [strResourceString], [intRowStatus]) VALUES (4500, 10049004, N'აღების თარიღი უნდა იყოს იგივე რაც იდენტიფიცირების თარიღი ან მის შემდეგ', 0)
INSERT INTO [dbo].[trtResourceTranslation] ([idfsResource], [idfsLanguage], [strResourceString], [intRowStatus]) VALUES (4501, 10049004, N'იდენტიფიცირების თარიღი უნდა იყოს იგივე ან სესიის დაწყების თარიღის შემდეგ', 0)
INSERT INTO [dbo].[trtResourceTranslation] ([idfsResource], [idfsLanguage], [strResourceString], [intRowStatus]) VALUES (4502, 10049004, N'იდენტიფიცირების თარიღი უნდა იყოს იგივე ან აღების თარიღის შემდეგ', 0)
INSERT INTO [dbo].[trtResourceTranslation] ([idfsResource], [idfsLanguage], [strResourceString], [intRowStatus]) VALUES (4503, 10049004, N'ადამიანის ეპიდემიის შემთხვევის ფორმა', 0)
INSERT INTO [dbo].[trtResourceTranslation] ([idfsResource], [idfsLanguage], [strResourceString], [intRowStatus]) VALUES (4504, 10049004, N'ბეჭდვის თარიღი', 0)
INSERT INTO [dbo].[trtResourceTranslation] ([idfsResource], [idfsLanguage], [strResourceString], [intRowStatus]) VALUES (4505, 10049004, N'ბეჭდვის დრო', 0)
INSERT INTO [dbo].[trtResourceTranslation] ([idfsResource], [idfsLanguage], [strResourceString], [intRowStatus]) VALUES (4506, 10049004, N'ენა', 0)
INSERT INTO [dbo].[trtResourceTranslation] ([idfsResource], [idfsLanguage], [strResourceString], [intRowStatus]) VALUES (4508, 10049004, N'პირის ID', 0)
INSERT INTO [dbo].[trtResourceTranslation] ([idfsResource], [idfsLanguage], [strResourceString], [intRowStatus]) VALUES (4509, 10049004, N'დასახელება', 0)
INSERT INTO [dbo].[trtResourceTranslation] ([idfsResource], [idfsLanguage], [strResourceString], [intRowStatus]) VALUES (4510, 10049004, N'შემთხვევის კლასიფიკაცია', 0)
INSERT INTO [dbo].[trtResourceTranslation] ([idfsResource], [idfsLanguage], [strResourceString], [intRowStatus]) VALUES (4511, 10049004, N'შეყვანის თარიღი', 0)
INSERT INTO [dbo].[trtResourceTranslation] ([idfsResource], [idfsLanguage], [strResourceString], [intRowStatus]) VALUES (4512, 10049004, N'უკანასკნელი დამახსოვრების თარიღი', 0)
INSERT INTO [dbo].[trtResourceTranslation] ([idfsResource], [idfsLanguage], [strResourceString], [intRowStatus]) VALUES (4513, 10049004, N'ეპიდაფეთქების ID', 0)
INSERT INTO [dbo].[trtResourceTranslation] ([idfsResource], [idfsLanguage], [strResourceString], [intRowStatus]) VALUES (4514, 10049004, N'დაწყების თარიღი', 0)
INSERT INTO [dbo].[trtResourceTranslation] ([idfsResource], [idfsLanguage], [strResourceString], [intRowStatus]) VALUES (4515, 10049004, N'დასრულების თარიღი', 0)
INSERT INTO [dbo].[trtResourceTranslation] ([idfsResource], [idfsLanguage], [strResourceString], [intRowStatus]) VALUES (4516, 10049004, N'დაავადება', 0)
INSERT INTO [dbo].[trtResourceTranslation] ([idfsResource], [idfsLanguage], [strResourceString], [intRowStatus]) VALUES (4517, 10049004, N'სტატუსი', 0)
INSERT INTO [dbo].[trtResourceTranslation] ([idfsResource], [idfsLanguage], [strResourceString], [intRowStatus]) VALUES (4518, 10049004, N'ტიპი', 0)
INSERT INTO [dbo].[trtResourceTranslation] ([idfsResource], [idfsLanguage], [strResourceString], [intRowStatus]) VALUES (4520, 10049004, N'შეტყობინება გაგზავნილია დაწესებულების მიერ', 0)
INSERT INTO [dbo].[trtResourceTranslation] ([idfsResource], [idfsLanguage], [strResourceString], [intRowStatus]) VALUES (4522, 10049004, N'შეტყობინება მიღებულია დაწესებულების მიერ', 0)
INSERT INTO [dbo].[trtResourceTranslation] ([idfsResource], [idfsLanguage], [strResourceString], [intRowStatus]) VALUES (4523, 10049004, N'ვის მიერ არის შეტყობინება მიღებული-სახელი', 0)
INSERT INTO [dbo].[trtResourceTranslation] ([idfsResource], [idfsLanguage], [strResourceString], [intRowStatus]) VALUES (4524, 10049004, N'Outbreak Case Summary', 0)
INSERT INTO [dbo].[trtResourceTranslation] ([idfsResource], [idfsLanguage], [strResourceString], [intRowStatus]) VALUES (4525, 10049004, N'Case Details', 0)
INSERT INTO [dbo].[trtResourceTranslation] ([idfsResource], [idfsLanguage], [strResourceString], [intRowStatus]) VALUES (4526, 10049004, N'ეპიდაფეთქების დეტალები', 0)
INSERT INTO [dbo].[trtResourceTranslation] ([idfsResource], [idfsLanguage], [strResourceString], [intRowStatus]) VALUES (4527, 10049004, N'რეგიონი', 0)
INSERT INTO [dbo].[trtResourceTranslation] ([idfsResource], [idfsLanguage], [strResourceString], [intRowStatus]) VALUES (4528, 10049004, N'რაიონი', 0)
INSERT INTO [dbo].[trtResourceTranslation] ([idfsResource], [idfsLanguage], [strResourceString], [intRowStatus]) VALUES (4529, 10049004, N'ქალაქი ან სოფელი', 0)
INSERT INTO [dbo].[trtResourceTranslation] ([idfsResource], [idfsLanguage], [strResourceString], [intRowStatus]) VALUES (4530, 10049004, N'ქუჩა', 0)
INSERT INTO [dbo].[trtResourceTranslation] ([idfsResource], [idfsLanguage], [strResourceString], [intRowStatus]) VALUES (4531, 10049004, N'სახლი/კორპუსი', 0)
INSERT INTO [dbo].[trtResourceTranslation] ([idfsResource], [idfsLanguage], [strResourceString], [intRowStatus]) VALUES (4532, 10049004, N'ბინა/ერთეული', 0)
INSERT INTO [dbo].[trtResourceTranslation] ([idfsResource], [idfsLanguage], [strResourceString], [intRowStatus]) VALUES (4533, 10049004, N'საფოსტო ინდექსი', 0)
INSERT INTO [dbo].[trtResourceTranslation] ([idfsResource], [idfsLanguage], [strResourceString], [intRowStatus]) VALUES (4534, 10049004, N'გრძედი', 0)
INSERT INTO [dbo].[trtResourceTranslation] ([idfsResource], [idfsLanguage], [strResourceString], [intRowStatus]) VALUES (4535, 10049004, N'განედი', 0)
INSERT INTO [dbo].[trtResourceTranslation] ([idfsResource], [idfsLanguage], [strResourceString], [intRowStatus]) VALUES (4536, 10049004, N'შეტყობინება', 0)
INSERT INTO [dbo].[trtResourceTranslation] ([idfsResource], [idfsLanguage], [strResourceString], [intRowStatus]) VALUES (4537, 10049004, N'კლინიკური ინფორმაცია', 0)
INSERT INTO [dbo].[trtResourceTranslation] ([idfsResource], [idfsLanguage], [strResourceString], [intRowStatus]) VALUES (4538, 10049004, N'შემთხვევის სტატუსი', 0)
INSERT INTO [dbo].[trtResourceTranslation] ([idfsResource], [idfsLanguage], [strResourceString], [intRowStatus]) VALUES (4540, 10049004, N'Date of Disease', 0)
INSERT INTO [dbo].[trtResourceTranslation] ([idfsResource], [idfsLanguage], [strResourceString], [intRowStatus]) VALUES (4541, 10049004, N'საავადმყოფოს დასახელება', 0)
INSERT INTO [dbo].[trtResourceTranslation] ([idfsResource], [idfsLanguage], [strResourceString], [intRowStatus]) VALUES (4542, 10049004, N'მიმართვის /ჰოსპიტალიზაციის თარიღი', 0)
INSERT INTO [dbo].[trtResourceTranslation] ([idfsResource], [idfsLanguage], [strResourceString], [intRowStatus]) VALUES (4543, 10049004, N'გაწერის თარიღი', 0)
INSERT INTO [dbo].[trtResourceTranslation] ([idfsResource], [idfsLanguage], [strResourceString], [intRowStatus]) VALUES (4544, 10049004, N'ნიმუშის აღებამდე ჩატარებული სპეციფიური თერაპია', 0)
INSERT INTO [dbo].[trtResourceTranslation] ([idfsResource], [idfsLanguage], [strResourceString], [intRowStatus]) VALUES (4545, 10049004, N'დასახელება', 0)
INSERT INTO [dbo].[trtResourceTranslation] ([idfsResource], [idfsLanguage], [strResourceString], [intRowStatus]) VALUES (4546, 10049004, N'დოზა', 0)
INSERT INTO [dbo].[trtResourceTranslation] ([idfsResource], [idfsLanguage], [strResourceString], [intRowStatus]) VALUES (4547, 10049004, N'თარიღი', 0)
INSERT INTO [dbo].[trtResourceTranslation] ([idfsResource], [idfsLanguage], [strResourceString], [intRowStatus]) VALUES (4548, 10049004, N'ვაქცინაციები', 0)
INSERT INTO [dbo].[trtResourceTranslation] ([idfsResource], [idfsLanguage], [strResourceString], [intRowStatus]) VALUES (4549, 10049004, N'Outbreak Investigation', 0)
INSERT INTO [dbo].[trtResourceTranslation] ([idfsResource], [idfsLanguage], [strResourceString], [intRowStatus]) VALUES (4550, 10049004, N'ორგანიზაცია რომელიც აწარმოებს კვლევას', 0)
INSERT INTO [dbo].[trtResourceTranslation] ([idfsResource], [idfsLanguage], [strResourceString], [intRowStatus]) VALUES (4551, 10049004, N'თანამშრომელი', 0)
INSERT INTO [dbo].[trtResourceTranslation] ([idfsResource], [idfsLanguage], [strResourceString], [intRowStatus]) VALUES (4552, 10049004, N'კვლევის დაწყების თარიღი', 0)
INSERT INTO [dbo].[trtResourceTranslation] ([idfsResource], [idfsLanguage], [strResourceString], [intRowStatus]) VALUES (4553, 10049004, N'საწყისი შემთხვევა', 0)
INSERT INTO [dbo].[trtResourceTranslation] ([idfsResource], [idfsLanguage], [strResourceString], [intRowStatus]) VALUES (4554, 10049004, N'Additional Comments', 0)
INSERT INTO [dbo].[trtResourceTranslation] ([idfsResource], [idfsLanguage], [strResourceString], [intRowStatus]) VALUES (4555, 10049004, N'Case Monitoring', 0)
INSERT INTO [dbo].[trtResourceTranslation] ([idfsResource], [idfsLanguage], [strResourceString], [intRowStatus]) VALUES (4556, 10049004, N'Monitoring Date', 0)
INSERT INTO [dbo].[trtResourceTranslation] ([idfsResource], [idfsLanguage], [strResourceString], [intRowStatus]) VALUES (4557, 10049004, N'Contacts', 0)
INSERT INTO [dbo].[trtResourceTranslation] ([idfsResource], [idfsLanguage], [strResourceString], [intRowStatus]) VALUES (4559, 10049004, N'Contact Name', 0)
INSERT INTO [dbo].[trtResourceTranslation] ([idfsResource], [idfsLanguage], [strResourceString], [intRowStatus]) VALUES (4560, 10049004, N'კავშირი', 0)
INSERT INTO [dbo].[trtResourceTranslation] ([idfsResource], [idfsLanguage], [strResourceString], [intRowStatus]) VALUES (4561, 10049004, N'ბოლო კონტაქტის თარიღი', 0)
INSERT INTO [dbo].[trtResourceTranslation] ([idfsResource], [idfsLanguage], [strResourceString], [intRowStatus]) VALUES (4562, 10049004, N'ბოლო კონტაქტის ადგილი', 0)
INSERT INTO [dbo].[trtResourceTranslation] ([idfsResource], [idfsLanguage], [strResourceString], [intRowStatus]) VALUES (4563, 10049004, N'Contact Status', 0)
INSERT INTO [dbo].[trtResourceTranslation] ([idfsResource], [idfsLanguage], [strResourceString], [intRowStatus]) VALUES (4564, 10049004, N'Contact Comment', 0)
INSERT INTO [dbo].[trtResourceTranslation] ([idfsResource], [idfsLanguage], [strResourceString], [intRowStatus]) VALUES (4565, 10049004, N'ნიმუშები', 0)
INSERT INTO [dbo].[trtResourceTranslation] ([idfsResource], [idfsLanguage], [strResourceString], [intRowStatus]) VALUES (4566, 10049004, N'ნიმუშების აღება', 0)
INSERT INTO [dbo].[trtResourceTranslation] ([idfsResource], [idfsLanguage], [strResourceString], [intRowStatus]) VALUES (4567, 10049004, N'თუ "არა", პასუხი დაასაბუთეთ', 0)
INSERT INTO [dbo].[trtResourceTranslation] ([idfsResource], [idfsLanguage], [strResourceString], [intRowStatus]) VALUES (4568, 10049004, N'ნიმუშების აღებასთან დაკავშირებული შენიშვნები და დამატებითი ტესტების მოთხოვნები', 0)
INSERT INTO [dbo].[trtResourceTranslation] ([idfsResource], [idfsLanguage], [strResourceString], [intRowStatus]) VALUES (4569, 10049004, N'ნიმუშის ტიპი', 0)
INSERT INTO [dbo].[trtResourceTranslation] ([idfsResource], [idfsLanguage], [strResourceString], [intRowStatus]) VALUES (4570, 10049004, N'ნიმუშის ადგილობრივი ID', 0)
INSERT INTO [dbo].[trtResourceTranslation] ([idfsResource], [idfsLanguage], [strResourceString], [intRowStatus]) VALUES (4571, 10049004, N'აღების თარიღი', 0)
INSERT INTO [dbo].[trtResourceTranslation] ([idfsResource], [idfsLanguage], [strResourceString], [intRowStatus]) VALUES (4572, 10049004, N'გაგზავ-ნის თარიღი', 0)
INSERT INTO [dbo].[trtResourceTranslation] ([idfsResource], [idfsLanguage], [strResourceString], [intRowStatus]) VALUES (4573, 10049004, N'მიღების თარიღი', 0)
INSERT INTO [dbo].[trtResourceTranslation] ([idfsResource], [idfsLanguage], [strResourceString], [intRowStatus]) VALUES (4574, 10049004, N'ნიმუშის მდგომარეობა მიღებისას', 0)
INSERT INTO [dbo].[trtResourceTranslation] ([idfsResource], [idfsLanguage], [strResourceString], [intRowStatus]) VALUES (4575, 10049004, N'კომენტარი', 0)
INSERT INTO [dbo].[trtResourceTranslation] ([idfsResource], [idfsLanguage], [strResourceString], [intRowStatus]) VALUES (4576, 10049004, N'ტესტის დასახელე-ბა', 0)
INSERT INTO [dbo].[trtResourceTranslation] ([idfsResource], [idfsLanguage], [strResourceString], [intRowStatus]) VALUES (4577, 10049004, N'ტესტის შედეგი', 0)
INSERT INTO [dbo].[trtResourceTranslation] ([idfsResource], [idfsLanguage], [strResourceString], [intRowStatus]) VALUES (4578, 10049004, N'ტესტირების თარიღი', 0)
INSERT INTO [dbo].[trtResourceTranslation] ([idfsResource], [idfsLanguage], [strResourceString], [intRowStatus]) VALUES (4579, 10049004, N'ნიმუშის ადგილობრივი ID', 0)
INSERT INTO [dbo].[trtResourceTranslation] ([idfsResource], [idfsLanguage], [strResourceString], [intRowStatus]) VALUES (4580, 10049004, N'ნიმუშის ტიპი', 0)
INSERT INTO [dbo].[trtResourceTranslation] ([idfsResource], [idfsLanguage], [strResourceString], [intRowStatus]) VALUES (4581, 10049004, N'ნიმუშის ლაბორატორიული ID', 0)
INSERT INTO [dbo].[trtResourceTranslation] ([idfsResource], [idfsLanguage], [strResourceString], [intRowStatus]) VALUES (4582, 10049004, N'ტესტის დასახელე-ბა', 0)
INSERT INTO [dbo].[trtResourceTranslation] ([idfsResource], [idfsLanguage], [strResourceString], [intRowStatus]) VALUES (4583, 10049004, N'ტესტის შედეგი', 0)
INSERT INTO [dbo].[trtResourceTranslation] ([idfsResource], [idfsLanguage], [strResourceString], [intRowStatus]) VALUES (4584, 10049004, N'Rule in/Rule Out', 0)
INSERT INTO [dbo].[trtResourceTranslation] ([idfsResource], [idfsLanguage], [strResourceString], [intRowStatus]) VALUES (4585, 10049004, N'ვინ მოახდინა ინტერპრეტირება', 0)
INSERT INTO [dbo].[trtResourceTranslation] ([idfsResource], [idfsLanguage], [strResourceString], [intRowStatus]) VALUES (4586, 10049004, N'ვინ მოახდინა ინტერპრეტირება', 0)
INSERT INTO [dbo].[trtResourceTranslation] ([idfsResource], [idfsLanguage], [strResourceString], [intRowStatus]) VALUES (4587, 10049004, N'Validated', 0)
INSERT INTO [dbo].[trtResourceTranslation] ([idfsResource], [idfsLanguage], [strResourceString], [intRowStatus]) VALUES (4588, 10049004, N'გადამოწმების თარიღი', 0)
INSERT INTO [dbo].[trtResourceTranslation] ([idfsResource], [idfsLanguage], [strResourceString], [intRowStatus]) VALUES (4589, 10049004, N'ვინ გადაამოწმა', 0)
INSERT INTO [dbo].[trtResourceTranslation] ([idfsResource], [idfsLanguage], [strResourceString], [intRowStatus]) VALUES (4592, 10049004, N'იდენტიფიცირების თარიღი უნდა იყოს იგივე ან სესიის დახურვის თარიღის შემდეგ', 0)
INSERT INTO [dbo].[trtResourceTranslation] ([idfsResource], [idfsLanguage], [strResourceString], [intRowStatus]) VALUES (4593, 10049004, N'ინფორმაცია ვაქცინაციის შესახებ', 0)
INSERT INTO [dbo].[trtResourceTranslation] ([idfsResource], [idfsLanguage], [strResourceString], [intRowStatus]) VALUES (4642, 10049004, N'შექმნა', 0)
PRINT(N'Operation applied to 199 rows out of 199')

PRINT(N'Add constraints to [dbo].[trtResourceTranslation]')
ALTER TABLE [dbo].[trtResourceTranslation] CHECK CONSTRAINT [FK_trtResourceTranslation_idfsLanguage]
ALTER TABLE [dbo].[trtResourceTranslation] WITH CHECK CHECK CONSTRAINT [FK_trtResourceTranslation_SourceSystemNameID]
ALTER TABLE [dbo].[trtResourceTranslation] CHECK CONSTRAINT [FK_trtResourceTranslation_trtResource]

PRINT(N'Add constraints to [dbo].[trtResource]')
ALTER TABLE [dbo].[trtResource] WITH CHECK CHECK CONSTRAINT [FK_trtResource_idfsResourceType]
ALTER TABLE [dbo].[trtResource] WITH CHECK CHECK CONSTRAINT [FK_trtResource_SourceSystemNameID]
ALTER TABLE [dbo].[trtResourceSetToResource] CHECK CONSTRAINT [FK_trtResourceSetToResource_trtResource]
--COMMIT TRANSACTION
GO
