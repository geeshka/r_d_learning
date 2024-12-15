
# **Налаштування бази даних у AWS RDS з публічним доступом**

## **1. Створення мережевої інфраструктури (VPC)**
Ми створили нову мережу (VPC) з публічним доступом, щоб забезпечити з'єднання з базою даних через інтернет.

### Кроки:
1. **Створення VPC**:
   - **Назва:** `library`
   - **CIDR блок:** `10.0.0.0/16`
2. **Створення публічної підмережі**:
   - **Назва:** `library-public-subnet`  
   - **CIDR блок:** `10.0.1.0/24`
   - **Зона доступності:** `eu-north-1a`
3. **Створення Internet Gateway (IGW)**:
   - Під'єднано до VPC `library`.
4. **Route Table для публічної підмережі**:
   - Маршрут `0.0.0.0/0` спрямовано на IGW.
5. **Security Group (SG)**:
   - **Назва:** `library-db-sg`
   - Дозволено доступ по порту `3306` лише з мого IP.

---

## **2. Налаштування Subnet Group для RDS**
AWS RDS вимагає Subnet Group, яка охоплює **щонайменше дві зони доступності (AZ)**.  
1. Створено додаткову публічну підмережу:  
   - **Назва:** `library-public-subnet-2`  
   - **CIDR блок:** `10.0.2.0/24`  
   - **Зона доступності:** `eu-north-1b`  
2. Створено **DB Subnet Group**, яка включає обидві публічні підмережі.

![Alt-текст](<1.png>)
![Alt-текст](<2.png>)
![Alt-текст](<3.png>)
![Alt-текст](<4.png>)
![Alt-текст](<5.png>)
---

## **3. Створення RDS інстансу**
1. **Тип бази даних:** MySQL  
2. **Назва інстансу:** `library-db`  
3. **Public Access:** `Yes`  
4. **Subnet Group:** `library-subnet-group`  
5. **Security Group:** `library-db-sg`  
6. **Endpoint для підключення:**  
   Отримано після створення інстансу.

library-db.cpmssugck11v.eu-north-1.rds.amazonaws.com
![Alt-текст](<6.png>)
![Alt-текст](<7.png>)
![Alt-текст](<8.png>)
![Alt-текст](<9.png>)
![Alt-текст](<10.png>)
---

## **4. Створення бази даних та таблиць**

![Alt-текст](<15.png>)

### Створення бази `library`:
```sql
CREATE DATABASE library; - видасть помилку, бо база вже створена при створенні інстансу РДС
USE library;
```

### Створення таблиць:

**Таблиця №1: authors**
```sql
CREATE TABLE authors (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    country VARCHAR(255)
);
```

**Таблиця №2: books**
```sql
CREATE TABLE books (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    author_id INT,
    genre VARCHAR(50),
    FOREIGN KEY (author_id) REFERENCES authors(id)
);
```

**Таблиця №3: reading_status**
```sql
CREATE TABLE reading_status (
    id INT AUTO_INCREMENT PRIMARY KEY,
    book_id INT,
    status ENUM('reading', 'completed', 'planned') NOT NULL,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (book_id) REFERENCES books(id)
);
```

---

## **5. Внесення даних**

### Додавання авторів:
```sql
INSERT INTO authors (name, country) VALUES 
('George Orwell', 'United Kingdom'),
('J.K. Rowling', 'United Kingdom'),
('Haruki Murakami', 'Japan');
```

### Додавання книг:
```sql
INSERT INTO books (title, author_id, genre) VALUES 
('1984', 1, 'Dystopian'),
('Harry Potter and the Philosopher's Stone', 2, 'Fantasy'),
('Kafka on the Shore', 3, 'Magical realism');
```

### Додавання статусу читання:
```sql
INSERT INTO reading_status (book_id, status) VALUES 
(1, 'reading');
```

---

## **6. Виконання запитів**

### Знайти всі книги, які ще не прочитані:
```sql
SELECT books.title, authors.name 
FROM books
JOIN authors ON books.author_id = authors.id
LEFT JOIN reading_status ON books.id = reading_status.book_id
WHERE reading_status.status IS NULL OR reading_status.status != 'completed';
```

### Підрахунок книг, які в процесі читання:
```sql
SELECT COUNT(*) AS reading_books
FROM reading_status
WHERE status = 'reading';
```

---

## **7. Налаштування доступу**

### Створення нового користувача:
```sql
CREATE USER 'library_user'@'%' IDENTIFIED BY 'strong_password';
```

### Налаштування прав доступу:
```sql
GRANT SELECT, INSERT, UPDATE ON library.* TO 'library_user'@'%';
FLUSH PRIVILEGES;
```
![Alt-текст](<16.png>)
![Alt-текст](<17.png>)
---

## **8. Моніторинг та резервне копіювання**
1. **Автоматичне резервне копіювання**:
   - Встановлено **Backup Retention Period**: 7 днів.
2. **Моніторинг у CloudWatch**:
   - **CPU Utilization**  
   - **Number of Connections**  
   - **IOPS**
![Alt-текст](<18.png>)
![Alt-текст](<19.png>)
![Alt-текст](<20.png>)
![Alt-текст](<21.png>)
---

