﻿//------------------------------------------------------------------------------
// <auto-generated>
//     This code was generated from a template.
//
//     Manual changes to this file may cause unexpected behavior in your application.
//     Manual changes to this file will be overwritten if the code is regenerated.
// </auto-generated>
//------------------------------------------------------------------------------

namespace PgmD.Service.Models
{
    using System;
    using System.Data.Entity;
    using System.Data.Entity.Infrastructure;
    using System.Data.Entity.Core.Objects;
    using System.Linq;
    
    public partial class PgmDEntities : DbContext
    {
        public PgmDEntities()
            : base("name=PgmDEntities")
        {
        }
    
        protected override void OnModelCreating(DbModelBuilder modelBuilder)
        {
            throw new UnintentionalCodeFirstException();
        }
    
        public virtual DbSet<ApplicationConfiguration> ApplicationConfigurations { get; set; }
        public virtual DbSet<HierarchicalAC> HierarchicalACs { get; set; }
        public virtual DbSet<ApplicationLogInfo> ApplicationLogInfoes { get; set; }
        public virtual DbSet<ApplicationPrivilegeAttribute> ApplicationPrivilegeAttributes { get; set; }
        public virtual DbSet<Application> Applications { get; set; }
        public virtual DbSet<Hierarchy> Hierarchies { get; set; }
        public virtual DbSet<HierarchyVersion> HierarchyVersions { get; set; }
        public virtual DbSet<OERolePersonnel> OERolePersonnels { get; set; }
        public virtual DbSet<OrgEntity> OrgEntities { get; set; }
        public virtual DbSet<Personnel> Personnels { get; set; }
        public virtual DbSet<RoleTypePrivilege> RoleTypePrivileges { get; set; }
        public virtual DbSet<RoleType> RoleTypes { get; set; }
        public virtual DbSet<Subhierarchy> Subhierarchies { get; set; }
        public virtual DbSet<HierarchyNode> HierarchyNodes { get; set; }
    
        public virtual int uspInsertApplicationLogInfo(string userId, string processName, string errorMessage, string traceInfo)
        {
            var userIdParameter = userId != null ?
                new ObjectParameter("userId", userId) :
                new ObjectParameter("userId", typeof(string));
    
            var processNameParameter = processName != null ?
                new ObjectParameter("processName", processName) :
                new ObjectParameter("processName", typeof(string));
    
            var errorMessageParameter = errorMessage != null ?
                new ObjectParameter("errorMessage", errorMessage) :
                new ObjectParameter("errorMessage", typeof(string));
    
            var traceInfoParameter = traceInfo != null ?
                new ObjectParameter("traceInfo", traceInfo) :
                new ObjectParameter("traceInfo", typeof(string));
    
            return ((IObjectContextAdapter)this).ObjectContext.ExecuteFunction("uspInsertApplicationLogInfo", userIdParameter, processNameParameter, errorMessageParameter, traceInfoParameter);
        }
    
