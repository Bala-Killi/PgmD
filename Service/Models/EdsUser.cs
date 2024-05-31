namespace PgmD.Service.Models {
	public class EdsUser {
		public string BemsId { get; set; }
		public string DisplayName { get; set; }
		public string FirstName { get; set; }
		public string Initials { get; set; }
		public string LastName { get; set; }
		public string DepartmentNumber { get; set; }
		public string Phone { get; set; }
		public string Email { get; set; }
		public string City { get; set; }
		public string State { get; set; }
		public bool IsUsPerson { get; set; }
		public bool IsBoeingEmployee { get; set; }
		public string Country { get; set; }
	}
}