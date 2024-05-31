-- =============================================
-- Create date: 9/10/2012
-- Description: Retrieve the access control info
-- =============================================
CREATE PROCEDURE [dbo].[uspGetAccessControlInfo] 
	
	@context				varchar(50) = NULL,
	@hierarchyName			varchar(255) = NULL,
	@requestedVersion		int = NULL,				-- if versionID is NULL, then get the most recent version
	@root					int = NULL,				-- if specified, this would select only one hierarchy within a hierarchy type
	@classificationType		varchar(50) = NULL,		-- choices are any Classification from HierachyClassifications or any classification if NULL
	@sortOrderType			varchar(50) = NULL,		-- choices are 'abbreviation', 'name' and 'position'. NULL indicates no particular sort order.
	@oeList					varchar(max) = NULL,	-- if specified, this comma separated list will be used to specify the orgs for which access control info need to be retrieved.
	@excludeStatusList		varchar(255) = NULL,	-- if specified, this comma separated list will be used to exclude orgs with any of the statuses
	@roleAppIdList			varchar(255),			-- this comma separated list will be used to specify the applications for which access control info need to be retrieved.
	@roleIdList				varchar(255),			-- this comma separated list will be used to specify the roles for which access control info need to be retrieved.
	@userIdList				varchar(max) = NULL,	-- if specified, this comma separated list will be used to specify the id (BEMSID) for the users for which access control info need to be retrieved.
	@userSourceList			varchar(max) = NULL,	-- if specified, this comma separated list will be used to specify the id (BEMSID)source system for the users for which access control info need to be retrieved.
	@expiredType				varchar(10),			-- this is used to specify whether retrieval is filtered for expired records, unexpired (i.e., valid) records or all records
	@expiredDate				datetime,				-- this establishes the date for determining if a record has expired or not 
	@userId					varchar(50) ,			-- this will be used to determine the logged in user's privileges
	@userSourceSystem		varchar(50)				-- used to determine the logged in user's privileges. If NULL, don't return privileges

