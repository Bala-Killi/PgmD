using PgmD.Service.Models;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text.RegularExpressions;

namespace PgmD.Service.Controllers {
    public class BoeingDirectory {
		private readonly List<EdsUser> EdsUsers = new List<EdsUser>() {
			new EdsUser() { BemsId = "0123456", DisplayName = "Hubbard, Jason S", FirstName = "Jason", Initials = "S", LastName = "Hubbard", DepartmentNumber = "IT00", Phone = "+1 800 0123456", Email = "jason.s.hubbard@boeing.com", City = "St. Louis", State = "MO", IsUsPerson = true, IsBoeingEmployee = true, Country = "USA" },
			new EdsUser() { BemsId = "1234567", DisplayName = "Doe, John M", FirstName = "John", Initials = "M", LastName = "Doe", DepartmentNumber = "IT00", Phone = "+1 800 1234567", Email = "john.m.doe@boeing.com", City = "New York", State = "NY", IsUsPerson = true, IsBoeingEmployee = true, Country = "USA" },
			new EdsUser() { BemsId = "2345678", DisplayName = "Griffin, Peter", FirstName = "Peter", Initials = "NULL", LastName = "Griffin", DepartmentNumber = "IT01", Phone = "+1 800 2345678", Email = "peter.griffen@boeing.com", City = "Quahog", State = "RI", IsUsPerson = true, IsBoeingEmployee = true, Country = "USA" },
			new EdsUser() { BemsId = "3456789", DisplayName = "Sanchez, Rick", FirstName = "Rick", Initials = "NULL", LastName = "Sanchez", DepartmentNumber = "SM00", Phone = "+1 800 3456789", Email = "rick.sanchez@boeing.com", City = "Mexico City", State = "CDMX", IsUsPerson = false, IsBoeingEmployee = true, Country = "MX" },
			new EdsUser() { BemsId = "4567890", DisplayName = "Public, John Q", FirstName = "John", Initials = "Q", LastName = "Public", DepartmentNumber = "", Phone = "+1 800 4567890", Email = "john.q.public@notboeing.com", City = "Seattle", State = "WA", IsUsPerson = true, IsBoeingEmployee = false, Country = "USA" },
			new EdsUser() { BemsId = "5678901", DisplayName = "Public, John Q", FirstName = "John", Initials = "Q", LastName = "Public", DepartmentNumber = "CC00", Phone = "+1 800 5678901", Email = "john.q.public2@boeing.com", City = "Washington", State = "DC", IsUsPerson = true, IsBoeingEmployee = true, Country = "USA" },
			new EdsUser() { BemsId = "6789012", DisplayName = "Vanderpool, Lars D", FirstName = "Lars", Initials = "D", LastName = "Vanderpool", DepartmentNumber = "", Phone = "+1 800 6789012", Email = "lars.d.vanderpool@foreign.com", City = "Amsterdam", State = "NL-NH", IsUsPerson = false, IsBoeingEmployee = false, Country = "NL" },
			new EdsUser() { BemsId = "7890123", DisplayName = "Smith, John L", FirstName = "John", Initials = "L", LastName = "Smith", DepartmentNumber = "CC01", Phone = "+1 800 7890123", Email = "john.l.smith@boeing.com", City = "Jamestown", State = "VA", IsUsPerson = true, IsBoeingEmployee = true, Country = "USA" },
			new EdsUser() { BemsId = "8901234", DisplayName = "Twist, Oliver", FirstName = "Oliver", Initials = "NULL", LastName = "Twist", DepartmentNumber = "CC02", Phone = "+1 800 8901234", Email = "oliver.twist@uk.com", City = "Melbourne", State = "VIC", IsUsPerson = false, IsBoeingEmployee = true, Country = "AUS" },
			new EdsUser() { BemsId = "9012345", DisplayName = "Ali, Muhammed", FirstName = "Muhammed", Initials = "NULL", LastName = "Ali", DepartmentNumber = "CC03", Phone = "+1 800 9012345", Email = "muhammed.ali@boeing.com", City = "Louisville", State = "KY", IsUsPerson = true, IsBoeingEmployee = true, Country = "USA" },
			new EdsUser() { BemsId = "9876543", DisplayName = "Favre, Brett R", FirstName = "Brett", Initials = "R", LastName = "Favre", DepartmentNumber = "ESVS", Phone = "+1 800 9876543", Email = "brett.r.favre@boeing.com", City = "Jackson", State = "MS", IsUsPerson = true, IsBoeingEmployee = true, Country = "USA" },
			new EdsUser() { BemsId = "8765432", DisplayName = "Rodgers, Aaron", FirstName = "Aaron", Initials = "NULL", LastName = "Rodgers", DepartmentNumber = "ESVS", Phone = "+1 800 8765432", Email = "aaron.rodgers@boeing.com", City = "Berkeley", State = "CA", IsUsPerson = true, IsBoeingEmployee = true, Country = "USA" },
			new EdsUser() { BemsId = "7654321", DisplayName = "Pujols, Albert", FirstName = "Albert", Initials = "NULL", LastName = "Pujols", DepartmentNumber = "ESVS", Phone = "+1 800 7654321", Email = "albert.pujols@boeing.com", City = "St. Louis", State = "MO", IsUsPerson = true, IsBoeingEmployee = true, Country = "USA" },
			new EdsUser() { BemsId = "6543210", DisplayName = "Testaberger, Wendy F", FirstName = "Wendy", Initials = "F", LastName = "Testaberger", DepartmentNumber = "ESVS", Phone = "+1 800 6543210", Email = "wendy.f.testaberger@boeing.com", City = "Chicago", State = "IL", IsUsPerson = true, IsBoeingEmployee = true, Country = "USA" },
			new EdsUser() { BemsId = "5432109", DisplayName = "Doe, Jane C", FirstName = "Jane", Initials = "C", LastName = "Doe", DepartmentNumber = "ESVS", Phone = "+1 800 5432109", Email = "jane.c.doe@boeing.com", City = "Arlington", State = "VA", IsUsPerson = true, IsBoeingEmployee = true, Country = "USA" },
			new EdsUser() { BemsId = "5432109", DisplayName = "Simpson, Lisa L", FirstName = "Lisa", Initials = "L", LastName = "Simpson", DepartmentNumber = "ESVS", Phone = "+1 800 5432109", Email = "lisa.l.simpson@boeing.com", City = "Springfield", State = "IL", IsUsPerson = true, IsBoeingEmployee = true, Country = "USA" },
			new EdsUser() { BemsId = "4321098", DisplayName = "Mars, Veronica", FirstName = "Veronica", Initials = "NULL", LastName = "Mars", DepartmentNumber = "ESVP", Phone = "+1 800 4321098", Email = "veronica.mars@boeing.com", City = "Miami", State = "FL", IsUsPerson = true, IsBoeingEmployee = true, Country = "USA" },
			new EdsUser() { BemsId = "3210987", DisplayName = "Dawson, Andre T", FirstName = "Andre", Initials = "T", LastName = "Dawson", DepartmentNumber = "ESVS", Phone = "+1 800 3210987", Email = "andre.t.dawson@boeing.com", City = "Chicago", State = "IL", IsUsPerson = true, IsBoeingEmployee = true, Country = "USA" },
			new EdsUser() { BemsId = "2109876", DisplayName = "Carroll, Taylor A", FirstName = "Taylor", Initials = "A", LastName = "Carroll", DepartmentNumber = "ESVS", Phone = "+1 800 2109876", Email = "taylor.a.carroll@boeing.com", City = "Des Moines", State = "IA", IsUsPerson = true, IsBoeingEmployee = true, Country = "USA" },
			new EdsUser() { BemsId = "1098765", DisplayName = "Washington, George", FirstName = "George", Initials = "NULL", LastName = "Washington", DepartmentNumber = "ESVP", Phone = "+1 800 1098765", Email = "george.washington@boeing.com", City = "Mt. Vernon", State = "VA", IsUsPerson = true, IsBoeingEmployee = true, Country = "USA" },
			new EdsUser() { BemsId = "1357924", DisplayName = "Walters, Barbara N", FirstName = "Barbara", Initials = "N", LastName = "Walters", DepartmentNumber = "ESVP", Phone = "+1 800 1357924", Email = "barbara.n.walters@boeing.com", City = "New York", State = "NY", IsUsPerson = true, IsBoeingEmployee = true, Country = "USA" },
			new EdsUser() { BemsId = "3579246", DisplayName = "Jordan, Michael B", FirstName = "Michael", Initials = "B", LastName = "Jordan", DepartmentNumber = "ESVS", Phone = "+1 800 3579246", Email = "michael.b.jordan@boeing.com", City = "Chapel Hill", State = "NC", IsUsPerson = true, IsBoeingEmployee = true, Country = "USA" },
			new EdsUser() { BemsId = "5792468", DisplayName = "Owens, Jesse", FirstName = "Jesse", Initials = "NULL", LastName = "Owens", DepartmentNumber = "ESVS", Phone = "+1 800 5792468", Email = "jesse.owens@boeing.com", City = "Oakville", State = "AL", IsUsPerson = true, IsBoeingEmployee = true, Country = "USA" },
			new EdsUser() { BemsId = "7924683", DisplayName = "Joyner, Jackie J", FirstName = "Jackie", Initials = "J", LastName = "Joyner", DepartmentNumber = "ESVS", Phone = "+1 800 7924683", Email = "jackie.j.joyner@boeing.com", City = "St. Louis", State = "MO", IsUsPerson = true, IsBoeingEmployee = true, Country = "USA" },
			new EdsUser() { BemsId = "9246835", DisplayName = "Forte, Will W", FirstName = "Will", Initials = "W", LastName = "Forte", DepartmentNumber = "ESVP", Phone = "+1 800 9246835", Email = "will.w.forte@boeing.com", City = "Chicago", State = "IL", IsUsPerson = true, IsBoeingEmployee = true, Country = "USA" },
			new EdsUser() { BemsId = "2468357", DisplayName = "Estrada, Sandra", FirstName = "Sandra", Initials = "NULL", LastName = "Estrada", DepartmentNumber = "ESVS", Phone = "+1 800 2468357", Email = "sandra.estrada@boeing.com", City = "Los Angeles", State = "CA", IsUsPerson = true, IsBoeingEmployee = true, Country = "USA" },
			new EdsUser() { BemsId = "4683579", DisplayName = "Hwang, Ju K", FirstName = "Ju", Initials = "K", LastName = "Hwang", DepartmentNumber = "ESVS", Phone = "+1 800 4683579", Email = "ju.k.hwang@boeing.com", City = "Seattle", State = "WA", IsUsPerson = true, IsBoeingEmployee = true, Country = "USA" },
			new EdsUser() { BemsId = "6835792", DisplayName = "Thompson, Billy", FirstName = "Billy", Initials = "NULL", LastName = "Thompson", DepartmentNumber = "ESVS", Phone = "+1 800 6835792", Email = "billy.thompson@boeing.com", City = "Atlanta", State = "GA", IsUsPerson = true, IsBoeingEmployee = true, Country = "USA" },
			new EdsUser() { BemsId = "8357924", DisplayName = "Howard, Kim R", FirstName = "Kim", Initials = "R", LastName = "Howard", DepartmentNumber = "ESVS", Phone = "+1 800 8357924", Email = "kim.r.howard@boeing.com", City = "Arlington", State = "VA", IsUsPerson = true, IsBoeingEmployee = true, Country = "USA" }
		};

