#region Usings

using EIDSS.Domain.Enumerations;
using EIDSS.Domain.ViewModels.Laboratory;
using EIDSS.Localization.Constants;
using EIDSS.Web.Enumerations;
using Microsoft.AspNetCore.Components;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Logging;
using Radzen.Blazor;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using static System.GC;

#endregion

namespace EIDSS.Web.Components.Laboratory
{
    public class RecordDeletionBase : LaboratoryBaseComponent, IDisposable
    {
        #region Globals

        #region Dependencies

        [Inject] private ILogger<RecordDeletionBase> Logger { get; set; }

        #endregion

        #region Parameters

        [Parameter] public LaboratoryTabEnum Tab { get; set; }

        #endregion

        #region Properties

        protected RadzenDataGrid<LaboratoryRecordDeletionItemViewModel> LaboratoryRecordGrid { get; set; }
        public int Count { get; set; }
        public LaboratoryRecordDeletionViewModel RecordDeletionRequest { get; set; }
        protected RadzenTemplateForm<LaboratoryRecordDeletionViewModel> Form { get; set; }
        protected RadzenTextBox ReasonForDeletionTextBox { get; set; }

        #endregion

        #region Member Variables

        private CancellationTokenSource _source;
        private CancellationToken _token;
        private bool _disposedValue;

        #endregion

        #endregion

        #region Constructors

        /// <summary>
        /// </summary>
        /// <param name="token"></param>
        public RecordDeletionBase(CancellationToken token) : base(token)
        {
        }

        /// <summary>
        /// </summary>
        protected RecordDeletionBase() : base(CancellationToken.None)
        {
        }

        #endregion

        #region Methods

        #region Lifecycle Events

        /// <summary>
        /// </summary>
        protected override void OnInitialized()
        {
            // Reset the cancellation token
            _source = new CancellationTokenSource();
            _token = _source.Token;

            base.OnInitialized();

            if (RecordDeletionRequest is null)
            {
                RecordDeletionRequest = new LaboratoryRecordDeletionViewModel
                { RecordsToDelete = new List<LaboratoryRecordDeletionItemViewModel>() };
                if (Tab == LaboratoryTabEnum.Samples)
                    foreach (var record in LaboratoryService.SelectedSamples)
                        RecordDeletionRequest.RecordsToDelete.Add(new LaboratoryRecordDeletionItemViewModel
                        {
                            EIDSSLaboratorySampleID = record.EIDSSLaboratorySampleID,
                            PatientOrFarmOwnerName = record.PatientOrFarmOwnerName,
                            SampleTypeName = record.SampleTypeName
                        });
                else
                    foreach (var record in LaboratoryService.SelectedMyFavorites)
                        RecordDeletionRequest.RecordsToDelete.Add(new LaboratoryRecordDeletionItemViewModel
                        {
                            EIDSSLaboratorySampleID = record.EIDSSLaboratorySampleID,
                            PatientOrFarmOwnerName = record.PatientOrFarmOwnerName,
                            SampleTypeName = record.SampleTypeName
                        });
            }

            _logger = Logger;

            authenticatedUser = _tokenService.GetAuthenticatedUser();
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

            _disposedValue = true;
        }

        /// <summary>
        /// Free up managed and unmanaged resources.
        /// </summary>
        public void Dispose()
        {
            // Do not change this code. Put cleanup code in 'Dispose(bool disposing)' method
            Dispose(true);
            SuppressFinalize(this);
        }

        #endregion

        #region Record Deletion Comment Text Box Change Event

        /// <summary>
        /// </summary>
        protected void OnRecordDeletionCommentTextBoxChange()
        {
            RecordDeletionRequest = new LaboratoryRecordDeletionViewModel
            { RecordsToDelete = new List<LaboratoryRecordDeletionItemViewModel>() };
            if (Tab == LaboratoryTabEnum.Samples)
                foreach (var record in LaboratoryService.SelectedSamples)
                    RecordDeletionRequest.RecordsToDelete.Add(new LaboratoryRecordDeletionItemViewModel
                    {
                        EIDSSLaboratorySampleID = record.EIDSSLaboratorySampleID,
                        PatientOrFarmOwnerName = record.PatientOrFarmOwnerName,
                        SampleTypeName = record.SampleTypeName
                    });
            else
                foreach (var record in LaboratoryService.SelectedMyFavorites)
                    RecordDeletionRequest.RecordsToDelete.Add(new LaboratoryRecordDeletionItemViewModel
                    {
                        EIDSSLaboratorySampleID = record.EIDSSLaboratorySampleID,
                        PatientOrFarmOwnerName = record.PatientOrFarmOwnerName,
                        SampleTypeName = record.SampleTypeName
                    });

            RecordDeletionRequest.ReasonForDeletion = ReasonForDeletionTextBox.Value;
        }

