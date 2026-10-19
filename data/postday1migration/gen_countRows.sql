Use [SalesforceMigration]
go

SELECT
    s.name  AS SchemaName,
    t.name  AS TableName,
    SUM(ps.row_count) AS [RowCount]
FROM sys.tables AS t
JOIN sys.schemas AS s
    ON s.schema_id = t.schema_id
JOIN sys.dm_db_partition_stats AS ps
    ON ps.object_id = t.object_id
WHERE s.name = 'sfrhd'
  AND ps.index_id IN (0, 1)   -- heap (0) or clustered index (1)
GROUP BY
    s.name,
    t.name
ORDER BY
    SUM(ps.row_count) desc, t.name;