using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Threading.Tasks;

namespace EIDSS.Web.ViewModels
{


    public class TESTUSER
    {
      
        [Required]
        public string username { get; set; } = "Lamont";
        public string password { get; set; } = "Jelly Bean";
        public string profileName { get; set; } = "Juke";
        public string address { get; set; } = "123 Any Rd";
        public int userId { get; set; } = 7;
    }

    public class TESTMODEL
    {
        public List<TESTUSER> _testUserList;
        public TESTUSER _tESTUSER;
        public TESTMODEL()
        {
            _tESTUSER = new TESTUSER();
             _testUserList = new List<TESTUSER>();
            for (int i = 0; i < 10; i++)
            {
                _testUserList.Add(new TESTUSER() { address = "ADDRESS" + i.ToString(), password = "PASSWORD" + i.ToString(), profileName = "PROFILE NAME" + i.ToString(), userId = i, username = "USERNAME" + i.ToString(), });
                
            }

        }
        public TESTUSER TESTUSER { get { return _tESTUSER; } }

        public List<TESTUSER> TESTUSERLIST { get { return _testUserList; } }


        public TESTUSER Details(int id)
        {
            TESTUSER user = new TESTUSER();
             _testUserList = new List<TESTUSER>();
            for (int i = 0; i < 10; i++)
            {
                _testUserList.Add(new TESTUSER() { address = "ADDRESS" + i.ToString(), password = "PASSWORD" + i.ToString(), profileName = "PROFILE NAME" + i.ToString(), userId = i, username = "USERNAME" + i.ToString(), });
              
            }
            user = _testUserList.Where(x => x.userId == id).ToList()[0];
            return user;
        }
    }
}
