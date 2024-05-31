CREATE TABLE [dbo].[OEHistory] (
    [OEID]                     INT           NOT NULL,
    [ModifiedDate]             DATETIME      NOT NULL,
    [SourcingHierarchyContext] VARCHAR (50)  NOT NULL,
    [Name]                     VARCHAR (255) NOT NULL,
    [Abbreviation]             VARCHAR (50)  NULL,
    [Alias]                    VARCHAR (255) NULL,
    [Status]                   VARCHAR (50)  NOT NULL,
    [Description]              VARCHAR (MAX) NULL,
    [State]                    VARCHAR (50)  NULL,
    [ModifiedBy]               VARCHAR (50)  NOT NULL,
    [ModifiedBySourceSystem]   VARCHAR (50)  NOT NULL,
    CONSTRAINT [PK_OEHistory] PRIMARY KEY NONCLUSTERED ([OEID] ASC, [ModifiedDate] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_OEHistory_OrgEntities] FOREIGN KEY ([OEID]) REFERENCES [dbo].[OrgEntities] ([ID]),
    CONSTRAINT [FK_OEHistory_Personnel] FOREIGN KEY ([ModifiedBy], [ModifiedBySourceSystem]) REFERENCES [dbo].[Personnel] ([ID], [SourceSystem])
);


GO
CREATE NONCLUSTERED INDEX [IX_OEHistory_SetUCO]
    ON [dbo].[OEHistory]([SourcingHierarchyContext] ASC, [State] ASC, [ModifiedDate] ASC)
    INCLUDE([OEID]) WITH (FILLFACTOR = 90);

