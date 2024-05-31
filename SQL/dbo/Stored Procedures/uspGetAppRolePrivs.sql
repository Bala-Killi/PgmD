-- =============================================
-- Create date: 10/19/2011
-- Description: Retrieve app privileges for specific roles
-- =============================================
CREATE PROCEDURE [dbo].[uspGetAppRolePrivs] 
	@context	varchar(50) = NULL
AS BEGIN
	SET NOCOUNT ON;
	SELECT rtp.AppID,
		a.Name AS AppName,
		a.DisplayName AS DisplayApp,
		rtp.RoleTypeID,
		rt.Name AS RoleName,
		rt.DisplayName AS DisplayRole,
		rtp.Privileges
	FROM RoleTypePrivileges rtp
		INNER JOIN RoleTypes rt
			ON rtp.AppID = rt.AppID
				AND rtp.RoleTypeID = rt.RoleTypeID
		INNER JOIN Applications a
			ON rtp.AppID = a.ID
	WHERE Context = ISNULL(@context, Context)
	ORDER BY rtp.Context, a.DisplayOrder, rtp.DisplayOrder
END