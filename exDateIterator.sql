-- DATE Iterator Example


DECLARE @StartDate      DATE
DECLARE @EndDate        DATE
DECLARE @OverallEndDate	DATE
DECLARE @PrintStart     NVARCHAR(10)
DECLARE @PrintEnd       NVARCHAR(10)
 
--	SET the start DATE and overall end DATE
--	SET the end DATE to 7 days after the start DATE
SET @OverallEndDate = '2018-12-31'
SET @StartDate = '2018-01-01'
SET @EndDate = DATEADD(DAY,7 ,@StartDate)
 
--	Loop while the start DATE is less than the overall end DATE
WHILE(@OverallEndDate > @StartDate)
BEGIN
        --     Print the working weeks
        SET @PrintStart = CONVERT( NVARCHAR(10),@StartDate, 120)
        SET @PrintEnd = CONVERT( NVARCHAR(10),@EndDate, 120)
        raiserror('Working on %s to %s' ,10, 1,@PrintStart ,@PrintEnd)
 
        --     Do something here
		--	select  [SalesOrderID]
		--	from	[Sales].[SalesOrderHeader]
		--	where	[OrderDATE] >= @StartDate
		--	and		[OrderDATE] < @EndDate
 
        --     Increment the weeks
        SET @StartDate = @EndDate
        SET @EndDate = DATEADD( dd,7 ,@StartDate)
 
END
raiserror('Finished!' ,10, 1)