using Newtonsoft.Json;
using PgmD.App.controller;
using PgmD.Service;
using PgmD.Service.Controllers;
using PgmD.Service.Models;
using System;
using System.Collections.Generic;
using System.Data;
using System.Diagnostics;
using System.Linq;
using System.Web;
using System.Web.UI;

namespace PgmD.App.view {

	/// <summary>
	///
	/// </summary>
	public partial class GetContent : Page {

		/// <summary>
		///
		/// </summary>
		private string _message = "";

		/// <summary>
		///
		/// </summary>
		/// <param name="sender"></param>
		/// <param name="e"></param>
		protected void Page_Error(object sender, EventArgs e) {
			Exception ex = Server.GetLastError();
			if (ex is HttpRequestValidationException) {
				Utilities.CatchException(new StackFrame(), ex);
				Response.Write("<span style='font-size:14pt; color:red; text-align:center;'>Embedded Script detected in your input. Please clean up your input and try to submit again<br /></span>");
				Response.StatusCode = 200;
				Response.End();
			}
		}

		/// <summary>
		///
		/// </summary>
		/// <param name="sender"></param>
		/// <param name="e"></param>
		protected void Page_Load(object sender, EventArgs e) {
			string respondJson = "";
			try {
				switch (Utilities.GetParamString("action").ToLower()) {
					case "createac":
						respondJson = CreateAc();
						break;

					case "deleteac":
						respondJson = DeleteAc();
						break;

					case "getac":
						respondJson = GetAc();
						break;

					case "gethiertree":
						respondJson = GetHierTree();
						break;

					case "getpersoneds":
						respondJson = GetPersonEds();
						break;

                    case "getpersondb":
                        respondJson = GetPersonDb();
                        break;

                    case "updateac":
						respondJson = UpdateAc();
						break;
				}
				if (string.IsNullOrEmpty(respondJson)) {
					respondJson = JsonConvert.SerializeObject(new {
						msg = "Error Occurred: Please contact application support",
						success = false
					});
				}
			} catch (Exception ex) {
				Utilities.CatchException(new StackFrame(), ex);
				respondJson = JsonConvert.SerializeObject(new {
					msg = ex.Message,
					success = false
				});
			}
			Response.Clear();
			Response.ContentType = "application/json; charset=utf-8";
			Response.Write(respondJson);
			Response.End();
		}

