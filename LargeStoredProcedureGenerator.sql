CREATE OR ALTER PROCEDURE GenerateProcedure
	@numberOfItems int = 1 --just defaults to a single variable/row
AS
 --create a procedure named dbo.BigBoy in the database where you execute it. 
 --each additional item added (using the @numberOfItems parameter), add 7 lines 
 --of code to the output procedure (starting at 33 for a parameter of 1
 BEGIN

--Header
	--shorthand for a hard return
	DECLARE @crlf nchar(2) = char(13) + char(10);

	DECLARE @procedureBody nvarchar(max) = 
'CREATE OR ALTER PROCEDURE dbo.BigBoy
 AS
   BEGIN
     SET NOCOUNT ON;
   '

	--start with variables. One for 1 - @variableCounter

	SET @procedureBody = @procedureBody + @crlf + 
	'     /* Variables, all set to 1 initially */' + @crlf 

	declare @VariableCounter int = 1

	SET @procedureBody = @procedureBody + '      DECLARE ' + @crlf;

	WHILE (@VariableCounter < @numberOfItems)
	 BEGIN
		SET @procedureBody = @procedureBody 
			+ '		' + CONCAT('@var_',@variableCounter,' int = 1,',@crlf)

		SET @VariableCounter = @VariableCounter + 1;
	 END
	SET @procedureBody = @procedureBody 
		+ '		' + CONCAT('@var_',@variableCounter,' int = 1',@crlf)


	--Now add all of the values together
	--reSET value

		SET @procedureBody = @procedureBody + @crlf +
		'     /* Add each variable to the previous value */' + @crlf +
		'     /* So @var2 will get old @var2 + current @var1 */' + @crlf +
		'     /* And so on */' + @crlf 

	SET @VariableCounter = 2 --don't need 1, because senseless to add to itself

	WHILE (@VariableCounter <= @numberOfItems)
	 BEGIN
		SET @procedureBody = @procedureBody 
			+ '		' + 
			CONCAT('SET @var_',@variableCounter,
			        ' = @var_',@variableCounter - 1,
					' + @var_',@variableCounter,@crlf)

		SET @VariableCounter = @VariableCounter + 1;
	 END

	--create a temporary table
	SET @procedureBody = @procedureBody + @crlf;

	SET @procedureBody = @procedureBody + 
		'     /* Temp table to hold all the variable values */' + @crlf 

	SET @procedureBody = @procedureBody + 
		'      CREATE TABLE #HoldData ' + @crlf + 
		'      (' + @crlf + 
		'        variableName nvarchar(100),' +  @crlf + 
		'        value int' +  @crlf +  
		'      )'+ @crlf + @crlf
		 
	--insert rows
	SET @procedureBody = @procedureBody + 
		'     /* Finally, insert each variable into the temp table */' + @crlf +
		'     /* So we can see if we got it right */' + @crlf 

	SET @variableCounter = 1;
	WHILE (@VariableCounter <= @numberOfItems)
	 BEGIN
		SET @procedureBody = @procedureBody 
			+ '      INSERT INTO #HoldData ' + @crlf + 
			+ '        (variableName,value) ' + @crlf + 
			+ '       VALUES ' + @crlf
			+ '        (' + 
				CONCAT('''Variable_',@variableCounter,''',',@variableCounter,');')
			+ @crlf + @crlf;

		SET @VariableCounter = @VariableCounter + 1;
	 END

	 SET @procedureBody = @procedureBody + 
		'     /* Finally view the data */' + @crlf 

	 SET @procedureBody = @procedureBody + @crlf + 

		'      SELECT *' + @crlf + 
		'      FROM #HoldData;' + @crlf

--finish up
	--add the end to the code
	SET @procedureBody = @procedureBody + @crlf + ' END;'

	--compile the procedure
	execute (@procedureBody);

	select REGEXP_COUNT(@procedureBody,'\r\n') + 1 as NumberOfLines;

END;
GO
