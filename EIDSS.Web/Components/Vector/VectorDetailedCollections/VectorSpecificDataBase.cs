using EIDSS.ClientLibrary.ApiClients.FlexForm;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.Domain.Enumerations;
using EIDSS.Domain.RequestModels.FlexForm;
using EIDSS.Domain.ViewModels.FlexForm;
using EIDSS.Web.Components.Vector.Common;
using EIDSS.Web.Services;
using Microsoft.AspNetCore.Components;
using Microsoft.Extensions.Logging;
using Microsoft.JSInterop;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;

namespace EIDSS.Web.Components.Vector
{
    public class VectorSpecificDataBase : VectorBaseComponent
    {
        #region Dependencies

        [Inject] private IJSRuntime JsRuntime { get; set; }
        [Inject] private IFlexFormClient FlexFormClient { get; set; }
        [Inject] private ILogger<VectorSpecificDataBase> Logger { get; set; }

        #endregion

        #region Parameters



        #endregion

        #region Properties

        protected FlexForm.FlexForm VectorSpecificDataFlexForm { get; set; }
        protected List<FlexFormTemplateDeterminantValuesListViewModel> FormTemplates { get; set; }

        #endregion

        #region Member Variables

        private CancellationTokenSource _source;
        private CancellationToken _token;
        private bool _disposedValue;

        #endregion


        protected override async Task OnInitializedAsync()
        {
            _logger = Logger;

            // Reset the cancellation token
            _source = new CancellationTokenSource();
            _token = _source.Token;

            await GetVectorSpecificTemplates().ConfigureAwait(false);

            if (VectorSpecificDataFlexForm is not null)
            {
                VectorSessionStateContainer.VectorFlexForm ??= new FlexFormQuestionnaireGetRequestModel();

                VectorSessionStateContainer.VectorFlexForm.LangID = GetCurrentLanguage();
                VectorSessionStateContainer.VectorFlexForm.idfsFormType =
                     (long)FlexibleFormTypeEnum.VectorSpecificData;
            }
            
            VectorSessionStateContainer.OnChange += OnStateContainerChangeAsync;

            await base.OnInitializedAsync();
        }

        /// <summary>
        /// </summary>
        /// <param name="firstRender"></param>
        /// <returns></returns>
        protected override async Task OnAfterRenderAsync(bool firstRender)
        {
            if (firstRender)
            {
                await JsRuntime
                    .InvokeVoidAsync("VectorSpecificDataSection.SetDotNetReference", _token,
                        DotNetObjectReference.Create(this))
                    .ConfigureAwait(false);
            }

        }

        private void OnStateContainerChangeAsync(string property)
        {
            if (property is "DetailVectorTypeID")
            {
                VectorSessionStateContainer.VectorFlexForm.idfsDiagnosis =
                    VectorSessionStateContainer.VectorDetailedCollectionKey;
                VectorSessionStateContainer.VectorFlexForm.idfObservation =
                    VectorSessionStateContainer.DetailObservationID;

                var formTemplate = FormTemplates.Where(x => x.idfsBaseReference == VectorSessionStateContainer.DetailVectorTypeID).ToList();
                if (formTemplate.Any())
                {
                    VectorSessionStateContainer.VectorFlexForm.idfsFormTemplate = formTemplate.First().idfsFormTemplate;
                }

                VectorSpecificDataFlexForm ??= new FlexForm.FlexForm();
                VectorSpecificDataFlexForm.SetRequestParameter(VectorSessionStateContainer.VectorFlexForm);

                StateHasChanged();
            }
        }

        protected override void Dispose(bool disposing)
        {
            if (disposing)
            {
                _source?.Cancel();
                _source?.Dispose();

                VectorSessionStateContainer.OnChange -= OnStateContainerChangeAsync;
            }

            base.Dispose(disposing);
        }

        protected async Task GetVectorSpecificTemplates()
        {
            FormTemplates = new List<FlexFormTemplateDeterminantValuesListViewModel>();

            FlexFormTemplateGetRequestModel request = new();

            try
            {
                request.LanguageId = GetCurrentLanguage();
                request.idfsFormTemplate = null;
                request.idfsFormType = (long)FlexibleFormTypes.VectorSpecificData;

                var formTemplates = await FlexFormClient.GetTemplateList(request);
                foreach (var template in formTemplates)
                {
                    var determinantValueTemplate = await GetFlexFormDeterminantValues(template.idfsFormTemplate);
                    if (determinantValueTemplate != null)
                    {
                        FormTemplates.Add(determinantValueTemplate);
                    }
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        protected async Task<FlexFormTemplateDeterminantValuesListViewModel> GetFlexFormDeterminantValues(long idfsFormTemplate)
        {
            FlexFormTemplateDeterminantValuesGetRequestModel request = new();

            try
            {
                request.LanguageId = GetCurrentLanguage();
                request.idfsFormTemplate = idfsFormTemplate;

                var list = await FlexFormClient.GetTemplateDeterminantValues(request);
                return list?.FirstOrDefault();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #region Validation Methods

        /// <summary>
        /// </summary>
        /// <returns></returns>
        [JSInvokable]
        public async Task<bool> ValidateSectionForSidebar()
        {
            await InvokeAsync(() =>
            {
                _ = VectorSpecificDataFlexForm.SaveFlexForm();
                StateHasChanged();
            });
            
            VectorSessionStateContainer.DetailObservationID = VectorSpecificDataFlexForm.Request.idfObservation;

            return true;
        }

        #endregion
    }
}
