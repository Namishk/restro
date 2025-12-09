DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS dishes;
DROP TABLE IF EXISTS restros;

CREATE TABLE restros (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    city VARCHAR(255),
    address VARCHAR(255)
);

CREATE TABLE dishes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    restro_id INT,
    FOREIGN KEY (restro_id) REFERENCES restros(id),
    INDEX idx_name_price (name, price)
);

CREATE TABLE orders (
    id INT AUTO_INCREMENT PRIMARY KEY,
    restro_id INT,
    dish_id INT,
    order_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (restro_id) REFERENCES restros(id),
    FOREIGN KEY (dish_id) REFERENCES dishes(id),
    INDEX idx_dish_id (dish_id)
);

DELIMITER $$

CREATE PROCEDURE PopulateData()
BEGIN
    DECLARE i INT DEFAULT 0;
    DECLARE j INT DEFAULT 0;
    DECLARE r_id INT;
    DECLARE d_id INT;
    
    -- Generate 20 Restaurants
    WHILE i < 20 DO
        INSERT INTO restros (name, city, address) 
        VALUES (CONCAT('Restaurant ', i), 'Generated City', CONCAT('Address ', i));
        SET r_id = LAST_INSERT_ID();
        
        -- Generate 8 Dishes for this restaurant
        SET j = 0;
        WHILE j < 8 DO
             INSERT INTO dishes (name, price, restro_id) 
             VALUES (CONCAT('Dish ', i, '-', j), ROUND(10 + RAND() * 100, 2), r_id);
             SET j = j + 1;
        END WHILE;
        
        SET i = i + 1;
    END WHILE;
    
    -- Generate 2000 Orders
    SET i = 0;
    WHILE i < 2000 DO
        -- Pick random existing restro and dish (simplistic approach, might pick dish not belonging to restro, but sticking to "valid ID" constraint)
        -- To be strictly correct: Pick a random dish, then get its restro_id.
        SELECT id, restro_id INTO d_id, r_id FROM dishes ORDER BY RAND() LIMIT 1;
        
        INSERT INTO orders (restro_id, dish_id) VALUES (r_id, d_id);
        SET i = i + 1;
    END WHILE;
    
END$$

DELIMITER ;

CALL PopulateData();
