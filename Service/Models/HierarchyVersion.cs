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
    
    public partial class HierarchyVersion
    {
        public HierarchyVersion()
        {
            this.Hierarchies = new HashSet<Hierarchy>();
        }
    
        public string Context { get; set; }
        public string HierarchyName { get; set; }
        public int VersionID { get; set; }
        public string Classification { get; set; }
        public System.DateTime VersionDate { get; set; }
        public string Description { get; set; }
    
        public virtual ICollection<Hierarchy> Hierarchies { get; set; }
    }
}