AS BEGIN
	SET NOCOUNT ON;

	-- Define all of the bit masks used to manipulate privileges --
	DECLARE @defaultUserPriv int
	DECLARE @adminPriv int
	DECLARE @removeWrite int
	DECLARE @basePriv int
	DECLARE @appIdx int
	DECLARE @appCount int
	DECLARE @app varchar(50)
	DECLARE @execStmt varchar(max)

	DECLARE @AllNodes TABLE(
		Context varchar(50) NOT NULL,
		HierarchyName varchar(255) NOT NULL,
		VersionID int NOT NULL,
		Root int NOT NULL,
		Node int,
		SubhierarchyContext varchar(50),
		SubhierarchyName varchar(255),
		SubhierarchyVersionID int,
		SubhierarchyRoot int,
		ParentContext varchar(50),
		ParentHierarchyName varchar(255),
		ParentVersionID int,
		ParentRoot int,
		Parent int,
		InternalSortPosition int,
		ExternalSortPosition decimal(15, 15),
		Type tinyint,
		Label varchar(50),
		SourcingHierarchyContext varchar(50),
		Name varchar(255),
		Abbreviation varchar(50),
		Status varchar(50),
		Description varchar(max),
		IsLeaf tinyint,
		IsSHRoot tinyint,
		Generation int,
		Position varchar(50),
		InheritedStatus varchar(50),
		Ancestry varchar(max),
		AbbreviationBreadCrumb varchar(max),
		NameBreadCrumb varchar(max),
		PositionBreadCrumb varchar(max),
		SortBreadCrumb nvarchar(max)
	)

	DECLARE @AppList TABLE(
		AppID int NOT NULL,
		AppName varchar(50) NOT NULL,
		AllPrivileges int,
		GrantPrivilegeMask int
	)

	DECLARE @PersonnelList TABLE(
		ID varchar(50),
		SourceSystem varchar(50)
	)

	DECLARE @RoleList TABLE(
		AppID int,
		RoleTypeID int
	)

	CREATE TABLE #FilteredNodes(
		Context varchar(50),
		HierarchyName varchar(255),
		VersionID int,
		Root int,
		Node int,
		SubhierarchyContext varchar(50),
		SubhierarchyName varchar(255),
		SubhierarchyVersionID int,
		SubhierarchyRoot int,
		ParentContext varchar(50),
		ParentHierarchyName varchar(255),
		ParentVersionID int,
		ParentRoot int,
		Parent int,
		InternalSortPosition int,
		ExternalSortPosition decimal(15, 15),
		Type tinyint,
		Label varchar(50),
		SourcingHierarchyContext varchar(50),
		Name varchar(255),
		Abbreviation varchar(50),
		Status varchar(50),
		Description varchar(max),
		IsLeaf tinyint,
		IsSHRoot tinyint,
		Generation int,
		Position varchar(50),
		InheritedStatus varchar(50),
		Ancestry varchar(max),
		AbbreviationBreadCrumb varchar(max),
		NameBreadCrumb varchar(max),
		PositionBreadCrumb varchar(max),
		SortBreadCrumb nvarchar(max)
	)

	CREATE TABLE #AggregatePrivileges(
		Root int,
		Node int,
		AppID int,
		AppName varchar(50) NOT NULL,
		GrantPrivilegeMask int,
		AggregateAppPriv int
	)

	INSERT INTO @AllNodes
	SELECT Context,
		HierarchyName,
		VersionID,
		Root,
		Node,
		SubhierarchyContext,
		SubhierarchyName,
		SubhierarchyVersionID,
		SubhierarchyRoot,
		ParentContext,
		ParentHierarchyName,
		ParentVersionID,
		ParentRoot,
		Parent,
		InternalSortPosition,
		ExternalSortPosition,
		Type,
		Label,
		SourcingHierarchyContext,
		Name,
		Abbreviation,
		Status,
		Description,
		IsLeaf,
		IsSHRoot,
		Generation,
		Position,
		InheritedStatus,
		Ancestry,
		AbbreviationBreadCrumb,
		NameBreadCrumb,
		PositionBreadCrumb,
		SortBreadCrumb
	FROM udfGetFullHierarchy(@context, @hierarchyName, @requestedVersion, @root, @classificationType, @sortOrderType)
	WHERE (',' + @excludeStatusList + ',' NOT LIKE '%,' + COALESCE(InheritedStatus, '') + ',%'
		AND @excludeStatusList IS NOT NULL)
		OR (@excludeStatusList IS NULL);

	IF (@userIdList IS NULL) BEGIN
		INSERT INTO @PersonnelList
		SELECT ID,
			SourceSystem
		FROM Personnel;
	END ELSE BEGIN
		IF (@userSourceList IS NULL) BEGIN
			INSERT INTO @PersonnelList
			SELECT CAST(a.Value AS varchar(50)),
				b.SourceSystem
			FROM udfParseColumnString(@userIdList, ',') a
				INNER JOIN Personnel b
					ON a.Value = b.ID;
		END ELSE BEGIN
			INSERT INTO @PersonnelList
			SELECT CAST(a.Value AS varchar(50)),
				CAST(b.Value AS varchar(50))
			FROM udfParseColumnString(@userIdList, ',') a
				INNER JOIN udfParseColumnString(@userSourceList, ',') b
					ON a.ID = b.ID;
		END
	END

	INSERT INTO @RoleList
	SELECT CAST(a.Value AS int),
		CAST(b.Value AS int)
	FROM udfParseColumnString(@roleAppIdList, ',') a
		INNER JOIN udfParseColumnString(@roleIdList, ',') b
			ON a.ID = b.ID;

	IF (@oeList = 'All') BEGIN
		INSERT INTO #FilteredNodes
		SELECT Context,
			HierarchyName,
			VersionID,
			Root,
			Node,
			SubhierarchyContext,
			SubhierarchyName,
			SubhierarchyVersionID,
			SubhierarchyRoot,
			ParentContext,
			ParentHierarchyName,
			ParentVersionID,
			ParentRoot,
			Parent,
			InternalSortPosition,
			ExternalSortPosition,
			Type,
			Label,
			SourcingHierarchyContext,
			Name,
			Abbreviation,
			Status,
			Description,
			IsLeaf,
			IsSHRoot,
			Generation,
			Position,
			InheritedStatus,
			Ancestry,
			AbbreviationBreadCrumb,
			NameBreadCrumb,
			PositionBreadCrumb,
			SortBreadCrumb
		FROM @AllNodes;
	END ELSE BEGIN
		IF (@oeList IS NULL) BEGIN
			INSERT INTO #FilteredNodes
			SELECT DISTINCT
				an2.Context,
				an2.HierarchyName,
				an2.VersionID,
				an2.Root,
				an2.Node,
				an2.SubhierarchyContext,
				an2.SubhierarchyName,
				an2.SubhierarchyVersionID,
				an2.SubhierarchyRoot,
				an2.ParentContext,
				an2.ParentHierarchyName,
				an2.ParentVersionID,
				an2.ParentRoot,
				an2.Parent,
				an2.InternalSortPosition,
				an2.ExternalSortPosition,
				an2.Type,
				an2.Label,
				an2.SourcingHierarchyContext,
				an2.Name,
				an2.Abbreviation,
				an2.Status,
				an2.Description,
				an2.IsLeaf,
				an2.IsSHRoot,
				an2.Generation,
				an2.Position,
				an2.InheritedStatus,
				an2.Ancestry,
				an2.AbbreviationBreadCrumb,
				an2.NameBreadCrumb,
				an2.PositionBreadCrumb,
				an2.SortBreadCrumb
			FROM @AllNodes an1
				INNER JOIN HierarchicalAC hac
					ON hac.Context = @context
						AND hac.Context = an1.Context
						AND hac.Root = an1.Root
						AND hac.Node = an1.Node
						AND (@expiredType = 'All'
							OR (@expiredType = 'Valid'
								AND hac.ExpirationDate > @expiredDate
							)
							OR (@expiredType = 'Expired'
								AND hac.ExpirationDate <= @expiredDate
							)
						)
				INNER JOIN @PersonnelList pl
					ON hac.Grantee = pl.ID
						AND hac.GranteeSourceSystem = pl.SourceSystem
				INNER JOIN @RoleList rl
					ON hac.AppID = rl.AppID
						AND hac.RoleTypeID = rl.RoleTypeID
				INNER JOIN @AllNodes an2
					ON an1.Root = an2.Root
						AND ',' + an1.Ancestry + ',' LIKE '%,' + CAST(an2.Node AS varchar(10)) + ',%';
		END ELSE BEGIN
			INSERT INTO #FilteredNodes
			SELECT DISTINCT
				an2.Context,
				an2.HierarchyName,
				an2.VersionID,
				an2.Root,
				an2.Node,
				an2.SubhierarchyContext,
				an2.SubhierarchyName,
				an2.SubhierarchyVersionID,
				an2.SubhierarchyRoot,
				an2.ParentContext,
				an2.ParentHierarchyName,
				an2.ParentVersionID,
				an2.ParentRoot,
				an2.Parent,
				an2.InternalSortPosition,
				an2.ExternalSortPosition,
				an2.Type,
				an2.Label,
				an2.SourcingHierarchyContext,
				an2.Name,
				an2.Abbreviation,
				an2.Status,
				an2.Description,
				an2.IsLeaf,
				an2.IsSHRoot,
				an2.Generation,
				an2.Position,
				an2.InheritedStatus,
				an2.Ancestry,
				an2.AbbreviationBreadCrumb,
				an2.NameBreadCrumb,
				an2.PositionBreadCrumb,
				an2.SortBreadCrumb
			FROM @AllNodes an1
				INNER JOIN udfParseColumnString(@oeList, ',') oe
					ON an1.Node = oe.Value
				INNER JOIN @AllNodes an2
					ON an1.Root = an2.Root
						AND ',' + an1.Ancestry + ',' LIKE '%,' + CAST(an2.Node AS varchar(10)) + ',%';
		END
	END;

	WITH FilteredNodes AS (
		SELECT Context,
			HierarchyName,
			VersionID,
			Root,
			Node,
			SubhierarchyContext,
			SubhierarchyName,
			SubhierarchyVersionID,
			SubhierarchyRoot,
			ParentContext,
			ParentHierarchyName,
			ParentVersionID,
			ParentRoot,
			Parent,
			InternalSortPosition,
			ExternalSortPosition,
			Type,
			Label,
			SourcingHierarchyContext,
			Name,
			Abbreviation,
			Status,
			Description,
			IsLeaf,
			IsSHRoot,
			Generation,
			Position,
			InheritedStatus,
			Ancestry,
			AbbreviationBreadCrumb,
			NameBreadCrumb,
			PositionBreadCrumb,
			SortBreadCrumb
		FROM #FilteredNodes
	)
	UPDATE #FilteredNodes
	SET Type = CASE
				WHEN fn2.Node IS NULL THEN 0
				ELSE 1
			END,
		IsLeaf = CASE
				WHEN fn2.Node IS NULL THEN 1
				ELSE 0
			END
	FROM #FilteredNodes fn1
		LEFT JOIN FilteredNodes fn2
			ON fn1.Root = fn2.Root
				AND fn1.Node = fn2.Parent;

	-- First determine the applications for which privileges are being sought.
	INSERT INTO @AppList
	SELECT a.ID,
		a.Name,
		apa.AllPrivileges,
		apa.GrantPrivilegeMask
	FROM ApplicationPrivilegeAttributes apa
		INNER JOIN Applications a
			ON apa.AppID = a.ID
				AND apa.Context = @context;

	SELECT @appCount = COUNT(*)
	FROM @AppList

	-- Retrieve all of the hierarchical privilege masks
	SELECT @defaultUserPriv = CAST(Value AS int)
	FROM ApplicationConfiguration
	WHERE Name = 'DefaultUserPriv';	-- 0...0 0001 0100

	SELECT @adminPriv = CAST(Value AS int)
	FROM ApplicationConfiguration
	WHERE Name = 'AdminPriv';	-- 0...0 1111 1111

	-- For PgmD privileges, set the base privilege as either the defaultUserPriv (i.e., read only) or the PgmD admin privileges for an admin (i.e., grant, hierarchy editing, write and read)
	-- Note, the userSourceSystem will always be EDS for anyone marked as an administrator in the ApplicationConfiguration table.
	-- If this premise changes, then we will create names for the combination of source system and admin (e.g., EDSAdmin, PgmDPersonnelAdmin, etc.) with values being the user id
	SET @basePriv = CASE
			WHEN (
					SELECT COUNT(*)
					FROM ApplicationConfiguration
					WHERE Name = 'Administrator'
						AND Value = @userId
				)
				= 0 THEN @defaultUserPriv
			ELSE @adminPriv
		END;

	-- Aggregate all of the privileges stored in the access control table for this user by nodes and application
	-- Every application uses a 32 bit word for storing privileges so we will aggregate and combine the 32 bits
	INSERT INTO #AggregatePrivileges
	SELECT fn.Root,
		fn.Node,
		al.AppID,
		al.AppName,
		al.GrantPrivilegeMask,
		COALESCE(MAX(0x00000001 & hac.Privileges) | MAX(0x00000002 & hac.Privileges) | MAX(0x00000004 & hac.Privileges) | MAX(0x00000008 & hac.Privileges) | MAX(0x00000010 & hac.Privileges) | MAX(0x00000020 & hac.Privileges) | MAX(0x00000040 & hac.Privileges) | MAX(0x00000080 & hac.Privileges) | MAX(0x00000100 & hac.Privileges) | MAX(0x00000200 & hac.Privileges) | MAX(0x00000400 & hac.Privileges) | MAX(0x00000800 & hac.Privileges) | MAX(0x00001000 & hac.Privileges) | MAX(0x00002000 & hac.Privileges) | MAX(0x00004000 & hac.Privileges) | MAX(0x00008000 & hac.Privileges) | MAX(0x00010000 & hac.Privileges) | MAX(0x00020000 & hac.Privileges) | MAX(0x00040000 & hac.Privileges) | MAX(0x00080000 & hac.Privileges) | MAX(0x00100000 & hac.Privileges) | MAX(0x00200000 & hac.Privileges) | MAX(0x00400000 & hac.Privileges) | MAX(0x00800000 & hac.Privileges) | MAX(0x01000000 & hac.Privileges) | MAX(0x02000000 & hac.Privileges) | MAX(0x04000000 & hac.Privileges) | MAX(0x08000000 & hac.Privileges) | MAX(0x10000000 & hac.Privileges) | MAX(0x20000000 & hac.Privileges) | MAX(0x40000000 & hac.Privileges) | MAX(0x80000000 & hac.Privileges), 0x00000000) & MAX(al.AllPrivileges) AS AggregateAppPriv
	FROM #FilteredNodes fn
		CROSS JOIN @AppList al
		LEFT JOIN HierarchicalAC hac
			ON hac.Context = @context
				AND hac.AppID = al.AppID
				AND hac.Grantee = @userId
				AND hac.GranteeSourceSystem = @userSourceSystem
				AND hac.ExpirationDate > GETDATE()
				AND hac.Context = fn.Context
				AND hac.Root = fn.Root
				AND ',' + fn.Ancestry + ',' LIKE '%,' + CAST(hac.Node AS varchar(10)) + ',%'
	GROUP BY	fn.Root,
				fn.Node,
				al.AppID,
				al.AppName,
				al.GrantPrivilegeMask;

	-- Modify the aggregated privileges for PgmD with the default base privs
	UPDATE #AggregatePrivileges
	SET AggregateAppPriv = AggregateAppPriv | @basePriv
	WHERE AppName = 'PgmD';

	ALTER TABLE #FilteredNodes ADD AppCount int;

	UPDATE #FilteredNodes
	SET AppCount = @appCount;

	SET @appIdx = 0;

	DECLARE AppListCursor CURSOR FOR SELECT AppName
	FROM @AppList;
	OPEN AppListCursor;
	FETCH NEXT FROM AppListCursor
	INTO @app;

	WHILE (@@FETCH_STATUS = 0) BEGIN
		SET @appIdx = @appIdx + 1;

		SET @execStmt = 'ALTER TABLE #FilteredNodes ADD AppID' + CAST(@appIdx AS varchar(3)) + ' int,' +
		' AppName' + CAST(@appIdx AS varchar(3)) + ' varchar(50),' +
		' AggregateAppPriv' + CAST(@appIdx AS varchar(3)) + ' int,' +
		' GrantPrivilegeMask' + CAST(@appIdx AS varchar(3)) + ' int';
		EXEC (@execStmt);

		SET @execStmt = 'UPDATE #FilteredNodes' +
		' SET AppID' + CAST(@appIdx AS varchar(3)) + ' = ap.AppID,' +
		' AppName' + CAST(@appIdx AS varchar(3)) + ' = ap.AppName,' +
		----' GrantPrivilege' + cast(@appIdx AS varchar(3)) + ' = CASE WHEN ap.GrantPrivilege <> 0 THEN 1 ELSE 0 END,' +
		' AggregateAppPriv' + CAST(@appIdx AS varchar(3)) + ' = ap.AggregateAppPriv,' +
		' GrantPrivilegeMask' + CAST(@appIdx AS varchar(3)) + ' = ap.GrantPrivilegeMask' +
		' FROM #FilteredNodes fn INNER JOIN #AggregatePrivileges ap' +
		' ON fn.Root = ap.Root AND fn.Node = ap.Node AND ap.AppName = ''' + @app + ''''
		EXEC (@execStmt);

		FETCH NEXT FROM AppListCursor
		INTO @app;
	END;

	-- Now select all of the org recs along with the roles that were requested
	SELECT [fn].*,
		--[fn].[Context], 
		--[fn].[HierarchyName], 
		--[fn].[VersionID], 
		--[fn].[Root], 
		--[fn].[Node], 
		--[fn].[SubhierarchyContext], 
		--[fn].[SubhierarchyName], 
		--[fn].[SubhierarchyVersionID], 
		--[fn].[SubhierarchyRoot], 
		--[fn].[ParentContext], 
		--[fn].[ParentHierarchyName], 
		--[fn].[ParentVersionID], 
		--[fn].[ParentRoot], 
		--[fn].[Parent], 
		--[fn].[InternalSortPosition], 
		--[fn].[ExternalSortPosition], 
		--[fn].[Type], 
		--[fn].[Label], 
		--[fn].[SourcingHierarchyContext], 
		--[fn].[Name], 
		--[fn].[Abbreviation], 
		--[fn].[Status], 
		--[fn].[Description], 
		--[fn].[IsLeaf], 
		--[fn].[IsSHRoot], 
		--[fn].[Generation], 
		--[fn].[Position], 
		--[fn].[InheritedStatus], 
		--[fn].[Ancestry], 
		--[fn].[AbbreviationBreadCrumb], 
		--[fn].[NameBreadCrumb], 
		--[fn].[PositionBreadCrumb], 
		--[fn].[SortBreadCrumb],
		[hac].[Grantee],
		[hac].[GranteeSourceSystem],
		[hac].[AppID],
		[hac].[RoleTypeID],
		[hac].[Privileges],
		[hac].[Reason],
		[hac].[CreatedBy],
		[hac].[CreatedBySourceSystem],
		[hac].[CreatedDate],
		[hac].[ExpirationDate],
		[hac].[ModifiedBy],
		[hac].[ModifiedBySourceSystem],
		[hac].[ModifiedDate],
		[hac].[NotificationStatus],
		[hac].[NotificationDate],
		p.ID AS Bemsid,
		p.DisplayName AS DisplayName,
		mb.ID AS ModBemsid,
		mb.DisplayName AS ModName,
		rt.DisplayName AS RoleName,
		a.Name AS AppName,
		a.DisplayName AS AppDisplayName
	FROM HierarchicalAC hac
		INNER JOIN Personnel p
			ON hac.Grantee = p.ID
				AND hac.GranteeSourceSystem = p.SourceSystem
		INNER JOIN @PersonnelList pl
			ON p.ID = pl.ID
				AND p.SourceSystem = pl.SourceSystem
		INNER JOIN @RoleList rl
			ON hac.AppID = rl.AppID
				AND hac.RoleTypeID = rl.RoleTypeID
		INNER JOIN RoleTypes rt
			ON rl.AppID = rt.AppID
				AND rl.RoleTypeID = rt.RoleTypeID
		INNER JOIN Applications a
			ON rl.AppID = a.ID
		INNER JOIN Personnel mb
			ON COALESCE(hac.ModifiedBy, hac.CreatedBy) = mb.ID
				AND COALESCE(hac.ModifiedBySourceSystem, hac.CreatedBySourceSystem) = mb.SourceSystem
		RIGHT JOIN #FilteredNodes fn
			ON hac.Context = @context
				AND hac.Context = fn.Context
				AND hac.Root = fn.Root
				AND hac.Node = fn.Node
				AND (@expiredType = 'All'
					OR (@expiredType = 'Valid'
						AND hac.ExpirationDate > @expiredDate)
					OR (@expiredType = 'Expired'
						AND hac.ExpirationDate <= @expiredDate)
				)
	ORDER BY SortBreadCrumb, rl.AppID, rl.RoleTypeID, p.DisplayName;
END