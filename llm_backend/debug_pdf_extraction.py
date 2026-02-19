import pypdf
import os

def debug_pdf_text(file_path):
    print(f"--- Debugging PDF: {file_path} ---\n")
    
    if not os.path.exists(file_path):
        print("❌ File not found.")
        return

    try:
        with open(file_path, "rb") as f:
            reader = pypdf.PdfReader(f)
            num_pages = len(reader.pages)
            print(f"✅ PDF loaded. Total pages: {num_pages}\n")
            
            for i, page in enumerate(reader.pages):
                print(f"--- Page {i+1} ---")
                text = page.extract_text()
                print(text)
                print("\n----------------\n")
                
                if i >= 2: # Only print first 3 pages to avoid spam
                    print("... (Stopping debug output after 3 pages) ...")
                    break
    except Exception as e:
        print(f"❌ Error reading PDF: {e}")

if __name__ == "__main__":
    pdf_path = os.path.join(os.getcwd(), "mydoc.pdf")
    debug_pdf_text(pdf_path)
