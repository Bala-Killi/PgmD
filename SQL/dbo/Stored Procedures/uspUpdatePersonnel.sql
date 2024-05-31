-- =============================================
-- Create date: 11/30/2011
-- Description: Update personnel table
-- =============================================
CREATE PROCEDURE [dbo].[uspUpdatePersonnel] 
	@bemsId					varchar(max),
	@source					varchar(max) = 'EDS',
	@displayName			varchar(max) = NULL,
	@lastName				varchar(max),
	@firstName				varchar(max) = NULL,
	@middle					varchar(max) = NULL,
	@email					varchar(max) = NULL,
	@phone					varchar(max) = NULL,
	@dept					varchar(max) = NULL,
	@usPerson				varchar(max) = NULL,
	@boeingEmp				varchar(max) = NULL,
	@city					varchar(max) = NULL,
	@state					varchar(max) = NULL,
	@country				varchar(max) = NULL,
	@jobcode				varchar(max) = NULL
AS BEGIN
	SET NOCOUNT ON
	DECLARE @personnelList TABLE(
		bemsId varchar(50) NOT NULL,
		source varchar(50) NOT NULL,
		displayName varchar(153),
		lastName varchar(50) NOT NULL,
		firstName varchar(50),
		middle varchar(50),
		email varchar(255),
		phone varchar(50),
		dept varchar(50),
		usPerson tinyint,
		boeingEmp tinyint,
		city	varchar(50),
		state	varchar(50),
		country varchar(50),
		jobcode varchar(20)
	)

	-- Build the table from the lists
	INSERT INTO @personnelList
	SELECT DISTINCT CAST(a.Value AS varchar(50)),
					CAST(b.Value AS varchar(50)),
					CASE c.Value
						WHEN '' THEN NULL
						ELSE c.Value
					END,
					CAST(d.Value AS varchar(50)),
					CASE e.Value
						WHEN '' THEN NULL
						ELSE e.Value
					END,
					CASE f.Value
						WHEN '' THEN NULL
						ELSE f.value
					END,
					CASE g.Value    
						WHEN '' THEN NULL
						ELSE g.value
					END,
					CASE h.Value     
						WHEN '' THEN NULL
						ELSE h.value
					END,
					CASE i.Value
						WHEN '' THEN NULL
						ELSE i.Value
					END,
					CASE j.Value        -- case of usPerson 3185236
						WHEN '' THEN NULL
						ELSE 0
					END,
					CASE k.Value         -- case of boeingEmp 3185236
						WHEN '' THEN NULL
						ELSE 0
					END,
					CASE l.Value
						WHEN '' THEN NULL
						ELSE l.Value
					END,
					CASE m.Value
						WHEN '' THEN NULL
						ELSE m.Value
					END,
					CASE n.Value
						WHEN '' THEN NULL
						ELSE n.Value
					END,
					CASE o.Value
						WHEN '' THEN NULL
						ELSE o.Value
					END
	FROM udfParseColumnString(@bemsId, ';') a
		INNER JOIN udfParseColumnString(@source, ';') b
			ON a.ID = b.ID
		LEFT JOIN udfParseColumnString(@displayName, ';') c
			ON a.ID = c.ID
		INNER JOIN udfParseColumnString(@lastName, ';') d
			ON a.ID = d.ID
		LEFT JOIN udfParseColumnString(@firstName, ';') e
			ON a.ID = e.ID
		LEFT JOIN udfParseColumnString(@middle, ';') f
			ON a.ID = f.ID
		LEFT JOIN udfParseColumnString(@email, ';') g
			ON a.ID = g.ID
		LEFT JOIN udfParseColumnString(@phone, ';') h
			ON a.ID = h.ID
		LEFT JOIN udfParseColumnString(@dept, ';') i
			ON a.ID = i.ID
		LEFT JOIN udfParseColumnString(@usPerson, ';') j
			ON a.ID = j.ID
		LEFT JOIN udfParseColumnString(@boeingEmp, ';') k
			ON a.ID = k.ID
		LEFT JOIN udfParseColumnString(@city, ';') l
			ON a.ID = l.ID
		LEFT JOIN udfParseColumnString(@state, ';') m
			ON a.ID = m.ID
		LEFT JOIN udfParseColumnString(@country, ';') n
			ON a.ID = n.ID
		LEFT JOIN udfParseColumnString(@jobcode, ';') o
			ON a.ID = o.ID

	-- Update preexisting data
	UPDATE Personnel
	SET DisplayName = pl.displayName,
		LastName = pl.lastName,
		FirstName = pl.firstName,
		Middle = pl.middle,
		Email = pl.email,
		Telephone = pl.phone,
		AcctDept = pl.dept,
		IsUSPerson = pl.usPerson,
		IsBoeingEmployee = pl.boeingEmp,
		City = pl.city,
		State = pl.state,
		Country = pl.country,
		JobCode = pl.jobcode
	FROM Personnel p
		INNER JOIN @personnelList pl
			ON p.ID = pl.bemsId
				AND p.SourceSystem = pl.source;

	-- Insert new data
	INSERT INTO Personnel (ID, SourceSystem, DisplayName, LastName, FirstName, Middle, Email, Telephone, AcctDept, IsUSPerson, 
		IsBoeingEmployee, City, State, Country, JobCode)
	SELECT pl.bemsId,
			pl.source,
			pl.displayName,
			pl.lastName,
			pl.firstName,
			pl.middle,
			pl.email,
			pl.phone,
			pl.dept,
			pl.usPerson,
			pl.boeingEmp,
			pl.city,
			pl.state,
			pl.Country,
			pl.JobCode
	FROM @personnelList pl
		LEFT JOIN Personnel p
			ON p.ID = pl.bemsId
				AND p.SourceSystem = pl.source
	WHERE p.ID IS NULL;
END