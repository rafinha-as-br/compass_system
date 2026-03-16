import PyPDF2
import sys

def extract_pdf(pdf_path, txt_path):
    try:
        reader = PyPDF2.PdfReader(pdf_path)
        with open(txt_path, 'w', encoding='utf-8') as f:
            for page in reader.pages:
                f.write(page.extract_text() + '\n')
        print(f"Successfully extracted {pdf_path} to {txt_path}")
    except Exception as e:
        print(f"Failed to extract {pdf_path}: {e}")

if __name__ == '__main__':
    extract_pdf('compass_system_doc.pdf', 'compass_doc.txt')
    extract_pdf('architecture_rules.pdf', 'architecture_rules.txt')
