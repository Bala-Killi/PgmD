CREATE TABLE [dbo].[OrgEntities] (
    [ID]                       INT           NOT NULL,
    [SourcingHierarchyContext] VARCHAR (50)  NOT NULL,
    [Name]                     VARCHAR (255) NOT NULL,
    [Abbreviation]             VARCHAR (50)  NULL,
    [Alias]                    VARCHAR (255) NULL,
    [Status]                   VARCHAR (50)  NOT NULL,
    [Description]              VARCHAR (MAX) NULL,
    [CreatedBy]                VARCHAR (50)  NOT NULL,
    [CreatedBySourceSystem]    VARCHAR (50)  NOT NULL,
    [CreatedDate]              DATETIME      NOT NULL,
    [ModifiedBy]               VARCHAR (50)  NULL,
    [ModifiedBySourceSystem]   VARCHAR (50)  NULL,
    [ModifiedDate]             DATETIME      NULL,
    CONSTRAINT [PK_OrgEntities] PRIMARY KEY CLUSTERED ([ID] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_OrgEntities-CreatedBy_Personnel] FOREIGN KEY ([CreatedBy], [CreatedBySourceSystem]) REFERENCES [dbo].[Personnel] ([ID], [SourceSystem]),
    CONSTRAINT [FK_OrgEntities-ModifiedBy_Personnel] FOREIGN KEY ([ModifiedBy], [ModifiedBySourceSystem]) REFERENCES [dbo].[Personnel] ([ID], [SourceSystem])
);

