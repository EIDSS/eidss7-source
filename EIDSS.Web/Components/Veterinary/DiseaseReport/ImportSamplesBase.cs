#region Usings

using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using EIDSS.ClientLibrary.ApiClients.Veterinary;
using EIDSS.Domain.RequestModels.Veterinary;
using EIDSS.Domain.ViewModels.Veterinary;
using EIDSS.Localization.Constants;
using EIDSS.Web.Abstracts;
using EIDSS.Web.Components.CrossCutting;
using EIDSS.Web.Enumerations;
using Microsoft.AspNetCore.Components;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Logging;
using Radzen.Blazor;
using static EIDSS.ClientLibrary.Enumerations.EIDSSConstants;

#endregion

namespace EIDSS.Web.Components.Veterinary.DiseaseReport
{
    /// <summary>
    /// </summary>
    public class ImportSamplesBase : BaseComponent, IDisposable
    {
        #region Globals

        #region Dependencies

        [Inject] private ILogger<ImportSamplesBase> Logger { get; set; }
        [Inject] private IVeterinaryClient VeterinaryClient { get; set; }

        #endregion

        #region Parameters

        [Parameter] public DiseaseReportGetDetailViewModel DiseaseReport { get; set; }

        #endregion

        #region Properties

        public ImportSampleGetListRequestModel ImportSamplesRequest { get; set; }
        public RadzenTemplateForm<ImportSampleGetListRequestModel> Form { get; set; }
        public IList<SampleGetListViewModel> Samples { get; set; } = new List<SampleGetListViewModel>();
        public IList<SampleGetListViewModel> SelectedSamples { get; set; } = new List<SampleGetListViewModel>();
        public RadzenDataGrid<SampleGetListViewModel> SamplesGrid { get; set; }
        public int Count { get; set; }
        public bool IsLoading { get; set; }

        public bool IsSelected
        {
            get
            {
                _isSelected = false;
                if (Samples != null)
                    _isSelected = Samples.Any(i => SelectedSamples != null && SelectedSamples.Contains(i));

                return _isSelected;
            }
        }

        public bool AllowImportIndicator { get; set; }

        #endregion

        #region Member Variables

        private CancellationTokenSource _source;
        private CancellationToken _token;
        private bool _disposedValue;
        private bool _isSelected;

        #endregion

        #region Constants

        #endregion

        #endregion

        #region Methods

        /// <summary>
        /// </summary>
        protected override void OnInitialized()
        {
            // Reset the cancellation token
            _source = new CancellationTokenSource();
            _token = _source.Token;

            authenticatedUser = _tokenService.GetAuthenticatedUser();

            _logger = Logger;

            ImportSamplesRequest = new ImportSampleGetListRequestModel();

            base.OnInitialized();
        }

        /// <summary>
        /// </summary>
        /// <param name="disposing"></param>
        protected virtual void Dispose(bool disposing)
        {
            if (_disposedValue) return;
            if (disposing)
            {
            }

            // TODO: free unmanaged resources (unmanaged objects) and override finalizer
            // TODO: set large fields to null
            _disposedValue = true;
        }

        // // TODO: override finalizer only if 'Dispose(bool disposing)' has code to free unmanaged resources
        // ~ImportSampleBase()
        // {
        //     // Do not change this code. Put cleanup code in 'Dispose(bool disposing)' method
        //     Dispose(disposing: false);
        // }
        public void Dispose()
        {
            // Do not change this code. Put cleanup code in 'Dispose(bool disposing)' method
            Dispose(true);
            GC.SuppressFinalize(this);
        }

