﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using HODOR.src.Globals;

namespace HODOR.src.DAO
{
    public class ProgrammDAO
    {
        public static Programm createAndGetProgramm(String programmName)
        {
            Programm prog = Programm.CreateProgramm(programmName);
            HodorGlobals.getHodorContext().Programms.AddObject(prog);
            HodorGlobals.save(); //strange.. all other DAO's need this... here it creates errors, because it is already persisted but the ObjectState isn't correct o_O
            return prog;
        }

        public static void deleteProgramm(Programm prog)
        {
            List<Release> releases = prog.Releases.ToList<Release>();
            foreach (Release release in releases)
            {
                ReleaseDAO.deleteRelease(release);
            }

            List<Lizenz_Zeitlich> licenses = prog.Lizenz_Zeitlich.ToList<Lizenz_Zeitlich>();
            foreach (Lizenz_Zeitlich license in licenses)
            {
                LizenzDAO.deleteTimespanLicense(license);
            }

            HodorGlobals.getHodorContext().Programms.DeleteObject(prog);

            HodorGlobals.save();
        }

        public static List<Programm> getAllProgramme()
        {
            var programmeQueryResult = from p in HodorGlobals.getHodorContext().Programms.Select(p => p) select p;
            return programmeQueryResult.ToList<Programm>();
        }

        public static Programm getProgrammByExactNameOrNull(String name)
        {
            List<Programm> progList = HodorGlobals.getHodorContext().Programms.Where(p => p.Name == name).ToList<Programm>();

            if (progList.Count == 1)
            {
                //everything ok
                return progList[0];
            }
            else if (progList.Count == 0)
            {
                //no Program with that name found
                return null;
            }
            else
            {
                throw new Exception("Entities for Programm are inconsistent. Duplicate (" + progList.Count +") name detected: " + name);
            }
        }

        public static List<Programm> getProgrammeWithNameContainingOrNull(String namePart)
        {
            if (namePart == null || namePart.Length == 0) return null;
            var programmeQueryResult = from p in HodorGlobals.getHodorContext().Programms.Where(p => p.Name.Contains(namePart)) select p;

            return programmeQueryResult.ToList<Programm>();
        }
    }
}