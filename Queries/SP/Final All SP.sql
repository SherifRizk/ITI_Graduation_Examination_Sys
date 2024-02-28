use [ Examination]
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
create or alter PROC Exam_Generation @ST_ID int,@Exam_Title nvarchar(300),@Exam_Duration int , @Exam_Date datetime , @Questions_Nums int
,@Exam_Grade int ,@Course_ID int ,@TF_Q int =5 , @MCQ_Q int =5
With Encryption
AS
Begin

	Begin Try
			declare @N_MCQ int = (select count(*) from Question where Course_ID = @Course_ID and Question_Type='MCQ')
			declare @TF int = (select count(*) from Question where Course_ID = @Course_ID and Question_Type='True/false')
			declare @TEMP_MCQ table (ID int, QTYPE nvarchar(20),ANS nchar(500),Q nchar(500),  Course_ID int)
			declare @TEMP_TF table (ID int, QTYPE nvarchar(20),ANS nchar(500),Q nchar(500),  Course_ID int)

		
			if(@N_MCQ< @MCQ_Q)
				begin 
					select 'MCQ questions is not enough'
					return
				end

			insert @TEMP_MCQ(ID, QTYPE,ANS, Q, Course_ID)
			select top(@MCQ_Q)*
			from Question
			where Course_ID = @Course_ID AND Question_Type='MCQ' 
			order by newid()

			if(@TF < @TF_Q)
				begin 
					select 'True/False questions is not enough'
					return
				end

			
			insert @TEMP_TF(ID, QTYPE,ANS, Q, Course_ID)
			select top(@TF_Q)*
			from Question
			where Course_ID = @Course_ID and Question_Type='True/false'
			order by newid()
		
			 --Union the 2 tables
			declare @ExamQuestions table (ID int, QTYPE nvarchar(20),ANS nchar(500),Q nchar(500),  Course_ID int)
			insert into @examQuestions (ID, QTYPE,ANS, Q, Course_ID)
			select * from @TEMP_MCQ
			union
			select * from @TEMP_TF

			declare @newExamID int = (select isnull(max(Exam_ID),0) from Exam)+1
			insert into Exam ([Exam_ID],[Exam_Title],[Exam_Duration],[Exam_Date],[Quest_Nums],[Exam_Grade],[Course_ID])
			Values (@newExamID,@Exam_Title ,@Exam_Duration , @Exam_Date, @Questions_Nums,@Exam_Grade ,@Course_ID)


		--Adding  exam to question @exam_id int,@quest_id into Exam_Quest
			declare question_cursor cursor 
			for select id
				from @examQuestions
			declare @q int
			open question_cursor
			fetch question_cursor into @q
			while @@FETCH_STATUS=0
				begin
					insert into Exam_Quest(exam_id,Question_ID)
					values(@newExamID,@q)
					fetch question_cursor into @q
				end
			close question_cursor
			deallocate question_cursor

			declare @stud_table table (st_id int)
			insert into @stud_table (st_id)
			select [St_ID] from [Stud_Course] where [Course_ID]=@Course_ID and [St_ID] =@ST_ID

			   
			declare cr cursor 
			for select st_id 
				from @stud_table
			declare @qq int
			open cr
			fetch cr into @qq
			while @@FETCH_STATUS=0
				begin
					insert into Student_Exam_Info([ST_ID],[Exam_ID],Exam_Time,Answered_Questions)
					values(@qq,@newExamID,CONVERT(TIME, CURRENT_TIMESTAMP),0)
					fetch cr into @qq
				end
			close cr
			deallocate cr

		 --OUTPUT the Exam Questions randomly	   
			select ID as [Question_ID],
				   QTYPE as [Question_type],
				   ANS as [Question_ModelAnswer],Q as [Question],
					Course_ID as [Course_ID]
					from @examQuestions order by NEWID()
	end try
	begin catch
		select 'Error in generating the exam'
	end catch
END


GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
alter PROC examCorrection @exam_id INT, @student_id INT
WITH ENCRYPTION
AS
	BEGIN TRY
		----Store the model answer for each question compared to the Student answer---
		DECLARE @correctAns TABLE (Qid int, ModelAns varchar(100), userAns varchar(100))
		INSERT @correctAns(Qid, ModelAns, userAns)
		SELECT Q.Question_ID, Question_ModelAnswer, Student_Answer
		FROM Student_Exam As SE, Question AS Q
		WHERE SE.Question_ID= Q.Question_ID AND ST_ID = @student_id AND Exam_ID = @exam_id

		
		------Set the grade for the correct answers-------
		UPDATE Student_Exam
		SET Question_Grade= 1
		WHERE Question_ID IN
		(
			SELECT Qid FROM @correctAns
			WHERE ModelAns = userAns
			AND ST_ID = @student_id AND Exam_ID = @exam_id
		) and ST_ID = @student_id AND Exam_ID = @exam_id 


		---------Set the null values by zero--------------
		UPDATE Student_Exam
		SET Question_Grade = 0 
		WHERE Question_ID not IN
			(SELECT Qid FROM @correctAns
			WHERE ModelAns = userAns
			AND ST_ID = @student_id AND Exam_ID = @exam_id
			)and ST_ID = @student_id AND Exam_ID = @exam_id


		---------Compute student final grade--------------
		DECLARE @StudentDegree FLOAT  = (SELECT SUM(Question_Grade) FROM Student_Exam
										  WHERE ST_ID  = @student_id AND Exam_ID = @exam_id )
		DECLARE @FinalDegree FLOAT = (SELECT COUNT(Question_ID) FROM Exam_Quest
								   	   WHERE Exam_ID = @exam_id
									   Group by Exam_ID )
		DECLARE @Student_percentage FLOAT = (@StudentDegree/@FinalDegree) * 100
		DECLARE @Student_percentage_table table ( x float)


		IF(@Student_percentage IS NULL)
		BEGIN
			SELECT 'Student Did not take this exam' as Caution
			RETURN
		END
		UPDATE Stud_Course
		SET St_Grade= @Student_percentage ,Exam_id =@exam_id
		WHERE ST_ID = @student_id AND Course_ID = (select Course_ID from Exam where exam_id= @exam_id)

		UPDATE Student_Exam_Info
		SET Answered_Questions = @StudentDegree
		WHERE ST_ID = @student_id AND Exam_ID= @exam_id

		/*insert into @Student_percentage_table SELECT @Student_percentage AS 'Student Degree in %'
		select * from @Student_percentage_table*/
		SELECT @Student_percentage AS 'Student Degree in %'
	END TRY

	BEGIN CATCH
		SELECT concat('Error in correcting Student exam',', Student Id: ',@student_id,' exam ID ',@exam_id)
	END CATCH

--------------------------------------

GO
SET ANSI_NULLS ON
GO

create or alter PROC Exam_Answer
			@student_Id INT,
			@exam_Id INT,
			@question_ID INT,
			@Student_Answer VARCHAR(max)
WITH ENCRYPTION
AS 
	INSERT INTO Student_Exam(st_id,Exam_ID,Question_ID,Student_Answer,Question_Grade)
	VALUES(@student_Id,@exam_Id,@question_ID,@Student_Answer,0)
	
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
----- get grade
Create or alter proc [Get_Grade] @ST_id int , @Exam_id int
as
	select St_Grade
	from Stud_Course
	WHERE St_id = @ST_id AND Exam_ID=@Exam_id
GO
---------
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
create or alter proc insert_Freelancing (@Freelanc_ID int,@Job_Name nvarchar(50),@Job_Website nvarchar(50),@Job_StartDate date
								,@Job_Tools varchar,@Feedback_Rating int,@st_id int)
