-- =============================================
-- Create date: 4/21/2011
-- Description: Retrieve attibutes for specific app privileges
-- =============================================
CREATE PROCEDURE [dbo].[uspGetAppPrivAttributes] 
	@context	varchar(50) = NULL
AS BEGIN
	SET NOCOUNT ON;
	SELECT apa.AppID,
		a.Name AS AppName,
		a.DisplayName AS DisplayApp,
		apa.MaxDuration,
		apa.GrantPrivilegeMask AS GrantMask
	FROM ApplicationPrivilegeAttributes apa
		INNER JOIN Applications a
			ON apa.AppID = a.ID
	WHERE Context = ISNULL(@context, Context)
	ORDER BY apa.Context, a.DisplayOrder
END