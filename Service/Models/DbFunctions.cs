using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Diagnostics;
using System.Linq;

namespace PgmD.Service.Models {

    /// <summary>
    /// </summary>
    public class DbFunctions {

		/// <summary>
		/// </summary>
		/// <param name="setting"></param>
		/// <param name="value">  </param>
		public static List<ApplicationConfiguration> GetApplicationConfiguration(string setting, string value) {
			List<ApplicationConfiguration> list = null;
			var entities = new PgmDEntities();
			try {
				list = entities.ApplicationConfigurations.Where(p => p.Name == setting && (p.Value == value || string.IsNullOrEmpty(value))).ToList();
			} catch (Exception ex) {
				entities.uspInsertApplicationLogInfo(
				PgmDContext.Current.BemsId,
				$"{"PgmD.Service.Data.DBFunctions"}.{new StackFrame().GetMethod().Name}",
				ex.Message,
				ex.StackTrace
				);
			}
			return list;
		}

		/// <summary>
		/// Notes: cannot convert to entityframework because of dynamic results
		/// </summary>
		/// <param name="context">       </param>
		/// <param name="hierarchy">     </param>
		/// <param name="hierClass">     </param>
		/// <param name="oeList">        </param>
		/// <param name="excStatusList"> </param>
		/// <param name="roleAppList">   </param>
		/// <param name="roleList">      </param>
		/// <param name="userList">      </param>
		/// <param name="userSourceList"></param>
		/// <param name="expiredType">   </param>
		/// <param name="expiredDate">   </param>
		/// <param name="error">         </param>
		/// <returns></returns>
		public DataTable GetAc(
		string context,
		string hierarchy,
		string hierClass,
		string oeList,
		string excStatusList,
		string roleAppList,
		string roleList,
		string userList,
		string userSourceList,
		string expiredType,
		string expiredDate,
		ref string error
		) {
			DataTable dataTable = null;
			try {
				var sqlCommand = new SqlCommand("uspGetAccessControlInfo", GetSqlConnection()) {
					CommandType = CommandType.StoredProcedure
				};
				sqlCommand.Parameters.Add("@context", SqlDbType.VarChar, 50).Value = context;
				sqlCommand.Parameters.Add("@hierarchyName", SqlDbType.VarChar, 255).Value = hierarchy;
				sqlCommand.Parameters.Add("@requestedVersion", SqlDbType.Int).Value = null;
				sqlCommand.Parameters.Add("@root", SqlDbType.Int).Value = null;
				sqlCommand.Parameters.Add("@classificationType", SqlDbType.VarChar, 50).Value = hierClass;
				sqlCommand.Parameters.Add("@sortOrderType", SqlDbType.VarChar, 50).Value = "Position";
				sqlCommand.Parameters.Add("@oeList", SqlDbType.VarChar).Value = oeList=="" ? (object)DBNull.Value : oeList;
				sqlCommand.Parameters.Add("@excludeStatusList", SqlDbType.VarChar, 255).Value = excStatusList;
				sqlCommand.Parameters.Add("@roleAppIdList", SqlDbType.VarChar, 255).Value = roleAppList;
				sqlCommand.Parameters.Add("@roleIdList", SqlDbType.VarChar, 255).Value = roleList;
				sqlCommand.Parameters.Add("@userIdList", SqlDbType.VarChar).Value = userList == "" ? (object)DBNull.Value : userList; 
				sqlCommand.Parameters.Add("@userSourceList", SqlDbType.VarChar).Value = userSourceList;
				sqlCommand.Parameters.Add("@expiredType", SqlDbType.VarChar, 10).Value = expiredType;
				sqlCommand.Parameters.Add("@expiredDate", SqlDbType.DateTime).Value = Convert.ToDateTime(expiredDate);
				sqlCommand.Parameters.Add("@userId", SqlDbType.VarChar, 50).Value = PgmDContext.Current.BemsId;
				sqlCommand.Parameters.Add("@userSourceSystem", SqlDbType.VarChar, 50).Value = "EDS";
				dataTable = GetSqlDataTable(sqlCommand);
			} catch (Exception ex) {
				var entities = new PgmDEntities();
				var currentMethod = $"{GetType().FullName}.{new StackFrame().GetMethod().Name}";
				if (error != "") {
					entities.uspInsertApplicationLogInfo(PgmDContext.Current.BemsId, currentMethod, error, error);
				}
				entities.uspInsertApplicationLogInfo(PgmDContext.Current.BemsId, currentMethod, ex.Message, ex.StackTrace);
			}
			return dataTable;
		}

