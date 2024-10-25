using DocumentFormat.OpenXml.Packaging;
using System;

namespace EIDSS.Web.Validators;

public class CustomRelationshipErrorHandler : RelationshipErrorHandler
{
    public override string Rewrite(Uri partUri, string? id, string? uri)
    {
        return "Error";
    }
}