WITH ENCRYPTION
as
	begin
		if  exists (select * from Freelancing where [Freelanc_ID]=@Freelanc_ID )
			 select 'duplicated id'
		else if not exists (select st_id from Student where st_id=@st_id) 
			 select 'student not exist'	
		else
		begin
		 insert into Freelancing([Freelanc_ID],[Job_Name],[Job_Website],[Job_StartDate],[Job_Tools],[Feedback_Rating],[ST_ID])
		 values (@Freelanc_ID ,@Job_Name ,@Job_Website ,@Job_StartDate 
								,@Job_Tools ,@Feedback_Rating ,@st_id )
		 Select 'Freelancing inserted successfully'
		end			
	end
GO

--test

--insert_Freelancing @Freelanc_ID=96 ,@Job_Name="SQL Joins" ,@Job_Website="Upwork" ,@Job_StartDate="2024-2-10" ,@Job_Tools="SQL server" , @Feedback_Rating=4 , @st_id=2

----
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
create or alter proc select_Freelancingforstudent (@st_id int )
WITH ENCRYPTION
	as
	begin
		if   not exists (select * from student where st_id=@st_id)
			 select 'invalid'
		
		else
		select * from Freelancing where st_id=@st_id
		 				
end
--test
--select_Freelancingforstudent 2
---------
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
create or alter proc update_Freelancing (@Freelanc_ID int,@Job_Name nvarchar(50),@Job_Website nvarchar(50),@Job_StartDate date
								,@Job_Tools varchar,@Feedback_Rating int,@st_id int)
 WITH ENCRYPTION
	as
	begin
		if   not exists (select * from Freelancing where [Freelanc_ID]=@Freelanc_ID )
			 select 'invalid'
		else if not exists (select st_id from Student where st_id=@st_id) 
			 select 'student not exist'	
		else
		begin
			 update Freelancing 
			 set  job_name=@Job_Name,Job_Website=@Job_Website,Job_StartDate=@Job_StartDate,Job_Tools=@Job_Tools,
			 Feedback_Rating=@Feedback_Rating, st_id=@st_id
			 where [Freelanc_ID]=@Freelanc_ID
			 Select 'Freelancing updated successfully'
		end		
end
--test

--update_Freelancing @Freelanc_ID=96 ,@Job_Name="SQL Joins" ,@Job_Website="Upwork" ,@Job_StartDate="2024-2-10" ,@Job_Tools=SSMS ,@Feedback_Rating=4 , @st_id=2
--
-----
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
create or alter proc delete_Freelancing (@Freelanc_ID int)
WITH ENCRYPTION
as
begin
		if  not exists (select * from Freelancing where [Freelanc_ID]=@Freelanc_ID )
			 select 'invalid'
		
		else
		begin
			delete from Freelancing  where Freelanc_ID=@Freelanc_ID
			Select 'Freelancing deleted successfully'
		end			
end
GO
--test
-- delete_Freelancing 96
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
create or alter proc select_all_freelancing 
WITH ENCRYPTION
as
	begin
			select * from Freelancing 
		 				
	end
GO

--select_all_freelancing
------------------------------------------
------------------------------------------
--Hiring
--GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
 create or alter proc insert_Hiring (@hiring_id int,@position nvarchar(100),@hiring_date date
                                 ,@company nvarchar(50),@job_location nvarchar(20),@Positon_type nvarchar(20),@st_id int)
 WITH ENCRYPTION
	as
	begin
		if  exists (select * from Hiring where [hiring_id]=@hiring_id )
			 select 'duplicated id'
		else if not exists (select st_id from Student where st_id=@st_id) 
			 select 'student not exist'	
		else
		begin
		 insert into Hiring([Hiring_ID],[Position] ,[Hiring_Date],[Company],[Location],[Positon_Type],st_id)
		 values (@hiring_id ,@position,@hiring_date,@company,@job_location,@Positon_type,@st_id)
		 Select 'Hiring inserted successfully'
		end		
end
GO
--test
--insert_Hiring @hiring_id=176,@position="Data Analyst" ,@hiring_date="2023-04-20" ,@company="Amazon" ,@job_location="Remote" ,@Positon_type="Part Time" ,@st_id =199
-----------------------------------------------

SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
create or alter proc select_Hiringforstudent (@st_id int)
WITH ENCRYPTION
as
	begin
			if   not exists (select * from Hiring where [st_id]=@st_id )
				 select 'invalid id'
		
			select * from   Hiring where  [st_id]=@st_id 
	end
GO
--test
-- select_Hiringforstudent 199

GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
 create or alter proc update_Hiring (@hiring_id int,@position nvarchar(100),@hiring_date date
                                 ,@company nvarchar(50),@job_location nvarchar(20),@Positon_type nvarchar(20),@st_id int)
 WITH ENCRYPTION
	as
	begin
		if   not exists (select * from Hiring where [hiring_id]=@hiring_id )
			 select 'invalid id'
		else if not exists (select st_id from Student where st_id=@st_id) 
			 select 'student not exist'	
		else
		begin
			update Hiring  set position=@position ,Positon_type=@Positon_type,company =@company ,
			hiring_date=@hiring_date ,Location=@job_location,st_id=@st_id
			  where   hiring_id=@hiring_id
			Select 'Hiring updated successfully'
		end
end
GO
-- test
-- update_Hiring @hiring_id=176,@position="Data Analyst" ,@hiring_date="2023-04-20" ,@company="Amazon" ,@job_location="Remote" ,@Positon_type="Full Time" ,@st_id =199

GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
create or alter proc delete_Hiring (@hiring_id int)
WITH ENCRYPTION
as
begin
		if   not exists (select * from Hiring where [hiring_id]=@hiring_id )
			 select 'duplicated id'
		else
		begin
			delete  Hiring where  [hiring_id]=@hiring_id
			Select 'Hiring deleted successfully'
		end
end
GO
-- test 
-- delete_Hiring 176

create or alter proc select_all_hiring 
WITH ENCRYPTION
as
	begin
			select * from Hiring 
	end
GO
--test

-- select_all_hiring

----------------------------
----------------------------
--Question

SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
create or alter procedure insert_question
(
	@quest_id int,@type varchar(20),@quest varchar(500),
	@modelanswer varchar(100),@cr_id int
)
with encryption 
as 
	begin 
			if exists (select Question_ID from Question where Question_ID=@quest_id)
			  select'Duplicate id'
		else
			if not exists (select Course_ID from Course where Course_ID=@cr_id )
			  select 'Invalid Id'
		else 
		begin
			insert into Question values (@quest_id ,@type ,@quest ,@modelanswer ,@cr_id )
			Select 'Question inserted successfully'
		end
	end 


--test
--insert_question @quest_id=97 ,@type='True/false' ,@quest='A head section is visible to a person viewing the Web page.' ,@modelanswer='b) FALSE' ,@cr_id =1
-------------------select--------------------------
go
create or alter procedure select_question (@quest_id int)
WITH ENCRYPTION
AS		
	BEGIN 
		if  exists (SELECT Question_ID FROM  Question where Question_ID =  @quest_id)
			SELECT * FROM  Question
			where Question_ID  =  @quest_id
		else
		 select 'Invalid id'
	END 

--test
--select_question 97
----------------------------------------------------update---------------------------------
go
create or alter procedure update_question
(
	@quest_id int,@type varchar(20),@quest varchar(500),@modelanswer varchar(100),@cr_id int
)
with encryption 
as 
	begin 
		if not exists (select Question_ID from Question where Question_ID=@quest_id)
		  select'Invalid Id'
	else
		if not exists (select Course_ID from Course where Course_ID=@cr_id )
		  select 'Invalid Id'
	else 
		begin
			update Question set Question_Type=@type ,Question=@quest ,Question_ModelAnswer=@modelanswer ,Course_ID=@cr_id 
			where Question_ID=@quest_id
			Select 'Question updated successfully'
		end
	end 
go

