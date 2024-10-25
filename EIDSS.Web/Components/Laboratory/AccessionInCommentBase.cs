#region Usings

using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.Domain.Enumerations;
using EIDSS.Domain.ViewModels;
using EIDSS.Domain.ViewModels.Laboratory;
using EIDSS.Localization.Constants;
using EIDSS.Web.Enumerations;
using Microsoft.AspNetCore.Components;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Logging;
using Radzen.Blazor;

#endregion

namespace EIDSS.Web.Components.Laboratory
{
    public class AccessionInCommentBase : LaboratoryBaseComponent
    {
        #region Globals

        #region Dependencies

        [Inject] private ILogger<AccessionInCommentBase> Logger { get; set; }

        #endregion

        #region Parameters

        [Parameter] public LaboratoryTabEnum Tab { get; set; }
        [Parameter] public AccessionInViewModel AccessionInAction { get; set; }

        #endregion

        #region Properties

        protected RadzenTemplateForm<AccessionInViewModel> Form { get; set; }

        #endregion

        #region Member Variables

        private UserPermissions _userPermissions;

        #endregion

        #endregion

        #region Constructors

        /// <summary>
        /// </summary>
        /// <param name="token"></param>
        public AccessionInCommentBase(CancellationToken token) : base(token)
        {
        }

        /// <summary>
        /// </summary>
        protected AccessionInCommentBase() : base(CancellationToken.None)
        {
        }

        #endregion

        #region Methods

        #region Lifecycle Events

        /// <summary>
        /// </summary>
        protected override void OnInitialized()
        {
            AccessionInAction ??= new AccessionInViewModel();

            base.OnInitialized();

            _logger = Logger;

            authenticatedUser = _tokenService.GetAuthenticatedUser();

            _userPermissions = GetUserPermissions(PagePermission.AccessToLaboratorySamples);
            AccessionInAction.WritePermissionIndicator = AccessionInAction.WritePermissionIndicator switch
            {
                null => _userPermissions.Write,
                true when _userPermissions.Write == false => false,
                _ => AccessionInAction.WritePermissionIndicator
            };
        }

        #endregion

        #region OK Button Click Event