        /// <summary>
        /// </summary>
        /// <returns></returns>
        protected async Task OnSearchClick()
        {
            try
            {
                IsLoading = true;

                const string sortColumn = "EIDSSLocalOrFieldSampleID";
                const string sortOrder = SortConstants.Descending;
                var speciesTypeIdList = DiseaseReport.Species.Aggregate(string.Empty,
                    (current, farmInventory) => current + string.Join(",", farmInventory.SpeciesTypeID));

                if (DiseaseReport.DiseaseID != null)
                {
                    var request = new ImportSampleGetListRequestModel
                    {
                        LanguageId = GetCurrentLanguage(),
                        Page = 1,
                        PageSize = int.MaxValue - 1,
                        SortColumn = sortColumn,
                        SortOrder = sortOrder,
                        EIDSSLocalOrFieldSampleID = ImportSamplesRequest.EIDSSLocalOrFieldSampleID,
                        FarmMasterID = DiseaseReport.FarmMasterID,
                        SpeciesTypeIDList = speciesTypeIdList,
                        DiseaseID = (long) DiseaseReport.DiseaseID
                    };

                    Samples = await VeterinaryClient.GetImportSampleList(request, _token);
                }

                Count = !Samples.Any() ? 0 : Samples.FirstOrDefault()!.TotalRowCount;

                IsLoading = false;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        /// <summary>
        /// </summary>
        /// <returns></returns>
        protected bool IsHeaderRecordSelected()
        {
            try
            {
                if (Samples is null)
                    return false;

                if (SelectedSamples is {Count: > 0})
                    if (Samples.Any(item => SelectedSamples.Any(x => x.SampleID == item.SampleID)))
                        return true;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }

            return false;
        }

        /// <summary>
        /// </summary>
        /// <param name="value"></param>
        protected void OnHeaderRecordSelectionChange(bool? value)
        {
            try
            {
                if (value == false)
                    foreach (var item in Samples)
                    {
                        if (SelectedSamples.All(x => x.SampleID != item.SampleID)) continue;
                        {
                            var selected = SelectedSamples.First(x => x.SampleID == item.SampleID);

                            SelectedSamples.Remove(selected);
                        }
                    }
                else
                    foreach (var item in Samples)
                        SelectedSamples.Add(item);

                if (SelectedSamples.Count == 1)
                    AllowImportIndicator = true;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        /// <summary>
        /// </summary>
        /// <param name="item"></param>
        /// <returns></returns>
        protected bool IsRecordSelected(SampleGetListViewModel item)
        {
            try
            {
                if (SelectedSamples != null && SelectedSamples.Any(x => x.SampleID == item.SampleID))
                    return true;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }

            return false;
        }

        /// <summary>
        /// </summary>
        /// <param name="value"></param>
        /// <param name="item"></param>
        protected void OnRecordSelectionChange(bool? value, SampleGetListViewModel item)
        {
            try
            {
                if (value == false)
                {
                    item = SelectedSamples.First(x => x.SampleID == item.SampleID);

                    SelectedSamples.Remove(item);
                }
                else
                {
                    SelectedSamples.Add(item);
                }

                if (SelectedSamples.Count == 1)
                    AllowImportIndicator = true;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        /// <summary>
        /// </summary>
        protected void OnImportClick()
        {
            try
            {
                SelectedSamples.First().VeterinaryDiseaseReportID = DiseaseReport.DiseaseReportID;
                SelectedSamples.First().ImportIndicator = true;

                DiagService.Close(SelectedSamples.First());
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        /// <summary>
        /// </summary>
        /// <returns></returns>
        protected async Task OnCancel()
        {
            try
            {
                List<DialogButton> buttons = new();
                DialogButton yesButton = new()
                {
                    ButtonText = Localizer.GetString(ButtonResourceKeyConstants.YesButton),
                    ButtonType = DialogButtonType.Yes
                };
                DialogButton noButton = new()
                {
                    ButtonText = Localizer.GetString(ButtonResourceKeyConstants.NoButton),
                    ButtonType = DialogButtonType.No
                };
                buttons.Add(yesButton);
                buttons.Add(noButton);

                Dictionary<string, object> dialogParams = new()
                {
                    {nameof(EIDSSDialog.DialogButtons), buttons},
                    {
                        nameof(EIDSSDialog.Message),
                        Localizer.GetString(MessageResourceKeyConstants.DoYouWantToCancelMessage)
                    }
                };

                var result =
                    await DiagService.OpenAsync<EIDSSDialog>(
                        Localizer.GetString(HeadingResourceKeyConstants.EIDSSModalHeading), dialogParams);

                if (result == null)
                    return;

                if (result is DialogReturnResult returnResult)
                    if (returnResult.ButtonResultText == Localizer.GetString(ButtonResourceKeyConstants.YesButton))
                        DiagService.Close(result);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        /// <summary>
        /// </summary>
        /// <param name="errorMessage"></param>
        /// <returns></returns>
        private async Task ShowErrorDialog(string errorMessage)
        {
            List<DialogButton> dialogButtons = new();
            DialogButton okButton = new()
            {
                ButtonText = Localizer.GetString(ButtonResourceKeyConstants.OKButton),
                ButtonType = DialogButtonType.OK
            };
            dialogButtons.Add(okButton);

            Dictionary<string, object> dialogParams = new()
            {
                {nameof(EIDSSDialog.DialogButtons), dialogButtons},
                {nameof(EIDSSDialog.Message), errorMessage}
            };
            await DiagService.OpenAsync<EIDSSDialog>(Localizer.GetString(HeadingResourceKeyConstants.EIDSSModalHeading),
                dialogParams);
        }

        #endregion
    }
}