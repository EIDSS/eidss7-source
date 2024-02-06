using EIDSS.ClientLibrary.ApiClients.Configuration;
using EIDSS.ClientLibrary.Services;
using EIDSS.Domain.RequestModels.Configuration;
using EIDSS.Domain.ResponseModels.Configuration;
using EIDSS.Web.Services;
using EIDSS.Web.ViewModels;
using Microsoft.AspNetCore.Components;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;
using System.Threading.Tasks;
using Microsoft.JSInterop;
using EIDSS.Web.Abstracts;
using Radzen;
using Microsoft.Extensions.Localization;
using EIDSS.Localization.Constants;
using EIDSS.Web.Components.CrossCutting;
namespace EIDSS.Web.Components.CrossCutting
{
    public class GridExtensionBase: BaseComponent, IDisposable
    {
        #region Events
        [Parameter]
        public EventCallback OnColumnSave { get; set; }
        #endregion

        #region Services
        [Inject]
        protected GridContainerServices GridContainerServices { get; set; }
      
        [Inject]
        private IConfigurationClient ConfigurationClient { get; set; }
        [Inject]
        protected ITokenService _tokenService { get; set; }
        [Inject]
        private IJSRuntime jsRuntime { get; set; }

        [Inject]
        protected DialogService DiagService { get; set; }
        #endregion

        #region Properties
        public int ColumnCounter { get; set; }
        #endregion


        #region LifeCycle Events
       
        protected override async Task OnInitializedAsync()
        {
           
             await base.OnInitializedAsync();
        }
        protected override void OnInitialized()
        {

           
            base.OnInitialized();
        }

        public void Dispose()
        {
            //throw new NotImplementedException();
        }
        #endregion

    

        #region Grid Operation Methods

        /// <summary>
        /// Loads The Gris
        /// </summary>
        /// <param name="tableNameId">Id or Name of Grid</param>
        /// <param name="_tokenService">Token Services</param>
        /// <param name="configurationClient">Configruation API reference</param>
        /// <returns></returns>
        public EIDSSGridColumnChooserDefinition GridColumnLoad(string tableNameId,ITokenService _tokenService, IConfigurationClient configurationClient)
        {
            GridContainerServices = new GridContainerServices();
            EIDSSGridColumnChooserDefinition eIDSSGridColumnChooserDefinition = new EIDSSGridColumnChooserDefinition();
            try
            {
                List<USP_CONF_USER_GRIDS_GETDETAILResponseModel> results = new List<USP_CONF_USER_GRIDS_GETDETAILResponseModel>();
                //USP_CONF_USER_GRIDS_GETDETAILRequestModel request = new USP_CONF_USER_GRIDS_GETDETAILRequestModel();
                //var userdetails = _tokenService.GetAuthenticatedUser();
                //request.idfUserID = long.Parse(userdetails.EIDSSUserId);
                //request.GridID = tableNameId;
                //results =  configurationClient.GetUserGridConfiguration(request);
                
                //if (results.Count > 0)
                //{
                //    GridContainerServices.GridColumnConfig.RowOrderDefinitionList = Newtonsoft.Json.JsonConvert.DeserializeObject<List<RowReOrderClass>>(results[0].ColumnDefinition);
                //    eIDSSGridColumnChooserDefinition = GridContainerServices.GridColumnConfig;
                //}
            }
            catch (Exception ex)
            {
                throw;
            }
            return eIDSSGridColumnChooserDefinition;
        }
       /// <summary>
       /// Saves Columns Of Grid
       /// </summary>
       /// <param name="tableNameId"> Name Of Grid</param>
       /// <param name="_tokenService"> token service</param>
       /// <param name="configuration"> Configruation API reference</param>
       /// <param name="colunList"> Column Colllection of Grid</param>
       /// <param name="gridContainerServices"> GridContainer Services</param>
        public async void GridColumnSave(string tableNameId,ITokenService _tokenService, IConfigurationClient configuration, List<dynamic> colunList,GridContainerServices gridContainerServices)
        { 
            string status = string.Empty;
            EIDSSGridColumnChooserDefinition eIDSSGridColumnChooserDefinition = new EIDSSGridColumnChooserDefinition();
            eIDSSGridColumnChooserDefinition.RowOrderDefinitionList = new List<RowReOrderClass>();
            List<USP_CONF_USER_GRIDS_SETResponseModel> results = new List<USP_CONF_USER_GRIDS_SETResponseModel>();
            if (gridContainerServices.VisibleColumnList.Count > 0)
            {
                for (int i = 0; i < colunList.Count(); i++)
                {

                    eIDSSGridColumnChooserDefinition.RowOrderDefinitionList.Add(new RowReOrderClass()
                    {
                        ColumnName = colunList[i].Property,
                        Index = colunList[i].OrderIndex == null ? 0 : colunList[i].OrderIndex,
                        ReorderedIndex = colunList[i].OrderIndex == null ? 0 : colunList[i].OrderIndex,
                        IsVisible = gridContainerServices.VisibleColumnList.Contains(colunList[i].Property) ? true : false
                    });
                }
            }
            else
            {
                for (int i = 0; i < colunList.Count(); i++)
                {
                    eIDSSGridColumnChooserDefinition.RowOrderDefinitionList.Add(new RowReOrderClass()
                    {
                        ColumnName = colunList[i].Property,
                        Index = colunList[i].OrderIndex == null ? 0 : colunList[i].OrderIndex,
                        ReorderedIndex = colunList[i].OrderIndex == null ? 0 : colunList[i].OrderIndex,
                        IsVisible = true
                    });
                }
            }
        
            USP_CONF_USER_GRIDS_SETRequestModel request = new USP_CONF_USER_GRIDS_SETRequestModel();
            var userdetails = _tokenService.GetAuthenticatedUser();
            string objData = Newtonsoft.Json.JsonConvert.SerializeObject(eIDSSGridColumnChooserDefinition.RowOrderDefinitionList);
            request.idfUserID = long.Parse(userdetails.EIDSSUserId);
            request.idfsSite = Int32.Parse(userdetails.SiteId);
            request.intRowStatus = 0;
            request.ColumnDefinition = objData;
            request.GridID = tableNameId;
            results = await configuration.SetUserGridConfiguration(request);
       
        }


