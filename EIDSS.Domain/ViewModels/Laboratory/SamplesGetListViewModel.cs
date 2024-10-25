#region Usings

using EIDSS.Domain.Abstracts;
using EIDSS.Domain.Enumerations;
using EIDSS.Domain.ViewModels.Laboratory.Freezers;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;

#endregion

namespace EIDSS.Domain.ViewModels.Laboratory
{
    [JsonObject(MemberSerialization.OptOut)]
    public class SamplesGetListViewModel : BaseModel
    {
        public SamplesGetListViewModel ShallowCopy()
        {
            return (SamplesGetListViewModel)MemberwiseClone();
        }

        public long SampleID { get; set; }
        /// <summary>
        /// System assigned smart identifier used on printing and scanning of barcodes.
        /// </summary>
        [StringLength(36)]
        public string EIDSSLaboratorySampleID { get; set; }
        public bool FavoriteIndicator { get; set; }
        /// <summary>
        /// The identifier of the original sample in the scenario where a sample is divided (aliquot/derivative) 
        /// to trace the lineage back to the first sample.  All samples have this identifier populated, and in 
        /// the scenario of a non-divided sample, this identifier will be the same as the sample ID.
        /// </summary>
        public long? RootSampleID { get; set; }
        /// <summary>
        /// The identifier of the parent sample for the child sample.  This identifier is populated when a 
        /// sample is divided or transferred out to another laboratory.
        /// </summary>
        public long? ParentSampleID { get; set; }
        public string ParentEIDSSLaboratorySampleID { get; set; }
        public long SampleTypeID { get; set; }
        public string SampleTypeName { get; set; }
        public long? HumanID { get; set; }
        public string PatientOrFarmOwnerName { get; set; }
        public string PatientSpeciesVectorInformation { get; set; }
        public long? SpeciesID { get; set; }
        public long? AnimalID { get; set; }
        [StringLength(36)]
        public string EIDSSAnimalID { get; set; }
        public long? VectorID { get; set; }
        public long? MonitoringSessionID { get; set; }
        public long? VectorSessionID { get; set; }
        public long? HumanDiseaseReportID { get; set; }
        public long? VeterinaryDiseaseReportID { get; set; }
        /// <summary>
        /// System assigned smart identifier of a disease report or monitoring session used on printing and scanning of barcodes.
        /// </summary>
        [StringLength(36)]
        public string EIDSSReportOrSessionID { get; set; }
        public string ReportOrSessionTypeName { get; set; }
        public bool TestCompletedIndicator { get; set; }
        public string DiseaseID { get; set; }
        public string DiseaseName { get; set; }
        public string DisplayDiseaseName { get; set; }
        public long? FunctionalAreaID { get; set; }
        public string FunctionalAreaName { get; set; }
        public long? FreezerSubdivisionID { get; set; }
        public long? OldFreezerSubdivisionID { get; set; }
        [StringLength(36)]
        public string StorageBoxPlace { get; set; }
        public string OldStorageBoxPlace { get; set; }
        //public long OldStorageSubdivisionID { get; set; }
        public FreezerSubdivisionViewModel OldStorageSubdivision { get; set; }
        public string StorageBoxLocation { get; set; }
        public DateTime? CollectionDate { get; set; }
        public long? CollectedByPersonID { get; set; }
        public string CollectedByPersonName { get; set; }
        public long? CollectedByOrganizationID { get; set; }
        public string CollectedByOrganizationName { get; set; }
        public DateTime? SentDate { get; set; }
        public long? SentToOrganizationID { get; set; }
        public string SentToOrganizationName { get; set; }
        public long SiteID { get; set; }
        [StringLength(36)]
        public string EIDSSLocalOrFieldSampleID { get; set; }
        public DateTime? EnteredDate { get; set; }
        public DateTime? OutOfRepositoryDate { get; set; }
        public long? MarkedForDispositionByPersonID { get; set; }
        public bool ReadOnlyIndicator { get; set; }
        public int AccessionIndicator { get; set; }
        public DateTime? AccessionDate { get; set; }

