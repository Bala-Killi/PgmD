CREATE TABLE [dbo].[OERolePersonnel] (
    [OEID]                   INT          NOT NULL,
    [AppID]                  INT          NOT NULL,
    [RoleTypeID]             INT          NOT NULL,
    [ModifiedDate]           DATETIME     NOT NULL,
    [PersonID]               VARCHAR (50) NOT NULL,
    [SourceSystem]           VARCHAR (50) NOT NULL,
    [RoleTitle]              VARCHAR (50) NULL,
    [JobCode]                VARCHAR (10) NULL,
    [ModifiedBy]             VARCHAR (50) NOT NULL,
    [ModifiedBySourceSystem] VARCHAR (50) NOT NULL,
    CONSTRAINT [PK_OERolePersonnel] PRIMARY KEY CLUSTERED ([OEID] ASC, [AppID] ASC, [RoleTypeID] ASC, [ModifiedDate] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_OERolePersonnel_OrgEntities] FOREIGN KEY ([OEID]) REFERENCES [dbo].[OrgEntities] ([ID]) ON UPDATE CASCADE,
    CONSTRAINT [FK_OERolePersonnel_RoleTypes] FOREIGN KEY ([AppID], [RoleTypeID]) REFERENCES [dbo].[RoleTypes] ([AppID], [RoleTypeID]),
    CONSTRAINT [FK_OERolePersonnel-ModifiedBy_Personnel] FOREIGN KEY ([ModifiedBy], [ModifiedBySourceSystem]) REFERENCES [dbo].[Personnel] ([ID], [SourceSystem]),
    CONSTRAINT [FK_OERolePersonnel-PersonID_Personnel] FOREIGN KEY ([PersonID], [SourceSystem]) REFERENCES [dbo].[Personnel] ([ID], [SourceSystem])
);

