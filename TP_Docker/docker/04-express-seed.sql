USE product_api;

INSERT IGNORE INTO categories (name) VALUES
('Electronics'),
('Accessories'),
('Computers');

INSERT INTO products (name, price, stock, category_id)
SELECT 'Laptop', 899.99, 10, id
FROM categories WHERE name = 'Computers'
  AND NOT EXISTS (SELECT 1 FROM products WHERE name = 'Laptop');

INSERT INTO products (name, price, stock, category_id)
SELECT 'Headphones', 59.99, 25, id
FROM categories WHERE name = 'Accessories'
  AND NOT EXISTS (SELECT 1 FROM products WHERE name = 'Headphones');

INSERT INTO products (name, price, stock, category_id)
SELECT 'Smartphone', 499.99, 15, id
FROM categories WHERE name = 'Electronics'
  AND NOT EXISTS (SELECT 1 FROM products WHERE name = 'Smartphone');
