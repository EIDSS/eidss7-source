using EIDSS.Domain.ViewModels.Human;
using EIDSS.Web.Components.Administration.Deduplication;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using EIDSS.Domain.Enumerations;

namespace EIDSS.Web.Services
{
    public class PersonDeduplicationSessionStateContainerService
    {

        #region backing fields

        private IList<Field> infoList { get; set; }
        private IList<Field> infoList2 { get; set; }
        private IEnumerable<int> infoValues { get; set; }
        private IEnumerable<int> infoValues2 { get; set; }
        private IList<Field> addressList { get; set; }
        private IList<Field> addressList2 { get; set; }
        private IEnumerable<int> addressValues { get; set; }
        private IEnumerable<int> addressValues2 { get; set; }
        private IList<Field> empList { get; set; }
        private IList<Field> empList2 { get; set; }
        private IEnumerable<int> empValues { get; set; }
        private IEnumerable<int> empValues2 { get; set; }



        #endregion
        #region Globals

        /// <summary>
        /// The event that will be raised for state changed.
        /// </summary>
        public event Action<string> OnChange;


        public IList<PersonViewModel> Records { get; set; }
        public IList<PersonViewModel> SelectedRecords { get; set; }
        public IList<PersonViewModel> SearchRecords { get; set; }

        public long HumanMasterID { get; set; }
        public long HumanMasterID2 { get; set; }

        public IList<Field> InfoList { get =>infoList ; set { infoList = value; NotifyStateChanged("InfoList"); } }
        public IList<Field> InfoList2 { get => infoList2; set { infoList2 = value; NotifyStateChanged("InfoList2"); } }
        public IList<Field> InfoList0 { get; set; }
        public IList<Field> InfoList02 { get; set; }
        
        public IEnumerable<int> InfoValues { get => infoValues; set { infoValues = (IEnumerable<int>)value; NotifyStateChanged("InfoValues"); } }
        public IEnumerable<int> InfoValues2 { get => infoValues2; set { infoValues2 = (IEnumerable<int>)value; NotifyStateChanged("InfoValues2"); } }

        public IList<Field> AddressList0 { get; set; }
        public IList<Field> AddressList02 { get; set; }
        public IList<Field> AddressList { get => addressList; set { addressList = value; NotifyStateChanged("AddressList"); } }
        public IList<Field> AddressList2 { get => addressList2; set { addressList2 = value; NotifyStateChanged("AddressList2"); } }

        public IEnumerable<int> AddressValues { get => addressValues; set { addressValues = (IEnumerable<int>)value; NotifyStateChanged("AddressValues"); } }
        public IEnumerable<int> AddressValues2 { get => addressValues2; set { addressValues2 = (IEnumerable<int>)value; NotifyStateChanged("AddressValues2"); } }

        public IList<Field> EmpList0 { get; set; }
        public IList<Field> EmpList02 { get; set; }
        public IList<Field> EmpList { get => empList; set { empList = value; NotifyStateChanged("EmpList"); } }
        public IList<Field> EmpList2 { get => empList2; set { empList2 = value; NotifyStateChanged("EmpList2"); } }

        public IEnumerable<int> EmpValues { get => empValues; set { empValues = (IEnumerable<int>)value; NotifyStateChanged("EmpValues"); } }
        public IEnumerable<int> EmpValues2 { get => empValues2; set { empValues2 = (IEnumerable<int>)value; NotifyStateChanged("EmpValues2"); } }

        public int RecordSelection { get; set; }
        public int Record2Selection { get; set; }

        public bool chkCheckAll { get; set; }
        public bool chkCheckAll2 { get; set; }
        public bool chkCheckAllAddress { get; set; }
        public bool chkCheckAllAddress2 { get; set; }
        public bool chkCheckAllEmp { get; set; }
        public bool chkCheckAllEmp2 { get; set; }

        public long SurvivorHumanMasterID { get; set; }
        public long SupersededHumanMasterID { get; set; }

        public IList<Field> SurvivorInfoList { get; set; }
        public IList<Field> SurvivorAddressList { get; set; }
        public IList<Field> SurvivorEmpList { get; set; }
        public IEnumerable<int> SurvivorInfoValues { get; set; }
        public IEnumerable<int> SurvivorAddressValues { get; set; }
        public IEnumerable<int> SurvivorEmpValues { get; set; }

        public bool TabChangeIndicator { get; set; }
        public PersonDeduplicationTabEnum Tab { get; set; }

        #endregion

        #region Methods


        /// <summary>
        /// The state change event notification
        /// </summary>
        private void NotifyStateChanged(string property) => OnChange?.Invoke(property);


        #endregion
    }
}
