-- =============================================
-- Create date: 9/10/2010
-- Description: Retrieve a hierarchy based on input parameters
-- =============================================
CREATE PROCEDURE [dbo].[uspGetHierarchy] 
	@context			varchar(50) = NULL,
	@hierarchyName		varchar(255) = NULL,
	@requestedVersion	int = NULL, -- if versionID is NULL, then get the most recent version
	@root				int = NULL, -- if specified, this would select only one hierarchy within a hierarchy type
	@classificationType	varchar(50) = NULL, -- choices are any Classification from HierachyClassifications or any classification if NULL
	@sortOrderType		varchar(50) = NULL, -- choices are 'abbreviation', 'name' and 'position'. NULL indicates no particular sort order.
	-- The next set of parms filter the rows selected. Note: these filters account for the inclusion of all ancestors or exclusion of all descendants.
	-- These filters are:
	--		1) inclusion of records (and their ancestors) with text found in the long or short name,
	--		2) inclusion of records (and their ancestors) with specified label(s),
	--		3) exclusion of records (and their descendants) with specified status(es),
	@filterType			tinyint, -- 0 = no filter, 1 = partial match filter, 2 = word match filter, 3 = exact match filter
	@filterValue		varchar(50) = NULL, -- if specified, this will be used to search names and abbreviations
	@includeLabelList	varchar(1024) = NULL, -- if specified, this comma separated list will be used to search for node labels.
	@excludeStatusList	varchar(255) = NULL, -- if specified, this comma separated list will be used to exclude orgs with any of the statuses
	-- The next set of parms add optional attributes (columns). Note: these filters account for the inclusion of all ancestors or exclusion of all descendants.
	@appNameList		varchar(max) = NULL, -- if specified, this comma separated list will be used to specify the applications for which privileges need to be retrieved.
	@userId				varchar(50) = NULL, -- if specified, this will be used to determine the user whose privileges are desired
	@userSourceSystem	varchar(50) = NULL, -- if specified, used to determine the user whose privileges are desired. If NULL, don't return privileges
	@oeRole				varchar(50) = NULL, -- if specified, used to indicate the type of role info to be returned. E.g., 'PM' would return program manager role info.
	@IncludeApp			tinyint = 1	-- 1: Return application info, 0: don't return app info