        #endregion

        #region Submit Event

        /// <summary>
        /// </summary>
        protected async Task OnSubmit()
        {
            if (Form.EditContext.Validate())
            {
                LaboratoryService.PendingSaveSamples ??= new List<SamplesGetListViewModel>();

                LaboratoryService.PendingSaveMyFavorites ??= new List<MyFavoritesGetListViewModel>();

                switch (Tab)
                {
                    case LaboratoryTabEnum.Samples:
                        if (LaboratoryService.SelectedSamples != null)
                            foreach (var sample in LaboratoryService.SelectedSamples)
                            {
                                sample.Comment = RecordDeletionRequest.ReasonForDeletion;
                                sample.SampleStatusTypeID = (long) SampleStatusTypeEnum.MarkedForDeletion;
                                sample.ActionPerformedIndicator = true;

                                if (LaboratoryService.Samples is not null && LaboratoryService.Samples.Any(x => x.SampleID == sample.SampleID))
                                {
                                    var index = LaboratoryService.Samples.ToList().FindIndex(x => x.SampleID == sample.SampleID);
                                    LaboratoryService.Samples[index] = sample;
                                }

                                TogglePendingSaveSamples(sample);

                                if (!sample.FavoriteIndicator) continue;
                                {
                                    // Has the user selected the my favorites tab?
                                    if (LaboratoryService.MyFavorites == null ||
                                        LaboratoryService.MyFavorites.All(x => x.SampleID != sample.SampleID))
                                    {
                                        await GetMyFavorite(sample, null, null, null);
                                    }
                                    else
                                    {
                                        LaboratoryService.MyFavorites.First(x => x.SampleID == sample.SampleID)
                                            .SampleStatusTypeID = sample.SampleStatusTypeID;
                                        LaboratoryService.MyFavorites.First(x => x.SampleID == sample.SampleID)
                                            .ActionPerformedIndicator = true;

                                        TogglePendingSaveMyFavorites(
                                            LaboratoryService.MyFavorites.FirstOrDefault(x =>
                                                x.SampleID == sample.SampleID));
                                    }
                                }
                            }

                        break;
                    case LaboratoryTabEnum.MyFavorites:
                        if (LaboratoryService.SelectedMyFavorites != null)
                            foreach (var myFavorite in LaboratoryService.SelectedMyFavorites)
                            {
                                myFavorite.SampleStatusTypeID = (long) SampleStatusTypeEnum.MarkedForDeletion;
                                myFavorite.ActionPerformedIndicator = true;

                                TogglePendingSaveMyFavorites(myFavorite);

                                // Has the user selected the samples tab?
                                if (LaboratoryService.Samples == null ||
                                    LaboratoryService.Samples.All(x => x.SampleID != myFavorite.SampleID))
                                {
                                    var sample = await GetSample(myFavorite.SampleID);
                                    sample.Comment = RecordDeletionRequest.ReasonForDeletion;
                                    sample.SampleStatusTypeID = myFavorite.SampleStatusTypeID;
                                    sample.ActionPerformedIndicator = true;

                                    TogglePendingSaveSamples(sample);
                                }
                                else
                                {
                                    LaboratoryService.Samples.First(x => x.SampleID == myFavorite.SampleID).Comment =
                                        RecordDeletionRequest.ReasonForDeletion;
                                    LaboratoryService.Samples.First(x => x.SampleID == myFavorite.SampleID)
                                        .SampleStatusTypeID = myFavorite.SampleStatusTypeID;
                                    LaboratoryService.Samples.First(x => x.SampleID == myFavorite.SampleID)
                                        .ActionPerformedIndicator = true;

                                    TogglePendingSaveSamples(
                                        LaboratoryService.Samples.First(x => x.SampleID == myFavorite.SampleID));
                                }
                            }

                        break;
                }
            }

            DiagService.Close(LaboratoryService.SelectedSamples);
        }

        #endregion

        #region Cancel Click Event

        /// <summary>
        /// </summary>
        /// <returns></returns>
        protected async Task OnCancelClick()
        {
            try
            {
                await InvokeAsync(StateHasChanged);

                var result =
                    await ShowWarningDialog(MessageResourceKeyConstants.DoYouWantToCancelChangesMessage, null)
                        .ConfigureAwait(false);

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

        #endregion

        #endregion
    }
}