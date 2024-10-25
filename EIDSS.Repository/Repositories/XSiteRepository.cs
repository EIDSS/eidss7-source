using EIDSS.Domain.ViewModels;
using EIDSS.Repository.Interfaces;
using EIDSS.Repository.ReturnModels;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading;
using System.Threading.Tasks;

namespace EIDSS.Repository.Repositories
{
    //public class XSiteRepository
    //{
    //    private DataRepository _repository = null;

    //    public XSiteRepository(DataRepository repository)
    //    {
    //        _repository = repository;
    //    }
    //    public async Task<List<XSiteDocumentListViewModel>> GetDocumentMap( string connectionStringName, CancellationToken cancellationToken)
    //    {
    //        List<XSiteDocumentListViewModel> results = new List<XSiteDocumentListViewModel>();

    //        try
    //        {
    //            #region (1)  Get the document map

    //            DataRepoArgs args = new DataRepoArgs
    //            {
    //                Args = new object[] { null, cancellationToken },
    //                MappedReturnType = typeof(List<XSiteDocumentListViewModel>),
    //                RepoMethodReturnType = typeof(List<USP_xSiteDocumentListGetResult>)
    //            };

    //            var map = await _repository.Get(args) as List<XSiteDocumentListViewModel>;

    //            #endregion

    //            #region (2) Get the associated document list of its respective database

    //            var langgroups = map.GroupBy(g => g.LanguageCode);

    //            foreach (var maplang in langgroups)
    //            {
    //                var optionsBuilder = new DbContextOptionsBuilder<XSiteContext>();
    //                optionsBuilder.UseSqlServer(getxSiteConnString(maplang.Key));
    //                // Call the xsite database to fetch the data...
    //                var ctx = new XSiteContext(optionsBuilder.Options);

    //                var langdocs =
    //                    (
    //                    from d in ctx.TDocuments
    //                    join m in ctx.TDocumentGroupMappings on d.DocumentId equals m.DocumentId into j1
    //                    from dmg in j1.DefaultIfEmpty()
    //                    join g in ctx.TDocumentGroups on dmg.DocumentGroupId equals g.DocumentGroupId into j2
    //                    from ddmg in j2.DefaultIfEmpty()
    //                    where d.Guid != null && d.FileName != null
    //                    select new XSiteDocumentListViewModel
    //                    {
    //                        DocumentID = d.DocumentId,
    //                        DocumentGroupName = "",
    //                        DocumentName = d.DocumentName,
    //                        FileName = d.FileName,
    //                        VideoName = d.ShowMePath,
    //                        GUID = d.Guid
    //                    }).Distinct().ToList();

    //                foreach (var doc in langdocs)
    //                {
    //                    // Get the document from the country database for the given guid in the mapping table
    //                    var isomap = maplang.Where(w => w.xSiteGUID == doc.GUID);
    //                    if (isomap != null && isomap.Count() > 0)
    //                    {
    //                        doc.EIDSSMenuID = isomap.FirstOrDefault().EIDSSMenuId;
    //                        doc.CountryISOCode = maplang.Key; // isomap.FirstOrDefault().LanguageCode;
    //                        doc.EIDSSMenuPageLink = isomap.FirstOrDefault().PageLink;
    //                    }

    //                }
    //                //Remove records where there's no associated menu map...
    //                langdocs.RemoveAll(r => r.CountryISOCode == null);
    //                results.AddRange(langdocs);
    //            }

    //            #endregion
    //            if (results == null)
    //            {
    //                Log.Information("Unable to find help documents");
    //                throw new Exception("Unable to locate help documents for the given language");
    //            }
    //            else
    //            {
    //                List<XSiteDocumentListViewModel> videolist = new();
    //                foreach (var doc in results)
    //                {
    //                    var idx = _options.LanguageConfigurations.FindIndex(f => f.CountryISOCode.ToLower() == doc.CountryISOCode.ToLower());
    //                    if (idx != -1)
    //                    {
    //                        doc.FileName = Path.Combine(_options.LanguageConfigurations[idx].DataDirectory, string.Format("DOC{0}", doc.DocumentID), doc.FileName);

    //                        //Check if there is an MP4 file as well.
    //                        if (doc.VideoName != null)
    //                        {
    //                            videolist.Add(new XSiteDocumentListViewModel
    //                            {
    //                                DocumentGroupName = doc.DocumentGroupName,
    //                                DocumentID = doc.DocumentID,
    //                                DocumentName = doc.DocumentName,
    //                                FileName = Path.Combine(_options.LanguageConfigurations[idx].DataDirectory, string.Format("DOC{0}", doc.DocumentID), doc.VideoName),
    //                                GUID = doc.GUID,
    //                                CountryISOCode = doc.CountryISOCode,
    //                                EIDSSMenuID = doc.EIDSSMenuID,
    //                                EIDSSMenuPageLink = doc.EIDSSMenuPageLink

    //                            });

    //                            doc.VideoName = null;

    //                        }

    //                    }
    //                    results.AddRange(videolist);
    //                }
    //            }

    //        }
    //        catch (Exception ex) when (ex is TaskCanceledException || ex is OperationCanceledException)
    //        {
    //            Log.Error("Process was cancelled");
    //        }
    //        catch (Exception ex)
    //        {
    //            Log.Error(ex.Message);
    //            throw;
    //        }

    //        return Ok(results);
    //    }
}
