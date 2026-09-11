/*
Table Structure & Data Dictionary Metadata
Purpose:
- Inspect column specifications and schema details for 'dim_customers'.
- Retrieve metadata including column names, data types, nullability,
and maximum character limits.
*/

SELECT 
    COLUMN_NAME, 
    DATA_TYPE, 
    IS_NULLABLE, 
    CHARACTER_MAXIMUM_LENGTH
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'dim_customers';