        public virtual int uspUpdatePersonnel(string bemsId, string source, string displayName, string lastName, string firstName, string middle, string email, string phone, string dept, string usPerson, string boeingEmp, string city, string state, string country, string jobcode)
        {
            var bemsIdParameter = bemsId != null ?
                new ObjectParameter("bemsId", bemsId) :
                new ObjectParameter("bemsId", typeof(string));
    
            var sourceParameter = source != null ?
                new ObjectParameter("source", source) :
                new ObjectParameter("source", typeof(string));
    
            var displayNameParameter = displayName != null ?
                new ObjectParameter("displayName", displayName) :
                new ObjectParameter("displayName", typeof(string));
    
            var lastNameParameter = lastName != null ?
                new ObjectParameter("lastName", lastName) :
                new ObjectParameter("lastName", typeof(string));
    
            var firstNameParameter = firstName != null ?
                new ObjectParameter("firstName", firstName) :
                new ObjectParameter("firstName", typeof(string));
    
            var middleParameter = middle != null ?
                new ObjectParameter("middle", middle) :
                new ObjectParameter("middle", typeof(string));
    
            var emailParameter = email != null ?
                new ObjectParameter("email", email) :
                new ObjectParameter("email", typeof(string));
    
            var phoneParameter = phone != null ?
                new ObjectParameter("phone", phone) :
                new ObjectParameter("phone", typeof(string));
    
            var deptParameter = dept != null ?
                new ObjectParameter("dept", dept) :
                new ObjectParameter("dept", typeof(string));
    
            var usPersonParameter = usPerson != null ?
                new ObjectParameter("usPerson", usPerson) :
                new ObjectParameter("usPerson", typeof(string));
    
            var boeingEmpParameter = boeingEmp != null ?
                new ObjectParameter("boeingEmp", boeingEmp) :
                new ObjectParameter("boeingEmp", typeof(string));
    
            var cityParameter = city != null ?
                new ObjectParameter("city", city) :
                new ObjectParameter("city", typeof(string));
    
            var stateParameter = state != null ?
                new ObjectParameter("state", state) :
                new ObjectParameter("state", typeof(string));
    
            var countryParameter = country != null ?
                new ObjectParameter("country", country) :
                new ObjectParameter("country", typeof(string));
    
            var jobcodeParameter = jobcode != null ?
                new ObjectParameter("jobcode", jobcode) :
                new ObjectParameter("jobcode", typeof(string));
    
            return ((IObjectContextAdapter)this).ObjectContext.ExecuteFunction("uspUpdatePersonnel", bemsIdParameter, sourceParameter, displayNameParameter, lastNameParameter, firstNameParameter, middleParameter, emailParameter, phoneParameter, deptParameter, usPersonParameter, boeingEmpParameter, cityParameter, stateParameter, countryParameter, jobcodeParameter);
        }
    
        public virtual ObjectResult<uspGetPersonnel_Result> uspGetPersonnel(string filterVal, string filterBy, string filterSource)
        {
            var filterValParameter = filterVal != null ?
                new ObjectParameter("filterVal", filterVal) :
                new ObjectParameter("filterVal", typeof(string));
    
            var filterByParameter = filterBy != null ?
                new ObjectParameter("filterBy", filterBy) :
                new ObjectParameter("filterBy", typeof(string));
    
            var filterSourceParameter = filterSource != null ?
                new ObjectParameter("filterSource", filterSource) :
                new ObjectParameter("filterSource", typeof(string));
    
            return ((IObjectContextAdapter)this).ObjectContext.ExecuteFunction<uspGetPersonnel_Result>("uspGetPersonnel", filterValParameter, filterByParameter, filterSourceParameter);
        }
    
        public virtual ObjectResult<Nullable<int>> uspDeleteAC(string context, Nullable<int> root, Nullable<int> oeId, Nullable<int> appId, Nullable<int> roleId, string bemsId, string source)
        {
            var contextParameter = context != null ?
                new ObjectParameter("context", context) :
                new ObjectParameter("context", typeof(string));
    
            var rootParameter = root.HasValue ?
                new ObjectParameter("root", root) :
                new ObjectParameter("root", typeof(int));
    
            var oeIdParameter = oeId.HasValue ?
                new ObjectParameter("oeId", oeId) :
                new ObjectParameter("oeId", typeof(int));
    
            var appIdParameter = appId.HasValue ?
                new ObjectParameter("appId", appId) :
                new ObjectParameter("appId", typeof(int));
    
            var roleIdParameter = roleId.HasValue ?
                new ObjectParameter("roleId", roleId) :
                new ObjectParameter("roleId", typeof(int));
    
            var bemsIdParameter = bemsId != null ?
                new ObjectParameter("bemsId", bemsId) :
                new ObjectParameter("bemsId", typeof(string));
    
            var sourceParameter = source != null ?
                new ObjectParameter("source", source) :
                new ObjectParameter("source", typeof(string));
    
            return ((IObjectContextAdapter)this).ObjectContext.ExecuteFunction<Nullable<int>>("uspDeleteAC", contextParameter, rootParameter, oeIdParameter, appIdParameter, roleIdParameter, bemsIdParameter, sourceParameter);
        }
    
