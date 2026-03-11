import logging
import os
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
