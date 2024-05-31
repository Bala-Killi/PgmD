-- =============================================
-- Create date: 9/8/2010
-- Description: Expand sub hierarchies for the requested hierarchy
-- =============================================
CREATE FUNCTION [dbo].[udfGetExpandedHierarchy] (
	@context				varchar(50),
	@hierarchyName			varchar(255),
	@requestedVersion		int = NULL, -- if versionID is NULL, then get the most recent version
	@root					int,
	@classificationType		varchar(50) = NULL -- choices are any Classification from HierachyClassifications or any classification if NULL
)
RETURNS @AllNodes TABLE (
	Context						varchar(50) NOT NULL,
	HierarchyName				varchar(255) NOT NULL,
	VersionID					int NOT NULL,
	Root						int NOT NULL,
	Node						int,
	SubhierarchyContext			varchar(50),
	SubhierarchyName			varchar(255),
	SubhierarchyVersionID		int,
	SubhierarchyRoot			int,
	ParentContext				varchar(50),
	ParentHierarchyName			varchar(255),
	ParentVersionID				int,
	ParentRoot					int,
	Parent						int,
	InternalSortPosition		int,
	ExternalSortPosition		decimal(15,15),
	Type						Tinyint,
	Label						varchar(50),
	OrgDetail					varchar(50),	
	Location					varchar(50),
	LocationOther				varchar(50),
	SourcingHierarchyContext	varchar(50),
	Name						varchar(255),
	Abbreviation				varchar(50),
	Alias						varchar(255),
	Status						varchar(50),
	Description					varchar(max)
	PRIMARY KEY (Node)
)
AS BEGIN
	 
	DECLARE @version				int;
	DECLARE @versionDate			datetime;
	DECLARE @nextVersionDate		datetime;
	DECLARE @classification			varchar(50);
	DECLARE @NodeBitMask			tinyint;
	DECLARE @SubhierarchyBitMask	tinyint;
	DECLARE @OE TABLE (
		OEID						int,
		ModifiedDate				datetime,
		SourcingHierarchyContext	varchar(50),
		Name						varchar(255),
		Abbreviation				varchar(50),
		Alias						varchar(255),
		Status						varchar(50),
		Description					varchar(max)
		PRIMARY KEY (OEID)
	);
	DECLARE @OEBySelectedDates TABLE (
		OEID			int,
		ModifiedDate	datetime
	);
	SET @NodeBitMask = 1;			-- bitstring '0001'
	SET @SubhierarchyBitMask = 2;	-- bitstring '0010'

	-- Get the version if not specified in the input parameters. Note: we will also get the context and hierarchyName
	-- from the table so that the case of the values match the database rather than the input fields
	IF (@requestedVersion IS NULL) BEGIN
		SELECT @version = VersionID,
			@context = Context,
			@hierarchyName = HierarchyName,
			@versionDate = VersionDate,
			@classification = Classification
		FROM HierarchyVersions
		WHERE Context = @context
			AND HierarchyName = @hierarchyName
			AND VersionDate = (
				SELECT MAX(VersionDate)
				FROM HierarchyVersions
				WHERE Context = @context
					AND HierarchyName = @hierarchyName
					AND Classification = ISNULL(@classificationType, Classification)
			);
	END ELSE BEGIN
		SELECT @version = @requestedVersion,
			@context = Context,
			@hierarchyName = HierarchyName,
			@versionDate = VersionDate,
			@classification = Classification
		FROM HierarchyVersions
		WHERE Context = @context
			AND HierarchyName = @hierarchyName
			AND VersionID = @requestedVersion;
	END;

	-- Get the next version date and classification. Note: these values can't be assigned in the above query
	--SELECT @nextVersionDate = COALESCE(MAX(VersionDate), GETDATE())
	SELECT TOP 1 @nextVersionDate=VersionDate 
	FROM HierarchyVersions
	WHERE Context = @context
		AND HierarchyName = @hierarchyName
		AND VersionDate > @versionDate
	ORDER BY VersionDate DESC

	-- Select the dates for the orgs to be included
	INSERT INTO @OEBySelectedDates
	SELECT OEID,
		MAX(ModifiedDate)
	FROM OEHistory
	WHERE Convert(Date,ModifiedDate) <= Convert(date, COALESCE(@nextVersionDate, GETDATE()))
	GROUP BY OEID

	-- Build up the OE table var for the appropriate date range. Start with the production set of OEs
	INSERT INTO @OE
	SELECT ID,
		COALESCE(ModifiedDate, CreatedDate),
		SourcingHierarchyContext,
		Name,
		Abbreviation,
		Alias,
		Status,
		Description
	FROM OrgEntities oe

	-- Update orgs with time appropriate data
	UPDATE @OE
	SET OEID = oeh.OEID,
		ModifiedDate = oeh.ModifiedDate,
		SourcingHierarchyContext = oeh.SourcingHierarchyContext,
		Name = oeh.Name,
		Abbreviation = oeh.Abbreviation,
		Alias = oeh.Alias,
		Status = oeh.Status,
		Description = oeh.Description
	FROM OEHistory oeh
		INNER JOIN @OEBySelectedDates oed
			ON oeh.OEID = oed.OEID
				AND oeh.ModifiedDate = oed.ModifiedDate
		INNER JOIN @OE oe
			ON oeh.OEID = oe.OEID

	-- Insert nodes that belong to the requested hierarchy
	INSERT INTO @AllNodes
	SELECT hn.Context,
		hn.HierarchyName,
		hn.VersionID,
		hn.Root,
		hn.Node,
		NULL,
		NULL,
		NULL,
		NULL,
		hn.ParentContext,
		hn.ParentHierarchyName,
		hn.ParentVersionID,
		hn.ParentRoot,
		hn.Parent,
		hn.InternalSortPosition,
		hn.ExternalSortPosition,
		0,
		hn.Label,
		hn.OrgDetail,		
		null,
		null,
		oe.SourcingHierarchyContext,
		oe.Name,
		oe.Abbreviation,
		oe.Alias,
		oe.Status,
		oe.Description
	FROM HierarchyNodes hn
		INNER JOIN @OE oe
			ON hn.Node = oe.OEID
				AND hn.Context = @context
				AND hn.HierarchyName = @hierarchyName
				AND hn.VersionID = @version
				AND hn.Root = @root

	-- Repeatedly insert nodes that belong to any attached subhierarchies in the requested hierarchy
	-- The iteration is to account for subhierarchies within subhierarchies. Use only the production version of subhierarchies
	WHILE @@ROWCOUNT > 0 BEGIN
	INSERT INTO @AllNodes
	SELECT @context,
		@hierarchyName,
		@version,
		@root,
		hn.Node,
		sh.ChildContext,
		sh.ChildHierarchyName,
		sh.ChildVersionID,
		sh.ChildRoot,
		COALESCE(hn.ParentContext, sh.Context),
		COALESCE(hn.ParentHierarchyName, sh.HierarchyName),
		COALESCE(hn.ParentVersionID, sh.VersionID),
		COALESCE(hn.ParentRoot, sh.Root),
		COALESCE(hn.Parent, sh.Parent),
		CASE
			WHEN sh.ChildRoot = hn.Node THEN sh.InternalSortPosition
			ELSE hn.InternalSortPosition
		END,
		CASE
			WHEN sh.ChildRoot = hn.Node THEN sh.ExternalSortPosition
			ELSE hn.ExternalSortPosition
		END,
		0,
		hn.Label,
		hn.OrgDetail,		
		null,
		null,
		oe.SourcingHierarchyContext,
		oe.Name,
		oe.Abbreviation,
		oe.Alias,
		oe.Status,
		oe.Description
	FROM HierarchyVersions hv
		INNER JOIN Subhierarchies sh
			ON hv.Context = sh.ChildContext
				AND hv.HierarchyName = sh.ChildHierarchyName
				AND hv.VersionID = sh.ChildVersionID
				AND hv.VersionDate = (
					SELECT MAX(VersionDate)
					FROM HierarchyVersions
					WHERE Context = sh.ChildContext
						AND HierarchyName = sh.ChildHierarchyName
						AND ((
							hv.Classification = 'Production'
								AND @classificationType IS NOT NULL
							)
							OR @classificationType IS NULL
						)
				)
		INNER JOIN HierarchyNodes hn
			ON hn.Context = sh.ChildContext
				AND hn.HierarchyName = sh.ChildHierarchyName
				AND hn.VersionID = sh.ChildVersionID
				AND hn.Root = sh.ChildRoot
		INNER JOIN @OE oe
			ON hn.Node = oe.OEID
	WHERE EXISTS (
			SELECT *
			FROM @AllNodes an1
			WHERE sh.Context = ISNULL(an1.SubhierarchyContext, an1.Context)
				AND sh.HierarchyName = ISNULL(an1.SubhierarchyName, an1.HierarchyName)
				AND sh.VersionID = ISNULL(an1.SubhierarchyVersionID, an1.VersionID)
				AND sh.Root = ISNULL(an1.SubhierarchyRoot, an1.Root)
		)
		AND NOT EXISTS (
			SELECT *
			FROM @AllNodes an2
			WHERE sh.ChildContext = ISNULL(an2.SubhierarchyContext, '')
				AND sh.ChildHierarchyName = ISNULL(an2.SubhierarchyName, '')
				AND sh.ChildVersionID = ISNULL(an2.SubhierarchyVersionID, '')
				AND sh.ChildRoot = ISNULL(an2.SubhierarchyRoot, '')
		)
	END;

	-- Update any parent node's Type. First, if added nodes, then set the node bit in Type
	WITH ChildNodes AS (
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
			OrgDetail,
			Location,
			LocationOther,
			SourcingHierarchyContext,
			Name,
			Abbreviation,
			Alias,
			Status,
			Description
		FROM @AllNodes
	)
	UPDATE @AllNodes
	SET Type = an1.Type | @NodeBitMask
	FROM @AllNodes an1
		INNER JOIN ChildNodes an2
			-- Find the children with parents
			ON an1.Node = an2.Parent
			-- Make sure to only include added nodes, not added subhierarchies
			AND (an2.SubhierarchyRoot <> an2.Node
				OR an2.SubhierarchyRoot IS NULL
			);

	-- Now update any parent node's Type by setting the subhierarchy bit for any added subhierarchy
	WITH ChildNodes
	AS (
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
			OrgDetail,
			Location,
			LocationOther,
			SourcingHierarchyContext,
			Name,
			Abbreviation,
			Alias,
			Status,
			Description
		FROM @AllNodes
	)
	UPDATE @AllNodes
	SET Type = an1.Type | @SubhierarchyBitMask
	FROM @AllNodes an1
		INNER JOIN ChildNodes an2
			-- Find the children with parents
			ON an1.Node = an2.Parent
				-- Make sure to only include added subhierarchies
				AND an2.SubhierarchyRoot = an2.Node
	RETURN
END