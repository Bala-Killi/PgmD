using PgmD.App.controller;
using PgmD.Service.Models;
using System;
using System.Web;

namespace PgmD.App {
    public partial class Default : System.Web.UI.Page {
		protected int? AcWarningPeriod;
		protected string Bemsid;
		protected object Data;
		protected string InitApp;
		protected string InitFunction;
		protected string InitTab;
		protected string IsAdmin;

		protected Default() {
			Data = null;
			InitFunction = null;
			Bemsid = null;
		}
		protected object PrivMask { get; private set; }
		protected void Page_Error(object sender, EventArgs e) {
			var ex = Server.GetLastError();
			if (!(ex is HttpRequestValidationException)) return;
			new PgmDEntities().uspInsertApplicationLogInfo(
				Service.PgmDContext.Current.BemsId,
				string.Format($"{0}.{1}", GetType().FullName, new System.Diagnostics.StackFrame().GetMethod().Name),
				ex.Message,
				ex.StackTrace
				);
			const string resMsg = "<html><body><span style='font-size: 14pt; color: red; text-align: center;'>Embeded Script detected in your input. Please clean up your input and try to submit again<br /></span></body></html>";
			Response.Write(resMsg);
			Response.StatusCode = 200;
			Response.End();
		}

		protected void Page_Load(object sender, EventArgs e) {
			IsAdmin = Service.PgmDContext.Current.IsAdmin ? "true" : "false";
			Bemsid = Service.PgmDContext.Current.BemsId;
			PrivMask = new {
				defaultUserPriv = Service.PgmDContext.Current.DefaultUserPriv,
				grantMask = Service.PgmDContext.Current.GrantMask,
				hierarchyEditMask = Service.PgmDContext.Current.HierarchyEditMask,
				metadataReadMask = Service.PgmDContext.Current.MetadataReadMask,
				metadataWriteMask = Service.PgmDContext.Current.MetadataWriteMask,
				restrictedReadMask = Service.PgmDContext.Current.RestrictedReadMask,
				restrictedWriteMask = Service.PgmDContext.Current.RestrictedWriteMask,
				unrestrictedReadMask = Service.PgmDContext.Current.UnrestrictedReadMask,
				unrestrictedWriteMask = Service.PgmDContext.Current.UnrestrictedWriteMask
			};
			AcWarningPeriod = Service.PgmDContext.Current.AcWarningPeriod;
			InitTab = Utilities.GetParamString("initTab", "tbHome");
			InitApp = Utilities.GetParamString("initApp");
			InitFunction = Utilities.GetParamString("initFunction");
			var entity = new PgmDEntities();
			Data = new {
				App = entity.uspGetAppPrivAttributes("Boeing Program Hierarchy"),
				AppRoles = entity.uspGetAppRolePrivs("Boeing Program Hierarchy")
			};
		}
	}
}