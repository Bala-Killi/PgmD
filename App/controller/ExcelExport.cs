using ClosedXML.Excel;
using System;
using System.Collections.Generic;
using System.Data;
using System.Diagnostics;
using System.Linq;
using System.Web;

namespace PgmD.App.controller {

    /// <summary>
    /// Generate excel file from data table
    /// </summary>
    public static class ExcelExport {

		/// <summary>
		/// </summary>
		private const double MaxWidth = 50.0;

		/// <summary>
		/// </summary>
		private const double MinWidth = 10.0;

		/// <summary>
		/// </summary>
		/// <param name="workbook"> </param>
		/// <param name="dataTable"></param>
		/// <returns></returns>
		public static void CreateAccessControlWorksheet(ref XLWorkbook workbook, DataTable dataTable) {
			try {
				if (workbook == null) {
					throw new ArgumentNullException(nameof(workbook));
				}

				IXLWorksheet worksheet = workbook.Worksheets.Add("Access Controls");
				worksheet.Style.Alignment.Vertical = XLAlignmentVerticalValues.Top;
				string[] header = new[]{
					"ORGANIZATION",
					"APPLICATION",
					"ROLE",
					"USER",
					"BEMS ID",
					"EXPIRATION",
					"REASON",
					"LAST MODIFIED BY",
					"ORG STATUS",
					"ORG ID",
					"BREADCRUMB"
				};
				int row = 1;
				AddQueryString(ref worksheet, ref row, header.Length);
				worksheet.Range(row, 1, row, header.Length).Merge().SetValue("Record Count:  " + dataTable.Rows.Count);
				row += 2;
				int headerRow = row;
				worksheet.Cell(row, 1).InsertData(new List<string[]>{
					header
				}).Style = SetStyle("th");
				// Format the header
				worksheet.SheetView.FreezeRows(row);
				foreach (DataRow dataRow in dataTable.Rows) {
					int col = 1;
					row += 1;
					worksheet.Cell(row, col++).SetValue(string.Join(" ", new string[Convert.ToInt32(dataRow["Generation"]) * 6 + 1]) + (dataRow["Abbreviation"] == DBNull.Value ? dataRow["Name"].ToString().Replace("'", "\\'") : dataRow["Abbreviation"].ToString().Replace("\"", "\\\"")));
					worksheet.Cell(row, col++).SetValue(dataRow["AppDisplayName"]);
					worksheet.Cell(row, col++).SetValue(dataRow["RoleName"]);
					worksheet.Cell(row, col++).SetValue(dataRow["DisplayName"]);
					worksheet.Cell(row, col++).SetValue(dataRow["Bemsid"]);
					worksheet.Cell(row, col++).SetValue(dataRow["ExpirationDate"]);
					worksheet.Cell(row, col++).SetValue(dataRow["Reason"]);
					worksheet.Cell(row, col++).SetValue(string.IsNullOrEmpty(dataRow["ModBemsId"].ToString()) ? "" :
						$"{dataRow["ModName"]} ({dataRow["ModBemsId"]})");
					worksheet.Cell(row, col++).SetValue(dataRow["Status"]);
					worksheet.Cell(row, col++).SetValue(dataRow["Node"]);
					worksheet.Cell(row, col).SetValue(dataRow["AbbreviationBreadCrumb"]);
				}
				worksheet.Range(headerRow, 1, headerRow + dataTable.Rows.Count, header.Length).RangeUsed().SetAutoFilter();
				worksheet.Columns().AdjustToContents(1, MinWidth, MaxWidth);
			} catch (Exception ex) {
				Utilities.CatchException(new StackFrame(), ex);
			}
		}

