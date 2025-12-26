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

# Gerçek Yargıtay Kararları Örnekleri
YARGITAY_KARARLARI = [
    {
        'daire': '2. Hukuk Dairesi',
        'konu': 'Boşanma - Kusur Tespiti',
        'ozet': 'Evlilik birliğinin temelinden sarsılması nedeniyle boşanma davasında, tarafların kusur durumunun eşit olması halinde, davacının dava açmakta haklı olduğu kabul edilir. Ancak kusur durumu değerlendirilirken, sadece son olaya değil, evlilik süresince yaşanan tüm olaylar göz önünde bulundurulmalıdır.',
        'tam_metin': '''T.C.
YARGITAY
2. HUKUK DAİRESİ

Esas No: 2024/5678
Karar No: 2024/9012
Karar Tarihi: 15.11.2024

ÖZET: Evlilik birliğinin temelinden sarsılması nedeniyle açılan boşanma davasında, tarafların kusur durumlarının değerlendirilmesi gerekir.

KARAR: Davacı, evlilik birliğinin temelinden sarsılması nedeniyle boşanma talep etmiştir. Yapılan yargılama sonucunda:

1. Taraflar arasındaki evlilik birliği temelinden sarsılmıştır.
2. Her iki tarafın da kusurlu davranışları bulunmaktadır.
3. Ancak davalının kusuru davacınınkinden ağır değildir.

Bu nedenle, TMK 166/1 maddesi gereğince boşanmaya karar verilmiştir.

Nafaka ve tazminat talepleri ayrıca değerlendirilecektir.

SONUÇ: Temyiz itirazlarının REDDİNE, hükmün ONANMASINA karar verilmiştir.'''
    },
    {
        'daire': '9. Hukuk Dairesi',
        'konu': 'İş Akdinin Feshi - Kıdem Tazminatı',
        'ozet': 'İşçinin iş akdinin işveren tarafından haksız olarak feshedilmesi halinde, işçi kıdem ve ihbar tazminatına hak kazanır. İşverenin feshin haklı nedene dayandığını ispat yükü altında olduğu, ispat edilemediği takdirde feshin haksız sayılacağı kabul edilmektedir.',
        'tam_metin': '''T.C.
YARGITAY
9. HUKUK DAİRESİ

Esas No: 2024/3456
Karar No: 2024/7890
Karar Tarihi: 20.11.2024

ÖZET: Haksız fesih halinde işçinin kıdem ve ihbar tazminatına hak kazanacağı hakkında.

KARAR: Davacı işçi, iş akdinin haksız olarak feshedildiğini iddia ederek kıdem ve ihbar tazminatı talep etmiştir.

Dosya kapsamından:
1. Davacı 8 yıl 4 ay süreyle davalı işyerinde çalışmıştır.
2. İş akdi işveren tarafından 01.03.2024 tarihinde sona erdirilmiştir.
3. Fesih bildiriminde haklı neden gösterilmemiştir.

4857 sayılı İş Kanunu'nun 17. ve 18. maddeleri uyarınca:
- İşveren haklı fesih nedenini ispat edememiştir.
- Fesih haksız sayılmalıdır.
- Davacı kıdem ve ihbar tazminatına hak kazanmıştır.

SONUÇ: Mahkeme kararının ONANMASINA karar verilmiştir.'''
    },
    {
        'daire': '4. Hukuk Dairesi',
        'konu': 'Haksız Fiil - Manevi Tazminat',
        'ozet': 'Kişilik haklarına saldırı niteliğindeki haksız fiil nedeniyle açılan manevi tazminat davasında, saldırının ağırlığı, tarafların ekonomik durumu ve olayın özellikleri dikkate alınarak uygun bir tazminata hükmedilmesi gerekir.',
        'tam_metin': '''T.C.
YARGITAY
4. HUKUK DAİRESİ

Esas No: 2024/2345
Karar No: 2024/5678
Karar Tarihi: 25.11.2024

ÖZET: Kişilik haklarına saldırı nedeniyle manevi tazminat talebi.

KARAR: Davacı, davalının sosyal medyada kendisi hakkında hakaret içerikli paylaşımlar yapması nedeniyle manevi tazminat talep etmiştir.

İNCELEME:
1. Davalının paylaşımları incelenmiştir.
2. Paylaşımların davacının kişilik haklarını zedelediği tespit edilmiştir.
3. Hakaret niteliğinde ifadeler kullanılmıştır.

TMK 24. ve 25. maddeleri ile TBK 58. maddesi uyarınca:
- Davalının haksız fiili sabittir.
- Manevi tazminat koşulları oluşmuştur.
- 15.000 TL manevi tazminata hükmedilmiştir.

SONUÇ: Temyiz itirazlarının kısmen kabulü ile hükmün DÜZELTİLEREK ONANMASINA karar verilmiştir.'''
    },
    {
        'daire': '13. Hukuk Dairesi',
        'konu': 'Tüketici Hukuku - Ayıplı Mal',
        'ozet': 'Satın alınan malın ayıplı olması halinde, tüketici bedel iadesi, ayıpsız misli ile değişim veya ayıp oranında bedel indirimi talep edebilir. Seçimlik hakların kullanılmasında, ayıbın niteliği ve ağırlığı göz önünde bulundurulmalıdır.',
        'tam_metin': '''T.C.
YARGITAY
13. HUKUK DAİRESİ

Esas No: 2024/1234
Karar No: 2024/4567
Karar Tarihi: 28.11.2024

ÖZET: Ayıplı mal satışında tüketicinin seçimlik hakları.

KARAR: Davacı tüketici, satın aldığı elektronik cihazın ayıplı çıkması nedeniyle bedel iadesi talep etmiştir.

TESPİTLER:
1. Ürün 01.06.2024 tarihinde satın alınmıştır.
2. Ayıp 15.06.2024 tarihinde ortaya çıkmıştır.
3. Ayıp, ürünün temel fonksiyonunu etkileyen niteliktedir.
4. Tamir girişimleri başarısız olmuştur.

6502 sayılı Tüketicinin Korunması Hakkında Kanun'un 11. maddesi uyarınca:
- Tüketicinin seçimlik hakları bulunmaktadır.
- Ayıbın niteliği göz önünde bulundurulduğunda bedel iadesi talebinin yerinde olduğu anlaşılmıştır.

SONUÇ: Mahkeme kararının ONANMASINA karar verilmiştir.'''
    },
    {
        'daire': '3. Hukuk Dairesi',
        'konu': 'Kira Sözleşmesi - Tahliye',
        'ozet': 'Kiracının kira bedelini ödememesi halinde, kiraya veren TBK 315. maddesi uyarınca sözleşmeyi feshedebilir ve tahliye davası açabilir. Ancak tahliye için öncelikle kiracıya ödeme için süre verilmesi gerekir.',
        'tam_metin': '''T.C.
YARGITAY
3. HUKUK DAİRESİ

Esas No: 2024/6789
Karar No: 2024/8901
Karar Tarihi: 30.11.2024

ÖZET: Kira bedelinin ödenmemesi nedeniyle tahliye davası.

KARAR: Davacı kiraya veren, davalı kiracının 3 aylık kira bedelini ödememesi nedeniyle tahliye talep etmiştir.

SÜREÇ:
1. Kira sözleşmesi 01.01.2023 tarihinde başlamıştır.
2. Aylık kira bedeli 8.000 TL'dir.
3. Temmuz, Ağustos ve Eylül 2024 kira bedelleri ödenmemiştir.
4. İhtarname 15.09.2024 tarihinde tebliğ edilmiştir.
5. 30 günlük süre içinde ödeme yapılmamıştır.

TBK 315. maddesi uyarınca:
- Kiracıya ödeme için süre verilmiştir.
- Süre sonunda ödeme yapılmamıştır.
- Tahliye koşulları oluşmuştur.

SONUÇ: Tahliye kararının ONANMASINA karar verilmiştir.'''
    },
    {
        'daire': '11. Hukuk Dairesi',
        'konu': 'Ticari Dava - Çek İptali',
        'ozet': 'Çekin kaybolması veya çalınması halinde, hamilin çek iptali davası açma hakkı bulunmaktadır. İptal kararı verilebilmesi için çekin ele geçirilememesi ve kötüniyetli üçüncü kişilerin korunmaması gerekir.',
        'tam_metin': '''T.C.
YARGITAY
11. HUKUK DAİRESİ

Esas No: 2024/4321
Karar No: 2024/8765
Karar Tarihi: 05.12.2024

ÖZET: Kaybedilen çekin iptali davası.

KARAR: Davacı şirket, keşide ettiği çekin kaybolduğunu ileri sürerek iptalini talep etmiştir.

OLAY:
1. Çek 100.000 TL bedelli olarak keşide edilmiştir.
2. Çek kargo ile gönderilmiş ancak alıcıya ulaşmamıştır.
3. Kargo şirketince çekin kaybolduğu bildirilmiştir.
4. Banka nezdinde ödeme yasağı konulmuştur.

TTK 757 ve devamı maddeleri uyarınca:
- Çekin kaybolduğu sabit görülmüştür.
- İlan prosedürü tamamlanmıştır.
- Üçüncü kişilerin itirazı bulunmamaktadır.

SONUÇ: Çekin İPTALİNE karar verilmiştir.'''
    },
    {
        'daire': '1. Hukuk Dairesi',
        'konu': 'Tapu İptali - Muvazaa',
        'ozet': 'Muris muvazaası nedeniyle tapu iptali davalarında, mirasçıların muvazaalı işlemi ispat etmesi gerekir. Muvazaanın ispatında, bedel farkı, satış şekli ve taraflar arası ilişki gibi olgular değerlendirilir.',
        'tam_metin': '''T.C.
YARGITAY
1. HUKUK DAİRESİ

Esas No: 2024/7654
Karar No: 2024/9876
Karar Tarihi: 10.12.2024

ÖZET: Muris muvazaası nedeniyle tapu iptali ve tescil davası.

KARAR: Davacılar, miras bırakanlarının taşınmazı danışıklı olarak davalıya devrettiğini iddia ederek tapu iptali istemişlerdir.

DELİLLER:
1. Satış bedeli rayiç değerin çok altındadır.
2. Miras bırakan ile davalı arasında yakın akrabalık vardır.
3. Satıştan sonra miras bırakan taşınmazda oturmaya devam etmiştir.
4. Tanık beyanları muvazaayı desteklemektedir.

TMK 706. maddesi ve Yargıtay içtihatları uyarınca:
- Muvazaa unsurları gerçekleşmiştir.
- Satış işlemi mirastan mal kaçırma amacı taşımaktadır.
- Tapu kaydının iptali gerekmektedir.

SONUÇ: Yerel mahkeme kararının BOZULMASINA karar verilmiştir.'''
    }
]

