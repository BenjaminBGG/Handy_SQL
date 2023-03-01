;WITH objects_cte AS
(
    SELECT
        o.name,
        o.type_desc,
        CASE
            WHEN o.principal_id IS NULL THEN s.principal_id
            ELSE o.principal_id
        END AS principal_id
    FROM sys.objects o
    INNER JOIN sys.schemas s
    ON o.schema_id = s.schema_id
    WHERE o.is_ms_shipped = 0
    AND o.type IN ('U', 'FN', 'FS', 'FT', 'IF', 'P', 'PC', 'TA', 'TF', 'TR', 'V')
)
SELECT
    cte.name,
    cte.type_desc,
    dp.name
FROM objects_cte cte
INNER JOIN sys.database_principals dp
ON cte.principal_id = dp.principal_id
WHERE dp.name = 'YourUser';