--test
--update_question @quest_id=97 ,@type='True/false' ,@quest='A head section is visible to a person viewing the Web page.' ,@modelanswer='b) FALSE' ,@cr_id =1
-----------------------------------------------------------delete-------------------------------------
create or alter procedure delete_question 
(@quest_id int)
with encryption 
as 
	begin
		if not exists (select Question_ID from Question WHERE Question_ID=@quest_id)
		   SELECT 'Invalid Id , Insert another one'
		else 
		if exists (select Question_ID from Choice where Question_ID=@quest_id)
		  select ' cannot Remove this question ,it  was related to another object'
		else 
		if exists (select Question_ID from Student_Exam where Question_ID=@quest_id)
		   select ' cannot Remove this question ,it  was related to Exams'
		else 
		begin
			delete  from Question where Question_ID=@quest_id
			Select 'Question deleted successfully'
		end
	end 
go
--test
--delete_question 97
---------------------------------------------------
go
create or alter procedure select_all_Questions
WITH ENCRYPTION
AS  
BEGIN  
     SELECT * FROM  Question
	 
END
go
--test
--select_all_Questions
---------------------------------------------------
create or alter procedure insert_Choice
(@choice_id int ,@choice varchar(100),@quest_id int)
 WITH ENCRYPTION
 as
	 begin 
		 if not exists(select Question_ID  from Question where Question_ID=@quest_id )
			  select'Question not exist'
		else if exists(select Choice_ID from Choice where Choice_ID = @choice_id)
		  select'Dublicated pk'
		else
		Begin
			 insert into Choice
			 (Choice_ID , Choice,Question_ID  )
			 values( @choice_id  , @choice ,@quest_id  )
			 Select 'Choice inserted successfully' 
		End
	end
go
--test
--insert_Choice @choice_id=700  , @choice='a) TRUE' ,@quest_id = 97
--insert_Choice @choice_id=701  , @choice='b) FALSE' ,@quest_id = 97

--------------select---------------------

create or alter procedure select_specific_choices 
       @choice_id int
   WITH ENCRYPTION
	as
	  begin
	  if exists(select Choice_ID from Choice where Choice_ID=@choice_id)
	   select * from Choice where Choice_ID=@choice_id
	  else
        select ('Not Found')
	  end
go
--test
--select_specific_choices @choice_id= 701
------------------------------------------------------update----------------
create or alter procedure update_Choice
 (@choice_id int ,@choice varchar(100),@quest_id int)
 WITH ENCRYPTION
 as
 begin
	 if not exists(select Question_ID from	Question where Question_ID=@quest_id )
		  select'Question not exist'
	 else if not exists(select Choice_ID from Choice where Choice_ID = @choice_id)
		  select'Invalid ID'
	else
	begin
	  update Choice
	  set Choice_ID=@choice_id,
	  choice= @choice,Question_ID=@quest_id
	  where Choice_ID=@choice_id
	  Select 'Choice updated successfully'
	end
end
go

--test
--update_Choice @choice_id=700  , @choice='a) TRUE' ,@quest_id = 97
--update_Choice @choice_id=701  , @choice='b) FALSE' ,@quest_id = 97

-------------------------------------------------------------------------------delete
create or alter procedure delete_Choice
@choise_id  int
WITH ENCRYPTION
as
	begin
		if exists(select Choice_ID from Choice where Choice_ID=@choise_id)
		begin 
		  delete from choice where Choice_ID=@choise_id
		  Select 'Choice deleted successfully'
		end
		else
		  select ('Not Found')
	end

--test
--delete_Choice @choise_id=700  
--delete_Choice @choise_id=701  

----------------------------------------------

go
create or alter procedure select_all_choice
   WITH ENCRYPTION
	as
	  begin
	  select * from choice
	  end
go
--test
--select_all_choice
----------------------
--Instructor
------------insert into instructor --------------
SET ANSI_NULLS ON
GO
 create or alter PROCEDURE insert_Instructor
				@ins_id INT,
				@ins_fname nvarchar(50),
				@ins_lname nvarchar(50),
				@ins_birthdate date,
				@ins_gender nvarchar(10),
				@ins_salary float,
				@ins_city nvarchar(50),
				@ins_Hire_Date date,
				@ins_Dept_ID INT
			
WITH ENCRYPTION
AS  
BEGIN 
IF NOT EXISTS(SELECT Instructor_ID FROM  Instructor WHERE Instructor_ID = @ins_id)
	Begin
	INSERT INTO Instructor(Instructor_ID,Instructor_Fname,Instructor_Lname,Instructor_BirthDate,Instuctor_Age,Instructor_Gender,Salary,City,Hire_Date,Dept_ID)
	VALUES(@ins_id,@ins_fname,@ins_lname,@ins_birthdate,DATEDIFF(YEAR,@ins_birthdate, GETDATE()),@ins_gender,@ins_salary,@ins_city ,@ins_Hire_Date,@ins_Dept_ID)
	Select 'Instructor inserted successfully'
	End
	ELSE
    SELECT'Duplicate ID' as Error
	
END
go

--test
--insert_Instructor @ins_id= 16,@ins_fname='abdo' ,@ins_lname='nagy',@ins_birthdate='1997-01-02' ,@ins_gender='m' ,@ins_salary= 3000 ,@ins_city='alex' ,@ins_Hire_Date='2021-01-01', @ins_Dept_ID=10

----
create or alter procedure select_instructor (@inst_id int)
WITH ENCRYPTION
AS		
	BEGIN 
		if  exists (SELECT Instructor_ID FROM  Instructor where Instructor_ID =  @inst_id)
			SELECT * FROM  Instructor
			where Instructor_ID  =  @inst_id
		else
		 select 'Invalid id'
	END 
go

--test
--select_instructor 16

-------------------------------------------Update instructor------------------------
SET ANSI_NULLS ON
GO
create or alter procedure update_Instructor
				@ins_id INT,
				@ins_fname nvarchar(50),
				@ins_lname nvarchar(50),
				@ins_birthdate date,
				@ins_gender nvarchar(10),
				@ins_salary float,
				@ins_city nvarchar(50),
				@ins_Hire_Date date,
				@ins_Dept_ID INT
				
WITH ENCRYPTION
AS  
   BEGIN 
      IF  EXISTS(SELECT Instructor_ID FROM  dbo.Instructor WHERE Instructor_ID=@ins_id)
	  BEGIN
		  UPDATE dbo.Instructor
		  SET
					Instructor_ID= @ins_id,
					Instructor_Fname=@ins_fname ,
					Instructor_Lname=@ins_lname,
					Instructor_BirthDate=@ins_birthdate ,
					Instuctor_Age= DATEDIFF(YEAR,@ins_birthdate, GETDATE()),
					Instructor_Gender =@ins_gender ,
					Salary=@ins_salary ,
					City=@ins_city,
					Hire_Date = @ins_Hire_Date,
					Dept_ID = @ins_Dept_ID
		   WHERE  Instructor_ID = @ins_id 
		   Select 'Instructor updated successfully'
		END
	else
	select 'invalid id' as Error
   END
go
-----testing
--update_Instructor @ins_id= 16,@ins_fname='Abdo' ,@ins_lname='Nagy',@ins_birthdate='1997-01-02' ,@ins_gender='m' ,@ins_salary= 5000 ,@ins_city='Alex' ,@ins_Hire_Date='2021-01-01', @ins_Dept_ID=10

-------------------------------------------Delete instructor------------------------
SET ANSI_NULLS ON
GO
create or alter PROCEDURE delete_Instructor @ins_id  INT
WITH ENCRYPTION
AS  
   BEGIN  
	 if exists(select Instructor_ID from Inst_Course where Instructor_ID=@ins_id )
	 select 'cannot delete an instructor related to a course' as Error
	 else if not EXISTS(SELECT Instructor_ID  FROM  Instructor WHERE Instructor_ID =@ins_id )
        select 'invalid id' as Error
	 else
	 BEGIN
	   delete from Instructor where Instructor_ID =@ins_id 
	   Select 'Instructor deleted successfully'
	 END
   END
