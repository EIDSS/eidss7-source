using EIDSS.Domain.Abstracts;
using EIDSS.Domain.Enumerations;
using System;
using System.ComponentModel.DataAnnotations;
using static System.String;

namespace EIDSS.Domain.ViewModels.Laboratory
{
    public class MyFavoritesGetListViewModel : BaseModel
    {
        public long SampleID { get; set; }
        public long SiteID { get; set; }
        public long? CurrentSiteID { get; set; }
        public long? TestID { get; set; }
        public long? TransferID { get; set; }
        [StringLength(36)]
        public string EIDSSReportOrSessionID { get; set; }
        public string PatientOrFarmOwnerName { get; set; }
        public string SampleTypeName { get; set; }
        public string DiseaseID { get; set; }
        public string DiseaseName { get; set; }
        public string DisplayDiseaseName { get; set; }
        public long? RootSampleID { get; set; }
        public long? ParentSampleID { get; set; }
        [StringLength(36)]
        public string EIDSSLaboratorySampleID { get; set; }
        [StringLength(36)]
        public string EIDSSLocalOrFieldSampleID { get; set; }
        public DateTime? CollectionDate { get; set; }
        public long? CollectedByPersonID { get; set; }
        public long? CollectedByOrganizationID { get; set; }
        public DateTime? SentDate { get; set; }
        public long? SentToOrganizationID { get; set; }
        public long? TestNameTypeID { get; set; }
        public string TestNameTypeName { get; set; }
        public long? TestStatusTypeID { get; set; }
        public string TestStatusTypeName { get; set; }
        public DateTime? StartedDate { get; set; }
        public long? TestResultTypeID { get; set; }
        public string TestResultTypeName { get; set; }
        public DateTime? ResultDate { get; set; }
        public long? ResultEnteredByPersonID { get; set; }
        public string ResultEnteredByPersonName { get; set; }
        public long? TestCategoryTypeID { get; set; }
        public string TestCategoryTypeName { get; set; }
        public DateTime? EnteredDate { get; set; }
        public DateTime? OutOfRepositoryDate { get; set; }
        public long? MarkedForDispositionByPersonID { get; set; }
        public bool ReadOnlyIndicator { get; set; }
        public int AccessionIndicator { get; set; }
        public DateTime? AccessionDate { get; set; }
        public long? FunctionalAreaID { get; set; }
        public string FunctionalAreaName { get; set; }
        public long? FreezerSubdivisionID { get; set; }
        [StringLength(36)]
        public string StorageBoxPlace { get; set; }

        private long? _accessionConditionTypeId;
        public long? AccessionConditionTypeID
        {
            get => _accessionConditionTypeId;
            set
            {
                _accessionConditionTypeId = value;

                if (_accessionConditionTypeId is null | _accessionConditionTypeId == (long)AccessionConditionTypeEnum.Rejected)
                {
                    AccessionDate = null;
                    AccessionedInByPersonID = null;
                    AccessionIndicator = 0;
                    CurrentSiteID = null;
                    EIDSSLaboratorySampleID = null;
                    FreezerSubdivisionID = null;
                    FunctionalAreaID = null;
                    FunctionalAreaName = null;
                    SampleStatusTypeID = null;
                }

                _displayAccessionConditionTypeSelectIndicator = null;
            }
        }

        /// <summary>
        /// The accession condition reference type has no value for un-accessioned, so use a non-nullable property
        /// for the UI portion so un-accessioned may be set as the default value of 0.
        /// </summary>
        private long _accessionConditionTypeSelect;
        public long AccessionConditionTypeSelect
        {
            get
            {
                _accessionConditionTypeSelect = 0;

                if (AccessionConditionTypeID != null)
                    _accessionConditionTypeSelect = (long)AccessionConditionTypeID;

                return _accessionConditionTypeSelect;
            }
            set
            {
                _accessionConditionTypeSelect = value;

                if (_accessionConditionTypeSelect == 0)
                    AccessionConditionTypeID = null;
                else
                    AccessionConditionTypeID = _accessionConditionTypeSelect;
            }
        }

