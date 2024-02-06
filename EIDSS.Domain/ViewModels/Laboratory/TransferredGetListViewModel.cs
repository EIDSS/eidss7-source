using EIDSS.Domain.Abstracts;
using EIDSS.Domain.Enumerations;
using EIDSS.Domain.ViewModels.Administration;
using EIDSS.Localization.Helpers;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;

namespace EIDSS.Domain.ViewModels.Laboratory
{
    public class TransferredGetListViewModel : BaseModel
    {
        public TransferredGetListViewModel ShallowCopy()
        {
            return (TransferredGetListViewModel)MemberwiseClone();
        }
        public long TransferID { get; set; }
        [StringLength(36)]
        public string EIDSSTransferID { get; set; }
        public long TransferredOutSampleID { get; set; }
        public long? TransferredInSampleID { get; set; }
        public bool FavoriteIndicator { get; set; }
        [StringLength(36)]
        public string EIDSSReportOrSessionID { get; set; }
        public string PatientOrFarmOwnerName { get; set; }
        [StringLength(36)]
        public string EIDSSLaboratorySampleID { get; set; }
        public long? TransferredToOrganizationID { get; set; }
        public string TransferredToOrganizationName { get; set; }
        public long? TransferredFromOrganizationID { get; set; }
        public string TransferredFromOrganizationName { get; set; }
        [LocalizedRequired]
        [LocalizedDateLessThanOrEqualToToday]
        public DateTime? TransferDate { get; set; }
        public string TestRequested { get; set; }
        public long? TestID { get; set; }
        public long? TestNameTypeID { get; set; }
        public string TestNameTypeName { get; set; }
        public long? TestResultTypeID { get; set; }
        public string TestResultTypeName { get; set; }
        public long? TestStatusTypeID { get; set; }
        public string TestStatusTypeName { get; set; }
        public long? TestCategoryTypeID { get; set; }
        public long? TestDiseaseID { get; set; }
        public DateTime? StartedDate { get; set; }
        public DateTime? ResultDate { get; set; }
        public string ContactPersonName { get; set; }
        [StringLength(36)]
        public string EIDSSLocalOrFieldSampleID { get; set; }
        public string SampleTypeName { get; set; }
        public string DiseaseID { get; set; }
        public string DiseaseName { get; set; }
        public DateTime? AccessionDate { get; set; }
        public long? FunctionalAreaID { get; set; }
        public string FunctionalAreaName { get; set; }
        public int AccessionIndicator { get; set; }
        public long? AccessionConditionTypeID { get; set; }
        public long? SampleStatusTypeID { get; set; }
        public string AccessionConditionOrSampleStatusTypeName { get; set; }
        public string AccessionComment { get; set; }
        public string PurposeOfTransfer { get; set; }
        public long TransferredFromOrganizationSiteID { get; set; }
        public long? TransferredToOrganizationSiteID { get; set; }
        public long? SentToOrganizationID { get; set; }
        public long? SentByPersonID { get; set; }
        public string SentByPersonName { get; set; }
        public long TransferStatusTypeID { get; set; }
        public int RowStatus { get; set; }
        [StringLength(36)]
        public string EIDSSAnimalID { get; set; }
        public int TestAssignedIndicator { get; set; }
        public bool ExternalOrganizationIndicator { get; set; }
        public bool ReadPermissionIndicator { get; set; }
        public int AccessToPersonalDataPermissionIndicator { get; set; }
        public int AccessToGenderAndAgeDataPermissionIndicator { get; set; }
        public bool WritePermissionIndicator { get; set; }
        public bool DeletePermissionIndicator { get; set; }

        public List<FilteredDiseaseGetListViewModel> Diseases { get; set; } = new();

        public int RowAction { get; set; }
        public int RowSelectionIndicator { get; set; }
        public int InProgressCount { get; set; }

        private string _accessionCommentClass;
        public string AccessionCommentClass
        {
            get
            {
                if (AccessionConditionTypeID is (long)AccessionConditionTypeEnum.AcceptedInPoorCondition || AccessionConditionTypeID == (long)AccessionConditionTypeEnum.Rejected)
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

        private bool _transferFormDisabledIndicator;
        public bool TransferFormDisabledIndicator
        {
            get
            {
                _transferFormDisabledIndicator = true;

                if (CanEditSampleTransferFormsAfterTransferIsSaved && TransferStatusTypeID == (long)TransferStatusTypeEnum.InProgress)
                    _transferFormDisabledIndicator = false;

                return _transferFormDisabledIndicator;
            }
        }

        public bool PrintBarcodeIndicator { get; set; }

        private bool _actionPerformedIndicator;
        public bool ActionPerformedIndicator 
        {
            get => _actionPerformedIndicator;
            set
            {
                _actionPerformedIndicator = value;

                if (_actionPerformedIndicator)
                {
                    if (TransferID > 0)
                    {
                        RowAction = (int)RowActionTypeEnum.Update;
                    }
                    else
                        RowAction = (int)RowActionTypeEnum.Insert;
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
        public bool AllowDatesInThePast { get; set; }
        public bool CanEditSampleTransferFormsAfterTransferIsSaved { get; set; }
    }
}