		/// <summary>
		/// </summary>
		/// <param name="worksheet"></param>
		/// <param name="row">      </param>
		/// <param name="length">   </param>
		private static void AddQueryString(ref IXLWorksheet worksheet, ref int row, int length = 10) {
			try {
				System.Collections.Specialized.NameValueCollection paramList = HttpContext.Current.Request.HttpMethod.ToLower() == "post" ? HttpContext.Current.Request.Form : HttpContext.Current.Request.QueryString;
				worksheet.Range(row, 1, row, length).Merge().SetValue($"Date: {DateTime.Now}");
				row += 1;
				foreach (
					string key in paramList.AllKeys.Where(key => !string.IsNullOrEmpty(paramList[key]))) {
					switch (key.ToLower()) {
						case "contractlist":
							worksheet.Range(row, 1, row, length).Merge().SetValue($"Contract List: {paramList[key]}");
							row += 1;
							break;

						case "customerlist":
							worksheet.Range(row, 1, row, length).Merge().SetValue($"Customer List: {paramList[key]}");
							row += 1;
							break;

						case "deputylist":
							worksheet.Range(row, 1, row, length).Merge().SetValue($"Deputy List: {paramList[key]}");
							row += 1;
							break;

						case "engineerlist":
							worksheet.Range(row, 1, row, length).Merge().SetValue($"Engineer List: {paramList[key]}");
							row += 1;
							break;

						case "excludestatuslist":
							worksheet.Range(row, 1, row, length).Merge().SetValue($"Excluded Status List: {paramList[key]}");
							row += 1;
							break;

						case "expireddate":
							worksheet.Range(row, 1, row, length).Merge().SetValue($"As of Date: {paramList[key]}");
							row += 1;
							break;

						case "fa":
							worksheet.Range(row, 1, row, length).Merge().SetValue($"Application(s): {paramList[key]}");
							row += 1;
							break;

						case "fal":
							worksheet.Range(row, 1, row, length).Merge().SetValue($"Change Attributes: {paramList[key]}");
							row += 1;
							break;

						case "fc":
							worksheet.Range(row, 1, row, length).Merge().SetValue($"Contracts: {paramList[key]}");
							row += 1;
							break;

						case "fcl":
							worksheet.Range(row, 1, row, length).Merge().SetValue($"Comparison Categories: {paramList[key]}");
							row += 1;
							break;

						case "fcust":
							worksheet.Range(row, 1, row, length).Merge().SetValue($"Customer(s): {paramList[key]}");
							row += 1;
							break;

						case "ffp":
							worksheet.Range(row, 1, row, length).Merge().SetValue($"Focus Program: {paramList[key]}");
							row += 1;
							break;

						case "fido":
							worksheet.Range(row, 1, row, length).Merge().SetValue($"Identified By: {paramList[key]}");
							row += 1;
							break;

						case "fl":
							worksheet.Range(row, 1, row, length).Merge().SetValue($"Org Type(s): {paramList[key]}");
							row += 1;
							break;

						case "fnv":
							worksheet.Range(row, 1, row, length).Merge().SetValue($"New Version: {paramList[key]}");
							row += 1;
							break;

						case "fo":
							worksheet.Range(row, 1, row, length).Merge().SetValue($"Organization(s): {HttpUtility.UrlDecode(paramList[key])}");
							row += 1;
							break;

						case "focusprog":
							worksheet.Range(row, 1, row, length).Merge().SetValue($"Focus Program: {paramList[key]}");
							row += 1;
							break;

						case "fov":
							worksheet.Range(row, 1, row, length).Merge().SetValue($"Old Version: {paramList[key]}");
							row += 1;
							break;

						case "fpt":
							worksheet.Range(row, 1, row, length).Merge().SetValue($"Prog Type(s): {paramList[key]}");
							row += 1;
							break;

						case "fpv":
							worksheet.Range(row, 1, row, length).Merge().SetValue($"Prog Values: {paramList[key]}");
							row += 1;
							break;

						case "fr":
							worksheet.Range(row, 1, row, length).Merge().SetValue($"Role(s): {paramList[key]}");
							row += 1;
							break;

						case "fs":
							worksheet.Range(row, 1, row, length).Merge().SetValue($"Status Type(s): {paramList[key]}");
							row += 1;
							break;

						case "fu":
							worksheet.Range(row, 1, row, length).Merge().SetValue($"Prog Manager(s): {paramList[key]}");
							row += 1;
							break;

						case "fv":
							worksheet.Range(row, 1, row, length).Merge().SetValue($"Visibility: {paramList[key]}");
							row += 1;
							break;

						case "idorglist":
							worksheet.Range(row, 1, row, length).Merge().SetValue($"Organization ID List: {paramList[key]}");
							row += 1;
							break;

						case "labellist":
							worksheet.Range(row, 1, row, length).Merge().SetValue($"Label List: {paramList[key]}");
							row += 1;
							break;
						case "orgdetaillist":
							worksheet.Range(row, 1, row, length).Merge().SetValue($"Org. Detail List: {paramList[key]}");
							row += 1;
							break;
						case "node":
							worksheet.Range(row, 1, row, length).Merge().SetValue($"Node: {paramList[key]}");
							row += 1;
							break;

						case "role":
							worksheet.Range(row, 1, row, length).Merge().SetValue($"Role: {paramList[key]}");
							row += 1;
							break;

						case "seitlist":
							worksheet.Range(row, 1, row, length).Merge().SetValue($"SEIT List: {paramList[key]}");
							row += 1;
							break;
						case "piolist":
							worksheet.Range(row, 1, row, length).Merge().SetValue($"PIO List: {paramList[key]}");
							row += 1;
							break;
						case "iptlist":
							worksheet.Range(row, 1, row, length).Merge().SetValue($"IPT List: {paramList[key]}");
							row += 1;
							break;
						case "lcphaselist":
							worksheet.Range(row, 1, row, length).Merge().SetValue($"Life Cycle Phase List: {paramList[key]}");
							row += 1;
							break;
						case "esgpList":
							worksheet.Range(row, 1, row, length).Merge().SetValue($"ESGP List: {paramList[key]}");
							row += 1;
							break;
						case "jobcode":
							worksheet.Range(row, 1, row, length).Merge().SetValue($"Job Code: {paramList[key]}");
							row += 1;
							break;
						case "userlist":
							worksheet.Range(row, 1, row, length).Merge().SetValue($"User List: {paramList[key]}");
							row += 1;
							break;

						case "usersourcelist":
							worksheet.Range(row, 1, row, length).Merge().SetValue($"User Source List: {paramList[key]}");
							row += 1;
							break;

						case "visibilitylist":
							worksheet.Range(row, 1, row, length).Merge().SetValue($"Visibility List: {paramList[key]}");
							row += 1;
							break;
						case "od":
							worksheet.Range(row, 1, row, length).Merge().SetValue($"Org. Detail(s): {paramList[key]}");
							row += 1;
							break;
						case "lcp":
							worksheet.Range(row, 1, row, length).Merge().SetValue($"Life Cycle Phase(s): {paramList[key]}");
							row += 1;
							break;
						case "esgp":
							worksheet.Range(row, 1, row, length).Merge().SetValue($"ESGP(s): {paramList[key]}");
							row += 1;
							break;
						case "action":
							break;

						case "attributelist":
							break;

						case "categorylist":
							break;

						case "colorder":
							break;

						case "context":
							break;

						case "expiredtype":
							break;

						case "ffal":
							break;

						case "hierarchy":
							break;

						case "hierclass":
							break;

						case "lineagetype":
							break;

						case "newversion":
							break;

						case "oefiltertype":
							break;

						case "oelist":
							break;

						case "oldversion":
							break;

						case "programtypelist":
							break;

						case "programvaluelist":
							break;

						case "roleapplist":
							break;

						case "rolelist":
							break;

						case "rootlist":
							break;

						case "statusfiltertype":
							break;

						case "statuslist":
							break;

						default:
							worksheet.Range(row, 1, row, length).Merge().SetValue($"{key}: {paramList[key]}");
							row += 1;
							break;
					}
				}
			} catch (Exception ex) {
				Utilities.CatchException(new StackFrame(), ex);
			}
		}