        private long? _sampleStatusTypeId;
        public long? SampleStatusTypeID
        {
            get => _sampleStatusTypeId;
            set
            {
                _sampleStatusTypeId = value;

                if (_sampleStatusTypeId is not null)
                {
                    switch (SampleStatusTypeID)
                    {
                        case (long)SampleStatusTypeEnum.Deleted:
                            FunctionalAreaIDDisabledIndicator = true;
                            SampleStatusTypeSelectDisabledIndicator = true;
                            StorageLocationDisabledIndicator = true;
                            break;
                        case (long)SampleStatusTypeEnum.InRepository:
                            OutOfRepositoryDate = null;
                            FunctionalAreaIDDisabledIndicator = false;
                            break;
                        case (long)SampleStatusTypeEnum.Destroyed:
                            FunctionalAreaIDDisabledIndicator = true;
                            SampleStatusTypeSelectDisabledIndicator = true;
                            StorageLocationDisabledIndicator = true;
                            break;
                        case (long)SampleStatusTypeEnum.MarkedForDeletion:
                            FunctionalAreaIDDisabledIndicator = true;
                            SampleStatusTypeSelectDisabledIndicator = true;
                            StorageLocationDisabledIndicator = true;
                            break;
                        case (long)SampleStatusTypeEnum.MarkedForDestruction:
                            FunctionalAreaIDDisabledIndicator = true;
                            SampleStatusTypeSelectDisabledIndicator = true;
                            StorageLocationDisabledIndicator = true;
                            break;
                        case (long)SampleStatusTypeEnum.TransferredOut:
                            FreezerSubdivisionID = null;
                            SampleStatusTypeSelectDisabledIndicator = true;
                            StorageBoxPlace = null;
                            break;
                    }
                }
                else
                {
                    FunctionalAreaIDDisabledIndicator = true;
                    StorageLocationDisabledIndicator = true;
                }

                _displayAccessionConditionTypeSelectIndicator = null;
                _displaySampleStatusTypeSelectIndicator = null;
            }
        }

        public string AccessionConditionOrSampleStatusTypeName { get; set; }
        public long? AccessionedInByPersonID { get; set; }
        public DateTime? SampleStatusDate { get; set; }
        [StringLength(200)]
        public string AccessionComment { get; set; }
        [StringLength(500)]
        public string Comment { get; set; }
        public long? DestructionMethodTypeID { get; set; }
        public DateTime? DestructionDate { get; set; }
        public long? DestroyedByPersonID { get; set; }
        [StringLength(36)]
        public string EIDSSAnimalID { get; set; }
        public long? BirdStatusTypeID { get; set; }
        public long? MainTestID { get; set; }
        public long? SampleKindTypeID { get; set; }
        public long? BatchStatusTypeID { get; set; }
        public bool TestAssignedIndicator { get; set; }
        public long? ActionRequestedID { get; set; }
        public string ActionRequested { get; set; }
        public bool TestCompletedIndicator { get; set; }
        public long? PreviousSampleTypeID { get; set; }
        public long? PreviousTestStatusTypeID { get; set; }
        public bool LaboratoryModuleSourceIndicator { get; set; }
        public bool ReadPermissionIndicator { get; set; }
        public bool AccessToPersonalDataPermissionIndicator { get; set; }
        public bool AccessToGenderAndAgeDataPermissionIndicator { get; set; }
        public bool WritePermissionIndicator { get; set; }
        public bool DeletePermissionIndicator { get; set; }
        public int RowAction { get; set; }
        public bool RowSelectionIndicator { get; set; }
        public int FavoriteCount { get; set; }

        private bool _actionPerformedIndicator;
        public bool ActionPerformedIndicator
        {
            get => _actionPerformedIndicator;
            set
            {
                _actionPerformedIndicator = value;

                if (_actionPerformedIndicator)
                {
                    if (AccessionConditionTypeID == null)
                    {
                        if (RowAction == (int)RowActionTypeEnum.Accession)
                            RowAction = (int)RowActionTypeEnum.Update;
                        else if (SampleStatusTypeID == (long)SampleStatusTypeEnum.MarkedForDeletion)
                            RowAction = (int)RowActionTypeEnum.Update;
                        else
                            RowAction = (int)RowActionTypeEnum.Read;
                    }
                    else if (AccessionConditionTypeID == (int)AccessionConditionTypeEnum.Rejected)
                    {
                        if (SampleID > 0)
                        {
                            if (SampleKindTypeID == (long)SampleKindTypeEnum.TransferredIn)
                                // Set the transferred out sample status to transferred out, so it will show in the 
                                // transferring laboratories samples tab for accessioning in.
                                RowAction = (int)RowActionTypeEnum.RejectUpdateTransferOut;
                            else
                                RowAction = (int)RowActionTypeEnum.Update;
                        }
                        else
                            RowAction = (int)RowActionTypeEnum.Insert;
                    }
                    else
                    {
                        if (SampleID > 0)
                        {
                            if (SampleStatusTypeID is null)
                            {
                                RowAction = (int)RowActionTypeEnum.Accession;
                                SampleStatusTypeID = (long)SampleStatusTypeEnum.InRepository;
                            }
                            else
                            {
                                RowAction = SampleStatusTypeID switch
                                {
                                    (long) SampleStatusTypeEnum.InRepository => SampleKindTypeID switch
                                    {
                                        null => (int) RowActionTypeEnum.Update,
                                        // Set the transferred out sample status to transferred out, so it will show in the 
                                        // transferring laboratories samples tab for accessioning in.
                                        (long) SampleKindTypeEnum.TransferredIn => (int) RowActionTypeEnum
                                            .AccessionUpdateTransferOut,
                                        _ => (int) RowActionTypeEnum.Update
                                    },
                                    _ => (int) RowActionTypeEnum.Update
                                };
                            }
                        }
                        else
                        {
                            if (SampleKindTypeID is (long)SampleKindTypeEnum.Aliquot or (long)SampleKindTypeEnum.Derivative)
                                RowAction = (int)RowActionTypeEnum.InsertAliquotDerivative;
                            else
                                RowAction = (int)RowActionTypeEnum.InsertAccession;
                        }
                    }
                }
                else
                {
                    if (RowAction != (int) RowActionTypeEnum.NarrowSearchCriteria)
                        RowAction = (int) RowActionTypeEnum.Read;
                }
            }
        }
        public bool VeterinaryLaboratoryChiefIndicator { get; set; }
        public bool HumanLaboratoryChiefIndicator { get; set; }
        public bool AdministratorRoleIndicator { get; set; }
        public bool CanPerformSampleAccessionIn { get; set; }
        public bool AllowDatesInThePast { get; set; }

