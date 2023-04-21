CREATE DATABASE luxinedu;
USE luxinedu;

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


CREATE TABLE attendancento (
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


/* ----------------------------------BEGIN------------------------------------------------*/



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
 
 /* Check that the CASE statements worked out and there are only numerical values and nulls */
SELECT 
	*
FROM
	attendance_num
LIMIT 5;
    
# Check the values in columns homework, speaking etc

SELECT
	group_name,
	student_name,
	max(homework) AS max_homework,
    min(homework) AS min_homework,
    max(comprehension) AS max_comprehension,
	min(comprehension) AS min_comprehension, #stopped here
    AVG(speaking) AS avg_speaking,
    AVG(behaviour) AS avg_behaviour,
    AVG(vocabulary) AS avg_vocabulary,
    AVG(reading) AS avg_reading,
    AVG(writing) AS avg_writing
FROM
	students AS st 
    INNER JOIN classes AS cl ON st.class_id = cl.class_id
    INNER JOIN attendance_num AS att_num ON st.student_id = att_num.student_id
GROUP BY att_num.student_id
LIMIT 5;

# Value in homework column for groups that use books ACT3 and below (ACT2 and ACT1) is not assigned, so zero values must be chaged to NULL 

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
		
# check that it worked

SELECT
	group_name,
	student_name,
    book_id,
	max(homework) AS max_homework,
    min(homework) AS min_homework,
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
GROUP BY group_name;
 
 /* 1. How well a student fits in the group */  
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
    AVG(behaviour) OVER (PARTITION BY att_num.student_id) AS avg_behaviour,
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

/* 2.Which book I have the most students on (percent)*/ 
CREATE OR REPLACE VIEW st_books_percent AS
SELECT
    book_name,
    count(student_id)/(
    SELECT
		count(student_id)
	FROM
		grups AS gr
	INNER JOIN students AS st ON gr.group_id = st.group_id) AS percentage		
FROM
	grups AS gr 
    INNER JOIN students AS st ON gr.group_id = st.group_id
    INNER JOIN teaching_materials AS tm ON gr.book_id = tm.book_id
    GROUP BY book_name;
    
/*----------------------------------------------------------------------*/

/* 3.Does the homework completion correlate with students avg score for HC1 and up */ 

CREATE OR REPLACE VIEW homework_avg_performance AS
SELECT
student_name,
(AVG(comprehension)+AVG(speaking)+AVG(behaviour)+AVG(vocabulary)+AVG(reading)+AVG(writing))/6 AS avg_performance,
AVG(homework) AS avg_homework
FROM
	students AS st
INNER JOIN attendance_num AS att_num ON st.student_id = att_num.student_id
INNER JOIN grups AS gr ON st.group_id = gr.group_id 
WHERE book_id NOT IN ('ACT3', 'ACT2', 'ACT1','HOT1','HOT2','HOT3','HOTN')
GROUP BY st.student_id
ORDER BY st.student_id;


    
/*----------------------------------------------------------------------*/

/* 4. How many students are shared with each TA (percent) */

CREATE OR REPLACE VIEW percent_st_with_ta AS
SELECT
	bm_name,
    count(student_id)/(
    SELECT
		count(student_id)
	FROM
		students) AS percent
FROM
	students AS st 
	INNER JOIN bilingual_mentors AS bm ON st.bm_id = bm.bm_id
GROUP BY bm_name;
/*----------------------------------------------------------------------*/

/*5. Aspect with which students of the each group struggle the most*/

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
    INNER JOIN grups AS gr ON st.group_id = gr.group_id
GROUP BY book_id;


USE i2intedu;
SHOW TABLES;
SELECT
	*
FROM
	students;
    