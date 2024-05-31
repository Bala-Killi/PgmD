CREATE TABLE [dbo].[RoleTypes] (
    [AppID]       INT            NOT NULL,
    [RoleTypeID]  INT            NOT NULL,
    [Name]        VARCHAR (50)   NOT NULL,
    [DisplayName] VARCHAR (50)   NULL,
    [Description] VARCHAR (1024) NULL,
    CONSTRAINT [PK_RoleTypes] PRIMARY KEY CLUSTERED ([AppID] ASC, [RoleTypeID] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_RoleTypes_Applications] FOREIGN KEY ([AppID]) REFERENCES [dbo].[Applications] ([ID]),
    CONSTRAINT [AK_RoleTypes] UNIQUE NONCLUSTERED ([AppID] ASC, [Name] ASC) WITH (FILLFACTOR = 90)
);

