import logging
import os
from datetime import datetime

# Logs directory setup
LOG_DIR = os.path.join(os.path.dirname(os.path.dirname(os.path.dirname(__file__))), "logs")
os.makedirs(LOG_DIR, exist_ok=True)

# Generate a unique filename for this session
session_timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
log_filename = f"chat_log_{session_timestamp}.txt"
log_filepath = os.path.join(LOG_DIR, log_filename)

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s | %(levelname)s | %(message)s",
    handlers=[
        logging.StreamHandler(),  # Console output
        logging.FileHandler(log_filepath, encoding='utf-8')  # File output
    ]
)

logger = logging.getLogger("AI-COACH")
logger.info(f"Logging started. Log file: {log_filepath}")
