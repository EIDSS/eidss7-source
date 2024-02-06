/*
Run this script on:

100.104.1.189,57355\NGSQLTEST1.EIDSS7_GG    -  This database will be modified

to synchronize it with:

100.104.1.167,49501\NGSQLDEV1.EIDSS7_GG_DT

You are recommended to back up your database before running this script

Script created by SQL Data Compare version 14.4.4.16824 from Red Gate Software Ltd at 1/24/2023 12:30:19 PM

*/
		
SET NUMERIC_ROUNDABORT OFF
GO
SET ANSI_PADDING, ANSI_WARNINGS, CONCAT_NULL_YIELDS_NULL, ARITHABORT, QUOTED_IDENTIFIER, ANSI_NULLS, NOCOUNT ON
GO
SET DATEFORMAT YMD
GO
SET XACT_ABORT ON
GO
SET TRANSACTION ISOLATION LEVEL Serializable
GO
BEGIN TRANSACTION

PRINT(N'Add rows to [dbo].[trtStringNameTranslation]')
INSERT INTO [dbo].[trtStringNameTranslation] ([idfsBaseReference], [idfsLanguage], [strTextString], [intRowStatus]) VALUES (10537010, 10049004, N'ვეტერინარული დაავადების ანგარიშის მონაცემები ხელმისაწვდომი უნდა იყოს ყველა იმ ორგანიზაციების საიტზე, რომლებიც დაკავშირებულია დაავადების ანგარიშთან.  (შეტყობინებაში მითითებული ორგანიზაცია: გამოსაკვლევი ორგანიზაცია,  ნიმუშებში მითითებული ორგანიზაცია, ორგანიზაცია რომელსაც გაეგზავნა ნიმუშები და ნიმუშების ამღები დაწესებულება.', 0)
INSERT INTO [dbo].[trtStringNameTranslation] ([idfsBaseReference], [idfsLanguage], [strTextString], [intRowStatus]) VALUES (10537018, 10049004, N'ვექტორული ზედამხედველობის სესიის მონაცემები ხელმისაწვდომი უნდა იყოს სპეციფიკური ადმინისტრაციული დონის ყველა საიტზე. ვექტორული ზედამხედველობის სესიის მონაცემებზე წვდომა უნდა ქონდეს ყველა იმ საიტს, სადაც დონის მნიშველობა უდრის სესიის რომელიმე სპეციკურ დონეს.  სესიის სპეციფიკური დონეების ჩამონათვალი მოიცავს: საიტის დონეს, სადაც შეიქმნა სესია, სესიის ადგილმდებარეობის დონეს, თუკი შევსებული შესაბამისი ველი', 0)
INSERT INTO [dbo].[trtStringNameTranslation] ([idfsBaseReference], [idfsLanguage], [strTextString], [intRowStatus]) VALUES (10537019, 10049004, N'ვექტორული ზედამხედველობის სესია ხელმისაწვდომი უნდა იყოს ამ სესიისათვის სპეციფიკურ ყველა ორგანიზაციის საიტზე. სპეფიციკური ორგანიზაციების ჩამონათვალი მოიცავს: მონაცემთა აღების დროს მითითებულ ორგანიზაციას, (ნებისმიერი ვექტორის/პულის ამღების დაწესებულება, ორგანიზაცია, რომელიც მითითებულია ვექტორულ მონაცემებში.  ( ვექტორის/პულის მაიდენტიფიცირებელი დაწესებულება) ორგანიზაცია მითითებული ნიმუშებში.  (ადრესატი ორგანიზაცია) საველე ტესტებში მითითებული ორგანიზაცია: (დაწესებულება, სადაც მოხდა საველე ტესტის ჩატარება და ორგანიზაცია მითითებული ლაბორატორიულ ტესტებში: (ლაბორატორიული ტესტების ჩამტარებელი დაწესებულება)', 0)
PRINT(N'Operation applied to 3 rows out of 4')

COMMIT TRANSACTION
GO
