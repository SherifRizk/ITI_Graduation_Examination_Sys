# ITI Graduation Examination System

The examination system is a streamlined method for performing examination-related tasks such as creating exam patterns with question banks, creating test timers, and administering exams digitally and without paper.

## Overview

This project is a comprehensive digital examination system developed for the Information Technology Institute (ITI). It provides a complete solution for creating, managing, and administering online examinations with features including automatic grading, result reporting, and data analytics.

## Technologies Used

- **Backend**: Python Flask web framework
- **Database**: Microsoft SQL Server
- **Frontend**: HTML, CSS, JavaScript, jQuery
- **Reporting**: SQL Server Reporting Services (SSRS)
- **Analytics**: Power BI
- **Database Connectivity**: PyODBC

## Project Structure

### 📁 Root Directory Files

- **`README.md`** - This documentation file describing the project
- **`Documentation For Examination System .pdf`** - Comprehensive system documentation
- **`Examination_ITI.bak`** - SQL Server database backup file for the examination system
- **`ITI_Grad.pbix`** - Power BI report file for data visualization and analytics

### 📁 Grad_APP/
The main Flask web application directory containing the examination system's web interface.

- **`main.py`** - Main Flask application file containing all route handlers and business logic
  - Database connection configuration
  - Exam creation and management routes
  - Student examination interface
  - Grade calculation and result display
  - AJAX endpoints for dynamic functionality

- **📁 templates/** - HTML template files for the web interface
  - **`create_exam.html`** - Form interface for creating new examinations
  - **`exam_details.html`** - Student exam taking interface with questions and answers
  - **`exam_created_successfully.html`** - Success page after exam creation
  - **`exam_id.html`** - Display exam ID information
  - **`show_results.html`** - Grade and result display page

### 📁 Queries/
Database scripts and stored procedures for the examination system.

- **`Tables_Creation.sql`** - Database schema creation script containing all table definitions
  - Student, Course, Instructor, Department tables
  - Question, Exam, Answer tracking tables
  - Relationship and constraint definitions

- **📁 SP/** - Stored Procedures directory
  - **`Final All SP.sql`** - Complete collection of all stored procedures
  - **`Test exam.sql`** - Test scripts for exam functionality
  - **`all 6 reports SP[1].sql`** - Stored procedures for reporting functions
  - **`reports_sp.sql`** - Additional reporting stored procedures

### 📁 Data/
CSV data files for populating the database with sample and initial data.

- **`Bult_Insert.sql`** - Bulk insert SQL script for loading CSV data
- **`Certificates.csv`** - Certificate information data
- **`Choice.csv`** - Multiple choice answer options
- **`Course.csv`** - Course information and details
- **`Course_Topic.csv`** - Course-topic relationship mappings
- **`Department.csv`** - Department structure data
- **`Freelancing.csv`** - Freelancing opportunity records
- **`Hiring.csv`** - Hiring and employment data
- **`Inst_Course.csv`** - Instructor-course assignments
- **`Instructor.csv`** - Instructor information
- **`Intake.csv`** - Student intake information
- **`Questions.csv`** - Question bank data
- **`Stud_Cert.csv`** - Student certification records
- **`Stud_Course.csv`** - Student-course enrollments
- **`Student.csv`** - Student information
- **`Topic.csv`** - Course topics and subjects
- **`Track.csv`** - Academic track information
- **`Track_Course.csv`** - Track-course relationship mappings

### 📁 reports/
SQL Server Reporting Services (SSRS) project for generating examination reports.

- **`Examination Reports Project.sln`** - Visual Studio solution file for reports
- **📁 .vs/** - Visual Studio configuration files
- **📁 testing ssrs/** - SSRS testing and development files

### 📁 ScreenShots/
Visual documentation and user interface screenshots organized by category.

- **📁 APP/** - Application interface screenshots
  - Various PNG files showing the web application interface
  - User journey documentation through screenshots

- **📁 ERD & Mapping/** - Database design documentation
  - **`Screenshot 2024-02-28 124447.png`** - Entity Relationship Diagram
  - **`WhatsApp Image 2024-02-27 at 15.48.51_*.jpg`** - Database mapping diagrams

- **📁 Exam_Screenshot/** - Examination interface documentation
- **📁 Power BI/** - Power BI report screenshots
- **📁 SSRS/** - SSRS report screenshots

## Key Features

1. **Exam Creation**: Create customized exams with configurable parameters
   - Question count and types (Multiple Choice, True/False)
   - Time duration and scheduling
   - Grade weighting and scoring

2. **Question Bank Management**: Comprehensive question repository
   - Multiple choice and true/false questions
   - Course-specific question organization
   - Dynamic question selection for exams

3. **Student Examination Interface**: User-friendly exam taking experience
   - Timed examinations with countdown
   - Question navigation and answer selection
   - Automatic submission and grading

4. **Automated Grading**: Real-time grade calculation
   - Immediate result generation
   - Score tracking and history

5. **Reporting and Analytics**: Comprehensive reporting capabilities
   - Student performance reports via SSRS
   - Data visualization through Power BI
   - Statistical analysis and insights

6. **Database Integration**: Robust data management
   - SQL Server backend with stored procedures
   - Data integrity and relationship enforcement
   - Scalable architecture for multiple users

## Setup Instructions

1. **Database Setup**:
   - Restore the `Examination_ITI.bak` file to SQL Server
   - Run `Tables_Creation.sql` if setting up from scratch
   - Execute stored procedures from the `SP/` directory
   - Load sample data using `Bult_Insert.sql` and CSV files

2. **Application Setup**:
   - Install Python and required packages: `pip install flask pyodbc`
   - Update database connection parameters in `main.py`
   - Run the Flask application: `python main.py`
   - Access the application at `http://localhost:5000`

3. **Reporting Setup**:
   - Open the SSRS project in Visual Studio
   - Configure database connections for reports
   - Deploy reports to SQL Server Reporting Services

4. **Analytics Setup**:
   - Open `ITI_Grad.pbix` in Power BI Desktop
   - Configure data source connections
   - Publish to Power BI Service if needed

## Usage

1. Navigate to the application homepage
2. Create a new exam using the exam creation form
3. Students can access exams through the exam interface
4. View results and grades in the results section
5. Generate reports using SSRS or Power BI for analytics

## Contributing

This project is part of the ITI graduation requirements. For contributions or modifications, please follow the established coding standards and database design patterns.
