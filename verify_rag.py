import requests
import time
import os
from reportlab.pdfgen import canvas
from reportlab.lib.pagesizes import letter

BASE_URL = "http://localhost:8000"

def create_pdf(filename):
    c = canvas.Canvas(filename, pagesize=letter)
    c.drawString(100, 750, "CONFIDENTIAL DOCUMENT")
    c.drawString(100, 730, "The secret project code is PROJECT-OMEGA-99.")
    c.drawString(100, 710, "This information is for authorized personnel only.")
    c.save()
    print(f"Created PDF: {filename}")

def test_rag():
    pdf_file = "test_rag.pdf"
    create_pdf(pdf_file)
    
    try:
        # 1. Ingest
        print(f"Ingesting {pdf_file}...")
        with open(pdf_file, "rb") as f:
            files = {"file": (pdf_file, f, "application/pdf")}
            response = requests.post(f"{BASE_URL}/rag/ingest", files=files)
            
        if response.status_code in [200, 201]:
            print("✅ Ingestion successful")
            print(response.json())
        else:
            print(f"❌ Ingestion failed: {response.status_code} {response.text}")
            return

        # 2. Query
        question = "What is the secret project code?"
        print(f"\nQuerying: {question}")
        
        payload = {
            "question": question,
            # history is optional
        }
        
        response = requests.post(f"{BASE_URL}/rag/answer", json=payload)
        
        if response.status_code == 200:
            data = response.json()
            answer = data["answer"]
            sources = data.get("sources", [])
            
            print(f"Answer: {answer}")
            print(f"Sources: {sources}")
            
            # Check if retrieval worked (sources should contain our PDF)
            if any(pdf_file in s.get("docTitle", "") for s in sources):
                print("✅ Retrieval successful (Source found)")
            else:
                print("❌ Retrieval failed (Source not found)")
                
            # Check if answer contains "OMEGA" (depends on Llama)
            if "OMEGA" in answer or "99" in answer:
                print("✅ Generation successful (Answer correct)")
            else:
                print("⚠️ Generation might be incomplete (Answer doesn't contain expected keyword). Check Llama logs.")
                
        else:
            print(f"❌ Query failed: {response.status_code} {response.text}")

        # 3. Test Chat (Standard)
        print("\nTesting /chat endpoint...")
        chat_payload = {"message": "Hello"}
        chat_response = requests.post(f"{BASE_URL}/chat", json=chat_payload)
        if chat_response.status_code == 200:
            print("✅ Chat endpoint successful")
            print(f"Response: {chat_response.json()}")
        else:
            print(f"❌ Chat endpoint failed: {chat_response.status_code} {chat_response.text}")

            
    except Exception as e:
        print(f"❌ Error: {e}")
        
    finally:
        if os.path.exists(pdf_file):
            os.remove(pdf_file)

if __name__ == "__main__":
    time.sleep(10) # Wait for server to be ready
    test_rag()
