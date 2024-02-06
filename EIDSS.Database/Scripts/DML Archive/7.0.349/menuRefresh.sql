--
-- create a temp table for Georgian and Russian transations 

DROP TABLE IF EXISTS dbo.ZZZ_MenuTranslations

GO


PRINT N'Creating [dbo].[ZZZ_MenuTranslations]';


CREATE TABLE dbo.ZZZ_MenuTranslations
(
	idfsBaseReference BIGINT NOT NULL,
	strkaGE NVARCHAR(2000) COLLATE Cyrillic_General_CI_AS NULL,
	strruRU NVARCHAR(2000) COLLATE Cyrillic_General_CI_AS NULL,
	SourceSystemNameID BIGINT NULL

)

--
-- insert Georgian and Russian transations into temp table

PRINT(N'Add rows to [dbo].[ZZZ_MenuTranslations]')

INSERT INTO [dbo].[ZZZ_MenuTranslations] ([idfsBaseReference], [strkaGE], [strruRU], [SourceSystemNameID]) VALUES (10506002, N'ადამიანის დაავადების შემთხვევა', N'Случай Заболевания Человека ', NULL)
INSERT INTO [dbo].[ZZZ_MenuTranslations] ([idfsBaseReference], [strkaGE], [strruRU], [SourceSystemNameID]) VALUES (10506003, N'ვეტერინარული ', N'Ветеринарный ', NULL)
INSERT INTO [dbo].[ZZZ_MenuTranslations] ([idfsBaseReference], [strkaGE], [strruRU], [SourceSystemNameID]) VALUES (10506004, N'აფეთქება', N'Вспышка', NULL)
INSERT INTO [dbo].[ZZZ_MenuTranslations] ([idfsBaseReference], [strkaGE], [strruRU], [SourceSystemNameID]) VALUES (10506005, N'ვექტორული დაავადება', N'Векторные Заболевания', NULL)
INSERT INTO [dbo].[ZZZ_MenuTranslations] ([idfsBaseReference], [strkaGE], [strruRU], [SourceSystemNameID]) VALUES (10506006, N'ლაბორატორიული', N'Лаборатория', NULL)
INSERT INTO [dbo].[ZZZ_MenuTranslations] ([idfsBaseReference], [strkaGE], [strruRU], [SourceSystemNameID]) VALUES (10506007, N'ადმინისტრაცია', N'Эмфизематозный карбункул (КРС)', NULL)
INSERT INTO [dbo].[ZZZ_MenuTranslations] ([idfsBaseReference], [strkaGE], [strruRU], [SourceSystemNameID]) VALUES (10506008, N'ადმინისტრაცია-კონფიგურაცია', N'L1.2. Название фермы', NULL)
INSERT INTO [dbo].[ZZZ_MenuTranslations] ([idfsBaseReference], [strkaGE], [strruRU], [SourceSystemNameID]) VALUES (10506009, N'ანგარიშები ', N'Отчеты', NULL)
INSERT INTO [dbo].[ZZZ_MenuTranslations] ([idfsBaseReference], [strkaGE], [strruRU], [SourceSystemNameID]) VALUES (10506010, N'გამოსვლა', N'Выход ', NULL)
INSERT INTO [dbo].[ZZZ_MenuTranslations] ([idfsBaseReference], [strkaGE], [strruRU], [SourceSystemNameID]) VALUES (10506011, N'ენა', N'Язык', NULL)
INSERT INTO [dbo].[ZZZ_MenuTranslations] ([idfsBaseReference], [strkaGE], [strruRU], [SourceSystemNameID]) VALUES (10506012, N'მომხმარებლების პარამეტრების დაყენება ', N'Настройки Параметров Пользователя', NULL)
INSERT INTO [dbo].[ZZZ_MenuTranslations] ([idfsBaseReference], [strkaGE], [strruRU], [SourceSystemNameID]) VALUES (10506013, N'პირი', N'Лицо', NULL)
INSERT INTO [dbo].[ZZZ_MenuTranslations] ([idfsBaseReference], [strkaGE], [strruRU], [SourceSystemNameID]) VALUES (10506014, N'პირი', N'Лицо', NULL)
INSERT INTO [dbo].[ZZZ_MenuTranslations] ([idfsBaseReference], [strkaGE], [strruRU], [SourceSystemNameID]) VALUES (10506015, N'დაავადების ანგარიში', N'Профилактические мероприятия', NULL)
INSERT INTO [dbo].[ZZZ_MenuTranslations] ([idfsBaseReference], [strkaGE], [strruRU], [SourceSystemNameID]) VALUES (10506016, N'ადამიანის დაავადების ანგარიში ', N'Отчеты по Заболеваниям Человека', NULL)
INSERT INTO [dbo].[ZZZ_MenuTranslations] ([idfsBaseReference], [strkaGE], [strruRU], [SourceSystemNameID]) VALUES (10506017, N'აგრეგირებული დაავადების ანგარიში ', N'Ботулизм-Факторы риска-Копченая или сушеная рыба-Укажите тип пищевого продукта', NULL)
INSERT INTO [dbo].[ZZZ_MenuTranslations] ([idfsBaseReference], [strkaGE], [strruRU], [SourceSystemNameID]) VALUES (10506018, N'აგრეგირებული დაავადების ანგარიში შეფასება', N'Ботулизм-Факторы риска-Указать контакт или профессию', NULL)
INSERT INTO [dbo].[ZZZ_MenuTranslations] ([idfsBaseReference], [strkaGE], [strruRU], [SourceSystemNameID]) VALUES (10506019, N'აქტიური ზედამხედველობის კამპანია (ადამიანის) ', N'И', NULL)
INSERT INTO [dbo].[ZZZ_MenuTranslations] ([idfsBaseReference], [strkaGE], [strruRU], [SourceSystemNameID]) VALUES (10506020, N'ზედამხედველობის სესია', N'Сессия Надзора', NULL)
INSERT INTO [dbo].[ZZZ_MenuTranslations] ([idfsBaseReference], [strkaGE], [strruRU], [SourceSystemNameID]) VALUES (10506021, N'აბერაციის ანალიზი (ადამიანის)', N'Анализ Аберраций', NULL)
INSERT INTO [dbo].[ZZZ_MenuTranslations] ([idfsBaseReference], [strkaGE], [strruRU], [SourceSystemNameID]) VALUES (10506022, N'ექსპორტირება CISD-ში', N'Столбняк-Клинические симптомы-Ригидность брюшных мышц', NULL)
INSERT INTO [dbo].[ZZZ_MenuTranslations] ([idfsBaseReference], [strkaGE], [strruRU], [SourceSystemNameID]) VALUES (10506025, N'ფერმის', N'Туляремия-Подтвержденный случай (для всех форм)-Тип теста', NULL)
INSERT INTO [dbo].[ZZZ_MenuTranslations] ([idfsBaseReference], [strkaGE], [strruRU], [SourceSystemNameID]) VALUES (10506026, N'ფერმის ჩანაწერი', N'Туляремия-Вероятный-Укус клещей или кровососущих насекомых', NULL)
INSERT INTO [dbo].[ZZZ_MenuTranslations] ([idfsBaseReference], [strkaGE], [strruRU], [SourceSystemNameID]) VALUES (10506027, N'ფრინველის ანგარიში', N'Depth of wound', NULL)
INSERT INTO [dbo].[ZZZ_MenuTranslations] ([idfsBaseReference], [strkaGE], [strruRU], [SourceSystemNameID]) VALUES (10506028, N'შინაური ცხოველის ანგარიში', N'Отчет по Домашнему Скоту', NULL)
INSERT INTO [dbo].[ZZZ_MenuTranslations] ([idfsBaseReference], [strkaGE], [strruRU], [SourceSystemNameID]) VALUES (10506029, N'ფრინველის დაავადების ანგარიში', N'Дни', NULL)
INSERT INTO [dbo].[ZZZ_MenuTranslations] ([idfsBaseReference], [strkaGE], [strruRU], [SourceSystemNameID]) VALUES (10506030, N'შინაური ცხოველის დაავადების ანგარიში', N'Отчеты по Заболеваниям Домашнего Скота', NULL)
INSERT INTO [dbo].[ZZZ_MenuTranslations] ([idfsBaseReference], [strkaGE], [strruRU], [SourceSystemNameID]) VALUES (10506031, N'აბერაციის ანალიზი (ვეტერინარული)', N'Анализ Аберраций', NULL)
INSERT INTO [dbo].[ZZZ_MenuTranslations] ([idfsBaseReference], [strkaGE], [strruRU], [SourceSystemNameID]) VALUES (10506032, N'აგრეგირებუი ანგარიში', N'Ботулизм-Факторы риска-Дата операции', NULL)
INSERT INTO [dbo].[ZZZ_MenuTranslations] ([idfsBaseReference], [strkaGE], [strruRU], [SourceSystemNameID]) VALUES (10506033, N'აგრეგირებული ანგარიშის შეფასება ', N'Ботулизм-Симметричный паралич черепно-мозговых нервов', NULL)
INSERT INTO [dbo].[ZZZ_MenuTranslations] ([idfsBaseReference], [strkaGE], [strruRU], [SourceSystemNameID]) VALUES (10506034, N'აგრეგირებული ქმედებები', N'Ботулизм-Факторы риска-Пункция', NULL)
INSERT INTO [dbo].[ZZZ_MenuTranslations] ([idfsBaseReference], [strkaGE], [strruRU], [SourceSystemNameID]) VALUES (10506035, N'აგერრეგირებული ქმედებების შეჯამება ', N'Ботулизм-Факторы риска-Дата пункции', NULL)
INSERT INTO [dbo].[ZZZ_MenuTranslations] ([idfsBaseReference], [strkaGE], [strruRU], [SourceSystemNameID]) VALUES (10506036, N'აქტიური ზედამხედველობის კამპანია (ვეტერინარული) ', N'И какой-либо из следующих симптомов', NULL)
INSERT INTO [dbo].[ZZZ_MenuTranslations] ([idfsBaseReference], [strkaGE], [strruRU], [SourceSystemNameID]) VALUES (10506037, N'ზედამხედველობის სესია', N'Сессия Надзора', NULL)
INSERT INTO [dbo].[ZZZ_MenuTranslations] ([idfsBaseReference], [strkaGE], [strruRU], [SourceSystemNameID]) VALUES (10506038, N'ლინკი EPINFO-თან (ვეტერინარული)', N'Ссылка на Epi INFO(ветеринария)', NULL)
INSERT INTO [dbo].[ZZZ_MenuTranslations] ([idfsBaseReference], [strkaGE], [strruRU], [SourceSystemNameID]) VALUES (10506040, N'ეპიდაფეთქება', N'Вспышка', NULL)
INSERT INTO [dbo].[ZZZ_MenuTranslations] ([idfsBaseReference], [strkaGE], [strruRU], [SourceSystemNameID]) VALUES (10506041, N'ზედამხეველობის სესია', N'Сессия Надзора', NULL)
INSERT INTO [dbo].[ZZZ_MenuTranslations] ([idfsBaseReference], [strkaGE], [strruRU], [SourceSystemNameID]) VALUES (10506042, N'ნიმუშები', N'Образцы', NULL)
INSERT INTO [dbo].[ZZZ_MenuTranslations] ([idfsBaseReference], [strkaGE], [strruRU], [SourceSystemNameID]) VALUES (10506043, N'გადატანილი', N'Переданные', NULL)
INSERT INTO [dbo].[ZZZ_MenuTranslations] ([idfsBaseReference], [strkaGE], [strruRU], [SourceSystemNameID]) VALUES (10506044, N'ტესტირება', N'Тестирование', NULL)
INSERT INTO [dbo].[ZZZ_MenuTranslations] ([idfsBaseReference], [strkaGE], [strruRU], [SourceSystemNameID]) VALUES (10506045, N'დამტკიცებები', N'Зоонозные заболевания - Область/Регион', NULL)
INSERT INTO [dbo].[ZZZ_MenuTranslations] ([idfsBaseReference], [strkaGE], [strruRU], [SourceSystemNameID]) VALUES (10506046, N'პარტიები', N'Партии', NULL)
INSERT INTO [dbo].[ZZZ_MenuTranslations] ([idfsBaseReference], [strkaGE], [strruRU], [SourceSystemNameID]) VALUES (10506047, N'საყინულები', N'Культивирование вируса', NULL)
INSERT INTO [dbo].[ZZZ_MenuTranslations] ([idfsBaseReference], [strkaGE], [strruRU], [SourceSystemNameID]) VALUES (10506050, N'მონაცემების დაარქივების დაყენების პარამეტრები', N'Другие состояния', NULL)
INSERT INTO [dbo].[ZZZ_MenuTranslations] ([idfsBaseReference], [strkaGE], [strruRU], [SourceSystemNameID]) VALUES (10506051, N'ობიექტის შეტყობინების გამოწერა', N'Подписки на оповещения на объекте', NULL)
INSERT INTO [dbo].[ZZZ_MenuTranslations] ([idfsBaseReference], [strkaGE], [strruRU], [SourceSystemNameID]) VALUES (10506052, N'თანამშრომლები ', N'Указать тип продукта', NULL)
INSERT INTO [dbo].[ZZZ_MenuTranslations] ([idfsBaseReference], [strkaGE], [strruRU], [SourceSystemNameID]) VALUES (10506053, N'ორგანიზაციები', N'Организации', NULL)
INSERT INTO [dbo].[ZZZ_MenuTranslations] ([idfsBaseReference], [strkaGE], [strruRU], [SourceSystemNameID]) VALUES (10506054, N'დასახლებების ტიპი', N'Типы Населенных Пунктов', NULL)
INSERT INTO [dbo].[ZZZ_MenuTranslations] ([idfsBaseReference], [strkaGE], [strruRU], [SourceSystemNameID]) VALUES (10506055, N'სტატისტიტკური მონაცემები', N'Статистические данные', NULL)
INSERT INTO [dbo].[ZZZ_MenuTranslations] ([idfsBaseReference], [strkaGE], [strruRU], [SourceSystemNameID]) VALUES (10506056, N'უსაფრთხოება ', N'Безопасность', NULL)
INSERT INTO [dbo].[ZZZ_MenuTranslations] ([idfsBaseReference], [strkaGE], [strruRU], [SourceSystemNameID]) VALUES (10506057, N'პაროლის შეცვლა', N'Случай заболевания человека - Статус случая', NULL)
INSERT INTO [dbo].[ZZZ_MenuTranslations] ([idfsBaseReference], [strkaGE], [strruRU], [SourceSystemNameID]) VALUES (10506058, N'უსაფრთხოების წესები', N'Правила Безопасности', NULL)
INSERT INTO [dbo].[ZZZ_MenuTranslations] ([idfsBaseReference], [strkaGE], [strruRU], [SourceSystemNameID]) VALUES (10506059, N'მომხმარებლების ჯგუფი', N'Группы Пользователей', NULL)
INSERT INTO [dbo].[ZZZ_MenuTranslations] ([idfsBaseReference], [strkaGE], [strruRU], [SourceSystemNameID]) VALUES (10506060, N'სიტემის ფუნქციები', N'Системные Функции', NULL)
INSERT INTO [dbo].[ZZZ_MenuTranslations] ([idfsBaseReference], [strkaGE], [strruRU], [SourceSystemNameID]) VALUES (10506061, N'დზეის-ის საიტები', N'Сметана, сливки', NULL)
INSERT INTO [dbo].[ZZZ_MenuTranslations] ([idfsBaseReference], [strkaGE], [strruRU], [SourceSystemNameID]) VALUES (10506062, N'უსაფრთხოების მოვლენეის ჟურნალი', N'Журнал регистрации событий безопасности', NULL)
INSERT INTO [dbo].[ZZZ_MenuTranslations] ([idfsBaseReference], [strkaGE], [strruRU], [SourceSystemNameID]) VALUES (10506063, N'სიტემის მოვლენების ჟურნალი', N'Журнал регистрации системных событий', NULL)
INSERT INTO [dbo].[ZZZ_MenuTranslations] ([idfsBaseReference], [strkaGE], [strruRU], [SourceSystemNameID]) VALUES (10506064, N'მონაცემების აუდიტის ჩატარების ჟურნალი', N'Прочие источники загрязнения', NULL)
INSERT INTO [dbo].[ZZZ_MenuTranslations] ([idfsBaseReference], [strkaGE], [strruRU], [SourceSystemNameID]) VALUES (10506065, N'ინტერფეისის რედაქტორი', N'Редактор Интерфейса', NULL)
INSERT INTO [dbo].[ZZZ_MenuTranslations] ([idfsBaseReference], [strkaGE], [strruRU], [SourceSystemNameID]) VALUES (10506066, N'რესურსების რედაქტორები', N'Редакторы Справочников', NULL)
INSERT INTO [dbo].[ZZZ_MenuTranslations] ([idfsBaseReference], [strkaGE], [strruRU], [SourceSystemNameID]) VALUES (10506067, N'ძირითადი ცნობარი', N'Дифтерия-Осложнения, выберите все относящиеся-Миокардит', NULL)
INSERT INTO [dbo].[ZZZ_MenuTranslations] ([idfsBaseReference], [strkaGE], [strruRU], [SourceSystemNameID]) VALUES (10506068, N'დაავადებები', N'Профилактика вертикальной передачи ВИЧ-инфекции с антиретровирусной подготовкой', NULL)
INSERT INTO [dbo].[ZZZ_MenuTranslations] ([idfsBaseReference], [strkaGE], [strruRU], [SourceSystemNameID]) VALUES (10506069, N'ღონისძიებები', N'Мероприятия', NULL)
INSERT INTO [dbo].[ZZZ_MenuTranslations] ([idfsBaseReference], [strkaGE], [strruRU], [SourceSystemNameID]) VALUES (10506070, N'ნიმუშების ტიპები', N'Типы Образцов', NULL)
INSERT INTO [dbo].[ZZZ_MenuTranslations] ([idfsBaseReference], [strkaGE], [strruRU], [SourceSystemNameID]) VALUES (10506071, N'ვექტორების ტიპები', N'Типы Вектора', NULL)
INSERT INTO [dbo].[ZZZ_MenuTranslations] ([idfsBaseReference], [strkaGE], [strruRU], [SourceSystemNameID]) VALUES (10506072, N'ვექტორების სახეობების ტიპები', N'Типы видов векторов', NULL)
INSERT INTO [dbo].[ZZZ_MenuTranslations] ([idfsBaseReference], [strkaGE], [strruRU], [SourceSystemNameID]) VALUES (10506073, N'სახეობების ტიპები', N'Типы Видов', NULL)
INSERT INTO [dbo].[ZZZ_MenuTranslations] ([idfsBaseReference], [strkaGE], [strruRU], [SourceSystemNameID]) VALUES (10506074, N'შემთხვევების კლასიფიკაცია ', N'Болел ли ранее висцеральным лейшманиозом?', NULL)
INSERT INTO [dbo].[ZZZ_MenuTranslations] ([idfsBaseReference], [strkaGE], [strruRU], [SourceSystemNameID]) VALUES (10506075, N'დაავადებების ჯგუფების ანგარიშგება ', N'Отчеты о группах заболеваний', NULL)
INSERT INTO [dbo].[ZZZ_MenuTranslations] ([idfsBaseReference], [strkaGE], [strruRU], [SourceSystemNameID]) VALUES (10506076, N'ზოგადი სტატისტიკური ტიპები ', N'Ослабление голоса, афония', NULL)
INSERT INTO [dbo].[ZZZ_MenuTranslations] ([idfsBaseReference], [strkaGE], [strruRU], [SourceSystemNameID]) VALUES (10506077, N'ასაკობრივი ჯგუფები დიაგნოზის მიხედვით', N'Ботулизм-Эпидемиологические связи-Посещение места жительства или работы данного лица', NULL)
INSERT INTO [dbo].[ZZZ_MenuTranslations] ([idfsBaseReference], [strkaGE], [strruRU], [SourceSystemNameID]) VALUES (10506078, N'ადამიანის დაავადების აგრეგირებულიანგარიშის მატრიცა', N'Матрица Агрегированного Отчета о Заболеваниях Человека', NULL)
INSERT INTO [dbo].[ZZZ_MenuTranslations] ([idfsBaseReference], [strkaGE], [strruRU], [SourceSystemNameID]) VALUES (10506079, N'ვეტერინარული აგრეგირებული შემთხვევის მატრიცა', N'Матрица Ветеринарных Агрегированных Случаев', NULL)
INSERT INTO [dbo].[ZZZ_MenuTranslations] ([idfsBaseReference], [strkaGE], [strruRU], [SourceSystemNameID]) VALUES (10506080, N'ვეტერინარული დიაგნოსტიკური კვლევების მატრიცა', N'Матрица Ветеринарных Диагностичесцих Исследований', NULL)
INSERT INTO [dbo].[ZZZ_MenuTranslations] ([idfsBaseReference], [strkaGE], [strruRU], [SourceSystemNameID]) VALUES (10506081, N'ვეტტერინარული პროფილაქტიკური ღონისძიებების მატრიცა', N'Матрица Ветеринарных Профилактических Мероприятий', NULL)
INSERT INTO [dbo].[ZZZ_MenuTranslations] ([idfsBaseReference], [strkaGE], [strruRU], [SourceSystemNameID]) VALUES (10506082, N'ვეტერინარული სანიტარული ღონისძიებების მატრიცა', N'Матрица Ветеринарных Санитарных Мероприятий', NULL)
INSERT INTO [dbo].[ZZZ_MenuTranslations] ([idfsBaseReference], [strkaGE], [strruRU], [SourceSystemNameID]) VALUES (10506083, N'სახეობები - ცხოველების ასაკის მატრიცა', N'Вид - Матрица Возраста Животного', NULL)
INSERT INTO [dbo].[ZZZ_MenuTranslations] ([idfsBaseReference], [strkaGE], [strruRU], [SourceSystemNameID]) VALUES (10506084, N'ნიმუშების ტიპები - დერივატების ტიპების მარტიცა', N'Тип образца - Матрица Типа Деривата ', NULL)
INSERT INTO [dbo].[ZZZ_MenuTranslations] ([idfsBaseReference], [strkaGE], [strruRU], [SourceSystemNameID]) VALUES (10506088, N'ტესტი - ტესტის შედეგების მატრიცა', N'Тесты - Матрица Результатов Теста', NULL)
INSERT INTO [dbo].[ZZZ_MenuTranslations] ([idfsBaseReference], [strkaGE], [strruRU], [SourceSystemNameID]) VALUES (10506089, N'ვექტორის ტიპი - აღების მეთოდის მატრიცა ', N'Типы Вектора - Матрица Методов Сбора', NULL)
INSERT INTO [dbo].[ZZZ_MenuTranslations] ([idfsBaseReference], [strkaGE], [strruRU], [SourceSystemNameID]) VALUES (10506090, N'ვექტორის ტიპი - ნიმუშის ტიპის მატრიცა ', N'Типы Вектора - Матрица Типов Проб', NULL)
INSERT INTO [dbo].[ZZZ_MenuTranslations] ([idfsBaseReference], [strkaGE], [strruRU], [SourceSystemNameID]) VALUES (10506091, N'ვექტორის ტიპი - საფელე ტესტის მატრიცა', N'Типы Вектора - Матрица Полевых Тестов', NULL)
INSERT INTO [dbo].[ZZZ_MenuTranslations] ([idfsBaseReference], [strkaGE], [strruRU], [SourceSystemNameID]) VALUES (10506092, N'დაავადება - ასაკობრივი ჯგუფის მატრიცა', N'Код приоритетного обследования', NULL)
INSERT INTO [dbo].[ZZZ_MenuTranslations] ([idfsBaseReference], [strkaGE], [strruRU], [SourceSystemNameID]) VALUES (10506093, N'ანგარიშის დიაგნოზის ჯგუფი - დიაგნოზის მატრიცა', N'Группа Диагноза Отчета - Матрица Диагноза', NULL)
INSERT INTO [dbo].[ZZZ_MenuTranslations] ([idfsBaseReference], [strkaGE], [strruRU], [SourceSystemNameID]) VALUES (10506094, N'მოდიცირებადი ანგარიშების რიგები', N'Осталось на конец отчетного периода больных', NULL)
INSERT INTO [dbo].[ZZZ_MenuTranslations] ([idfsBaseReference], [strkaGE], [strruRU], [SourceSystemNameID]) VALUES (10506095, N'ასაკობრივი ჯგუფები -სტატისტიკური ასაკობრივი ჯგუფების მატრიცა', N'Ботулизм-Эпидемиологические связи-Знаете ли Вы других людей со сходным заболеванием', NULL)
INSERT INTO [dbo].[ZZZ_MenuTranslations] ([idfsBaseReference], [strkaGE], [strruRU], [SourceSystemNameID]) VALUES (10506096, N'დაავადების ჯგუფი - დაავადების მატრიცა', N'Приоритет исследования', NULL)
INSERT INTO [dbo].[ZZZ_MenuTranslations] ([idfsBaseReference], [strkaGE], [strruRU], [SourceSystemNameID]) VALUES (10506097, N'პარაეტრის ტიპის რედაქტორი ', N'Редактор Типа Параметра', NULL)
INSERT INTO [dbo].[ZZZ_MenuTranslations] ([idfsBaseReference], [strkaGE], [strruRU], [SourceSystemNameID]) VALUES (10506098, N'უნიკალური დანომვრის სქემა', N'Схема нумерации уникальных номеров', NULL)
INSERT INTO [dbo].[ZZZ_MenuTranslations] ([idfsBaseReference], [strkaGE], [strruRU], [SourceSystemNameID]) VALUES (10506099, N'აგრეგირებული ფორმების პარამეტრები', N'Кампилобактериоз КРС', NULL)
INSERT INTO [dbo].[ZZZ_MenuTranslations] ([idfsBaseReference], [strkaGE], [strruRU], [SourceSystemNameID]) VALUES (10506100, N'რუქის კასტომიზაცია ', N'Конфигурирование Карты', NULL)
INSERT INTO [dbo].[ZZZ_MenuTranslations] ([idfsBaseReference], [strkaGE], [strruRU], [SourceSystemNameID]) VALUES (10506101, N'ქაღალდის ფორმები', N'Бумажные Формы', NULL)
INSERT INTO [dbo].[ZZZ_MenuTranslations] ([idfsBaseReference], [strkaGE], [strruRU], [SourceSystemNameID]) VALUES (10506103, N'ადამიანის დაავადების ანგარიში ', N'Отчеты по Заболеваниям Человека', NULL)
INSERT INTO [dbo].[ZZZ_MenuTranslations] ([idfsBaseReference], [strkaGE], [strruRU], [SourceSystemNameID]) VALUES (10506104, N'ვეტერინარული ანგარიში', N'Ветеринарный Отчет', NULL)
INSERT INTO [dbo].[ZZZ_MenuTranslations] ([idfsBaseReference], [strkaGE], [strruRU], [SourceSystemNameID]) VALUES (10506105, N'ლაბორატორიული ანგარიშები', N'Лабораторные отчеты', NULL)
INSERT INTO [dbo].[ZZZ_MenuTranslations] ([idfsBaseReference], [strkaGE], [strruRU], [SourceSystemNameID]) VALUES (10506107, N'ადმინისტატიული ანგარიშები', N'Автозные поражения на языке', NULL)
INSERT INTO [dbo].[ZZZ_MenuTranslations] ([idfsBaseReference], [strkaGE], [strruRU], [SourceSystemNameID]) VALUES (10506108, N'შტრიხკოდების ამობეჭდვა', N'Распечатка штрих-кодов', NULL)
INSERT INTO [dbo].[ZZZ_MenuTranslations] ([idfsBaseReference], [strkaGE], [strruRU], [SourceSystemNameID]) VALUES (10506109, N'ადამიანის დაავადების ანგარიში ', N'Отчеты по Заболеваниям Человека', NULL)
INSERT INTO [dbo].[ZZZ_MenuTranslations] ([idfsBaseReference], [strkaGE], [strruRU], [SourceSystemNameID]) VALUES (10506110, N'ადამიანის დაავადების აგრეგირებული ანგარიში', N'Aгрегированные Отчета о Заболеваниях Человека ', NULL)
INSERT INTO [dbo].[ZZZ_MenuTranslations] ([idfsBaseReference], [strkaGE], [strruRU], [SourceSystemNameID]) VALUES (10506111, N'ადამიანის აქტიური ზედამხეველობის კამპანია', N'Кампания по Активному Эпиднадзору за Заболеваниями Человека ', NULL)
INSERT INTO [dbo].[ZZZ_MenuTranslations] ([idfsBaseReference], [strkaGE], [strruRU], [SourceSystemNameID]) VALUES (10506112, N'ადამიანის აქტიური ზედამხეველობის სესია', N'Сессия по Активному Эпиднадзору за Заболеваниями Человека ', NULL)
INSERT INTO [dbo].[ZZZ_MenuTranslations] ([idfsBaseReference], [strkaGE], [strruRU], [SourceSystemNameID]) VALUES (10506113, N'პირი', N'Лицо', NULL)
INSERT INTO [dbo].[ZZZ_MenuTranslations] ([idfsBaseReference], [strkaGE], [strruRU], [SourceSystemNameID]) VALUES (10506114, N'ეპიდაფეთქება', N'Вспышка', NULL)
INSERT INTO [dbo].[ZZZ_MenuTranslations] ([idfsBaseReference], [strkaGE], [strruRU], [SourceSystemNameID]) VALUES (10506115, N'ფერმის', N'Туляремия-Подтвержденный случай (для всех форм)-Тип теста', NULL)
INSERT INTO [dbo].[ZZZ_MenuTranslations] ([idfsBaseReference], [strkaGE], [strruRU], [SourceSystemNameID]) VALUES (10506116, N'ფრინველის დაავადების ანგარიში', N'Пало', NULL)
INSERT INTO [dbo].[ZZZ_MenuTranslations] ([idfsBaseReference], [strkaGE], [strruRU], [SourceSystemNameID]) VALUES (10506117, N'შინაური ცხოველის დაავადების ანგარიში', N'Отчеты по Заболеваниям Домашнего Скота', NULL)
INSERT INTO [dbo].[ZZZ_MenuTranslations] ([idfsBaseReference], [strkaGE], [strruRU], [SourceSystemNameID]) VALUES (10506119, N'ვეტერინარი აგრეგირებული ანგარიშგება', N'Ветеринарные Агрегированные Отчеты', NULL)
INSERT INTO [dbo].[ZZZ_MenuTranslations] ([idfsBaseReference], [strkaGE], [strruRU], [SourceSystemNameID]) VALUES (10506120, N'ვეტერინარული აგერეგირებული ქმედებები', N'Ветеринарные Агрегированные Мероприятия', NULL)
INSERT INTO [dbo].[ZZZ_MenuTranslations] ([idfsBaseReference], [strkaGE], [strruRU], [SourceSystemNameID]) VALUES (10506121, N'ვეტერინარული აქტიური ზედამხედველობის სესია', N'Сесия активного Ветеринарного Надзора', NULL)
INSERT INTO [dbo].[ZZZ_MenuTranslations] ([idfsBaseReference], [strkaGE], [strruRU], [SourceSystemNameID]) VALUES (10506122, N'ნიმუშების ძებნა ', N'Поиск Образцов', NULL)
INSERT INTO [dbo].[ZZZ_MenuTranslations] ([idfsBaseReference], [strkaGE], [strruRU], [SourceSystemNameID]) VALUES (10506123, N'ტესტირება', N'Тестирование', NULL)
INSERT INTO [dbo].[ZZZ_MenuTranslations] ([idfsBaseReference], [strkaGE], [strruRU], [SourceSystemNameID]) VALUES (10506124, N'ნიმუშის გადაცემა ', N'Передача Образца', NULL)
INSERT INTO [dbo].[ZZZ_MenuTranslations] ([idfsBaseReference], [strkaGE], [strruRU], [SourceSystemNameID]) VALUES (10506125, N'დამტკიცებები', N'Зоонозные заболевания - Область/Регион', NULL)
INSERT INTO [dbo].[ZZZ_MenuTranslations] ([idfsBaseReference], [strkaGE], [strruRU], [SourceSystemNameID]) VALUES (10506126, N'ჩემი პრიორიტები', N'Мои Фавориты', NULL)
INSERT INTO [dbo].[ZZZ_MenuTranslations] ([idfsBaseReference], [strkaGE], [strruRU], [SourceSystemNameID]) VALUES (10506127, N'ვექტორების აღება ', N'Сбор Векторов', NULL)
INSERT INTO [dbo].[ZZZ_MenuTranslations] ([idfsBaseReference], [strkaGE], [strruRU], [SourceSystemNameID]) VALUES (10506128, N'ტრეინიგის ვიდეო ჩანაწერები ', N'Учебные видеоматериалы', NULL)
INSERT INTO [dbo].[ZZZ_MenuTranslations] ([idfsBaseReference], [strkaGE], [strruRU], [SourceSystemNameID]) VALUES (10506129, N'შეტყობინება ', N'Извещения', NULL)
INSERT INTO [dbo].[ZZZ_MenuTranslations] ([idfsBaseReference], [strkaGE], [strruRU], [SourceSystemNameID]) VALUES (10506130, N'ჩემი შეტყობინებები', N'Мои Извещения', NULL)
INSERT INTO [dbo].[ZZZ_MenuTranslations] ([idfsBaseReference], [strkaGE], [strruRU], [SourceSystemNameID]) VALUES (10506131, N'ჩემი კვლევები', N'Мои Расследования', NULL)
INSERT INTO [dbo].[ZZZ_MenuTranslations] ([idfsBaseReference], [strkaGE], [strruRU], [SourceSystemNameID]) VALUES (10506132, N'გამოკვლევები ', N'Расследования', NULL)
INSERT INTO [dbo].[ZZZ_MenuTranslations] ([idfsBaseReference], [strkaGE], [strruRU], [SourceSystemNameID]) VALUES (10506133, N'ნიმუშები, რომელიც არ არის მიღებული', N'Непринятые образцы', NULL)
INSERT INTO [dbo].[ZZZ_MenuTranslations] ([idfsBaseReference], [strkaGE], [strruRU], [SourceSystemNameID]) VALUES (10506134, N'დამტკიცებები', N'Зоонозные заболевания - Область/Регион', NULL)
INSERT INTO [dbo].[ZZZ_MenuTranslations] ([idfsBaseReference], [strkaGE], [strruRU], [SourceSystemNameID]) VALUES (10506135, N'ჩემი არებულები', N'Мои Отборы', NULL)
INSERT INTO [dbo].[ZZZ_MenuTranslations] ([idfsBaseReference], [strkaGE], [strruRU], [SourceSystemNameID]) VALUES (10506136, N'მომხმარებლები', N'Пользователи', NULL)
INSERT INTO [dbo].[ZZZ_MenuTranslations] ([idfsBaseReference], [strkaGE], [strruRU], [SourceSystemNameID]) VALUES (10506137, N'ქაღალდის ფორმების ჩამოტვითვა', N'Скачать Бумажные Формы', NULL)
INSERT INTO [dbo].[ZZZ_MenuTranslations] ([idfsBaseReference], [strkaGE], [strruRU], [SourceSystemNameID]) VALUES (10506138, N'ტრეინიგის ვიდეო ჩანაწერები ', N'Учебные видеоматериалы', NULL)
INSERT INTO [dbo].[ZZZ_MenuTranslations] ([idfsBaseReference], [strkaGE], [strruRU], [SourceSystemNameID]) VALUES (10506139, N'სისტემური უპირატესობები', N'Системные Привилегии', NULL)
INSERT INTO [dbo].[ZZZ_MenuTranslations] ([idfsBaseReference], [strkaGE], [strruRU], [SourceSystemNameID]) VALUES (10506140, N'თანამშრომლები ', N'Указать тип продукта', NULL)
INSERT INTO [dbo].[ZZZ_MenuTranslations] ([idfsBaseReference], [strkaGE], [strruRU], [SourceSystemNameID]) VALUES (10506141, N'მომხმარებლების ჯგუფი', N'Группы Пользователей', NULL)
INSERT INTO [dbo].[ZZZ_MenuTranslations] ([idfsBaseReference], [strkaGE], [strruRU], [SourceSystemNameID]) VALUES (10506142, N'ობიექტი', N'Объекты', NULL)
INSERT INTO [dbo].[ZZZ_MenuTranslations] ([idfsBaseReference], [strkaGE], [strruRU], [SourceSystemNameID]) VALUES (10506143, N'ორგანიზაციები', N'Организации', NULL)
INSERT INTO [dbo].[ZZZ_MenuTranslations] ([idfsBaseReference], [strkaGE], [strruRU], [SourceSystemNameID]) VALUES (10506145, N'გმდ აგრეგირებული ფორმა', N'Агрегированный отчет по ГПЗ', NULL)
INSERT INTO [dbo].[ZZZ_MenuTranslations] ([idfsBaseReference], [strkaGE], [strruRU], [SourceSystemNameID]) VALUES (10506146, N'დედუპლიკაცია ', N'Дедупликация', NULL)
INSERT INTO [dbo].[ZZZ_MenuTranslations] ([idfsBaseReference], [strkaGE], [strruRU], [SourceSystemNameID]) VALUES (10506148, N'მოქნილი ფორმის კონსტრუქტორი', N'Конструктор Гибких Форм', NULL)
INSERT INTO [dbo].[ZZZ_MenuTranslations] ([idfsBaseReference], [strkaGE], [strruRU], [SourceSystemNameID]) VALUES (10506149, N'გმდ აბერაციის ანალიზი', N'Анализ аберраций ГПЗ', NULL)
INSERT INTO [dbo].[ZZZ_MenuTranslations] ([idfsBaseReference], [strkaGE], [strruRU], [SourceSystemNameID]) VALUES (10506150, N'ყოველთვიური ავადობა და სივდილიანობა', N'Ежемесячная Заболеваемость и Смертность', NULL)
INSERT INTO [dbo].[ZZZ_MenuTranslations] ([idfsBaseReference], [strkaGE], [strruRU], [SourceSystemNameID]) VALUES (10506151, N'საწყისი და საბოლოო დაიგნოზის შესაბამისობა ', N'Июль', NULL)
INSERT INTO [dbo].[ZZZ_MenuTranslations] ([idfsBaseReference], [strkaGE], [strruRU], [SourceSystemNameID]) VALUES (10506152, N'წლიური ვეტერინარული სიტუაცია ', N'Годовая Ветеринарная Ситуация', NULL)
INSERT INTO [dbo].[ZZZ_MenuTranslations] ([idfsBaseReference], [strkaGE], [strruRU], [SourceSystemNameID]) VALUES (10506153, N'ვეტერინარული აქტიური ზედამხედველობა ', N'Активный Ветеринарный Надзор', NULL)
INSERT INTO [dbo].[ZZZ_MenuTranslations] ([idfsBaseReference], [strkaGE], [strruRU], [SourceSystemNameID]) VALUES (10506154, N'დაავადება - ადამიანის სქესის მატრიცა', N'Частное хозяйство', NULL)
INSERT INTO [dbo].[ZZZ_MenuTranslations] ([idfsBaseReference], [strkaGE], [strruRU], [SourceSystemNameID]) VALUES (10506155, N'პერსონალური საიდენტიფიკაციო ტიპის მატრიცა', N'Матрица типов персональной идентификации', NULL)
INSERT INTO [dbo].[ZZZ_MenuTranslations] ([idfsBaseReference], [strkaGE], [strruRU], [SourceSystemNameID]) VALUES (10506157, N'ობიექტის ჯგუფი', N'Группы Объектов', NULL)
INSERT INTO [dbo].[ZZZ_MenuTranslations] ([idfsBaseReference], [strkaGE], [strruRU], [SourceSystemNameID]) VALUES (10506160, N'სისტემური უპირატესობები', N'Системные Привилегии', NULL)
INSERT INTO [dbo].[ZZZ_MenuTranslations] ([idfsBaseReference], [strkaGE], [strruRU], [SourceSystemNameID]) VALUES (10506161, N'ევროპის ბიულეტენი ცოფის შესახებ - ზედამხედველობის კვარტალური ანგარიში', N'Европейский Бюллетень по Бешенству - Ежеквартальный Отчет Эпиднадзора', NULL)
INSERT INTO [dbo].[ZZZ_MenuTranslations] ([idfsBaseReference], [strkaGE], [strruRU], [SourceSystemNameID]) VALUES (10506162, N'რამდენომე წლის შედარებითი ანგარიში თვის მიხედვით', N'Сравнительный Отчет за несколько лет по месяцам', NULL)
INSERT INTO [dbo].[ZZZ_MenuTranslations] ([idfsBaseReference], [strkaGE], [strruRU], [SourceSystemNameID]) VALUES (10506163, N'გადამდები დაავადებების/მდგომარეობების შედარებითი ანგარიში (თვეების მიხედვით)', N'Сравнительный Отчет по Инфекционным Заболеваниям/Состояниям (по месяцам)', NULL)
INSERT INTO [dbo].[ZZZ_MenuTranslations] ([idfsBaseReference], [strkaGE], [strruRU], [SourceSystemNameID]) VALUES (10506164, N'სეროლოგიური კვლევის შედეგი', N'Результат серологического исследования', NULL)
INSERT INTO [dbo].[ZZZ_MenuTranslations] ([idfsBaseReference], [strkaGE], [strruRU], [SourceSystemNameID]) VALUES (10506165, N'ანტიბიოტიკების მიმართ მგრძნობელობის ბარათი (დკსჯეც)', N'Карта Устойчивости к Антибиотикам (NCDC&PH)', NULL)
INSERT INTO [dbo].[ZZZ_MenuTranslations] ([idfsBaseReference], [strkaGE], [strruRU], [SourceSystemNameID]) VALUES (10506166, N'ანტიბიოტიკების მიმართ მგრძნობელობის ბარათი (სმსლ)', N'Карта Устойчивости к Антибиотикам (LMA)', NULL)
INSERT INTO [dbo].[ZZZ_MenuTranslations] ([idfsBaseReference], [strkaGE], [strruRU], [SourceSystemNameID]) VALUES (10506167, N'60B ჟურნალი      ', N'60B Журнал Регистрации', NULL)
INSERT INTO [dbo].[ZZZ_MenuTranslations] ([idfsBaseReference], [strkaGE], [strruRU], [SourceSystemNameID]) VALUES (10506168, N'ანგარიში ზოგიერთი დაავადების/მდგომარეობის შესახებ (ყოველთვიური ფორმა IV–03)', N'Отчет о Специфических Заболеваниях/Состояниях (Ужемесячная форма IV-03)', NULL)
INSERT INTO [dbo].[ZZZ_MenuTranslations] ([idfsBaseReference], [strkaGE], [strruRU], [SourceSystemNameID]) VALUES (10506169, N'ადმინისტრაციულ მოვლენათა ჟურნალი', N'Журнал Регтсирации Административных Событий', NULL)
INSERT INTO [dbo].[ZZZ_MenuTranslations] ([idfsBaseReference], [strkaGE], [strruRU], [SourceSystemNameID]) VALUES (10506170, N'შუალედური ანგარიში ყოველთვიური ფორმა IV–03–ის მიხედვით', N'Промежуточный Отчет по Ежемесячной Форме IV-03', NULL)
INSERT INTO [dbo].[ZZZ_MenuTranslations] ([idfsBaseReference], [strkaGE], [strruRU], [SourceSystemNameID]) VALUES (10506172, N'ანგარიშების ძველი ვერსია ', N'Старая Версия Отчетов', NULL)
INSERT INTO [dbo].[ZZZ_MenuTranslations] ([idfsBaseReference], [strkaGE], [strruRU], [SourceSystemNameID]) VALUES (10506173, N'ანგარიში ზოგიერთი დაავადების/მდგომარეობის შესახებ (ყოველთვიური ფორმა IV–03 შჯსდს-ს 01-82/ნ ბრძანების შესაბამისად)  ', N'Отчет об Специфических Заболеваниях/Состояниях (Ежемесячная форма IV-03 - в соответствии с приказом Минздрава 01-82/N', NULL)
INSERT INTO [dbo].[ZZZ_MenuTranslations] ([idfsBaseReference], [strkaGE], [strruRU], [SourceSystemNameID]) VALUES (10506174, N'შუალედური ანგარიში ყოველთვიური ფორმა IV–03–ის მიხედვით (შჯსდს-ს 01-82/ნ ბრძანების შესაბამისად)', N'Промежуточный Отчет по Ежемесячной Форме IV-03 (в соответствии с приказом MoLHSA 01-82/N)', NULL)
INSERT INTO [dbo].[ZZZ_MenuTranslations] ([idfsBaseReference], [strkaGE], [strruRU], [SourceSystemNameID]) VALUES (10506175, N'ანგარიში ზოგიერთი დაავადების/მდგომარეობის შესახებ (ყოველთვიური ფორმა IV–03 შჯსდს-ს 01-27/ნ ბრძანების შესაბამისად)', N'Отчет об Специфических Заболеваниях/Состояниях (Ежемесячная форма IV-03 - в соответствии с приказом МЗБС 01-27/N)', NULL)
INSERT INTO [dbo].[ZZZ_MenuTranslations] ([idfsBaseReference], [strkaGE], [strruRU], [SourceSystemNameID]) VALUES (10506176, N'შუალედური ანგარიში წლიური ფორმა IV–03–ის მიხედვით (შჯსდს-ს 101/ნ ბრძანების შესაბამისად)', N'Промежуточный Отчет по Ежемесячной Форме IV-03 (в соответствии с Приказом Минздравсоцразвития 01-27/N)', NULL)
INSERT INTO [dbo].[ZZZ_MenuTranslations] ([idfsBaseReference], [strkaGE], [strruRU], [SourceSystemNameID]) VALUES (10506177, N'ანგარიში წლიურ ანგარიშგებას დაქვემდებარებული გადამდები დაავადების შემთხვევების შესახებ (წლიური ფორმა IV–03 შჯსდს-ს 101/ნ ბრძანების შესაბამისად)', N'Отчет о Случаях Ежегодно Регистрируемых Инфекционных Заболеваний (Годовая форма IV-03 - в соответствии с приказом 101/N Минздрава)', NULL)
INSERT INTO [dbo].[ZZZ_MenuTranslations] ([idfsBaseReference], [strkaGE], [strruRU], [SourceSystemNameID]) VALUES (10506178, N'შუალედური ანგარიში წლიური ფორმა IV–03–ის მიხედვით (შჯსდს-ს 101/ნ ბრძანების შესაბამისად)', N'Промежуточный Отчет по Годовой Форме IV-03 (в соответствии с Приказом Минздрава 101/N)', NULL)
INSERT INTO [dbo].[ZZZ_MenuTranslations] ([idfsBaseReference], [strkaGE], [strruRU], [SourceSystemNameID]) VALUES (10506179, N'ინფეცქიური დაავადებების შემთხვევების ანგარიში  (ყოველთვიური ფორმა IV–03/1 შჯსდს-ს  101/ნ ბრძანების შესაბამისად', N'Отчет о Случаях Инфекционных Заболеваний (Ежемесячная форма IV-03/1 - в соответствии с приказом 101/N Минздрава)', NULL)
INSERT INTO [dbo].[ZZZ_MenuTranslations] ([idfsBaseReference], [strkaGE], [strruRU], [SourceSystemNameID]) VALUES (10506180, N'შუალედური ანგარიში წლიური ფორმა IV–03–ის მიხედვით (შჯსდს-ს 101/ნ ბრძანების შესაბამისად)', N'Промежуточный Отчет по Ежемесячной Форме IV-03/1 (в соответствии с Приказом Минздрава 101/N)', NULL)
INSERT INTO [dbo].[ZZZ_MenuTranslations] ([idfsBaseReference], [strkaGE], [strruRU], [SourceSystemNameID]) VALUES (10506184, N'მიკრობილიოლოგიური კვლევის შედეგი', N'Результат микробиологичкского исследования ', NULL)
INSERT INTO [dbo].[ZZZ_MenuTranslations] ([idfsBaseReference], [strkaGE], [strruRU], [SourceSystemNameID]) VALUES (10506188, N'ყოველკვირეული ანგარიშგების ფორმა', N'Еженедельная Отчетная Форма', NULL)
INSERT INTO [dbo].[ZZZ_MenuTranslations] ([idfsBaseReference], [strkaGE], [strruRU], [SourceSystemNameID]) VALUES (10506189, N'ყოველკვირეული ანგარიშგების ფორმის შეჯამება', N'Сводная Еженедельная Отчетная Форма', NULL)
INSERT INTO [dbo].[ZZZ_MenuTranslations] ([idfsBaseReference], [strkaGE], [strruRU], [SourceSystemNameID]) VALUES (10506196, N'აუდიტის ადმინისტრაციული ანგარიშის ჟურნალი', N'Журнал Аудита Административных Отчетов', NULL)
INSERT INTO [dbo].[ZZZ_MenuTranslations] ([idfsBaseReference], [strkaGE], [strruRU], [SourceSystemNameID]) VALUES (10506201, N'ფორმაცვალებადი ფილტრი', N'L1.1. Хозяин фермы', NULL)
INSERT INTO [dbo].[ZZZ_MenuTranslations] ([idfsBaseReference], [strkaGE], [strruRU], [SourceSystemNameID]) VALUES (10506212, N'ადმინისტრაციული ქვედანაყოფი', N'Административные Подразделения', NULL)
INSERT INTO [dbo].[ZZZ_MenuTranslations] ([idfsBaseReference], [strkaGE], [strruRU], [SourceSystemNameID]) VALUES (10506213, N'არქივთან დაკავშირება', N'Соединение с Архивом', NULL)
INSERT INTO [dbo].[ZZZ_MenuTranslations] ([idfsBaseReference], [strkaGE], [strruRU], [SourceSystemNameID]) VALUES (10506214, N'ინტერფეისის რედაქტორი', N'Редактор Интерфейса', NULL)
INSERT INTO [dbo].[ZZZ_MenuTranslations] ([idfsBaseReference], [strkaGE], [strruRU], [SourceSystemNameID]) VALUES (10506215, N'ეპიდაფეთქების გვერდი', N'Страница Вспышки', NULL)
INSERT INTO [dbo].[ZZZ_MenuTranslations] ([idfsBaseReference], [strkaGE], [strruRU], [SourceSystemNameID]) VALUES (10506216, N'ადამიანის დაავადების გამოკვლევის ფორმა', N'Форма Расследования Заболевания Человека', NULL)
INSERT INTO [dbo].[ZZZ_MenuTranslations] ([idfsBaseReference], [strkaGE], [strruRU], [SourceSystemNameID]) VALUES (10506217, N'ფრინველის დაავადების გამოკვლევის ფორმა', N'Форма Расследования Птичьих Заболеваний', NULL)
INSERT INTO [dbo].[ZZZ_MenuTranslations] ([idfsBaseReference], [strkaGE], [strruRU], [SourceSystemNameID]) VALUES (10506218, N'შინაური ცხოველის გამოკვლევის ფორმა', N'Форма Расследования Заболеваний Домашнего Скота', NULL)
INSERT INTO [dbo].[ZZZ_MenuTranslations] ([idfsBaseReference], [strkaGE], [strruRU], [SourceSystemNameID]) VALUES (10506219, N'დზეი 7 -ის პანელი', N'Панель EIDSS7', NULL)
PRINT(N'Operation applied to 175 rows out of 175')

