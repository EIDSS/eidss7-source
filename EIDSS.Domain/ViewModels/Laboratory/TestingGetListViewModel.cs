using EIDSS.Domain.Abstracts;
using EIDSS.Domain.Enumerations;
using EIDSS.Domain.RequestModels.FlexForm;
using EIDSS.Domain.ResponseModels.FlexForm;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using static System.String;

namespace EIDSS.Domain.ViewModels.Laboratory
{
    public class TestingGetListViewModel : BaseModel
    {
        public TestingGetListViewModel ShallowCopy()
        {
            return (TestingGetListViewModel)MemberwiseClone();
        }
        public long TestID { get; set; }
        public bool FavoriteIndicator { get; set; }
        public long SiteID { get; set; }
        public long? CurrentSiteID { get; set; }
        public long? TestNameTypeID { get; set; }
        public long? TestCategoryTypeID { get; set; }
        public long? TestResultTypeID { get; set; }

        private long _testStatusTypeId;
        public long TestStatusTypeID {
            get => _testStatusTypeId;
            set
            {
                _testStatusTypeId = value;

                switch (_testStatusTypeId)
                {
                    case (long)TestStatusTypeEnum.Amended:
                        ResultDateDisabledIndicator = true;
                        StartedDateDisabledIndicator = true;
                        TestNameTypeDisabledIndicator = true;
                        TestCategoryTypeDisabledIndicator = true;
                        TestResultTypeDisabledIndicator = true;
                        TestStatusTypeSelectDisabledIndicator = true;
                        TestedByDisabledIndicator = false;
                        break;
                    case (long)TestStatusTypeEnum.InProgress:
                        ResultDateDisabledIndicator = false;
                        StartedDateDisabledIndicator = false;
                        TestCategoryTypeDisabledIndicator = false;

                        TestNameTypeDisabledIndicator = !ExternalTestIndicator;
    
                        TestResultTypeDisabledIndicator = false;
                        TestStatusTypeSelectDisabledIndicator = false;
                        TestedByDisabledIndicator = false;
                        break;
                    case (long)TestStatusTypeEnum.MarkedForDeletion:
                        ResultDateDisabledIndicator = true;
                        StartedDateDisabledIndicator = true;
                        TestStatusTypeSelectDisabledIndicator = true;
                        TestNameTypeDisabledIndicator = true;
                        TestCategoryTypeDisabledIndicator = true;
                        TestResultTypeDisabledIndicator = true;
                        TestedByDisabledIndicator = true;
                        break;
                    case (long)TestStatusTypeEnum.Deleted:
                        ResultDateDisabledIndicator = true;
                        StartedDateDisabledIndicator = true;
                        TestCategoryTypeDisabledIndicator = true;
                        TestNameTypeDisabledIndicator = true;
                        TestResultTypeDisabledIndicator = true;
                        TestStatusTypeSelectDisabledIndicator = true;
                        TestedByDisabledIndicator = true;
                        break;
                    case (long)TestStatusTypeEnum.Final:
                        if (ActionPerformedIndicator == false)
                        {
                            ResultDateDisabledIndicator = true;
                            StartedDateDisabledIndicator = true;
                            TestedByDisabledIndicator = true;
                            TestCategoryTypeDisabledIndicator = true;
                            TestNameTypeDisabledIndicator = true;
                            TestResultTypeDisabledIndicator = true;
                            TestStatusTypeSelectDisabledIndicator = true;
                            TestedByDisabledIndicator = true;
                        }
                        break;
                    case (long)TestStatusTypeEnum.Preliminary:
                        ResultDateDisabledIndicator = false;
                        StartedDateDisabledIndicator = false;
                        TestCategoryTypeDisabledIndicator = false;
                        if (ExternalTestIndicator == false)
                            TestNameTypeDisabledIndicator = true;
                        TestResultTypeDisabledIndicator = false;
                        TestStatusTypeSelectDisabledIndicator = false;
                        TestedByDisabledIndicator = false;
                        break;
                }
            }
        }
        public long? PreviousTestStatusTypeID { get; set; }
        public long? DiseaseID { get; set; }
        public long SampleID { get; set; }
        public long? RootSampleID { get; set; }
        public long? ParentSampleID { get; set; }
        public long? SentToOrganizationID { get; set; }
        public long? BatchTestID { get; set; }
        public long? ObservationID { get; set; }
        public int? TestNumber { get; set; }
        public string Note { get; set; }
        public DateTime? StartedDate { get; set; }
        public DateTime? ResultDate { get; set; }
        public long? TestedByOrganizationID { get; set; }
        public long? TestedByPersonID { get; set; }
        public long? ResultEnteredByOrganizationID { get; set; }
        public long? ResultEnteredByPersonID { get; set; }
        public string ResultEnteredByPersonName { get; set; }
        public long? ValidatedByOrganizationID { get; set; }
        public long? ValidatedByPersonID { get; set; }
        public string ValidatedByPersonName { get; set; }
        public bool ReadOnlyIndicator { get; set; }
        public bool NonLaboratoryTestIndicator { get; set; }
        public bool ExternalTestIndicator { get; set; }
        public long? PerformedByOrganizationID { get; set; }
        public string PerformedByOrganizationName { get; set; }
        public DateTime? ReceivedDate { get; set; }
        public string ContactPersonName { get; set; }
        [StringLength(36)]
        public string EIDSSReportOrSessionID { get; set; }
        public string PatientOrFarmOwnerName { get; set; }
        public string SampleTypeName { get; set; }
        public string DiseaseName { get; set; }
        [StringLength(36)]
        public string EIDSSLaboratorySampleID { get; set; }
        [StringLength(36)]
        public string EIDSSLocalOrFieldSampleID { get; set; }
        public string TestNameTypeName { get; set; }
        public string TestStatusTypeName { get; set; }
        public string TestResultTypeName { get; set; }
        public string TestCategoryTypeName { get; set; }
        public DateTime? AccessionDate { get; set; }
        public string FunctionalAreaName { get; set; }
        public long? AccessionConditionTypeID { get; set; }
        public long? SampleStatusTypeID { get; set; }
        public string AccessionConditionOrSampleStatusTypeName { get; set; }
        [StringLength(200)]
        public string AccessionComment { get; set; }
        [StringLength(36)]
        public string EIDSSAnimalID { get; set; }
        public int TransferredCount { get; set; }
        public long? TransferID { get; set; }
        public long? HumanDiseaseReportID { get; set; }
        public long? VeterinaryDiseaseReportID { get; set; }
        public long? MonitoringSessionID { get; set; }
        public long? VectorID { get; set; }
        public int RowStatus { get; set; }
        public bool ReadPermissionIndicator { get; set; }
        public bool AccessToPersonalDataPermissionIndicator { get; set; }
        public bool AccessToGenderAndAgeDataPermissionIndicator { get; set; }
        public bool WritePermissionIndicator { get; set; }
        public bool DeletePermissionIndicator { get; set; }
        public int RowAction { get; set; }
        public bool RowSelectionIndicator { get; set; }
        public int InProgressCount { get; set; }

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