		public DataTable Search(string filterValue, string filterField) {
			var validInputRegex = new Regex(@"^[a-zA-Z0-9!=\/,-_\s\.]+$");
			if (!string.IsNullOrEmpty(filterValue) && validInputRegex.IsMatch(filterValue) && string.IsNullOrEmpty(filterField)) {
				var edsUsers = new List<EdsUser>(EdsUsers
					.Where(edsUser => edsUser.BemsId == filterValue || edsUser.DisplayName.StartsWith(filterValue, true, System.Globalization.CultureInfo.InvariantCulture))
					.OrderBy(edsUser => edsUser.DisplayName)
				);

				if (edsUsers.Count > 0) {
					var searchResults = new DataTable();
					searchResults.Columns.AddRange(new DataColumn[] {
						new DataColumn("BoeingBemsId"),
						new DataColumn("BoeingDisplayName"),
						new DataColumn("GivenName"),
						new DataColumn("Initials"),
						new DataColumn("SN"),
						new DataColumn("DepartmentNumber"),
						new DataColumn("TelephoneNumber"),
						new DataColumn("BoeingInternetEmail"),
						new DataColumn("City"),
						new DataColumn("State"),
						new DataColumn("UsPerson"),
						new DataColumn("BoeingEmployee"),
						new DataColumn("Country"),
					});
					foreach (EdsUser edsUser in edsUsers) {
						searchResults.Rows.Add(new object[] {
							Convert.ToInt32(edsUser.BemsId),
							edsUser.DisplayName,
							edsUser.FirstName,
							edsUser.Initials,
							edsUser.LastName,
							edsUser.DepartmentNumber,
							edsUser.Phone,
							edsUser.Email,
							edsUser.City,
							edsUser.State,
							edsUser.IsUsPerson ? "1" : "0",
							edsUser.IsBoeingEmployee ? "1" : "0",
							edsUser.Country
						});
					}

					return searchResults;
				}
			}

			return null;
		}
	}
}