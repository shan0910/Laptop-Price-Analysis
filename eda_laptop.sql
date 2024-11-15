SELECT * FROM casestudy.laptop_backup;
SELECT COUNT(*) FROM laptop_backup;

USE casestudy;

-- Check memory consumption for reference
SELECT DATA_LENGTH
FROM information_schema.TABLES
WHERE TABLE_SCHEMA='casestudy'
AND TABLE_NAME='laptop_backup';

SELECT * FROM laptop_backup;

-- Drop non important columns

ALTER TABLE laptop_backup DROP COLUMN `Unnamed: 0`;

-- Check for null values

SELECT * FROM laptop_backup
WHERE Company IS NULL;

-- Check for duplicates

SELECT Company,TypeName,Inches,ScreenResolution,Cpu,Ram,Memory,Gpu,OpSys,Weight,Price,COUNT(*),
ROW_NUMBER() OVER()
FROM laptop_backup
GROUP BY Company,TypeName,Inches,ScreenResolution,Cpu,Ram,Memory,Gpu,OpSys,Weight,Price
HAVING COUNT(*)>1;

-- Change data type of inches
ALTER TABLE laptop_backup MODIFY COLUMN Inches DECIMAL(10,1);

-- Modify RAM columns
UPDATE laptop_backup l1
SET Ram =( SELECT REPLACE(Ram,'GB','') FROM laptop_backup l2 WHERE l2.index=l1.index);

UPDATE laptop_backup l1
SET l1.Ram = (SELECT REPLACE(l2.Ram, 'GB', '') FROM laptop_backup l2 WHERE l2.index = l1.index);

SELECT * FROM laptop_backup;

UPDATE laptop_backup
SET Ram=REPLACE(Ram,'GB','');

SELECT * FROM laptop_backup;

-- Modify weights columns
UPDATE laptop_backup
SET Weight=REPLACE(Weight,'kg','');

ALTER TABLE laptop_backup MODIFY COLUMN Weight DECIMAL(10,1);

SELECT * FROM laptop_backup;

-- Modify Price columns
SELECT ROUND(Price) FROM laptop_backup;

UPDATE laptop_backup
SET price=ROUND(Price);

SELECT * FROM laptop_backup;

ALTER TABLE laptop_backup MODIFY COLUMN Price INTEGER;

-- Modify Opsys columns

SELECT DISTINCT OpSys
FROM laptop_backup;

SELECT OpSys,
CASE
	WHEN OpSys LIKE '%mac%' THEN 'macOS'
    WHEN OpSys LIKE '%Windows%' THEN 'WindowOS'
    WHEN OpSys LIKE '%Linux%' THEN 'LinuxOS'
    WHEN OpSys='No OS' THEN 'N/A'
    ELSE 'Other'
END AS 'OS_Brand'    
FROM laptop_backup;

UPDATE laptop_backup
SET OpSys=
CASE
	WHEN OpSys LIKE '%mac%' THEN 'macOS'
    WHEN OpSys LIKE '%Windows%' THEN 'WindowOS'
    WHEN OpSys LIKE '%Linux%' THEN 'LinuxOS'
    WHEN OpSys='No OS' THEN 'N/A'
    ELSE 'Other'
END;
SELECT * FROM laptop_backup;

-- Modify GPU columns

ALTER TABLE laptop_backup
ADD COLUMN gpu_brand VARCHAR(255) AFTER Gpu,
ADD COLUMN gpu_name VARCHAR(255) AFTER gpu_brand;

SELECT SUBSTRING_INDEX(Gpu,' ',1)
FROM laptop_backup;
UPDATE laptop_backup
SET gpu_brand=SUBSTRING_INDEX(Gpu,' ',1);

SELECT* FROM laptop_backup;

SELECT Gpu,
REPLACE(Gpu,gpu_brand,'')
FROM laptop_backup;
UPDATE laptop_backup
SET gpu_name=REPLACE(Gpu,gpu_brand,'');

SELECT * FROM laptop_backup;

ALTER TABLE laptop_backup DROP COLUMN Gpu;

SELECT * FROM laptop_backup;

-- Modify CPU columns
ALTER TABLE laptop_backup
ADD COLUMN cpu_brand VARCHAR(255) AFTER Cpu,
ADD COLUMN cpu_name VARCHAR(255) AFTER cpu_brand,
ADD COLUMN cpu_speed DECIMAL(10,1) AFTER cpu_name;

SELECT * FROM laptop_backup;
SELECT SUBSTRING_INDEX(Cpu,' ',1)
FROM laptop_backup;
UPDATE laptop_backup
SET cpu_brand=SUBSTRING_INDEX(Cpu,' ',1);

SELECT SUBSTRING_INDEX(Cpu,' ',-1)
FROM laptop_backup;
SELECT CAST(REPLACE(SUBSTRING_INDEX(Cpu,' ',-1),'GHz',' ') AS DECIMAL(10,2))
FROM laptop_backup;
UPDATE laptop_backup
SET cpu_speed=CAST(REPLACE(SUBSTRING_INDEX(Cpu,' ',-1),'GHz',' ') AS DECIMAL(10,2));

SELECT * FROM laptop_backup;

