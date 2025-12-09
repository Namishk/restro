DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS dishes;
DROP TABLE IF EXISTS restros;

CREATE TABLE restros (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    city VARCHAR(255),
    address VARCHAR(255)
);

CREATE TABLE dishes (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    restro_id INT,
    FOREIGN KEY (restro_id) REFERENCES restros(id),
    CONSTRAINT restro_fk FOREIGN KEY (restro_id) REFERENCES restros(id)
);
CREATE INDEX idx_name_price ON dishes (name, price);

CREATE TABLE orders (
    id SERIAL PRIMARY KEY,
    restro_id INT,
    dish_id INT,
    order_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (restro_id) REFERENCES restros(id),
    FOREIGN KEY (dish_id) REFERENCES dishes(id)
);
CREATE INDEX idx_dish_id ON orders (dish_id);

DO $$
DECLARE
    i INT := 0;
    j INT := 0;
    r_id INT;
    d_id INT;
BEGIN
    -- Generate 20 Restaurants
    WHILE i < 20 LOOP
        INSERT INTO restros (name, city, address) 
        VALUES (
            CONCAT('Restaurant ', i), 
            CASE (i % 10)
                WHEN 0 THEN 'Mumbai'
                WHEN 1 THEN 'Delhi'
                WHEN 2 THEN 'Bangalore'
                WHEN 3 THEN 'Hyderabad'
                WHEN 4 THEN 'Chennai'
                WHEN 5 THEN 'Kolkata'
                WHEN 6 THEN 'Pune'
                WHEN 7 THEN 'Jaipur'
                WHEN 8 THEN 'Ahmedabad'
                ELSE 'Lucknow'
            END,
            CONCAT('Address ', i)
        )
        RETURNING id INTO r_id;
        
        -- Generate 8 Dishes for this restaurant
        j := 0;
        WHILE j < 8 LOOP
             INSERT INTO dishes (name, price, restro_id) 
             VALUES (
                CASE (j % 8)
                    WHEN 0 THEN 'Hyderabadi Biryani'
                    WHEN 1 THEN 'Butter Chicken'
                    WHEN 2 THEN 'Paneer Tikka Masala'
                    WHEN 3 THEN 'Masala Dosa'
                    WHEN 4 THEN 'Chole Bhature'
                    WHEN 5 THEN 'Tandoori Chicken'
                    WHEN 6 THEN 'Palak Paneer'
                    ELSE 'Veg Thali'
                END,
                ROUND((100 + random() * 400)::numeric, 2), 
                r_id
             );
             j := j + 1;
        END LOOP;
        
        i := i + 1;
    END LOOP;
    
    -- Generate 2000 Orders
    i := 0;
    WHILE i < 2000 LOOP
        -- Select a random dish and its restro_id
        SELECT id, restro_id INTO d_id, r_id FROM dishes ORDER BY random() LIMIT 1;
        
        INSERT INTO orders (restro_id, dish_id) VALUES (r_id, d_id);
        i := i + 1;
    END LOOP;
END $$;