		/// <summary>
		/// </summary>
		/// <returns>JSON string</returns>
		private static string BuildHierTree(ICollection<DataRow> rows, DataTable dt, bool expParent, bool activeOnly) {
			string respondJson = "undefined";
			try {
				if (rows != null) {
					if (rows.Count == 0) {
						respondJson = "null";
					} else {
						respondJson = "[";
						int rowCount = 1;
						foreach (DataRow dr in rows) {
							bool isDraggable = false;
							bool isDroppable = false;
							bool isLeaf = dr["IsLeaf"].ToString() == "1";
							object shortName = dr["Abbreviation"] == DBNull.Value ? dr["Name"] : dr["Abbreviation"];
							string appPrivileges = "{";
							for (int i = 1; i < Convert.ToInt32(dr["AppCount"]) + 1; i++) {
								string appName = dr["AppName" + Convert.ToString(i)].ToString();
								appPrivileges += i == 1 ? "" : ", ";
								appPrivileges += appName + ":" + JsonConvert.SerializeObject(new {
									appName,
									appId = dr["AppID" + Convert.ToString(i)],
									privileges = dr["Privileges" + Convert.ToString(i)]
								});
								// Update PgmD privilege based attributes
								if (appName == "PgmD") {
									isDraggable = (PgmDContext.Current.HierarchyEditMask & Convert.ToInt32(dr["Privileges" + Convert.ToString(i)])) == PgmDContext.Current.HierarchyEditMask && dr["SubhierarchyName"] == DBNull.Value && dr["SubhierarchyContext"] == DBNull.Value;
									isDroppable = (PgmDContext.Current.HierarchyEditMask & Convert.ToInt32(dr["Privileges" + Convert.ToString(i)])) == PgmDContext.Current.HierarchyEditMask;
								}
							}
							appPrivileges += "}";
							respondJson += rowCount > 1 ? ", " : "";
							respondJson += JsonConvert.SerializeObject(new {
								allowDrop = isDroppable,
								cls = $"{dr["Status"]}" == "Inactive" ? "x-tree-node-disabled" : "",
								draggable = isDraggable,
								expanded = isLeaf | expParent,
								hidden = $"{dr["Status"]}" == "Inactive" && activeOnly,
								iconCls = "icon" + dr["Label"].ToString().Replace(" ", ""),
								id = dr["Node"],
								leaf = false,
								loaded = isLeaf,
								qtip = dr["Name"],
								text = shortName,
								abbreviation = $"{dr["Abbreviation"]}",
								alias = $"{dr["Alias"]}",
								ancestry = dr["Ancestry"],
								appPrivileges = JsonConvert.DeserializeObject(appPrivileges),
								breadcrumb = dr["AbbreviationBreadCrumb"],
								deputyBemsId = dr["DeputyBemsId"],
								deputyDisplayName = dr["DeputyDisplayName"],
								deputySjc = $"{dr["DeputySjc"]}",
								pioBemsId = dr["PioBemsId"],
								pioDisplayName = dr["PioDisplayName"],
								pioSjc = $"{dr["PioSjc"]}",
								iptBemsId = dr["IptBemsId"],
								iptDisplayName = dr["IptDisplayName"],
								iptSjc = $"{dr["IptSjc"]}",
								description = dr["Description"],
								engineerBemsId = dr["EngineerBemsId"],
								engineerDisplayName = dr["EngineerDisplayName"],
								seitBemsId = dr["SeitBemsId"],
								seitDisplayName = dr["SeitDisplayName"],
								externalSortPos = dr["ExternalSortPosition"],
								internalSortPos = dr["InternalSortPosition"],
								label = dr["Label"],
								orgdetail = $"{dr["OrgDetail"]}",
								oe = $"[{dr["Node"]}, '{shortName}']",
								ohid = dr["Root"],
								parent = dr["Parent"],
								parentHierarchy = new {
									context = dr["ParentContext"],
									name = dr["ParentHierarchyName"],
									root = dr["ParentRoot"],
									version = dr["ParentVersionID"]
								},
								pmBemsId = dt.Columns.Contains("PMBemsid") ? dr["PMBemsid"] : null,
								pmDisplayName = dt.Columns.Contains("PMDisplayName") ? dr["PMDisplayName"] : null,
								pmSource = dt.Columns.Contains("PMSource") ? dr["PMSource"] : null,
								pmTitle = dt.Columns.Contains("PMTitle") ? $"{dr["PMTitle"]}" : null,
								pmSjc = dt.Columns.Contains("PMSjc") ? $"{dr["PMSjc"]}" : null,
								pmUniqueDN = dt.Columns.Contains("PMBemsid") && dr["PMBemsid"] != DBNull.Value ?
									$"{dr["PMDisplayName"]} ({dr["PMBemsid"]})"
									: "",
								position = dr["Position"],
								status = dr["Status"],
								subHierarchy = new {
									context = dr["SubhierarchyContext"],
									name = dr["SubhierarchyName"],
									root = dr["SubhierarchyRoot"],
									version = dr["SubhierarchyVersionID"]
								},
								children = JsonConvert.DeserializeObject(BuildHierTree(dt.Select($"[Parent] = '{dr["Node"]}'"), dt, expParent, activeOnly))
							});
							rowCount++;
						}
						respondJson += "]";
					}
				}
			} catch (Exception ex) {
				Utilities.CatchException(new StackFrame(), ex);
			}
			return respondJson;
		}

		/// <summary>
		/// </summary>
		/// <returns>JSON string</returns>
		private static string CreateAc() {
			string respondJson = "";
			try {
				string context = Utilities.GetParamString("context");
				int? root = Utilities.GetParamInt("root");
				int? oeId = Utilities.GetParamInt("oeId");
				int? appId = Utilities.GetParamInt("appId");
				int? roleId = Utilities.GetParamInt("roleId");
				DateTime? expiredDate = Utilities.GetParamDateTime("expiredDate");
				string reason = Utilities.GetParamString("reason");
				string bemsId = Utilities.GetParamString("bemsId");
				string source = "EDS"; //Utilities.GetParamString("source");
				string displayName = Utilities.GetParamString("displayName");
				string lastName = Utilities.GetParamString("lastName");
				string firstName = Utilities.GetParamString("firstName");
				string middle = Utilities.GetParamString("middle");
				string email = Utilities.GetParamString("email");
				string phone = Utilities.GetParamString("phone");
				string dept = Utilities.GetParamString("dept");
				string usPerson = Utilities.GetParamString("usPerson");
				string boeingEmp = Utilities.GetParamString("boeingEmp");

				// Check for duplicate
				if (!new PgmDEntities().HierarchicalACs.Any(a => a.Context == context && a.Root == root && a.Node == oeId
					&& a.Grantee == bemsId && a.AppID == appId && a.RoleTypeID == roleId)) {

					uspUpdateAC_Result result = new PgmDEntities().uspUpdateAC("create", context, root, oeId, appId, roleId, expiredDate, reason, bemsId, source, displayName, lastName, firstName, middle, email, phone, dept, usPerson, boeingEmp, PgmDContext.Current.BemsId, "EDS").First();
					respondJson = JsonConvert.SerializeObject(new {
						data = result,
						msg = "",
						success = result.ErrCode == 0
					});
				} else {
					respondJson = JsonConvert.SerializeObject(new {
						data = "[]",
						msg = "User with the same role already exists.",
						success = false
					});
				}
			} catch (Exception ex) {
				Utilities.CatchException(new StackFrame(), ex);
			}
			return respondJson;
		}