        public virtual ObjectResult<uspUpdateAC_Result> uspUpdateAC(string type, string context, Nullable<int> root, Nullable<int> oeId, Nullable<int> appId, Nullable<int> roleId, Nullable<System.DateTime> expiredDate, string reason, string bemsId, string source, string displayName, string lastName, string firstName, string middle, string email, string phone, string dept, string usPerson, string boeingEmp, string userId, string userSourceSystem)
        {
            var typeParameter = type != null ?
                new ObjectParameter("type", type) :
                new ObjectParameter("type", typeof(string));
    
            var contextParameter = context != null ?
                new ObjectParameter("context", context) :
                new ObjectParameter("context", typeof(string));
    
            var rootParameter = root.HasValue ?
                new ObjectParameter("root", root) :
                new ObjectParameter("root", typeof(int));
    
            var oeIdParameter = oeId.HasValue ?
                new ObjectParameter("oeId", oeId) :
                new ObjectParameter("oeId", typeof(int));
    
            var appIdParameter = appId.HasValue ?
                new ObjectParameter("appId", appId) :
                new ObjectParameter("appId", typeof(int));
    
            var roleIdParameter = roleId.HasValue ?
                new ObjectParameter("roleId", roleId) :
                new ObjectParameter("roleId", typeof(int));
    
            var expiredDateParameter = expiredDate.HasValue ?
                new ObjectParameter("expiredDate", expiredDate) :
                new ObjectParameter("expiredDate", typeof(System.DateTime));
    
            var reasonParameter = reason != null ?
                new ObjectParameter("reason", reason) :
                new ObjectParameter("reason", typeof(string));
    
            var bemsIdParameter = bemsId != null ?
                new ObjectParameter("bemsId", bemsId) :
                new ObjectParameter("bemsId", typeof(string));
    
            var sourceParameter = source != null ?
                new ObjectParameter("source", source) :
                new ObjectParameter("source", typeof(string));
    
            var displayNameParameter = displayName != null ?
                new ObjectParameter("displayName", displayName) :
                new ObjectParameter("displayName", typeof(string));
    
            var lastNameParameter = lastName != null ?
                new ObjectParameter("lastName", lastName) :
                new ObjectParameter("lastName", typeof(string));
    
            var firstNameParameter = firstName != null ?
                new ObjectParameter("firstName", firstName) :
                new ObjectParameter("firstName", typeof(string));
    
            var middleParameter = middle != null ?
                new ObjectParameter("middle", middle) :
                new ObjectParameter("middle", typeof(string));
    
            var emailParameter = email != null ?
                new ObjectParameter("email", email) :
                new ObjectParameter("email", typeof(string));
    
            var phoneParameter = phone != null ?
                new ObjectParameter("phone", phone) :
                new ObjectParameter("phone", typeof(string));
    
            var deptParameter = dept != null ?
                new ObjectParameter("dept", dept) :
                new ObjectParameter("dept", typeof(string));
    
            var usPersonParameter = usPerson != null ?
                new ObjectParameter("usPerson", usPerson) :
                new ObjectParameter("usPerson", typeof(string));
    
            var boeingEmpParameter = boeingEmp != null ?
                new ObjectParameter("boeingEmp", boeingEmp) :
                new ObjectParameter("boeingEmp", typeof(string));
    
            var userIdParameter = userId != null ?
                new ObjectParameter("userId", userId) :
                new ObjectParameter("userId", typeof(string));
    
            var userSourceSystemParameter = userSourceSystem != null ?
                new ObjectParameter("userSourceSystem", userSourceSystem) :
                new ObjectParameter("userSourceSystem", typeof(string));
    
            return ((IObjectContextAdapter)this).ObjectContext.ExecuteFunction<uspUpdateAC_Result>("uspUpdateAC", typeParameter, contextParameter, rootParameter, oeIdParameter, appIdParameter, roleIdParameter, expiredDateParameter, reasonParameter, bemsIdParameter, sourceParameter, displayNameParameter, lastNameParameter, firstNameParameter, middleParameter, emailParameter, phoneParameter, deptParameter, usPersonParameter, boeingEmpParameter, userIdParameter, userSourceSystemParameter);
        }
    
