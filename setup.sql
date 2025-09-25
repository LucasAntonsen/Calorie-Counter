ALTER TABLE food
MODIFY COLUMN fdc_id INTEGER NOT NULL,
MODIFY COLUMN data_type VARCHAR(50) NOT NULL,
MODIFY COLUMN description VARCHAR(255),
MODIFY COLUMN food_category_id INTEGER,
MODIFY COLUMN publication_date DATE NOT NULL;

LOAD DATA LOCAL INFILE 'food.csv'
INTO TABLE food 
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n' 
IGNORE 1 ROWS 
(fdc_id, data_type, description, @food_category_id, @publication_date) 
SET 
    food_category_id = NULLIF(@food_category_id, ''), 
    publication_date = 
        CASE 
            WHEN @publication_date REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2}$' 
                THEN @publication_date 
            ELSE STR_TO_DATE(@publication_date, '%m/%d/%Y') 
        END;

CREATE TABLE food_nutrient (
    id INT NOT NULL PRIMARY KEY,
    fdc_id INT NOT NULL,
    nutrient_id INT NOT NULL,
    amount DECIMAL(22,16) NOT NULL,
    data_points INT,
    derivation_id INT,
    min DECIMAL(12,7),
    max DECIMAL(11,6),
    median DECIMAL(12,7),
    footnote VARCHAR(1000),
    min_year_acquired YEAR,
    FOREIGN KEY (fdc_id) REFERENCES food(fdc_id),
    FOREIGN KEY (nutrient_id) REFERENCES nutrient(id)
);

-- skips some rows that don't have corresponding key in nutrient table (27 rows)

LOAD DATA LOCAL INFILE 'food_nutrient.csv'
INTO TABLE food_nutrient
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n' 
IGNORE 1 ROWS
(id, fdc_id, nutrient_id, @amount, @data_points, @derivation_id, @min, @max, @median, footnote, @min_year_acquired)
SET amount = NULLIF(@amount, ''),
    data_points = NULLIF(@data_points, ''),
    derivation_id = NULLIF(@derivation_id, ''),
    min = NULLIF(@min, ''),
    max = NULLIF(@max, ''),
    median = NULLIF(@median, ''),
    min_year_acquired = NULLIF(@min_year_acquired, '');

ALTER TABLE food_nutrient
MODIFY COLUMN min DECIMAL(12,7),
MODIFY COLUMN max DECIMAL(11,6),
MODIFY COLUMN median DECIMAL(12,7),
MODIFY COLUMN footnote VARCHAR(1000);

ALTER TABLE food_nutrient
MODIFY COLUMN amount DECIMAL(22,16);

-- "id","name","unit_name","nutrient_nbr","rank"
-- "2047","Energy (Atwater General Factors)","KCAL","957","280.0"

CREATE TABLE nutrient (
    id INTEGER NOT NULL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    unit_name VARCHAR(50) NOT NULL,
    nutrient_nbr INTEGER NULL,
    `rank` DECIMAL(10,2) NOT NULL
);

LOAD DATA LOCAL INFILE 'nutrient.csv'
INTO TABLE nutrient
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n' 
IGNORE 1 ROWS
(id, name, unit_name, @nutrient_nbr, @rank)
SET nutrient_nbr = NULLIF(@nutrient_nbr, ''),
    `rank` = NULLIF(@rank, '');