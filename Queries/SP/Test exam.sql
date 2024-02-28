select * from Course
--testexam
execute Exam_Generation @ST_ID=5,@Exam_Title=data,@Exam_Duration=60,@Exam_Date='2024-1-06',
@Questions_Nums=10,@Exam_Grade=100,@Course_ID=1
go
GET_Exam_ID 
go
Questions 9 -- to  select exam questions
go
Exam_Answer @student_Id=5,@exam_Id=9,@question_ID=91 ,@Student_Answer='a) TRUE'
go
Exam_Answer 5,9,89  ,'b) FALSE'
go
Exam_Answer 5,9,75  ,'b) BOOLEAN'
go
Exam_Answer 5,9,75  ,'a) TRUE'
go
Exam_Answer 5,9,75  ,'a) TRUE'
go
Exam_Answer 5,9,75  ,'b) FALSE'
go
Exam_Answer 5,9,75  ,'a) <ul>'
GO
Exam_Answer 5,9,75  ,'c) src'



examCorrection @examID=9,@studentID=5