GO
---testing--
--delete_Instructor @ins_id=16
-------------------------------------------select instructor------------------------
SET ANSI_NULLS ON
GO
create or alter PROCEDURE select_Instructors
WITH ENCRYPTION
AS  
   BEGIN 
  select * from Instructor
   END
GO
-----testing 
--select_Instructors

---------------------------------------------
-- Department
------------insert into Department --------------
SET ANSI_NULLS ON
GO
 create or alter PROCEDURE insert_Department
				@Dept_ID INT,
				@Dept_Name nvarchar(30),
				@Dept_Location nvarchar(20),
				@Dept_Description nvarchar(50),
				@Manager_ID INT
			
WITH ENCRYPTION
AS  
   BEGIN 
   IF NOT EXISTS(SELECT Dept_ID FROM  Deptartment WHERE Dept_ID = @Dept_ID)
	   BEGIN
		 INSERT INTO Deptartment(Dept_ID,Dept_Name,Dept_Location,Dept_Description,Manager_ID)
		 VALUES(@Dept_ID,@Dept_Name,@Dept_Location,@Dept_Description,@Manager_ID)
		 Select 'Department inserted successfully'
	   END
   ELSE
     SELECT'Duplicate ID' as Error
   END
--testing
--insert_Department @Dept_ID=80,@Dept_Name='a',@Dept_Location='alex',@Dept_Description='aaa',@Manager_ID=1  --duplicated error work correctly
go
--------------------------------------

create or alter procedure select_department (@Dept_ID int)
WITH ENCRYPTION
AS		
	BEGIN 
		if  exists (SELECT Dept_ID FROM  Deptartment where Dept_ID =  @Dept_ID)
			SELECT * FROM  Deptartment
			where Dept_ID =  @Dept_ID
		else
		 select 'Invalid id'
	END 

--test 
-- select_department @Dept_ID=80
Go
-------------------------------------------Update deparment------------------------
SET ANSI_NULLS ON
GO
create or alter procedure update_Department
				@Dept_ID INT,
				@Dept_Name nvarchar(30),
				@Dept_Location nvarchar(20),
				@Dept_Description nvarchar(50),
				@Manager_ID INT
				
WITH ENCRYPTION
AS  
   BEGIN 
      IF  EXISTS(SELECT Dept_ID FROM  Deptartment WHERE Dept_ID = @Dept_ID)
	  BEGIN
		  UPDATE Deptartment
		  SET
				Dept_ID = @Dept_ID,
				Dept_Name = @Dept_Name,
				Dept_Location = @Dept_Location,
				Dept_Description = @Dept_Description,
				Manager_ID = @Manager_ID 
					
		   WHERE  Dept_ID = @Dept_ID
		   Select 'Department updated successfully'
		END
	else
	select 'invalid id' as Error
   END
go
--testing
-- update_Department @Dept_ID=80,@Dept_Name='UI',@Dept_Location='Aswan',@Dept_Description='aaa',@Manager_ID=1   
-------------------------------------------Delete Deptartment------------------------
SET ANSI_NULLS ON
GO
create or alter PROCEDURE delete_Deptartment @Dept_ID  INT
WITH ENCRYPTION
AS  
   BEGIN  
	 if exists(select Dept_ID from Instructor where Dept_ID= @Dept_ID )
	 select 'cannot delete Department related to a instructors' as Error
	 else if not EXISTS(SELECT Dept_ID  FROM  Deptartment WHERE Dept_ID =@Dept_ID )
        select 'invalid id' as Error
	 else
	 begin
	   delete from Deptartment where Dept_ID =@Dept_ID 
	   Select 'Department deleted successfully'
	 end
   END
GO
---testing--
--delete_Deptartment @Dept_ID= 80
-------------------------------------------select Deptartment------------------------
SET ANSI_NULLS ON
GO
create or alter PROCEDURE select_Deptartments
WITH ENCRYPTION
AS  
   BEGIN 
  select * from Deptartment
   END
GO
-----testing 
--select_Deptartments

-----------------------------
--Stud_Course
------------insert into Stud_Course --------------
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
create or alter proc  insert_Stud_Course(@c_id int ,@st_id int,@St_Grade nchar(10))
  WITH ENCRYPTION
  as
  begin 
		if not exists (select * from Student where [ST_ID]=@st_id) and not exists (select * from Course where [Course_ID]=@c_id)
			   select 'student and Course not Exist' as Error
	   else if not exists (select * from Course where [Course_ID]=@c_id)
			   select 'Course not Exist' as Error			  
	   else if not exists (select * from Student where [ST_ID]=@st_id)
			   select 'student not Exist' as Error
	   else if exists (select * from Stud_Course where [Course_ID]=@c_id and [St_ID]=@st_id) 
			   select 'dublicated id' as Error
	   else		
	   begin
				  insert into [dbo].[Stud_Course] (St_ID,Course_ID,St_Grade)
				  values (@st_id,@c_id ,@St_Grade)
				  Select 'Student-Course inserted successfully'
	  end
  end
-------testing
--insert_Stud_Course @st_id=1,@c_id=3,@St_Grade=null

go
----------------------------------- select Stud_Course-----------------------------------------
SET ANSI_NULLS ON
GO
create or alter procedure  select_Stud_course @st_id int,@c_id int
as
begin
    if  exists (select * from Stud_Course where [Course_ID]=@c_id and [ST_ID]=@st_id)
	      select * from Stud_Course where [Course_ID]=@c_id and [ST_ID]=@st_id
	else  
         select 'invalid id'  as Error
					
 end
GO
--testing-----
--select_Stud_course @st_id=1,@c_id=3
----------------------------------- update Stud_Course-----------------------------------------
SET ANSI_NULLS ON
GO
create or alter procedure  update_Stud_Course (@c_id int ,@st_id int,@St_Grade nchar(10)) 
WITH ENCRYPTION
As
begin
   if  not exists (select * from Course where [Course_ID]=@c_id) AND NOT EXISTS (select * from Student where [ST_ID]=@st_id)
	      select 'student and Course not Exist'	 as Error 
   else if not exists (select * from Course where [Course_ID]=@c_id)
	      select 'course not Exist'	 
							  
	else if not exists (select * from Student where [ST_ID]=@st_id)
			    select 'student not Exist' as Error
	else if not  exists (select * from Stud_Course where [Course_ID]=@c_id and [ST_ID]=@st_id) 
                 select 'invalid id' as Error
	else
	begin
			update Stud_Course 
			set St_Grade = @St_Grade
			where [Course_ID]=@c_id and  [ST_ID]=@st_id
			Select 'Student-Course updated successfully'

	end
 end
GO
-------testing
--update_Stud_Course @st_id=1,@c_id=3,@St_Grade=null

----------------------------------- delete Stud_Course-----------------------------------------
SET ANSI_NULLS ON
GO
create or alter procedure  delete_Stud_Course  @st_id int,@c_id int
WITH ENCRYPTION
As
begin
   if  exists (select * from Stud_Course where [Course_ID]=@c_id and [ST_ID]=@st_id)
   begin
         delete from Stud_Course where [Course_ID]=@c_id and [ST_ID]=@st_id	 
		 Select 'Student-Course deleted successfully'
	end
   else  
         select 'invalid id' as Error				
 end
GO

--testing-----
--delete_Stud_Course @st_id=1,@c_id=3
----------

go
create or alter procedure select_all_Stud_Course
WITH ENCRYPTION
AS  
	BEGIN  
		 SELECT * FROM  Stud_Course
	END

--test
-- select_all_Stud_Course

