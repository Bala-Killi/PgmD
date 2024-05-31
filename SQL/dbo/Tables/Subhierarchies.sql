CREATE TABLE [dbo].[Subhierarchies] (
    [Context]              VARCHAR (50)     NOT NULL,
    [HierarchyName]        VARCHAR (255)    NOT NULL,
    [VersionID]            INT              NOT NULL,
    [Root]                 INT              NOT NULL,
    [ChildContext]         VARCHAR (50)     NOT NULL,
    [ChildHierarchyName]   VARCHAR (255)    NOT NULL,
    [ChildVersionID]       INT              NOT NULL,
    [ChildRoot]            INT              NOT NULL,
    [ParentContext]        VARCHAR (50)     NOT NULL,
    [ParentHierarchyName]  VARCHAR (255)    NOT NULL,
    [ParentVersionID]      INT              NOT NULL,
    [ParentRoot]           INT              NOT NULL,
    [Parent]               INT              NOT NULL,
    [InternalSortPosition] INT              NOT NULL,
    [ExternalSortPosition] DECIMAL (15, 15) NULL,
    CONSTRAINT [PK_Subhierarchies] PRIMARY KEY CLUSTERED ([Context] ASC, [HierarchyName] ASC, [VersionID] ASC, [Root] ASC, [ChildContext] ASC, [ChildHierarchyName] ASC, [ChildVersionID] ASC, [ChildRoot] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_Subhierarchies_Hierarchies] FOREIGN KEY ([Context], [HierarchyName], [VersionID], [Root]) REFERENCES [dbo].[Hierarchies] ([Context], [HierarchyName], [VersionID], [Root]),
    CONSTRAINT [FK_Subhierarchies_HierarchyNodes] FOREIGN KEY ([ParentContext], [ParentHierarchyName], [ParentVersionID], [ParentRoot], [Parent]) REFERENCES [dbo].[HierarchyNodes] ([Context], [HierarchyName], [VersionID], [Root], [Node]),
    CONSTRAINT [FK_Subhierarchies-Child_Hierarchies] FOREIGN KEY ([ChildContext], [ChildHierarchyName], [ChildVersionID], [ChildRoot]) REFERENCES [dbo].[Hierarchies] ([Context], [HierarchyName], [VersionID], [Root])
);

