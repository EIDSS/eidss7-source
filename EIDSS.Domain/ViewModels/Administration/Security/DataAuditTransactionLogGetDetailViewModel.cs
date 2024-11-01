﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.ViewModels.Administration.Security
{
    public class DataAuditTransactionLogGetDetailViewModel
    {
        public long? idfDataAuditEvent { get; set; }
        public Guid idfDataAuditDetail { get; set; }
        public string strTableName { get; set; }
        public string strColumnName { get; set; }
        public long? idfObject { get; set; }
        public long? idfObjectDetail { get; set; }
        public object strOldValue { get; set; }
        public object strNewValue { get; set; }
        public string strObject { get; set; }
        public string strActionType { get; set; }

    }
}
