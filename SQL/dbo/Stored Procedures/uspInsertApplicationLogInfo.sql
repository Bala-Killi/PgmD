-- =================================================
-- Create date: 12/13/2010
-- Description: Insert App Log Info to Log table
-- =================================================
CREATE PROCEDURE [dbo].[uspInsertApplicationLogInfo]
	@userId VARCHAR(20),
	@processName varchar(255),
	@errorMessage nvarchar(400),
	@traceInfo nvarchar(max)
AS BEGIN
	
INSERT INTO ApplicationLogInfo (DateLog, UserId, ProcessName, ErrorMessage, TraceInfo)
	VALUES (GETDATE(), @userId, @processName, @errorMessage, @traceInfo)
END