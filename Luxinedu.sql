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

USE i2intedu;

/* ----------------------------------BEGIN------------------------------------------------*/


/* 1. How well a student fits in the group */
# Check how clean the data is by looking at uniqie values in each column

SELECT
    DISTINCT(homework)
FROM
	attendance;
	
SELECT
    DISTINCT(comprehension)
FROM
	attendance;
SELECT
    DISTINCT(behaviour)
FROM
	attendance;
    #etc

#Create a temporary table 'attendance_num'that has grades 1-5 rather than Great - Poor

DROP TABLE IF EXISTS attendance_num;
CREATE TABLE attendance_num
SELECT
	record_id,
    att_date,
    student_id,
    CASE homework
    WHEN 1 THEN 5
    WHEN 0 THEN 0
    ELSE NULL
    END AS homework,
    CASE comprehension
    WHEN 'Great' THEN 5
    WHEN 'Good' THEN 4
    WHEN 'Satisfactory' THEN 3
    WHEN 'Poor' THEN 2
    WHEN 'None' THEN 1
    ELSE NULL
    END AS comprehension,
    CASE speaking
    WHEN 'Great' THEN 5
    WHEN 'Misses words' THEN 4
    WHEN 'Single word' THEN 3
    WHEN 'Needs help' THEN 2
    WHEN 'None' THEN 1
    ELSE NULL
    END AS speaking,
    CASE behaviour
    WHEN 'Very active' THEN 5
    WHEN 'Tried' THEN 4
    WHEN 'Satisfactory' THEN 3
    WHEN 'Poor' THEN 2
    WHEN 'None' THEN 1
    ELSE NULL
    END AS behaviour,
    CASE vocabulary
    WHEN 'Knows all' THEN 5
    WHEN 'Knows some' THEN 4
    WHEN 'Knows basic' THEN 3
    WHEN 'Needs help' THEN 2
    WHEN 'None' THEN 1
    ELSE NULL
    END AS vocabulary,
    CASE reading
    WHEN 'Great' THEN 5
    WHEN 'Good' THEN 4
    WHEN 'Satisfactory' THEN 3
    WHEN 'Poor' THEN 2
    WHEN 'None' THEN 1
    ELSE NULL
    END AS reading,
    CASE writing
    WHEN 'Great' THEN 5
    WHEN 'Good' THEN 4
    WHEN 'Satisfactory' THEN 3
    WHEN 'Poor' THEN 2
    WHEN 'None' THEN 1
    ELSE NULL
    END AS writing
FROM
	attendance;
 
 /* Check that the CASE statements worked out and there are only numerical values and nulls */
SELECT 
	*
FROM
	attendance_num;
    
# Check the values in columns homework, speaking etc

SELECT
	group_name,
	student_name,
	AVG(homework) AS avg_homework,
    AVG(comprehension) AS avg_comprehension,
    AVG(speaking) AS avg_speaking,
    AVG(behaviour) AS avg_behaviour,
    AVG(vocabulary) AS avg_vocabulary,
    AVG(reading) AS avg_reading,
    AVG(writing) AS avg_writing
FROM
	students AS st 
    INNER JOIN grups AS gr ON st.group_id = gr.group_id
    INNER JOIN attendance_num AS att_num ON st.student_id = att_num.student_id
GROUP BY att_num.student_id;

# Value in homework column for groups that use books ACT3 and below (ACT2 and ACT1) is not assigned, so zero values must be chaged to NULL 

# Create a temporary table that contains book ids as well as students ids 

DROP TABLE IF EXISTS groups_homework;
CREATE TEMPORARY TABLE groups_homework
SELECT
	student_id,
    book_id
FROM
	students AS st 
    INNER JOIN grups AS gr ON st.group_id = gr.group_id;

UPDATE attendance_num
	SET homework = NULL
	WHERE student_id IN (
    SELECT
		student_id
    FROM
		groups_homework
	WHERE book_id IN ('ACT3', 'ACT2','ACT1'));
		
# check that it worked

SELECT
	group_name,
	student_name,
	AVG(homework) AS avg_homework,
    AVG(comprehension) AS avg_comprehension,
    AVG(speaking) AS avg_speaking,
    AVG(behaviour) AS avg_behaviour,
    AVG(vocabulary) AS avg_vocabulary,
    AVG(reading) AS avg_reading,
    AVG(writing) AS avg_writing
FROM
	students AS st 
    INNER JOIN grups AS gr ON st.group_id = gr.group_id
    INNER JOIN attendance_num AS att_num ON st.student_id = att_num.student_id
GROUP BY att_num.student_id;
    
# pull up students average performance versus average group performance into a view

CREATE OR REPLACE VIEW st_avg_vs_gr_avg AS
SELECT
	DISTINCT(att_num.student_id),
    student_name,
    grp.group_id,
    group_name,
    AVG(homework) OVER (PARTITION BY att_num.student_id) AS avg_homework,
    AVG(homework) OVER (PARTITION BY grp.group_id) AS avg_gr_homework,
    AVG(comprehension) OVER (PARTITION BY att_num.student_id) AS avg_comprehension,
    AVG(comprehension) OVER (PARTITION BY grp.group_id) AS avg_gr_comprehension,
    AVG(speaking) OVER (PARTITION BY att_num.student_id) AS avg_speaking,
    AVG(speaking) OVER (PARTITION BY grp.group_id) AS avg_gr_speaking,
    AVG (behaviour) OVER (PARTITION BY att_num.student_id) AS avg_behaviour,
    AVG(behaviour) OVER (PARTITION BY grp.group_id) AS avg_gr_behaviour,
    AVG(vocabulary) OVER (PARTITION BY att_num.student_id) AS avg_vocabulary,
    AVG(vocabulary) OVER (PARTITION BY grp.group_id) AS avg_gr_vocabulary,
    AVG(reading) OVER (PARTITION BY att_num.student_id) AS avg_reading,
    AVG(reading) OVER (PARTITION BY grp.group_id) AS avg_gr_reading,
    AVG(writing) OVER (PARTITION BY att_num.student_id) AS avg_writing,
    AVG(writing) OVER (PARTITION BY grp.group_id) AS avg_gr_writing
FROM
	students AS st
    INNER JOIN attendance_num AS att_num ON st.student_id = att_num.student_id
    INNER JOIN grups AS grp ON st.group_id = grp.group_id
ORDER BY group_id;

/*----------------------------------------------------------------------*/

