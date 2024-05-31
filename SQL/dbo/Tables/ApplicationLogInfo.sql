CREATE TABLE [dbo].[ApplicationLogInfo] (
    [RecID]        INT            IDENTITY (1, 1) NOT NULL,
    [DateLog]      DATETIME       NULL,
    [UserId]       VARCHAR (20)   NULL,
    [ProcessName]  VARCHAR (255)  NULL,
    [ErrorMessage] NVARCHAR (MAX) NULL,
    [TraceInfo]    NVARCHAR (MAX) NULL,
    CONSTRAINT [PK_ApplicationLogInfo] PRIMARY KEY CLUSTERED ([RecID] ASC) WITH (FILLFACTOR = 90)
);

