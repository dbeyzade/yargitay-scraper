import os
import time
import schedule
import requests
from datetime import datetime
import logging
import json

SUPABASE_URL = os.environ.get('SUPABASE_URL', 'https://wievkhwncqmlfkdcjggp.supabase.co')
SUPABASE_KEY = os.environ.get('SUPABASE_KEY', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6IndpZXZraHduY3FtbGZrZGNqZ2dwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjY0MzQ3MDcsImV4cCI6MjA4MjAxMDcwN30.Z9-bOxIAsNlczCPhSZl0ug4yn1SCuCuE2PFU6ZcDxV8')

logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

def yargitay_kararlari_cek():
    logger.info("=" * 80)
    logger.info(f"🤖 Yeni kararlar kontrol ediliyor - {datetime.now()}")
    logger.info("=" * 80)
    
    eklenen_sayi = 0
    mevcut_sayi = 0
    
    try:
        headers = {
            'apikey': SUPABASE_KEY,
            'Authorization': f'Bearer {SUPABASE_KEY}',
            'Content-Type': 'application/json',
        }
        
        karar_id = f'2025-{datetime.now().strftime("%m%d")}-001'
        
        # Duplicate kontrolü
        check_url = f"{SUPABASE_URL}/rest/v1/kararlar?id=eq.{karar_id}&select=id"
        check_response = requests.get(check_url, headers=headers)
        
        if check_response.status_code == 200 and len(check_response.json()) == 0:
            # Yeni karar ekle
            karar = {
                'id': karar_id,
                'daire': '9. Hukuk Dairesi',
                'tarih': datetime.now().strftime('%Y-%m-%d'),
                'konu': 'Boşanma - Manevi Tazminat',
                'ozet': 'Yargıtay otomatik scraper karar.',
                'tam_metin': 'Örnek karar metni.'
            }
            
            insert_url = f"{SUPABASE_URL}/rest/v1/kararlar"
            insert_response = requests.post(insert_url, json=karar, headers=headers)
            
            if insert_response.status_code == 201:
                logger.info(f"✅ Yeni karar eklendi: {karar_id}")
                eklenen_sayi += 1
            else:
                logger.error(f"❌ Insert hatası: {insert_response.text}")
        else:
            logger.info(f"⏭️  Karar zaten mevcut: {karar_id}")
            mevcut_sayi += 1
            
    except Exception as e:
        logger.error(f"❌ Hata: {str(e)}")
    
    logger.info(f"✅ Eklenen: {eklenen_sayi}, ⏭️  Mevcut: {mevcut_sayi}")
    logger.info("=" * 80)

schedule.every().day.at("03:00").do(yargitay_kararlari_cek)

if __name__ == "__main__":
    logger.info("🤖 YARGITAY OTOMATİK SCRAPER BAŞLATILDI")
    yargitay_kararlari_cek()
    while True:
        schedule.run_pending()
        time.sleep(60)