--
---------------------------------------------------------------
--Students
--
go
create or alter procedure Insert_Student
(
@St_ID int,@St_SSN int,@St_BirthDate date,@St_City varchar(50),@St_Fname varchar(50),
@St_Lname varchar(50),@St_Gender varchar(30),@Track_ID int,@Intake_ID int
)
with encryption 
as 
begin 
	if exists ( select St_ID from student where St_ID=@St_ID )
		select 'Duplicated ID , Insert another one'
	else if not exists (select Intake_ID  from Intake where Intake_ID= @Intake_ID) and not exists (select Track_ID from track where Track_ID = @Track_ID)
		select 'Invalid Intake Id and Track Id'
	else if not exists (select Intake_ID  from Intake where Intake_ID= @Intake_ID)
		 select 'Invalid Intake Id'
	else iF not exists (select Track_ID from track where Track_ID = @Track_ID)
		  select 'Invalid Track Id'
	ELSE 
	begin 
		INSERT INTO Student VALUES (@St_ID ,@St_SSN ,@St_Fname ,@St_Lname ,@St_BirthDate ,DATEDIFF(YEAR,@St_BirthDate,GETDATE()),@St_City,@St_Gender,@Intake_ID, @Track_ID)
		SELECT 'Student inserted successfully'
	end
end

--test
/*
EXEC Insert_Student 
    @St_ID = 200,
    @St_SSN = 123587789,
    @St_BirthDate = '1990-01-01',
    @St_City = 'Cairo',
    @St_Fname = 'John',
    @St_Lname = 'Doe',
    @St_Gender = 'Male',
    @Track_ID = 4,
    @Intake_ID = 40*/



------------------------------------------------------------------------------------------
go
create or alter procedure Select_Student (@St_ID int)
with encryption 
as 
	begin 
		if not exists (select St_ID from Student where St_ID =@St_ID)
		   select ' Invalid Id '
		else 
		select * from Student where St_ID=@St_ID
	end
go
--test
--Select_Student 200

--------------------------------
go
create or alter Procedure Update_Student
(@St_ID int,@St_SSN int,@St_BirthDate date,@St_City varchar(50),@St_Fname varchar(50),
@St_Lname varchar(50),@St_Gender varchar(10),@Track_ID int,@Intake_ID int)
with encryption 
as 
begin 
	if not exists ( select St_ID from Student where St_ID=@St_ID )
		select 'Invalid id'
	 
	else if not exists (select Track_Id  from Track where Track_ID = @Track_ID) and not exists (select Intake_ID from Intake where Intake_ID = @Intake_ID)
		select 'Invalid Intake Id and Track Id'
	else if not exists (select Intake_ID  from Intake where Intake_ID= @Intake_ID)
		 select 'Invalid Intake Id'
	else if not exists (select track_id from track where Track_ID = @Track_ID)
		  select 'Invalid Track Id'
	else 
	begin
		update Student set St_SSN=@st_ssn, ST_BirthDate=@st_birthdate, ST_City=@st_city, ST_Fname=@st_fname,
		ST_Lname=@st_lname, ST_Gender= @st_gender,
		Intake_ID =@Intake_ID , Track_ID = @Track_ID,
		ST_Age = DATEDIFF(YEAR,@st_birthdate,GETDATE())
		where St_ID =@st_id
		Select 'Student updated successfully'
	end
end

/**/
EXEC Update_Student 
    @St_ID = 200,
    @St_SSN = 123456789,
    @St_BirthDate = '1990-01-01',
    @St_City = 'Cairo',
    @St_Fname = 'John',
    @St_Lname = 'Doe',
    @St_Gender = 'Male',
    @Track_ID = 2,
    @Intake_ID = 40
go
----------------------------------------------------------------------------------------------
create or alter procedure Delete_Student
(@ST_ID int)
with encryption 
as 
begin 
		if not exists (select ST_ID from Student where ST_ID=@ST_ID)
			select 'Invalid Id insert another one'
		else
		if exists (select  ST_ID from Stud_Course where ST_ID=@ST_ID)
		   select 'cannot remove this student , he enrolled courses'
		else
		if exists (select ST_ID from Student_Exam where ST_ID=@ST_ID)
		 select 'cannot remove this student , he is already doing exams'
		else
		if exists (select ST_ID from Freelancing where ST_ID=@ST_ID)
			select 'cannot remove this student ,he has done freelance job'
		else
		if exists (select ST_ID from Hiring where ST_ID=@ST_ID)
			select 'cannot remove this student ,he has been hired a position' 
		else 
		begin
			delete from Student where ST_ID = @ST_ID
			Select 'Student deleted successfully'
		end
end
--test
--Delete_Student @ST_ID=200

----------------------------
go
create or alter procedure Select_All_Students
 WITH ENCRYPTION
AS  
   BEGIN  
      SELECT * FROM  Student
	 
   END
go
--test
--Select_All_Students

----------------------------------------------------------------------------------------
--Intake
--

go
create or alter PROCEDURE dbo.insert_intake
      @Intake_ID int,@Intake_StartDate date,@Intake_EndDate date,
	  @Intake_Duration Int,@Branch_Name Varchar(25)
WITH ENCRYPTION
AS  
   BEGIN 
   IF NOT EXISTS(SELECT Intake_ID from Intake WHERE Intake_ID =@Intake_ID)
   BEGIN
     INSERT INTO dbo.Intake
     (Intake_ID,Intake_StartDate ,Intake_EndDate,Intake_Duration,Branch_Name)
     VALUES
     (@Intake_ID,@Intake_StartDate,@Intake_EndDate,@Intake_Duration,@Branch_Name)
	 SELECT 'Intake inserted successfully'
   END
   ELSE
     SELECT 'Duplicate ID'
   END
go  
--test
--insert_intake @Intake_ID= 39,@Intake_StartDate='2018-03-01' ,@Intake_EndDate='2019-03-01',@Intake_Duration=4 ,@Branch_Name= Fayoum

--------------------------------------------------
create or alter PROCEDURE dbo.Select_Intake ( @Intake_ID int )
  WITH ENCRYPTION
	AS  
	   BEGIN  
		 IF Not EXISTS(SELECT Intake_ID FROM dbo.Intake WHERE  Intake_ID=@Intake_ID)
			select 'Invalid ID'
		 else
			 SELECT * FROM dbo.Intake WHERE  Intake_ID=@Intake_ID
	   END
go
--test
--Select_Intake 39
------------------------------------------------------------------
create or alter PROCEDURE dbo.update_intake 
      @Intake_ID int,@Intake_StartDate date,@Intake_EndDate date,
	  @Intake_Duration Int,@Branch_Name Varchar(25)
WITH ENCRYPTION
AS  
   BEGIN  
	  IF EXISTS(SELECT Intake_ID FROM dbo.Intake WHERE Intake_ID=@Intake_ID)
	   Begin
		  UPDATE dbo.Intake
		  SET
			 Intake_StartDate=@Intake_StartDate,
			 Intake_EndDate=@Intake_EndDate,
			 Intake_Duration=@Intake_Duration,
			 Branch_Name=@Branch_Name
		   WHERE Intake_ID=@Intake_ID
		  Select 'Intake updated successfully'
		End
	else
	select 'Invalid ID'
   END
 go
 --test
 -- update_intake @Intake_ID= 39,@Intake_StartDate='2018-03-01' ,@Intake_EndDate='2019-03-01',@Intake_Duration=4 ,@Branch_Name= Mansoura
----------------------------------------------------
create or alter PROCEDURE dbo.Delete_Intake
         @Intake_ID INT
 WITH ENCRYPTION  
AS  
   BEGIN 
	  if exists(select Intake_ID from Student where Intake_ID = @Intake_ID )
		 select 'cannot delete this intake,relate to another student'
	  else if
		 not EXISTS(SELECT Intake_ID FROM  dbo.Intake WHERE Intake_ID =@Intake_ID )
		 select'Invalid ID'
	  else
	  begin
		 delete from Intake where Intake_ID=@Intake_ID
		 Select 'Intake deleted successfully'
	  end
	END