        private bool _accessionConditionTypeSelectDisabledIndicator;
        public bool AccessionConditionTypeSelectDisabledIndicator
        {
            get
            {
                _accessionConditionTypeSelectDisabledIndicator = true;

                if (CanPerformSampleAccessionIn)
                    _accessionConditionTypeSelectDisabledIndicator = false;

                return _accessionConditionTypeSelectDisabledIndicator;
            }
        }

        private bool? _displayAccessionConditionTypeSelectIndicator;
        public bool DisplayAccessionConditionTypeSelectIndicator
        {
            get
            {
                if (_displayAccessionConditionTypeSelectIndicator != null)
                    return (bool) _displayAccessionConditionTypeSelectIndicator;
                _displayAccessionConditionTypeSelectIndicator = false;

                switch (SampleStatusTypeID)
                {
                    case null:
                    case (long)SampleStatusTypeEnum.InRepository:
                        _displayAccessionConditionTypeSelectIndicator = true;
                        break;
                }

                return (bool)_displayAccessionConditionTypeSelectIndicator;
            }
        }
        public bool SampleStatusTypeSelectDisabledIndicator { get; set; }

        private bool? _displaySampleStatusTypeSelectIndicator;
        public bool DisplaySampleStatusTypeSelectIndicator
        {
            get
            {
                if (_displaySampleStatusTypeSelectIndicator != null)
                    return (bool) _displaySampleStatusTypeSelectIndicator;
                _displaySampleStatusTypeSelectIndicator = false;

                if (SampleStatusTypeID == null) return (bool) _displaySampleStatusTypeSelectIndicator;
                if (SampleStatusTypeID != (long)SampleStatusTypeEnum.InRepository)
                {
                    _displaySampleStatusTypeSelectIndicator = true;
                }

                return (bool)_displaySampleStatusTypeSelectIndicator;
            }
        }

        private string _accessionCommentClass;
        public string AccessionCommentClass
        {
            get
            {
                if (AccessionConditionTypeID is (long)AccessionConditionTypeEnum.AcceptedInPoorCondition or (long)AccessionConditionTypeEnum.Rejected)
                {
                    _accessionCommentClass = IsNullOrEmpty(AccessionComment) ? "comment-empty-required" : "comment-non-empty-required";
                }
                else
                {
                    _accessionCommentClass = IsNullOrEmpty(AccessionComment) ? "comment-empty" : "comment-non-empty";
                }

                return _accessionCommentClass;
            }
        }

        private bool _testCategoryTypeSelectDisabledIndicator;
        public bool TestCategoryTypeSelectDisabledIndicator
        {
            get
            {
                _testCategoryTypeSelectDisabledIndicator = true;

                if (ActionPerformedIndicator && TransferID is not null && TestID is not null)
                    _testCategoryTypeSelectDisabledIndicator = false;
                else if (TestID is not null && TestStatusTypeID != (long)TestStatusTypeEnum.Amended && TestStatusTypeID != (long)TestStatusTypeEnum.Final)
                    _testCategoryTypeSelectDisabledIndicator = false;

                return _testCategoryTypeSelectDisabledIndicator;
            }
            set
            {
                value = true;

                if (ActionPerformedIndicator && TransferID is not null && TestID is not null)
                    value = false;
                else if (TestID is not null && TestStatusTypeID != (long)TestStatusTypeEnum.Amended && TestStatusTypeID != (long)TestStatusTypeEnum.Final)
                    value = false;

                _testCategoryTypeSelectDisabledIndicator = value;
            }
        }

