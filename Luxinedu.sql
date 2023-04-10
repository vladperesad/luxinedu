CREATE DATABASE Luxinedu;
USE luxinedu;

DROP TABLE IF EXISTS books;
CREATE TABLE books (
book_id INT AUTO_INCREMENT PRIMARY KEY,
book_name VARCHAR(25) NOT NULL
);

CREATE TABLE teach_assistants (
ta_id INT AUTO_INCREMENT PRIMARY KEY,
ta_name VARCHAR (25) NOT NULL
);

CREATE TABLE classes (
class_id INT AUTO_INCREMENT PRIMARY KEY,
class_name VARCHAR (25),
ta_id INT,
book_id INT,
FOREIGN KEY (ta_id)
	REFERENCES teach_assistants (ta_id) 
    ON UPDATE CASCADE ON DELETE CASCADE,
FOREIGN KEY (book_id)
	REFERENCES books (book_id)
    ON UPDATE CASCADE ON DELETE CASCADE
    );

CREATE TABLE students (
stud_id INT AUTO_INCREMENT PRIMARY KEY,
stud_name VARCHAR (25) NOT NULL, 
class_id INT,
ta_id INT,
FOREIGN KEY (class_id)
	REFERENCES classes (class_id)
    ON UPDATE CASCADE ON DELETE CASCADE,
FOREIGN KEY (ta_id)
	REFERENCES teach_assistants (ta_id)
    ON UPDATE CASCADE ON DELETE CASCADE
);

DROP TABLE IF EXISTS attendance;
CREATE TABLE attendance (
record_id INT AUTO_INCREMENT PRIMARY KEY,
att_date DATE NOT NULL,
stud_id INT NOT NULL,
unit_lsn DECIMAL (4,2) NOT NULL,
unit_lsn_2 DECIMAL (4,2),
homework BOOLEAN,
compr VARCHAR (10),#ENUM ('E','D','C','B','A') NOT NULL,
speak VARCHAR (10),#ENUM ('E','D','C','B','A') NOT NULL,
behav VARCHAR (10),#ENUM ('E','D','C','B','A') NOT NULL,
vocab VARCHAR (10),#ENUM ('E','D','C','B','A'),
readn VARCHAR (10),#ENUM ('E','D','C','B','A'),
writ VARCHAR (10),#ENUM ('E','D','C','B','A'),
FOREIGN KEY (stud_id)
	REFERENCES students (stud_id)
    ON UPDATE CASCADE ON DELETE CASCADE
);

DESCRIBE attendance;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/attendance.csv'
INTO TABLE attendance
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n';

SHOW TABLES;
SELECT
	*
FROM
	students;