		/// <summary>
		/// </summary>
		/// <param name="styleName"></param>
		/// <returns></returns>
		private static IXLStyle SetStyle(string styleName) {
			XLWorkbook workbook = new XLWorkbook();
			IXLStyle style = workbook.Style;
			try {
				if (styleName == null) {
					throw new ArgumentNullException(nameof(styleName));
				}

				switch (styleName.ToLower()) {
					case "th":
						style.Alignment.Horizontal = XLAlignmentHorizontalValues.Center;
						style.Alignment.Vertical = XLAlignmentVerticalValues.Bottom;
						style.Alignment.WrapText = true;
						style.Border.TopBorder = XLBorderStyleValues.Thin;
						style.Border.TopBorderColor = XLColor.Black;
						style.Border.RightBorder = XLBorderStyleValues.Thin;
						style.Border.RightBorderColor = XLColor.Black;
						style.Border.BottomBorder = XLBorderStyleValues.Thin;
						style.Border.BottomBorderColor = XLColor.Black;
						style.Border.LeftBorder = XLBorderStyleValues.Thin;
						style.Border.LeftBorderColor = XLColor.Black;
						style.Border.InsideBorder = XLBorderStyleValues.Thin;
						style.Border.InsideBorderColor = XLColor.Black;
						style.Fill.BackgroundColor = XLColor.LightGray;
						style.Font.Bold = true;
						break;
				}
			} catch (Exception ex) {
				Utilities.CatchException(new StackFrame(), ex);
			}
			return style;
		}
	}
}