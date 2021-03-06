﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using HODOR.src.Globals;

namespace HODOR.src.DAO
{
    public class LizenzDAO
    {
        public static Lizenz_Zeitlich createAndGetZeitlizenz(Programm licensedProgramm, DateTime startDate, DateTime endDate)
        {
            Lizenz_Zeitlich license = Lizenz_Zeitlich.CreateLizenz_Zeitlich(licensedProgramm.ProgrammID, startDate, endDate);
            HodorGlobals.getHodorContext().Lizenzs.AddObject(license);
            HodorGlobals.save();
            return license;
        }

        public static Lizenz_Zeitlich createAndGetZeitlizenz(Programm licensedProgramm, DateTime endDate)
        {
            return createAndGetZeitlizenz(licensedProgramm, DateTime.Now, endDate);
        }

        public static Lizenz_Versionsorientiert createAndGetVersionslizenz(Release licensedRelease, Int32 versionIncremention)
        {
            Lizenz_Versionsorientiert license = Lizenz_Versionsorientiert.CreateLizenz_Versionsorientiert(versionIncremention, licensedRelease.ReleaseID);

            HodorGlobals.getHodorContext().Lizenzs.AddObject(license);
            HodorGlobals.save();

            return license;
        }

        public static void deleteLicense(Lizenz license)
        {
            if (license is Lizenz_Versionsorientiert)
            {
                Lizenz_Versionsorientiert versionLicense = (Lizenz_Versionsorientiert)license;
                deleteVersionLicense(versionLicense);
            } else if (license is Lizenz_Zeitlich) {
                Lizenz_Zeitlich timespanLicense = (Lizenz_Zeitlich)license;
                deleteTimespanLicense(timespanLicense);
            } else {
                throw new ArgumentException("Unknown type of License: "+license.LizenzID);
            }

        }

        public static void deleteVersionLicense(Lizenz_Versionsorientiert versionLicense)
        {
            HODOR_entities db = HodorGlobals.getHodorContext();

            db.Lizenzs.DeleteObject(versionLicense);

            HodorGlobals.save();
        }

        public static void deleteTimespanLicense(Lizenz_Zeitlich timespanLicense)
        {
            HODOR_entities db = HodorGlobals.getHodorContext();

            db.Lizenzs.DeleteObject(timespanLicense);

            HodorGlobals.save();
        }
    }
}