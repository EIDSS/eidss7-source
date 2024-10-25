#region Usings

using EIDSS.ClientLibrary.Enumerations;
using EIDSS.ClientLibrary.Responses;
using EIDSS.Domain.Enumerations;
using EIDSS.Domain.ViewModels;
using EIDSS.Domain.ViewModels.Laboratory;
using EIDSS.Localization.Constants;
using EIDSS.Web.Components.CrossCutting;
using EIDSS.Web.Enumerations;
using EIDSS.Web.ViewModels;
using Microsoft.AspNetCore.Components;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Logging;
using Radzen;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.JSInterop;
using static EIDSS.ClientLibrary.Enumerations.EIDSSConstants;
using static System.String;

#endregion

namespace EIDSS.Web.Components.Laboratory
{
    /// <summary>
    /// </summary>
    public class MenuBase : LaboratoryBaseComponent, IDisposable
    {
        #region Globals

        #region Dependencies

        [Inject] private IJSRuntime JsRuntime { get; set; }
        [Inject] private ILogger<MenuBase> Logger { get; set; }

        #endregion

        #region Parameters

        [Parameter] public LaboratoryTabEnum Tab { get; set; }
        [Parameter] public EventCallback AccessionInEvent { get; set; }
        [Parameter] public EventCallback AssignTestEvent { get; set; }
        [Parameter] public EventCallback CreateAliquotEvent { get; set; }
        [Parameter] public EventCallback CreateDerivativeEvent { get; set; }
        [Parameter] public EventCallback TransferOutEvent { get; set; }
        [Parameter] public EventCallback RegisterNewSampleEvent { get; set; }
        [Parameter] public EventCallback SetTestResultEvent { get; set; }
        [Parameter] public EventCallback AmendTestResultEvent { get; set; }
        [Parameter] public EventCallback ValidateTestResultEvent { get; set; }
        [Parameter] public EventCallback DestroySampleByIncinerationEvent { get; set; }
        [Parameter] public EventCallback DestroySampleByAutoclaveEvent { get; set; }
        [Parameter] public EventCallback ApproveSampleDestructionEvent { get; set; }
        [Parameter] public EventCallback RejectSampleDestructionEvent { get; set; }
        [Parameter] public EventCallback DeleteSampleRecordEvent { get; set; }
        [Parameter] public EventCallback DeleteTestRecordEvent { get; set; }
        [Parameter] public EventCallback ApproveRecordDeletionEvent { get; set; }
        [Parameter] public EventCallback RejectRecordDeletionEvent { get; set; }
        [Parameter] public EventCallback RestoreDeletedSampleRecordEvent { get; set; }
        [Parameter] public EventCallback ShowSamplePaperFormReportEvent { get; set; }
        [Parameter] public EventCallback ShowAccessionInPaperFormReportEvent { get; set; }
        [Parameter] public EventCallback ShowTestResultPaperFormReportEvent { get; set; }
        [Parameter] public EventCallback ShowTransferPaperFormReportEvent { get; set; }
        [Parameter] public EventCallback ShowSampleDestructionPaperFormReportEvent { get; set; }

        #endregion

        #region Properties

        private bool _accessionInDisabledIndicator;

        public bool AccessionInDisabledIndicator
        {
            get
            {
                _accessionInDisabledIndicator = true;

                _userPermissions = GetUserPermissions(PagePermission.CanPerformSampleAccessionIn);

                switch (Tab)
                {
                    case LaboratoryTabEnum.Samples:
                        if (_userPermissions.Execute)
                            if (LaboratoryService.SelectedSamples is {Count: > 0} &&
                                !LaboratoryService.SelectedSamples.Any(x =>
                                    x.AccessionIndicator == 1 || x.AccessionConditionTypeID is not null))
                                _accessionInDisabledIndicator = false;
                        break;
                    case LaboratoryTabEnum.MyFavorites:
                        if (_userPermissions.Execute)
                            if (LaboratoryService.SelectedMyFavorites is {Count: > 0} &&
                                !LaboratoryService.SelectedMyFavorites.Any(x =>
                                    x.AccessionIndicator == 1 || x.AccessionConditionTypeID is not null))
                                _accessionInDisabledIndicator = false;
                        break;
                }

                return _accessionInDisabledIndicator;
            }
        }

        private bool _groupAccessionDisabledIndicator;

        public bool GroupAccessionInDisabledIndicator
        {
            get
            {
                _groupAccessionDisabledIndicator = true;

                _userPermissions = GetUserPermissions(PagePermission.CanPerformSampleAccessionIn);

                switch (Tab)
                {
                    case LaboratoryTabEnum.Samples:
                        if (_userPermissions.Execute)
                            _groupAccessionDisabledIndicator = false;
                        break;
                    case LaboratoryTabEnum.MyFavorites:
                        if (_userPermissions.Execute)
                            _groupAccessionDisabledIndicator = false;
                        break;
                }

                return _groupAccessionDisabledIndicator;
            }
        }

        private bool _assignTestDisabledIndicator;

        public bool AssignTestDisabledIndicator
        {
            get
            {
                _assignTestDisabledIndicator = true;

                _userPermissions = GetUserPermissions(PagePermission.AccessToLaboratoryTesting);

                switch (Tab)
                {
                    case LaboratoryTabEnum.Samples:
                        if (LaboratoryService.SelectedSamples is {Count: > 0} && _userPermissions.Create)
                        {
                            bool conditionSampleOk;
                            var diseaseSampleOk = conditionSampleOk = false;

                            var diseaseId = LaboratoryService.SelectedSamples.First().DiseaseID;
                            if (LaboratoryService.SelectedSamples.All(x =>
                                    x.DiseaseID == diseaseId)) // all diseases must be the same
                                diseaseSampleOk = true;

                            if (LaboratoryService.SelectedSamples.All(x =>
                                    x.AccessionConditionTypeID is (long) AccessionConditionTypeEnum
                                            .AcceptedInGoodCondition
                                        or (long) AccessionConditionTypeEnum.AcceptedInPoorCondition
                                    && x.SampleStatusTypeID == (long) SampleStatusTypeEnum.InRepository))
                                conditionSampleOk = true;

                            if (diseaseSampleOk && conditionSampleOk) _assignTestDisabledIndicator = false;
                        }

                        break;
                    case LaboratoryTabEnum.Testing:
                        bool conditionTestingOk;
                        var diseaseTestingOk = conditionTestingOk = false;

                        if (LaboratoryService.SelectedTesting is {Count: > 0} && _userPermissions.Create)
                        {
                            var diseaseId = LaboratoryService.SelectedTesting.First().DiseaseID;
                            if (LaboratoryService.SelectedTesting.All(x =>
                                    x.DiseaseID == diseaseId)) // all diseases must be the same
                                diseaseTestingOk = true;

                            if (LaboratoryService.SelectedTesting.All(x =>
                                    x.AccessionConditionTypeID is (long) AccessionConditionTypeEnum
                                            .AcceptedInGoodCondition
                                        or (long) AccessionConditionTypeEnum.AcceptedInPoorCondition
                                    && x.SampleStatusTypeID == (long) SampleStatusTypeEnum.InRepository))
                                conditionTestingOk = true;

                            if (diseaseTestingOk && conditionTestingOk) _assignTestDisabledIndicator = false;
                        }

                        break;
                    case LaboratoryTabEnum.MyFavorites:
                        if (LaboratoryService.SelectedMyFavorites is {Count: > 0} && _userPermissions.Create)
                            if (LaboratoryService.SelectedMyFavorites.All(x =>
                                    x.AccessionConditionTypeID is (long) AccessionConditionTypeEnum
                                            .AcceptedInGoodCondition
                                        or (long) AccessionConditionTypeEnum.AcceptedInPoorCondition
                                    && x.SampleStatusTypeID == (long) SampleStatusTypeEnum.InRepository))
                                _assignTestDisabledIndicator = false;
                        break;
                }

                return _assignTestDisabledIndicator;
            }
        }

        private bool _createAliquotDisabledIndicator;

        public bool CreateAliquotDisabledIndicator
        {
            get
            {
                _createAliquotDisabledIndicator = true;

                _userPermissions = GetUserPermissions(PagePermission.AccessToLaboratorySamples);

                switch (Tab)
                {
                    case LaboratoryTabEnum.Samples:
                        if (LaboratoryService.SelectedSamples is {Count: > 0} && _userPermissions.Create)
                            if (LaboratoryService.SelectedSamples.All(x =>
                                    x.AccessionConditionTypeID is (long) AccessionConditionTypeEnum
                                            .AcceptedInGoodCondition
                                        or (long) AccessionConditionTypeEnum.AcceptedInPoorCondition
                                    && x.SampleStatusTypeID == (long) SampleStatusTypeEnum.InRepository))
                                _createAliquotDisabledIndicator = false;
                        break;
                    case LaboratoryTabEnum.MyFavorites:
                        if (LaboratoryService.SelectedMyFavorites is {Count: > 0} && _userPermissions.Create)
                            if (LaboratoryService.SelectedMyFavorites.All(x =>
                                    x.AccessionConditionTypeID is (long) AccessionConditionTypeEnum
                                            .AcceptedInGoodCondition
                                        or (long) AccessionConditionTypeEnum.AcceptedInPoorCondition
                                    && x.SampleStatusTypeID == (long) SampleStatusTypeEnum.InRepository))
                                _createAliquotDisabledIndicator = false;
                        break;
                }

                return _createAliquotDisabledIndicator;
            }
        }