        public virtual ObjectResult<uspGetAppPrivAttributes_Result> uspGetAppPrivAttributes(string context)
        {
            var contextParameter = context != null ?
                new ObjectParameter("context", context) :
                new ObjectParameter("context", typeof(string));
    
            return ((IObjectContextAdapter)this).ObjectContext.ExecuteFunction<uspGetAppPrivAttributes_Result>("uspGetAppPrivAttributes", contextParameter);
        }
    
        public virtual ObjectResult<uspGetAppRolePrivs_Result> uspGetAppRolePrivs(string context)
        {
            var contextParameter = context != null ?
                new ObjectParameter("context", context) :
                new ObjectParameter("context", typeof(string));
    
            return ((IObjectContextAdapter)this).ObjectContext.ExecuteFunction<uspGetAppRolePrivs_Result>("uspGetAppRolePrivs", contextParameter);
        }
    
        public virtual int uspGetHierarchy(string context, string hierarchyName, Nullable<int> requestedVersion, Nullable<int> root, string classificationType, string sortOrderType, Nullable<byte> filterType, string filterValue, string includeLabelList, string excludeStatusList, string appNameList, string userId, string userSourceSystem, string oeRole, Nullable<byte> includeApp)
        {
            var contextParameter = context != null ?
                new ObjectParameter("context", context) :
                new ObjectParameter("context", typeof(string));
    
            var hierarchyNameParameter = hierarchyName != null ?
                new ObjectParameter("hierarchyName", hierarchyName) :
                new ObjectParameter("hierarchyName", typeof(string));
    
            var requestedVersionParameter = requestedVersion.HasValue ?
                new ObjectParameter("requestedVersion", requestedVersion) :
                new ObjectParameter("requestedVersion", typeof(int));
    
            var rootParameter = root.HasValue ?
                new ObjectParameter("root", root) :
                new ObjectParameter("root", typeof(int));
    
            var classificationTypeParameter = classificationType != null ?
                new ObjectParameter("classificationType", classificationType) :
                new ObjectParameter("classificationType", typeof(string));
    
            var sortOrderTypeParameter = sortOrderType != null ?
                new ObjectParameter("sortOrderType", sortOrderType) :
                new ObjectParameter("sortOrderType", typeof(string));
    
            var filterTypeParameter = filterType.HasValue ?
                new ObjectParameter("filterType", filterType) :
                new ObjectParameter("filterType", typeof(byte));
    
            var filterValueParameter = filterValue != null ?
                new ObjectParameter("filterValue", filterValue) :
                new ObjectParameter("filterValue", typeof(string));
    
            var includeLabelListParameter = includeLabelList != null ?
                new ObjectParameter("includeLabelList", includeLabelList) :
                new ObjectParameter("includeLabelList", typeof(string));
    
            var excludeStatusListParameter = excludeStatusList != null ?
                new ObjectParameter("excludeStatusList", excludeStatusList) :
                new ObjectParameter("excludeStatusList", typeof(string));
    
            var appNameListParameter = appNameList != null ?
                new ObjectParameter("appNameList", appNameList) :
                new ObjectParameter("appNameList", typeof(string));
    
            var userIdParameter = userId != null ?
                new ObjectParameter("userId", userId) :
                new ObjectParameter("userId", typeof(string));
    
            var userSourceSystemParameter = userSourceSystem != null ?
                new ObjectParameter("userSourceSystem", userSourceSystem) :
                new ObjectParameter("userSourceSystem", typeof(string));
    
            var oeRoleParameter = oeRole != null ?
                new ObjectParameter("oeRole", oeRole) :
                new ObjectParameter("oeRole", typeof(string));
    
            var includeAppParameter = includeApp.HasValue ?
                new ObjectParameter("IncludeApp", includeApp) :
                new ObjectParameter("IncludeApp", typeof(byte));
    
            return ((IObjectContextAdapter)this).ObjectContext.ExecuteFunction("uspGetHierarchy", contextParameter, hierarchyNameParameter, requestedVersionParameter, rootParameter, classificationTypeParameter, sortOrderTypeParameter, filterTypeParameter, filterValueParameter, includeLabelListParameter, excludeStatusListParameter, appNameListParameter, userIdParameter, userSourceSystemParameter, oeRoleParameter, includeAppParameter);
        }
    
