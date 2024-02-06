#region Usings

using EIDSS.Web.Extensions;
using System.Collections.Generic;

#endregion

namespace EIDSS.Web.ViewModels
{
    public class ReportViewModel
	{
		/// <summary>
		/// 
		/// </summary>
		public string ReportPath { get; set; }

		/// <summary>
		/// 
		/// </summary>
		public List<KeyValuePair<string, string>> Parameters { get; set; }

		public ReportViewModel()
		{
			Parameters = new List<KeyValuePair<string, string>>();
		}

		/// <summary>
		/// 
		/// </summary>
		/// <param name="name"></param>
		/// <param name="value"></param>
		public void AddParameter(string name, string value)
		{
			if (!name.HasValue()) { return; }

			KeyValuePair<string, string> param = new(name, string.IsNullOrEmpty(value) ? string.Empty : value.ToString());

			Parameters.Add(param);
		}
	}
}