        private bool _createDerivativeDisabledIndicator;

        public bool CreateDerivativeDisabledIndicator
        {
            get
            {
                _createDerivativeDisabledIndicator = true;

                _userPermissions = GetUserPermissions(PagePermission.AccessToLaboratorySamples);

                switch (Tab)
                {
                    case LaboratoryTabEnum.Samples:
                        if (LaboratoryService.SelectedSamples is {Count: > 0} && _userPermissions.Create)
                            if (LaboratoryService.SelectedSamples.All(x =>
                                    x.AccessionConditionTypeID is (long) AccessionConditionTypeEnum
                                            .AcceptedInGoodCondition
                                        or (long) AccessionConditionTypeEnum.AcceptedInPoorCondition
                                    && x.SampleStatusTypeID == (long) SampleStatusTypeEnum.InRepository))
                                _createDerivativeDisabledIndicator = false;
                        break;
                    case LaboratoryTabEnum.MyFavorites:
                        if (LaboratoryService.SelectedMyFavorites is {Count: > 0} && _userPermissions.Create)
                            if (LaboratoryService.SelectedMyFavorites.All(x =>
                                    x.AccessionConditionTypeID is (long) AccessionConditionTypeEnum
                                            .AcceptedInGoodCondition
                                        or (long) AccessionConditionTypeEnum.AcceptedInPoorCondition
                                    && x.SampleStatusTypeID == (long) SampleStatusTypeEnum.InRepository))
                                _createDerivativeDisabledIndicator = false;
                        break;
                }

                return _createDerivativeDisabledIndicator;
            }
        }

        private bool _transferOutDisabledIndicator;

        public bool TransferOutDisabledIndicator
        {
            get
            {
                _transferOutDisabledIndicator = true;

                _userPermissions = GetUserPermissions(PagePermission.AccessToLaboratoryTransferred);

                switch (Tab)
                {
                    case LaboratoryTabEnum.Samples:
                        if (LaboratoryService.SelectedSamples is {Count: > 0} && _userPermissions.Create && LaboratoryService.SelectedSamples.All(
                                x => x.AccessionIndicator == 1 && x.TestAssignedCount == 0 &&
                                     x.SampleStatusTypeID is (long) SampleStatusTypeEnum.InRepository))
                            _transferOutDisabledIndicator = false;
                        break;
                    case LaboratoryTabEnum.MyFavorites:
                        if (LaboratoryService.SelectedMyFavorites is {Count: > 0} && _userPermissions.Create &&
                            LaboratoryService.SelectedMyFavorites.All(x =>
                                x.AccessionIndicator == 1 && x.TestAssignedIndicator == false &&
                                x.SampleStatusTypeID is (long) SampleStatusTypeEnum.InRepository))
                            _transferOutDisabledIndicator = false;
                        break;
                    case LaboratoryTabEnum.Transferred:
                        if (LaboratoryService.SelectedTransferred is {Count: > 0} && _userPermissions.Create &&
                            !LaboratoryService.SelectedTransferred.Any(x =>
                                x.AccessionIndicator == 0 ||
                                x.AccessionIndicator == 1 && IsNullOrEmpty(x.EIDSSLaboratorySampleID) ||
                                x.SampleStatusTypeID is (long) SampleStatusTypeEnum.Deleted or (long) SampleStatusTypeEnum.MarkedForDeletion or (long) SampleStatusTypeEnum.Destroyed or (long) SampleStatusTypeEnum.MarkedForDestruction or (long) SampleStatusTypeEnum.TransferredOut))
                            _transferOutDisabledIndicator = false;
                        break;
                }

                return _transferOutDisabledIndicator;
            }
        }

        private bool _registerNewSampleDisabledIndicator;

        public bool RegisterNewSampleDisabledIndicator
        {
            get
            {
                _registerNewSampleDisabledIndicator = true;

                _userPermissions = GetUserPermissions(PagePermission.CanPerformSampleAccessionIn);

                if (!_userPermissions.Execute) return _registerNewSampleDisabledIndicator;
                switch (Tab)
                {
                    case LaboratoryTabEnum.Samples:
                        _userPermissions = GetUserPermissions(PagePermission.AccessToLaboratorySamples);

                        if (_userPermissions.Read)
                            _registerNewSampleDisabledIndicator = false;
                        break;
                    case LaboratoryTabEnum.MyFavorites:
                        _userPermissions = GetUserPermissions(PagePermission.AccessToLaboratorySamples);

                        if (_userPermissions.Read)
                            _registerNewSampleDisabledIndicator = false;
                        break;
                }

                return _registerNewSampleDisabledIndicator;
            }
        }

        private bool _setTestResultDisabledIndicator;

        public bool SetTestResultDisabledIndicator
        {
            get
            {
                _setTestResultDisabledIndicator = true;

                _userPermissions = GetUserPermissions(PagePermission.AccessToLaboratoryTesting);

                switch (Tab)
                {
                    case LaboratoryTabEnum.Testing:
                        if (LaboratoryService.SelectedTesting is {Count: > 0} && _userPermissions.Write &&
                            LaboratoryService.SelectedTesting.Count(x =>
                                x.TestStatusTypeID == (long) TestStatusTypeEnum.InProgress) ==
                            1) _setTestResultDisabledIndicator = false;
                        break;
                    case LaboratoryTabEnum.MyFavorites:
                        if (LaboratoryService.SelectedMyFavorites is {Count: > 0} && _userPermissions.Write &&
                            LaboratoryService.SelectedMyFavorites.Count(x =>
                                x.TestID != null && x.TestStatusTypeID == (long) TestStatusTypeEnum.InProgress) ==
                            1) _setTestResultDisabledIndicator = false;
                        break;
                }

                return _setTestResultDisabledIndicator;
            }
        }

        private bool _validateTestResultDisabledIndicator;

        public bool ValidateTestResultDisabledIndicator
        {
            get
            {
                _validateTestResultDisabledIndicator = true;

                var finalizeTestUserPermissions = GetUserPermissions(PagePermission.CanFinalizeLaboratoryTest);
                _userPermissions = GetUserPermissions(PagePermission.AccessToLaboratoryApprovals);

                if (!finalizeTestUserPermissions.Execute || !_userPermissions.Write)
                    return _validateTestResultDisabledIndicator;
                switch (Tab)
                {
                    case LaboratoryTabEnum.Approvals:
                        if (LaboratoryService.SelectedApprovals is { Count: > 0 } &&
                            LaboratoryService.SelectedApprovals.Any(x =>
                                x.TestStatusTypeID == (long)TestStatusTypeEnum.Preliminary))
                            _validateTestResultDisabledIndicator = false;
                        break;
                    case LaboratoryTabEnum.Batches:
                        if (LaboratoryService.SelectedBatches is { Count: > 0 } &&
                            LaboratoryService.SelectedBatchTests != null &&
                            LaboratoryService.SelectedBatchTests.Count(x =>
                                x.TestStatusTypeID == (long)TestStatusTypeEnum.Preliminary) ==
                            1) _validateTestResultDisabledIndicator = false;
                        break;
                    case LaboratoryTabEnum.MyFavorites:
                        if (LaboratoryService.SelectedMyFavorites is { Count: > 0 } &&
                            LaboratoryService.SelectedMyFavorites.Any(x =>
                                x.TestID != null && x.SentToOrganizationID == authenticatedUser.OfficeId &&
                                x.TestStatusTypeID == (long)TestStatusTypeEnum.Preliminary))
                            _validateTestResultDisabledIndicator = false;
                        break;
                }

                return _validateTestResultDisabledIndicator;
            }
        }

        private bool _amendTestResultDisabledIndicator;

        public bool AmendTestResultDisabledIndicator
        {
            get
            {
                _amendTestResultDisabledIndicator = true;

                _userPermissions = GetUserPermissions(PagePermission.CanAmendATest);

                if (!_userPermissions.Execute) return _amendTestResultDisabledIndicator;
                switch (Tab)
                {
                    case LaboratoryTabEnum.Testing:
                        if (LaboratoryService.SelectedTesting is { Count: > 0 })
                        {
                            if (LaboratoryService.SelectedTesting.Any(x =>
                                    x.TestStatusTypeID is (long)TestStatusTypeEnum.Deleted
                                        or (long)TestStatusTypeEnum.MarkedForDeletion
                                        or (long)TestStatusTypeEnum.InProgress or (long)TestStatusTypeEnum.Preliminary
                                        or (long)TestStatusTypeEnum.NotStarted))
                                _amendTestResultDisabledIndicator = true;
                            else if (LaboratoryService.SelectedTesting.Count > 1)
                                _amendTestResultDisabledIndicator = true;
                            else
                                _amendTestResultDisabledIndicator = false;
                        }

                        break;
                    case LaboratoryTabEnum.MyFavorites:
                        if (LaboratoryService.SelectedMyFavorites is { Count: > 0 })
                        {
                            if (LaboratoryService.SelectedMyFavorites.Any(x =>
                                    x.WritePermissionIndicator == false ||
                                    x.TestStatusTypeID is (long)TestStatusTypeEnum.Deleted or (long)TestStatusTypeEnum.MarkedForDeletion or (long)TestStatusTypeEnum.InProgress or (long)TestStatusTypeEnum.Preliminary or (long)TestStatusTypeEnum.NotStarted))
                                _amendTestResultDisabledIndicator = true;
                            else if (LaboratoryService.SelectedMyFavorites.Count > 1)
                                _amendTestResultDisabledIndicator = true;
                            else if (LaboratoryService.SelectedMyFavorites.Any(x => x.TestID != null))
                                _amendTestResultDisabledIndicator = false;
                        }

                        break;
                }

                return _amendTestResultDisabledIndicator;
            }
        }

