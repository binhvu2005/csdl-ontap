-- Tạo cơ sở dữ liệu
CREATE DATABASE quanlybanhang;
USE quanlybanhang;

-- Bảng Customers
CREATE TABLE Customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    phone VARCHAR(20) NOT NULL UNIQUE,
    address VARCHAR(255) NULL
);

-- Bảng Products
CREATE TABLE Products (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL UNIQUE,
    price DECIMAL(10,2) NOT NULL,
    quantity INT NOT NULL CHECK (quantity >= 0),
    category VARCHAR(50) NOT NULL
);

-- Bảng Employees
CREATE TABLE Employees (
    employee_id INT AUTO_INCREMENT PRIMARY KEY,
    employee_name VARCHAR(100) NOT NULL,
    birthday DATE NULL,
    position VARCHAR(50) NOT NULL,
    salary DECIMAL(10,2) NOT NULL,
    revenue DECIMAL(10,2) DEFAULT 0
);

-- Bảng Orders
CREATE TABLE Orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT,
    employee_id INT,
    order_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    total_amount DECIMAL(10,2) DEFAULT 0,
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id),
    FOREIGN KEY (employee_id) REFERENCES Employees(employee_id)
);

-- Bảng OrderDetails
CREATE TABLE OrderDetails (
    order_detail_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT,
    product_id INT,
    quantity INT NOT NULL CHECK (quantity > 0),
    unit_price DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (order_id) REFERENCES Orders(order_id),
    FOREIGN KEY (product_id) REFERENCES Products(product_id)
);

-- câu 3.1
alter table Customers add column email varchar(100) not null unique;
-- cau 3.2
alter table Employees drop column birthday;
-- câu 4
-- Thêm dữ liệu vào bảng Customers
INSERT INTO Customers (customer_name, phone, address, email) VALUES
('Nguyễn Văn A', '0987654321', 'Hà Nội', 'nguyenvana@example.com'),
('Trần Thị B', '0976543210', 'Hồ Chí Minh', 'tranthib@example.com'),
('Lê Văn C', '0965432109', 'Đà Nẵng', 'levanc@example.com'),
('Phạm Thị D', '0954321098', 'Hải Phòng', 'phamthid@example.com'),
('Hoàng Văn E', '0943210987', 'Cần Thơ', 'hoangvane@example.com');

-- Thêm dữ liệu vào bảng Products
INSERT INTO Products (product_name, price, quantity, category) VALUES
('Áo Thun', 150000, 50, 'Thời trang'),
('Quần Jean', 300000, 30, 'Thời trang'),
('Giày Thể Thao', 500000, 20, 'Giày dép'),
('Túi Xách', 400000, 15, 'Phụ kiện'),
('Đồng Hồ', 1200000, 10, 'Phụ kiện');

-- Thêm dữ liệu vào bảng Employees
INSERT INTO Employees (employee_name, position, salary, revenue) VALUES
('Nguyễn Văn F', 'Nhân viên bán hàng', 7000000, 0),
('Trần Thị G', 'Nhân viên kho', 8000000, 0),
('Lê Văn H', 'Nhân viên giao hàng', 7500000, 0),
('Phạm Thị I', 'Nhân viên thu ngân', 7200000, 0),
('Hoàng Văn J', 'Quản lý', 15000000, 0);

-- Thêm dữ liệu vào bảng Orders
INSERT INTO Orders (customer_id, employee_id, order_date, total_amount) VALUES
(1, 1, '2024-02-20 10:30:00', 450000),
(2, 2, '2024-02-19 14:00:00', 700000),
(3, 3, '2024-02-18 16:45:00', 500000),
(4, 4, '2024-02-17 11:20:00', 400000),
(5, 5, '2024-02-16 09:15:00', 1200000);

-- Thêm dữ liệu vào bảng OrderDetails
INSERT INTO OrderDetails (order_id, product_id, quantity, unit_price) VALUES
(1, 1, 3, 150000),
(2, 2, 2, 300000),
(3, 3, 1, 500000),
(4, 4, 1, 400000),
(5, 5, 1, 1200000);

-- câu 5.1
select
customer_id ,
customer_name ,
phone ,
address
from Customers;
-- câu 5.2
update Products set product_name = "Laptop Dell XPS" , price = 99.99 where  product_id = 1;
-- câu 5.3 
select 
o.order_id,
c.customer_name,
e.employee_name,
o.order_date,
o.total_amount	
from Orders o
join Customers c on c.customer_id = o.customer_id
join Employees e on o.employee_id = e.employee_id;
-- câu 6.1
select 
c.customer_id,
c.customer_name,
count(order_id) as total_order
from Customers c 
join Orders o on o.customer_id = c.customer_id
group by customer_id;
-- câu 6.2
SELECT 
    e.employee_id, 
    e.employee_name, 
    COALESCE(SUM(o.total_amount), 0) AS total_revenue