        /// <summary>
        /// Returns the Index of Each Column
        /// </summary>
        /// <param name="propertyName">Property Name </param>
        /// <returns></returns>
        public int FindColumnOrder(string propertyName)
        {
            var index = 0;
            if (GridContainerServices != null)
            {
                if (GridContainerServices.GridColumnConfig.RowOrderDefinitionList != null)
                {
                    if (GridContainerServices.GridColumnConfig.RowOrderDefinitionList.Count() > 0)
                    {
                        index = GridContainerServices.GridColumnConfig.RowOrderDefinitionList.ToList().FindIndex(x => x.ColumnName == propertyName);
                    }
                }
            }
            return index;
        }
        public bool GetColumnVisibility(string propertyName)
        {
            bool visible = true;
            //if (GridContainerServices != null)
            //{
            //    if (GridContainerServices.GridColumnConfig.RowOrderDefinitionList != null)
            //    {
            //        if (GridContainerServices.GridColumnConfig.RowOrderDefinitionList.Count() > 0)
            //        {
            //           var index = GridContainerServices.GridColumnConfig.RowOrderDefinitionList.ToList().FindIndex(x => x.ColumnName == propertyName);
            //            if (index > -1)
            //            {
            //                visible = GridContainerServices.GridColumnConfig.RowOrderDefinitionList[index].IsVisible;
            //            }
            //        }
            //    }
            //}
            return visible;
        }


        public  void GetPropertyValues(Object obj)
        {
            Type t = obj.GetType();
          //  Console.WriteLine("Type is: {0}", t);
            PropertyInfo[] props = t.GetProperties();
          
        }


        //Temporary Handle Visible List
        public System.Timers.Timer timer;
        public List<string> HandleVisibilityList(GridContainerServices gridContainerServices,string propertyName)
        {
            //if (timer == null)
            //{
            //    timer = new System.Timers.Timer(300);
            //    timer.Elapsed += (sender, e) => HandleTimer();
            //}
            GridContainerServices = new GridContainerServices();
            GridContainerServices.VisibleColumnList = new List<string>();

            //if (GridContainerServices.ColumnCounter == 0)
            //{
            //    GridContainerServices.VisibleColumnList.Clear();
            //    timer.Start();
            //}
            //if (!GridContainerServices.VisibleColumnList.Contains(propertyName))
            //{
            //    GridContainerServices.VisibleColumnList.Add(propertyName);
            //}
            //GridContainerServices.ColumnCounter++;
            return GridContainerServices.VisibleColumnList;
        }
        public void HandleTimer()
        {
            GridContainerServices.ColumnCounter = 0;
            timer.Stop();
        }
        #endregion

       

    }
}
