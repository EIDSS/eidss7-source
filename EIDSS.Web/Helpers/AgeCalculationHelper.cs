using EIDSS.Web.Extensions;
using Microsoft.Extensions.Configuration.UserSecrets;
using Microsoft.VisualBasic;
using System;
using static EIDSS.ClientLibrary.Enumerations.EIDSSConstants;

namespace EIDSS.Web.Helpers
{
    public static class AgeCalculationHelper
    {
        public static bool GetDOBandAgeForPerson(DateTime? dateOfBirth, DateTime? D, ref int _intPatientAge, ref long _idfsHumanAgeType)
        {
            double ddAge = -1;
            DateTime? datUp = null;
            if (dateOfBirth.HasValue && D.HasValue)
            {
                datUp = D;
                ddAge = -dateOfBirth.Value.Date.Subtract(D.Value.Date).TotalDays;

                if (ddAge > -1)
                {
                    long yyAge = DateDifference(HumanAgeTypeConstants.Years, dateOfBirth.Value.Date, datUp.Value);
                    if (yyAge > 0)
                    {
                        _intPatientAge = (int)yyAge;
                        _idfsHumanAgeType = long.Parse(HumanAgeTypeConstants.Years);
                        return true;
                    }
                    else
                    {
                        long mmAge = DateDifference(HumanAgeTypeConstants.Months, dateOfBirth.Value.Date, datUp.Value);
                        if (mmAge > 0)
                        {
                            _intPatientAge = (int)mmAge;
                            _idfsHumanAgeType = long.Parse(HumanAgeTypeConstants.Months);
                            return true;
                        }
                        else
                        {
                            _intPatientAge = (int)ddAge;
                            _idfsHumanAgeType = long.Parse(HumanAgeTypeConstants.Days);
                            return true;
                        }
                    }
                }
            }
            return false;
        }

        public static long DateDifference(string Interval, DateTime Date1, DateTime Date2)
        {

            int dd1 = Date1.Day;
            int mm1 = Date1.Month;
            int yy1 = Date1.Year;

            int dd2 = Date2.Day;
            int mm2 = Date2.Month;
            int yy2 = Date2.Year;

            if ((dd2 <= 0) || (dd1 <= 0) || (mm2 <= 0) || (mm1 <= 0) || (yy2 <= 0) || (yy1 <= 0))
                return -1;

            long diff = -1;

            int sgnY = 1;
            int sgnM = 1;
            int sgnD = 1;
            if (yy2 < yy1)
            {
                sgnY = sgnY * (-1);
                ChangeValues(ref yy2, ref yy1);
            }
            else if (yy2 == yy1)
            {
                sgnY = 0;
            }

            if (mm2 < mm1)
            {
                sgnM = sgnM * (-1);
                ChangeValues(ref mm2, ref mm1);
            }
            else if (mm2 == mm1)
            {
                sgnM = 0;
            }

            if (dd2 < dd1)
            {
                sgnD = sgnD * (-1);
            }
            else if (dd2 == dd1)
            {
                sgnD = 0;
            }

            switch (Interval)
            {
                case HumanAgeTypeConstants.Years:
                    diff = sgnY * (yy2 - yy1 + sgnM * sgnM * (System.Convert.ToInt16((sgnM * sgnY - 1) / 2))
                         + (1 - sgnM * sgnM) * sgnD * sgnD * (System.Convert.ToInt16((sgnD * sgnY - 1) / 2)));
                    break;
                case HumanAgeTypeConstants.Months:
                    int sgnYM = sgnY + (1 - sgnY * sgnY) * sgnM;
                    diff = sgnY * (yy2 - yy1) * 12 + sgnM * (mm2 - mm1) +
                           sgnYM * sgnD * sgnD * (System.Convert.ToInt16((sgnD * sgnYM - 1) / 2));
                    break;
                case HumanAgeTypeConstants.Days:
                    diff = System.Convert.ToInt64(-Date1.Subtract(Date2).TotalDays);
                    break;
                default:
                    break;
            }
            return diff;
        }

        private static void ChangeValues(ref int Value1, ref int Value2)
        {
            int i = Value1;
            Value1 = Value2;
            Value2 = i;
        }
    }
}
