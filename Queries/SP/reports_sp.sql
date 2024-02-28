----Last 3 Report--------------------------------
--•	Report that takes course ID and returns its topics
use [ Examination]
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
go
create proc SelectCourseTopic @Course_ID int
with encryption 
as 
	 select c.Course_ID Course_ID,Course_Name,t.Topic_ID Topic_ID , Topic_Name
	 from Course c
	 join Course_Topic ct
	 on c.Course_ID = ct.Course_ID
	 join Topic t
	 on t.Topic_ID = ct.Topic_ID
	 where c.Course_ID = @Course_id
---------------
--•	Report that takes exam number and returns the Questions in it and chocies [freeform report]

GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
go
create proc QuestionsinExam @exam_id int
with encryption 
as 
	 select Question, Choice
	 from Exam e
	 join Exam_Quest eq
	 on e.Exam_ID = eq.Exam_ID
	 join Question q
	 on q.Question_ID = eq.Question_ID
	 join Choice c
	 on c.Question_ID = q.Question_ID
	 where e.Exam_ID = @exam_id


GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
go
-------------------------
--•	Report that takes exam number and the student ID then returns 
--the Questions in this exam with the student answers. 
create proc QuestionsinExamWithSTAnswer @exam_id int, @st_id int
with encryption 
as 
	 select Question, Student_Answer
	 from Exam e
	 join Exam_Quest eq
	 on e.Exam_ID = eq.Exam_ID
	 join Question q
	 on q.Question_ID = eq.Question_ID
	 join Student_Exam se
	 on se.Exam_ID = e.Exam_ID
	 join Student s
	 on s.ST_ID = se.ST_ID
	 where e.Exam_ID = @exam_id and s.ST_ID = @st_id

---------------------------------------------
