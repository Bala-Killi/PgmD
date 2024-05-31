﻿CREATE TABLE [dbo].[HierarchicalAC] (
    [Context]                VARCHAR (50)   NOT NULL,
    [Root]                   INT            NOT NULL,
    [Node]                   INT            NOT NULL,
    [Grantee]                VARCHAR (50)   NOT NULL,
    [GranteeSourceSystem]    VARCHAR (50)   NOT NULL,
    [AppID]                  INT            NOT NULL,
    [RoleTypeID]             INT            NOT NULL,
    [Privileges]             INT            NOT NULL,
    [Reason]                 VARCHAR (1024) NULL,
    [CreatedBy]              VARCHAR (50)   NOT NULL,
    [CreatedBySourceSystem]  VARCHAR (50)   NOT NULL,
    [CreatedDate]            DATETIME       NOT NULL,
    [ExpirationDate]         DATE           NOT NULL,
    [ModifiedBy]             VARCHAR (50)   NULL,
    [ModifiedBySourceSystem] VARCHAR (50)   NULL,
    [ModifiedDate]           DATETIME       NULL,
    [NotificationStatus]     VARCHAR (10)   NULL,
    [NotificationDate]       DATE           NULL,
    CONSTRAINT [PK_HierarchicalAC] PRIMARY KEY CLUSTERED ([Context] ASC, [Root] ASC, [Node] ASC, [Grantee] ASC, [GranteeSourceSystem] ASC, [AppID] ASC, [RoleTypeID] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_HierarchicalAC_RoleTypePrivileges] FOREIGN KEY ([Context], [AppID], [RoleTypeID]) REFERENCES [dbo].[RoleTypePrivileges] ([Context], [AppID], [RoleTypeID]),
    CONSTRAINT [FK_HierarchicalAC-CreatedBy_Personnel] FOREIGN KEY ([CreatedBy], [CreatedBySourceSystem]) REFERENCES [dbo].[Personnel] ([ID], [SourceSystem]),
    CONSTRAINT [FK_HierarchicalAC-Grantee_Personnel] FOREIGN KEY ([Grantee], [GranteeSourceSystem]) REFERENCES [dbo].[Personnel] ([ID], [SourceSystem]),
    CONSTRAINT [FK_HierarchicalAC-ModifiedBy_Personnel] FOREIGN KEY ([ModifiedBy], [ModifiedBySourceSystem]) REFERENCES [dbo].[Personnel] ([ID], [SourceSystem]),
    CONSTRAINT [FK_HierarchicalAC-Node_OrgEntities] FOREIGN KEY ([Node]) REFERENCES [dbo].[OrgEntities] ([ID]),
    CONSTRAINT [FK_HierarchicalAC-Root_OrgEntities] FOREIGN KEY ([Root]) REFERENCES [dbo].[OrgEntities] ([ID])
);
