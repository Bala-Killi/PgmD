-- =============================================
-- Create date: 11/30/2011
-- Description: Delete HierarchicalAC privileges
-- =============================================
CREATE PROCEDURE [dbo].[uspDeleteAC] 
	@context	varchar(50),
	@root		int,
	@oeId		int,
	@appId		int,
	@roleId		int,
	@bemsId		varchar(max),
	@source		varchar(max)
AS BEGIN
	SET NOCOUNT ON;
	DECLARE @err int;
	SET @err = 0;
	DELETE
	FROM HierarchicalAC
	WHERE Context = @context
		AND Root = @root
		AND Node = @oeId
		AND Grantee = @bemsId
		AND GranteeSourceSystem = @source
		AND AppID = @appId
		AND RoleTypeID = @roleId;
	IF (@@ERROR <> 0) SET @err = 1;
	SELECT @err AS ERRCODE;
END