go
--test
--Delete_Intake 39
--------------------------------------------------
create or alter PROCEDURE dbo.Select_All_Intakes		
WITH ENCRYPTION
AS  
   BEGIN  
     
      SELECT * FROM dbo.Intake
	 
   END
go 
--test
--Select_All_Intakes	
---------------------------------------------------

----------*******************************************---------------*******************************************---------------*******************************************-----

SET ANSI_NULLS, QUOTED_IDENTIFIER ON
go
create or alter proc insert_topic (@tpc_id int, @tpc_name varchar(50))
with encryption 
as	
	if not exists(select Topic_ID from Topic where Topic_ID = @tpc_id )
		begin
		insert into topic(Topic_ID,Topic_Name) 
		values(@tpc_id,@tpc_name)
		SELECT 'Topic inserted successfully' as message
		end
	else
		select 'this topic is exist'

go
---------testing-----------
--insert_topic 100,'prog'
--************************************************--
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
go
create or alter proc select_topic (@topic_id int)
with encryption 
as	
	if exists(select Topic_ID from Topic where Topic_ID = @topic_id )
		select * from topic
		where Topic_ID =  @topic_id
	else
		select 'This topic id is not exist'
go
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
go
---------testing-----------
--select_topic 100
--************************************************--

GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
create or alter proc update_topic  (@topic_id  int ,@topic_name nvarchar(50))
With encryption
As 
	if  not exists (select topic_id from Topic where  topic_id=@topic_id )
		select 'this topic id is not exist ' as message
	else 
		begin
		update  Topic  set  topic_name = @topic_name
		where topic_id=@topic_id 
		Select 'Topic updated successfully' as message
		end
GO
---------testing-----------
--update_topic 100,p
--************************************************--
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
create or alter proc delete_topic(@topic_id  int)
With encryption
As 
begin

	if  exists (select topic_id from Topic where  topic_id=@topic_id )
		begin
	       delete Topic where topic_id =@topic_id
		   Select 'Topic deleted successfully' as message
		end
	else 
	       select 'This Topic ID is not exist'
end
GO
---------testing-----------
--delete_topic 100
--************************************************--
go
create or alter procedure select_all_topics
WITH ENCRYPTION
AS  
BEGIN  
     SELECT * FROM  Topic
	 
END
---------testing-----------
--select_all_topics
--************************************************--
go
create or alter proc insert_track 
(@track_id int, @track_name varchar(50) ,@track_title varchar(50),@supervisor_id int )
with encryption 
as	
	if exists(select track_ID from Track where Track_ID = @track_id )
		select 'Duplicte ID'
	else if not exists(select Instructor_ID from Instructor where Instructor_ID = @supervisor_id )
		select 'Invalid Supervisor ID'
	else
		begin
		SET IDENTITY_INSERT track ON
		insert into Track(track_ID,track_Name,track_titles,supervisor_id) 
		values(@track_id, @track_name ,@track_title,@supervisor_id)
		SELECT 'Track inserted successfully' as message
		SET IDENTITY_INSERT track OFF

		end
go
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
go
---------testing-----------
--insert_track 100,'a','b',11
--************************************************--
create or alter proc select_track ( @track_id int)
with encryption 
as	
	if exists(select track_ID from Track where Track_ID = @track_id )
		select * from  Track  where  Track_ID =  @track_id
	else
		select 'The Track ID is not exist'
go
---------testing-----------
--select_track 100
--************************************************--

SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
create or alter procedure update_track
(@track_id int, @track_name varchar(50) ,@track_title varchar(50),@supervisor_id int )
with encryption 
as 
	if not exists (select track_id from Track where track_id=@track_id)
       select 'invalid id ,input another one'
	else
		begin
		update Track set 
		track_name=@track_name,
		supervisor_id=@supervisor_id,Track_Titles =@track_title
		where track_id=@track_id
		Select 'Track updated successfully' as message
		end
go
---------testing-----------
--update_track 100,'za','aaa',11
--************************************************--
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
create or alter procedure delete_track (@track_id  int)
with encryption 
as 
	if not exists (select track_id from track where track_id=@track_id)
		select 'This track_id ID is not exist'
	else if exists(select track_id from Track_Course where track_id=@track_id)
		select 'Cannot delete this track it  has a relation'
	else if exists (select track_id from Student where track_id=@track_id)
		select 'Cannot delete this track it  has a relation'
	else 
		 begin
		 delete track where track_id=@track_id
		 Select 'Intake deleted successfully'
	  end
GO
---------testing-----------
--delete_track 100
--*********************************************
go
create or alter procedure select_all_tracks
WITH ENCRYPTION
AS  
	BEGIN  
		 SELECT * FROM  Track
	 
	END

go
---------testing-----------
--select_all_tracks
--************************************************--

SET ANSI_NULLS, QUOTED_IDENTIFIER ON
go
create or alter proc insert_course 
(@course_id int, @course_name varchar(50) ,@Course_Duration int ,@Course_Level varchar(50) )
with encryption 
as	
	if exists(select course_id from Course where course_id = @course_id )
		select 'Duplicte ID'
	else
		begin
		insert into Course(course_id , course_name ,Course_Duration,Course_Level) 
		values(@course_id , @course_name ,@Course_Duration,@Course_Level)
		SELECT 'Course inserted successfully' as message
		end
go
---------testing-----------
--insert_course 100,'a',20,'beginner'
--************************************************--
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
go
create or alter proc select_course (@course_id int)
with encryption 
as	
	if exists(select course_id from Course where course_id = @course_id )
		select * from  Course  where  course_id = @course_id
	else
		select 'The Course ID is not exist'
go
---------testing-----------
--select_course 100
----------*******************************************-----

SET ANSI_NULLS, QUOTED_IDENTIFIER ON
go
create or alter proc update_course (@course_id int, @course_name varchar(50) ,@Course_Duration int ,@Course_Level varchar(50) )
with encryption 
as	
	if not exists(select course_id from Course where course_id = @course_id )
		select 'The Course ID is not exist'
	else if exists(select course_id from Track_Course where course_id = @course_id )
			select 'Cannot delete this Course it  has a relation'
	else if exists(select course_id from Stud_Course where course_id = @course_id )
			select 'Cannot delete this Course it  has a relation'
	else if exists(select course_id from Inst_Course where course_id = @course_id )
			select 'Cannot delete this Course it  has a relation'
	else if exists(select course_id from Course_Topic where course_id = @course_id )
		    select 'Cannot delete this Course it  has a relation'
	else if exists(select course_id from Question where course_id = @course_id )
		    select 'Cannot delete this Course it  has a relation'
	else if exists(select course_id from Exam where course_id = @course_id )
		    select 'Cannot delete this Course it  has a relation'
	else
		
		begin
		 Update Course  
		set  course_name = @course_name ,Course_Duration =@Course_Duration 
		,Course_Level =@Course_Level
		where  course_id = @course_id
		 Select 'Course updated successfully'
	  end
go
---------testing-----------
--update_course 100 ,'a',21,'mid'
--************************************************--

SET ANSI_NULLS, QUOTED_IDENTIFIER ON
go
create or alter proc delete_course (@course_id int)
with encryption 
as	
	if not exists(select course_id from Course where course_id = @course_id )
		select 'The Course ID is not exist'
	else if exists(select course_id from Track_Course where course_id = @course_id )
			select 'Cannot delete this Course it  has a relation'
	else if exists(select course_id from Stud_Course where course_id = @course_id )
			select 'Cannot delete this Course it  has a relation'
	else if exists(select course_id from Inst_Course where course_id = @course_id )
			select 'Cannot delete this Course it  has a relation'
	else if exists(select course_id from Course_Topic where course_id = @course_id )
		    select 'Cannot delete this Course it  has a relation'
	else if exists(select course_id from Question where course_id = @course_id )
		    select 'Cannot delete this Course it  has a relation'
	else if exists(select course_id from Exam where course_id = @course_id )
		    select 'Cannot delete this Course it  has a relation'
	else
		
		begin
		 delete Course  where  course_id = @course_id
		 Select 'Course deleted successfully'
	  end
