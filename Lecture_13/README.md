1. Встановлюємо Mysql

sudo apt update
sudo apt install mysql-server
sudo mysql_secure_installation

![Alt-текст](<1.png>)

2. Підключаємося до Mysql та створюємо базу SchoolDB

sudo mysql -u root -p
CREATE DATABASE SchoolDB;
USE SchoolDB;

![Alt-текст](<2.png>)

3. Створюємо таблиці Institutions, Classes, Children, Parents

CREATE TABLE Institutions (
    institution_id INT AUTO_INCREMENT PRIMARY KEY,
    institution_name VARCHAR(100) NOT NULL,
    institution_type ENUM('School', 'Kindergarten') NOT NULL,
    address VARCHAR(255) NOT NULL
);
CREATE TABLE Classes (
    class_id INT AUTO_INCREMENT PRIMARY KEY,
    class_name VARCHAR(100) NOT NULL,
    institution_id INT,
    direction ENUM('Mathematics', 'Biology and Chemistry', 'Language Studies') NOT NULL,
    FOREIGN KEY (institution_id) REFERENCES Institutions(institution_id) ON DELETE CASCADE
);
CREATE TABLE Children (
    child_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    birth_date DATE NOT NULL,
    year_of_entry YEAR NOT NULL,
    age INT NOT NULL,
    institution_id INT,
    class_id INT,
    FOREIGN KEY (institution_id) REFERENCES Institutions(institution_id) ON DELETE CASCADE,
    FOREIGN KEY (class_id) REFERENCES Classes(class_id) ON DELETE SET NULL
);
CREATE TABLE Parents (
    parent_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    child_id INT,
    tuition_fee DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (child_id) REFERENCES Children(child_id) ON DELETE CASCADE
);

![Alt-текст](<3.png>)

4. Наповнюємо базу даними

![Alt-текст](<4.png>)

![Alt-текст](<5.png>)

5. Виконаємо запити
5.1 Виводимо список дітей з вказанням закладу та напрямку навчання

![Alt-текст](<6.png>)

5.2 Виводимо інформацію про батьків та дітей та вартість навчання

![Alt-текст](<7.png>)

5.3 Список закладів та їх дітей

![Alt-текст](<8.png>)

6. Зробимо дамп бази даних

mysqldump -u root -p SchoolDB > /backup/SchoolDB_backup.sql

![Alt-текст](<9.png>)

7. Відновимо базу з бекапа та перевіримо цілісність, виконавши запит

mysql -u root -p SchoolDB < /backup/SchoolDB_backup.sql

![Alt-текст](<10.png>)
![Alt-текст](<11.png>)

8. Анонімізуємо дані 
![Alt-текст](<12.png>)
![Alt-текст](<13.png>)