        private bool _destroySampleByIncinerationDisabledIndicator;

        public bool DestroySampleByIncinerationDisabledIndicator
        {
            get
            {
                _destroySampleByIncinerationDisabledIndicator = true;

                _userPermissions = GetUserPermissions(PagePermission.CanDestroySamples);

                switch (Tab)
                {
                    case LaboratoryTabEnum.Samples:
                        if (_userPermissions.Execute)
                            if (LaboratoryService.SelectedSamples is {Count: > 0} &&
                                LaboratoryService.SelectedSamples.All(x =>
                                    x.AccessionIndicator == 1 && x.TestAssignedCount == 0 &&
                                    x.SampleStatusTypeID is (long) SampleStatusTypeEnum.InRepository))
                                _destroySampleByIncinerationDisabledIndicator = false;
                        break;
                    case LaboratoryTabEnum.MyFavorites:
                        if (_userPermissions.Execute)
                            if (LaboratoryService.SelectedMyFavorites is {Count: > 0} &&
                                LaboratoryService.SelectedMyFavorites.All(x =>
                                    x.AccessionIndicator == 1 && x.TestAssignedIndicator == false &&
                                    x.SampleStatusTypeID is (long) SampleStatusTypeEnum.InRepository))
                                _destroySampleByIncinerationDisabledIndicator = false;
                        break;
                }

                return _destroySampleByIncinerationDisabledIndicator;
            }
        }

        private bool _destroySampleByAutoclaveDisabledIndicator;

        public bool DestroySampleByAutoclaveDisabledIndicator
        {
            get
            {
                _destroySampleByAutoclaveDisabledIndicator = true;

                _userPermissions = GetUserPermissions(PagePermission.CanDestroySamples);

                switch (Tab)
                {
                    case LaboratoryTabEnum.Samples:
                        if (_userPermissions.Execute)
                            if (LaboratoryService.SelectedSamples is {Count: > 0} &&
                                LaboratoryService.SelectedSamples.All(x =>
                                    x.AccessionIndicator == 1 && x.TestAssignedCount == 0 &&
                                    x.SampleStatusTypeID is (long) SampleStatusTypeEnum.InRepository))
                                _destroySampleByAutoclaveDisabledIndicator = false;
                        break;
                    case LaboratoryTabEnum.MyFavorites:
                        if (_userPermissions.Execute)
                            if (LaboratoryService.SelectedMyFavorites is {Count: > 0} &&
                                LaboratoryService.SelectedMyFavorites.All(x =>
                                    x.AccessionIndicator == 1 && x.TestAssignedIndicator == false &&
                                    x.SampleStatusTypeID is (long) SampleStatusTypeEnum.InRepository))
                                _destroySampleByAutoclaveDisabledIndicator = false;
                        break;
                }

                return _destroySampleByAutoclaveDisabledIndicator;
            }
        }

        private bool _approveSampleDestructionDisabledIndicator;

        public bool ApproveSampleDestructionDisabledIndicator
        {
            get
            {
                _approveSampleDestructionDisabledIndicator = true;

                _userPermissions = GetUserPermissions(PagePermission.AccessToLaboratoryApprovals);

                if (!_userPermissions.Write) return _approveSampleDestructionDisabledIndicator;
                switch (Tab)
                {
                    case LaboratoryTabEnum.Approvals:
                        if (LaboratoryService.SelectedApprovals is { Count: > 0 } &&
                            LaboratoryService.SelectedApprovals.All(x =>
                                x.SampleStatusTypeID == (long)SampleStatusTypeEnum.MarkedForDestruction))
                            _approveSampleDestructionDisabledIndicator = false;
                        break;
                    case LaboratoryTabEnum.MyFavorites:
                        if (LaboratoryService.SelectedMyFavorites is { Count: > 0 } &&
                            LaboratoryService.SelectedMyFavorites.All(x =>
                                x.SampleStatusTypeID == (long)SampleStatusTypeEnum.MarkedForDestruction))
                            _approveSampleDestructionDisabledIndicator = false;
                        break;
                }

                return _approveSampleDestructionDisabledIndicator;
            }
        }

        private bool _rejectSampleDestructionDisabledIndicator;

        public bool RejectSampleDestructionDisabledIndicator
        {
            get
            {
                _rejectSampleDestructionDisabledIndicator = true;

                _userPermissions = GetUserPermissions(PagePermission.AccessToLaboratoryApprovals);

                if (!_userPermissions.Write) return _rejectSampleDestructionDisabledIndicator;
                switch (Tab)
                {
                    case LaboratoryTabEnum.Approvals:
                        if (LaboratoryService.SelectedApprovals is { Count: > 0 } &&
                            LaboratoryService.SelectedApprovals.All(x =>
                                x.SampleStatusTypeID == (long)SampleStatusTypeEnum.MarkedForDestruction))
                            _rejectSampleDestructionDisabledIndicator = false;
                        break;
                    case LaboratoryTabEnum.MyFavorites:
                        if (LaboratoryService.SelectedMyFavorites is { Count: > 0 } &&
                            LaboratoryService.SelectedMyFavorites.All(x =>
                                x.SampleStatusTypeID == (long)SampleStatusTypeEnum.MarkedForDestruction))
                            _rejectSampleDestructionDisabledIndicator = false;
                        break;
                }

                return _rejectSampleDestructionDisabledIndicator;
            }
        }

        private bool _deleteSampleRecordDisabledIndicator;

        public bool DeleteSampleRecordDisabledIndicator
        {
            get
            {
                _deleteSampleRecordDisabledIndicator = true;

                _userPermissions = GetUserPermissions(PagePermission.CanDestroySamples);

                if (!_userPermissions.Execute) return _deleteSampleRecordDisabledIndicator;
                switch (Tab)
                {
                    case LaboratoryTabEnum.Samples:
                        if (LaboratoryService.SelectedSamples is { Count: > 0 } && LaboratoryService.SelectedSamples.All(
                                x =>
                                    x.DeletePermissionIndicator && (x.AccessionIndicator == 1 ||
                                    !IsNullOrEmpty(x.EIDSSLaboratorySampleID)) && (x.TestAssignedCount == 0 ||
                                    x.TestCompletedIndicator) && x.SampleStatusTypeID is 
                                        (long)SampleStatusTypeEnum.Destroyed or 
                                        (long)SampleStatusTypeEnum.MarkedForDestruction or 
                                        (long)SampleStatusTypeEnum.InRepository))
                            _deleteSampleRecordDisabledIndicator = false;
                        break;
                    case LaboratoryTabEnum.MyFavorites:
                        if (LaboratoryService.SelectedMyFavorites is { Count: > 0 } &&
                            LaboratoryService.SelectedMyFavorites.All(x =>
                                x.DeletePermissionIndicator && (x.AccessionIndicator == 1 ||
                                !IsNullOrEmpty(x.EIDSSLaboratorySampleID)) && (x.TestAssignedIndicator == false ||
                                x.TestCompletedIndicator) && x.SampleStatusTypeID is 
                                    (long)SampleStatusTypeEnum.Destroyed or 
                                    (long)SampleStatusTypeEnum.MarkedForDestruction or 
                                    (long)SampleStatusTypeEnum.InRepository))
                            _deleteSampleRecordDisabledIndicator = false;
                        break;
                }

                return _deleteSampleRecordDisabledIndicator;
            }
        }

        private bool _deleteTestRecordDisabledIndicator;

        public bool DeleteTestRecordDisabledIndicator
        {
            get
            {
                _deleteTestRecordDisabledIndicator = true;

                _userPermissions = GetUserPermissions(PagePermission.CanDestroySamples);

                if (!_userPermissions.Execute) return _deleteTestRecordDisabledIndicator;
                switch (Tab)
                {
                    case LaboratoryTabEnum.Testing:
                        if (LaboratoryService.SelectedTesting is { Count: > 0 } && LaboratoryService.SelectedTesting.All(
                                x => x.WritePermissionIndicator &&
                                     x.TestStatusTypeID is (long)TestStatusTypeEnum.NotStarted or (long)TestStatusTypeEnum.InProgress or (long)TestStatusTypeEnum.Preliminary))
                            _deleteTestRecordDisabledIndicator = false;
                        break;
                    case LaboratoryTabEnum.MyFavorites:
                        if (LaboratoryService.SelectedMyFavorites is { Count: > 0 } &&
                            LaboratoryService.SelectedMyFavorites.All(x =>
                                x.WritePermissionIndicator && x.TestID != null &&
                                x.TestStatusTypeID is (long)TestStatusTypeEnum.NotStarted or (long)TestStatusTypeEnum.InProgress or (long)TestStatusTypeEnum.Preliminary))
                            _deleteTestRecordDisabledIndicator = false;
                        break;
                }

                return _deleteTestRecordDisabledIndicator;
            }
        }

