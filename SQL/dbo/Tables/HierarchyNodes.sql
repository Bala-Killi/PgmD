CREATE TABLE [dbo].[HierarchyNodes] (
    [Context]              VARCHAR (50)     NOT NULL,
    [HierarchyName]        VARCHAR (255)    NOT NULL,
    [VersionID]            INT              NOT NULL,
    [Root]                 INT              NOT NULL,
    [Node]                 INT              NOT NULL,
    [ParentContext]        VARCHAR (50)     NULL,
    [ParentHierarchyName]  VARCHAR (255)    NULL,
    [ParentVersionID]      INT              NULL,
    [ParentRoot]           INT              NULL,
    [Parent]               INT              NULL,
    [InternalSortPosition] INT              NOT NULL,
    [ExternalSortPosition] DECIMAL (15, 15) NULL,
    [Type]                 TINYINT          NOT NULL,
    [Label]                VARCHAR (50)     NOT NULL,
    [OrgDetail]            VARCHAR (50)     NULL,
    CONSTRAINT [PK_HierarchyNodes] PRIMARY KEY CLUSTERED ([Context] ASC, [HierarchyName] ASC, [VersionID] ASC, [Root] ASC, [Node] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_HierarchyNodes_Hierarchies] FOREIGN KEY ([Context], [HierarchyName], [VersionID], [Root]) REFERENCES [dbo].[Hierarchies] ([Context], [HierarchyName], [VersionID], [Root]),
    CONSTRAINT [FK_HierarchyNodes_HierarchyNodes] FOREIGN KEY ([ParentContext], [ParentHierarchyName], [ParentVersionID], [ParentRoot], [Parent]) REFERENCES [dbo].[HierarchyNodes] ([Context], [HierarchyName], [VersionID], [Root], [Node]),
    CONSTRAINT [FK_HierarchyNodes_OrgEntities] FOREIGN KEY ([Node]) REFERENCES [dbo].[OrgEntities] ([ID])
);


GO
CREATE NONCLUSTERED INDEX [IX_HierarchyNodes_NODE]
    ON [dbo].[HierarchyNodes]([Node] ASC) WITH (FILLFACTOR = 90);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Type is a bitwise representation of the types of children a node can have. Bit 0 = presence of node(s) as children; Bit 1 = presence of subhierarchy(ies) as children. I.e., the node bitmask = 01 and the subhierachy bitmask = 10. If neither the node (bit 0) nor the subhierarchy bit (bit 1) are set, then the node has no children. I.e., it is a Leaf with a Type of 0 (bitwise = 00). If only the node bit is set, then the node only has node(s) for children and has a Type of 1 (bitwise = 01). If only the subhierarchy bit is set, then the node only has Subhierarchy(ies) for children and has a Type of 2 (bitwise = 10). If both node and hierarchy bits are set, then the node has at least 1 node and 1 subhierarchy as children and has a Type of 3 (bitwise = 11).', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'HierarchyNodes', @level2type = N'COLUMN', @level2name = N'Type';

