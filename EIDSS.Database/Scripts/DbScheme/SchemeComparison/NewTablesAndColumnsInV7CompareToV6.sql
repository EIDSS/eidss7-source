--TODO: Add PK to the tables, and FK from the columns

select tv7.[name] as table_name, 
		case when tv6.[object_id] is null then N' (new table in v7)' else N'' end as is_new_table, 
		cv7.[name] as column_name, typv7.[name] as column_type, 
		case when cv7.system_type_id in (231 /*nvarchar*/, 167 /*varchar*/) and cv7.max_length > 0 
				then N'(' + cast(cv7.max_length as nvarchar(20)) + N')' 
			 when cv7.system_type_id in (231 /*nvarchar*/, 167 /*varchar*/) and cv7.max_length = -1
				then N'(max)'
			 else N''
		end as column_length,
		isnull(N' ' + cv7.collation_name, N'') as column_collation,
		case when cv7.is_nullable = 0 then N' not null' else N'null' end as is_nullable, 
		case when cv7.is_identity = 1 then N' identity' else N'' end as is_identity, 
		case when cv7.is_computed = 1 then N' computed' else N'' end as is_computed, 
		isnull(dcv7.[definition], N'') as default_constraint 
from [EIDSS7_GG2].sys.tables tv7
join [EIDSS7_GG2].sys.schemas sv7
on sv7.[schema_id] = tv7.[schema_id]
left join [Falcon_GG].sys.tables tv6
	join [FALCON_GG].sys.schemas sv6
	on sv6.[schema_id] = tv6.[schema_id]
on	sv6.[name] = sv7.[name]
	and tv6.[name] = tv7.[name]
join [EIDSS7_GG2].sys.columns cv7
on	cv7.[object_id] = tv7.[object_id]
	and cv7.is_rowguidcol = 0
	and not exists
		(	select 1
			from [Falcon_GG].sys.columns cv6
			where cv6.[object_id] = tv6.[object_id]
					and cv6.[name] = cv7.[name]
		)
	and cv7.[name] not in
		(	N'SourceSystemNameID',
			N'SourceSystemKeyValue',
			N'AuditCreateUser',
			N'AuditCreateDTM',
			N'AuditUpdateUser',
			N'AuditUpdateDTM'
		)
left join [EIDSS7_GG2].sys.types typv7
on	typv7.[user_type_id] = cv7.[user_type_id]
left join [EIDSS7_GG2].sys.[default_constraints] dcv7
on	dcv7.[parent_object_id] = tv7.[object_id]
	and dcv7.[object_id] = cv7.default_object_id
	and dcv7.[parent_column_id] = cv7.[column_id]
where	tv7.[type] = N'U'
		and tv7.[name] not like N'_dmcc%'
order by tv7.[name], cv7.[name]