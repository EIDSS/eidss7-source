using EIDSS.Domain.Attributes;
using Microsoft.AspNetCore.Http;

namespace EIDSS.Domain.RequestModels.Outbreak
{
    [DataUpdateType(Enumerations.DataUpdateTypeEnum.Update)]
    public class OutbreakSessionNoteCreateRequestModel
    {
        public string LangID { get; set; }
        public long? idfOutbreakNote { get; set; }
        public long? idfOutbreak { get; set; }
        public string strNote { get; set; }
        public long? idfPerson { get; set; }
        public int? intRowStatus { get; set; } = 0;
        public string strMaintenanceFlag { get; set; }
        public string strReservedAttribute { get; set; }
        public long? UpdatePriorityID { get; set; }
        public string UpdateRecordTitle { get; set; }
        public string UploadFileName { get; set; }
        public string UploadFileDescription { get; set; }
        public byte[] UploadFileObject { get; set; }
        public string DeleteAttachment { get; set; }
        public string User { get; set; }
        public IFormFile FileUpload { get; set; }
        public string FileExtension { get; set; }
    }
}
