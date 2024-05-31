CREATE TABLE [dbo].[HierarchyVersions] (
    [Context]        VARCHAR (50)  NOT NULL,
    [HierarchyName]  VARCHAR (255) NOT NULL,
    [VersionID]      INT           NOT NULL,
    [Classification] VARCHAR (50)  NOT NULL,
    [VersionDate]    DATETIME      DEFAULT (getdate()) NOT NULL,
    [Description]    VARCHAR (MAX) NULL,
    CONSTRAINT [PK_HierarchyVersions] PRIMARY KEY CLUSTERED ([Context] ASC, [HierarchyName] ASC, [VersionID] ASC) WITH (FILLFACTOR = 90)
);

