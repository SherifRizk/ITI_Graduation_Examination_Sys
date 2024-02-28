from flask import Flask, request, render_template,redirect,url_for,jsonify
import pyodbc

app = Flask(__name__)

# Database connection parameters
server = 'LAPTOP-P47PGR3P'
database = ' Examination'
username = 'BI'
password = 'Stay@safe2024'
cnxn = pyodbc.connect('DRIVER={ODBC Driver 17 for SQL Server};SERVER=' +
                      server+';DATABASE='+database+';UID='+username+';PWD='+ password)
student_id =  None
@app.route('/')
def index():
    # Redirect to the create exam page as the default route
    return redirect(url_for('create_exam'))
from datetime import datetime

@app.route('/show_exam', methods=['GET','POST'])
def show_exam():
    #exam_title = request.form['Exam_title']  # Or other criteria for identifying the exam

    cursor = cnxn.cursor()
    # Assuming "GET_EXAM_ID" returns a single ID based on the exam title or criteria
    cursor.execute("EXEC GET_EXAM_ID")
    exam_id_row = cursor.fetchone()
    if exam_id_row:
        exam_id = exam_id_row[0]

        # Now, use the exam ID to get the exam details
        cursor.execute("EXEC Questions @ex_id=?", (exam_id,))
        rows = cursor.fetchall()

        # Organizing questions similar to previous steps
        # ... (organizing code as shown previously)
        # Organizing questions by their IDs
        questions = {}
        for row in rows:
            qid, question_text, choice = row
            if qid not in questions:
                questions[qid] = {'text': question_text, 'choices': [],"qid":qid}
            questions[qid]['choices'].append(choice)

        # Convert dict to list for easier templating
        
        questions_list = list(questions.values())
        global student_id
        return render_template('exam_details.html', questions=questions_list,exam_id=exam_id,student_id=student_id)
        
    else:
        return "Exam not found."


@app.route('/get_exam_details', methods=['POST'])
def get_exam_details():
    exam_id = request.form['exam_id']  # Assuming the exam_id is passed from a form or session

    cursor = cnxn.cursor()
    cursor.execute("EXEC Questions @ex_id=?", (exam_id,))
    rows = cursor.fetchall()

    # Organizing questions by their IDs
    questions = {}
    for row in rows:
        qid, question_text, choice = row
        if qid not in questions:
            questions[qid] = {'text': question_text, 'choices': []}
        questions[qid]['choices'].append(choice)

    # Convert dict to list for easier templating
    questions_list = list(questions.values())

    return render_template('exam_details.html', questions=questions_list)
def call_exam_answer_procedure(student_id, exam_id, question_id, student_answer):
    cursor = cnxn.cursor()
    cursor.execute("{CALL Exam_Answer (?, ?, ?, ?)}", (student_id, exam_id, question_id, student_answer))
    cnxn.commit()

@app.route('/submit_exam', methods=['POST'])
def submit_exam():
    data = request.get_json()
    
    # Extract data from the request
    student_id = data.get('student_id')
    exam_id = data.get('exam_id')
    answers = data.get('answers', [])

    # Loop through each answer and call the stored procedure
    for answer in answers:
        question_id = answer.get('question_id')
        student_answer = answer.get('answer')
        # Call the stored procedure with the provided data
        call_exam_answer_procedure(student_id, exam_id, question_id, student_answer)
    # import pdb ; pdb.set_trace()
    # Call the exam correction stored procedure after submitting answers
    correct_exam(exam_id, student_id)
    grade = get_grade(exam_id, student_id)
    # Redirect to results page (or return data to be handled by frontend for redirection)
    #return jsonify({'redirect': url_for('show_results', student_id=student_id, grade=grade)})
    return  jsonify({'grade': grade})
    
def get_grade(exam_id  , student_id):
    # import pdb ;  pdb.set_trace()
    cursor=  cnxn.cursor()
    # cursor.execute("CALL Get_Grade (? ,  ? ) " , (student_id , exam_id))

    cursor.execute("{CALL Get_Grade (? ,?)}" , (student_id , exam_id))
    grade = cursor.fetchall()[0][0]
    cursor.commit()
    cnxn.commit()
    return grade 
def correct_exam(exam_id, student_id):
    # Connect to the database and call the correction stored procedure
    cursor = cnxn.cursor()
   
    #cursor.execute("EXEC examCorrection @exam_id=?,@student_id=?", (exam_id, student_id,))
    cursor.execute("{CALL examCorrection (?, ?)}", (exam_id, student_id))
    cursor.commit()
    cnxn.commit()
    # grade = cursor.fetchone()[0]   # Assuming the procedure returns the grade
    # return grade

@app.route('/results/<int:student_id>/<int:grade>')
def show_results(student_id, grade):
    # import pdb ; pdb.set_trace()
    # Generate the results page
    # In a real application, you'd probably use a template
    return render_template("show_results.html", student_id = student_id , student_grade = grade)

@app.route('/submit_answer', methods=['POST'])
def submit_answer():
    # import pdb;pdb.set_trace()
    student_id = request.form['student_id']
    exam_id = request.form['exam_id']
    question_id = request.form['question_id']
    student_answer = request.form['answer']

    cursor = cnxn.cursor()
    try:
        cursor.execute("EXEC Exam_Answer @student_Id=?, @exam_Id=?, @question_ID=?, @Student_Answer=?", (student_id, exam_id, question_id, student_answer))
        cnxn.commit()
        return jsonify({'message': 'Answer submitted successfully'})
    except Exception as e:
        return jsonify({'error': str(e)}), 500


@app.route('/create_exam', methods=['GET', 'POST'])
def create_exam():
    if request.method == 'POST':
        # Extract form data
        st_id = request.form['ST_ID']
        global student_id 
        student_id = st_id
        exam_title = request.form['Exam_Title']
        exam_duration = request.form['Exam_Duration']
        exam_date_str = request.form['Exam_Date']
        
        # Convert the exam_date from string to a datetime object
        # Adjust the format if necessary to match your input form's date format
        exam_date = datetime.strptime(exam_date_str, '%Y-%m-%dT%H:%M')

        # Now convert it back to string in the format SQL Server expects
        exam_date = exam_date.strftime('%Y-%m-%d %H:%M:%S')
        questions_nums = request.form['Questions_Nums']
        exam_grade = request.form['Exam_Grade']
        course_id = request.form['Course_ID']
        tf_q = request.form['TF_Q']
        mcq_q = request.form['MCQ_Q']
        
        # Execute the stored procedure
        cursor = cnxn.cursor()
        cursor.execute("EXEC Exam_Generation @ST_ID=?, @Exam_Title=?, @Exam_Duration=?, @Exam_Date=?, @Questions_Nums=?, @Exam_Grade=?, @Course_ID=?, @TF_Q=?, @MCQ_Q=?", (st_id, exam_title, exam_duration, exam_date, questions_nums, exam_grade, course_id, tf_q, mcq_q))
        cnxn.commit()
        
        # Instead of returning a simple message, render a template with the option to fetch the exam ID
        return render_template('exam_created_successfully.html', exam_title=exam_title)

    else:
        # Render the form for GET request
        return render_template('create_exam.html')

if __name__ == '__main__':
    app.run(debug=True)

