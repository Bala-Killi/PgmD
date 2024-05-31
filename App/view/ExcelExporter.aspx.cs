using ClosedXML.Excel;
using Newtonsoft.Json;
using PgmD.App.controller;
using PgmD.Service.Models;
using System;
using System.Diagnostics;
using System.IO;
using System.Web;
using System.Web.UI;

namespace PgmD.App.view {

    /// <summary>
    /// </summary>
    public partial class ExcelExporter : Page {

		/// <summary>
		/// </summary>
		/// <param name="sender"></param>
		/// <param name="e"></param>
		protected void Page_Error(object sender, EventArgs e) {
			Exception x = Server.GetLastError();
			if (!(x is HttpRequestValidationException)) {
				return;
			}

			Utilities.CatchException(new StackFrame(), x);
			Response.StatusCode = 200;
			Response.End();
		}

		/// <summary>
		/// </summary>
		/// <param name="sender"></param>
		/// <param name="e"></param>
		protected void Page_Load(object sender, EventArgs e) {
			HttpResponse httpResponse = HttpContext.Current.Response;
			httpResponse.Clear();
			try {
				string fileName = "";
				string message = "";
				string action = Utilities.GetParamString("action");
				string context = Utilities.GetParamString("context");
				string hierarchy = Utilities.GetParamString("hierarchy");
				string hierclass = Utilities.GetParamString("hierClass");
				string oeList = Utilities.GetParamString("oeList");
				string userList = Utilities.GetParamString("userList");
				string userSourceList = Utilities.GetParamString("userSourceList");
				DbFunctions dbf = new DbFunctions();
				XLWorkbook workbook = new XLWorkbook();
				switch (action.ToLower()) {
					case "accesscontrol":	//*
						string excStatusList = Utilities.GetParamString("excludeStatusList");
						string roleAppList = Utilities.GetParamString("roleAppList");
						string roleList = Utilities.GetParamString("roleList");
						string expiredType = Utilities.GetParamString("expiredType");
						string expiredDate = Utilities.GetParamString("expiredDate");
						ExcelExport.CreateAccessControlWorksheet(ref workbook, dbf.GetAc(context, hierarchy, hierclass, oeList, excStatusList, roleAppList, roleList, userList, userSourceList, expiredType, expiredDate, ref message));
						fileName = $"AccessControlExport{DateTime.Today.ToString("yyyyMMdd")}.xlsx";
						break;
				}
				httpResponse.ContentType = "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet";
				httpResponse.AddHeader("content-disposition", $"attachment;filename=\"{fileName}\"");
				using (MemoryStream memoryStream = new MemoryStream()) {
					workbook.SaveAs(memoryStream);
					memoryStream.WriteTo(httpResponse.OutputStream);
				}
			} catch (Exception ex) {
				Utilities.CatchException(new StackFrame(), ex);
				httpResponse.ContentType = "application/json; charset=utf-8";
				httpResponse.Write(JsonConvert.SerializeObject(new {
					success = false,
					message = "Error Occurred: Please contact application support"
				}));
				httpResponse.End();
			}
		}
	}
}