        [DbFunction("PgmDEntities", "udfGetExpandedHierarchy")]
        public virtual IQueryable<udfGetExpandedHierarchy_Result> udfGetExpandedHierarchy(string context, string hierarchyName, Nullable<int> requestedVersion, Nullable<int> root, string classificationType)
        {
            var contextParameter = context != null ?
                new ObjectParameter("context", context) :
                new ObjectParameter("context", typeof(string));
    
            var hierarchyNameParameter = hierarchyName != null ?
                new ObjectParameter("hierarchyName", hierarchyName) :
                new ObjectParameter("hierarchyName", typeof(string));
    
            var requestedVersionParameter = requestedVersion.HasValue ?
                new ObjectParameter("requestedVersion", requestedVersion) :
                new ObjectParameter("requestedVersion", typeof(int));
    
            var rootParameter = root.HasValue ?
                new ObjectParameter("root", root) :
                new ObjectParameter("root", typeof(int));
    
            var classificationTypeParameter = classificationType != null ?
                new ObjectParameter("classificationType", classificationType) :
                new ObjectParameter("classificationType", typeof(string));
    
            return ((IObjectContextAdapter)this).ObjectContext.CreateQuery<udfGetExpandedHierarchy_Result>("[PgmDEntities].[udfGetExpandedHierarchy](@context, @hierarchyName, @requestedVersion, @root, @classificationType)", contextParameter, hierarchyNameParameter, requestedVersionParameter, rootParameter, classificationTypeParameter);
        }
    
        [DbFunction("PgmDEntities", "udfGetFullHierarchy")]
        public virtual IQueryable<udfGetFullHierarchy_Result> udfGetFullHierarchy(string context, string hierarchyName, Nullable<int> requestedVersion, Nullable<int> root, string classificationType, string sortOrderType)
        {
            var contextParameter = context != null ?
                new ObjectParameter("context", context) :
                new ObjectParameter("context", typeof(string));
    
            var hierarchyNameParameter = hierarchyName != null ?
                new ObjectParameter("hierarchyName", hierarchyName) :
                new ObjectParameter("hierarchyName", typeof(string));
    
            var requestedVersionParameter = requestedVersion.HasValue ?
                new ObjectParameter("requestedVersion", requestedVersion) :
                new ObjectParameter("requestedVersion", typeof(int));
    
            var rootParameter = root.HasValue ?
                new ObjectParameter("root", root) :
                new ObjectParameter("root", typeof(int));
    
            var classificationTypeParameter = classificationType != null ?
                new ObjectParameter("classificationType", classificationType) :
                new ObjectParameter("classificationType", typeof(string));
    
            var sortOrderTypeParameter = sortOrderType != null ?
                new ObjectParameter("sortOrderType", sortOrderType) :
                new ObjectParameter("sortOrderType", typeof(string));
    
            return ((IObjectContextAdapter)this).ObjectContext.CreateQuery<udfGetFullHierarchy_Result>("[PgmDEntities].[udfGetFullHierarchy](@context, @hierarchyName, @requestedVersion, @root, @classificationType, @sortOrderType)", contextParameter, hierarchyNameParameter, requestedVersionParameter, rootParameter, classificationTypeParameter, sortOrderTypeParameter);
        }
    
        [DbFunction("PgmDEntities", "udfParseColumnString")]
        public virtual IQueryable<udfParseColumnString_Result> udfParseColumnString(string cSV_String, string deliChar)
        {
            var cSV_StringParameter = cSV_String != null ?
                new ObjectParameter("CSV_String", cSV_String) :
                new ObjectParameter("CSV_String", typeof(string));
    
            var deliCharParameter = deliChar != null ?
                new ObjectParameter("DeliChar", deliChar) :
                new ObjectParameter("DeliChar", typeof(string));
    
            return ((IObjectContextAdapter)this).ObjectContext.CreateQuery<udfParseColumnString_Result>("[PgmDEntities].[udfParseColumnString](@CSV_String, @DeliChar)", cSV_StringParameter, deliCharParameter);
        }
    
