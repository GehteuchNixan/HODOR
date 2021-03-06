﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using HODOR.src.Globals;

namespace HODOR.src.DAO
{
    public class BuildDAO
    {
        public static Build createAndGetBuild(Subrelease subreleaseOfBuild, DateTime buildDate, Int32 buildNumber)
        {
            subreleaseOfBuild.ProgrammReference.Load();
            Int32 programmID = subreleaseOfBuild.ProgrammReference.Value.ProgrammID;
            Build build = Build.CreateBuild(programmID, buildDate, buildNumber, subreleaseOfBuild.ReleaseID);

            HodorGlobals.getHodorContext().Releases.AddObject(build);
            HodorGlobals.save();

            return build;
        }

        public static Build createAndGetBuild(Subrelease subreleaseOfBuild, Int32 buildNumber)
        {
            return createAndGetBuild(subreleaseOfBuild, DateTime.Now, buildNumber);
        }

        public static Build createAndGetBuild(Subrelease subreleaseOfBuild)
        {
            Int32 nextBuildNumber = getNextBuildNumberFor(subreleaseOfBuild);
            return createAndGetBuild(subreleaseOfBuild, nextBuildNumber);
        }

        public static void deleteBuild(Build build)
        {
            HODOR_entities db = HodorGlobals.getHodorContext();

            List<Download_History> historyEntries = build.Download_History.ToList<Download_History>();

            foreach (Download_History historyEntry in historyEntries)
            {
                db.Download_History.DeleteObject(historyEntry);
            }

            db.Releases.DeleteObject(build);

            HodorGlobals.save();
        }

        public static Int32 getNextBuildNumberFor(Subrelease sub)
        {
            //sub.Builds.Load();

            Int32 highestCurrentBuild;
            HODOR_entities db = HodorGlobals.getHodorContext();

            IQueryable<Release> queryResult = db.Releases.OfType<Build>()
                                                            .Where(b => b.BuildVonSubrelease == sub.ReleaseID);
            if (queryResult.Count() == 0)
            {
                return 0;
            }
            else
            {
                highestCurrentBuild = queryResult.Max(r => r.Releasenummer);
            }

            Int32 nextBuildNumber = highestCurrentBuild + 1;
            return nextBuildNumber;
        }
    }
}