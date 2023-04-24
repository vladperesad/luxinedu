#Create a database luxinedu.

CREATE DATABASE luxinedu;
USE luxinedu;

#Create tables using schema https://drawsql.app/teams/mickey-3220s/diagrams/luxinedu/?ref=embed

CREATE TABLE books (
	book_id VARCHAR(25) PRIMARY KEY,
	book_name VARCHAR(25) NOT NULL
);

DESCRIBE books;

CREATE TABLE teach_assistants (
	ta_id INT AUTO_INCREMENT PRIMARY KEY,
	ta_name VARCHAR (25) NOT NULL
);

DESCRIBE teach_assistants;

CREATE TABLE classes (
	class_id INT AUTO_INCREMENT PRIMARY KEY,
	class_name VARCHAR (25),
	ta_id INT,
	book_id VARCHAR(25),
FOREIGN KEY (ta_id)
	REFERENCES teach_assistants (ta_id) 
    ON UPDATE CASCADE ON DELETE CASCADE,
FOREIGN KEY (book_id)
	REFERENCES books (book_id)
    ON UPDATE CASCADE ON DELETE CASCADE
    );
    
DESCRIBE classes;


CREATE TABLE students (
	student_id INT AUTO_INCREMENT PRIMARY KEY,
	student_name VARCHAR (25) NOT NULL, 
	class_id INT,
	ta_id INT,
FOREIGN KEY (class_id)
	REFERENCES classes (class_id)
    ON UPDATE CASCADE ON DELETE CASCADE,
FOREIGN KEY (ta_id)
	REFERENCES teach_assistants (ta_id)
    ON UPDATE CASCADE ON DELETE CASCADE
);

DESCRIBE students;


CREATE TABLE attendance (
	record_id INT AUTO_INCREMENT PRIMARY KEY,
	att_date DATE NOT NULL,
	student_id INT NOT NULL,
	un_lsn DECIMAL (4,2) NOT NULL,
	un_lsn_2 DECIMAL (4,2),
	homework BOOLEAN,
	comprehension ENUM ('E','D','C','B','A') NOT NULL,
	speaking ENUM ('E','D','C','B','A') NOT NULL,
	behaviour ENUM ('E','D','C','B','A') NOT NULL,
	vocabulary ENUM ('E','D','C','B','A'),
	reading ENUM ('E','D','C','B','A'),
	writing ENUM ('E','D','C','B','A'),
FOREIGN KEY (student_id)
	REFERENCES students (student_id)
    ON UPDATE CASCADE ON DELETE CASCADE
);

DESCRIBE attendance;

---

#Check min and max dates

SELECT
	min(att_date) AS start,
    max(att_date) AS end
FROM
	attendance;

#Number of students

SELECT
	count(distinct(student_id)) AS num_of_ss
FROM
	attendance;


# Check the data by making sure the values in each column are what they are supposed to be.

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
    
SELECT
    DISTINCT(speaking)
FROM
	attendance;
    
 SELECT
    DISTINCT(vocabulary)
FROM
	attendance;
    
SELECT
    DISTINCT(reading)
FROM
	attendance;
    
SELECT
    DISTINCT(writing)
FROM
	attendance;


#Create a table 'attendance_num'that has grades 1-5 rather than Great - Poor

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
    WHEN 'A' THEN 5
	WHEN 'B' THEN 4
	WHEN 'C' THEN 3
	WHEN 'D' THEN 2
	WHEN 'E' THEN 1
    ELSE NULL
    END AS comprehension,
    CASE speaking
    WHEN 'A' THEN 5
	WHEN 'B' THEN 4
	WHEN 'C' THEN 3
	WHEN 'D' THEN 2
	WHEN 'E' THEN 1
    ELSE NULL
    END AS speaking,
    CASE behaviour
    WHEN 'A' THEN 5
	WHEN 'B' THEN 4
	WHEN 'C' THEN 3
	WHEN 'D' THEN 2
	WHEN 'E' THEN 1
    ELSE NULL
    END AS behaviour,
    CASE vocabulary
    WHEN 'A' THEN 5
	WHEN 'B' THEN 4
	WHEN 'C' THEN 3
	WHEN 'D' THEN 2
	WHEN 'E' THEN 1
    ELSE NULL
    END AS vocabulary,
    CASE reading
    WHEN 'A' THEN 5
	WHEN 'B' THEN 4
	WHEN 'C' THEN 3
	WHEN 'D' THEN 2
	WHEN 'E' THEN 1
    ELSE NULL
    END AS reading,
    CASE writing
    WHEN 'A' THEN 5
	WHEN 'B' THEN 4
	WHEN 'C' THEN 3
	WHEN 'D' THEN 2
	WHEN 'E' THEN 1
    ELSE NULL
    END AS writing
FROM
	attendance;
 
 # Check that the CASE statements worked out and there are only numerical values and nulls
 
SELECT 
	*
FROM
	attendance_num
LIMIT 5;
    
# Check the values in columns homework, speaking etc

