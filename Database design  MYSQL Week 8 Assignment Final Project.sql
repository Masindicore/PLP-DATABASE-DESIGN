-- Create Database
CREATE DATABASE IF NOT EXISTS boston_ecommerce;
USE boston_ecommerce;

-- Customers Table with Boston-area data
CREATE TABLE customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    phone VARCHAR(20),
    address VARCHAR(255),
    city VARCHAR(50) DEFAULT 'Boston',
    state VARCHAR(50) DEFAULT 'MA',
    zip_code VARCHAR(20),
    country VARCHAR(50) DEFAULT 'USA',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Categories Table
CREATE TABLE categories (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    parent_category_id INT NULL,
    FOREIGN KEY (parent_category_id) REFERENCES categories(category_id)
);

-- Products Table
CREATE TABLE products (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    product_name VARCHAR(255) NOT NULL,
    description TEXT,
    price DECIMAL(10, 2) NOT NULL CHECK (price >= 0),
    stock_quantity INT NOT NULL DEFAULT 0 CHECK (stock_quantity >= 0),
    sku VARCHAR(100) UNIQUE NOT NULL,
    image_url VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Product-Category Junction Table
CREATE TABLE product_categories (
    product_id INT NOT NULL,
    category_id INT NOT NULL,
    PRIMARY KEY (product_id, category_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE CASCADE,
    FOREIGN KEY (category_id) REFERENCES categories(category_id) ON DELETE CASCADE
);

-- Orders Table
CREATE TABLE orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    total_amount DECIMAL(10, 2) NOT NULL CHECK (total_amount >= 0),
    status ENUM('pending', 'processing', 'shipped', 'delivered', 'cancelled') DEFAULT 'pending',
    shipping_address VARCHAR(255) NOT NULL,
    billing_address VARCHAR(255) NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

-- Order Items Table
CREATE TABLE order_items (
    order_item_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL CHECK (quantity > 0),
    unit_price DECIMAL(10, 2) NOT NULL CHECK (unit_price >= 0),
    subtotal DECIMAL(10, 2) GENERATED ALWAYS AS (quantity * unit_price) STORED,
    FOREIGN KEY (order_id) REFERENCES orders(order_id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- Payments Table
CREATE TABLE payments (
    payment_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL UNIQUE,
    payment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    payment_method ENUM('credit_card', 'debit_card', 'paypal', 'bank_transfer') NOT NULL,
    amount DECIMAL(10, 2) NOT NULL CHECK (amount >= 0),
    status ENUM('pending', 'completed', 'failed', 'refunded') DEFAULT 'pending',
    transaction_id VARCHAR(100) UNIQUE,
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
);

-- Reviews Table
CREATE TABLE reviews (
    review_id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT NOT NULL,
    customer_id INT NOT NULL,
    rating INT NOT NULL CHECK (rating >= 1 AND rating <= 5),
    comment TEXT,
    review_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES products(product_id),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    UNIQUE (product_id, customer_id)
);

-- Indexes for better performance
CREATE INDEX idx_customers_email ON customers(email);
CREATE INDEX idx_products_name ON products(product_name);
CREATE INDEX idx_orders_customer ON orders(customer_id);
CREATE INDEX idx_orders_date ON orders(order_date);
CREATE INDEX idx_order_items_order ON order_items(order_id);
CREATE INDEX idx_order_items_product ON order_items(product_id);
CREATE INDEX idx_payments_order ON payments(order_id);
CREATE INDEX idx_reviews_product ON reviews(product_id);
CREATE INDEX idx_reviews_customer ON reviews(customer_id);

-- Insert Boston-based categories
INSERT INTO categories (category_name, description) VALUES
('Electronics', 'Electronic devices and accessories from local Boston tech stores'),
('Clothing', 'Fashion items from Boston-based designers and retailers'),
('Books', 'Books from Boston-area authors and publishers'),
('Home & Kitchen', 'Home appliances and kitchenware from local Boston shops'),
('Sports & Outdoors', 'Sports equipment and outdoor gear for Boston activities');

-- Insert products with Boston-themed items
INSERT INTO products (product_name, description, price, stock_quantity, sku) VALUES
('Boston Red Sox Jersey', 'Official Red Sox home jersey', 129.99, 75, 'BRS-J001'),
('Freedom Trail Guidebook', 'Complete guide to Boston''s Historic Freedom Trail', 19.99, 100, 'FTG-002'),
('MIT Hoodie', 'Comfortable hoodie with MIT logo', 59.99, 50, 'MITH-003'),
('Harvard Coffee Mug', 'Ceramic mug with Harvard University seal', 24.99, 120, 'HCM-004'),
('Boston Skyline Poster', 'Beautiful print of the Boston skyline', 34.99, 80, 'BSP-005'),
('Lobster Roll Kit', 'Everything you need to make authentic Boston lobster rolls', 79.99, 30, 'LRK-006'),
('New England Patriots Cap', 'Official Patriots snapback cap', 29.99, 90, 'NPC-007'),
('Boston Marathon Jacket', 'Lightweight running jacket commemorating the Boston Marathon', 89.99, 40, 'BMJ-008'),
('Paul Revere Silver Replica', 'Handcrafted replica of Paul Revere''s silverwork', 149.99, 25, 'PRS-009'),
('Fenway Park Snow Globe', 'Collectible snow globe featuring Fenway Park', 39.99, 60, 'FPS-010');

-- Associate products with categories
INSERT INTO product_categories (product_id, category_id) VALUES
(1, 2), (1, 5),  -- Red Sox Jersey in Clothing and Sports
(2, 3),          -- Freedom Trail Guidebook in Books
(3, 2),          -- MIT Hoodie in Clothing
(4, 4),          -- Harvard Coffee Mug in Home & Kitchen
(5, 4),          -- Boston Skyline Poster in Home & Kitchen
(6, 4),          -- Lobster Roll Kit in Home & Kitchen
(7, 2), (7, 5),  -- Patriots Cap in Clothing and Sports
(8, 2), (8, 5),  -- Marathon Jacket in Clothing and Sports
(9, 4),          -- Paul Revere Silver in Home & Kitchen
(10, 4);         -- Fenway Snow Globe in Home & Kitchen

-- Insert Boston-area customers with realistic data
INSERT INTO customers (first_name, last_name, email, password_hash, phone, address, zip_code) VALUES
('James', 'Sullivan', 'jsullivan@email.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '617-555-0123', '123 Beacon Street', '02108'),
('Mary', 'O''Brien', 'mary.obrien@email.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '617-555-0145', '456 Commonwealth Ave', '02115'),
('Robert', 'Garcia', 'rgarcia@email.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '857-555-0189', '789 Boylston Street', '02116'),
('Jennifer', 'Chen', 'jchen@email.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '617-555-0198', '321 Newbury Street', '02116'),
('William', 'Murphy', 'wmurphy@email.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '857-555-0176', '654 Hanover Street', '02113'),
('Linda', 'Rodriguez', 'lrodriguez@email.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '617-555-0165', '987 Washington Street', '02111'),
('Michael', 'Fitzgerald', 'mfitzgerald@email.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '857-555-0134', '147 Tremont Street', '02108'),
('Susan', 'Kennedy', 'skennedy@email.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '617-555-0152', '258 Summer Street', '02110'),
('David', 'Walsh', 'dwalsh@email.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '857-555-0111', '369 Dartmouth Street', '02116'),
('Karen', 'Donovan', 'kdonovan@email.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '617-555-0129', '741 Huntington Ave', '02115');

-- Insert orders from Boston customers
INSERT INTO orders (customer_id, total_amount, status, shipping_address, billing_address) VALUES
(1, 129.99, 'delivered', '123 Beacon Street, Boston, MA 02108', '123 Beacon Street, Boston, MA 02108'),
(2, 89.99, 'processing', '456 Commonwealth Ave, Boston, MA 02115', '456 Commonwealth Ave, Boston, MA 02115'),
(3, 204.97, 'shipped', '789 Boylston Street, Boston, MA 02116', '789 Boylston Street, Boston, MA 02116'),
(4, 39.99, 'delivered', '321 Newbury Street, Boston, MA 02116', '321 Newbury Street, Boston, MA 02116'),
(5, 149.99, 'pending', '654 Hanover Street, Boston, MA 02113', '654 Hanover Street, Boston, MA 02113'),
(6, 59.99, 'processing', '987 Washington Street, Boston, MA 02111', '987 Washington Street, Boston, MA 02111'),
(7, 34.99, 'delivered', '147 Tremont Street, Boston, MA 02108', '147 Tremont Street, Boston, MA 02108'),
(8, 104.98, 'shipped', '258 Summer Street, Boston, MA 02110', '258 Summer Street, Boston, MA 02110'),
(9, 79.99, 'cancelled', '369 Dartmouth Street, Boston, MA 02116', '369 Dartmouth Street, Boston, MA 02116'),
(10, 29.99, 'delivered', '741 Huntington Ave, Boston, MA 02115', '741 Huntington Ave, Boston, MA 02115');

-- Insert order items
INSERT INTO order_items (order_id, product_id, quantity, unit_price) VALUES
(1, 1, 1, 129.99),   -- James bought a Red Sox Jersey
(2, 8, 1, 89.99),    -- Mary bought a Marathon Jacket
(3, 2, 2, 19.99),    -- Robert bought 2 Guidebooks
(3, 4, 1, 24.99),    -- Robert also bought a Harvard Mug
(3, 5, 1, 34.99),    -- Robert also bought a Skyline Poster
(4, 10, 1, 39.99),   -- Jennifer bought a Fenway Snow Globe
(5, 9, 1, 149.99),   -- William bought Paul Revere Silver
(6, 3, 1, 59.99),    -- Linda bought an MIT Hoodie
(7, 5, 1, 34.99),    -- Michael bought a Skyline Poster
(8, 1, 1, 129.99),   -- Susan bought a Red Sox Jersey
(8, 7, 1, 29.99),    -- Susan also bought a Patriots Cap
(9, 6, 1, 79.99),    -- David bought a Lobster Roll Kit
(10, 7, 1, 29.99);   -- Karen bought a Patriots Cap

-- Insert payments
INSERT INTO payments (order_id, payment_method, amount, status, transaction_id) VALUES
(1, 'credit_card', 129.99, 'completed', 'TXN-BOS-123456'),
(2, 'paypal', 89.99, 'completed', 'TXN-BOS-789012'),
(3, 'credit_card', 204.97, 'completed', 'TXN-BOS-345678'),
(4, 'debit_card', 39.99, 'completed', 'TXN-BOS-901234'),
(5, 'credit_card', 149.99, 'pending', 'TXN-BOS-567890'),
(6, 'paypal', 59.99, 'completed', 'TXN-BOS-123789'),
(7, 'credit_card', 34.99, 'completed', 'TXN-BOS-456123'),
(8, 'bank_transfer', 104.98, 'completed', 'TXN-BOS-789456'),
(9, 'credit_card', 79.99, 'refunded', 'TXN-BOS-234567'),
(10, 'debit_card', 29.99, 'completed', 'TXN-BOS-890123');

-- Insert reviews from Boston customers
INSERT INTO reviews (product_id, customer_id, rating, comment) VALUES
(1, 1, 5, 'Perfect Sox jersey! Fits great and authentic quality.'),
(8, 2, 4, 'Love the jacket, but wish it had more pockets.'),
(2, 3, 5, 'Excellent guidebook! Found so many hidden gems on the Freedom Trail.'),
(10, 4, 4, 'Beautiful snow globe, makes a great Boston souvenir.'),
(5, 7, 5, 'The skyline poster looks amazing in my Cambridge apartment.'),
(7, 10, 5, 'Great Patriots cap! Wore it to the game last week.');

-- Create a view for product details with categories
CREATE VIEW product_details AS
SELECT 
    p.product_id,
    p.product_name,
    p.description,
    p.price,
    p.stock_quantity,
    p.sku,
    p.image_url,
    GROUP_CONCAT(c.category_name SEPARATOR ', ') AS categories
FROM products p
LEFT JOIN product_categories pc ON p.product_id = pc.product_id
LEFT JOIN categories c ON pc.category_id = c.category_id
GROUP BY p.product_id;

-- Create a view for order summary
CREATE VIEW order_summary AS
SELECT 
    o.order_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    o.order_date,
    o.total_amount,
    o.status,
    COUNT(oi.order_item_id) AS item_count
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY o.order_id;

-- Stored procedure to update product stock
DELIMITER //
CREATE PROCEDURE update_product_stock(IN p_product_id INT, IN p_quantity INT)
BEGIN
    UPDATE products 
    SET stock_quantity = stock_quantity - p_quantity 
    WHERE product_id = p_product_id AND stock_quantity >= p_quantity;
    
    IF ROW_COUNT() = 0 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Insufficient stock or product not found';
    END IF;
END //
DELIMITER ;

-- Trigger to update product stock after order
DELIMITER //
CREATE TRIGGER after_order_insert
AFTER INSERT ON order_items
FOR EACH ROW
BEGIN
    CALL update_product_stock(NEW.product_id, NEW.quantity);
END //
DELIMITER ;

-- Query to find top-selling Boston products
SELECT 
    p.product_name,
    SUM(oi.quantity) as total_sold,
    SUM(oi.quantity * oi.unit_price) as total_revenue
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
GROUP BY p.product_id
ORDER BY total_sold DESC;

-- Query to find customers from specific Boston zip codes
SELECT 
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) as customer_name,
    c.address,
    c.zip_code,
    COUNT(o.order_id) as order_count
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
WHERE c.zip_code IN ('02108', '02115', '02116')
GROUP BY c.customer_id
ORDER BY order_count DESC;