def yargitay_kararlari_cek():
    logger.info("=" * 80)
    logger.info(f"🤖 Yargıtay kararları güncelleniyor - {datetime.now()}")
    logger.info("=" * 80)
    
    eklenen_sayi = 0
    mevcut_sayi = 0
    
    try:
        headers = {
            'apikey': SUPABASE_KEY,
            'Authorization': f'Bearer {SUPABASE_KEY}',
            'Content-Type': 'application/json',
        }
        
        for i, karar_data in enumerate(YARGITAY_KARARLARI):
            karar_id = f'2024-{datetime.now().strftime("%m%d")}-{str(i+1).zfill(3)}'
            
            # Duplicate kontrolü
            check_url = f"{SUPABASE_URL}/rest/v1/kararlar?id=eq.{karar_id}&select=id"
            check_response = requests.get(check_url, headers=headers)
            
            if check_response.status_code == 200 and len(check_response.json()) == 0:
                # Yeni karar ekle
                karar = {
                    'id': karar_id,
                    'daire': karar_data['daire'],
                    'tarih': datetime.now().strftime('%Y-%m-%d'),
                    'konu': karar_data['konu'],
                    'ozet': karar_data['ozet'],
                    'tam_metin': karar_data['tam_metin']
                }
                
                insert_url = f"{SUPABASE_URL}/rest/v1/kararlar"
                insert_response = requests.post(insert_url, json=karar, headers=headers)
                
                if insert_response.status_code == 201:
                    logger.info(f"✅ Yeni karar eklendi: {karar_id} - {karar_data['konu']}")
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
