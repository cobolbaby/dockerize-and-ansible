import re

import pandas as pd
import PyPDF2

# Read PDF file and extract text
pdf_path = './题库+答案.pdf'
pdf_file = open(pdf_path, 'rb')
pdf_reader = PyPDF2.PdfReader(pdf_file)

# Extract text from each page of the PDF
text = ""
for page_num in range(len(pdf_reader.pages)):
    page = pdf_reader.pages[page_num]
    text += page.extract_text()

# Close the PDF file
pdf_file.close()

# Split the text into lines
lines = text.split('\n')

def parse_pdf_to_questions(lines):
    questions = []
    current_category = ""
    current_question = ""
    current_options = []
    current_answer = ""
    shared_stem = ""
    shared_stem_active = False
    shared_stem_range = (0, 0)
    current_question_number = 0
    collecting_question = False
    
    for line in lines:
        line = line.strip()

        # Identify the category
        if "单项选择题" in line:
            current_category = "单选题"
        elif "多项选择题" in line:
            current_category = "多选题"
        
        # Identify the shared stem
        shared_stem_match = re.match(r"\((\d+)-(\d+)\s*题共用题干\)", line)
        if shared_stem_match:
            shared_stem_active = True
            shared_stem_range = (int(shared_stem_match.group(1)), int(shared_stem_match.group(2)))
            shared_stem = ""
            continue

        # Append to shared stem if active
        if shared_stem_active:
            if line and not re.match(r"\d+\.", line) and not re.match(r"[A-E]\.", line):
                shared_stem += " " + line
                continue
            else:
                shared_stem_active = False
        
        # Identify the question or continue collecting a multi-line question
        if collecting_question:
            question_continuation_match = re.match(r"(.*?)（\s*([A-E]+)\s*）", line)
            if question_continuation_match:
                question_text, correct_answer = question_continuation_match.groups()
                current_question += f"{question_text}（    ）".strip()
                current_answer = correct_answer
                collecting_question = False
            else:
                current_question += line.strip()
            continue
        else:
            question_match = re.match(r"(\d+)\.(.+?)（(\s*[A-E]+\s*)）", line)
            if question_match:
                if current_question:
                    questions.append([current_question_number, current_category, current_question.strip(), '|'.join(current_options), current_answer])
                    current_question = ""
                    current_options = []
                    current_answer = ""
                current_question_number, question_text, correct_answer = question_match.groups()
                current_question_number = int(current_question_number)
                if shared_stem and shared_stem_range[0] <= current_question_number <= shared_stem_range[1]:
                    current_question = f"{shared_stem} {question_text}（    ）".strip()
                else:
                    current_question = f"{question_text}（    ）".strip()
                current_answer = correct_answer
                continue
            else:
                question_start_match = re.match(r"(\d+)\.(.+)", line)
                if question_start_match:
                    if current_question:
                        questions.append([current_question_number, current_category, current_question.strip(), '|'.join(current_options), current_answer])
                        current_question = ""
                        current_options = []
                        current_answer = ""
                    current_question_number, question_text = question_start_match.groups()
                    current_question_number = int(current_question_number)
                    if shared_stem and shared_stem_range[0] <= current_question_number <= shared_stem_range[1]:
                        current_question = f"{shared_stem} {question_text}".strip()
                    else:
                        current_question = question_text.strip()
                    collecting_question = True
                    continue
        
        # Identify the options
        option_match = re.match(r"([A-E])\.(.+)", line)
        if option_match:
            option_letter, option_text = option_match.groups()
            current_options.append(f"{option_letter}-{option_text.strip()}")

    # Append the last question
    if current_question:
        questions.append([current_question_number, current_category, current_question.strip(), '|'.join(current_options), current_answer])
    
    return questions

# Parse the text from PDF
parsed_questions = parse_pdf_to_questions(lines)

# Create a DataFrame from the parsed questions
df_parsed_questions = pd.DataFrame(parsed_questions, columns=["序号", "题型", "题干", "选项", "答案"])

# Save the intermediate DataFrame to a file for debugging
intermediate_path = './parsed_questions.xlsx'
df_parsed_questions.to_excel(intermediate_path, index=True)

df_parsed_questions.head()
