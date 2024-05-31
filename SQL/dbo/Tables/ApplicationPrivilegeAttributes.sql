CREATE TABLE [dbo].[ApplicationPrivilegeAttributes] (
    [Context]            VARCHAR (50) NOT NULL,
    [AppID]              INT          NOT NULL,
    [MaxDuration]        INT          NULL,
    [AllPrivileges]      INT          NULL,
    [GrantPrivilegeMask] INT          NULL,
    CONSTRAINT [PK_ApplicationPrivilegeAttributes] PRIMARY KEY NONCLUSTERED ([Context] ASC, [AppID] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_ApplicationPrivilegeAttributes_Applications] FOREIGN KEY ([AppID]) REFERENCES [dbo].[Applications] ([ID])
);

