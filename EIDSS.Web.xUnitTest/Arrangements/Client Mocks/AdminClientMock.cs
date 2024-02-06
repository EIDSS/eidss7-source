using AutoFixture;
using EIDSS.ClientLibrary.ApiClients.Admin;
using EIDSS.Domain.RequestModels.Administration;
using EIDSS.Domain.ResponseModels;
using EIDSS.Domain.ResponseModels.Administration;
using EIDSS.Domain.ViewModels;
using EIDSS.Domain.ViewModels.Administration;
using EIDSS.Web.xUnitTest.Abstracts;
using Moq;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Web.xUnitTest.Arrangements.Client_Mocks
{
    public class AdminClientMock : BaseClientMock<IAdminClient>, IAdminClient
    {

        private LoginResponseViewModel liResponse
        {
            get
            {
                return new LoginResponseViewModel
                {
                    Token = BaseArrangement.UserToken,
                    Status = true,
                    Expiration = BaseArrangement.TokenExpiration,
                    userId = BaseArrangement.Fixture.Create<long>()
                };
            }
        }

        public async Task<ResponseViewModel> AddEmployee(RegisterViewModel model)
        {
            Client.Setup(p => p.AddEmployee(model)).ReturnsAsync(BaseArrangement.Fixture.Create<ResponseViewModel>());
            return await Client.Object.AddEmployee(model);
        }

        public async Task<APIPostResponseModel> DeleteAgeGroup(long idfsAgeGroup, bool? deleteAnyway)
        {
            Client.Setup(p => p.DeleteAgeGroup(idfsAgeGroup, deleteAnyway)).ReturnsAsync(BaseArrangement.APIPostResponseMock_200);
            return await Client.Object.DeleteAgeGroup(idfsAgeGroup, deleteAnyway);
        }

        public async Task<APIPostResponseModel> DeleteBaseReference(long idfsBaseReference)
        {
            Client.Setup(p => p.DeleteBaseReference(idfsBaseReference)).ReturnsAsync(BaseArrangement.APIPostResponseMock_200);
            return await Client.Object.DeleteBaseReference(idfsBaseReference);
        }

        public async Task<ResponseViewModel> DisableUserAccount(DisableUserAccountParams disableUserAccountParams)
        {
            Client.Setup(p => p.DisableUserAccount(disableUserAccountParams)).ReturnsAsync(BaseArrangement.PostResponseMock_Success);
            return await Client.Object.DisableUserAccount(disableUserAccountParams);
        }

        public async Task<ResponseViewModel> EnableUserAccount(EnableUserAccountParams enableUserAccountParams)
        {
            Client.Setup(p => p.EnableUserAccount(enableUserAccountParams)).ReturnsAsync(BaseArrangement.PostResponseMock_Success);
            return await Client.Object.EnableUserAccount(enableUserAccountParams);
        }

        public async Task<BaseReferenceEditorsViewModel[]> GetAgeGroupList(AgeGroupGetRequestModel request)
        {
            Client.Setup(p => p.GetAgeGroupList(request)).ReturnsAsync(BaseArrangement.Fixture.CreateMany<BaseReferenceEditorsViewModel>().ToArray());
            return await Client.Object.GetAgeGroupList(request);
        }

        public async Task<AppUserViewModel> GetAppUser(string userName)
        {
            Client.Setup(p => p.GetAppUser(userName)).ReturnsAsync(BaseArrangement.Fixture.Create<AppUserViewModel>());
            return await Client.Object.GetAppUser(userName);
        }

        public async Task<BaseReferenceEditorsViewModel[]> GetBaseReferenceListAsync(string languageId, long? idfsReferenceType, int page, int pageSize, string sortColumn, string sortOrder, string advancedSearch = null)
        {
            Client.Setup(p => p.GetBaseReferenceListAsync(languageId, idfsReferenceType, page, pageSize, sortColumn, sortOrder, advancedSearch)).ReturnsAsync(BaseArrangement.Fixture.CreateMany<BaseReferenceEditorsViewModel>().ToArray());
            return await Client.Object.GetBaseReferenceListAsync(languageId, idfsReferenceType, page, pageSize, sortColumn, sortOrder, advancedSearch);
        }

        public async Task<ResponseViewModel> LockAccount(LockUserAccountParams lockUserAccountParams)
        {
            Client.Setup(p => p.LockAccount(lockUserAccountParams)).ReturnsAsync(BaseArrangement.PostResponseMock_Success);
            return await Client.Object.LockAccount(lockUserAccountParams);
        }

        public async Task<LoginResponseViewModel> LoginAsync(string username, string password)
        {
            Client.Setup(p => p.LoginAsync(username, password)).ReturnsAsync(liResponse);
            return await Client.Object.LoginAsync(username, password);
        }

        public Task LogOutAsync(string userName)
        {
            throw new NotImplementedException();
        }

        public async Task<APIPostResponseModel> RemoveEmployee(string aspnetUserId)
        {
            Client.Setup(p => p.RemoveEmployee(aspnetUserId)).ReturnsAsync(BaseArrangement.APIPostResponseMock_200);
            return await Client.Object.RemoveEmployee(aspnetUserId);
        }

        public Task<ResponseViewModel> ResetPassword(ResetPasswordParams resetPasswordParams)
        {
            throw new NotImplementedException();
        }

        public Task<ResponseViewModel> ResetPasswordByUser(ResetPasswordByUserParams resetPasswordByUserParams)
        {
            throw new NotImplementedException();
        }

        public async Task<AgeGroupSaveRequestResponseModel> SaveAgeGroup(AgeGroupSaveRequestModel request)
        {
            Client.Setup(p => p.SaveAgeGroup(request)).ReturnsAsync(BaseArrangement.Fixture.Create<AgeGroupSaveRequestResponseModel>());
            return await Client.Object.SaveAgeGroup(request);
        }

        public async Task<BaseReferenceSaveRequestResponseModel> SaveBaseReference(BaseReferenceSaveRequestModel request)
        {
            Client.Setup(p => p.SaveBaseReference(request)).ReturnsAsync(BaseArrangement.Fixture.Create<BaseReferenceSaveRequestResponseModel>());
            return await Client.Object.SaveBaseReference(request);

        }

        public async Task<ResponseViewModel> UnLockAccount(UnLockUserAccountParams lockUserAccountParams)
        {
            Client.Setup(p => p.UnLockAccount(lockUserAccountParams)).ReturnsAsync(BaseArrangement.PostResponseMock_Success);
            return await Client.Object.UnLockAccount(lockUserAccountParams);
        }

        public Task<bool> UpdateIdentityOptions()
        {
            throw new NotImplementedException();
        }

        public Task<ResponseViewModel> UpdateUserName(UpdateUserNameParams updateUserNameParams)
        {
            Client.Setup<Task<ResponseViewModel>>(p => p.UpdateUserName(updateUserNameParams)).Returns(Task.FromResult(BaseArrangement.PostResponseMock_Success));
            return Client.Object.UpdateUserName(updateUserNameParams);
        }

        public async Task<bool> UserExists(string userName)
        {
            Client.Setup(p => p.UserExists(userName)).ReturnsAsync(true);
            return await Client.Object.UserExists(userName);
        }

        public async Task<ResponseViewModel> ValidatePassword(string username, string password)
        {
            Client.Setup(p => p.ValidatePassword(username, password)).ReturnsAsync(BaseArrangement.PostResponseMock_Failure);
            return await Client.Object.ValidatePassword(username, password);
        }
    }
}
