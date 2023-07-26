create procedure syn.usp_ImportFileCustomerSeasonal
/* @ID_Record int нужно написать в скобках */
	@ID_Record int 
as
set nocount on
begin
	declare @RowCount int = (select count(*) from syn.SA_CustomerSeasonal)
	declare @ErrorMessage varchar(max)

-- Проверка на корректность загрузки
	/*присутствует лишний отступ в начале строки*/
	if not exists ( 
	select 1 
	from syn.ImportFile as f 
	/* условия необходимо добавить в скобки */
	where f.ID = @ID_Record 
		and f.FlagLoaded = cast(1 as bit) 
	)
	/*присутствуют 2 лишних отступа в начале строки*/
		begin 
		/*присутствуют 2 лишних отступа в начале строки*/
			set @ErrorMessage = 'Ошибка при загрузке файла, проверьте корректность данных' 
			/*присутствуют 2 лишних отступа в начале строки*/
			raiserror(@ErrorMessage, 3, 1) 
			/*присутствуют 2 лишних отступа в начале строки*/
			/*отсутствет пустая строка перед return*/			
			return 
		/*присутствуют 2 лишних отступа в начале строки*/
		end 
 /* CREATE TABLE не должен быть написан капсом,
	хэштег необходимо удалить, отсутствует пробел между скобкой и созданием объекта */
	CREATE TABLE #ProcessedRows(ActionType varchar(255), ID int)

	/*присутствуют 2 лишние строчки*/
	/*присутствуют пробел перед "чтение"*/
	--Чтение из слоя временных данных 	
	select
		cc.ID as ID_dbo_Customer
		,cst.ID as ID_CustomerSystemType
		,s.ID as ID_Season
		,cast(sa.DateBegin as date) as DateBegin
		,cast(sa.DateEnd as date) as DateEnd
		,cd.ID as ID_dbo_CustomerDistributor
		,cast(isnull(sa.FlagActive, 0) as bit) as FlagActive
	into #CustomerSeasonal
	from syn.SA_CustomerSeasonal cs
		join dbo.Customer as cc on cc.UID_DS = sa.UID_DS_Customer
			and cc.ID_mapping_DataSource = 1
		join dbo.Season as s on s.Name = sa.Season
		join dbo.Customer as cd on cd.UID_DS = sa.UID_DS_CustomerDistributor
			and cd.ID_mapping_DataSource = 1
		/*Сперва указываем поле присоединяемой таблицы*/
		join syn.CustomerSystemType as cst on sa.CustomerSystemType = cst.Name
	where try_cast(sa.DateBegin as date) is not null
		and try_cast(sa.DateEnd as date) is not null
		and try_cast(isnull(sa.FlagActive, 0) as bit) is not null

	-- Определяем некорректные записи
	-- Добавляем причину, по которой запись считается некорректной
	select
		sa.*
		,case
			when cc.ID is null then 'UID клиента отсутствует в справочнике "Клиент"'
			when cd.ID is null then 'UID дистрибьютора отсутствует в справочнике "Клиент"'
			when s.ID is null then 'Сезон отсутствует в справочнике "Сезон"'
			when cst.ID is null then 'Тип клиента в справочнике "Тип клиента"'
			when try_cast(sa.DateBegin as date) is null then 'Невозможно определить Дату начала'
			when try_cast(sa.DateEnd as date) is null then 'Невозможно определить Дату начала'
			when try_cast(isnull(sa.FlagActive, 0) as bit) is null then 'Невозможно определить Активность'
		/*присутствуют 2 лишних отступа в начале строки*/
		end as Reason
	into #BadInsertedRows
	from syn.SA_CustomerSeasonal as cs
	/*Необходимо все left join сделать с табуляцией*/
	left join dbo.Customer as cc on cc.UID_DS = sa.UID_DS_Customer
		and cc.ID_mapping_DataSource = 1
	left join dbo.Customer as cd on cd.UID_DS = sa.UID_DS_CustomerDistributor and cd.ID_mapping_DataSource = 1
	left join dbo.Season as s on s.Name = sa.Season
	left join syn.CustomerSystemType as cst on cst.Name = sa.CustomerSystemType
	where cc.ID is null
		or cd.ID is null
		or s.ID is null
		or cst.ID is null
		or try_cast(sa.DateBegin as date) is null
		or try_cast(sa.DateEnd as date) is null
		or try_cast(isnull(sa.FlagActive, 0) as bit) is null

/*Присутствует лишняя строка*/		
end
