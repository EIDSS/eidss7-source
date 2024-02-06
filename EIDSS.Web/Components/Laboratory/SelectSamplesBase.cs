#region Usings

using EIDSS.Domain.Enumerations;
using EIDSS.Domain.ViewModels.Laboratory;
using Microsoft.AspNetCore.Components;
using Microsoft.Extensions.Logging;
using Radzen;
using Radzen.Blazor;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using static System.GC;
using static System.String;

#endregion

namespace EIDSS.Web.Components.Laboratory
{
    public class SelectSamplesBase : LaboratoryBaseComponent, IDisposable
    {
        #region Globals

        #region Dependencies

        [Inject] private ILogger<SelectSamplesBase> Logger { get; set; }

        #endregion

        #region Parameters

        [Parameter] public List<SamplesGetListViewModel> Samples { get; set; }

        #endregion

        #region Properties

        public IList<SamplesGetListViewModel> SelectedSamples { get; set; } = new List<SamplesGetListViewModel>();

        public RadzenDataGrid<SamplesGetListViewModel> SamplesGrid;
        public int Count;

        private bool _isSelected;
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

        public bool AllowAccessionIndicator { get; set; }

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
        public SelectSamplesBase(CancellationToken token) : base(token)
        {
            _token = token;
        }

        /// <summary>
        /// </summary>
        protected SelectSamplesBase() : base(CancellationToken.None)
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

            authenticatedUser = _tokenService.GetAuthenticatedUser();

            base.OnInitialized();

            _logger = Logger;
        }

        protected override void OnAfterRender(bool firstRender)
        {
            base.OnAfterRender(firstRender);

            if (!firstRender) return;
            LoadSamplesData(new LoadDataArgs());
            StateHasChanged();
        }

        /// <summary>
        /// </summary>
        /// <param name="disposing"></param>
        protected virtual void Dispose(bool disposing)
        {
            try
            {
                if (_disposedValue) return;
                if (disposing)
                {
                    _source?.Cancel();
                    _source?.Dispose();
                }

                _disposedValue = true;
            }
            catch (ObjectDisposedException)
            {
            }
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

        #region Load Data Method

        /// <summary>
        /// 
        /// </summary>
        /// <param name="args"></param>
        /// <returns></returns>
        protected void LoadSamplesData(LoadDataArgs args)
        {
            try
            {
                if (SamplesGrid.PageSize != 0)
                {
                }

                args.Top ??= 0;

                if ((!IsNullOrEmpty(args.OrderBy)))
                {
                    if (args.Sorts == null || args.Sorts.Any() == false)
                    {
                    }
                    else
                    {
                        if (args.Sorts.First().SortOrder.HasValue)
                            if (args.Sorts.First().SortOrder?.ToString() == "Ascending")
                            {
                            }
                    }
                }

                Count = Samples.Count;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion

        #region Data Grid Events

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

                AllowAccessionIndicator = SelectedSamples.Count > 0;
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
        protected bool IsRecordSelected(SamplesGetListViewModel item)
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
        protected void OnRecordSelectionChange(bool? value, SamplesGetListViewModel item)
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

                AllowAccessionIndicator = SelectedSamples.Count > 0;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion

        #region Submit Click Event

        /// <summary>
        /// </summary>
        /// <returns></returns>
        protected async Task OnSubmit()
        {
            try
            {
                IList<LaboratorySelectionViewModel> records = SelectedSamples
                    .Select(sample => new LaboratorySelectionViewModel {SampleID = sample.SampleID}).ToList();

                var sampleIdentifiers = await AccessionIn(records, (long) AccessionConditionTypeEnum.AcceptedInGoodCondition,
                    LaboratoryService.AccessionConditionTypes.First(x =>
                        x.IdfsBaseReference == (long) AccessionConditionTypeEnum.AcceptedInGoodCondition).Name)
                    .ConfigureAwait(false);

                DiagService.Close(sampleIdentifiers);
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