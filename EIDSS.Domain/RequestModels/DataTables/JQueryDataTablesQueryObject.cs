using Newtonsoft.Json.Linq;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Text.Json;
using System.Threading.Tasks;



namespace EIDSS.Domain.RequestModels.DataTables
{
    /// <summary>
    /// Object that Is Sent From Jquery Datatables to the API ENDPOINT
    /// or Controller Methods
    /// </summary>
    public class JQueryDataTablesQueryObject
    {


        int _length;
        int _start;
        int _page;
        string _sortOrder;
        string _sortColumn;
        List<JQueryDataTablesColumnNames> _columns;
        List<JQueryDataTablesOrderColumnNameIndexes> _order;
        KeyValuePair<string,string> _sortingColumnAndOrder;
        /// <summary>
        /// Object that Datatables uses to keep track of pages drawn
        /// </summary>
        public int draw { get; set; }
        /// <summary>
        /// Number Of Items Displayed in the Grid or Page Length
        /// </summary>
        public int length { get { return _length; } set { _length = value; } }
        /// <summary>
        /// Page number and increments by page length. 
        /// </summary>
        public int start { get { return _start; } set { _start = value; } }
        /// <summary>
        /// Custom parameters. Should be serialized
        /// </summary>
        public string postArgs { get; set; }

        public int page { get { return Paging(); } set { _page = value; } }

        public string sortColumn { get; set; }
        public string sortOrder { get; set; }
        public KeyValuePair<string, string> sortingColumnAndOrder { get; set; }
        public JsonElement columns { get; set; }

        public JsonElement order { get; set; }
        public JQueryDataTablesQueryObject()
        {
           
        }

        /// <summary>
        /// DataTable Row Data
        /// </summary>
        public JsonElement data { get; set; }

        // order: [{column: 3, dir: "asc"}]
        public string DeserializeColumns(int index)
        {
            string columnName = string.Empty;
            if (columns.ValueKind != JsonValueKind.Undefined)
            {
                foreach (var items in columns.EnumerateArray())
                {
                    var res = items;
                    var jsonObject1 = JObject.Parse(res.ToString());
                    if (jsonObject1 != null)
                    {
                        if (!String.IsNullOrEmpty(jsonObject1["data"].ToString()))
                        {
                            if (Int32.Parse(jsonObject1["data"].ToString()) == index)
                            {
                                columnName = jsonObject1["name"].ToString();
                                break;
                            }
                        }
                     
                    }
                }
            }
            return columnName;
        }

        public KeyValuePair<string, string> ReturnSortParameter()
        {

            KeyValuePair<string, string> sortOrderKVP = new KeyValuePair<string, string>();
            if (order.ValueKind != JsonValueKind.Undefined)
               {
                foreach (var items in order.EnumerateArray())
                {
                    var res = items;
                    var jsonObject1 = JObject.Parse(res.ToString());
                    if (jsonObject1 != null)
                    {
                        if (!String.IsNullOrEmpty(jsonObject1["column"].ToString()))
                        {
                            string column_index = jsonObject1["column"].ToString();
                            string columnName = DeserializeColumns(Int32.Parse(column_index));
                            sortOrderKVP = new KeyValuePair<string, string>(columnName, jsonObject1["dir"].ToString());
                        }
                    }
                  
                }
            }
            return sortOrderKVP;
        }
        
        public int Paging()
        {
             _page = 0;
            if (_start == 0)
            {
                _page = 1;
            }
            else
            {
                _page = (_start / _length) + 1;
            }
            return _page;
        }


    }

    public class JQueryDataTablesColumnNames
    {
        public string data { get; set; }
        public string name { get; set; }
        public Boolean searchable { get; set; }
        public Boolean orderable { get; set; }
        public string MyProperty { get; set; }
        //{data: 0, name: "", searchable: true, orderable: false, search: {value: "", regex: false}}
    }
    public class JQueryDataTablesOrderColumnNameIndexes
    {
        public int column { get; set; }
        public string dir { get; set; }
    }
}
