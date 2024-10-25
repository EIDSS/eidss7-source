using EIDSS.Domain.RequestModels.Administration;
using System;
using System.Collections.Generic;

namespace EIDSS.Web.ViewModels.Administration
{
    public class StatisticalDataFileModel
    {
        public List<string[]> rows { get; set; }
        public List<USP_ADMIN_STAT_SETResultRequestModel> GoodRows { get; set; }
        //public List<List<StatisticalDataImportError>> MessageList { get; set; }

        public List<StatisticalDataImportError> ErrorMessagesList { get; set; }

        public DateTime DateOfImport { get; set; }
        public string User { get; set; }
        public int ErrorCount { get; set; }
        public bool IsIncorrectFileFormat { get; set; }
    }
    public class StatisticalDataImportError
    {
        public string LineNumber { get; set; }
        public string ColumnNumber { get; set; }
        public string ErrorMessage { get; set; }
        public string Row { get; set; }
        public int Type { get; set; }
    }
}
