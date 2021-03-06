﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace HODOR
{
    public partial class Startseite : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }

        protected void MenuLink_Command(object sender, CommandEventArgs e)
        {
            string viewName = e.CommandName + "View";

            View newView = this.StartseiteMultiView.FindControl(viewName) as View;

            if (newView != null)
            {
                this.StartseiteMultiView.SetActiveView(newView);
            }
        }
    }
}
