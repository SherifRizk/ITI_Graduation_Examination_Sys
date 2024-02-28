use [ Examination]
--inserting Project Data
BULK INSERT Course
FROM 'E:\Grad\Course.csv'
WITH (
  FIELDTERMINATOR = ',',
  ROWTERMINATOR = '\n',
  FIRSTROW = 2
)
BULK INSERT Deptartment
FROM 'E:\Grad\Department.csv'
WITH (
  FIELDTERMINATOR = ',',
  ROWTERMINATOR = '\n',
  FIRSTROW = 2
)
BULK INSERT Instructor
FROM 'E:\Grad\Instructor.csv'
WITH (
  FIELDTERMINATOR = ',',
  ROWTERMINATOR = '\n',
  FIRSTROW = 2
)
BULK INSERT Topic
FROM 'E:\Grad\Topic.csv'
WITH (
  FIELDTERMINATOR = ',',
  ROWTERMINATOR = '\n',
  FIRSTROW = 2
)
BULK INSERT Course_Topic
FROM 'E:\Grad\Course_Topic.csv'
WITH (
  FIELDTERMINATOR = ',',
  ROWTERMINATOR = '\n',
  FIRSTROW = 2
)

BULK INSERT Inst_Course
FROM 'E:\Grad\Inst_Course.csv'
WITH (
  FIELDTERMINATOR = ',',
  ROWTERMINATOR = '\n',
  FIRSTROW = 2
)
BULK INSERT Hiring
FROM 'E:\Grad\Hiring.csv'
WITH (
  FIELDTERMINATOR = ',',
  ROWTERMINATOR = '\n',
  FIRSTROW = 2
)
BULK INSERT Freelancing
FROM 'E:\Grad\Freelancing.csv'
WITH (
  FIELDTERMINATOR = ',',
  ROWTERMINATOR = '\n',
  FIRSTROW = 2
)
BULK INSERT Choice
FROM 'E:\Grad\Choice.csv'
WITH (
  FIELDTERMINATOR = ',',
  ROWTERMINATOR = '\n',
  FIRSTROW = 2
)
BULK INSERT Question
FROM 'E:\Grad\Questions.csv'
WITH (
  FIELDTERMINATOR = ',',
  ROWTERMINATOR = '\n',
  FIRSTROW = 2
)

BULK INSERT Intake
FROM 'E:\Grad\Intake.csv'
WITH (
  FIELDTERMINATOR = ',',
  ROWTERMINATOR = '\n',
  FIRSTROW = 2
)
BULK INSERT Track
FROM 'E:\Grad\Track.csv'
WITH (
  FIELDTERMINATOR = ',',
  ROWTERMINATOR = '\n',
  FIRSTROW = 2
)
BULK INSERT Student
FROM 'E:\Grad\Student.csv'
WITH (
  FIELDTERMINATOR = ',',
  ROWTERMINATOR = '\n',
  FIRSTROW = 2
)


BULK INSERT Track_Course
FROM 'E:\Grad\Track_Course.csv'
WITH (
  FIELDTERMINATOR = ',',
  ROWTERMINATOR = '\n',
  FIRSTROW = 2
)
BULK INSERT Stud_Course
FROM 'E:\Grad\Stud_Course.csv'
WITH (
  FIELDTERMINATOR = ',',
  ROWTERMINATOR = '\n',
  FIRSTROW = 2
)

BULK INSERT Certificates
FROM 'E:\Grad\Certificates.csv'
WITH (
  FIELDTERMINATOR = ',',
  ROWTERMINATOR = '\n',
  FIRSTROW = 2
)
BULK INSERT Stud_Cert
FROM 'E:\Grad\Stud_Cert.csv'
WITH (
  FIELDTERMINATOR = ',',
  ROWTERMINATOR = '\n',
  FIRSTROW = 2
)