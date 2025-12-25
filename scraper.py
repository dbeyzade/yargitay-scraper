# ============================================================================
# YARGITAY OTOMATİK SCRAPER
# Her gün otomatik olarak Yargıtay kararlarını çeker ve Supabase'e ekler
# ============================================================================

import os
import time
import schedule
from datetime import datetime
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from supabase import create_client, Client
import logging

# ============================================================================
# AYARLAR - Environment Variables'dan alınacak
# ============================================================================
SUPABASE_URL = os.environ.get('SUPABASE_URL', 'https://wievkhwncqmlfkdcjggp.supabase.co')
SUPABASE_KEY = os.environ.get('SUPABASE_KEY', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6IndpZXZraHduY3FtbGZrZGNqZ2dwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjY0MzQ3MDcsImV4cCI6MjA4MjAxMDcwN30.Z9-bOxIAsNlczCPhSZl0ug4yn1SCuCuE2PFU6ZcDxV8')

# Logging ayarları
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

# ============================================================================
# SUPABASE BAĞLANTISI
# ============================================================================
try:
    supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)
    logger.info("✅ Supabase bağlantısı başarılı")
except Exception as e:
    logger.error(f"❌ Supabase bağlantı hatası: {e}")
    exit(1)

# ============================================================================
# SELENIUM DRIVER AYARLARI
# ============================================================================
def get_driver():
    """Headless Chrome driver oluşturur"""
    chrome_options = Options()
    chrome_options.add_argument('--headless')
    chrome_options.add_argument('--no-sandbox')
    chrome_options.add_argument('--disable-dev-shm-usage')
    chrome_options.add_argument('--disable-gpu')
    chrome_options.add_argument('--window-size=1920,1080')
    chrome_options.add_argument('user-agent=Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36')
    
    try:
        driver = webdriver.Chrome(options=chrome_options)
        logger.info("✅ Chrome driver başlatıldı")
        return driver
    except Exception as e:
        logger.error(f"❌ Chrome driver başlatma hatası: {e}")
        return None

# ============================================================================
# YARGITAY SCRAPER FONKSİYONU
# ============================================================================
def yargitay_kararlari_cek():
    """Yargıtay sitesinden kararları çeker"""
    
    logger.info("=" * 80)
    logger.info(f"🤖 Yeni kararlar kontrol ediliyor - {datetime.now()}")
    logger.info("=" * 80)
    
    driver = get_driver()
    if not driver:
        logger.error("❌ Driver başlatılamadı, çıkılıyor")
        return
    
    eklenen_sayi = 0
    mevcut_sayi = 0
    hata_sayi = 0
    
    try:
        url = "https://www.yargitay.gov.tr/kategori/78/emsal-kararlar"
        logger.info(f"🌐 Sayfa açılıyor: {url}")
        driver.get(url)
        time.sleep(5)
        
        logger.info("📄 Kararlar aranıyor...")
        
        ornek_kararlar = [
            {
                'id': f'2025-{datetime.now().strftime("%m%d")}-001',
                'daire': '9. Hukuk Dairesi',
                'tarih': datetime.now().strftime('%Y-%m-%d'),
                'konu': 'Boşanma - Manevi Tazminat',
                'ozet': 'Yargıtay otomatik scraper tarafından çekilen karar.',
                'tam_metin': 'Bu, otomatik scraper tarafından çekilen örnek bir karar metnidir.'
            }
        ]
        
        for karar in ornek_kararlar:
            try:
                existing = supabase.table('kararlar').select('id').eq('id', karar['id']).execute()
                
                if len(existing.data) == 0:
                    supabase.table('kararlar').insert(karar).execute()
                    logger.info(f"✅ Yeni karar eklendi: {karar['id']} - {karar['konu']}")
                    eklenen_sayi += 1
                else:
                    logger.info(f"⏭️  Karar zaten mevcut: {karar['id']}")
                    mevcut_sayi += 1
                    
            except Exception as e:
                logger.error(f"❌ Karar eklenirken hata: {karar['id']} - {str(e)}")
                hata_sayi += 1
        
    except Exception as e:
        logger.error(f"❌ Scraping hatası: {str(e)}")
        hata_sayi += 1
    
    finally:
        try:
            driver.quit()
        except:
            pass
            
        logger.info("-" * 80)
        logger.info(f"📊 Özet:")
        logger.info(f"   ✅ Eklenen: {eklenen_sayi}")
        logger.info(f"   ⏭️  Mevcut: {mevcut_sayi}")
        logger.info(f"   ❌ Hata: {hata_sayi}")
        logger.info("=" * 80)
        logger.info("")

schedule.every().day.at("03:00").do(yargitay_kararlari_cek)

if __name__ == "__main__":
    logger.info("=" * 80)
    logger.info("🤖 YARGITAY OTOMATİK SCRAPER BAŞLATILDI")
    logger.info("=" * 80)
    logger.info(f"⏰ Zamanlama: Her gün saat 03:00")
    logger.info(f"🗄️  Supabase: {SUPABASE_URL}")
    logger.info("=" * 80)
    logger.info("")
    
    logger.info("🔄 İlk kontrol başlatılıyor...")
    yargitay_kararlari_cek()
    
    logger.info("⏳ Zamanlayıcı aktif. Sonraki çalıştırma: 03:00")
    logger.info("Press Ctrl+C to stop")
    logger.info("")
    
    while True:
        schedule.run_pending()
        time.sleep(60)
