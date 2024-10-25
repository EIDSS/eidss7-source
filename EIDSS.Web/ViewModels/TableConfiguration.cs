using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace EIDSS.Web.ViewModels
{
    public class TableConfiguration
    {
        public List<ColumnConfiguration> ColumnInfo { get; set; }
    }

    public class ColumnConfiguration
    {
        public string columnName { get; set; }
        public string Class { get; set; }  
        public bool orderable { get; set; }       
        public string data { get; set; }        
        public string defaultContent { get; set; }

        /// <summary>
        /// Column is a Edit Link
        /// </summary>
        public bool isEdit { get;set; }

        /// <summary>
        /// Column is a Delete Link
        /// </summary>
        public bool isDelete { get; set; }

        /// <summary>
        /// Column is a details link
        /// </summary>
        public bool isDetails { get; set; }

        /// <summary>
        /// Column displays a Drop Down Contrl
        /// </summary>
        public bool isDropDown { get; set; }

        public Select2DataItem select2DefaultDataItem { get; set; }
        /// <summary>
        /// Used to create a Custom Javascript Function on the Column
        /// method must be formatted with the following 3 parameters example: function_Name(data, type, row, meta){}
        /// </summary>
        public ColumnAction ColumnAction { get; set; }

    }

    public class ColumnAction
    {
      //  public int targets { get; set; }
        public bool visible { get; set; }

        public string type { get; set; }

        public string javascriptFunction { get; set; }
      
    }
}