SELECT
	class_name,
	max(homework) AS max_hmw,
    min(homework) AS min_hmw,
    max(comprehension) AS max_comp,
	min(comprehension) AS min_comp,
    max(speaking) AS max_spk,
    min(speaking) AS min_spk,
	max(behaviour) AS max_beh,
    min(behaviour) AS min_beh,
    max(vocabulary) AS max_voc,
    min(vocabulary) AS min_voc,
    max(reading) AS max_read,
    min(reading) AS min_read,
    max(writing) AS max_wrt,
    min(writing) AS min_wrt
FROM
	students AS st 
    INNER JOIN classes AS cl ON st.class_id = cl.class_id
    INNER JOIN attendance_num AS att_num ON st.student_id = att_num.student_id
GROUP BY class_name;

# Value in homework column for groups that use books MV3 and below (MV2 and MV11) is not assigned, so zero values must be chaged to NULL 

# Create a temporary table that contains book ids as well as students ids 

DROP TABLE IF EXISTS classes_homework;
CREATE TEMPORARY TABLE classes_homework
SELECT
	student_id,
    book_id
FROM
	students AS st 
    INNER JOIN classes AS cl ON st.class_id = cl.class_id;

UPDATE attendance_num
	SET homework = NULL
	WHERE student_id IN (
    SELECT
		student_id
    FROM
		classes_homework
	WHERE book_id IN ('MV3', 'MV2','MV1','HO1','HO2','HO3','HOi'));
		
# check that the update worked properly

SELECT
	group_name,
    book_id,
	max(homework) AS max_hmw,
    min(homework) AS min_hmw
FROM
	students AS st 
    INNER JOIN grups AS gr ON st.group_id = gr.group_id
    INNER JOIN attendance_num AS att_num ON st.student_id = att_num.student_id
GROUP BY group_name;
 
#  question 1.
# How well a student fits in the group
 
# pull up students average performance versus average group performance into a view

CREATE OR REPLACE VIEW st_avg_vs_cl_avg AS
SELECT
	DISTINCT(att_num.student_id),
    student_name,
    cl.class_id,
    class_name,
    AVG(homework) OVER (PARTITION BY att_num.student_id) AS avg_hmw,
    AVG(homework) OVER (PARTITION BY cl.class_id) AS avg_cl_hmw,
    AVG(comprehension) OVER (PARTITION BY att_num.student_id) AS avg_comp,
    AVG(comprehension) OVER (PARTITION BY cl.class_id) AS avg_cl_comp,
    AVG(speaking) OVER (PARTITION BY att_num.student_id) AS avg_spk,
    AVG(speaking) OVER (PARTITION BY cl.class_id) AS avg_cl_spk,
    AVG(behaviour) OVER (PARTITION BY att_num.student_id) AS avg_beh,
    AVG(behaviour) OVER (PARTITION BY cl.class_id) AS avg_cl_beh,
    AVG(vocabulary) OVER (PARTITION BY att_num.student_id) AS avg_voc,
    AVG(vocabulary) OVER (PARTITION BY cl.class_id) AS avg_cl_voc,
    AVG(reading) OVER (PARTITION BY att_num.student_id) AS avg_read,
    AVG(reading) OVER (PARTITION BY cl.class_id) AS avg_cl_read,
    AVG(writing) OVER (PARTITION BY att_num.student_id) AS avg_wrt,
    AVG(writing) OVER (PARTITION BY cl.class_id) AS avg_cl_wrt
FROM
	students AS st
    INNER JOIN attendance_num AS att_num ON st.student_id = att_num.student_id
    INNER JOIN classes AS cl ON st.class_id = cl.class_id
ORDER BY class_id;


# question 2. 
# What percentage of students uses each book


CREATE OR REPLACE VIEW st_books_percent AS
SELECT
    book_name,
    count(student_id)/(
    SELECT
		count(student_id)
	FROM
		classes AS cl
	INNER JOIN students AS st ON cl.class_id = st.class_id) AS percentage		
FROM
	class AS cl 
    INNER JOIN students AS st ON cl.class_id = st.group_id
    INNER JOIN books AS bk ON cl.book_id = bk.book_id
    GROUP BY book_name;
    


#question 3.
# What perentage of students is shared with each teaching assistant

CREATE OR REPLACE VIEW percent_st_with_ta AS
SELECT
	ta_name,
    count(student_id)/(
    SELECT
		count(student_id)
	FROM
		students) AS percent
FROM
	students AS st 
	INNER JOIN teach_assisstants AS ta ON st.ta_id = ta.ta_id
GROUP BY ta_name;

# question 4. 
# Aspect with which students of the each group struggle the most*/

CREATE OR REPLACE VIEW st_performance_with_book AS
SELECT
	book_id,
	AVG(comprehension) AS avg_comprehension,
    AVG(speaking) AS avg_speaking,
    AVG(behaviour) AS avg_behaviour,
    AVG(vocabulary) AS avg_vocabulary,
    AVG(reading) AS avg_reading,
    AVG(writing) AS avg_writing
FROM
	students AS st
    INNER JOIN attendance_num AS att_num ON st.student_id = att_num.student_id
    INNER JOIN classes AS cl ON st.class_id = cl.class_id
GROUP BY book_id;