---------testing-----------
--delete_course 100
--************************************************--
go
create or alter procedure select_all_courses
WITH ENCRYPTION
AS  
	BEGIN  
		 SELECT * FROM  Course
	 
	END

go
---------testing-----------
--select_all_courses
--************************************************--


SET ANSI_NULLS, QUOTED_IDENTIFIER ON
go
create or alter proc insert_Course_Topic
(@course_id int,@topic_id int)
with encryption 
as	
	if not exists(select course_id from Course where course_id = @course_id )
		select 'Invalid Course ID'
	else if not exists(select Topic_ID from Topic where Topic_ID = @topic_id)
		select 'Invalid Topic ID'
	else
		
		begin
		 insert into Course_Topic(course_id ,topic_id) 
		 values(@course_id ,@topic_id)
		 SELECT 'Course_Topic inserted successfully'
	  end

go
---------testing-----------
--insert_Course_Topic 100,200
--************************************************--
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
go
create or alter proc select_course_topic (@course_id int, @topic_id int)
with encryption 
as	
	if not exists(select course_id from Course where course_id = @course_id ) 
	and not exists(select Topic_ID from Topic where Topic_ID = @topic_id )
		select 'Invalid Course ID and Topic ID'
	else if not exists(select course_id from Course where course_id = @course_id )
		select 'The Course ID is not exist'
	else if not exists(select Topic_ID from Topic where Topic_ID = @topic_id )
		select 'The Topic ID is not exist'
	else
		select * from  Course_Topic  
		where  course_id = @course_id and Topic_id = @topic_id
		
go
---------testing-----------
--select_course_topic 100,200
----------*******************************************-----
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
create or alter procedure  update_Course_Topic  @course_id int,@topic_id int
as
begin
   if not exists(select course_id from Course where course_id = @course_id ) 
	and not exists(select Topic_ID from Topic where Topic_ID = @topic_id )
		select 'Invalid Course ID and Topic ID'
	else if not exists(select course_id from Course where course_id = @course_id )
		 select 'The Course ID is not exist'
	else if not exists(select Topic_ID from Topic where Topic_ID = @topic_id )
		 select 'The Topic ID is not exist'
   else if not exists (select * from Course_Topic where course_id=@course_id and topic_id=@topic_id) 
         select 'The Course ID and Topic ID do not exists'
   else
		begin
		 update Course_Topic 
		set course_id= @course_id,topic_id=@topic_id
		 Select 'Course_Topic updated successfully'
	  end
 end

GO
---------testing-----------
--update_Course_Topic 100,200
----------*******************************************-----

SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
create or alter procedure  delete_Course_Topic(@course_id int,@topic_id int)
as
  if exists (select * from Course_Topic where course_id=@course_id and topic_id= @topic_id) 
	   begin
		 delete from Course_Topic 
		 where course_id = @course_id and topic_id = @topic_id
		 Select 'Course_Topic deleted successfully'
	  end
  else 
       select 'Invalid Course ID and Topic ID'

GO
---------testing-----------
--update_Course_Topic 100,200
--************************************************--
go
create or alter procedure select_all_course_topic
WITH ENCRYPTION
AS  
	BEGIN  
		 SELECT * FROM  Course_Topic
	 
	END

go

---------testing-----------
--select_all_course_topic
--************************************************--

create or alter procedure insert_certificate 
(@Certification_ID int, @Certification_Name varchar(100), @Certificate_Hour int , @Certificate_Website varchar(50), @Certificate_URL varchar(120),@Certificate_Date date )
WITH ENCRYPTION
AS  
	BEGIN  try 
		begin 
		if exists (SELECT Certification_ID FROM  Certificates where Certification_ID =  @Certification_ID)
			select 'Duplicate id'
		 else 
		  begin
		 insert into Certificates (Certification_ID , Certification_Name, Certificate_Hour , Certificate_Website, Certificate_URL ,Certificate_Date )
		  values (@Certification_ID , @Certification_Name, @Certificate_Hour , @Certificate_Website, @Certificate_URL ,@Certificate_Date )
		 SELECT 'Certificate inserted successfully'
		  end
		end
	END try
	begin catch
		select @@ERROR
	end catch

go
---------testing-----------
--insert_certificate 100,'a',20,'www.datacamp.com','https://www.datacamp.com/completed/statement-of-accomplishment/track/83749f8137f9a72118028f1514c4035c70736973','2024-01-05'

--************************************************--
create or alter procedure update_certificate 
(@Certification_ID int, @Certification_Name varchar(100), @Certificate_Hour int , @Certificate_Website varchar(50), @Certificate_URL varchar(120),@Certificate_Date date )
WITH ENCRYPTION
AS  
	BEGIN  
		if not  exists (SELECT Certification_ID FROM  Certificates where Certification_ID =  @Certification_ID)
			select 'Invalid id'
		else 
			begin
		    update Certificates
			set Certification_Name= @Certification_Name, Certificate_Hour=@Certificate_Hour  , Certificate_Website=@Certificate_Website ,
			Certificate_URL= @Certificate_URL ,Certificate_Date= @Certificate_Date
			where Certification_ID=@Certification_ID
		 Select 'Certificate updated successfully'
	  end
		 
	END


go
--************************************************--

---------testing-----------
-- update_certificate insert_certificate 100,'b',20,'www.datacamp.com','https://www.datacamp.com/completed/statement-of-accomplishment/track/83749f8137f9a72118028f1514c4035c70736973','2024-02-05'
--************************************************--
create or alter procedure select_certificate (@cert_id int)
WITH ENCRYPTION
AS		
	BEGIN 
		if  exists (SELECT Certification_ID FROM  Certificates where Certification_ID =  @cert_id)
			SELECT * FROM  Certificates
			where Certification_ID  =  @cert_id
		else
		 select 'Invalid id'
	END 

go
--************************************************--
---------testing-----------
--select_certificate 100
create or alter procedure delete_certificate (@Certification_ID int)
WITH ENCRYPTION
AS  
	BEGIN  
		if not exists (SELECT Certification_ID FROM  Certificates where Certification_ID =  @Certification_ID)
			select 'Invalid id'
		else

			begin
			delete from Certificates 
			where Certification_ID =  @Certification_ID		 
		    Select 'Certificate deleted successfully'
			end
	END

go

---------testing-----------
--delete_certificate 100

--************************************************--
go
create or alter procedure select_all_certificates
WITH ENCRYPTION
AS  
	BEGIN  
		 SELECT * FROM  Certificates
	 
	END

go
---------testing-----------
--select_all_certificates
--************************************************--
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
create or alter proc inserting_Registeration_Student
 @st_id int,@register_id int
 WITH ENCRYPTION
 as
 begin
 if not exists(select * from Student where st_id= @st_id)and not exists(select * from Registeration where register_id=@register_id )
            select'student and Registeration not exist'
else if not exists(select * from Student where st_id=@st_id)
       select'Student is not existed'
else if not exists(select * from Registeration where register_id=@register_id)
       select'Registeration is not existed'
else if exists(select * from Student_Register where st_id=@st_id and register_id=@register_id)
  select'Your ID is Dublicated '
else

begin
	insert into Student_Register
	values(@register_id,@st_id,getdate())
	SELECT 'Registeration_Student inserted successfully'
end
end
GO
-------testing----------
--inserting_Registeration_Student 1,1
----------*******************************************-----

GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
create or alter PROCEDURE dbo.Update_Student_Register
    @st_id int,@register_id int,@St_Insertion_Date date
 WITH ENCRYPTION
 as
 begin
 if not exists(select * from Student where st_id= @st_id)and not exists(select * from Registeration where Register_ID = @register_id )
            select'Student and Registeration not exist'