		/// <summary>
		/// </summary>
		/// <returns>JSON string</returns>
		private static string DeleteAc() {
			string respondJson = "";
			try {
				int? result = new PgmDEntities().uspDeleteAC(
					Utilities.GetParamString("context"),
					Utilities.GetParamInt("root"),
					Utilities.GetParamInt("oeId"),
					Utilities.GetParamInt("appId"),
					Utilities.GetParamInt("roleId"),
					Utilities.GetParamString("bemsId"),
					"EDS"//Utilities.GetParamString("source")
					).First();
				respondJson = JsonConvert.SerializeObject(new {
					errCode = result,
					msg = result == 0 ? "Deleted" : "Error in privilege deletion",
					success = result == 0
				});
			} catch (Exception ex) {
				Utilities.CatchException(new StackFrame(), ex);
			}
			return respondJson;
		}

		/// <summary>
		/// Call by 'Get Privs' button of 'Access Manager' tab
		/// </summary>
		/// <returns>JSON string</returns>
		private string GetAc() {
			string respondJson = "";
			try {
				string context = Utilities.GetParamString("context");
				string hierarchy = Utilities.GetParamString("hierarchy");
				string hierClass = Utilities.GetParamString("hierClass");
				string oeList = Utilities.GetParamString("oeList");
				string excStatusList = Utilities.GetParamString("excludeStatusList");
				string roleAppList = Utilities.GetParamString("roleAppList");
				string roleList = Utilities.GetParamString("roleList");
				string userList = Utilities.GetParamString("userList");
				string userSourceList = Utilities.GetParamString("userSourceList");
				string expiredType = Utilities.GetParamString("expiredType");
				string expiredDate = Utilities.GetParamString("expiredDate");
				DataTable dt = new DbFunctions().GetAc(context, hierarchy, hierClass, oeList, excStatusList, roleAppList, roleList, userList, userSourceList, expiredType, expiredDate, ref _message);
				if (dt != null && dt.Rows.Count > 0) {
					respondJson = "{\"data\":[";
					int rowCount = 1;
					foreach (DataRow dr in dt.Rows) {
						int appCount = dr["AppCount"] == DBNull.Value ? Convert.ToInt32(0) : Convert.ToInt32(dr["AppCount"]);
						int hideGroupAdd = 1;
						int hideRowDelete = 1;
						int rolePrivs = dr["Privileges"] == DBNull.Value ? Convert.ToInt32(0) : Convert.ToInt32(dr["Privileges"]);
						string appPrivs = "{";
						for (int i = 1; i < appCount + 1; i++) {
							string apAppName = dr["AppName" + Convert.ToString(i)].ToString();
							object apAppId = dr["AppID" + Convert.ToString(i)];
							int aggregatePriv = dr["AggregateAppPriv" + Convert.ToString(i)] == DBNull.Value ? Convert.ToInt32(0) : Convert.ToInt32(dr["AggregateAppPriv" + Convert.ToString(i)]);
							int appGrantPrivMask = dr["GrantPrivilegeMask" + Convert.ToString(i)] == DBNull.Value ? Convert.ToInt32(0) : Convert.ToInt32(dr["GrantPrivilegeMask" + Convert.ToString(i)]);
							int grantPriv = (aggregatePriv & appGrantPrivMask) == appGrantPrivMask ? 1 : 0;
							appPrivs += i == 1 ? "" : ", ";
							appPrivs += apAppName + ":" + JsonConvert.SerializeObject(new {
								aggregatePriv,
								appId = apAppId,
								appName = apAppName,
								grantPriv
							});
							hideGroupAdd = grantPriv == 1 && ("," + roleAppList + ",").Replace(" ", "").IndexOf("," + apAppId + ",", StringComparison.Ordinal) != -1 ? 0 : hideGroupAdd;
							hideRowDelete = grantPriv == 1 && (aggregatePriv & rolePrivs) == rolePrivs && dr["AppID"].ToString() == apAppId.ToString() ? 0 : hideRowDelete;
						}
						appPrivs += "}";
						respondJson += rowCount > 1 ? "," : "";
						respondJson += JsonConvert.SerializeObject(new {
							appDisplayName = dr["AppDisplayName"],
							appId = dr["AppID"],
							appName = dr["AppName"],
							appPrivileges = JsonConvert.DeserializeObject(appPrivs),
							expiredDate = dr["ExpirationDate"],
							generation = dr["Generation"],
							hideGroupAdd,
							hideRowDelete,
							longName = dr["Name"],
							modID = dr["ModBemsid"],
							modName = dr["ModName"],
							oeId = dr["Node"],
							reason = dr["Reason"],
							root = dr["Root"],
							roleId = dr["RoleTypeID"],
							roleName = dr["RoleName"],
							shortName = dr["Abbreviation"] == DBNull.Value ? dr["Name"] : dr["Abbreviation"],
							sortBC = dr["AbbreviationBreadCrumb"],
							userId = dr["Bemsid"],
							userName = dr["DisplayName"],
							userSource = dr["GranteeSourceSystem"]
						});
						rowCount++;
					}
					respondJson += "], \"msg\":\"\", \"success\":true, \"total\":" + dt.Rows.Count + "}";
				}
			} catch (Exception ex) {
				Utilities.CatchException(new StackFrame(), ex);
			}
			return respondJson;
		}

