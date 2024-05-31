-- =============================================
-- Create date: 9/10/2010
-- Description: Retrieve personnel info
-- =============================================
CREATE PROCEDURE [dbo].[uspGetPersonnel] 
	@filterVal		varchar(50) = NULL,
	@filterBy		varchar(50) = NULL, -- if null, will filter by bemsId OR displayName
	@filterSource	varchar(50) = NULL
AS BEGIN
	SET NOCOUNT ON;

	IF (@filterBy IS NULL) BEGIN
		SELECT ID AS BoeingBemsId,
				DisplayName AS BoeingDisplayName,
				FirstName AS GivenName,
				Middle AS Initials,
				LastName AS SN,
				AcctDept AS DepartmentNumber,
				Telephone AS TelephoneNumber,
				Email AS BoeingInternetEmail,
				City,
				State,
				IsUSPerson AS UsPerson,
				IsBoeingEmployee AS BoeingEmployee,
				Status,
				Country,
				JobCode
		FROM Personnel
		WHERE (ID = @filterVal
			OR ISNULL(DisplayName, '') LIKE @filterVal + '%')
			AND SourceSystem = ISNULL(@filterSource, SourceSystem)
		ORDER BY DisplayName
	END ELSE BEGIN
		SELECT ID AS BoeingBemsId,
				DisplayName AS BoeingDisplayName,
				FirstName AS GivenName,
				Middle AS Initials,
				LastName AS SN,
				AcctDept AS DepartmentNumber,
				Telephone AS TelephoneNumber,
				Email AS BoeingInternetEmail,
				City,
				State,
				IsUSPerson AS UsPerson,
				IsBoeingEmployee AS BoeingEmployee,
				Status,
				Country,
				JobCode
		FROM Personnel
		WHERE ((ID = @filterVal
				AND @filterBy = 'ID')
			OR (ISNULL(DisplayName, '') LIKE @filterVal + '%'
				AND @filterBy = 'DisplayName')
			OR (ISNULL(FirstName, '') LIKE @filterVal + '%'
				AND @filterBy = 'FirstName')
			OR (ISNULL(Middle, '') LIKE @filterVal + '%'
				AND @filterBy = 'Middle')
			OR (ISNULL(LastName, '') LIKE @filterVal + '%'
				AND @filterBy = 'LastName')
			OR (ISNULL(AcctDept, '') LIKE @filterVal + '%'
				AND @filterBy = 'AcctDept')
			OR (ISNULL(Telephone, '') LIKE @filterVal + '%'
				AND @filterBy = 'Telephone')
			OR (ISNULL(Email, '') LIKE @filterVal + '%'
				AND @filterBy = 'Email')
			OR (ISNULL(IsUSPerson, 0) = CASE
					WHEN LEFT(@filterVal, 1) = 'Y' THEN 1
					ELSE 0
				END
				AND @filterBy = 'IsUSPerson')
			OR (ISNULL(IsBoeingEmployee, 0) = CASE
					WHEN LEFT(@filterVal, 1) = 'Y' THEN 1
					ELSE 0
				END
				AND @filterBy = 'IsBoeingEmployee')
			OR (((Status IS NULL
				AND @filterVal IS NULL)
			OR (ISNULL(Status, '') = @filterVal))
				AND @filterBy = 'Status')
			AND ((ISNULL(SourceSystem, '') = @filterSource
				AND @filterSource IS NOT NULL)
			OR (@filterSource IS NULL)))
		ORDER BY DisplayName
	END;
END