        private bool _approveRecordDeletionDisabledIndicator;

        public bool ApproveRecordDeletionDisabledIndicator
        {
            get
            {
                _approveRecordDeletionDisabledIndicator = true;

                _userPermissions = GetUserPermissions(PagePermission.AccessToLaboratoryApprovals);

                if (!_userPermissions.Write) return _approveRecordDeletionDisabledIndicator;
                switch (Tab)
                {
                    case LaboratoryTabEnum.Approvals:
                        if (LaboratoryService.SelectedApprovals is { Count: > 0 } &&
                            LaboratoryService.SelectedApprovals.All(x =>
                                x.ActionRequestedID is (long)SampleStatusTypeEnum.MarkedForDeletion
                                    or (long)TestStatusTypeEnum.MarkedForDeletion))
                            _approveRecordDeletionDisabledIndicator = false;
                        break;
                    case LaboratoryTabEnum.MyFavorites:
                        if (LaboratoryService.SelectedMyFavorites is { Count: > 0 } &&
                            LaboratoryService.SelectedMyFavorites.All(x => x.ActionPerformedIndicator == false &&
                                (x.SampleStatusTypeID == (long)SampleStatusTypeEnum.MarkedForDeletion ||
                                x.TestStatusTypeID is (long)TestStatusTypeEnum.MarkedForDeletion)))
                            _approveRecordDeletionDisabledIndicator = false;
                        break;
                }

                return _approveRecordDeletionDisabledIndicator;
            }
        }

        private bool _rejectRecordDeletionDisabledIndicator;

        public bool RejectRecordDeletionDisabledIndicator
        {
            get
            {
                _rejectRecordDeletionDisabledIndicator = true;

                _userPermissions = GetUserPermissions(PagePermission.AccessToLaboratoryApprovals);

                if (!_userPermissions.Write) return _rejectRecordDeletionDisabledIndicator;
                switch (Tab)
                {
                    case LaboratoryTabEnum.Approvals:
                        if (LaboratoryService.SelectedApprovals is { Count: > 0 } &&
                            LaboratoryService.SelectedApprovals.All(x =>
                                x.ActionRequestedID is (long)SampleStatusTypeEnum.MarkedForDeletion
                                    or (long)TestStatusTypeEnum.MarkedForDeletion))
                            _rejectRecordDeletionDisabledIndicator = false;
                        break;
                    case LaboratoryTabEnum.MyFavorites:
                        if (LaboratoryService.SelectedMyFavorites is { Count: > 0 } &&
                            LaboratoryService.SelectedMyFavorites.All(x => x.ActionPerformedIndicator == false &&
                                (x.SampleStatusTypeID == (long)SampleStatusTypeEnum.MarkedForDeletion ||
                                x.TestStatusTypeID is (long)TestStatusTypeEnum.MarkedForDeletion)))
                            _rejectRecordDeletionDisabledIndicator = false;
                        break;
                }

                return _rejectRecordDeletionDisabledIndicator;
            }
        }

        private bool _restoreSampleDisabledIndicator;

        public bool RestoreSampleDisabledIndicator
        {
            get
            {
                _restoreSampleDisabledIndicator = true;

                _userPermissions = GetUserPermissions(PagePermission.CanModifyStatusOfRejectedSample);

                if (!_userPermissions.Execute) return _restoreSampleDisabledIndicator;
                switch (Tab)
                {
                    case LaboratoryTabEnum.Samples:
                        if (LaboratoryService.SelectedSamples is { Count: > 0 } &&
                            (authenticatedUser.IsInRole(RoleEnum.Administrator) ||
                             authenticatedUser.IsInRole(RoleEnum.ChiefofLaboratory_Human) ||
                             authenticatedUser.IsInRole(RoleEnum.ChiefofLaboratory_Vet) ||
                             GetUserPermissions(PagePermission.CanRestoreDeletedRecords).Execute))
                            if (LaboratoryService.SelectedSamples.Any(x => x.SampleStatusTypeID is not null
                                    and not ((long)SampleStatusTypeEnum.InRepository or
                                    (long)SampleStatusTypeEnum.Destroyed or
                                    (long)SampleStatusTypeEnum.MarkedForDestruction or
                                    (long)SampleStatusTypeEnum.MarkedForDeletion or
                                    (long)SampleStatusTypeEnum.TransferredOut)))
                                _restoreSampleDisabledIndicator = false;
                        break;
                }

                return _restoreSampleDisabledIndicator;
            }
        }

        private bool _samplePaperFormReportDisabledIndicator;

        public bool SamplePaperFormReportDisabledIndicator
        {
            get
            {
                _samplePaperFormReportDisabledIndicator = true;

                switch (Tab)
                {
                    case LaboratoryTabEnum.Samples:
                        if (LaboratoryService.SelectedSamples is {Count: 1})
                            _samplePaperFormReportDisabledIndicator = false;
                        break;
                    case LaboratoryTabEnum.Testing:
                        if (LaboratoryService.SelectedTesting is {Count: 1})
                            _samplePaperFormReportDisabledIndicator = false;
                        break;
                    case LaboratoryTabEnum.Transferred:
                        if (LaboratoryService.SelectedTransferred is {Count: 1})
                            _samplePaperFormReportDisabledIndicator = false;
                        break;
                    case LaboratoryTabEnum.MyFavorites:
                        if (LaboratoryService.SelectedMyFavorites is {Count: 1})
                            _samplePaperFormReportDisabledIndicator = false;
                        break;
                    case LaboratoryTabEnum.Batches:
                        if (LaboratoryService.SelectedBatchTests is {Count: 1})
                            _samplePaperFormReportDisabledIndicator = false;
                        break;
                }

                return _samplePaperFormReportDisabledIndicator;
            }
        }

        private bool _accessionInPaperFormReportDisabledIndicator;

        public bool AccessionInPaperFormReportDisabledIndicator
        {
            get
            {
                _accessionInPaperFormReportDisabledIndicator = true;

                switch (Tab)
                {
                    case LaboratoryTabEnum.Samples:
                        if (LaboratoryService.SelectedSamples is {Count: > 0} &&
                            LaboratoryService.SelectedSamples.Count(x => x.AccessionIndicator == 1) ==
                            LaboratoryService.SelectedSamples.Count)
                            _accessionInPaperFormReportDisabledIndicator = false;
                        break;
                    case LaboratoryTabEnum.Testing:
                        if (LaboratoryService.SelectedTesting is {Count: > 0})
                            _accessionInPaperFormReportDisabledIndicator = false;
                        break;
                    case LaboratoryTabEnum.Transferred:
                        if (LaboratoryService.SelectedTransferred is {Count: > 0} &&
                            LaboratoryService.SelectedTransferred.Count(x => x.AccessionIndicator == 1) ==
                            LaboratoryService.SelectedTransferred.Count)
                            _accessionInPaperFormReportDisabledIndicator = false;
                        break;
                    case LaboratoryTabEnum.MyFavorites:
                        if (LaboratoryService.SelectedMyFavorites is {Count: > 0} &&
                            LaboratoryService.SelectedMyFavorites.Count(x => x.AccessionIndicator == 1) ==
                            LaboratoryService.SelectedMyFavorites.Count)
                            _accessionInPaperFormReportDisabledIndicator = false;
                        break;
                    case LaboratoryTabEnum.Batches:
                        if (LaboratoryService.SelectedBatches is {Count: > 0})
                            _accessionInPaperFormReportDisabledIndicator = false;
                        break;
                }

                return _accessionInPaperFormReportDisabledIndicator;
            }
        }

        private bool _testResultPaperFormReportDisabledIndicator;

        public bool TestResultPaperFormReportDisabledIndicator
        {
            get
            {
                _testResultPaperFormReportDisabledIndicator = true;

                switch (Tab)
                {
                    case LaboratoryTabEnum.Samples:
                        if (LaboratoryService.SelectedSamples is {Count: 1})
                            if (LaboratoryService.SelectedSamples.All(x =>
                                    x.TestAssignedCount > 0 || x.TestCompletedIndicator))
                                _testResultPaperFormReportDisabledIndicator = false;
                        break;
                    case LaboratoryTabEnum.Testing:
                        if (LaboratoryService.SelectedTesting is {Count: 1})
                            _testResultPaperFormReportDisabledIndicator = false;
                        break;
                    case LaboratoryTabEnum.Transferred:
                        if (LaboratoryService.SelectedTransferred is {Count: 1})
                            if (LaboratoryService.SelectedTransferred.All(x => x.TestAssignedIndicator == 1))
                                _testResultPaperFormReportDisabledIndicator = false;
                        break;
                    case LaboratoryTabEnum.MyFavorites:
                        if (LaboratoryService.SelectedMyFavorites is {Count: 1})
                            if (LaboratoryService.SelectedMyFavorites.All(x =>
                                    x.TestAssignedIndicator || x.TestCompletedIndicator))
                                _testResultPaperFormReportDisabledIndicator = false;
                        break;
                    case LaboratoryTabEnum.Batches:
                        if (LaboratoryService.SelectedBatchTests is {Count: 1})
                            _testResultPaperFormReportDisabledIndicator = false;
                        break;
                }

                return _testResultPaperFormReportDisabledIndicator;
            }
        }

