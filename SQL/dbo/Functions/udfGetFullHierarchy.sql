-- =============================================
-- Create date: 9/8/2010
-- Description: Retrieve all nodes for a specific hierarchy
-- =============================================
CREATE FUNCTION [dbo].[udfGetFullHierarchy](
	@context			varchar(50) = NULL,
	@hierarchyName					varchar(255) = NULL,
	@requestedVersion		int = NULL, -- if versionID is NULL, then get the most recent version
	@root					int = NULL, -- if specified, this would select only one hierarchy within a hierarchy type
	@classificationType		varchar(50) = NULL, -- choices are any Classification from HierachyClassifications or any classification if NULL
	@sortOrderType			varchar(50) = NULL -- choices are 'abbreviation', 'name' and 'position'. NULL indicates no particular sort order.
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
	Description					varchar(max),
	IsLeaf						tinyint,
	IsSHRoot					tinyint,
	Generation					int,
	Position					varchar(50),
	InheritedStatus				varchar(50),
	Ancestry					varchar(max),
	AbbreviationBreadCrumb		varchar(max),
	NameBreadCrumb				varchar(max),
	PositionBreadCrumb			varchar(max),
	SortBreadCrumb				nvarchar(max)
	PRIMARY KEY (Root, Node)
)
AS BEGIN
	
	DECLARE @classification varchar(50)
	DECLARE @version int
	DECLARE @generation int
	DECLARE @Parents TABLE (
		Root					int,
		Node					int,
		InheritedStatus			varchar(50),
		Ancestry				varchar(max),
		AbbreviationBreadCrumb	varchar(max),
		NameBreadCrumb			varchar(max),
		PositionBreadCrumb		varchar(max),
		SortBreadCrumb			nvarchar(max)
		PRIMARY KEY (Root, Node)
	)
	DECLARE @Children TABLE(
		Root	int,
		Node	int,
		Parent	int
		PRIMARY KEY (Root, Node)
	)

	-- Get the version and classification
	SELECT @version = COALESCE(@requestedVersion, VersionID),
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
		)

	DECLARE hierarchyCursor CURSOR FOR SELECT Root
	FROM Hierarchies
	WHERE Context = @context
		AND HierarchyName = @hierarchyName
		AND VersionID = @version
		AND Root = ISNULL(@root, Root)
	OPEN hierarchyCursor
	FETCH NEXT FROM hierarchyCursor
	INTO @root

	WHILE (@@FETCH_STATUS = 0) BEGIN
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
			OrgDetail,
			Location,
			LocationOther,
			SourcingHierarchyContext,
			Name,
			Abbreviation,
			Alias,
			Status,
			Description,
			CASE WHEN Type = 0 THEN 1 ELSE 0 END,
			CASE WHEN SubhierarchyRoot = Node THEN 1 ELSE 0 END,
			NULL,
			RIGHT(REPLICATE('0', 19) + CAST(COALESCE(InternalSortPosition, 0) + COALESCE(ExternalSortPosition, 0.000000000000000) AS varchar(19)), 19),
			NULL,
			NULL,
			NULL,
			NULL,
			NULL,
			NULL
		FROM udfGetExpandedHierarchy(@context, @hierarchyName, @requestedVersion, @root, @classificationType);

		FETCH NEXT FROM hierarchyCursor
		INTO @root
	END
	CLOSE hierarchyCursor
	DEALLOCATE hierarchyCursor

	-- Update the data by looping through each generation. We need to get the generation, sorting breadcrumbs, first and last child
	SET @generation = 0

	-- Start by initializing the parent and children table variables
	INSERT INTO @Children
	SELECT Root,
		Node,
		Parent
	FROM @AllNodes
	WHERE Parent IS NULL

	INSERT INTO @Parents
	SELECT Root,
		Node,
		NULL,
		NULL,
		NULL,
		NULL,
		NULL,
		NULL
	FROM @Children

	WHILE @@ROWCOUNT > 0 BEGIN
		-- Update the collected hierarchy with the information that is generational.
		-- Note: the status value(s) in the when clause of the case statement for InheritedStatus are for any type of status that should be inherited by the children. Currently, only Inactive statuses are inherited.
		UPDATE @AllNodes
		SET Generation = @generation,
			InheritedStatus = COALESCE(p.InheritedStatus, CASE WHEN an.Status = 'Inactive' THEN an.Status ELSE NULL END),
			Ancestry = COALESCE(p.Ancestry + ',', '') + CAST(an.Node AS varchar(10)),
			AbbreviationBreadCrumb = COALESCE(p.AbbreviationBreadCrumb + '>>', '') + COALESCE(an.Abbreviation, an.Name),
			NameBreadCrumb = COALESCE(p.NameBreadCrumb + '>>', '') + an.Name,
			PositionBreadCrumb = COALESCE(p.PositionBreadCrumb + '>>', '') + an.Position,
			SortBreadCrumb = COALESCE(p.SortBreadCrumb + NCHAR(9), '') +
			CASE @sortOrderType
				WHEN 'Abbreviation' THEN COALESCE(an.Abbreviation, an.Name)
				WHEN 'Name' THEN an.Name
				-- Temporarily do sort by abbreviation whenever position is requested
				-- WHEN 'Position' THEN an.Position
				WHEN 'Position' THEN COALESCE(an.Abbreviation, an.Name)
				ELSE NULL
			END
		FROM @AllNodes an
			INNER JOIN @Children c
				-- First limit the records found to only the children of interest
				ON an.Root = c.Root
					AND an.Node = c.Node
			LEFT JOIN @Parents p
				-- Find the parents of the children of interest
				ON c.Root = p.Root
					AND ISNULL(c.Parent, c.Node) = p.Node;

		SET @generation = @generation + 1;

		DELETE
		FROM @Parents;

		-- Note: the status value(s) in the case statement for InheritedStatus are for any type of status that should be
		--    inherited by the children. Currently, only Inactive statuses are inherited.
		INSERT INTO @Parents
		SELECT c.Root,
			c.Node,
			COALESCE(an.InheritedStatus, CASE
				WHEN an.Status = 'Inactive' THEN an.Status
				ELSE NULL
			END),
			an.Ancestry,
			an.AbbreviationBreadCrumb,
			an.NameBreadCrumb,
			an.PositionBreadCrumb,
			an.SortBreadCrumb
		FROM @AllNodes an
			INNER JOIN @Children c
				-- First limit the records found to only the children we are copying to parents
				ON an.Root = c.Root
					AND an.Node = c.Node

		DELETE
		FROM @Children;

		INSERT INTO @Children
		SELECT an.Root,
			an.Node,
			an.Parent
		FROM @AllNodes an
			INNER JOIN @Parents p
				-- Find the new children of interest
				ON an.Root = p.Root
					AND an.Parent = p.Node;
	END;
	RETURN
END