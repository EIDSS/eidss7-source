using EIDSS.ClientLibrary.ApiClients.CrossCutting;
using EIDSS.Domain.RequestModels.CrossCutting;
using EIDSS.Web.Abstracts;
using Microsoft.AspNetCore.Components;
using System;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;

namespace EIDSS.Web.Components.Shared
{
    public class AddPostalCodeModalBase: BaseComponent, IDisposable
    {
        #region Dependency Injection

        [Inject] private ICrossCuttingClient CrossCuttingClient { get; set; }

        #endregion Dependency Injection

        #region parameters

        [Parameter] public long? BottomAdminLevel { get; set; }

        #endregion

        #region private fields

        private CancellationTokenSource _source;

        #endregion

        #region protected fields

        protected bool DisableAddButton { get; set; }
        protected string Message { get; set; }
        protected string PostalCodeName { get; set; }

        #endregion

        public void Dispose()
        {
            _source?.Cancel();
            _source?.Dispose();
        }

        protected override void OnInitialized()
        {
            base.OnInitialized();

            Message = "";
            DisableAddButton = true;
        }

        protected async Task OnChange(string value)
        {
            DisableAddButton = true;
            Message = "";
            if (string.IsNullOrEmpty(value))
            {
                DisableAddButton = true;
            }
            else
            {
                DisableAddButton = false;
                if (BottomAdminLevel != null)
                {
                    var streetList = await CrossCuttingClient.GetPostalCodeList(BottomAdminLevel.Value);
                    if (streetList.FirstOrDefault(s => s.PostalCodeString.ToUpper() == value.ToUpper()) == null)
                    {
                        DisableAddButton = false;
                    }
                    else
                    {
                        DisableAddButton = true;
                        Message = "Record Exists Already";
                    }
                }
            }
        }

        protected async Task OnClick()
        {
            Message = "";
            if (!string.IsNullOrEmpty(PostalCodeName))
            {
                if (BottomAdminLevel != null)
                {
                    var streetSaveRequestModel = new PostalCodeSaveRequestModel()
                    {
                        idfsLocation = BottomAdminLevel.Value,
                        strPostCode = PostalCodeName,
                        idfPostalCode = null,
                        user = _tokenService.GetAuthenticatedUser().UserName
                    };
                    var result = await CrossCuttingClient.SavePostalCode(streetSaveRequestModel);
                    if (result != null)
                    {
                        Message = "Record Saved Successfully";
                    }
                }
            }
        }
    }
}