        private bool _transferPaperFormReportDisabledIndicator;

        public bool TransferPaperFormReportDisabledIndicator
        {
            get
            {
                _transferPaperFormReportDisabledIndicator = true;

                switch (Tab)
                {
                    case LaboratoryTabEnum.Samples:
                        if (LaboratoryService.SelectedSamples is {Count: 1} &&
                            LaboratoryService.SelectedSamples.Count(x => x.TransferredCount > 0) ==
                            LaboratoryService.SelectedSamples.Count)
                            _transferPaperFormReportDisabledIndicator = false;
                        break;
                    case LaboratoryTabEnum.Testing:
                        if (LaboratoryService.SelectedTesting is {Count: 1} &&
                            LaboratoryService.SelectedTesting.Count(x => x.TransferredCount > 0) ==
                            LaboratoryService.SelectedTesting.Count)
                            _transferPaperFormReportDisabledIndicator = false;
                        break;
                    case LaboratoryTabEnum.Transferred:
                        if (LaboratoryService.SelectedTransferred is {Count: 1})
                            _transferPaperFormReportDisabledIndicator = false;
                        break;
                    case LaboratoryTabEnum.MyFavorites:
                        if (LaboratoryService.SelectedMyFavorites is {Count: 1} &&
                            LaboratoryService.SelectedMyFavorites.Count(x => x.TransferID != null) ==
                            LaboratoryService.SelectedMyFavorites.Count)
                            _transferPaperFormReportDisabledIndicator = false;
                        break;
                    case LaboratoryTabEnum.Batches:
                        if (LaboratoryService.SelectedBatchTests is {Count: 1} &&
                            LaboratoryService.SelectedBatchTests.Count(x => x.TransferredCount > 0) ==
                            LaboratoryService.SelectedBatchTests.Count)
                            _transferPaperFormReportDisabledIndicator = false;
                        break;
                }

                return _transferPaperFormReportDisabledIndicator;
            }
        }

        private bool _sampleDestructionPaperFormReportDisabledIndicator;

        public bool SampleDestructionPaperFormReportDisabledIndicator
        {
            get
            {
                _sampleDestructionPaperFormReportDisabledIndicator = true;

                switch (Tab)
                {
                    case LaboratoryTabEnum.Samples:
                        if (LaboratoryService.SelectedSamples is {Count: 1} &&
                            LaboratoryService.SelectedSamples.Count(x =>
                                x.SampleStatusTypeID == (long) SampleStatusTypeEnum.Destroyed) ==
                            LaboratoryService.SelectedSamples.Count)
                            _sampleDestructionPaperFormReportDisabledIndicator = false;
                        break;
                    case LaboratoryTabEnum.Testing:
                        if (LaboratoryService.SelectedTesting is {Count: 1} &&
                            LaboratoryService.SelectedTesting.Count(x =>
                                x.SampleStatusTypeID == (long) SampleStatusTypeEnum.Destroyed) ==
                            LaboratoryService.SelectedTesting.Count)
                            _sampleDestructionPaperFormReportDisabledIndicator = false;
                        break;
                    case LaboratoryTabEnum.Transferred:
                        if (LaboratoryService.SelectedTransferred is {Count: 1} &&
                            LaboratoryService.SelectedTransferred.Count(x =>
                                x.SampleStatusTypeID == (long) SampleStatusTypeEnum.Destroyed) ==
                            LaboratoryService.SelectedTransferred.Count)
                            _sampleDestructionPaperFormReportDisabledIndicator = false;
                        break;
                    case LaboratoryTabEnum.MyFavorites:
                        if (LaboratoryService.SelectedMyFavorites is {Count: 1} &&
                            LaboratoryService.SelectedMyFavorites.Count(x =>
                                x.SampleStatusTypeID == (long) SampleStatusTypeEnum.Destroyed) ==
                            LaboratoryService.SelectedMyFavorites.Count)
                            _sampleDestructionPaperFormReportDisabledIndicator = false;
                        break;
                    case LaboratoryTabEnum.Batches:
                        if (LaboratoryService.SelectedBatchTests is {Count: 1} &&
                            LaboratoryService.SelectedBatchTests.Count(x =>
                                x.SampleStatusTypeID == (long) SampleStatusTypeEnum.Destroyed) ==
                            LaboratoryService.SelectedBatchTests.Count)
                            _sampleDestructionPaperFormReportDisabledIndicator = false;
                        break;
                }

                return _sampleDestructionPaperFormReportDisabledIndicator;
            }
        }

        private bool _printBarcodesDisabledIndicator;

        public bool PrintBarcodesDisabledIndicator
        {
            get
            {
                _printBarcodesDisabledIndicator = true;

                switch (Tab)
                {
                    case LaboratoryTabEnum.Samples:
                        if (LaboratoryService.SelectedSamples is {Count: > 0} &&
                            LaboratoryService.SelectedSamples.Count(x =>
                                !IsNullOrEmpty(x.EIDSSLocalOrFieldSampleID) ||
                                !IsNullOrEmpty(x.EIDSSLaboratorySampleID)) ==
                            LaboratoryService.SelectedSamples.Count)
                            _printBarcodesDisabledIndicator = false;
                        break;
                    case LaboratoryTabEnum.Testing:
                        if (LaboratoryService.SelectedTesting is {Count: > 0} &&
                            LaboratoryService.SelectedTesting.Count(x =>
                                !IsNullOrEmpty(x.EIDSSLocalOrFieldSampleID) ||
                                !IsNullOrEmpty(x.EIDSSLaboratorySampleID)) ==
                            LaboratoryService.SelectedTesting.Count)
                            _printBarcodesDisabledIndicator = false;
                        break;
                    case LaboratoryTabEnum.Transferred:
                        if (LaboratoryService.SelectedTransferred is {Count: > 0} &&
                            LaboratoryService.SelectedTransferred.Count(x =>
                                !IsNullOrEmpty(x.EIDSSLocalOrFieldSampleID) ||
                                !IsNullOrEmpty(x.EIDSSLaboratorySampleID)) ==
                            LaboratoryService.SelectedTransferred.Count)
                            _printBarcodesDisabledIndicator = false;
                        break;
                    case LaboratoryTabEnum.MyFavorites:
                        if (LaboratoryService.SelectedMyFavorites is {Count: > 0} &&
                            LaboratoryService.SelectedMyFavorites.Count(x =>
                                !IsNullOrEmpty(x.EIDSSLocalOrFieldSampleID) ||
                                !IsNullOrEmpty(x.EIDSSLaboratorySampleID)) ==
                            LaboratoryService.SelectedMyFavorites.Count)
                            _printBarcodesDisabledIndicator = false;
                        break;
                    case LaboratoryTabEnum.Batches:
                        if (LaboratoryService.SelectedBatchTests is {Count: > 0} &&
                            LaboratoryService.SelectedBatchTests.Count(x =>
                                !IsNullOrEmpty(x.EIDSSLocalOrFieldSampleID) ||
                                !IsNullOrEmpty(x.EIDSSLaboratorySampleID)) ==
                            LaboratoryService.SelectedBatchTests.Count)
                            _printBarcodesDisabledIndicator = false;
                        break;
                }

                return _printBarcodesDisabledIndicator;
            }
        }

        #endregion

        #region Constants

        #endregion

        #region Member Variables

        private readonly CancellationToken _token;
        private UserPermissions _userPermissions;

        #endregion

        #endregion

        #region Constructors

        /// <summary>
        /// </summary>
        /// <param name="token"></param>
        public MenuBase(CancellationToken token) : base(token)
        {
            _token = token;
        }

        /// <summary>
        /// </summary>
        protected MenuBase() : base(CancellationToken.None)
        {
        }

        #endregion

        #region Methods

        #region Lifecycle Events

        /// <summary>
        /// </summary>
        protected override void OnInitialized()
        {
            base.OnInitialized();

            _logger = Logger;

            authenticatedUser = _tokenService.GetAuthenticatedUser();
        }

        /// <summary>
        /// </summary>
        public void Dispose()
        {
        }

        #endregion

        #region Accession In Events

