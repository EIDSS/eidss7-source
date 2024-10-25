namespace EIDSS.Domain.ViewModels.Outbreak
{
    public class FlexFormAssignedTemplatesModel
    {
        public long? HumanCaseQuestionaireTemplateID { get; set; }
        public long? HumanCaseMonitoringTemplateID { get; set; }
        public long? HumanContactTracingTemplateID { get; set; }

        public long? AvianCaseQuestionaireTemplateID { get; set; }
        public long? AvianCaseMonitoringTemplateID { get; set; }
        public long? AvianContactTracingTemplateID { get; set; }

        public long? LivestockCaseQuestionaireTemplateID { get; set; }
        public long? LivestockCaseMonitoringTemplateID { get; set; }
        public long? LivestockContactTracingTemplateID { get; set; }
    }
}
