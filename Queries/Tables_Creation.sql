USE [ Examination]
GO

/****** Object:  Table [dbo].[Certificates]    Script Date: 2/28/2024 1:08:48 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Certificates](
	[Certification_ID] [int] IDENTITY(1,1) NOT NULL,
	[Certification_Name] [varchar](100) NULL,
	[Certificate_Hour] [int] NULL,
	[Certificate_Website] [varchar](50) NULL,
	[Certificate_URL] [varchar](120) NULL,
	[Certificate_Date] [date] NULL,
 CONSTRAINT [PK_Certificates] PRIMARY KEY CLUSTERED 
(
	[Certification_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO


USE [ Examination]
GO

/****** Object:  Table [dbo].[Course]    Script Date: 2/28/2024 1:10:27 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Course](
	[Course_ID] [int] NOT NULL,
	[Course_Name] [varchar](30) NULL,
	[Course_Duration] [int] NULL,
	[Course_Level] [varchar](20) NULL,
 CONSTRAINT [PK_Course] PRIMARY KEY CLUSTERED 
(
	[Course_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

USE [ Examination]
GO

/****** Object:  Table [dbo].[Course_Topic]    Script Date: 2/28/2024 1:10:53 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Course_Topic](
	[Course_ID] [int] NOT NULL,
	[Topic_ID] [int] NOT NULL,
 CONSTRAINT [PK_Course_Topic] PRIMARY KEY CLUSTERED 
(
	[Course_ID] ASC,
	[Topic_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Course_Topic]  WITH CHECK ADD  CONSTRAINT [FK_Course_Topic_Course] FOREIGN KEY([Course_ID])
REFERENCES [dbo].[Course] ([Course_ID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO

ALTER TABLE [dbo].[Course_Topic] CHECK CONSTRAINT [FK_Course_Topic_Course]
GO

ALTER TABLE [dbo].[Course_Topic]  WITH CHECK ADD  CONSTRAINT [FK_Course_Topic_Topic] FOREIGN KEY([Topic_ID])
REFERENCES [dbo].[Topic] ([Topic_ID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO

ALTER TABLE [dbo].[Course_Topic] CHECK CONSTRAINT [FK_Course_Topic_Topic]
GO

USE [ Examination]
GO

/****** Object:  Table [dbo].[Deptartment]    Script Date: 2/28/2024 1:15:46 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Deptartment](
	[Dept_ID] [int] NOT NULL,
	[Dept_Name] [varchar](30) NULL,
	[Dept_Location] [varchar](20) NULL,
	[Dept_Description] [varchar](50) NULL,
	[Manager_ID] [int] NULL,
 CONSTRAINT [PK_Deptartment] PRIMARY KEY CLUSTERED 
(
	[Dept_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Deptartment]  WITH CHECK ADD  CONSTRAINT [FK_Deptartment_Instructor] FOREIGN KEY([Manager_ID])
REFERENCES [dbo].[Instructor] ([Instructor_ID])
GO

ALTER TABLE [dbo].[Deptartment] CHECK CONSTRAINT [FK_Deptartment_Instructor]
GO

USE [ Examination]
GO

/****** Object:  Table [dbo].[Exam]    Script Date: 2/28/2024 1:15:59 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Exam](
	[Exam_ID] [int] NOT NULL,
	[Exam_Title] [varchar](50) NULL,
	[Exam_Duration] [int] NULL,
	[Exam_Date] [datetime] NULL,
	[Quest_Nums] [int] NULL,
	[Exam_Grade] [int] NULL,
	[Course_ID] [int] NULL,
 CONSTRAINT [PK_Exam] PRIMARY KEY CLUSTERED 
(
	[Exam_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Exam]  WITH CHECK ADD  CONSTRAINT [FK_Exam_Course] FOREIGN KEY([Course_ID])
REFERENCES [dbo].[Course] ([Course_ID])
ON UPDATE CASCADE
ON DELETE SET NULL
GO

ALTER TABLE [dbo].[Exam] CHECK CONSTRAINT [FK_Exam_Course]
GO

USE [ Examination]
GO

/****** Object:  Table [dbo].[Exam_Quest]    Script Date: 2/28/2024 1:16:08 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Exam_Quest](
	[Exam_ID] [int] NOT NULL,
	[Question_ID] [int] NOT NULL,
 CONSTRAINT [PK_Exam_Quest] PRIMARY KEY CLUSTERED 
(
	[Exam_ID] ASC,
	[Question_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Exam_Quest]  WITH CHECK ADD  CONSTRAINT [FK_Exam_Quest_Exam] FOREIGN KEY([Exam_ID])
REFERENCES [dbo].[Exam] ([Exam_ID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO

ALTER TABLE [dbo].[Exam_Quest] CHECK CONSTRAINT [FK_Exam_Quest_Exam]
GO

ALTER TABLE [dbo].[Exam_Quest]  WITH CHECK ADD  CONSTRAINT [FK_Exam_Quest_Question] FOREIGN KEY([Question_ID])
REFERENCES [dbo].[Question] ([Question_ID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO

ALTER TABLE [dbo].[Exam_Quest] CHECK CONSTRAINT [FK_Exam_Quest_Question]
GO

USE [ Examination]
GO

/****** Object:  Table [dbo].[Freelancing]    Script Date: 2/28/2024 1:16:16 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Freelancing](
	[Freelanc_ID] [int] NOT NULL,
	[Job_Name] [varchar](50) NULL,
	[Job_Website] [varchar](50) NULL,
	[Job_StartDate] [date] NULL,
	[Job_Tools] [varchar](30) NULL,
	[Feedback_Rating] [int] NULL,
	[ST_ID] [int] NULL,
 CONSTRAINT [PK_Freelancing] PRIMARY KEY CLUSTERED 
(
	[Freelanc_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Freelancing]  WITH CHECK ADD  CONSTRAINT [FK_Freelancing_Student] FOREIGN KEY([ST_ID])
REFERENCES [dbo].[Student] ([ST_ID])
ON UPDATE CASCADE
ON DELETE SET NULL
GO

ALTER TABLE [dbo].[Freelancing] CHECK CONSTRAINT [FK_Freelancing_Student]
GO

USE [ Examination]
GO

/****** Object:  Table [dbo].[Hiring]    Script Date: 2/28/2024 1:16:25 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Hiring](
	[Hiring_ID] [int] NOT NULL,
	[Position] [varchar](100) NULL,
	[Hiring_Date] [date] NULL,
	[Company] [varchar](50) NULL,
	[Location] [varchar](20) NULL,
	[Positon_Type] [varchar](20) NULL,
	[ST_ID] [int] NULL,
 CONSTRAINT [PK_Hiring] PRIMARY KEY CLUSTERED 
(
	[Hiring_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Hiring]  WITH CHECK ADD  CONSTRAINT [FK_Hiring_Student] FOREIGN KEY([ST_ID])
REFERENCES [dbo].[Student] ([ST_ID])
ON UPDATE CASCADE
ON DELETE SET NULL
GO

ALTER TABLE [dbo].[Hiring] CHECK CONSTRAINT [FK_Hiring_Student]
GO

USE [ Examination]
GO

/****** Object:  Table [dbo].[Inst_Course]    Script Date: 2/28/2024 1:16:37 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Inst_Course](
	[Course_ID] [int] NOT NULL,
	[Instructor_ID] [int] NOT NULL,
 CONSTRAINT [PK_Inst_Course] PRIMARY KEY CLUSTERED 
(
	[Course_ID] ASC,
	[Instructor_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Inst_Course]  WITH CHECK ADD  CONSTRAINT [FK_Inst_Course_Course] FOREIGN KEY([Course_ID])
REFERENCES [dbo].[Course] ([Course_ID])
GO

ALTER TABLE [dbo].[Inst_Course] CHECK CONSTRAINT [FK_Inst_Course_Course]
GO

ALTER TABLE [dbo].[Inst_Course]  WITH CHECK ADD  CONSTRAINT [FK_Inst_Course_Instructor] FOREIGN KEY([Instructor_ID])
REFERENCES [dbo].[Instructor] ([Instructor_ID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO

ALTER TABLE [dbo].[Inst_Course] CHECK CONSTRAINT [FK_Inst_Course_Instructor]
GO

USE [ Examination]
GO

/****** Object:  Table [dbo].[Instructor]    Script Date: 2/28/2024 1:17:30 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Instructor](
	[Instructor_ID] [int] NOT NULL,
	[Instructor_Fname] [varchar](20) NULL,
	[Instructor_Lname] [varchar](20) NULL,
	[Instuctor_Age] [int] NULL,
	[Instructor_BirthDate] [date] NULL,
	[Instructor_Gender] [varchar](10) NULL,
	[Salary] [int] NULL,
	[City] [varchar](20) NULL,
	[Hire_Date] [date] NULL,
	[Dept_ID] [int] NULL,
 CONSTRAINT [PK_Instructor] PRIMARY KEY CLUSTERED 
(
	[Instructor_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Instructor]  WITH CHECK ADD  CONSTRAINT [FK_Instructor_Deptartment] FOREIGN KEY([Dept_ID])
REFERENCES [dbo].[Deptartment] ([Dept_ID])
GO

ALTER TABLE [dbo].[Instructor] CHECK CONSTRAINT [FK_Instructor_Deptartment]
GO

USE [ Examination]
GO

/****** Object:  Table [dbo].[Instructor_Register]    Script Date: 2/28/2024 1:17:41 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Instructor_Register](
	[Instructor_id] [int] NOT NULL,
	[Register_ID] [int] NOT NULL,
	[Ins_Insertion_Date] [date] NULL,
 CONSTRAINT [PK_Instructor_Register] PRIMARY KEY CLUSTERED 
(
	[Instructor_id] ASC,
	[Register_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Instructor_Register]  WITH CHECK ADD  CONSTRAINT [FK__Instructo__Instr__0EF836A4] FOREIGN KEY([Instructor_id])
REFERENCES [dbo].[Instructor] ([Instructor_ID])
GO

ALTER TABLE [dbo].[Instructor_Register] CHECK CONSTRAINT [FK__Instructo__Instr__0EF836A4]
GO

ALTER TABLE [dbo].[Instructor_Register]  WITH CHECK ADD  CONSTRAINT [FK__Instructo__Regis__0FEC5ADD] FOREIGN KEY([Register_ID])
REFERENCES [dbo].[Registeration] ([Register_ID])
GO

ALTER TABLE [dbo].[Instructor_Register] CHECK CONSTRAINT [FK__Instructo__Regis__0FEC5ADD]
GO

USE [ Examination]
GO

/****** Object:  Table [dbo].[Intake]    Script Date: 2/28/2024 1:17:52 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Intake](
	[Intake_ID] [int] NOT NULL,
	[Branch_Name] [varchar](25) NOT NULL,
	[Intake_StartDate] [date] NULL,
	[Intake_EndDate] [date] NULL,
	[Intake_Duration] [int] NULL,
 CONSTRAINT [PK_Intake] PRIMARY KEY CLUSTERED 
(
	[Intake_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

USE [ Examination]
GO

/****** Object:  Table [dbo].[Question]    Script Date: 2/28/2024 1:18:01 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Question](
	[Question_ID] [int] NOT NULL,
	[Question_Type] [varchar](20) NULL,
	[Question_ModelAnswer] [varchar](100) NULL,
	[Question] [varchar](500) NULL,
	[Course_ID] [int] NULL,
 CONSTRAINT [PK_Question] PRIMARY KEY CLUSTERED 
(
	[Question_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Question]  WITH CHECK ADD  CONSTRAINT [FK_Question_Course] FOREIGN KEY([Course_ID])
REFERENCES [dbo].[Course] ([Course_ID])
GO

ALTER TABLE [dbo].[Question] CHECK CONSTRAINT [FK_Question_Course]
GO

USE [ Examination]
GO

/****** Object:  Table [dbo].[Registeration]    Script Date: 2/28/2024 1:18:09 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Registeration](
	[Register_ID] [int] NOT NULL,
	[Email] [varchar](50) NULL,
	[UserName] [varchar](30) NULL,
	[Password] [varchar](30) NULL,
	[Usertype] [varchar](20) NULL,
 CONSTRAINT [PK__Register__E454148E2FD22A35] PRIMARY KEY CLUSTERED 
(
	[Register_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

USE [ Examination]
GO

/****** Object:  Table [dbo].[Stud_Cert]    Script Date: 2/28/2024 1:18:21 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Stud_Cert](
	[ST_ID] [int] NOT NULL,
	[Certificate_ID] [int] NOT NULL,
 CONSTRAINT [PK_Stud_Cert] PRIMARY KEY CLUSTERED 
(
	[ST_ID] ASC,
	[Certificate_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Stud_Cert]  WITH CHECK ADD  CONSTRAINT [FK_Stud_Cert_Certificates] FOREIGN KEY([Certificate_ID])
REFERENCES [dbo].[Certificates] ([Certification_ID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO

ALTER TABLE [dbo].[Stud_Cert] CHECK CONSTRAINT [FK_Stud_Cert_Certificates]
GO

ALTER TABLE [dbo].[Stud_Cert]  WITH NOCHECK ADD  CONSTRAINT [FK_Stud_Cert_Student] FOREIGN KEY([ST_ID])
REFERENCES [dbo].[Student] ([ST_ID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO

ALTER TABLE [dbo].[Stud_Cert] CHECK CONSTRAINT [FK_Stud_Cert_Student]
GO

USE [ Examination]
GO

/****** Object:  Table [dbo].[Stud_Course]    Script Date: 2/28/2024 1:18:30 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Stud_Course](
	[St_ID] [int] NOT NULL,
	[Course_ID] [int] NOT NULL,
	[St_Grade] [float] NULL,
	[Exam_ID] [int] NULL,
 CONSTRAINT [PK_Stud_Course] PRIMARY KEY CLUSTERED 
(
	[St_ID] ASC,
	[Course_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Stud_Course]  WITH NOCHECK ADD  CONSTRAINT [FK_Stud_Course_Course] FOREIGN KEY([Course_ID])
REFERENCES [dbo].[Course] ([Course_ID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO

ALTER TABLE [dbo].[Stud_Course] CHECK CONSTRAINT [FK_Stud_Course_Course]
GO

ALTER TABLE [dbo].[Stud_Course]  WITH NOCHECK ADD  CONSTRAINT [FK_Stud_Course_Student] FOREIGN KEY([St_ID])
REFERENCES [dbo].[Student] ([ST_ID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO

ALTER TABLE [dbo].[Stud_Course] CHECK CONSTRAINT [FK_Stud_Course_Student]
GO

USE [ Examination]
GO

/****** Object:  Table [dbo].[Student]    Script Date: 2/28/2024 1:18:39 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Student](
	[ST_ID] [int] NOT NULL,
	[ST_SSN] [int] NULL,
	[ST_Fname] [varchar](50) NULL,
	[ST_Lname] [varchar](50) NULL,
	[ST_BirthDate] [date] NULL,
	[ST_Age] [int] NULL,
	[ST_City] [varchar](50) NULL,
	[ST_Gender] [varchar](30) NULL,
	[Intake_ID] [int] NULL,
	[Track_ID] [int] NULL,
 CONSTRAINT [PK_Student] PRIMARY KEY CLUSTERED 
(
	[ST_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Student]  WITH CHECK ADD  CONSTRAINT [FK_Student_Intake] FOREIGN KEY([Intake_ID])
REFERENCES [dbo].[Intake] ([Intake_ID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO

ALTER TABLE [dbo].[Student] CHECK CONSTRAINT [FK_Student_Intake]
GO

ALTER TABLE [dbo].[Student]  WITH CHECK ADD  CONSTRAINT [FK_Student_Track] FOREIGN KEY([Track_ID])
REFERENCES [dbo].[Track] ([Track_ID])
ON UPDATE CASCADE
ON DELETE SET NULL
GO

ALTER TABLE [dbo].[Student] CHECK CONSTRAINT [FK_Student_Track]
GO

USE [ Examination]
GO

/****** Object:  Table [dbo].[Student_Exam]    Script Date: 2/28/2024 1:18:50 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Student_Exam](
	[ST_ID] [int] NOT NULL,
	[Exam_ID] [int] NOT NULL,
	[Question_ID] [int] NOT NULL,
	[Question_Grade] [int] NULL,
	[Student_Answer] [varchar](150) NULL,
 CONSTRAINT [PK_Student_Exam] PRIMARY KEY CLUSTERED 
(
	[ST_ID] ASC,
	[Exam_ID] ASC,
	[Question_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Student_Exam]  WITH CHECK ADD  CONSTRAINT [FK_Student_Exam_Exam] FOREIGN KEY([Exam_ID])
REFERENCES [dbo].[Exam] ([Exam_ID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO

ALTER TABLE [dbo].[Student_Exam] CHECK CONSTRAINT [FK_Student_Exam_Exam]
GO

ALTER TABLE [dbo].[Student_Exam]  WITH CHECK ADD  CONSTRAINT [FK_Student_Exam_Student] FOREIGN KEY([ST_ID])
REFERENCES [dbo].[Student] ([ST_ID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO

ALTER TABLE [dbo].[Student_Exam] CHECK CONSTRAINT [FK_Student_Exam_Student]
GO

USE [ Examination]
GO

/****** Object:  Table [dbo].[Student_Exam_Info]    Script Date: 2/28/2024 1:18:58 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Student_Exam_Info](
	[ST_ID] [int] NOT NULL,
	[Exam_ID] [int] NOT NULL,
	[Exam_Time] [time](7) NULL,
	[Answered_Questions] [int] NULL,
 CONSTRAINT [PK_Student_Exam_Info] PRIMARY KEY CLUSTERED 
(
	[ST_ID] ASC,
	[Exam_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Student_Exam_Info]  WITH CHECK ADD  CONSTRAINT [FK_Student_Exam_Info_Exam] FOREIGN KEY([Exam_ID])
REFERENCES [dbo].[Exam] ([Exam_ID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO

ALTER TABLE [dbo].[Student_Exam_Info] CHECK CONSTRAINT [FK_Student_Exam_Info_Exam]
GO

ALTER TABLE [dbo].[Student_Exam_Info]  WITH CHECK ADD  CONSTRAINT [FK_Student_Exam_Info_Student] FOREIGN KEY([ST_ID])
REFERENCES [dbo].[Student] ([ST_ID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO

ALTER TABLE [dbo].[Student_Exam_Info] CHECK CONSTRAINT [FK_Student_Exam_Info_Student]
GO

USE [ Examination]
GO

/****** Object:  Table [dbo].[Student_Register]    Script Date: 2/28/2024 1:19:07 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Student_Register](
	[Register_ID] [int] NOT NULL,
	[St_ID] [int] NOT NULL,
	[St_Insertion_Date] [date] NULL,
 CONSTRAINT [PK__Student___E454148E6050446F] PRIMARY KEY CLUSTERED 
(
	[Register_ID] ASC,
	[St_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Student_Register]  WITH CHECK ADD  CONSTRAINT [FK__Student_R__Regis__13BCEBC1] FOREIGN KEY([Register_ID])
REFERENCES [dbo].[Registeration] ([Register_ID])
ON DELETE CASCADE
GO

ALTER TABLE [dbo].[Student_Register] CHECK CONSTRAINT [FK__Student_R__Regis__13BCEBC1]
GO

ALTER TABLE [dbo].[Student_Register]  WITH CHECK ADD  CONSTRAINT [FK__Student_R__St_ID__12C8C788] FOREIGN KEY([St_ID])
REFERENCES [dbo].[Student] ([ST_ID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO

ALTER TABLE [dbo].[Student_Register] CHECK CONSTRAINT [FK__Student_R__St_ID__12C8C788]
GO

USE [ Examination]
GO

/****** Object:  Table [dbo].[Topic]    Script Date: 2/28/2024 1:19:15 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Topic](
	[Topic_ID] [int] NOT NULL,
	[Topic_Name] [varchar](50) NULL,
 CONSTRAINT [PK_Topic] PRIMARY KEY CLUSTERED 
(
	[Topic_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

USE [ Examination]
GO

/****** Object:  Table [dbo].[Track]    Script Date: 2/28/2024 1:19:22 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Track](
	[Track_ID] [int] IDENTITY(1,1) NOT NULL,
	[Track_Name] [varchar](50) NULL,
	[Track_Titles] [varchar](50) NULL,
	[Supervisor_ID] [int] NULL,
 CONSTRAINT [PK_Track] PRIMARY KEY CLUSTERED 
(
	[Track_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Track]  WITH CHECK ADD  CONSTRAINT [FK_Track_Instructor] FOREIGN KEY([Supervisor_ID])
REFERENCES [dbo].[Instructor] ([Instructor_ID])
GO

ALTER TABLE [dbo].[Track] CHECK CONSTRAINT [FK_Track_Instructor]
GO

USE [ Examination]
GO

/****** Object:  Table [dbo].[Track_Course]    Script Date: 2/28/2024 1:19:30 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Track_Course](
	[Track_ID] [int] NOT NULL,
	[Course_ID] [int] NOT NULL,
 CONSTRAINT [PK_Track_Course] PRIMARY KEY CLUSTERED 
(
	[Track_ID] ASC,
	[Course_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Track_Course]  WITH CHECK ADD  CONSTRAINT [FK_Track_Course_Course] FOREIGN KEY([Course_ID])
REFERENCES [dbo].[Course] ([Course_ID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO

ALTER TABLE [dbo].[Track_Course] CHECK CONSTRAINT [FK_Track_Course_Course]
GO

ALTER TABLE [dbo].[Track_Course]  WITH CHECK ADD  CONSTRAINT [FK_Track_Course_Track] FOREIGN KEY([Track_ID])
REFERENCES [dbo].[Track] ([Track_ID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO

ALTER TABLE [dbo].[Track_Course] CHECK CONSTRAINT [FK_Track_Course_Track]
GO

