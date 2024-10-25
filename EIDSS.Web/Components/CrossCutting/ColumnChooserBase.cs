using EIDSS.Localization.Constants;
using EIDSS.Web.Abstracts;
using EIDSS.Web.ViewModels;
using Microsoft.AspNetCore.Components;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Logging;
using Radzen;
using Radzen.Blazor;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace EIDSS.Web.Components.CrossCutting
{
    public class ColumnChooserBase<TItem>  :  BaseComponent
    {
        [Parameter]
        public List<ChoosableColumn> ChoosableColumns { get; set; }

        [Parameter]
        public RadzenDataGrid<TItem> Grid { get; set;  }

        [Parameter]
        public EventCallback<List<ChoosableColumn>> OnColumnChooserClose { get; set; }

        [Inject]
        ILogger<ColumnChooserBase<TItem>> Logger { get; set; }

        protected override Task OnInitializedAsync()
        {
            DiagService.OnClose += ColumnChooserClose;
            return base.OnInitializedAsync();
        }
        protected async Task ShowColumnChooser()
        {
            try
            {
                var dialogParams = new Dictionary<string, object>();
                dialogParams.Add("DialogName", "ColumnChooser");
                dialogParams.Add("Columns", ChoosableColumns);
                await DiagService.OpenAsync<ColumnChooserDialog>(Localizer.GetString(HeadingResourceKeyConstants.EIDSSModalHeading), dialogParams);
            }
            catch (Exception ex)
            {
                Logger.LogError(ex, "Exception in column chooser.");
                throw;
            }
        }

        public void Dispose()
        {
            try
            {
                 DiagService.OnClose -= ColumnChooserClose;
            }
            catch (Exception)
            {
                throw;
            }
        }


        //protected override void OnAfterRender(bool firstRender)
        //{
        //    if (Grid !=null)
        //    {
        //        Console.WriteLine("Not null");
        //    }
        //    base.OnAfterRender(firstRender);
        //}

        void ColumnChooserClose(dynamic result)
        {
           OnColumnChooserClose.InvokeAsync(ChoosableColumns);
        }

       
    }
}