        /// <summary>
        /// </summary>
        protected async Task OnOKClick()
        {
            try
            {
                LaboratoryService.Samples ??= new List<SamplesGetListViewModel>();
                LaboratoryService.MyFavorites ??= new List<MyFavoritesGetListViewModel>();
                LaboratoryService.Testing ??= new List<TestingGetListViewModel>();

                switch (Tab)
                {
                    case LaboratoryTabEnum.Samples:
                        if (LaboratoryService.SearchSamples is not null && LaboratoryService.SearchSamples.Any(x =>
                                AccessionInAction.SampleID != null && x.SampleID == (long) AccessionInAction.SampleID))
                            await BuildComment(LaboratoryService.SearchSamples.First(x =>
                                AccessionInAction.SampleID != null && x.SampleID == (long) AccessionInAction.SampleID), null, null);
                        else
                            await BuildComment(LaboratoryService.Samples.First(x =>
                                AccessionInAction.SampleID != null && x.SampleID == (long) AccessionInAction.SampleID), null, null);
                        break;
                    case LaboratoryTabEnum.Testing:
                        if (LaboratoryService.SearchTesting is not null && LaboratoryService.SearchTesting.Any(x =>
                                AccessionInAction.SampleID != null && x.SampleID == (long) AccessionInAction.SampleID))
                            await BuildComment(null, null, LaboratoryService.SearchTesting.First(x =>
                                AccessionInAction.SampleID != null && x.SampleID == (long) AccessionInAction.SampleID));
                        else
                            await BuildComment(null, null, LaboratoryService.Testing.First(x =>
                                AccessionInAction.SampleID != null && x.SampleID == (long) AccessionInAction.SampleID));
                        break;
                    case LaboratoryTabEnum.MyFavorites:
                        if (LaboratoryService.SearchMyFavorites is not null && LaboratoryService.SearchMyFavorites.Any(x =>
                                AccessionInAction.SampleID != null && x.SampleID == (long) AccessionInAction.SampleID))
                            await BuildComment(null, LaboratoryService.SearchMyFavorites.First(x =>
                                AccessionInAction.SampleID != null && x.SampleID == (long) AccessionInAction.SampleID), null);
                        else
                            await BuildComment(null, LaboratoryService.MyFavorites.First(x =>
                                AccessionInAction.SampleID != null && x.SampleID == (long) AccessionInAction.SampleID), null);
                        break;
                }

                DialogReturnResult returnResult = new()
                {
                    ButtonResultText = Localizer.GetString(ButtonResourceKeyConstants.OKButton)
                };
                DiagService.Close(returnResult);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        /// <summary>
        /// </summary>
        /// <param name="sample"></param>
        /// <param name="myFavorite"></param>
        /// <param name="test"></param>
        private async Task BuildComment(SamplesGetListViewModel sample, MyFavoritesGetListViewModel myFavorite, TestingGetListViewModel test)
        {
            if (sample is not null)
            {
                sample.AccessionComment = AccessionInAction.AccessionInComment;
                sample.ActionPerformedIndicator = true;

                if (sample.FavoriteIndicator)
                {
                    if (LaboratoryService.MyFavorites.Any(x => x.SampleID == sample.SampleID))
                        LaboratoryService.MyFavorites.First(x => x.SampleID == sample.SampleID).AccessionComment =
                            AccessionInAction.AccessionInComment;
                    else
                        await GetMyFavorites();

                    if (LaboratoryService.MyFavorites.Any(x => x.SampleID == sample.SampleID))
                        TogglePendingSaveMyFavorites(
                            LaboratoryService.MyFavorites.First(x => x.SampleID == sample.SampleID));
                }

                TogglePendingSaveSamples(sample);
            }
            else if (myFavorite is not null)
            {
                myFavorite.AccessionComment = AccessionInAction.AccessionInComment;
                
                sample = await GetSample(myFavorite.SampleID);
                sample.AccessionComment = AccessionInAction.AccessionInComment;
                sample.RowAction = (int) RowActionTypeEnum.Update;
                sample.ActionPerformedIndicator = true;

                if (myFavorite.TestID is not null)
                {
                    if (LaboratoryService.Testing.Any(x => x.TestID == myFavorite.TestID))
                    {
                        LaboratoryService.Testing.First(x => x.TestID == myFavorite.TestID).AccessionComment =
                            AccessionInAction.AccessionInComment;
                        LaboratoryService.Testing.First(x => x.TestID == myFavorite.TestID).RowAction =
                            (int) RowActionTypeEnum.Update;
                        LaboratoryService.Testing.First(x => x.TestID == myFavorite.TestID).ActionPerformedIndicator = true;
                        TogglePendingSaveTesting(LaboratoryService.Testing.First(x => x.TestID == myFavorite.TestID));
                    }
                    else
                    {
                        if (LaboratoryService.SearchTesting.Any(x => x.TestID == myFavorite.TestID))
                        {
                            LaboratoryService.SearchTesting.First(x => x.TestID == myFavorite.TestID).AccessionComment =
                                AccessionInAction.AccessionInComment;
                            LaboratoryService.SearchTesting.First(x => x.TestID == myFavorite.TestID).RowAction =
                                (int) RowActionTypeEnum.Update;
                            LaboratoryService.SearchTesting.First(x => x.TestID == myFavorite.TestID)
                                .ActionPerformedIndicator = true;
                            TogglePendingSaveTesting(LaboratoryService.SearchTesting.First(x => x.TestID == myFavorite.TestID));
                        }
                    }
                }

                TogglePendingSaveSamples(sample);

                TogglePendingSaveMyFavorites(myFavorite);
            }
            else if (test is not null)
            {
                test.AccessionComment = AccessionInAction.AccessionInComment;
                
                sample = await GetSample(test.SampleID);
                sample.AccessionComment = AccessionInAction.AccessionInComment;
                sample.RowAction = (int) RowActionTypeEnum.Update;
                sample.ActionPerformedIndicator = true;
                TogglePendingSaveSamples(sample);

                if (test.FavoriteIndicator)
                {
                    if (LaboratoryService.MyFavorites.Any(x => x.SampleID == test.SampleID))
                        LaboratoryService.MyFavorites.First(x => x.SampleID == test.SampleID).AccessionComment =
                            AccessionInAction.AccessionInComment;
                    else
                        await GetMyFavorites();

                    if (LaboratoryService.MyFavorites.Any(x => x.SampleID == test.SampleID))
                        TogglePendingSaveMyFavorites(
                            LaboratoryService.MyFavorites.First(x => x.SampleID == test.SampleID));
                }

                TogglePendingSaveTesting(test);
            }
        }

        #endregion

        #region Cancel Button Click Event

        /// <summary>
        /// </summary>
        /// <returns></returns>
        protected async Task OnCancelClick()
        {
            try
            {
                await InvokeAsync(StateHasChanged);

                if (Form.EditContext.IsModified())
                {
                    var result = await ShowWarningDialog(MessageResourceKeyConstants.DoYouWantToCancelChangesMessage,
                        null);

                    if (result is DialogReturnResult returnResult)
                        if (returnResult.ButtonResultText == Localizer.GetString(ButtonResourceKeyConstants.YesButton))
                            DiagService.Close(result);
                }
                else
                    DiagService.Close();
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