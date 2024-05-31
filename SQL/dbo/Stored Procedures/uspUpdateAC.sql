-- =============================================
-- Create date: 11/30/2011
-- Description: Add or update HierarchicalAC privileges
-- =============================================
CREATE PROCEDURE [uspUpdateAC] 
	@type				varchar(10),
	@context			varchar(50),
	@root				int,
	@oeId				int,
	@appId				int,
	@roleId				int,
	@expiredDate		date,
	@reason				varchar(1024),
	@bemsId				varchar(max),
	@source				varchar(max),
	@displayName		varchar(max) = NULL,
	@lastName			varchar(max) = NULL,
	@firstName			varchar(max) = NULL,
	@middle				varchar(max) = NULL,
	@email				varchar(max) = NULL,
	@phone				varchar(max) = NULL,
	@dept				varchar(max) = NULL,
	@usPerson			varchar(max) = NULL,
	@boeingEmp			varchar(max) = NULL,
	@userId				varchar(50),	-- this will be used to determine the logged in user
	@userSourceSystem	varchar(50)		-- used to determine the logged in user's source system. hardcoded to EDS in the calling program.
AS BEGIN
	SET NOCOUNT ON;
	DECLARE @today datetime;
	DECLARE @err int;
	DECLARE @rowCount int;
	DECLARE @returnCode int;
	DECLARE @personnelList TABLE(
		bemsId varchar(255) NOT NULL,
		source varchar(255) NOT NULL
	);

	SET @err = 0;
	SET @today = GETDATE();
	BEGIN TRANSACTION
	-- Build the personnel list table from the lists
	INSERT INTO @personnelList
	SELECT DISTINCT a.Value, b.Value
	FROM udfParseColumnString(@bemsId, ';') a
		INNER JOIN udfParseColumnString(@source, ';') b
			ON a.ID = b.ID;
	IF (@@ERROR <> 0 AND @err = 0) SET @err = 1;

	IF (@type = 'create') BEGIN
		-- Update/add personnel
		EXECUTE @returnCode = uspUpdatePersonnel
			@bemsId,
			@source,
			@displayName,
			@lastName,
			@firstName,
			@middle,
			@email,
			@phone,
			@dept,
			@usPerson,
			@boeingEmp
		IF (@returnCode <> 0 AND @err = 0) SET @err = 2;

		-- Insert new data
		INSERT INTO HierarchicalAC
		SELECT @context,
				@root,
				@oeId,
				CAST(pl.bemsId AS varchar(50)),
				CAST(pl.source AS varchar(50)),
				@appId,
				@roleId,
				rtp.Privileges,
				@reason,
				@userId,
				@userSourceSystem,
				@today,
				@expiredDate,
				NULL,
				NULL,
				NULL,
				NULL,
				NULL
		FROM @personnelList pl
			CROSS JOIN RoleTypePrivileges rtp
		WHERE rtp.Context = @context
			AND rtp.AppID = @appId
			AND rtp.RoleTypeID = @roleId;
		SELECT @returnCode = @@ERROR,
				@rowCount = @@ROWCOUNT;
		IF (@returnCode <> 0 AND @err = 0) SET @err = 3;
	END ELSE BEGIN
		-- Update preexisting data
		UPDATE HierarchicalAC
		SET Reason = @reason,
			ExpirationDate = @expiredDate,
			ModifiedBy = @userId,
			ModifiedBySourceSystem = @userSourceSystem,
			ModifiedDate = @today
		FROM HierarchicalAC hac
			INNER JOIN @personnelList pl
				ON hac.Context = @context
				AND hac.Root = @root
				AND hac.Node = @oeId
				AND hac.Grantee = pl.bemsId
				AND hac.GranteeSourceSystem = pl.source
				AND hac.AppID = @appId
				AND hac.RoleTypeID = @roleId;
		SELECT @returnCode = @@ERROR,
				@rowCount = @@ROWCOUNT;
		IF (@returnCode <> 0 AND @err = 0) SET @err = 4;
	END

	-- If there were any errors, backout the transaction
	IF (@err <> 0) BEGIN
		ROLLBACK TRANSACTION;
	END ELSE BEGIN
		COMMIT TRANSACTION;
	END

	SELECT @err AS ErrCode,
			@rowCount AS rows,
			@userId AS modID,
			p.DisplayName AS modName
	FROM Personnel p
	WHERE p.ID = @userId
		AND p.SourceSystem = @userSourceSystem;
END