		/// <summary>
		/// </summary>
		/// <param name="context">          </param>
		/// <param name="hierarchy">        </param>
		/// <param name="versionId">        </param>
		/// <param name="root">             </param>
		/// <param name="hierClass">        </param>
		/// <param name="orderType">        </param>
		/// <param name="filterType">       </param>
		/// <param name="filterValue">      </param>
		/// <param name="includeLabelList"> </param>
		/// <param name="excludeStatusList"></param>
		/// <param name="appList">          </param>
		/// <param name="userId">           </param>
		/// <param name="userSourceSystem"> </param>
		/// <param name="oeRole">           </param>
		/// <param name="error">            </param>
		/// <returns></returns>
		public DataTable GetHierarchy(
		string context,
		string hierarchy,
		int? versionId,
		int? root,
		string hierClass,
		string orderType,
		int filterType,
		string filterValue,
		string includeLabelList,
		string excludeStatusList,
		string appList,
		string userId,
		string userSourceSystem,
		string oeRole,
		ref string error
		) {
			DataTable dataTable = null;
			try {
				var sqlCommand = new SqlCommand("uspGetHierarchy", GetSqlConnection()) {
					CommandType = CommandType.StoredProcedure
				};
				sqlCommand.Parameters.Add("@context", SqlDbType.VarChar, 50).Value = context;
				sqlCommand.Parameters.Add("@hierarchyName", SqlDbType.VarChar, 255).Value = hierarchy;
				sqlCommand.Parameters.Add("@requestedVersion", SqlDbType.Int).Value = versionId;
				sqlCommand.Parameters.Add("@root", SqlDbType.Int).Value = root;
				sqlCommand.Parameters.Add("@classificationType", SqlDbType.VarChar, 50).Value = hierClass;
				sqlCommand.Parameters.Add("@sortOrderType", SqlDbType.VarChar, 50).Value = orderType;
				sqlCommand.Parameters.Add("@filterType", SqlDbType.Int).Value = filterType;
				sqlCommand.Parameters.Add("@filterValue", SqlDbType.VarChar, 50).Value = filterValue;
				sqlCommand.Parameters.Add("@includeLabelList", SqlDbType.VarChar, 1024).Value = includeLabelList;
				sqlCommand.Parameters.Add("@excludeStatusList", SqlDbType.VarChar, 255).Value = excludeStatusList;
				sqlCommand.Parameters.Add("@appNameList", SqlDbType.VarChar).Value = appList;
				sqlCommand.Parameters.Add("@userId", SqlDbType.VarChar, 50).Value = userId;
				sqlCommand.Parameters.Add("@userSourceSystem", SqlDbType.VarChar, 50).Value = userSourceSystem;
				sqlCommand.Parameters.Add("@oeRole", SqlDbType.VarChar, 50).Value = oeRole;
				//null oeRole indicates that any PgmD role is not needed
				dataTable = GetSqlDataTable(sqlCommand);
			} catch (Exception ex) {
				var entities = new PgmDEntities();
				var currentMethod = $"{GetType().FullName}.{new StackFrame().GetMethod().Name}";
				if (error != "") {
					entities.uspInsertApplicationLogInfo(PgmDContext.Current.BemsId, currentMethod, error, error);
				}
				entities.uspInsertApplicationLogInfo(PgmDContext.Current.BemsId, currentMethod, ex.Message, ex.StackTrace);
			}
			return dataTable;
		}

		/// <summary>
		/// </summary>
		/// <returns></returns>
		public SqlConnection GetSqlConnection() {
			SqlConnection con = null;
			try {
				using (var pdc = new PgmDEntities()) {
					con = new SqlConnection(pdc.Database.Connection.ConnectionString);
					if (con.State != ConnectionState.Open) con.Open();
				}
			} catch (Exception ex) {
				new PgmDEntities().uspInsertApplicationLogInfo(PgmDContext.Current.BemsId,
					$"{GetType().FullName}.{new StackFrame().GetMethod().Name}", ex.Message, ex.StackTrace);
			}
			return con;
		}

		/// <summary>
		/// </summary>
		public DataTable GetSqlDataTable(SqlCommand sqlCommand) {
			var dataTable = new DataTable();
			try {
				dataTable.Load(sqlCommand.ExecuteReader());
			} catch (Exception ex) {
				new PgmDEntities().uspInsertApplicationLogInfo(PgmDContext.Current.BemsId,
					$"{GetType().FullName}.{new StackFrame().GetMethod().Name}", ex.Message, ex.StackTrace);
			} finally {
				sqlCommand.Connection.Close();
			}
			return dataTable;
		}
	}
}