FROM Employees e
LEFT JOIN Orders o ON e.employee_id = o.employee_id
WHERE YEAR(o.order_date) = YEAR(CURDATE()) 
GROUP BY e.employee_id, e.employee_name;



-- câu 6.3
select 
p.product_id,
p.product_name,
count(order_detail_id) as count_order
from Products p
join OrderDetails o on p.product_id = o.product_id
join Orders on Orders.order_id = o.order_id
where  month(Orders.order_date) = month(current_date()) and year(Orders.order_date) = year(curdate())
group by product_id ,product_name
having  sum(o.quantity) > 100
order by count_order desc;
-- câu 7.1
select 
c.customer_id ,
c.customer_name
from Customers c
join Orders o on c.customer_id = o.customer_id
group by customer_id
having count(o.order_id ) = 0;
-- câu 7.2
SELECT * 
FROM Products 
WHERE price > (SELECT AVG(price) FROM Products);
-- câu 7.3
SELECT 
    c.customer_id, 
    c.customer_name, 
    SUM(o.total_amount) AS total_spent
FROM Customers c
JOIN Orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id
HAVING total_spent = (
    SELECT MAX(total_spent) 
    FROM (
        SELECT customer_id, SUM(total_amount) AS total_spent
        FROM Orders 
        GROUP BY customer_id
    ) AS subquery
);
-- câu 8.1
CREATE VIEW view_order_list AS
SELECT 
    o.order_id, 
    c.customer_name, 
    e.employee_name, 
    o.total_amount, 
    o.order_date
FROM Orders o
JOIN Customers c ON o.customer_id = c.customer_id
JOIN Employees e ON o.employee_id = e.employee_id
ORDER BY o.order_date DESC;
-- câu 8.2 
CREATE VIEW view_order_detail_product AS
SELECT 
    od.order_detail_id, 
    p.product_name, 
    od.quantity, 
    od.unit_price
FROM OrderDetails od
JOIN Products p ON od.product_id = p.product_id
ORDER BY od.quantity DESC;
-- câu 9.1
DELIMITER //

CREATE PROCEDURE proc_insert_employee(
    IN emp_name VARCHAR(100),
    IN emp_position VARCHAR(50),
    IN emp_salary DECIMAL(10,2)
)
BEGIN
    INSERT INTO Employees (employee_name, position, salary, revenue) 
    VALUES (emp_name, emp_position, emp_salary, 0);
    
    SELECT LAST_INSERT_ID() AS new_employee_id;
END //

DELIMITER ;
-- câu 9.2
DELIMITER //

CREATE PROCEDURE proc_get_orderdetails(IN order_id_param INT)
BEGIN
    SELECT * FROM OrderDetails WHERE order_id = order_id_param;
END //

DELIMITER ;
-- câu 9.3
DELIMITER //

CREATE PROCEDURE proc_cal_total_amount_by_order(IN order_id_param INT, OUT total_products INT)
BEGIN
    SELECT COUNT(DISTINCT product_id) INTO total_products
    FROM OrderDetails 
    WHERE order_id = order_id_param;
END //

DELIMITER ;
-- câu 10 
DELIMITER //

CREATE TRIGGER trigger_after_insert_order_details
AFTER INSERT ON OrderDetails
FOR EACH ROW
BEGIN
    DECLARE available_qty INT;

    -- Lấy số lượng sản phẩm hiện có
    SELECT quantity INTO available_qty FROM Products WHERE product_id = NEW.product_id;

    -- Kiểm tra nếu số lượng không đủ
    IF available_qty < NEW.quantity THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Số lượng sản phẩm trong kho không đủ';
    ELSE
        -- Cập nhật số lượng sản phẩm trong kho
        UPDATE Products 
        SET quantity = quantity - NEW.quantity
        WHERE product_id = NEW.product_id;
    END IF;
END //

DELIMITER ;
-- câu 11
DELIMITER //

CREATE PROCEDURE proc_insert_order_details(
    IN order_id_param INT,
    IN product_id_param INT,
    IN quantity_param INT,
    IN price_param DECIMAL(10,2)
)
BEGIN
    DECLARE order_exists INT;
    DECLARE total_price DECIMAL(10,2);

    -- Kiểm tra xem mã đơn hàng có tồn tại không
    SELECT COUNT(*) INTO order_exists FROM Orders WHERE order_id = order_id_param;

    IF order_exists = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Không tồn tại mã hóa đơn';
    END IF;

    -- Bắt đầu transaction
    START TRANSACTION;

    -- Thêm dữ liệu vào bảng OrderDetails
    INSERT INTO OrderDetails (order_id, product_id, quantity, unit_price) 
    VALUES (order_id_param, product_id_param, quantity_param, price_param);

    -- Cập nhật tổng tiền của đơn hàng
    SELECT SUM(quantity * unit_price) INTO total_price FROM OrderDetails WHERE order_id = order_id_param;
    UPDATE Orders SET total_amount = total_price WHERE order_id = order_id_param;

    -- Nếu không có lỗi, commit transaction
    COMMIT;

END //

DELIMITER ;