AS BEGIN
	SET NOCOUNT ON;
	-- Define all of the bit masks used to manipulate privileges --
	DECLARE @metadataWriteMask int,
		@unrestrictedWriteMask int,
		@restrictedWriteMask int,
		@defaultUserPriv int,
		@adminPriv int,
		@removeWrite int,
		@basePriv int,
		@appIdx int,
		@appCount int,
		@app varchar(50),
		@execStmt varchar(max)

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
		OrgDetail varchar(50),
		SourcingHierarchyContext varchar(50),
		Name varchar(255),
		Abbreviation varchar(50),
		Alias varchar(255),
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
		PRIMARY KEY (Root, Node)
	)

	DECLARE @AppList TABLE(
		AppID int,
		AppName varchar(50),
		AllPrivileges int
	)
	--IF OBJECT_ID('tempdb..#FilteredNodes') IS NOT NULL DROP TABLE #FilteredNodes
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
		OrgDetail varchar(50),
		SourcingHierarchyContext varchar(50),
		Name varchar(255),
		Abbreviation varchar(50),
		Alias varchar(255),
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
		SortBreadCrumb nvarchar(max),
		PRIMARY KEY (Root, Node)
	)
	
	--IF OBJECT_ID('tempdb..#AggregatePrivileges') IS NOT NULL DROP TABLE #AggregatePrivileges
	CREATE TABLE #AggregatePrivileges(
		Root int,
		Node int,
		AppID int,
		AppName varchar(50),
		Privileges int
	)

	INSERT INTO @AllNodes
	SELECT [Context],
			[HierarchyName],
			[VersionID],
			[Root],
			[Node],
			[SubhierarchyContext],
			[SubhierarchyName],
			[SubhierarchyVersionID],
			[SubhierarchyRoot],
			[ParentContext],
			[ParentHierarchyName],
			[ParentVersionID],
			[ParentRoot],
			[Parent],
			[InternalSortPosition],
			[ExternalSortPosition],
			[Type],
			[Label],
			[OrgDetail],
			[SourcingHierarchyContext],
			[Name],
			[Abbreviation],
			[Alias],
			[Status],
			[Description],
			[IsLeaf],
			[IsSHRoot],
			[Generation],
			[Position],
			[InheritedStatus],
			[Ancestry],
			[AbbreviationBreadCrumb],
			[NameBreadCrumb],
			[PositionBreadCrumb],
			[SortBreadCrumb]
	FROM udfGetFullHierarchy(@context, @hierarchyName, @requestedVersion, @root, @classificationType, @sortOrderType)
	WHERE (',' + @excludeStatusList + ',' NOT LIKE '%,' + COALESCE(InheritedStatus, '') + ',%'
		AND @excludeStatusList IS NOT NULL)
		OR @excludeStatusList IS NULL;
	
	-- This filter section will include records matching filterValue in abbreviation or name as well as records with the specified labels.
	-- All ancestors of the records found will also be included in this section
	IF (@filterType = 0) BEGIN
		IF (@includeLabelList IS NOT NULL) BEGIN
			INSERT INTO #FilteredNodes
			SELECT DISTINCT	[an1].[Context],
							[an1].[HierarchyName],
							[an1].[VersionID],
							[an1].[Root],
							[an1].[Node],
							[an1].[SubhierarchyContext],
							[an1].[SubhierarchyName],
							[an1].[SubhierarchyVersionID],
							[an1].[SubhierarchyRoot],
							[an1].[ParentContext],
							[an1].[ParentHierarchyName],
							[an1].[ParentVersionID],
							[an1].[ParentRoot],
							[an1].[Parent],
							[an1].[InternalSortPosition],
							[an1].[ExternalSortPosition],
							[an1].[Type],
							[an1].[Label],
							[an1].[OrgDetail],
							[an1].[SourcingHierarchyContext],
							[an1].[Name],
							[an1].[Abbreviation],
							[an1].[Alias],
							[an1].[Status],
							[an1].[Description],
							[an1].[IsLeaf],
							[an1].[IsSHRoot],
							[an1].[Generation],
							[an1].[Position],
							[an1].[InheritedStatus],
							[an1].[Ancestry],
							[an1].[AbbreviationBreadCrumb],
							[an1].[NameBreadCrumb],
							[an1].[PositionBreadCrumb],
							[an1].[SortBreadCrumb]
			FROM @AllNodes an1
				INNER JOIN @AllNodes an2
					ON an1.Root = an2.Root
						AND ',' + an2.Ancestry + ',' LIKE '%,' + CAST(an1.Node AS varchar(10)) + ',%'
				INNER JOIN udfParseColumnString(COALESCE(@includeLabelList, ''), ',') l
					ON an2.Label = l.Value
						AND l.Value IS NOT NULL;
		END ELSE BEGIN
			INSERT INTO #FilteredNodes
			SELECT [Context],
					[HierarchyName],
					[VersionID],
					[Root],
					[Node],
					[SubhierarchyContext],
					[SubhierarchyName],
					[SubhierarchyVersionID],
					[SubhierarchyRoot],
					[ParentContext],
					[ParentHierarchyName],
					[ParentVersionID],
					[ParentRoot],
					[Parent],
					[InternalSortPosition],
					[ExternalSortPosition],
					[Type],
					[Label],
					[OrgDetail],
					[SourcingHierarchyContext],
					[Name],
					[Abbreviation],
					[Alias],
					[Status],
					[Description],
					[IsLeaf],
					[IsSHRoot],
					[Generation],
					[Position],
					[InheritedStatus],
					[Ancestry],
					[AbbreviationBreadCrumb],
					[NameBreadCrumb],
					[PositionBreadCrumb],
					[SortBreadCrumb]
			FROM @AllNodes;
		END;
	END ELSE BEGIN
		IF (@filterType = 1 OR @filterType = 3) BEGIN
			IF (@filterType = 1) BEGIN
				SET @filterValue = '%' + CAST(@filterValue AS varchar(48)) + '%';
			END
			IF (@includeLabelList IS NOT NULL) BEGIN
				INSERT INTO #FilteredNodes
				SELECT DISTINCT	[an1].[Context],
								[an1].[HierarchyName],
								[an1].[VersionID],
								[an1].[Root],
								[an1].[Node],
								[an1].[SubhierarchyContext],
								[an1].[SubhierarchyName],
								[an1].[SubhierarchyVersionID],
								[an1].[SubhierarchyRoot],
								[an1].[ParentContext],
								[an1].[ParentHierarchyName],
								[an1].[ParentVersionID],
								[an1].[ParentRoot],
								[an1].[Parent],
								[an1].[InternalSortPosition],
								[an1].[ExternalSortPosition],
								[an1].[Type],
								[an1].[Label],
								[an1].[OrgDetail],
								[an1].[SourcingHierarchyContext],
								[an1].[Name],
								[an1].[Abbreviation],
								[an1].[Alias],
								[an1].[Status],
								[an1].[Description],
								[an1].[IsLeaf],
								[an1].[IsSHRoot],
								[an1].[Generation],
								[an1].[Position],
								[an1].[InheritedStatus],
								[an1].[Ancestry],
								[an1].[AbbreviationBreadCrumb],
								[an1].[NameBreadCrumb],
								[an1].[PositionBreadCrumb],
								[an1].[SortBreadCrumb]
				FROM @AllNodes an1
					INNER JOIN @AllNodes an2
						ON an1.Root = an2.Root
							AND (
							an2.Name LIKE @filterValue
							OR an2.Abbreviation LIKE @filterValue
							)
							AND ',' + an2.Ancestry + ',' LIKE '%,' + CAST(an1.Node AS varchar(10)) + ',%'
					INNER JOIN udfParseColumnString(COALESCE(@includeLabelList, ''), ',') l
						ON an2.Label = l.Value
							AND l.Value IS NOT NULL;
			END ELSE BEGIN
				INSERT INTO #FilteredNodes
				SELECT DISTINCT	[an1].[Context],
								[an1].[HierarchyName],
								[an1].[VersionID],
								[an1].[Root],
								[an1].[Node],
								[an1].[SubhierarchyContext],
								[an1].[SubhierarchyName],
								[an1].[SubhierarchyVersionID],
								[an1].[SubhierarchyRoot],
								[an1].[ParentContext],
								[an1].[ParentHierarchyName],
								[an1].[ParentVersionID],
								[an1].[ParentRoot],
								[an1].[Parent],
								[an1].[InternalSortPosition],
								[an1].[ExternalSortPosition],
								[an1].[Type],
								[an1].[Label],
								[an1].[OrgDetail],
								[an1].[SourcingHierarchyContext],
								[an1].[Name],
								[an1].[Abbreviation],
								[an1].[Alias],
								[an1].[Status],
								[an1].[Description],
								[an1].[IsLeaf],
								[an1].[IsSHRoot],
								[an1].[Generation],
								[an1].[Position],
								[an1].[InheritedStatus],
								[an1].[Ancestry],
								[an1].[AbbreviationBreadCrumb],
								[an1].[NameBreadCrumb],
								[an1].[PositionBreadCrumb],
								[an1].[SortBreadCrumb]
				FROM @AllNodes an1
					INNER JOIN @AllNodes an2
						ON an1.Root = an2.Root
							AND (
							an2.Name LIKE @filterValue
							OR an2.Abbreviation LIKE @filterValue
							)
							AND ',' + an2.Ancestry + ',' LIKE '%,' + CAST(an1.Node AS varchar(10)) + ',%';
			END
		END ELSE BEGIN
			IF (@filterType = 2) BEGIN
				SET @filterValue = LTRIM(RTRIM(@filterValue));
				IF (@includeLabelList IS NOT NULL) BEGIN
					INSERT INTO #FilteredNodes
					SELECT DISTINCT	[an1].[Context],
									[an1].[HierarchyName],
									[an1].[VersionID],
									[an1].[Root],
									[an1].[Node],
									[an1].[SubhierarchyContext],
									[an1].[SubhierarchyName],
									[an1].[SubhierarchyVersionID],
									[an1].[SubhierarchyRoot],
									[an1].[ParentContext],
									[an1].[ParentHierarchyName],
									[an1].[ParentVersionID],
									[an1].[ParentRoot],
									[an1].[Parent],
									[an1].[InternalSortPosition],
									[an1].[ExternalSortPosition],
									[an1].[Type],
									[an1].[Label],
									[an1].[OrgDetail],
									[an1].[SourcingHierarchyContext],
									[an1].[Name],
									[an1].[Abbreviation],
									[an1].[Alias],
									[an1].[Status],
									[an1].[Description],
									[an1].[IsLeaf],
									[an1].[IsSHRoot],
									[an1].[Generation],
									[an1].[Position],
									[an1].[InheritedStatus],
									[an1].[Ancestry],
									[an1].[AbbreviationBreadCrumb],
									[an1].[NameBreadCrumb],
									[an1].[PositionBreadCrumb],
									[an1].[SortBreadCrumb]
					FROM @AllNodes an1
						INNER JOIN @AllNodes an2
							ON an1.Root = an2.Root
								AND (' ' + an2.Name + ' ' LIKE '%[^a-z0-9]' + @filterValue + '[^a-z0-9]%'
								OR an2.Name = @filterValue
								OR ' ' + an2.Abbreviation + ' ' LIKE '%[^a-z0-9]' + @filterValue + '[^a-z0-9]%'
								OR an2.Abbreviation = @filterValue
								)
								AND ',' + an2.Ancestry + ',' LIKE '%,' + CAST(an1.Node AS varchar(10)) + ',%'
						INNER JOIN udfParseColumnString(COALESCE(@includeLabelList, ''), ',') l
							ON an2.Label = l.Value
								AND l.Value IS NOT NULL;
				END ELSE BEGIN
					INSERT INTO #FilteredNodes
					SELECT DISTINCT	[an1].[Context],
									[an1].[HierarchyName],
									[an1].[VersionID],
									[an1].[Root],
									[an1].[Node],
									[an1].[SubhierarchyContext],
									[an1].[SubhierarchyName],
									[an1].[SubhierarchyVersionID],
									[an1].[SubhierarchyRoot],
									[an1].[ParentContext],
									[an1].[ParentHierarchyName],
									[an1].[ParentVersionID],
									[an1].[ParentRoot],
									[an1].[Parent],
									[an1].[InternalSortPosition],
									[an1].[ExternalSortPosition],
									[an1].[Type],
									[an1].[Label],
									[an1].[OrgDetail],
									[an1].[SourcingHierarchyContext],
									[an1].[Name],
									[an1].[Abbreviation],
									[an1].[Alias],
									[an1].[Status],
									[an1].[Description],
									[an1].[IsLeaf],
									[an1].[IsSHRoot],
									[an1].[Generation],
									[an1].[Position],
									[an1].[InheritedStatus],
									[an1].[Ancestry],
									[an1].[AbbreviationBreadCrumb],
									[an1].[NameBreadCrumb],
									[an1].[PositionBreadCrumb],
									[an1].[SortBreadCrumb]
					FROM @AllNodes an1
						INNER JOIN @AllNodes an2
							ON an1.Root = an2.Root
								AND (' ' + an2.Name + ' ' LIKE '%[^a-z0-9]' + @filterValue + '[^a-z0-9]%'
								OR an2.Name = @filterValue
								OR ' ' + an2.Abbreviation + ' ' LIKE '%[^a-z0-9]' + @filterValue + '[^a-z0-9]%'
								OR an2.Abbreviation = @filterValue
								)
								AND ',' + an2.Ancestry + ',' LIKE '%,' + CAST(an1.Node AS varchar(10)) + ',%';
				END;
			END;
		END;
	END;

	WITH FilteredNodes AS (
		SELECT [Context],
				[HierarchyName],
				[VersionID],
				[Root],
				[Node],
				[SubhierarchyContext],
				[SubhierarchyName],
				[SubhierarchyVersionID],
				[SubhierarchyRoot],
				[ParentContext],
				[ParentHierarchyName],
				[ParentVersionID],
				[ParentRoot],
				[Parent],
				[InternalSortPosition],
				[ExternalSortPosition],
				[Type],
				[Label],
				[OrgDetail],
				[SourcingHierarchyContext],
				[Name],
				[Abbreviation],
				[Alias],
				[Status],
				[Description],
				[IsLeaf],
				[IsSHRoot],
				[Generation],
				[Position],
				[InheritedStatus],
				[Ancestry],
				[AbbreviationBreadCrumb],
				[NameBreadCrumb],
				[PositionBreadCrumb],
				[SortBreadCrumb]
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

	-- If the userSourceSystem is Null, then privileges are not being retrieved and there is no need to update the privileges in the returned record set
	IF (@userSourceSystem IS NOT NULL) BEGIN
		-- First determine the applications for which privileges are being sought.
		IF (@appNameList IS NOT NULL) BEGIN
			INSERT INTO @AppList
			SELECT a.ID,
					a.Name,
					apa.AllPrivileges
			FROM ApplicationPrivilegeAttributes apa
				INNER JOIN Applications a
					ON apa.AppID = a.ID
						AND apa.Context = @context
				INNER JOIN udfParseColumnString(@appNameList, ',') an
					ON a.Name = an.Value;
		END ELSE BEGIN
			INSERT INTO @AppList
			SELECT a.ID,
					a.Name,
					apa.AllPrivileges
			FROM ApplicationPrivilegeAttributes apa
				INNER JOIN Applications a
					ON apa.AppID = a.ID
						AND apa.Context = @context;
		END

		SELECT @appCount = COUNT(*)
		FROM @AppList

		-- Retrieve all of the hierarchical privilege masks
		SELECT @metadataWriteMask = CAST(Value AS int)
		FROM ApplicationConfiguration
		WHERE Name = 'MetadataWriteMask';		-- 0...0 0000 1000

		SELECT @unrestrictedWriteMask = CAST(Value AS int)
		FROM ApplicationConfiguration
		WHERE Name = 'UnrestrictedWriteMask';	-- 0...0 0010 0000

		SELECT @restrictedWriteMask = CAST(Value AS int)
		FROM ApplicationConfiguration
		WHERE Name = 'RestrictedWriteMask';		-- 0...0 1000 0000

		SELECT @defaultUserPriv = CAST(Value AS int)
		FROM ApplicationConfiguration
		WHERE Name = 'DefaultUserPriv';			-- 0...0 0001 0100

		SELECT @adminPriv = CAST(Value AS int)
		FROM ApplicationConfiguration
		WHERE Name = 'AdminPriv';				-- 0...0 1111 1111

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
			COALESCE(
			MAX(0x00000001 & hac.Privileges) | MAX(0x00000002 & hac.Privileges) | MAX(0x00000004 & hac.Privileges) | MAX(0x00000008 & hac.Privileges) |
			MAX(0x00000010 & hac.Privileges) | MAX(0x00000020 & hac.Privileges) | MAX(0x00000040 & hac.Privileges) | MAX(0x00000080 & hac.Privileges) |
			MAX(0x00000100 & hac.Privileges) | MAX(0x00000200 & hac.Privileges) | MAX(0x00000400 & hac.Privileges) | MAX(0x00000800 & hac.Privileges) |
			MAX(0x00001000 & hac.Privileges) | MAX(0x00002000 & hac.Privileges) | MAX(0x00004000 & hac.Privileges) | MAX(0x00008000 & hac.Privileges) |
			MAX(0x00010000 & hac.Privileges) | MAX(0x00020000 & hac.Privileges) | MAX(0x00040000 & hac.Privileges) | MAX(0x00080000 & hac.Privileges) |
			MAX(0x00100000 & hac.Privileges) | MAX(0x00200000 & hac.Privileges) | MAX(0x00400000 & hac.Privileges) | MAX(0x00800000 & hac.Privileges) |
			MAX(0x01000000 & hac.Privileges) | MAX(0x02000000 & hac.Privileges) | MAX(0x04000000 & hac.Privileges) | MAX(0x08000000 & hac.Privileges) |
			MAX(0x10000000 & hac.Privileges) | MAX(0x20000000 & hac.Privileges) | MAX(0x40000000 & hac.Privileges) | MAX(0x80000000 & hac.Privileges), 0x00000000) &
			MAX(al.AllPrivileges) AS Privileges
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
		GROUP BY fn.Root,
			fn.Node,
			al.AppID,
			al.AppName;

		-- Modify the aggregated privileges for PgmD with the default base privs and remove write privs
		-- if the node is not part of the sourcing hierarchy type, even for admins
		SET @removeWrite = ~(@metadataWriteMask | @unrestrictedWriteMask | @restrictedWriteMask);

		UPDATE #AggregatePrivileges
		SET Privileges = CASE
					WHEN fn.Context = fn.SourcingHierarchyContext THEN COALESCE(ap.Privileges | @basePriv, @basePriv)
					ELSE COALESCE(ap.Privileges | @basePriv, @basePriv) & @removeWrite
				END
		FROM #FilteredNodes fn
			INNER JOIN #AggregatePrivileges ap
				ON fn.Root = ap.Root
					AND fn.Node = ap.Node
					AND ap.AppName = 'PgmD';

		IF @IncludeApp = 1 BEGIN
			ALTER TABLE #FilteredNodes ADD AppCount int;
			UPDATE #FilteredNodes SET AppCount = @appCount;

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
				' Privileges' + CAST(@appIdx AS varchar(3)) + ' int';
				EXEC (@execStmt);

				SET @execStmt = 'UPDATE #FilteredNodes' +
				' SET AppID' + CAST(@appIdx AS varchar(3)) + ' = ap.AppID,' +
				' AppName' + CAST(@appIdx AS varchar(3)) + ' = ap.AppName,' +
				' Privileges' + CAST(@appIdx AS varchar(3)) + ' = ap.Privileges' +
				' FROM #FilteredNodes fn INNER JOIN #AggregatePrivileges ap' +
				' ON fn.Root = ap.Root AND fn.Node = ap.Node AND ap.AppName = ''' + @app + ''''
				EXEC (@execStmt);

				FETCH NEXT FROM AppListCursor
				INTO @app;
			END;
		END;
	END;

	--// Gather Personnel Info for these organization
	DECLARE @PerInfo TABLE (NodeId int, ModDate datetime, PersonID int, SourceSys varchar(20), RoleTitle varchar(255), 
		RoleId int, JobCode varchar(50), DisplayName varchar(255), Country varchar(10))
	INSERT INTO @PerInfo
		SELECT DISTINCT OEId, ModifiedDate, PersonID, t.SourceSystem, RoleTitle, RoleTypeID, p.JobCode, p.DisplayName, p.Country
		FROM (
			SELECT *, ROW_NUMBER() OVER (PARTITION BY OEId, RoleTypeID ORDER BY ModifiedDate DESC) As rn
			FROM OERolePersonnel
		) t JOIN Personnel p ON t.PersonID=p.Id
		WHERE rn = 1 AND t.OEID IN (SELECT DISTINCT Node FROM #FilteredNodes)
	
	--// Add Personnel info to FilteredNodes table
	ALTER TABLE #FilteredNodes
	ADD PMBemsid varchar(50),
		PMSource varchar(50),
		PMDisplayName varchar(255),
		PMTitle varchar(50),
		PMSjc varchar(10),
		DeputyBemsId varchar(50),
		DeputyDisplayName varchar(255),
		DeputySjc varchar(10),
		PioBemsId varchar(50),
		PioDisplayName varchar(255),
		PioSjc varchar(10),
		IptBemsId varchar(50),
		IptDisplayName varchar(255),
		IptSjc varchar(10),
		EngineerBemsId varchar(50),
		EngineerDisplayName varchar(255),
		SeitBemsId varchar(50),
		SeitDisplayName varchar(255)
	
	UPDATE fn
		SET PMBemsid = o.PersonId,
			PMSource = o.SourceSys,
			PMDisplayName = o.DisplayName,
			PMTitle = o.RoleTitle,
			PMSjc = o.JobCode,
			DeputyBemsId = d.PersonId,
			DeputyDisplayName = d.DisplayName,
			DeputySjc = d.JobCode,
			PioBemsId = pio.PersonId,
			PioDisplayName = pio.DisplayName,
			PioSjc = pio.JobCode,
			IptBemsId = Ipt.PersonId,
			IptDisplayName = Ipt.DisplayName,
			IptSjc = Ipt.JobCode,
			EngineerBemsId = ce.PersonId,
			EngineerDisplayName = ce.DisplayName,
			SeitBemsId = s.PersonId,
			SeitDisplayName = s.DisplayName
	FROM #FilteredNodes fn
	LEFT JOIN @PerInfo o ON fn.Node=o.NodeId AND o.RoleId=4			--// Org leader
	LEFT JOIN @PerInfo d ON fn.Node=d.NodeId AND d.RoleId=5			--// deputy
	LEFT JOIN @PerInfo ce ON fn.Node=ce.NodeId AND ce.RoleId=6		--// c.engr
	LEFT JOIN @PerInfo s ON fn.Node=s.NodeId AND s.RoleId=7			--// Seit
	LEFT JOIN @PerInfo pio ON fn.Node=pio.NodeId AND pio.RoleId=8	--// pio
	LEFT JOIN @PerInfo ipt ON fn.Node=ipt.NodeId AND ipt.RoleId=9	--// ipt

	SELECT *
	FROM #FilteredNodes
	ORDER BY SortBreadCrumb;
END