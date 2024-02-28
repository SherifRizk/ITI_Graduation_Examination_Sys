--------------------Students Grades
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
create or alter proc Stud_Grades  @St_id int 
with encryption
As
select  Course_Name As Course_Name ,Course_Duration
      ,Course_Level , St_Grade  
from Stud_Course AS S inner join Course As C
on S.Course_ID=C.Course_ID and St_ID=@St_id

GO
--------------------Courses No Students
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
Create or alter Proc  Courses_NoStud  @Ins_ID int 
with encryption
As
SELECT        Course.Course_Name, count (st_id) As Number_of_Students
FROM            Course INNER JOIN
                         Inst_Course ON Course.Course_ID = Inst_Course.Course_ID INNER JOIN
                         Stud_Course ON Course.Course_ID = Stud_Course.Course_ID 
						 where  Instructor_ID=@Ins_ID
						 group by Course.Course_Name
						
GO
---------------------------------SP Students Deptartments
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
Create or alter Proc Studs_Dept @Dept_ID INT
AS
BEGIN
    SELECT s.[ST_ID],
           s.[ST_SSN],
           s.[ST_Fname],
           s.[ST_Lname],
           s.[ST_BirthDate],
           s.[ST_Age],
           s.[ST_City],
           s.[ST_Gender],
           s.[Intake_ID],
           s.[Track_ID]
           
    FROM Student s
    INNER JOIN Stud_Course sc ON s.ST_ID          = sc.St_ID
    INNER JOIN Course c       ON sc.Course_ID     = c.Course_ID
	INNER JOIN Inst_Course ic ON c.Course_ID      = ic.Course_ID
	INNER JOIN Instructor i   ON ic.Instructor_ID = i.Instructor_ID
    INNER JOIN Deptartment d   ON i.Dept_ID        = d.Dept_ID
    WHERE d.Dept_ID = @Dept_ID
END
  
-----------------------
----Last 3 Report--------------------------------
--•	Report that takes course ID and returns its topics ------- SP Select Course Topic

GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
go
create or alter proc SelectCourseTopic @Course_id int
with encryption 
as 
	 select c.Course_ID Course_ID,Course_Name,t.Topic_ID Topic_ID , Topic_Name
	 from Course c
	 join Course_Topic ct
	 on c.Course_ID = ct.Course_ID
	 join Topic t
	 on t.Topic_ID = ct.Topic_ID
	 where c.Course_ID =  @Course_id
----------------------------------View Questions in Exam -----
--alter view Questions_in_Exam
--with encryption 
--as 
--	with Choices 
--	as (select Choice_ID, Question_ID, Choice
--	from Choice)
--	 select e.Exam_ID Exam_ID,q.Question_ID Question_ID
--	 ,Question, c1.Choice Choice1, c2.Choice Choice2, isnull(c3.Choice,'') Choice3,
--	 isnull(c4.Choice,'') Choice4
--		 from Exam e
--		 join Exam_Quest eq
--		 on e.Exam_ID = eq.Exam_ID
--		 join Question q
--		 on q.Question_ID = eq.Question_ID
--		 join Choices c1
--		 on c1.Question_ID = q.Question_ID and c1.Choice like '%a)%'
--		 join Choices c2
--		 on c2.Question_ID = q.Question_ID and c2.Choice like '%b)%'
--		  left join Choices c3
--		 on c3.Question_ID = q.Question_ID and c3.Choice like '%c)%'
--		 left join Choices c4
--		 on c4.Question_ID = q.Question_ID and c4.Choice like '%d)%'
---------------------------- SP Questions in Exam
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO

ALTER PROC QuestionsinExam @exam_id int
WITH ENCRYPTION 
AS 
BEGIN
    SELECT 
        ROW_NUMBER() OVER (ORDER BY Question ASC) AS RowNumber, 
        Question, Choice1, Choice2, Choice3, Choice4
    FROM Questions_in_Exam
    WHERE Exam_ID = @exam_id
END
GO
--------------------------------Questions in Exam With ST Answer
--•	Report that takes exam number and the student ID then returns 
--the Questions in this exam with the student answers. 
create or alter proc QuestionsinExamWithSTAnswer @exam_id int, @st_id int
with encryption 
as 
		BEGIN	
			WITH RankedQuestions AS (
				SELECT 
					ROW_NUMBER() OVER (ORDER BY q.Question_ID) AS RowNumber,
					--se.[Question_ID],
					q.Question,
					se.[Student_Answer],
					CASE WHEN se.[Question_Grade] = 1 THEN 'Correct Answer'
						 WHEN se.[Question_Grade] = 0 THEN 'Wrong Answer'
					END AS [Answer Correction]
				FROM Student_Exam se
				JOIN Exam e ON e.Exam_ID = se.Exam_ID
				JOIN Question q ON q.Question_ID = se.Question_ID
				WHERE e.Exam_ID = @exam_id AND se.ST_ID = @st_id
			)
			SELECT RowNumber, Question, Student_Answer, [Answer Correction]
			FROM RankedQuestions
		END		
	

QuestionsinExamWithSTAnswer 4,1 