        /// <summary>
        /// </summary>
        /// <returns></returns>
        public async Task OnAccessionInClick()
        {
            try
            {
                await JsRuntime.InvokeAsync<string>("closeMenu", _token).ConfigureAwait(false);

                IList<LaboratorySelectionViewModel> records = new List<LaboratorySelectionViewModel>();
                var sampleIDs = new List<SampleIDsGetListViewModel>();

                switch (Tab)
                {
                    case LaboratoryTabEnum.Samples:
                        foreach (var sample in LaboratoryService.SelectedSamples)
                            records.Add(new LaboratorySelectionViewModel { SampleID = sample.SampleID });

                        sampleIDs = await AccessionIn(records, (long)AccessionConditionTypeEnum.AcceptedInGoodCondition,
                            LaboratoryService.AccessionConditionTypes.First(x =>
                                x.IdfsBaseReference == (long)AccessionConditionTypeEnum.AcceptedInGoodCondition).Name);
                        break;
                    case LaboratoryTabEnum.MyFavorites:
                        foreach (var myFavorite in LaboratoryService.SelectedMyFavorites)
                            records.Add(new LaboratorySelectionViewModel { SampleID = myFavorite.SampleID });

                        sampleIDs = await AccessionIn(records, (long)AccessionConditionTypeEnum.AcceptedInGoodCondition,
                            LaboratoryService.AccessionConditionTypes.First(x =>
                                x.IdfsBaseReference == (long)AccessionConditionTypeEnum.AcceptedInGoodCondition).Name);
                        break;
                }

                await InvokeAsync(() => { AccessionInEvent.InvokeAsync(); });

                // Display a prompt to the user asking them whether or not to display the print barcode dialog.
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

                var dialogParams = new Dictionary<string, object>
                {
                    {nameof(EIDSSDialog.DialogButtons), buttons},
                    {
                        nameof(EIDSSDialog.Message),
                        Localizer.GetString(MessageResourceKeyConstants.DoYouWantToPrintBarcodesMessage)
                    }
                };
                var result = await DiagService.OpenAsync<EIDSSDialog>(
                    Localizer.GetString(HeadingResourceKeyConstants.EIDSSModalHeading), dialogParams);

                if (result is DialogReturnResult returnResult && returnResult.ButtonResultText ==
                    Localizer.GetString(ButtonResourceKeyConstants.YesButton))
                {
                    LaboratoryService.PrintBarcodeSamples = sampleIDs.Aggregate(Empty,
                        (current, s) => current + (s.EIDSSLaboratorySampleID + ','));

                    if (LaboratoryService.PrintBarcodeSamples != null)
                        LaboratoryService.PrintBarcodeSamples =
                            LaboratoryService.PrintBarcodeSamples.Remove(
                                LaboratoryService.PrintBarcodeSamples.Length - 1, 1);
                }
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
        public async Task OnGroupAccessionInClick()
        {
            try
            {
                await JsRuntime.InvokeAsync<string>("closeMenu", _token).ConfigureAwait(false);

                var result = await DiagService.OpenAsync<GroupAccessionIn>(
                    Localizer.GetString(HeadingResourceKeyConstants.LaboratoryGroupAccessionInModalHeading),
                    new Dictionary<string, object> { { "Tab", Tab } },
                    new DialogOptions
                    {
                        Width = LaboratoryModuleCSSClassConstants.DefaultDialogWidth,
                        Height = LaboratoryModuleCSSClassConstants.DefaultDialogHeight,
                        Resizable = true,
                        Draggable = false
                    });

                if (result == null)
                    return;

                if (result is DialogReturnResult)
                {
                    await InvokeAsync(() => { AccessionInEvent.InvokeAsync(); });

                    DiagService.Close(result);
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion

        #region Assign Test Event

        /// <summary>
        /// </summary>
        /// <returns></returns>
        public async Task OnAssignTestClick()
        {
            try
            {
                await JsRuntime.InvokeAsync<string>("closeMenu", _token).ConfigureAwait(false);

                var result = await DiagService.OpenAsync<AssignTest>(
                    Localizer.GetString(HeadingResourceKeyConstants.LaboratoryAssignTestModalHeading),
                    new Dictionary<string, object> { { "Tab", Tab } },
                    new DialogOptions
                    {
                        Style = LaboratoryModuleCSSClassConstants.AssignTestDialog,
                        Resizable = true,
                        Draggable = false
                    });

                if (result == null)
                    return;

                if (result is DialogReturnResult)
                {
                    await InvokeAsync(() => { AssignTestEvent.InvokeAsync(); });

                    DiagService.Close(result);
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion

        #region Create Aliquot/Derivative Events

        /// <summary>
        /// </summary>
        /// <returns></returns>
        public async Task OnCreateAliquotClick()
        {
            try
            {
                await JsRuntime.InvokeAsync<string>("closeMenu", _token).ConfigureAwait(false);

                var result = await DiagService.OpenAsync<CreateAliquotDerivative>(
                    Localizer.GetString(HeadingResourceKeyConstants.LaboratoryAliquotsDerivativesModalHeading),
                    new Dictionary<string, object> { { "Tab", Tab }, { "FormationType", SampleDivisionTypeEnum.Aliquot } },
                    new DialogOptions
                    {
                        Style = LaboratoryModuleCSSClassConstants.CreateAliquotDerivativeDialog,
                        Resizable = true,
                        Draggable = false
                    });

                if (result == null)
                    return;

                if (result == 0)
                    await InvokeAsync(() => { CreateAliquotEvent.InvokeAsync(); });
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
        public async Task OnCreateDerivativeClick()
        {
            try
            {
                await JsRuntime.InvokeAsync<string>("closeMenu", _token).ConfigureAwait(false);

                var result = await DiagService.OpenAsync<CreateAliquotDerivative>(
                    Localizer.GetString(HeadingResourceKeyConstants.LaboratoryAliquotsDerivativesModalHeading),
                    new Dictionary<string, object> { { "Tab", Tab }, { "FormationType", SampleDivisionTypeEnum.Derivative } },
                    new DialogOptions
                    {
                        Style = LaboratoryModuleCSSClassConstants.CreateAliquotDerivativeDialog,
                        Resizable = true,
                        Draggable = false
                    });

                if (result == null)
                    return;

                if (result == 0)
                    await InvokeAsync(() => { CreateDerivativeEvent.InvokeAsync(); });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion

        #region Transfer Out Event

        /// <summary>
        /// </summary>
        /// <returns></returns>
        public async Task OnTransferOutClick()
        {
            try
            {
                await JsRuntime.InvokeAsync<string>("closeMenu", _token).ConfigureAwait(false);

                var result = await DiagService.OpenAsync<TransferOut>(
                    Localizer.GetString(HeadingResourceKeyConstants.LaboratoryTransferSampleModalHeading),
                    new Dictionary<string, object> { { "Tab", Tab } },
                    new DialogOptions
                    {
                        Style = LaboratoryModuleCSSClassConstants.TransferOutDialog,
                        Resizable = true,
                        Draggable = false
                    });

                if (result == null)
                    return;

                if (result is DialogReturnResult)
                {
                    await InvokeAsync(() => { TransferOutEvent.InvokeAsync(); });

                    DiagService.Close(result);
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion

        #region Register New Samples Event

        /// <summary>
        /// </summary>
        /// <returns></returns>
        public async Task OnRegisterNewSampleClick()
        {
            try
            {
                var result = await DiagService.OpenAsync<RegisterNewSample>(
                    Localizer.GetString(HeadingResourceKeyConstants.RegisterNewSampleModalHeading),
                    new Dictionary<string, object> { { "Tab", Tab } },
                    new DialogOptions
                    {
                        Style = LaboratoryModuleCSSClassConstants.RegisterNewSampleDialog, Resizable = true, Draggable = false
                    });

                if (result == null)
                    return;

                if (result is DialogReturnResult)
                {
                    await RegisterNewSampleEvent.InvokeAsync();

                    DiagService.Close(result);
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion

        #region Test Result Events

        /// <summary>
        /// </summary>
        /// <returns></returns>
        public async Task OnSetTestResultClick()
        {
            try
            {
                await JsRuntime.InvokeAsync<string>("closeMenu", _token).ConfigureAwait(false);

                dynamic test = null;
                switch (Tab)
                {
                    case LaboratoryTabEnum.Testing:
                        test = LaboratoryService.SelectedTesting.First();
                        break;
                    case LaboratoryTabEnum.MyFavorites:
                        var testId = LaboratoryService.SelectedMyFavorites.First().TestID;
                        if (testId != null)
                            test = LaboratoryService.Testing is not null && LaboratoryService.Testing.Any(x =>
                                x.TestID == (long) testId)
                                ? LaboratoryService.Testing.First(x =>
                                    x.TestID == (long) testId)
                                : await GetTest((long) testId);
                        break;
                }

                if (test != null)
                {
                    var result = await DiagService.OpenAsync<LaboratoryDetails>(
                        Localizer.GetString(HeadingResourceKeyConstants.LaboratorySampleTestDetailsModalHeading),
                        new Dictionary<string, object> { { "Tab", Tab }, { "SampleID", test.SampleID }, { "TestID", test.TestID } },
                        new DialogOptions
                        {
                            Style = LaboratoryModuleCSSClassConstants.LaboratoryRecordDetailsDialog,
                            AutoFocusFirstElement = true,
                            CloseDialogOnOverlayClick = false,
                            Draggable = false,
                            Resizable = true
                        });

                    if (result == null)
                        return;

                    if (result is DialogReturnResult)
                    {
                        await InvokeAsync(() => { SetTestResultEvent.InvokeAsync(); });

                        DiagService.Close(result);
                    }
                }
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
        public async Task OnValidateTestResultClick()
        {
            try
            {
                await JsRuntime.InvokeAsync<string>("closeMenu", _token).ConfigureAwait(false);

                await Approve(Tab);

                await InvokeAsync(() => { ValidateTestResultEvent.InvokeAsync(); });
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
        public async Task OnAmendTestResultClick()
        {
            try
            {
                await JsRuntime.InvokeAsync<string>("closeMenu", _token).ConfigureAwait(false);

                dynamic result = null;

                switch (Tab)
                {
                    case LaboratoryTabEnum.Testing:
                        result = await DiagService.OpenAsync<AmendTestResult>(
                            Localizer.GetString(HeadingResourceKeyConstants.LaboratoryAmendTestResultModalHeading),
                            new Dictionary<string, object> { { "Tab", Tab }, { "Test", LaboratoryService.SelectedTesting.FirstOrDefault() } },
                            new DialogOptions
                            {
                                Style = LaboratoryModuleCSSClassConstants.AmendTestResultDialog, Resizable = true, Draggable = false
                            });
                        break;
                    case LaboratoryTabEnum.MyFavorites:
                        if (LaboratoryService.SelectedMyFavorites is not null &&
                            LaboratoryService.SelectedMyFavorites.Any())
                        {
                            var testId = LaboratoryService.SelectedMyFavorites.First().TestID;
                            if (testId != null)
                            {
                                var test = await GetTest((long) testId);
                                result = await DiagService.OpenAsync<AmendTestResult>(
                                    Localizer.GetString(HeadingResourceKeyConstants
                                        .LaboratoryAmendTestResultModalHeading),
                                    new Dictionary<string, object> {{"Tab", Tab}, {"Test", test}},
                                    new DialogOptions
                                    {
                                        Style = LaboratoryModuleCSSClassConstants.AmendTestResultDialog,
                                        Resizable = true, Draggable = false
                                    });
                            }
                        }
                        break;
                }

                if (result == null)
                    return;

                if (result is DialogReturnResult)
                {
                    await InvokeAsync(() => { AmendTestResultEvent.InvokeAsync(); });

                    DiagService.Close(result);
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion

        #region Sample Destruction Events

        /// <summary>
        /// </summary>
        /// <returns></returns>
        protected async Task OnDestroySampleByIncinerationClick()
        {
            try
            {
                await JsRuntime.InvokeAsync<string>("closeMenu", _token).ConfigureAwait(false);

                await InvokeAsync(() => { DestroySampleByIncinerationEvent.InvokeAsync(); });
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
        public async Task OnDestroySampleByAutoclaveClick()
        {
            try
            {
                await JsRuntime.InvokeAsync<string>("closeMenu", _token).ConfigureAwait(false);

                await InvokeAsync(() => { DestroySampleByAutoclaveEvent.InvokeAsync(); });
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
        public async Task OnApproveSampleDestructionClick()
        {
            try
            {
                await JsRuntime.InvokeAsync<string>("closeMenu", _token).ConfigureAwait(false);

                await Approve(Tab);

                await InvokeAsync(() => { ApproveSampleDestructionEvent.InvokeAsync(); });
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
        public async Task OnRejectSampleDestructionClick()
        {
            try
            {
                await JsRuntime.InvokeAsync<string>("closeMenu", _token).ConfigureAwait(false);

                await Reject(Tab);

                await InvokeAsync(() => { RejectSampleDestructionEvent.InvokeAsync(); });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion

        #region Record Deletion Events

        /// <summary>
        /// </summary>
        /// <returns></returns>
        public async Task OnDeleteSampleRecordClick()
        {
            try
            {
                await JsRuntime.InvokeAsync<string>("closeMenu", _token).ConfigureAwait(false);

                var result = await DiagService.OpenAsync<RecordDeletion>(
                    Localizer.GetString(HeadingResourceKeyConstants.LaboratoryLabRecordDeletionHeading),
                    new Dictionary<string, object> { { "Tab", Tab } },
                    new DialogOptions
                    {
                        Width = LaboratoryModuleCSSClassConstants.DefaultDialogWidth,
                        Height = LaboratoryModuleCSSClassConstants.DefaultDialogHeight,
                        Resizable = true,
                        Draggable = false
                    });

                if (result == null)
                    return;

                await InvokeAsync(() => { DeleteSampleRecordEvent.InvokeAsync(); });
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
        public async Task OnDeleteTestRecordClick()
        {
            try
            {
                await JsRuntime.InvokeAsync<string>("closeMenu", _token).ConfigureAwait(false);

                await InvokeAsync(() => { DeleteTestRecordEvent.InvokeAsync(); });
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
        public async Task OnApproveRecordDeletionClick()
        {
            try
            {
                await JsRuntime.InvokeAsync<string>("showApproveProcessingIndicator", _token).ConfigureAwait(false);
                await JsRuntime.InvokeAsync<string>("closeMenu", _token).ConfigureAwait(false);

                var response = Task.Run(() => Approve(Tab), _token);

                response.Wait(_token);

                await InvokeAsync(() => { ApproveRecordDeletionEvent.InvokeAsync(); });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
            finally
            {
                await JsRuntime.InvokeAsync<string>("hideApproveProcessingIndicator", _token).ConfigureAwait(false);
            }
        }

        /// <summary>
        /// </summary>
        /// <returns></returns>
        public async Task OnRejectRecordDeletionClick()
        {
            try
            {
                await JsRuntime.InvokeAsync<string>("showRejectProcessingIndicator", _token).ConfigureAwait(false);
                await JsRuntime.InvokeAsync<string>("closeMenu", _token).ConfigureAwait(false);

                await Reject(Tab);

                await InvokeAsync(() => { RejectRecordDeletionEvent.InvokeAsync(); });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
            finally
            {
                await JsRuntime.InvokeAsync<string>("hideRejectProcessingIndicator", _token).ConfigureAwait(false);
            }
        }

        /// <summary>
        /// </summary>
        /// <returns></returns>
        public async Task OnRestoreDeletedSampleRecordClick()
        {
            try
            {
                await JsRuntime.InvokeAsync<string>("closeMenu", _token).ConfigureAwait(false);

                RestoreDeletedSample();

                await InvokeAsync(() => { RestoreDeletedSampleRecordEvent.InvokeAsync(); });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion

        #region Paper Form Events

        /// <summary>
        /// </summary>
        /// <returns></returns>
        public async Task OnSamplePaperFormReportClick()
        {
            try
            {
                await JsRuntime.InvokeAsync<string>("closeMenu", _token).ConfigureAwait(false);

                ReportViewModel model = new();

                switch (Tab)
                {
                    case LaboratoryTabEnum.Samples:
                        model.AddParameter("ObjID", LaboratoryService.SelectedSamples.First().SampleID.ToString());
                        break;
                    case LaboratoryTabEnum.MyFavorites:
                        model.AddParameter("ObjID", LaboratoryService.SelectedMyFavorites.First().SampleID.ToString());
                        break;
                }

                model.AddParameter("LangID", GetCurrentLanguage());
                model.AddParameter("PersonID", Convert.ToString(authenticatedUser.PersonId));

                var result = await DiagService.OpenAsync<DisplayReport>(
                    Localizer.GetString(HeadingResourceKeyConstants.LaboratorySampleReportHeading),
                    new Dictionary<string, object> {{"ReportName", "Samples"}, {"Parameters", model.Parameters}},
                    new DialogOptions
                    {
                        Style = LaboratoryModuleCSSClassConstants.LaboratoryPaperFormsDialog, Resizable = true,
                        Draggable = false
                    });

                if (result == null)
                    return;

                await ShowSamplePaperFormReportEvent.InvokeAsync();
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
        public async Task OnHumanDiseaseReportOutbreakCaseAccessionInPaperFormReportClick()
        {
            try
            {
                await JsRuntime.InvokeAsync<string>("closeMenu", _token).ConfigureAwait(false);

                await DiagService.OpenAsync<DisplayReport>(
                    Localizer.GetString(HeadingResourceKeyConstants.LaboratoryAccessionInFormHeading),
                    new Dictionary<string, object> {{"ReportName", "HumanAccessionIn"}},
                    new DialogOptions
                    {
                        Style = LaboratoryModuleCSSClassConstants.LaboratoryPaperFormsDialog, Resizable = true,
                        Draggable = false
                    });
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
        public async Task OnHumanActiveSurveillanceSessionAccessionInPaperFormReportClick()
        {
            try
            {
                await JsRuntime.InvokeAsync<string>("closeMenu", _token).ConfigureAwait(false);

                await DiagService.OpenAsync<DisplayReport>(
                    Localizer.GetString(HeadingResourceKeyConstants.LaboratoryAccessionInFormHeading),
                    new Dictionary<string, object> {{"ReportName", "AccessionInHumanAsSession"}},
                    new DialogOptions
                    {
                        Style = LaboratoryModuleCSSClassConstants.LaboratoryPaperFormsDialog, Resizable = true,
                        Draggable = false
                    });
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
        public async Task OnVectorSurveillanceSessionAccessionInPaperFormReportClick()
        {
            try
            {
                await JsRuntime.InvokeAsync<string>("closeMenu", _token).ConfigureAwait(false);

                await DiagService.OpenAsync<DisplayReport>(
                    Localizer.GetString(HeadingResourceKeyConstants.LaboratoryAccessionInFormHeading),
                    new Dictionary<string, object> {{"ReportName", "AccessionInVectorAsSession"}},
                    new DialogOptions
                    {
                        Style = LaboratoryModuleCSSClassConstants.LaboratoryPaperFormsDialog, Resizable = true,
                        Draggable = false
                    });
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
        public async Task OnVeterinaryActiveSurveillanceSessionAccessionInPaperFormReportClick()
        {
            try
            {
                await JsRuntime.InvokeAsync<string>("closeMenu", _token).ConfigureAwait(false);

                await DiagService.OpenAsync<DisplayReport>(
                    Localizer.GetString(HeadingResourceKeyConstants.LaboratoryAccessionInFormHeading),
                    new Dictionary<string, object> {{"ReportName", "AccessionInVeterinaryAsSession"}},
                    new DialogOptions
                    {
                        Style = LaboratoryModuleCSSClassConstants.LaboratoryPaperFormsDialog, Resizable = true,
                        Draggable = false
                    });
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
        public async Task OnTestResultPaperFormReportClick()
        {
            try
            {
                await JsRuntime.InvokeAsync<string>("closeMenu", _token).ConfigureAwait(false);

                ReportViewModel model = new();

                switch (Tab)
                {
                    case LaboratoryTabEnum.Testing:
                        model.AddParameter("ObjID", LaboratoryService.SelectedTesting.First().TestID.ToString());
                        break;
                    case LaboratoryTabEnum.MyFavorites:
                        model.AddParameter("ObjID", LaboratoryService.SelectedMyFavorites.First().TestID.ToString());
                        break;
                }

                model.AddParameter("LangID", GetCurrentLanguage());
                model.AddParameter("PersonID", Convert.ToString(authenticatedUser.PersonId));

                var result = await DiagService.OpenAsync<DisplayReport>(
                    Localizer.GetString(HeadingResourceKeyConstants.LaboratoryTestResultReportHeading),
                    new Dictionary<string, object>
                        {{"ReportName", "LaboratoryTests"}, {"Parameters", model.Parameters}},
                    new DialogOptions
                    {
                        Style = LaboratoryModuleCSSClassConstants.LaboratoryPaperFormsDialog, Resizable = true,
                        Draggable = false
                    });

                if (result == null)
                    return;

                await ShowTestResultPaperFormReportEvent.InvokeAsync();
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
        public async Task OnTransferPaperFormReportClick()
        {
            try
            {
                await JsRuntime.InvokeAsync<string>("closeMenu", _token).ConfigureAwait(false);

                ReportViewModel model = new();

                switch (Tab)
                {
                    case LaboratoryTabEnum.Transferred:
                        model.AddParameter("ObjID",
                            LaboratoryService.SelectedTransferred.First().TransferID.ToString());
                        break;
                    case LaboratoryTabEnum.MyFavorites:
                        model.AddParameter("ObjID",
                            LaboratoryService.SelectedMyFavorites.First().TransferID.ToString());
                        break;
                }

                model.AddParameter("LangID", GetCurrentLanguage());
                model.AddParameter("PersonID", Convert.ToString(authenticatedUser.PersonId));

                var result = await DiagService.OpenAsync<DisplayReport>(
                    Localizer.GetString(HeadingResourceKeyConstants.LaboratoryTransferReportHeading),
                    new Dictionary<string, object>
                        {{"ReportName", "SamplesTransfer"}, {"Parameters", model.Parameters}},
                    new DialogOptions
                    {
                        Style = LaboratoryModuleCSSClassConstants.LaboratoryPaperFormsDialog, Resizable = true,
                        Draggable = false
                    });

                if (result == null)
                    return;

                await ShowTransferPaperFormReportEvent.InvokeAsync();
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
        public async Task OnDestructionPaperFormReportClick()
        {
            try
            {
                await JsRuntime.InvokeAsync<string>("closeMenu", _token).ConfigureAwait(false);

                ReportViewModel model = new();

                switch (Tab)
                {
                    case LaboratoryTabEnum.Samples:
                        model.AddParameter("ObjID", LaboratoryService.SelectedSamples.First().SampleID.ToString());
                        break;
                    case LaboratoryTabEnum.MyFavorites:
                        model.AddParameter("ObjID", LaboratoryService.SelectedMyFavorites.First().SampleID.ToString());
                        break;
                }

                model.AddParameter("LangID", GetCurrentLanguage());
                model.AddParameter("PersonID", Convert.ToString(authenticatedUser.PersonId));

                var result = await DiagService.OpenAsync<DisplayReport>(
                    Localizer.GetString(HeadingResourceKeyConstants.LaboratorySampleReportHeading),
                    new Dictionary<string, object>
                        {{"ReportName", "SamplesDisposition"}, {"Parameters", model.Parameters}},
                    new DialogOptions
                    {
                        Style = LaboratoryModuleCSSClassConstants.LaboratoryPaperFormsDialog, Resizable = true,
                        Draggable = false
                    });

                if (result == null)
                    return;

                await ShowSamplePaperFormReportEvent.InvokeAsync();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion

        #region Print Barcodes Event

        /// <summary>
        /// </summary>
        /// <returns></returns>
        public async Task OnPrintBarcodesClick()
        {
            try
            {
                await JsRuntime.InvokeAsync<string>("closeMenu", _token).ConfigureAwait(false);

                switch (Tab)
                {
                    case LaboratoryTabEnum.Samples:
                        LaboratoryService.PrintBarcodeSamples = LaboratoryService.SelectedSamples.Aggregate(Empty,
                            (current, s) => current + (s.EIDSSLaboratorySampleID + ','));

                        if (LaboratoryService.PrintBarcodeSamples != null)
                            LaboratoryService.PrintBarcodeSamples =
                                LaboratoryService.PrintBarcodeSamples.Remove(
                                    LaboratoryService.PrintBarcodeSamples.Length - 1, 1);
                        break;
                    case LaboratoryTabEnum.Testing:
                        LaboratoryService.PrintBarcodeSamples = LaboratoryService.SelectedTesting.Aggregate(Empty,
                            (current, s) => current + (s.EIDSSLaboratorySampleID + ','));

                        if (LaboratoryService.PrintBarcodeSamples != null)
                            LaboratoryService.PrintBarcodeSamples =
                                LaboratoryService.PrintBarcodeSamples.Remove(
                                    LaboratoryService.PrintBarcodeSamples.Length - 1, 1);
                        break;
                    case LaboratoryTabEnum.Transferred:
                        LaboratoryService.PrintBarcodeSamples = LaboratoryService.SelectedTransferred.Aggregate(Empty,
                            (current, s) => current + (s.EIDSSLaboratorySampleID + ','));

                        if (LaboratoryService.PrintBarcodeSamples != null)
                            LaboratoryService.PrintBarcodeSamples =
                                LaboratoryService.PrintBarcodeSamples.Remove(
                                    LaboratoryService.PrintBarcodeSamples.Length - 1, 1);
                        break;
                    case LaboratoryTabEnum.MyFavorites:
                        LaboratoryService.PrintBarcodeSamples = LaboratoryService.SelectedMyFavorites.Aggregate(Empty,
                            (current, s) => current + (s.EIDSSLaboratorySampleID + ','));

                        if (LaboratoryService.PrintBarcodeSamples != null)
                            LaboratoryService.PrintBarcodeSamples =
                                LaboratoryService.PrintBarcodeSamples.Remove(
                                    LaboratoryService.PrintBarcodeSamples.Length - 1, 1);
                        break;
                    case LaboratoryTabEnum.Batches:
                        LaboratoryService.PrintBarcodeSamples = LaboratoryService.SelectedBatchTests.Aggregate(Empty,
                            (current, s) => current + (s.EIDSSLaboratorySampleID + ','));

                        if (LaboratoryService.PrintBarcodeSamples != null)
                            LaboratoryService.PrintBarcodeSamples =
                                LaboratoryService.PrintBarcodeSamples.Remove(
                                    LaboratoryService.PrintBarcodeSamples.Length - 1, 1);
                        break;
                    case LaboratoryTabEnum.Approvals:
                        LaboratoryService.PrintBarcodeSamples = LaboratoryService.SelectedApprovals.Aggregate(Empty,
                            (current, s) => current + (s.EIDSSLaboratorySampleID + ','));

                        if (LaboratoryService.PrintBarcodeSamples != null)
                            LaboratoryService.PrintBarcodeSamples =
                                LaboratoryService.PrintBarcodeSamples.Remove(
                                    LaboratoryService.PrintBarcodeSamples.Length - 1, 1);
                        break;
                }

                if (!IsNullOrEmpty(LaboratoryService.PrintBarcodeSamples))
                    await GenerateBarcodeReport(LaboratoryService.PrintBarcodeSamples);

                LaboratoryService.PrintBarcodeSamples = null;
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