        private bool _actionPerformedIndicator;
        public bool ActionPerformedIndicator
        {
            get => _actionPerformedIndicator;
            set
            {
                _actionPerformedIndicator = value;

                if (_actionPerformedIndicator)
                {
                    if (TestID > 0)
                        RowAction = (int)RowActionTypeEnum.Update;
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
        private bool _testStatusTypeSelectDisabledIndicator;
        public bool TestStatusTypeSelectDisabledIndicator
        {
            get
            {
                _testStatusTypeSelectDisabledIndicator = true;

                if (TestStatusTypeID != (long) TestStatusTypeEnum.Amended &&
                    TestStatusTypeID != (long) TestStatusTypeEnum.Final &&
                    TestStatusTypeID != (long) TestStatusTypeEnum.Deleted &&
                    TestStatusTypeID != (long) TestStatusTypeEnum.MarkedForDeletion)
                    _testStatusTypeSelectDisabledIndicator = false;

                if (TestStatusTypeID == (long) TestStatusTypeEnum.Final && ActionPerformedIndicator)
                    _testStatusTypeSelectDisabledIndicator = false;

                return _testStatusTypeSelectDisabledIndicator;
            }
            set
            {
                value = true;

                if (TestStatusTypeID != (long) TestStatusTypeEnum.Amended &&
                    TestStatusTypeID != (long) TestStatusTypeEnum.Final &&
                    TestStatusTypeID != (long) TestStatusTypeEnum.Deleted &&
                    TestStatusTypeID != (long) TestStatusTypeEnum.MarkedForDeletion)
                    value = false;

                _testStatusTypeSelectDisabledIndicator = value;
            }
        }
        public bool TestResultTypeDisabledIndicator { get; set; }
        private bool _testResultTypeRequiredVisibleIndicator;
        public bool TestResultTypeRequiredVisibleIndicator
        {
            get
            {
                _testResultTypeRequiredVisibleIndicator = true;

                if (TestStatusTypeID is (long)TestStatusTypeEnum.InProgress or (long)TestStatusTypeEnum.Deleted or (long)TestStatusTypeEnum.MarkedForDeletion)
                {
                    _testResultTypeRequiredVisibleIndicator = false;
                }

                return _testResultTypeRequiredVisibleIndicator;
            }
            set
            {
                value = true;

                if (TestStatusTypeID is (long)TestStatusTypeEnum.InProgress or (long)TestStatusTypeEnum.Deleted or (long)TestStatusTypeEnum.MarkedForDeletion)
                {
                    value = false;
                }

                _testResultTypeRequiredVisibleIndicator = value;
            }
        }
        public bool TestNameTypeDisabledIndicator { get; set; }
        public bool TestCategoryTypeDisabledIndicator { get; set; }
        public bool StartedDateDisabledIndicator { get; set; }
        public bool ResultDateDisabledIndicator { get; set; }
        public bool TestedByDisabledIndicator { get; set; }
        public bool VeterinaryLaboratoryChiefIndicator { get; set; }
        public bool HumanLaboratoryChiefIndicator { get; set; }
        public bool AdministratorRoleIndicator { get; set; }
        public bool AllowDatesInThePast { get; set; }
        public int RowNumber { get; set; }

        public FlexFormQuestionnaireGetRequestModel AdditionalTestDetailsFlexFormRequest { get; set; }
        public IList<FlexFormActivityParametersListResponseModel> AdditionalTestDetailsFlexFormAnswers { get; set; }
        public string AdditionalTestDetailsObservationParameters { get; set; }
    }
}