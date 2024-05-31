CREATE TABLE [dbo].[Applications] (
    [ID]           INT            NOT NULL,
    [Name]         VARCHAR (50)   NOT NULL,
    [DisplayName]  VARCHAR (50)   NULL,
    [Description]  VARCHAR (1024) NULL,
    [DisplayOrder] INT            NOT NULL,
    CONSTRAINT [PK_Applications] PRIMARY KEY CLUSTERED ([ID] ASC) WITH (FILLFACTOR = 90)
);

