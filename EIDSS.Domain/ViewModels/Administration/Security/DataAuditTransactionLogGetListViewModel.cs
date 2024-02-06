using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using EIDSS.Domain.Abstracts;
using Microsoft.CodeAnalysis.CSharp.Syntax;

namespace EIDSS.Domain.ViewModels.Administration.Security
{
    public class DataAuditTransactionLogGetListViewModel:BaseModel
    {
        public long auditEventId { get; set; }
        public string siteName { get; set; }
        public long siteId { get; set; }
        public long? userId { get; set; }
        public string userFirstName { get; set; }
        public string userFamilyName { get; set; }
        public DateTime? TransactionDate { get; set; }
        public string ActionName { get; set; }
        public long? actionTypeId { get; set; }
        public string ObjectType { get; set; }
        public long? ObjectTypeId { get; set; }
        public long? ObjectTable { get; set; }
        public long? ObjectId { get; set; }
        public string tableName { get; set; }
        public string strMainObject { get; set; }

        private string _userName;

        private string _strTransDate;

        private string _strSiteId;


        public string UserName
        {
            get => _userName;
            set
            {
                _userName = $"{userFirstName} {userFamilyName}";
                this._userName = value;
            }
        }

        public string StrTransDate
        {
            get => _strTransDate;
            set
            {
                _strTransDate = TransactionDate.ToString();
                this._strTransDate = value;
            }
        }

        public string StrSiteId
        {
            get => _strSiteId;
            set
            {
                _strSiteId = siteId.ToString();
                this._strSiteId = value;
            }
        }

    }
}
