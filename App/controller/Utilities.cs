using PgmD.Service;
using PgmD.Service.Models;
using System;
using System.Data;
using System.Diagnostics;
using System.Text.RegularExpressions;
using System.Web;
using System.Web.Security.AntiXss;

namespace PgmD.App.controller {

    /// <summary>
    ///
    /// </summary>
    public static class Utilities {

		/// <summary>
		///
		/// </summary>
		/// <param name="sf"></param>
		/// <param name="ex"></param>
		public static void CatchException(StackFrame sf, Exception ex) {
			new PgmDEntities().uspInsertApplicationLogInfo(PgmDContext.Current.BemsId,
				$"{sf.GetType().FullName}.{sf.GetMethod().Name}", ex.Message, ex.StackTrace);
		}

		/// <summary>
		/// </summary>
		/// <param name="name"></param>
		/// <param name="defaultValue"></param>
		/// <returns></returns>
		public static DateTime? GetParamDateTime(string name, DateTime? defaultValue = null) {
			var value = defaultValue;
			try {
				var paramList = HttpContext.Current.Request.HttpMethod.ToLower() == "post"
					? HttpContext.Current.Request.Form
					: HttpContext.Current.Request.QueryString;
				if (!string.IsNullOrEmpty(paramList[name])) {
					if (DateTime.TryParse(paramList[name], out DateTime outValue)) {
						value = outValue;
					}
				}
			} catch (Exception ex) {
				CatchException(new StackFrame(), ex);
			}

			return value;
		}

		/// <summary>
		/// </summary>
		/// <param name="name"></param>
		/// <param name="defaultValue"></param>
		/// <returns></returns>
		public static int? GetParamInt(string name, int? defaultValue = null) {
			var value = defaultValue;
			try {
				var paramList = HttpContext.Current.Request.HttpMethod.ToLower() == "post"
					? HttpContext.Current.Request.Form
					: HttpContext.Current.Request.QueryString;
				if (!string.IsNullOrEmpty(paramList[name])) {
					if (int.TryParse(paramList[name], out int outValue)) {
						value = outValue;
					}
				}
			} catch (Exception ex) {
				CatchException(new StackFrame(), ex);
			}
			return value;
		}

		/// <summary>
		/// </summary>
		/// <param name="name"></param>
		/// <param name="defaultValue"></param>
		/// <param name="nullIfEmpty"></param>
		/// <returns></returns>
		public static string GetParamString(string name, string defaultValue = null, Boolean nullIfEmpty = true) {
			var value = defaultValue;
			try {
				var paramList = HttpContext.Current.Request.HttpMethod.ToLower() == "post"
					? HttpContext.Current.Request.Form
					: HttpContext.Current.Request.QueryString;
				if (!nullIfEmpty || !string.IsNullOrEmpty(paramList[name])) {
					value = StringSanitize(paramList[name]);
				}
			} catch (Exception ex) {
				CatchException(new StackFrame(), ex);
			}
			return value;
		}

		/// <summary>
		/// </summary>
		/// <param name="value"></param>
		/// <returns></returns>
		private static string StringSanitize(string value) {
			if (!string.IsNullOrEmpty(value))
			{
				var returnString = value;
				returnString = Regex.Replace(returnString, @"<script [^>]*>[\s\S]*?</script>", string.Empty);
				returnString = returnString.Replace("&amp;", "&");
				returnString = returnString.Replace("&amp", "&");
				returnString = returnString.Replace("\"", string.Empty);
				returnString = returnString.Replace("../", string.Empty);
				returnString = returnString.Replace("\\", string.Empty);
				returnString = returnString.Replace("--", string.Empty);
				return AntiXssEncoder.HtmlEncode(returnString, false);
			}
			else
			{
				return value;
			}
		}

		private static void SelectParent(DataTable mainTable, int nodeId, ref DataTable parents) {
			try {
				var row = mainTable.Select($"[Node] = {nodeId}")[0];
				parents.ImportRow(row);
				if ($"{row["Parent"]}" != "") {
					SelectParent(mainTable,
						$"{row["Parent"]}" == "" ? 0 : Convert.ToInt32(row["Parent"]),
						ref parents);
				} 
			} catch (Exception ex) {
				CatchException(new StackFrame(), ex);
			}
		}
	}
}