        public virtual int uspGetAccessControlInfo(string context, string hierarchyName, Nullable<int> requestedVersion, Nullable<int> root, string classificationType, string sortOrderType, string oeList, string excludeStatusList, string roleAppIdList, string roleIdList, string userIdList, string userSourceList, string expiredType, Nullable<System.DateTime> expiredDate, string userId, string userSourceSystem)
        {
            var contextParameter = context != null ?
                new ObjectParameter("context", context) :
                new ObjectParameter("context", typeof(string));
    
            var hierarchyNameParameter = hierarchyName != null ?
                new ObjectParameter("hierarchyName", hierarchyName) :
                new ObjectParameter("hierarchyName", typeof(string));
    
            var requestedVersionParameter = requestedVersion.HasValue ?
                new ObjectParameter("requestedVersion", requestedVersion) :
                new ObjectParameter("requestedVersion", typeof(int));
    
            var rootParameter = root.HasValue ?
                new ObjectParameter("root", root) :
                new ObjectParameter("root", typeof(int));
    
            var classificationTypeParameter = classificationType != null ?
                new ObjectParameter("classificationType", classificationType) :
                new ObjectParameter("classificationType", typeof(string));
    
            var sortOrderTypeParameter = sortOrderType != null ?
                new ObjectParameter("sortOrderType", sortOrderType) :
                new ObjectParameter("sortOrderType", typeof(string));
    
            var oeListParameter = oeList != null ?
                new ObjectParameter("oeList", oeList) :
                new ObjectParameter("oeList", typeof(string));
    
            var excludeStatusListParameter = excludeStatusList != null ?
                new ObjectParameter("excludeStatusList", excludeStatusList) :
                new ObjectParameter("excludeStatusList", typeof(string));
    
            var roleAppIdListParameter = roleAppIdList != null ?
                new ObjectParameter("roleAppIdList", roleAppIdList) :
                new ObjectParameter("roleAppIdList", typeof(string));
    
            var roleIdListParameter = roleIdList != null ?
                new ObjectParameter("roleIdList", roleIdList) :
                new ObjectParameter("roleIdList", typeof(string));
    
            var userIdListParameter = userIdList != null ?
                new ObjectParameter("userIdList", userIdList) :
                new ObjectParameter("userIdList", typeof(string));
    
            var userSourceListParameter = userSourceList != null ?
                new ObjectParameter("userSourceList", userSourceList) :
                new ObjectParameter("userSourceList", typeof(string));
    
            var expiredTypeParameter = expiredType != null ?
                new ObjectParameter("expiredType", expiredType) :
                new ObjectParameter("expiredType", typeof(string));
    
            var expiredDateParameter = expiredDate.HasValue ?
                new ObjectParameter("expiredDate", expiredDate) :
                new ObjectParameter("expiredDate", typeof(System.DateTime));
    
            var userIdParameter = userId != null ?
                new ObjectParameter("userId", userId) :
                new ObjectParameter("userId", typeof(string));
    
            var userSourceSystemParameter = userSourceSystem != null ?
                new ObjectParameter("userSourceSystem", userSourceSystem) :
                new ObjectParameter("userSourceSystem", typeof(string));
    
            return ((IObjectContextAdapter)this).ObjectContext.ExecuteFunction("uspGetAccessControlInfo", contextParameter, hierarchyNameParameter, requestedVersionParameter, rootParameter, classificationTypeParameter, sortOrderTypeParameter, oeListParameter, excludeStatusListParameter, roleAppIdListParameter, roleIdListParameter, userIdListParameter, userSourceListParameter, expiredTypeParameter, expiredDateParameter, userIdParameter, userSourceSystemParameter);
        }
    }
}
