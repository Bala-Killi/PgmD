CREATE FUNCTION [udfParseColumnString](
	@CSV_String	varchar (max),
	@DeliChar	char(1)
)
RETURNS @tblValues TABLE (
	ID		int IDENTITY PRIMARY KEY,
	Value	varchar (255)
)
AS BEGIN
	DECLARE
		@pos			int,
		@delim_pos		int,
		@next_delim_pos	int,
		@str_len 		int
	IF @DeliChar = '' OR @DeliChar IS NULL
SET @DeliChar = ','
SET @pos = 1
SET @delim_pos = 0
SET @next_delim_pos = CHARINDEX(@DeliChar, @CSV_String, @pos)
SET @str_len = LEN(@CSV_String)
WHILE @pos <= @str_len + 1 BEGIN
IF @CSV_String NOT LIKE '%' + @DeliChar + '%' BEGIN
INSERT INTO @tblValues (Value)
	VALUES (LTRIM(RTRIM(@CSV_String)))
BREAK
END
INSERT INTO @tblValues (Value)
	VALUES (LTRIM(RTRIM(SUBSTRING(@CSV_String, @pos, (@next_delim_pos - (@delim_pos + 1))))))
SET @delim_pos = CHARINDEX(@DeliChar, @CSV_String, @pos)
SET @next_delim_pos = CHARINDEX(@DeliChar, @CSV_String, (@delim_pos + 1))
IF @delim_pos = 0 BREAK
IF @next_delim_pos = 0 SET @next_delim_pos = @str_len + 1
SET @pos = @delim_pos + 1
END
RETURN
END