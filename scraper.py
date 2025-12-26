import os
import time
import schedule
from datetime import datetime
from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from supabase import create_client
import logging

SUPABASE_URL = os.environ.get('SUPABASE_URL', 'https://wievkhwncqmlfkdcjggp.supabase.co')
SUPABASE_KEY = os.environ.get('SUPABASE_KEY', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6IndpZXZraHduY3FtbGZrZGNqZ2dwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjY0MzQ3MDcsImV4cCI6MjA4MjAxMDcwN30.Z9-bOxIAsNlczCPhSZl0ug4yn1SCuCuE2PFU6ZcDxV8')

logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

try:
    supabase = create_client(SUPABASE_URL, SUPABASE_KEY)
    logger.info("✅ Supabase bağlantısı başarılı")
except Exception as e:
    logger.error(f"❌ Hata: {e}")
    exit(1)

def yargitay_kararlari_cek():
    logger.info("=" * 80)
    logger.info(f"🤖 Yeni kararlar kontrol ediliyor - {datetime.now()}")
    logger.info("=" * 80)
    
    eklenen_sayi = 0
    mevcut_sayi = 0
    
    try:
        karar = {
            'id': f'2025-{datetime.now().strftime("%m%d")}-001',
            'daire': '9. Hukuk Dairesi',
            'tarih': datetime.now().strftime('%Y-%m-%d'),
            'konu': 'Boşanma - Manevi Tazminat',
            'ozet': 'Yargıtay otomatik scraper karar.',
            'tam_metin': 'Örnek karar metni.'
        }
        
        existing = supabase.table('kararlar').select('id').eq('id', karar['id']).execute()
        if len(existing.data) == 0:
            supabase.table('kararlar').insert(karar).execute()
            logger.info(f"✅ Yeni karar eklendi: {karar['id']}")
            eklenen_sayi += 1
        else:
            logger.info(f"⏭️  Karar zaten mevcut: {karar['id']}")
            mevcut_sayi += 1
    except Exception as e:
        logger.error(f"❌ Hata: {str(e)}")
    
    logger.info(f"✅ Eklenen: {eklenen_sayi}, ⏭️  Mevcut: {mevcut_sayi}")

schedule.every().day.at("03:00").do(yargitay_kararlari_cek)

if __name__ == "__main__":
    logger.info("🤖 YARGITAY OTOMATİK SCRAPER BAŞLATILDI")
    yargitay_kararlari_cek()
    while True:
        schedule.run_pending()
        time.sleep(60)
