using PgmD.Service.Models;
using System;
using System.Configuration;
using System.Threading;
using System.Web;

namespace PgmD.Service {

    /// <summary>
    /// Represents a PgmDContext
    /// </summary>
    public class PgmDContext {
		private readonly HttpContext _context = HttpContext.Current;

		/// <summary>
		/// Creates a new instance of the PgmDContext class
		/// </summary>
		private PgmDContext() {
			GetEnvironmentInfo(_context?.Request.ServerVariables["SERVER_NAME"].ToLower() ?? "BatchJob");
		}

		/// <summary>
		/// Gets an instance of the PgmDContext, which can be used to retrieve information about
		/// current context.
		/// </summary>
		public static PgmDContext Current {
			get {
				if (HttpContext.Current == null) {
					var data = Thread.GetData(Thread.GetNamedDataSlot("PgmDContext"));
					if (data != null) {
						return (PgmDContext)data;
					}
					var context = new PgmDContext();
					Thread.SetData(Thread.GetNamedDataSlot("PgmDContext"), context);
					return context;
				}
				if (HttpContext.Current.Items["PgmDContext"] == null) {
					var context = new PgmDContext();
					HttpContext.Current.Items.Add("PgmDContext", context);
					return context;
				}
				return (PgmDContext)HttpContext.Current.Items["PgmDContext"];
			}
		}

		/// <summary>
		/// Gets or sets the default user privileges
		/// </summary>
		public int? AcWarningPeriod { get; private set; }

		/// <summary>
		/// Gets or sets the current user bemsId
		/// </summary>
		public string BemsId { get; private set; }

		/// <summary>
		/// Gets or sets the default user privileges
		/// </summary>
		public int? DefaultUserPriv { get; private set; }

		/// <summary>
		/// Gets or sets the grant priv mask
		/// </summary>
		public int? GrantMask { get; private set; }

		/// <summary>
		/// Gets or sets the hierarchy edit priv mask
		/// </summary>
		public int? HierarchyEditMask { get; private set; }

		/// <summary>
		/// Gets or sets the admin priv for the user
		/// </summary>
		public bool IsAdmin { get; private set; }

		/// <summary>
		/// Gets or sets the metadata read priv mask
		/// </summary>
		public int? MetadataReadMask { get; private set; }

		/// <summary>
		/// Gets or sets the metadata write priv mask
		/// </summary>
		public int? MetadataWriteMask { get; private set; }

		/// <summary>
		/// Gets or sets the restricted read priv mask
		/// </summary>
		public int? RestrictedReadMask { get; private set; }

		/// <summary>
		/// Gets or sets the restricted write priv mask
		/// </summary>
		public int? RestrictedWriteMask { get; private set; }

		/// <summary>
		/// Gets or sets the unrestricted read priv mask
		/// </summary>
		public int? UnrestrictedReadMask { get; private set; }

		/// <summary>
		/// Gets or sets the unrestricted write priv mask
		/// </summary>
		public int? UnrestrictedWriteMask { get; private set; }

		/// <summary>
		/// Gets or sets an object item in the context by the specified key.
		/// </summary>
		/// <param name="key">The key of the value to get.</param>
		/// <returns>The value associated with the specified key.</returns>
		// ReSharper disable once UnusedMember.Global
		public object this[string key] {
			get {
				if (_context?.Items[key] != null) {
					return _context.Items[key];
				}
				return null;
			}
			set {
				if (_context != null) {
					_context.Items.Remove(key);
					_context.Items.Add(key, value);
				}
			}
		}

		/// <summary>
		///
		/// </summary>
		/// <param name="serverName"></param>
		private void GetEnvironmentInfo(string serverName) {
			BemsId = ConfigurationManager.AppSettings["LocalBemsId"];
			IsAdmin = BemsId != null && BemsId.Trim() != "" && DbFunctions.GetApplicationConfiguration("Administrator", BemsId).Count == 1;
			GrantMask = Convert.ToInt32(DbFunctions.GetApplicationConfiguration("GrantMask", null)[0].Value);
			HierarchyEditMask = Convert.ToInt32(DbFunctions.GetApplicationConfiguration("HierarchyEditMask", null)[0].Value);
			MetadataReadMask = Convert.ToInt32(DbFunctions.GetApplicationConfiguration("MetadataReadMask", null)[0].Value);
			MetadataWriteMask = Convert.ToInt32(DbFunctions.GetApplicationConfiguration("MetadataWriteMask", null)[0].Value);
			RestrictedReadMask = Convert.ToInt32(DbFunctions.GetApplicationConfiguration("RestrictedReadMask", null)[0].Value);
			RestrictedWriteMask = Convert.ToInt32(DbFunctions.GetApplicationConfiguration("RestrictedWriteMask", null)[0].Value);
			UnrestrictedReadMask = Convert.ToInt32(DbFunctions.GetApplicationConfiguration("UnrestrictedReadMask", null)[0].Value);
			UnrestrictedWriteMask = Convert.ToInt32(DbFunctions.GetApplicationConfiguration("UnrestrictedWriteMask", null)[0].Value);
			DefaultUserPriv = Convert.ToInt32(DbFunctions.GetApplicationConfiguration("DefaultUserPriv", null)[0].Value);
			AcWarningPeriod = Convert.ToInt32(DbFunctions.GetApplicationConfiguration("acWarningPeriod", null)[0].Value);
		}
	}
}