SELECT REPLACE(REPLACE(Cpu,cpu_brand,''),SUBSTRING_INDEX(REPLACE(Cpu,cpu_brand,''),' ',-1),'')
FROM laptop_backup;

UPDATE laptop_backup
SET cpu_name=REPLACE(REPLACE(Cpu,cpu_brand,''),SUBSTRING_INDEX(REPLACE(Cpu,cpu_brand,''),' ',-1),'');
SELECT * FROM laptop_backup;
	
ALTER TABLE laptop_backup DROP COLUMN Cpu;

-- Modify ScreenResolution column
SELECT ScreenResolution,
SUBSTRING_INDEX(SUBSTRING_INDEX(ScreenResolution,' ',-1),'x',-1)
FROM laptop_backup;

ALTER TABLE laptop_backup
ADD COLUMN resolution_width  INTEGER AFTER ScreenResolution,
ADD COLUMN resolution_height  INTEGER AFTER resolution_width;

SELECT * FROM laptop_backup;

UPDATE laptop_backup
SET resolution_width =SUBSTRING_INDEX(SUBSTRING_INDEX(ScreenResolution,' ',-1),'x',1);

UPDATE laptop_backup
SET resolution_height=SUBSTRING_INDEX(SUBSTRING_INDEX(ScreenResolution,' ',-1),'x',-1);

SELECT * FROM laptop_backup;

ALTER TABLE laptop_backup
ADD COLUMN Touchscreen  INTEGER AFTER resolution_height;

SELECT ScreenResolution LIKE '%Touch%' FROM laptop_backup;

UPDATE laptop_backup
SET Touchscreen=ScreenResolution LIKE '%Touch%';

SELECT * FROM laptop_backup;

ALTER TABLE laptop_backup
DROP COLUMN ScreenResolution;

-- Modify cpu name column
SELECT cpu_name,
SUBSTRING_INDEX(TRIM(cpu_name),' ',2)
FROM laptop_backup;

UPDATE laptop_backup
SET cpu_name=SUBSTRING_INDEX(TRIM(cpu_name),' ',2);

ALTER TABLE laptop_backup
ADD COLUMN memory_type VARCHAR(255) AFTER Memory,
ADD COLUMN primary_storage INTEGER AFTER memory_type,
ADD COLUMN secondary_storage INTEGER AFTER primary_storage;

SELECT Memory ,
CASE
	WHEN Memory LIKE '%SSD%' AND Memory LIKE '%HDD%' THEN 'Hybrid'
    WHEN Memory LIKE '%SSD%' THEN 'SSD'
    WHEN Memory LIKE '%HDD%' THEN 'HDD'
    WHEN Memory LIKE '%Flash Storage%' THEN 'Flash Storage'
    WHEN Memory LIKE '%Hybrid%' THEN 'Hybrid'
    WHEN Memory LIKE '%Flash Storage%' AND Memory LIKE '%HDD%' THEN 'Hybrid'
    ELSE NULL
END AS 'memory_type'
FROM laptop_backup;

UPDATE laptop_backup
SET memory_type=CASE
	WHEN Memory LIKE '%SSD%' AND Memory LIKE '%HDD%' THEN 'Hybrid'
    WHEN Memory LIKE '%SSD%' THEN 'SSD'
    WHEN Memory LIKE '%HDD%' THEN 'HDD'
    WHEN Memory LIKE '%Flash Storage%' THEN 'Flash Storage'
    WHEN Memory LIKE '%Hybrid%' THEN 'Hybrid'
    WHEN Memory LIKE '%Flash Storage%' AND Memory LIKE '%HDD%' THEN 'Hybrid'
    ELSE NULL
END;

SELECT * FROM laptop_backup;

SELECT Memory,
REGEXP_SUBSTR(SUBSTRING_INDEX(Memory,'+',1),'[0-9]+'),
CASE WHEN Memory LIKE '%+%' THEN REGEXP_SUBSTR(SUBSTRING_INDEX(Memory,'+',-1),'[0-9]+') ELSE 0 END
FROM laptop_backup;

UPDATE laptop_backup
SET primary_storage = REGEXP_SUBSTR(SUBSTRING_INDEX(Memory,'+',1),'[0-9]+'),
secondary_storage = CASE WHEN Memory LIKE '%+%' THEN REGEXP_SUBSTR(SUBSTRING_INDEX(Memory,'+',-1),'[0-9]+') ELSE 0 END;

SELECT * FROM laptop_backup;

SELECT 
primary_storage,
CASE WHEN primary_storage <= 2 THEN primary_storage*1024 ELSE primary_storage END,
secondary_storage,
CASE WHEN secondary_storage <= 2 THEN secondary_storage*1024 ELSE secondary_storage END
FROM laptop_backup;

UPDATE laptop_backup
SET primary_storage = CASE WHEN primary_storage <= 2 THEN primary_storage*1024 ELSE primary_storage END,
secondary_storage = CASE WHEN secondary_storage <= 2 THEN secondary_storage*1024 ELSE secondary_storage END;

SELECT * FROM laptop_backup;

ALTER TABLE laptop_backup DROP COLUMN Memory;
ALTER TABLE laptop_backup DROP COLUMN gpu_name;

SELECT * FROM laptop_backup;




















    