		/// <summary>
		/// </summary>
		/// <returns>JSON string</returns>
		private string GetHierTree() {
			string respondJson = "";
			try {
				string context = Utilities.GetParamString("context");
				string excludeStatusList = Utilities.GetParamString("excludeStatusList");
				string hierarchy = Utilities.GetParamString("hierarchy");
				string hierClass = Utilities.GetParamString("hierClass");
				string filter = Utilities.GetParamString("filter");
				string labelList = Utilities.GetParamString("labelList");
				string role = Utilities.GetParamString("role");
				int? versionId = Utilities.GetParamInt("version");
				bool expandParent = !string.IsNullOrEmpty(filter);
				bool reload = Utilities.GetParamString("reload") == "true";

				if (reload || Session["PgmDTreeData"] == null) {
					DataTable dataTable = new DbFunctions().GetHierarchy(context, hierarchy, versionId, null, hierClass, "Position", 0, filter, labelList, null, null, PgmDContext.Current.BemsId, "EDS", role, ref _message);
					if (dataTable != null && string.IsNullOrEmpty(_message)) {
						DataRow[] dataRows = dataTable.Select("[Parent] IS NULL");
						respondJson = BuildHierTree(dataRows, dataTable, expandParent, excludeStatusList == "Inactive");
						Session["PgmDTreeData"] = respondJson;
					}
				} else {
					respondJson = $"{Session["PgmDTreeData"]}";
				}
			} catch (Exception ex) {
				Utilities.CatchException(new StackFrame(), ex);
			}
			return respondJson;
		}

		/// <summary>
		/// </summary>
		/// <returns>JSON string</returns>
		private string GetPersonDb() {
			string respondJson = "";
			try {
				System.Data.Entity.Core.Objects.ObjectResult<uspGetPersonnel_Result> result = new PgmDEntities().uspGetPersonnel(Utilities.GetParamString("query"), Utilities.GetParamString("filterBy"), Utilities.GetParamString("filterSource"));
				respondJson = JsonConvert.SerializeObject(new {
					data = result,
					msg = "",
					success = true
				});
			} catch (Exception ex) {
				Utilities.CatchException(new StackFrame(), ex);
			}
			return respondJson;
		}

		/// <summary>
		/// </summary>
		/// <returns>JSON string</returns>
		private string GetPersonEds() {
			string respondJson = "";
			try {
				respondJson = JsonConvert.SerializeObject(new {
					data = new BoeingDirectory().Search(Utilities.GetParamString("query"), Utilities.GetParamString("filterBy")),
					msg = "",
					success = true
				});
			} catch (Exception ex) {
				Utilities.CatchException(new StackFrame(), ex);
			}
			return respondJson;
		}

		/// <summary>
		/// </summary>
		/// <returns>JSON string</returns>
		private string UpdateAc() {
			string respondJson = "";
			try {
				string context = Utilities.GetParamString("context");
				int? root = Utilities.GetParamInt("root");
				int? oeId = Utilities.GetParamInt("oeId");
				int? appId = Utilities.GetParamInt("appId");
				int? roleId = Utilities.GetParamInt("roleId");
				DateTime? expiredDate = Utilities.GetParamDateTime("expiredDate");
				string reason = Utilities.GetParamString("reason");
				string bemsId = Utilities.GetParamString("bemsId");
				string source = "EDS"; //Utilities.GetParamString("source");
				uspUpdateAC_Result result = new PgmDEntities().uspUpdateAC("update", context, root, oeId, appId, roleId, expiredDate, reason, bemsId, source, null, null, null, null, null, null, null, null, null, PgmDContext.Current.BemsId, "EDS").First();
				respondJson = JsonConvert.SerializeObject(new {
					data = result,
					msg = "",
					success = result.ErrCode == 0
				});
			} catch (Exception ex) {
				Utilities.CatchException(new StackFrame(), ex);
			}
			return respondJson;
		}
	}
}