else if not exists(select * from Student where St_ID = @st_id)
       select'Student not exist'
else if not exists(select * from Registeration where Register_ID = @register_id)
       select'Registeration not exist'
else if exists(select * from Student_Register where St_ID = @st_id and Register_ID = @register_id)
  select'Dublicated PK'
  else 
		  
	begin
		 UPDATE dbo.Student_Register
		  SET
		  St_ID = @st_id , Register_ID = @register_id,
	      St_Insertion_Date = @St_Insertion_Date
		   WHERE Register_ID = @register_id and St_ID = @st_id
		 Select 'Registeration_Student updated successfully'
	  end
   END
GO
-------testing----------
--Update_Student_Register 1,1,'2022-11-01'
----------*******************************************-----
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
  create or alter PROCEDURE dbo.Delete_Student_Register
           @St_ID int,@Register_ID int
 WITH ENCRYPTION  
AS  
   BEGIN  
       IF  EXISTS(SELECT Register_ID , St_ID  FROM dbo.Student_Register WHERE Register_ID = @Register_ID and St_ID = @St_ID )
		 begin
		 Delete from Student_Register where Register_ID = @Register_ID and St_ID  =@St_ID 
		 Select 'Intake deleted successfully'
	  end
	  else
		 select 'Invalid ID'
   END
GO
----------*******************************************-----
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
create or alter proc inserting_Registeration_Instructor
 @ins_id int,@register_id int
 WITH ENCRYPTION
 as
 begin
 if not exists(select * from Instructor where Instructor_id= @ins_id)and not exists(select * from Registeration where register_id=@register_id )
            select'instructor and Registeration not exist'
else if not exists(select * from Instructor where Instructor_id=@ins_id)
       select'Instructor is not existed'
else if not exists(select * from Registeration where register_id=@register_id)
       select'Registeration is not existed'
else if exists(select * from Instructor_Register where Instructor_id=@ins_id and register_id=@register_id)
  select'Your ID is Dublicated '
else

	begin
		insert into [dbo].[Instructor_Register]
		values(@register_id,@ins_id,getdate())
		 SELECT 'Registeration_Instructor inserted successfully'
	  end
end
GO
-------testing----------
--inserting_Registeration_Instructor 1,1
----------*******************************************-----
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
create or alter PROCEDURE dbo.Update_Instructor_Register
     @ins_id int,@register_id int,@Ins_Insertion_Date date
 WITH ENCRYPTION
 as
 begin
 if not exists(select * from Instructor where Instructor_id = @ins_id)and not exists(select * from Registeration where Register_ID = @register_id )
            select'instructor and Registeration not exist'
else if not exists(select * from Instructor where Instructor_id = @ins_id)
       select'Instructor not exist'
else if not exists(select * from Registeration where Register_ID = @register_id)
       select'Registeration not exist'
else if exists(select * from Instructor_Register where Instructor_id = @ins_id and Register_ID = @register_id)
  select'Dublicated PK'
else
		begin
		 UPDATE dbo.Instructor_Register
		  SET
		  Instructor_id = @ins_id , Register_ID = @register_id,
		  Ins_Insertion_Date = @Ins_Insertion_Date
		   WHERE Register_ID= @register_id and Instructor_id = @ins_id
		 Select 'Registeration_Instructor updated successfully'
	  end
   END
GO
-------testing----------
--inserting_Registeration_Instructor 1,1,'2022-11-01'
----------*******************************************-----
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
create or alter PROCEDURE Delete_Instructor_Register
         @Ins_ID int , @Register_ID int
 WITH ENCRYPTION  
AS  
   BEGIN  
       IF  EXISTS(SELECT Instructor_id ,Register_ID  FROM dbo.Instructor_Register WHERE Register_ID = @Register_ID and Instructor_id = @Ins_ID )
		 begin
		 delete from Instructor_Register where Register_ID = @Register_ID and Instructor_id = @Ins_ID
		 Select 'Registeration_Instructor deleted successfully'
	  end
	  else
		 select 'Invalid ID'
   END
GO

----------*******************************************-----
create or alter proc GET_Exam_ID 
AS

	Select max(exam_id)
	from Exam
----------*******************************************-----
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
create or alter PROCEDURE Registration_Inserting_Data
          @register_id INT,@email NVARCHAR(50),
				@username nvarchar(30),
				@password  nvarchar(30),
				@usertype nvarchar(20)
WITH ENCRYPTION
AS  
   BEGIN 
   IF NOT EXISTS(SELECT register_id FROM Registeration WHERE register_id=@register_id)
     
		 begin
		 INSERT INTO Registeration
     (
         register_id,
        email,
         username,
         password,
         usertype
     )
     VALUES
     (    @register_id ,
	       @email,
			@username,
			@password,
			@usertype
         )
		 SELECT 'Registeration inserted successfully'
			end
     ELSE
     SELECT'Duplicate ID'
   END
-------testing----------
--GO
--Registration_Inserting_Data 1, 'Andrew@gmail.com','Andrew','123456','Student'
----------*******************************************-----
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
create or alter PROCEDURE dbo.Update_Registration 
     @register_id INT,@email VARCHAR(255), @username varchar(100)
	 ,@password  varchar(100),@usertype varchar(50)
WITH ENCRYPTION
AS  
   BEGIN  
      IF  EXISTS(SELECT Register_ID FROM dbo.Registeration WHERE Register_ID = @register_id)
		   begin
		  UPDATE dbo.Registeration
		  SET
		  Register_ID = @register_id,
		  Email = @email ,
		   UserName = @username,
		   Password = @password,
		   Usertype = @usertype 
		   WHERE Register_ID = @register_id 
		 Select 'Registeration updated successfully'
		   end
	else
	select 'Invalid Id'
   END
GO
-------testing----------
--Update_Registration 1,'a@gmail.com','aa',123,'b'
---------------------------------------------------------------------------
----------*******************************************-----

GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
create or alter PROCEDURE dbo.Delete_Registration
         @Register_ID INT
 WITH ENCRYPTION  
AS  
   BEGIN 
  if  exists(select Register_ID from Instructor_Register  where Register_ID = @Register_ID)
	 select 'Can not delete this Registeration , Related to Instructor'
  else if exists(select Register_ID from Student_Register where Register_ID = @Register_ID )
	 select 'Can not delete this Registeration , Related to Student'
  else IF not EXISTS(SELECT Register_ID From dbo.Registeration Where Register_ID = @Register_ID )
        select 'Invalid ID'
   else
   begin
		 delete from Registeration where Register_ID = @Register_ID
		 Select 'Registeration deleted successfully'
	  end
   END
GO
-------testing----------
--Delete_Registration 1
----------*******************************************------------reports----------*******************************************-----

GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
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
	
---------testing-----------
--QuestionsinExamWithSTAnswer 4,1 
----------*******************************************-----
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
-------testing----------
--Stud_Grades 1
----------*******************************************-----
--------------------Courses No Students
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
create or alter Proc  Courses_NoStud  @Ins_ID int 
with encryption
As
SELECT        Course.Course_Name, count (st_id) As Number_of_Students
FROM            Course INNER JOIN
                         Inst_Course ON Course.Course_ID = Inst_Course.Course_ID INNER JOIN
                         Stud_Course ON Course.Course_ID = Stud_Course.Course_ID 
						 where  Instructor_ID=@Ins_ID
						 group by Course.Course_Name
						
GO
-------testing----------
--Courses_NoStud 1
----------*******************************************-----
---------------------------------SP Students Deptartments
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
create or alter Proc Studs_Dept @Dept_ID INT
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
  
-------testing----------
--Studs_Dept 10

----------*******************************************-----
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
-------testing----------
--SelectCourseTopic 1
----------*******************************************-----
---------------------------- SP Questions in Exam
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO

create or alter PROC QuestionsinExam @exam_id int
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
-------testing----------
--QuestionsinExam 4

