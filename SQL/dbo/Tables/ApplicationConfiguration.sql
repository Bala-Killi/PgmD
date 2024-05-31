CREATE TABLE [dbo].[ApplicationConfiguration] (
    [Name]  VARCHAR (50)  NOT NULL,
    [Value] VARCHAR (255) NOT NULL,
    [Type]  VARCHAR (50)  NULL,
    CONSTRAINT [PK_ApplicationConfiguration] PRIMARY KEY CLUSTERED ([Name] ASC, [Value] ASC) WITH (FILLFACTOR = 90)
);

