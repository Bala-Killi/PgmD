//------------------------------------------------------------------------------
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
    using System.Collections.Generic;
    
    public partial class Subhierarchy
    {
        public string Context { get; set; }
        public string HierarchyName { get; set; }
        public int VersionID { get; set; }
        public int Root { get; set; }
        public string ChildContext { get; set; }
        public string ChildHierarchyName { get; set; }
        public int ChildVersionID { get; set; }
        public int ChildRoot { get; set; }
        public string ParentContext { get; set; }
        public string ParentHierarchyName { get; set; }
        public int ParentVersionID { get; set; }
        public int ParentRoot { get; set; }
        public int Parent { get; set; }
        public int InternalSortPosition { get; set; }
        public Nullable<decimal> ExternalSortPosition { get; set; }
    
        public virtual Hierarchy Hierarchy { get; set; }
        public virtual Hierarchy Hierarchy1 { get; set; }
        public virtual HierarchyNode HierarchyNode { get; set; }
    }
}