UPDATE T
SET T.SourceSystemNameID = S.SourceSystemNameID
FROM [dbo].[ZZZ_MenuTranslations] T
INNER JOIN dbo.trtBaseReference S ON S.idfsBaseReference = T.idfsBaseReference

--------------------------------------------------------------------------------------------------------------------------------
--
-- use a cursor and variables to update target database
--
--------------------------------------------------------------------------------------------------------------------------------

PRINT N'Processing [dbo].[ZZZ_MenuTranslations] at ' + CAST(GETDATE() AS NVARCHAR(24))

DECLARE @idfsBaseReference BIGINT
DECLARE @strkaGE NVARCHAR(500)
DECLARE @strruRU NVARCHAR(500)
DECLARE @SourceSystemNameID BIGINT

DECLARE Cursor_StringNameTranslation
CURSOR FOR
SELECT
	idfsBaseReference,
    strkaGE,
    strruRU,
	SourceSystemNameID

FROM dbo.ZZZ_MenuTranslations

OPEN Cursor_StringNameTranslation
FETCH NEXT FROM Cursor_StringNameTranslation
INTO
	@idfsBaseReference,
	@strkaGE,
	@strruRU,
	@SourceSystemNameID

WHILE @@FETCH_STATUS = 0
BEGIN
	--Georgian
	IF NOT EXISTS (SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = @idfsBaseReference AND idfsLanguage = dbo.FN_GBL_LanguageCode_GET('ka-GE'))
	BEGIN
		INSERT INTO dbo.trtStringNameTranslation
		(
		    idfsBaseReference,
		    idfsLanguage,
		    strTextString,
		    rowguid,
		    intRowStatus,
		    SourceSystemNameID,
		    SourceSystemKeyValue,
		    AuditCreateUser,
		    AuditCreateDTM
		)
		SELECT
			@idfsBaseReference,
			dbo.FN_GBL_LanguageCode_GET('ka-GE'),
			@strkaGE,
			NEWID(),
			0,
			@SourceSystemNameID,
			N'[{"idfsBaseReference":' + CAST(@idfsBaseReference AS NVARCHAR(24)) + N',"idfsLanguage":'+ CAST(dbo.FN_GBL_LanguageCode_GET('ka-GE') AS NVARCHAR(24)) + N'}]',
			'System',
			GETDATE()

	END
	ELSE
	BEGIN

		UPDATE dbo.trtStringNameTranslation
		SET strTextString = @strkaGE,
			intRowStatus = 0,
			SourceSystemNameID = @SourceSystemNameID,
			SourceSystemKeyValue = N'[{"idfsBaseReference":' + CAST(@idfsBaseReference AS NVARCHAR(24)) + N',"idfsLanguage":'+ CAST(dbo.FN_GBL_LanguageCode_GET('ka-GE') AS NVARCHAR(24)) + N'}]',
			AuditUpdateUser = 'System',
			AuditUpdateDTM = GETDATE()

		WHERE idfsBaseReference = @idfsBaseReference 
		AND idfsLanguage = dbo.FN_GBL_LanguageCode_GET('ka-GE')

	END

	--Russian
	IF NOT EXISTS (SELECT * FROM dbo.trtStringNameTranslation WHERE idfsBaseReference = @idfsBaseReference AND idfsLanguage = dbo.FN_GBL_LanguageCode_GET('ru-RU'))
	BEGIN
		INSERT INTO dbo.trtStringNameTranslation
		(
		    idfsBaseReference,
		    idfsLanguage,
		    strTextString,
		    rowguid,
		    intRowStatus,
		    SourceSystemNameID,
		    SourceSystemKeyValue,
		    AuditCreateUser,
		    AuditCreateDTM
		)
		SELECT
			@idfsBaseReference,
			dbo.FN_GBL_LanguageCode_GET('ru-RU'),
			@strruRU,
			NEWID(),
			0,
			@SourceSystemNameID,
			N'[{"idfsBaseReference":' + CAST(@idfsBaseReference AS NVARCHAR(24)) + N',"idfsLanguage":'+ CAST(dbo.FN_GBL_LanguageCode_GET('ru-RU') AS NVARCHAR(24)) + N'}]',
			'System',
			GETDATE()

	END
	ELSE
	BEGIN

		UPDATE dbo.trtStringNameTranslation
		SET strTextString = @strruRU,
			intRowStatus = 0,
			SourceSystemNameID = @SourceSystemNameID,
			SourceSystemKeyValue = N'[{"idfsBaseReference":' + CAST(@idfsBaseReference AS NVARCHAR(24)) + N',"idfsLanguage":'+ CAST(dbo.FN_GBL_LanguageCode_GET('ru-RU') AS NVARCHAR(24)) + N'}]',
			AuditUpdateUser = 'System',
			AuditUpdateDTM = GETDATE()

		WHERE idfsBaseReference = @idfsBaseReference 
		AND idfsLanguage = dbo.FN_GBL_LanguageCode_GET('ru-RU')

	END

	FETCH NEXT FROM Cursor_StringNameTranslation
	INTO
		@idfsBaseReference,
		@strkaGE,
		@strruRU,
		@SourceSystemNameID

END

CLOSE Cursor_StringNameTranslation
DEALLOCATE Cursor_StringNameTranslation

-- DROP TEMP TABLE
PRINT N'Dropping [dbo].[ZZZ_MenuTranslations] at ' + CAST(GETDATE() AS NVARCHAR(24))

DROP TABLE IF EXISTS [dbo].[ZZZ_MenuTranslations]



