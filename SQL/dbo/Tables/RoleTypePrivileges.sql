CREATE TABLE [dbo].[RoleTypePrivileges] (
    [Context]      VARCHAR (50)   NOT NULL,
    [AppID]        INT            NOT NULL,
    [RoleTypeID]   INT            NOT NULL,
    [Privileges]   INT            NOT NULL,
    [Description]  VARCHAR (1024) NULL,
    [DisplayOrder] INT            NULL,
    CONSTRAINT [PK_RoleTypePrivileges] PRIMARY KEY CLUSTERED ([Context] ASC, [AppID] ASC, [RoleTypeID] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_RoleTypePrivileges_RoleTypes] FOREIGN KEY ([AppID], [RoleTypeID]) REFERENCES [dbo].[RoleTypes] ([AppID], [RoleTypeID])
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Defines the privileges associated with a particular role type for a given application. Currently, PgmD has 8 privilege bits as follows: b0 = Grant; b1 = Hierarchy Edit; b2 = Metadata Read; b3 = Metadata Write; b4 = Unrestricted Read; b5 = Unrestricted Write; b6 = Restricted Read; b7 = Restricted Write.

PgmD also maintains the roles to privileges mapping for other applications.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RoleTypePrivileges';

