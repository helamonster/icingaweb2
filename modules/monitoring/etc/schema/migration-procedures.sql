# Helper functions and procedures for idempotent schema migrations

DELIMITER //
DROP FUNCTION IF EXISTS m_index_exists //
CREATE FUNCTION m_index_exists(
  f_table_name varchar(64),
  f_index_name varchar(64)
)
RETURNS BOOL
BEGIN
  DECLARE m_index_exists BOOL DEFAULT FALSE;
  SELECT EXISTS (
      SELECT 1
      FROM information_schema.statistics
      WHERE table_schema = SCHEMA()
            AND table_name = f_table_name
            AND index_name = f_index_name
  ) INTO m_index_exists;
  RETURN m_index_exists;
END //
DELIMITER ;

DELIMITER //
DROP PROCEDURE IF EXISTS m_drop_index //
CREATE PROCEDURE m_drop_index (
  IN p_table_name varchar(64),
  IN p_index_name varchar(64)
)
BEGIN
  IF m_index_exists(p_table_name, p_index_name)
  THEN
    SET @m_drop_index_sql = CONCAT('ALTER TABLE `', SCHEMA(), '`.`', p_table_name, '` DROP INDEX `', p_index_name, '`');
    PREPARE stmt FROM @m_drop_index_sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
    SET @m_drop_index_sql = NULL;
  END IF;
END //
DELIMITER ;

DELIMITER //
DROP PROCEDURE IF EXISTS m_create_index //
CREATE PROCEDURE m_create_index (
  IN p_table_name varchar(64),
  IN p_index_name varchar(64),
  IN p_index_columns varchar(512)
)
BEGIN
  IF NOT m_index_exists(p_table_name, p_index_name)
  THEN
    SET @m_create_index_sql = CONCAT(
      'ALTER TABLE `', SCHEMA(), '`.`', p_table_name, '` ADD INDEX `', p_index_name, '` (', p_index_columns, ')'
    );
    PREPARE stmt FROM @m_create_index_sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
    SET @m_create_index_sql = NULL;
  END IF;
END //
DELIMITER ;

DELIMITER //
DROP PROCEDURE IF EXISTS m_create_unique_index //
CREATE PROCEDURE m_create_unique_index (
  IN p_table_name varchar(64),
  IN p_index_name varchar(64),
  IN p_index_columns varchar(512)
)
BEGIN
  IF NOT m_index_exists(p_table_name, p_index_name)
  THEN
    SET @m_create_index_sql = CONCAT(
      'ALTER TABLE `', SCHEMA(), '`.`', p_table_name, '` ADD UNIQUE INDEX `', p_index_name, '` (', p_index_columns, ')'
    );
    PREPARE stmt FROM @m_create_index_sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
    SET @m_create_index_sql = NULL;
  END IF;
END //
DELIMITER ;

DELIMITER //
DROP FUNCTION IF EXISTS m_column_exists //
CREATE FUNCTION m_column_exists(
  f_table_name varchar(64),
  f_column_name varchar(64)
)
RETURNS BOOL
BEGIN
  DECLARE m_column_exists BOOL DEFAULT FALSE;
  SELECT EXISTS (
      SELECT 1
      FROM information_schema.columns
      WHERE table_schema = SCHEMA()
            AND table_name = f_table_name
            AND column_name = f_column_name
  ) INTO m_column_exists;
  RETURN m_column_exists;
END //
DELIMITER ;

DELIMITER //
DROP PROCEDURE IF EXISTS m_drop_column //
CREATE PROCEDURE m_drop_column (
  IN p_table_name varchar(64),
  IN p_column_name varchar(64)
)
BEGIN
  IF m_column_exists(p_table_name, p_column_name)
  THEN
    SET @m_drop_column_sql = CONCAT('ALTER TABLE `', SCHEMA(), '`.`', p_table_name, '` DROP COLUMN `', p_column_name, '`');
    PREPARE stmt FROM @m_drop_column_sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
    SET @m_drop_column_sql = NULL;
  END IF;
END //
DELIMITER ;

DELIMITER //
DROP PROCEDURE IF EXISTS m_add_column //
CREATE PROCEDURE m_add_column (
  IN p_table_name varchar(64),
  IN p_column_name varchar(64),
  IN p_column_definition varchar(64)
)
BEGIN
  IF NOT m_column_exists(p_table_name, p_column_name)
  THEN
    SET @m_add_column_sql = CONCAT(
      'ALTER TABLE `', SCHEMA(), '`.`', p_table_name, '` ADD COLUMN `', p_column_name, '` ', p_column_definition
    );
    PREPARE stmt FROM @m_add_column_sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
    SET @m_add_column_sql = NULL;
  END IF;
END //
DELIMITER ;