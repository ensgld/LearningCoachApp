import logging
import os
from datetime import datetime
from logging.handlers import TimedRotatingFileHandler

# Logs directory setup
LOG_DIR = os.path.join(os.path.dirname(os.path.dirname(os.path.dirname(__file__))), "logs")
os.makedirs(LOG_DIR, exist_ok=True)

log_filepath = os.path.join(LOG_DIR, "chat_log.log")

# Configure logging with TimedRotatingFileHandler for daily logs
file_handler = TimedRotatingFileHandler(log_filepath, when="midnight", interval=1, backupCount=30, encoding='utf-8')
file_handler.suffix = "%Y-%m-%d"

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s | %(levelname)s | %(message)s",
    handlers=[
        logging.StreamHandler(),  # Console output
        file_handler  # Daily rotating file output
    ]
)

logger = logging.getLogger("AI-COACH")
logger.info(f"Logging started. Log file: {log_filepath}")

def log_llm_interaction(prompt_type: str, user_message: str, ai_response: str):
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S_%f")
    filename = f"llm_run_{prompt_type}_{timestamp}.txt"
    filepath = os.path.join(LOG_DIR, filename)
    try:
        with open(filepath, "w", encoding="utf-8") as f:
            f.write(f"=== {prompt_type.upper()} ===\n")
            f.write(f"Zaman: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n\n")
            f.write("=== KULLANICI MESAJI / SORUSU ===\n")
            f.write(f"{user_message}\n\n")
            f.write("=== LLM YANITI ===\n")
            f.write(f"{ai_response}\n")
    except Exception as e:
        logger.error(f"Failed to create specific log file for LLM run: {e}")
