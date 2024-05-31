CREATE TABLE [dbo].[Personnel] (
    [ID]               VARCHAR (50)  NOT NULL,
    [SourceSystem]     VARCHAR (50)  NOT NULL,
    [DisplayName]      VARCHAR (153) NULL,
    [LastName]         VARCHAR (50)  NOT NULL,
    [FirstName]        VARCHAR (50)  NULL,
    [Middle]           VARCHAR (50)  NULL,
    [Email]            VARCHAR (255) NULL,
    [Telephone]        VARCHAR (50)  NULL,
    [AcctDept]         VARCHAR (50)  NULL,
    [City]             VARCHAR (50)  NULL,
    [State]            VARCHAR (50)  NULL,
    [IsUSPerson]       TINYINT       NULL,
    [IsBoeingEmployee] TINYINT       NULL,
    [Status]           VARCHAR (50)  NULL,
    [JobCode]          VARCHAR (50)  NULL,
    [Country]          VARCHAR (10)  NULL,
    CONSTRAINT [PK_Personnel] PRIMARY KEY CLUSTERED ([ID] ASC, [SourceSystem] ASC) WITH (FILLFACTOR = 90)
);


GO