        private long? _accessionConditionTypeId;
        public long? AccessionConditionTypeID
        {
            get => _accessionConditionTypeId;
            set
            {
                _accessionConditionTypeId = value;

                if (_accessionConditionTypeId is null | _accessionConditionTypeId == (long)AccessionConditionTypeEnum.Rejected)
                {
                    AccessionByPersonID = null;
                    AccessionIndicator = 0;
                    CurrentSiteID = null;
                    EIDSSLaboratorySampleID = null;
                    FreezerSubdivisionID = null;
                    FunctionalAreaID = null;
                    FunctionalAreaName = null;
                    SampleStatusTypeID = null;

                    if (_accessionConditionTypeId is null)
                        ReadOnlyIndicator = false;
                }
                else
                    AccessionIndicator = 1;

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

        public string AccessionConditionOrSampleStatusTypeName { get; set; }
        public long? AccessionByPersonID { get; set; }

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
        public DateTime? SampleStatusDate { get; set; }
        [StringLength(200)]
        public string AccessionComment { get; set; }
        public long? DestructionMethodTypeID { get; set; }
        public string DestructionMethodTypeName { get; set; }
        public DateTime? DestructionDate { get; set; }
        public long? DestroyedByPersonID { get; set; }
        public int TestAssignedCount { get; set; }
        public int TransferredCount { get; set; }
        [StringLength(500)]
        public string Comment { get; set; }
        public long? CurrentSiteID { get; set; }
        public long? BirdStatusTypeID { get; set; }
        public long? MainTestID { get; set; }
        public long? SampleKindTypeID { get; set; }
        public long? PreviousSampleTypeID { get; set; }
        public long? PreviousSampleStatusTypeID { get; set; }

        private bool _laboratoryModuleSourceIndicator;
        public bool LaboratoryModuleSourceIndicator 
        {
            get => _laboratoryModuleSourceIndicator;
            set
            {
                _laboratoryModuleSourceIndicator = value;

                EIDSSLocalOrFieldSampleIDDisabledIndicator = !_laboratoryModuleSourceIndicator;
            }
        }

        public int RowStatus { get; set; }
        public bool ReadPermissionIndicator { get; set; }
        public bool AccessToPersonalDataPermissionIndicator { get; set; }
        public bool AccessToGenderAndAgeDataPermissionIndicator { get; set; }
        public bool WritePermissionIndicator { get; set; }
        public bool DeletePermissionIndicator { get; set; }
        public int RowAction { get; set; }
        public int UnaccessionedSampleCount { get; set; }
        public long? HumanMasterID { get; set; }
        public long? SpeciesTypeID { get; set; }
        public long? VectorTypeID { get; set; }

        private bool _actionPerformedIndicator;
        public bool ActionPerformedIndicator
        {
            get => _actionPerformedIndicator;
            set
            {
                _actionPerformedIndicator = value;

                if (_actionPerformedIndicator)
                {
                    switch (AccessionConditionTypeID)
                    {
                        case null when RowAction == (int)RowActionTypeEnum.Accession:
                        case null when SampleStatusTypeID == (long)SampleStatusTypeEnum.MarkedForDeletion:
                            RowAction = (int)RowActionTypeEnum.Update;
                            break;
                        case null:
                            RowAction = (int)RowActionTypeEnum.Read;
                            break;
                        case (int)AccessionConditionTypeEnum.Rejected when SampleID > 0:
                        {
                            if (SampleKindTypeID == (long)SampleKindTypeEnum.TransferredIn)
                                // Set the transferred out sample status to transferred out, so it will show in the 
                                // transferring laboratories samples tab for accessioning in.
                                RowAction = (int)RowActionTypeEnum.RejectUpdateTransferOut;
                            else
                                RowAction = (int)RowActionTypeEnum.Update;
                            break;
                        }
                        case (int)AccessionConditionTypeEnum.Rejected:
                            RowAction = (int)RowActionTypeEnum.Insert;
                            break;
                        default:
                        {
                            if (SampleID > 0)
                            {
                                switch (SampleStatusTypeID)
                                {
                                    case null:
                                        RowAction = (int)RowActionTypeEnum.Accession;
                                        SampleStatusTypeID = (long)SampleStatusTypeEnum.InRepository;
                                        break;
                                    case (long) SampleStatusTypeEnum.Destroyed:
                                        RowAction = (int) RowActionTypeEnum.SampleDestruction;
                                        break;
                                    default:
                                    {
                                        if (SampleStatusTypeID != (long)SampleStatusTypeEnum.InRepository)
                                        {
                                            RowAction = (int)RowActionTypeEnum.Update;
                                        }
                                        else if (SampleKindTypeID is not null)
                                        {
                                            if (SampleKindTypeID == (long)SampleKindTypeEnum.TransferredIn)
                                                // Set the transferred out sample status to transferred out, so it will show in the 
                                                // transferring laboratories samples tab for accessioning in.
                                                RowAction = (int)RowActionTypeEnum.AccessionUpdateTransferOut;
                                            else if (RowAction != (int)RowActionTypeEnum.InsertAliquotDerivative)
                                                RowAction = (int)RowActionTypeEnum.Update;
                                        }
                                        else if (RowAction == (int)RowActionTypeEnum.Read)
                                            RowAction = (int)RowActionTypeEnum.Update;

                                        break;
                                    }
                                }
                            }
                            else
                            {
                                if (SampleKindTypeID is (long)SampleKindTypeEnum.Aliquot or (long)SampleKindTypeEnum.Derivative)
                                    RowAction = (int)RowActionTypeEnum.InsertAliquotDerivative;
                                else
                                    RowAction = (int)RowActionTypeEnum.InsertAccession;
                            }

                            break;
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
        public bool CanModifyStatusOfRejectedDeletedSample { get; set; }
        public bool AllowDatesInThePast { get; set; }

        private bool _accessionConditionTypeSelectDisabledIndicator;
        public bool AccessionConditionTypeSelectDisabledIndicator
        {
            get
            {
                _accessionConditionTypeSelectDisabledIndicator = true;

                if (!CanPerformSampleAccessionIn) return _accessionConditionTypeSelectDisabledIndicator;
                if (AccessionConditionTypeID is (long)AccessionConditionTypeEnum.Rejected)
                {
                    if (AccessionConditionTypeID == (long)AccessionConditionTypeEnum.Rejected && CanModifyStatusOfRejectedDeletedSample)
                        _accessionConditionTypeSelectDisabledIndicator = false;
                    else if (AdministratorRoleIndicator || HumanLaboratoryChiefIndicator || VeterinaryLaboratoryChiefIndicator)
                        _accessionConditionTypeSelectDisabledIndicator = false;
                    else if (RowAction is (int)RowActionTypeEnum.Accession or (int)RowActionTypeEnum.Update or (int)RowActionTypeEnum.RejectUpdateTransferOut)
                        _accessionConditionTypeSelectDisabledIndicator = false;
                }
                else
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
                    _accessionCommentClass = string.IsNullOrEmpty(AccessionComment) ? "comment-empty-required" : "comment-non-empty-required";
                }
                else
                {
                    _accessionCommentClass = string.IsNullOrEmpty(AccessionComment) ? "comment-empty" : "comment-non-empty";
                }

                return _accessionCommentClass;
            }
        }

        public bool EIDSSLocalOrFieldSampleIDDisabledIndicator { get; set; }
        public bool FunctionalAreaIDDisabledIndicator { get; set; }
        public bool StorageLocationDisabledIndicator { get; set; }
        /// <summary>
        /// Used to register new veterinary samples that have no associated disease report or
        /// active surveillance session currently tied to it.
        /// </summary>
        public long? FarmMasterID { get; set; }
        public long? FarmID { get; set; }

        public long SelectedStorageLocationId { get; set; }
        public List<FreezerSubdivisionBoxLocationAvailability> BoxLocationAvailability { get; set; }
        public string BoxSizeTypeName { get; set; }
    }
}