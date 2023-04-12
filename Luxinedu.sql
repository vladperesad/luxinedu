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

/* 1. How well a student fits in the group */
#Create a temporary table 'attendance_num'that has grades 1-5 rather than A-E

DROP TABLE IF EXISTS attendance_num;
CREATE TEMPORARY TABLE attendance_num
SELECT
	record_id,
    att_date,
    stud_id,
    CASE homework
    WHEN 1 THEN 5
    WHEN 0 THEN 0
    ELSE NULL
    END AS homework,
    CASE compr
    WHEN 'A' THEN 5
    WHEN 'B' THEN 4
    WHEN 'C' THEN 3
    WHEN 'D' THEN 2
    WHEN 'E' THEN 1
    ELSE NULL
    END AS comp,
    CASE speak
    WHEN 'A' THEN 5
    WHEN 'B' THEN 4
    WHEN 'C' THEN 3
    WHEN 'D' THEN 2
    WHEN 'E' THEN 1
    ELSE NULL
    END AS speak,
    CASE behav
    WHEN 'A' THEN 5
    WHEN 'B' THEN 4
    WHEN 'C' THEN 3
    WHEN 'D' THEN 2
    WHEN 'E' THEN 1
    ELSE NULL
    END AS behav,
    CASE vocab
    WHEN 'A' THEN 5
    WHEN 'B' THEN 4
    WHEN 'C' THEN 3
    WHEN 'D' THEN 2
    WHEN 'E' THEN 1
    ELSE NULL
    END AS vocab,
    CASE readn
    WHEN 'A' THEN 5
    WHEN 'B' THEN 4
    WHEN 'C' THEN 3
    WHEN 'D' THEN 2
    WHEN 'E' THEN 1
    ELSE NULL
    END AS readn,
    CASE writ
    WHEN 'A' THEN 5
    WHEN 'B' THEN 4
    WHEN 'C' THEN 3
    WHEN 'D' THEN 2
    WHEN 'E' THEN 1
    ELSE NULL
    END AS writ
FROM
	attendance;
    
#perform a join so that students names and group names can be viewed

SELECT
	record_id,
    att_date,
    stud_name,
    class_name,
    homework,
    comp,
    speak,
    behav,
    vocab,
    readn,
    writ
FROM
	students AS std
    INNER JOIN attendance_num AS att ON std.stud_id = att.stud_id
    INNER JOIN classes AS cls ON std.class_id = cls.class_id
ORDER BY
	record_id;