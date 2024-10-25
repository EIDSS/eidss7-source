using System;
using Microsoft.Data.SqlClient;

namespace EIDSS.Repository.Extensions
{
    public static class SqlParameterExtensions
    {
        public static SqlParameter ToSqlParam(this string? value, string parameterName, int? size = null)
        {
            var sqlParameter = new SqlParameter
            {
                ParameterName = parameterName,
                Value = value ?? Convert.DBNull,
                SqlDbType = System.Data.SqlDbType.NVarChar,
            };

            if (size.HasValue)
            {
                sqlParameter.Size = size.Value;
            }

            return sqlParameter;
        }
        
        public static SqlParameter ToSqlParam(this int? value, string parameterName)
        {
            return new SqlParameter
            {
                ParameterName = parameterName,
                Value = value ?? Convert.DBNull,
                SqlDbType = System.Data.SqlDbType.Int,
            };
        }
    }
}