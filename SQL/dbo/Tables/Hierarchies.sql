CREATE TABLE [dbo].[Hierarchies] (
    [Context]                VARCHAR (50)  NOT NULL,
    [HierarchyName]          VARCHAR (255) NOT NULL,
    [VersionID]              INT           NOT NULL,
    [Root]                   INT           NOT NULL,
    [CreatedBy]              VARCHAR (50)  NOT NULL,
    [CreatedBySourceSystem]  VARCHAR (50)  NOT NULL,
    [CreatedDate]            DATETIME      NOT NULL,
    [ModifiedBy]             VARCHAR (50)  NULL,
    [ModifiedBySourceSystem] VARCHAR (50)  NULL,
    [ModifiedDate]           DATETIME      NULL,
    CONSTRAINT [PK_Hierarchies] PRIMARY KEY CLUSTERED ([Context] ASC, [HierarchyName] ASC, [VersionID] ASC, [Root] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_Hierarchies_HierarchyVersions] FOREIGN KEY ([Context], [HierarchyName], [VersionID]) REFERENCES [dbo].[HierarchyVersions] ([Context], [HierarchyName], [VersionID]),
    CONSTRAINT [FK_Hierarchies_OrgEntities] FOREIGN KEY ([Root]) REFERENCES [dbo].[OrgEntities] ([ID]),
    CONSTRAINT [FK_Hierarchies-CreatedBy_Personnel] FOREIGN KEY ([CreatedBy], [CreatedBySourceSystem]) REFERENCES [dbo].[Personnel] ([ID], [SourceSystem]),
    CONSTRAINT [FK_Hierarchies-ModifiedBy_Personnel] FOREIGN KEY ([ModifiedBy], [ModifiedBySourceSystem]) REFERENCES [dbo].[Personnel] ([ID], [SourceSystem])
);