        private bool _testResultTypeSelectDisabledIndicator;
        public bool TestResultTypeSelectDisabledIndicator
        {
            get
            {
                _testResultTypeSelectDisabledIndicator = true;

                if (BatchStatusTypeID == null)
                {
                    if (ActionPerformedIndicator && TransferID is not null && TestID is not null)
                        _testResultTypeSelectDisabledIndicator = false;
                    else if (TestID is not null && TestStatusTypeID != (long)TestStatusTypeEnum.Amended && TestStatusTypeID != (long)TestStatusTypeEnum.Final)
                        _testResultTypeSelectDisabledIndicator = false;
                }
                else if (BatchStatusTypeID != (long)BatchTestStatusTypeEnum.Closed)
                    _testResultTypeSelectDisabledIndicator = false;

                return _testResultTypeSelectDisabledIndicator;
            }
            set
            {
                value = true;

                if (BatchStatusTypeID == null)
                {
                    if (ActionPerformedIndicator && TransferID is not null && TestID is not null)
                        value = false;
                    else if (TestID is not null && TestStatusTypeID != (long)TestStatusTypeEnum.Amended && TestStatusTypeID != (long)TestStatusTypeEnum.Final)
                        value = false;
                }
                else if (BatchStatusTypeID != (long)BatchTestStatusTypeEnum.Closed)
                    value = false;

                _testResultTypeSelectDisabledIndicator = value;
            }
        }

        private bool _testStatusTypeSelectDisabledIndicator;
        public bool TestStatusTypeSelectDisabledIndicator
        {
            get
            {
                _testStatusTypeSelectDisabledIndicator = true;

                if (TestID is not null && TestStatusTypeID == (long)TestStatusTypeEnum.InProgress || TestStatusTypeID == (long)TestStatusTypeEnum.Preliminary)
                    _testStatusTypeSelectDisabledIndicator = false;

                if (TestID is not null && TestStatusTypeID == (long) TestStatusTypeEnum.Final && ActionPerformedIndicator)
                    _testStatusTypeSelectDisabledIndicator = false;
                
                return _testStatusTypeSelectDisabledIndicator;
            }
            set
            {
                value = true;

                if (TestID is not null && TestStatusTypeID == (long)TestStatusTypeEnum.InProgress || TestStatusTypeID == (long)TestStatusTypeEnum.Preliminary)
                    value = false;

                _testStatusTypeSelectDisabledIndicator = value;
            }
        }

        private bool _testStatusTypeSelectVisibleIndicator;
        public bool TestStatusTypeSelectVisibleIndicator
        {
            get
            {
                _testStatusTypeSelectVisibleIndicator = true;

                if (TestID is not null && TestStatusTypeID == (long)TestStatusTypeEnum.Final)
                    _testStatusTypeSelectVisibleIndicator = false;

                return _testStatusTypeSelectVisibleIndicator;
            }
            set
            {
                value = true;

                if (TestID is not null && TestStatusTypeID == (long)TestStatusTypeEnum.Final)
                    value = false;

                _testStatusTypeSelectVisibleIndicator = value;
            }
        }

        private bool _testResultTypeRequiredVisibleIndicator;
        public bool TestResultTypeRequiredVisibleIndicator
        {
            get
            {
                _testResultTypeRequiredVisibleIndicator = true;

                if (TestID is not null && TestStatusTypeID is ((long)TestStatusTypeEnum.InProgress) or ((long)TestStatusTypeEnum.Deleted) or ((long)TestStatusTypeEnum.MarkedForDeletion))
                {
                    _testResultTypeRequiredVisibleIndicator = false;
                }

                return _testResultTypeRequiredVisibleIndicator;
            }
            set
            {
                value = true;

                if (TestID is not null && TestStatusTypeID is ((long)TestStatusTypeEnum.InProgress) or ((long)TestStatusTypeEnum.Deleted) or ((long)TestStatusTypeEnum.MarkedForDeletion))
                {
                    value = false;
                }

                _testResultTypeRequiredVisibleIndicator = value;
            }
        }

        public bool FunctionalAreaIDDisabledIndicator { get; set; }
        public bool StorageLocationDisabledIndicator { get; set; }
        public long? VectorID { get; set; }
        public long? MonitoringSessionID { get; set; }
        public long? VectorSessionID { get; set; }
        public long? HumanDiseaseReportID { get; set; }
        public long? VeterinaryDiseaseReportID { get; set; }
    }
}
