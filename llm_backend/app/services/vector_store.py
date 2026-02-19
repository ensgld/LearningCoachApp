import os
from langchain_huggingface import HuggingFaceEmbeddings
from langchain_community.vectorstores import FAISS
from app.core.logger import logger

FAISS_INDEX_PATH = os.path.join(os.getcwd(), "faiss_index")
EMBEDDING_MODEL_NAME = "sentence-transformers/all-MiniLM-L6-v2"

def get_embeddings():
    # Model kw_args map to sentence-transformers
    return HuggingFaceEmbeddings(model_name=EMBEDDING_MODEL_NAME)

def load_vector_store():
    """
    Loads the FAISS index from disk. Returns None if not found.
    """
    if os.path.exists(FAISS_INDEX_PATH):
        try:
            embeddings = get_embeddings()
            return FAISS.load_local(FAISS_INDEX_PATH, embeddings, allow_dangerous_deserialization=True)
        except Exception as e:
            logger.error(f"Failed to load FAISS index: {e}")
            return None
    return None

def create_vector_store(texts: list[str], metadatas: list[dict]=None):
    """
    Creates a new FAISS index in memory.
    """
    embeddings = get_embeddings()
    vector_store = FAISS.from_texts(texts, embeddings, metadatas=metadatas)
    return vector_store

def save_vector_store(vector_store):
    """
    Saves the FAISS index to disk.
    """
    vector_store.save_local(FAISS_INDEX_PATH)

