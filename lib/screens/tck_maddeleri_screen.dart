import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:animate_do/animate_do.dart';
import '../theme/app_theme.dart';
import 'legal_category_detail_screen.dart';

class TckMaddeleriScreen extends StatefulWidget {
  const TckMaddeleriScreen({super.key});

  @override
  State<TckMaddeleriScreen> createState() => _TckMaddeleriScreenState();
}

class _TckMaddeleriScreenState extends State<TckMaddeleriScreen>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  int? _selectedKisimIndex;
  late AnimationController _glowController;

  // TCK Ana Kısımlar - TAM METİN
  final List<Map<String, dynamic>> _kisimlar = [
    {
      'baslik': 'Temel İlkeler',
      'alt': 'Madde 1-19',
      'emoji': '⚖️',
      'icon': Icons.balance,
      'color': const Color(0xFFFFD700),
      'maddeler': [
        {
          'no': '1',
          'baslik': 'Ceza Kanununun amacı',
          'icerik': '''(1) Ceza Kanununun amacı; kişi hak ve özgürlüklerini, kamu düzen ve güvenliğini, hukuk devletini, kamu sağlığını ve çevreyi, toplum barışını korumak, suç işlenmesini önlemektir. Kanunda, bu amacın gerçekleştirilmesi için ceza sorumluluğunun temel esasları ile suçlar, ceza ve güvenlik tedbirlerinin türleri düzenlenmiştir.'''
        },
        {
          'no': '2',
          'baslik': 'Suçta ve cezada kanunilik ilkesi',
          'icerik': '''(1) Kanunun açıkça suç saymadığı bir fiil için kimseye ceza verilemez ve güvenlik tedbiri uygulanamaz. Kanunda yazılı cezalardan ve güvenlik tedbirlerinden başka bir ceza ve güvenlik tedbirine hükmolunamaz.
(2) İdarenin düzenleyici işlemleriyle suç ve ceza konulamaz.
(3) Kanunların suç ve ceza içeren hükümlerinin uygulanmasında kıyas yapılamaz. Suç ve ceza içeren hükümler, kıyasa yol açacak biçimde geniş yorumlanamaz.'''
        },
        {
          'no': '3',
          'baslik': 'Adalet ve kanun önünde eşitlik ilkesi',
          'icerik': '''(1) Suç işleyen kişi hakkında işlenen fiilin ağırlığıyla orantılı ceza ve güvenlik tedbirine hükmolunur.
(2) Ceza Kanununun uygulamasında kişiler arasında ırk, dil, din, mezhep, milliyet, renk, cinsiyet, siyasal veya diğer fikir yahut düşünceleri, felsefi inanç, milli veya sosyal köken, doğum, ekonomik ve diğer toplumsal konumları yönünden ayrım yapılamaz ve hiçbir kimseye ayrıcalık tanınamaz.'''
        },
        {
          'no': '4',
          'baslik': 'Kanunun bağlayıcılığı',
          'icerik': '''(1) Ceza kanunlarını bilmemek mazeret sayılmaz.
(2) Ancak sakınamayacağı bir hata nedeniyle kanunu bilmediği için meşru sanarak bir suç işleyen kimse cezaen sorumlu olmaz.'''
        },
        {
          'no': '5',
          'baslik': 'Özel kanunlarla ilişki',
          'icerik': '''(1) Bu Kanunun genel hükümleri, özel ceza kanunları ve ceza içeren kanunlardaki suçlar hakkında da uygulanır.'''
        },
        {
          'no': '6',
          'baslik': 'Tanımlar',
          'icerik': '''(1) Ceza kanunlarının uygulanmasında;
a) Vatandaş deyiminden; fiili işlediği sırada Türk vatandaşı olan kişi,
b) Çocuk deyiminden; henüz onsekiz yaşını doldurmamış kişi,
c) Kamu görevlisi deyiminden; kamusal faaliyetin yürütülmesine atama veya seçilme yoluyla ya da herhangi bir surette sürekli, süreli veya geçici olarak katılan kişi,
d) Yargı görevi yapan deyiminden; yüksek mahkemeler, adlî ve idarî mahkemeler üye ve hakimleri ile Cumhuriyet savcısı ve avukatlar,
e) Gece vakti deyiminden; güneşin batmasından bir saat sonra başlayan ve doğmasından bir saat evvele kadar devam eden zaman süresi,
f) Silah deyiminden;
1. Ateşli silahlar,
2. Patlayıcı maddeler,
3. Saldırı ve savunmada kullanılmak üzere yapılmış her türlü kesici, delici veya bereleyici alet,
4. Saldırı ve savunma amacıyla yapılmış olmasa bile fiilen saldırı ve savunmada kullanılmaya elverişli diğer şeyler,
5. Yakıcı, aşındırıcı, yaralayıcı, boğucu, zehirleyici, sürekli hastalığa yol açıcı nükleer, radyoaktif, kimyasal, biyolojik maddeler,
g) Basın ve yayın yolu ile deyiminden; her türlü yazılı, görsel, işitsel ve elektronik kitle iletişim aracıyla yapılan yayınlar,
h) İtiyadi suçlu deyiminden; kasıtlı bir suçun temel şeklini ya da daha ağır veya daha az cezayı gerektiren nitelikli şekillerini bir yıl içinde ve farklı zamanlarda ikiden fazla işleyen kişi,
i) Suçu meslek edinen kişi deyiminden; kısmen de olsa geçimini suçtan elde ettiği kazançla sağlamaya alışmış kişi,
j) Örgüt mensubu suçlu deyiminden; bir suç örgütünü kuran, yöneten, örgüte katılan veya örgüt adına diğerleriyle birlikte veya tek başına suç işleyen kişi,
Anlaşılır.'''
        },
        {
          'no': '7',
          'baslik': 'Zaman bakımından uygulama',
          'icerik': '''(1) İşlendiği zaman yürürlükte bulunan kanuna göre suç sayılmayan bir fiilden dolayı kimseye ceza verilemez ve güvenlik tedbiri uygulanamaz. İşlendikten sonra yürürlüğe giren kanuna göre suç sayılmayan bir fiilden dolayı da kimse cezalandırılamaz ve hakkında güvenlik tedbiri uygulanamaz. Böyle bir ceza veya güvenlik tedbiri hükmolunmuşsa infazı ve kanuni neticeleri kendiliğinden kalkar.
(2) Suçun işlendiği zaman yürürlükte bulunan kanun ile sonradan yürürlüğe giren kanunların hükümleri farklı ise, failin lehine olan kanun uygulanır ve infaz olunur.
(3) Hapis cezasının ertelenmesi, koşullu salıverilme ve tekerrürle ilgili olanlar hariç; infaz rejimine ilişkin hükümler, derhal uygulanır.
(4) Geçici veya süreli kanunların, yürürlükte bulundukları süre içinde işlenmiş olan suçlar hakkında uygulanmasına devam edilir.'''
        },
        {
          'no': '8',
          'baslik': 'Yer bakımından uygulama',
          'icerik': '''(1) Türkiye'de işlenen suçlar hakkında Türk kanunları uygulanır. Fiilin kısmen veya tamamen Türkiye'de işlenmesi veya neticenin Türkiye'de gerçekleşmesi halinde suç, Türkiye'de işlenmiş sayılır.
(2) Suç;
a) Türk kara ve hava sahaları ile Türk karasularında,
b) Açık denizde ve bunun üzerindeki hava sahasında, Türk deniz ve hava araçlarında veya bu araçlarla,
c) Türk deniz ve hava savaş araçlarında veya bu araçlarla,
d) Türkiye'nin kıt'a sahanlığında veya münhasır ekonomik bölgesinde tesis edilmiş sabit platformlarda veya bunlara karşı,
İşlendiğinde Türkiye'de işlenmiş sayılır.'''
        },
        {
          'no': '9',
          'baslik': 'Yabancı ülkede hüküm verilmesi',
          'icerik': '''(1) Türkiye'de işlediği suçtan dolayı yabancı ülkede hakkında hüküm verilmiş olan kimse, Türkiye'de yeniden yargılanır.'''
        },
        {
          'no': '10',
          'baslik': 'Görev suçları',
          'icerik': '''(1) Yabancı ülkede Türkiye namına memuriyet veya görev üstlenmiş olup da bundan dolayı bir suç işleyen kimse, bu fiile ilişkin olarak yabancı ülkede hakkında mahkumiyet hükmü verilmiş bulunsa bile, Türkiye'de yeniden yargılanır.'''
        },
        {
          'no': '11',
          'baslik': 'Vatandaş tarafından işlenen suç',
          'icerik': '''(1) Bir Türk vatandaşı, 13 üncü maddede yazılı suçlar dışında, Türk kanunlarına göre aşağı sınırı bir yıldan az olmayan hapis cezasını gerektiren bir suçu yabancı ülkede işlediği ve kendisi Türkiye'de bulunduğu takdirde, bu suçtan dolayı yabancı ülkede hüküm verilmemiş olması ve Türkiye'de kovuşturulabilirliğin bulunması koşulu ile Türk kanunlarına göre cezalandırılır.
(2) Suç, aşağı sınırı bir yıldan az hapis veya adlî para cezasını gerektirdiğinde yargılama yapılması zarar görenin veya yabancı hükümetin şikayetine bağlıdır. Bu durumda şikayet, vatandaşın Türkiye'ye girdiği tarihten itibaren altı ay içinde yapılmalıdır.'''
        },
        {
          'no': '12',
          'baslik': 'Yabancı tarafından işlenen suç',
          'icerik': '''(1) Bir yabancı, 13 üncü maddede yazılı suçlar dışında, Türk kanunlarına göre aşağı sınırı en az bir yıl hapis cezasını gerektiren bir suçu yabancı ülkede Türkiye'nin zararına işlediği ve kendisi Türkiye'de bulunduğu takdirde, Türk kanunlarına göre cezalandırılır. Yargılama yapılması Adalet Bakanının istemine bağlıdır.
(2) Yukarıdaki fıkrada belirtilen suçun bir Türk vatandaşının zararına işlenmesi ve failin Türkiye'de bulunması halinde, bu suçtan dolayı yabancı ülkede hüküm verilmemiş olması koşuluyla, Türk vatandaşının şikayeti üzerine fail, Türk kanunlarına göre cezalandırılır.
(3) Mağdur yabancı ise, aşağıdaki koşulların varlığı halinde fail, Adalet Bakanının istemi ile yargılanır:
a) Suçun, Türk kanunlarına göre aşağı sınırı üç yıldan az olmayan hapis cezasını gerektirmesi.
b) Geri verme isteminin bulunmaması veya geri verme isteminin kabul edilmemiş olması.'''
        },
        {
          'no': '13',
          'baslik': 'Diğer suçlar',
          'icerik': '''(1) Aşağıdaki suçların, vatandaş veya yabancı tarafından, yabancı ülkede işlenmesi halinde, Türk kanunları uygulanır:
a) İkinci Kitap, Birinci Kısım altında yer alan suçlar.
b) İkinci Kitap, Dördüncü Kısım altındaki Üçüncü, Dördüncü, Beşinci, Altıncı, Yedinci ve Sekizinci Bölümlerde yer alan suçlar.
c) İşkence (madde 94, 95).
d) Çevrenin kasten kirletilmesi (madde 181).
e) Uyuşturucu veya uyarıcı madde imal ve ticareti (madde 188), uyuşturucu veya uyarıcı madde kullanılmasını kolaylaştırma (madde 190).
f) Parada sahtecilik (madde 197), para ve kıymetli damgaları imale yarayan araçların üretimi ve ticareti (madde 200), mühürde sahtecilik (madde 202).
g) Fuhuş (madde 227).
h) (Mülga: 26/6/2009 – 5765/3 md.)
ı) Deniz, demiryolu veya havayolu ulaşım araçlarının kaçırılması veya alıkonulması (madde 223, ikinci ve üçüncü fıkra) ya da bu araçlara karşı işlenen zarar verme (madde 152) suçları.'''
        },
        {
          'no': '14',
          'baslik': 'Seçimlik cezalarda soruşturma',
          'icerik': '''(Mülga: 6/12/2006 – 5560/1 md.)'''
        },
        {
          'no': '15',
          'baslik': 'Soruşturma ve kovuşturma',
          'icerik': '''(Mülga: 6/12/2006 – 5560/1 md.)'''
        },
        {
          'no': '16',
          'baslik': 'Geri verme',
          'icerik': '''(1) Yabancı bir ülkede işlenen veya işlendiği iddia edilen bir suç nedeniyle hakkında ceza kovuşturması başlatılan veya mahkumiyet kararı verilmiş olan bir yabancı, talep üzerine, kovuşturmanın yapılabilmesi veya hükmedilen cezanın infazı amacıyla geri verilebilir. Geri vermeye, Türkiye Büyük Millet Meclisinin onayladığı uluslararası sözleşmelerdeki koşullar çerçevesinde yetkili mahkeme tarafından karar verilir.
(2) Uluslararası Ceza Divanına taraf olmanın gerektirdiği yükümlülükler hariç olmak üzere; vatandaş, suç sebebiyle yabancı bir ülkeye verilemez.
(3) Vatandaşlık, suçun işlendiği tarih itibarıyla belirlenir.'''
        },
        {
          'no': '17',
          'baslik': 'Türkiye\'de yargılama',
          'icerik': '''(1) Bir suç nedeniyle yabancı ülkede mahkumiyet veya beraat kararı verilmiş olsa bile, Adalet Bakanının talebi üzerine Türkiye'de yargılama yapılır. Ancak, yabancı ülkede;
a) Mahkumiyet kararı verilmiş ve infaz edilmiş olan suç nedeniyle, fail hakkında ayrıca ceza verilemez.
b) Mahkumiyet kararı verilmiş ve fakat infaz edilmemiş veya kısmen infaz edilmiş olan suç nedeniyle, verilecek cezadan mahkum kalınan ceza süresi indirilir.'''
        },
        {
          'no': '18',
          'baslik': 'Geri vermede ayrıklık',
          'icerik': '''(1) Geri verme talebi kabul edilmediğinde, suç, Türkiye'de Adalet Bakanının talebi üzerine kovuşturulur.'''
        },
        {
          'no': '19',
          'baslik': 'Vatandaşlığa alınma',
          'icerik': '''(1) Türkiye'de aranan bir suç nedeniyle hakkında Türk kanunlarına göre ceza kovuşturması başlatılmış olan kişinin Türk vatandaşlığına alınması, kovuşturma ve hükmolunan cezanın infazına engel olmaz.'''
        },
      ],
    },
    {
      'baslik': 'Ceza Sorumluluğu',
      'alt': 'Madde 20-34',
      'emoji': '👤',
      'icon': Icons.person_pin,
      'color': const Color(0xFF00CED1),
      'maddeler': [
        {
          'no': '20',
          'baslik': 'Ceza sorumluluğunun şahsiliği',
          'icerik': '''(1) Ceza sorumluluğu şahsidir. Kimse başkasının fiilinden dolayı sorumlu tutulamaz.
(2) Tüzel kişiler hakkında ceza yaptırımı uygulanamaz. Ancak, suç dolayısıyla kanunda öngörülen güvenlik tedbiri niteliğindeki yaptırımlar saklıdır.'''
        },
        {
          'no': '21',
          'baslik': 'Kast',
          'icerik': '''(1) Suçun oluşması kastın varlığına bağlıdır. Kast, suçun kanuni tanımındaki unsurların bilerek ve istenerek gerçekleştirilmesidir.
(2) Kişinin, suçun kanuni tanımındaki unsurların gerçekleşebileceğini öngörmesine rağmen, fiili işlemesi halinde olası kast vardır. Bu halde, ağırlaştırılmış müebbet hapis cezasını gerektiren suçlarda müebbet hapis cezasına, müebbet hapis cezasını gerektiren suçlarda yirmi yıldan yirmibeş yıla kadar hapis cezasına hükmolunur; diğer suçlarda ise temel ceza üçte birden yarısına kadar indirilir.'''
        },
        {
          'no': '22',
          'baslik': 'Taksir',
          'icerik': '''(1) Taksirle işlenen fiiller, kanunun açıkça belirttiği hallerde cezalandırılır.
(2) Taksir, dikkat ve özen yükümlülüğüne aykırılık dolayısıyla, bir davranışın suçun kanuni tanımında belirtilen neticesi öngörülmeyerek gerçekleştirilmesidir.
(3) Kişinin öngördüğü neticeyi istememesine karşın, neticenin meydana gelmesi halinde bilinçli taksir vardır; bu halde taksirli suça ilişkin ceza üçte birden yarısına kadar artırılır.
(4) Taksirle işlenen suçtan dolayı verilecek olan ceza failin kusuruna göre belirlenir.
(5) Birden fazla kişinin taksirle işlediği suçlarda, herkes kendi kusurundan dolayı sorumlu olur. Her failin cezası kusuruna göre ayrı ayrı belirlenir.
(6) Taksirli hareket sonucu neden olunan netice, münhasıran failin kişisel ve ailevi durumu bakımından, artık bir cezanın hükmedilmesini gereksiz kılacak derecede mağdur olmasına yol açmışsa ceza verilmez; bilinçli taksir halinde verilecek ceza yarıdan altıda bire kadar indirilebilir.'''
        },
        {
          'no': '23',
          'baslik': 'Netice sebebiyle ağırlaşmış suç',
          'icerik': '''(1) Bir fiilin, kastedilenden daha ağır veya başka bir neticenin oluşumuna sebebiyet vermesi halinde, kişinin bundan dolayı sorumlu tutulabilmesi için bu netice bakımından en azından taksirle hareket etmesi gerekir.'''
        },
        {
          'no': '24',
          'baslik': 'Kanunun hükmü ve amirin emri',
          'icerik': '''(1) Kanunun hükmünü yerine getiren kimseye ceza verilmez.
(2) Yetkili bir merciden verilip, yerine getirilmesi görev gereği zorunlu olan bir emri uygulayan sorumlu olmaz.
(3) Konusu suç teşkil eden emir hiçbir surette yerine getirilemez. Aksi takdirde yerine getiren ile emri veren sorumlu olur.
(4) Emrin, hukuka uygunluğunun denetlenmesinin kanun tarafından engellendiği hallerde, yerine getirilmesinden emri veren sorumlu olur.'''
        },
        {
          'no': '25',
          'baslik': 'Meşru savunma ve zorunluluk hali',
          'icerik': '''(1) Gerek kendisine ve gerek başkasına ait bir hakka yönelmiş, gerçekleşen, gerçekleşmesi veya tekrarı muhakkak olan haksız bir saldırıyı o anda hal ve koşullara göre saldırı ile orantılı biçimde defetmek zorunluluğu ile işlenen fiillerden dolayı faile ceza verilmez.
(2) Gerek kendisine gerek başkasına ait bir hakka yönelik olup, bilerek neden olmadığı ve başka suretle korunmak olanağı bulunmayan ağır ve muhakkak bir tehlikeden kurtulmak veya başkasını kurtarmak zorunluluğu ile ve tehlikenin ağırlığı ile konu ve kullanılan vasıta arasında orantı bulunmak koşulu ile işlenen fiillerden dolayı faile ceza verilmez.'''
        },
        {
          'no': '26',
          'baslik': 'Hakkın kullanılması ve ilgilinin rızası',
          'icerik': '''(1) Hakkını kullanan kimseye ceza verilmez.
(2) Kişinin üzerinde mutlak surette tasarruf edebileceği bir hakkına ilişkin olmak üzere, açıkladığı rızası çerçevesinde işlenen fiilden dolayı kimseye ceza verilmez.'''
        },
        {
          'no': '27',
          'baslik': 'Sınırın aşılması',
          'icerik': '''(1) Ceza sorumluluğunu kaldıran nedenlerde sınırın kast olmaksızın aşılması halinde, fiil taksirle işlendiğinde de cezalandırılıyorsa, taksirli suç için kanunda yazılı cezanın altıda birinden üçte birine kadarı indirilerek hükmolunur.
(2) Meşru savunmada sınırın aşılması mazur görülebilecek bir heyecan, korku veya telaştan ileri gelmiş ise faile ceza verilmez.'''
        },
        {
          'no': '28',
          'baslik': 'Cebir ve şiddet, korkutma ve tehdit',
          'icerik': '''(1) Karşı koyamayacağı veya kurtulamayacağı cebir ve şiddet veya muhakkak ve ağır bir korkutma veya tehdit sonucu suç işleyen kimseye ceza verilmez. Bu gibi hallerde cebir ve şiddet, korkutma ve tehdidi kullanan kişi suçun faili sayılır.'''
        },
        {
          'no': '29',
          'baslik': 'Haksız tahrik',
          'icerik': '''(1) Haksız bir fiilin meydana getirdiği hiddet veya şiddetli elemin etkisi altında suç işleyen kimseye, ağırlaştırılmış müebbet hapis cezası yerine onsekiz yıldan yirmidört yıla ve müebbet hapis cezası yerine oniki yıldan onsekiz yıla kadar hapis cezası verilir. Diğer hallerde verilecek cezanın dörtte birinden dörtte üçüne kadarı indirilir.'''
        },
        {
          'no': '30',
          'baslik': 'Hata',
          'icerik': '''(1) Fiilin icrası sırasında suçun kanuni tanımındaki maddi unsurları bilmeyen bir kimse, kasten hareket etmiş olmaz. Bu hata dolayısıyla taksirli sorumluluk hali saklıdır.
(2) Bir suçun daha ağır veya daha az cezayı gerektiren nitelikli hallerinin gerçekleştiği hususunda hataya düşen kişi, bu hatasından yararlanır.
(3) Ceza sorumluluğunu kaldıran veya azaltan nedenlere ait koşulların gerçekleştiği hususunda kaçınılmaz bir hataya düşen kişi, bu hatasından yararlanır.
(4) İşlediği fiilin haksızlık oluşturduğu hususunda kaçınılmaz bir hataya düşen kişi, cezalandırılmaz.'''
        },
        {
          'no': '31',
          'baslik': 'Yaş küçüklüğü',
          'icerik': '''(1) Fiili işlediği sırada oniki yaşını doldurmamış olan çocukların ceza sorumluluğu yoktur. Bu kişiler hakkında, ceza kovuşturması yapılamaz; ancak, çocuklara özgü güvenlik tedbirleri uygulanabilir.
(2) Fiili işlediği sırada oniki yaşını doldurmuş olup da onbeş yaşını doldurmamış olanların işlediği fiilin hukuki anlam ve sonuçlarını algılayamaması veya davranışlarını yönlendirme yeteneğinin yeterince gelişmemiş olması halinde ceza sorumluluğu yoktur. Ancak bu kişiler hakkında çocuklara özgü güvenlik tedbirlerine hükmolunur. İşlediği fiilin hukuki anlam ve sonuçlarını algılama ve bu fiille ilgili olarak davranışlarını yönlendirme yeteneğinin varlığı halinde, bu kişiler hakkında suç, ağırlaştırılmış müebbet hapis cezasını gerektirdiği takdirde oniki yıldan onbeş yıla; müebbet hapis cezasını gerektirdiği takdirde dokuz yıldan onbir yıla kadar hapis cezasına hükmolunur. Diğer cezaların yarısı indirilir ve bu halde her fiil için verilecek hapis cezası yedi yıldan fazla olamaz.
(3) Fiili işlediği sırada onbeş yaşını doldurmuş olup da onsekiz yaşını doldurmamış olan kişiler hakkında suç, ağırlaştırılmış müebbet hapis cezasını gerektirdiği takdirde onsekiz yıldan yirmidört yıla; müebbet hapis cezasını gerektirdiği takdirde oniki yıldan onbeş yıla kadar hapis cezasına hükmolunur. Diğer cezaların üçte biri indirilir ve bu halde her fiil için verilecek hapis cezası oniki yıldan fazla olamaz.'''
        },
        {
          'no': '32',
          'baslik': 'Akıl hastalığı',
          'icerik': '''(1) Akıl hastalığı nedeniyle, işlediği fiilin hukuki anlam ve sonuçlarını algılayamayan veya bu fiille ilgili olarak davranışlarını yönlendirme yeteneği önemli derecede azalmış olan kişiye ceza verilmez. Ancak, bu kişiler hakkında güvenlik tedbirine hükmolunur.
(2) Birinci fıkrada yazılı derecede olmamakla birlikte işlediği fiille ilgili olarak davranışlarını yönlendirme yeteneği azalmış olan kişiye, ağırlaştırılmış müebbet hapis cezası yerine yirmibeş yıl, müebbet hapis cezası yerine yirmi yıl hapis cezası verilir. Diğer hallerde verilecek ceza, altıda birden fazla olmamak üzere indirilebilir. Mahkum olunan ceza, süresi aynı olmak koşuluyla, kısmen veya tamamen, akıl hastalarına özgü güvenlik tedbiri olarak da uygulanabilir.'''
        },
        {
          'no': '33',
          'baslik': 'Sağır ve dilsizlik',
          'icerik': '''(1) Bu Kanunun, fiili işlediği sırada oniki yaşını doldurmamış olan çocuklara ilişkin hükümleri, onbeş yaşını doldurmamış olan sağır ve dilsizler hakkında; oniki yaşını doldurmuş olup da onbeş yaşını doldurmamış olanlara ilişkin hükümleri, onbeş yaşını doldurmuş olup da onsekiz yaşını doldurmamış olan sağır ve dilsizler hakkında; onbeş yaşını doldurmuş olup da onsekiz yaşını doldurmamış olanlara ilişkin hükümleri, onsekiz yaşını doldurmuş olup da yirmibir yaşını doldurmamış olan sağır ve dilsizler hakkında da uygulanır.'''
        },
        {
          'no': '34',
          'baslik': 'Geçici nedenler, alkol veya uyuşturucu',
          'icerik': '''(1) Geçici bir nedenle ya da irade dışı alınan alkol veya uyuşturucu madde nedeniyle, işlediği fiilin hukuki anlam ve sonuçlarını algılayamayan veya bu fiille ilgili olarak davranışlarını yönlendirme yeteneği önemli derecede azalmış olan kişiye ceza verilmez.
(2) İradi olarak alınan alkol veya uyuşturucu madde etkisinde suç işleyen kişi hakkında birinci fıkra hükmü uygulanmaz.'''
        },
      ],
    },
    {
      'baslik': 'Suça Teşebbüs & İştirak',
      'alt': 'Madde 35-44',
      'emoji': '👥',
      'icon': Icons.people_alt,
      'color': const Color(0xFFFF6B6B),
      'maddeler': [
        {
          'no': '35',
          'baslik': 'Suça teşebbüs',
          'icerik': '''(1) Kişi, işlemeyi kastettiği bir suçu elverişli hareketlerle doğrudan doğruya icraya başlayıp da elinde olmayan nedenlerle tamamlayamaz ise teşebbüsten dolayı sorumlu tutulur.
(2) Suça teşebbüs halinde fail, meydana gelen zarar veya tehlikenin ağırlığına göre, ağırlaştırılmış müebbet hapis cezası yerine onüç yıldan yirmi yıla kadar, müebbet hapis cezası yerine dokuz yıldan onbeş yıla kadar hapis cezası ile cezalandırılır. Diğer hallerde verilecek cezanın dörtte birinden dörtte üçüne kadarı indirilir.'''
        },
        {
          'no': '36',
          'baslik': 'Gönüllü vazgeçme',
          'icerik': '''(1) Fail, suçun icra hareketlerinden gönüllü vazgeçer veya kendi çabalarıyla suçun tamamlanmasını veya neticenin gerçekleşmesini önlerse, teşebbüsten dolayı cezalandırılmaz; fakat tamam olan kısım esasen bir suç oluşturduğu takdirde, sadece o suça ait ceza ile cezalandırılır.'''
        },
        {
          'no': '37',
          'baslik': 'Faillik',
          'icerik': '''(1) Suçun kanuni tanımında yer alan fiili birlikte gerçekleştiren kişilerden her biri, fail olarak sorumlu olur.
(2) Suçun işlenmesinde bir başkasını araç olarak kullanan kişi de fail olarak sorumlu tutulur. Kusur yeteneği olmayanları suçun işlenmesinde araç olarak kullanan kişinin cezası, üçte birden yarısına kadar artırılır.'''
        },
        {
          'no': '38',
          'baslik': 'Azmettirme',
          'icerik': '''(1) Başkasını suç işlemeye azmettiren kişi, işlenen suçun cezası ile cezalandırılır.
(2) Üstsoy ve altsoy ilişkisinden doğan nüfuz kullanılmak suretiyle suça azmettirme halinde, azmettirenin cezası üçte birden yarısına kadar artırılır. Çocukların suça azmettirilmesi halinde, bu fıkra hükmüne göre cezanın artırılabilmesi için üstsoy ve altsoy ilişkisinin varlığı aranmaz.
(3) Azmettirenin belli olmaması halinde, kim olduğunun ortaya çıkmasını sağlayan fail veya diğer suç ortağı hakkında ağırlaştırılmış müebbet hapis cezası yerine yirmi yıldan yirmibeş yıla kadar, müebbet hapis cezası yerine onbeş yıldan yirmi yıla kadar hapis cezasına hükmolunur. Diğer hallerde verilecek cezada, üçte bir oranında indirim yapılır.'''
        },
        {
          'no': '39',
          'baslik': 'Yardım etme',
          'icerik': '''(1) Suçun işlenmesine yardım eden kişiye, işlenen suçun ağırlaştırılmış müebbet hapis cezasını gerektirmesi halinde, onbeş yıldan yirmi yıla; müebbet hapis cezasını gerektirmesi halinde, on yıldan onbeş yıla kadar hapis cezası verilir. Diğer hallerde cezanın yarısı indirilir. Ancak, bu durumda verilecek ceza sekiz yılı geçemez.
(2) Aşağıdaki hallerde kişi işlenen suçtan dolayı yardım eden sıfatıyla sorumlu olur:
a) Suç işlemeye teşvik etmek veya suç işleme kararını kuvvetlendirmek veya fiilin işlenmesinden sonra yardımda bulunacağını vaat etmek.
b) Suçun nasıl işleneceği hususunda yol göstermek veya fiilin işlenmesinde kullanılan araçları sağlamak.
c) Suçun işlenmesinden önce veya işlenmesi sırasında yardımda bulunarak icrasını kolaylaştırmak.'''
        },
        {
          'no': '40',
          'baslik': 'Bağlılık kuralı',
          'icerik': '''(1) Suça iştirak için kasten ve hukuka aykırı işlenmiş bir fiilin varlığı yeterlidir. Suçun işlenişine iştirak eden her kişi, diğerinin cezalandırılmasını önleyen kişisel nedenler göz önünde bulundurulmaksızın kendi kusurlu fiiline göre cezalandırılır.
(2) Özgü suçlarda, ancak özel faillik niteliğini taşıyan kişi fail olabilir. Bu suçların işlenişine iştirak eden diğer kişiler ise, azmettiren veya yardım eden olarak sorumlu tutulur.
(3) Suça iştirakten dolayı sorumlu tutulabilmek için ilgili suçun en azından teşebbüs aşamasına varmış olması gerekir.'''
        },
        {
          'no': '41',
          'baslik': 'İştirak halinde gönüllü vazgeçme',
          'icerik': '''(1) İştirak halinde işlenen suçlarda, gönüllü vazgeçen suç ortağı, sadece kendi çabasının neticelerinden yararlanır ve kendi çabasıyla suçun tamamlanmasını veya neticenin gerçekleşmesini önlerse cezalandırılmaz. Suçun icrasına başlanmadan gönüllü olarak suçtan vazgeçen ve vazgeçmesiyle suç işlenmesini önleyen suç ortağı da cezalandırılmaz.'''
        },
        {
          'no': '42',
          'baslik': 'Bileşik suç',
          'icerik': '''(1) Biri diğerinin unsurunu veya ağırlaştırıcı nedenini oluşturması dolayısıyla tek fiil sayılan suça bileşik suç denir. Bu tür suçlarda içtima hükümleri uygulanmaz.'''
        },
        {
          'no': '43',
          'baslik': 'Zincirleme suç',
          'icerik': '''(1) Bir suç işleme kararının icrası kapsamında, değişik zamanlarda bir kişiye karşı aynı suçun birden fazla işlenmesi durumunda, bir cezaya hükmedilir. Ancak bu ceza, dörtte birinden dörtte üçüne kadar artırılır. Bir suçun temel şekli ile daha ağır veya daha az cezayı gerektiren nitelikli şekilleri, aynı suç sayılır. Mağduru belli bir kişi olmayan suçlarda da bu fıkra hükmü uygulanır.
(2) Aynı suçun birden fazla kişiye karşı tek bir fiille işlenmesi durumunda da, birinci fıkra hükmü uygulanır.
(3) Kasten öldürme, kasten yaralama, işkence ve yağma suçlarında bu madde hükümleri uygulanmaz.'''
        },
        {
          'no': '44',
          'baslik': 'Fikri içtima',
          'icerik': '''(1) İşlediği bir fiil ile birden fazla farklı suçun oluşmasına sebebiyet veren kişi, bunlardan en ağır cezayı gerektiren suçtan dolayı cezalandırılır.'''
        },
      ],
    },
    {
      'baslik': 'Kişilere Karşı Suçlar',
      'alt': 'Cinayet, Yaralama, İstismar',
      'emoji': '🚨',
      'icon': Icons.person_remove,
      'color': const Color(0xFFE74C3C),
      'maddeler': [],
    },
    {
      'baslik': 'Kişisel Hak ve Özgürlükler',
      'alt': 'Hakaret, Tehdit, Şantaj',
      'emoji': '🛡️',
      'icon': Icons.shield,
      'color': const Color(0xFF3498DB),
      'maddeler': [],
    },
    {
      'baslik': 'Malvarlığına Karşı Suçlar',
      'alt': 'Hırsızlık, Dolandırıcılık',
      'emoji': '💰',
      'icon': Icons.money_off,
      'color': const Color(0xFFF39C12),
      'maddeler': [],
    },
    {
      'baslik': 'Topluma Karşı Suçlar',
      'alt': 'Uyuşturucu, Fuhuş',
      'emoji': '⛔',
      'icon': Icons.block,
      'color': const Color(0xFFE67E22),
      'maddeler': [],
    },
    {
      'baslik': 'Kamu İdaresine Karşı Suçlar',
      'alt': 'Rüşvet, Zimmet, İrtikap',
      'emoji': '🏛️',
      'icon': Icons.account_balance,
      'color': const Color(0xFF16A085),
      'maddeler': [],
    },
    {
      'baslik': 'Adliyeye Karşı Suçlar',
      'alt': 'Yalan Tanıklık, Delil Karartma',
      'emoji': '⚖️',
      'icon': Icons.gavel,
      'color': const Color(0xFF8E44AD),
      'maddeler': [],
    },
    {
      'baslik': 'Kamunun Sağlığına Karşı Suçlar',
      'alt': 'Taksirle Yaralama/Öldürme',
      'emoji': '🏥',
      'icon': Icons.local_hospital,
      'color': const Color(0xFF27AE60),
      'maddeler': [],
    },
    {
      'baslik': 'Yaptırımlar',
      'alt': 'Madde 45-60',
      'emoji': '⚠️',
      'icon': Icons.policy,
      'color': const Color(0xFF9B59B6),
      'maddeler': [
        {
          'no': '45',
          'baslik': 'Cezalar',
          'icerik': '''(1) Suç karşılığında uygulanan yaptırım olarak cezalar, hapis ve adlî para cezalarıdır.'''
        },
        {
          'no': '46',
          'baslik': 'Hapis cezaları',
          'icerik': '''(1) Hapis cezaları şunlardır:
a) Ağırlaştırılmış müebbet hapis cezası.
b) Müebbet hapis cezası.
c) Süreli hapis cezası.'''
        },
        {
          'no': '47',
          'baslik': 'Ağırlaştırılmış müebbet hapis cezası',
          'icerik': '''(1) Ağırlaştırılmış müebbet hapis cezası, hükümlünün hayatı boyunca devam eder, kanun ve Cumhurbaşkanlığı kararnamelerinde belirtilen esaslar çerçevesinde düzenlenir ve yüksek güvenlikli kapalı ceza infaz kurumlarında infaz edilir.'''
        },
        {
          'no': '48',
          'baslik': 'Müebbet hapis cezası',
          'icerik': '''(1) Müebbet hapis cezası, hükümlünün hayatı boyunca devam eder, kanun ve Cumhurbaşkanlığı kararnamelerinde belirtilen esaslar çerçevesinde infaz edilir.'''
        },
        {
          'no': '49',
          'baslik': 'Süreli hapis cezası',
          'icerik': '''(1) Süreli hapis cezası, kanunda aksi belirtilmeyen hallerde bir aydan az, yirmi yıldan fazla olamaz.
(2) Hükmedilen bir yıl veya daha az süreli hapis cezası, kısa süreli hapis cezasıdır.'''
        },
        {
          'no': '50',
          'baslik': 'Kısa süreli hapis cezasına seçenek yaptırımlar',
          'icerik': '''(1) Kısa süreli hapis cezası, suçlunun kişiliğine, sosyal ve ekonomik durumuna, yargılama sürecinde duyduğu pişmanlığa ve suçun işlenmesindeki özelliklere göre;
a) Adlî para cezasına,
b) Mağdurun veya kamunun uğradığı zararın aynen iade, suçtan önceki hale getirme veya tazmin suretiyle, tamamen giderilmesine,
c) En az iki yıl süreyle, bir meslek veya sanat edinmeyi sağlamak amacıyla, gerektiğinde barınma imkanı da bulunan bir eğitim kurumuna devam etmeye,
d) Mahkum olunan cezanın yarısından bir katına kadar süreyle, belirli yerlere gitmekten veya belirli etkinlikleri yapmaktan yasaklanmaya,
e) Sağladığı hak ve yetkiler kötüye kullanılmak suretiyle veya gerektirdiği dikkat ve özen yükümlülüğüne aykırı davranılarak suç işlenmiş olması durumunda; mahkum olunan cezanın yarısından bir katına kadar süreyle, ilgili ehliyet ve ruhsat belgelerinin geri alınmasına, belli bir meslek ve sanatı yapmaktan yasaklanmaya,
f) Mahkum olunan cezanın yarısından bir katına kadar süreyle ve target gönüllü olmak koşuluyla kamuya yararlı bir işte çalıştırılmaya,
Çevrilebilir.
(2) Suç tanımında hapis cezası ile adlî para cezasının seçenek olarak öngörüldüğü hallerde, hapis cezasına hükmedilmişse; bu ceza artık adlî para cezasına çevrilmez.
(3) Daha önce hapis cezasına mahkum edilmemiş olmak koşuluyla, mahkum olunan otuz gün ve daha az süreli hapis cezası ile fiili işlediği tarihte onsekiz yaşını doldurmamış veya altmışbeş yaşını bitirmiş bulunanların mahkum edildiği bir yıl veya daha az süreli hapis cezası, birinci fıkrada yazılı seçenek yaptırımlardan birine çevrilir.
(4) Taksirli suçlardan dolayı hükmolunan hapis cezası uzun süreli de olsa; bu ceza, diğer koşulların varlığı halinde, birinci fıkranın (a) bendine göre adlî para cezasına çevrilebilir. Ancak, bu hüküm, bilinçli taksir halinde uygulanmaz.
(5) Uygulamada asıl mahkumiyet, bu madde hükümlerine göre çevrilen adlî para cezası veya tedbirdir.
(6) Hüküm kesinleştikten sonra Cumhuriyet savcılığınca yapılan tebligata rağmen otuz gün içinde seçenek tedbirin gereklerinin yerine getirilmesine başlanmaması veya başlanıp da devam edilmemesi halinde, hükmü veren mahkeme kısa süreli hapis cezasının tamamen veya kısmen infazına karar verir ve bu karar derhal infaz edilir. Bu durumda, beşinci fıkra hükmü uygulanmaz.
(7) Hükmedilen seçenek tedbirin hükümlünün elinde olmayan nedenlerle yerine getirilememesi durumunda, hükmü veren mahkemece tedbir değiştirilir.'''
        },
        {
          'no': '51',
          'baslik': 'Hapis cezasının ertelenmesi',
          'icerik': '''(1) İşlediği suçtan dolayı iki yıl veya daha az süreyle hapis cezasına mahkum edilen kişinin cezası ertelenebilir. Bu sürenin üst sınırı, fiili işlediği sırada onsekiz yaşını doldurmamış veya altmışbeş yaşını bitirmiş olan kişiler bakımından üç yıldır. Ancak, erteleme kararının verilebilmesi için kişinin;
a) Daha önce kasıtlı bir suçtan dolayı üç aydan fazla hapis cezasına mahkum edilmemiş olması,
b) Suçu işledikten sonra yargılama sürecinde gösterdiği pişmanlık dolayısıyla tekrar suç işlemeyeceği konusunda mahkemede bir kanaatin oluşması,
Gerekir.
(2) Cezanın ertelenmesi, mağdurun veya kamunun uğradığı zararın aynen iade, suçtan önceki hale getirme veya tazmin suretiyle tamamen giderilmesi koşuluna bağlı tutulabilir. Bu durumda, koşul gerçekleşinceye kadar cezanın infaz kurumunda çektirilmesine devam edilir. Koşulun yerine getirilmesi halinde, hakim kararıyla hükümlü infaz kurumundan derhal salıverilir.
(3) Cezası ertelenen hükümlü hakkında, bir yıldan az, üç yıldan fazla olmamak üzere, bir denetim süresi belirlenir. Bu sürenin alt sınırı, mahkum olunan ceza süresinden az olamaz.
(4) Denetim süresi içinde;
a) Bir meslek veya sanat sahibi olmayan hükümlünün, bu amaçla bir eğitim programına devam etmesine,
b) Bir meslek veya sanat sahibi hükümlünün, bir kamu kurumunda veya özel olarak aynı meslek veya sanatı icra eden bir başkasının gözetimi altında ücret karşılığında çalıştırılmasına,
c) Onsekiz yaşından küçük olan hükümlülerin, bir meslek veya sanat edinmelerini sağlamak amacıyla, gerektiğinde barınma imkanı da bulunan bir eğitim kurumuna devam etmesine,
Mahkemece karar verilebilir.
(5) Mahkeme, denetim süresi içinde hükümlüye rehberlik edecek bir uzman kişiyi görevlendirebilir. Bu kişi, kötü alışkanlıklardan kurtulmasını ve sorumluluk bilinciyle iyi bir hayat sürmesini temin hususunda hükümlüye öğütte bulunur; eğitim gördüğü kurum yetkilileri veya nezdinde çalıştığı kişilerle görüşerek, istişarelerde bulunur;게 üçer aylık sürelerle, hükümlünün gelişimi hakkında raporu mahkemeye verir.
(6) Mahkeme, hükümlünün kişiliğini ve sosyal durumunu göz önünde bulundurarak, denetim süresinin herhangi bir yükümlülük belirlemeden veya uzman kişi görevlendirmeden geçirilmesine de karar verebilir.
(7) Hükümlünün denetim süresi içinde kasıtlı bir suç işlemesi veya kendisine yüklenen yükümlülüklere, hakimin uyarısına rağmen, uymamakta ısrar etmesi halinde; ertelenen cezanın kısmen veya tamamen infaz kurumunda çektirilmesine karar verilir.
(8) Denetim süresi yükümlülüklere uygun veya iyi halli olarak geçirildiği takdirde, ceza infaz edilmiş sayılır.'''
        },
        {
          'no': '52',
          'baslik': 'Adlî para cezası',
          'icerik': '''(1) Adlî para cezası, beş günden az ve kanunda aksine hüküm bulunmayan hallerde yediyüzotuz günden fazla olmamak üzere belirlenen tam gün sayısının, bir gün karşılığı olarak takdir edilen miktar ile çarpılması suretiyle hesaplanan meblağın hükümlü tarafından Devlet Hazinesine ödenmesinden ibarettir.
(2) En az yirmi ve en fazla yüz Türk Lirası olan bir gün karşılığı adlî para cezasının miktarı, kişinin ekonomik ve diğer şahsi halleri göz önünde bulundurularak takdir edilir.
(3) Kararda, adlî para cezasının belirlenmesinde esas alınan tam gün sayısı ile bir gün karşılığı olarak takdir edilen miktar ayrı ayrı gösterilir.
(4) Hakim, ekonomik ve şahsi hallerini göz önünde bulundurarak, kişiye adlî para cezasını ödemesi için hükmün kesinleşme tarihinden itibaren bir yıldan fazla olmamak üzere mehil verebileceği gibi, bu cezanın belirli taksitler halinde ödenmesine de karar verebilir. Taksit süresi iki yılı geçemez ve taksit miktarı dörtten az olamaz. Kararda, taksitlerden birinin zamanında ödenmemesi halinde geri kalan kısmın tamamının tahsil edileceği ve ödenmeyen adlî para cezasının hapse çevrileceği belirtilir.'''
        },
        {
          'no': '53',
          'baslik': 'Belli hakları kullanmaktan yoksun bırakılma',
          'icerik': '''(1) Kişi, kasten işlemiş olduğu suçtan dolayı hapis cezasına mahkumiyetin kanuni sonucu olarak;
a) Sürekli, süreli veya geçici bir kamu görevinin üstlenilmesinden; bu kapsamda, Türkiye Büyük Millet Meclisi üyeliğinden veya Devlet, il, belediye, köy veya bunların denetim ve gözetimi altında bulunan kurum ve kuruluşlarca verilen, atamaya veya seçime tabi bütün memuriyet ve hizmetlerde istihdam edilmekten,
b) Seçme ve seçilme ehliyetinden ve diğer siyasi hakları kullanmaktan,
c) Velayet hakkından; vesayet veya kayyımlığa ait bir hizmette bulunmaktan,
d) Vakıf, dernek, sendika, şirket, kooperatif ve siyasi parti tüzel kişiliklerinin yöneticisi veya denetçisi olmaktan,
e) Bir kamu kurumunun veya kamu kurumu niteliğindeki meslek kuruluşunun iznine tabi bir meslek veya sanatı, kendi sorumluluğu altında serbest meslek erbabı veya tacir olarak icra etmekten,
Yoksun bırakılır.
(2) Kişi, işlemiş bulunduğu suç dolayısıyla mahkum olduğu hapis cezasının infazı tamamlanıncaya kadar bu hakları kullanamaz.
(3) Mahkum olduğu hapis cezası ertelenen veya koşullu salıverilen hükümlünün kendi altsoyu üzerindeki velayet, vesayet ve kayyımlık yetkileri açısından yukarıdaki fıkralar hükümleri uygulanmaz. Mahkum olduğu hapis cezası ertelenen hükümlü hakkında birinci fıkranın (e) bendinde söz konusu edilen hak yoksunluğunun uygulanmamasına karar verilebilir.
(4) Kısa süreli hapis cezası ertelenmiş veya fiili işlediği sırada onsekiz yaşını doldurmamış olan kişiler hakkında birinci fıkra hükmü uygulanmaz.
(5) Birinci fıkrada sayılan hak ve yetkilerden birinin kötüye kullanılması suretiyle işlenen suçlar dolayısıyla hapis cezasına mahkumiyet halinde, ayrıca, cezanın infazından sonra işlemek üzere, hükmolunan cezanın yarısından bir katına kadar bu hak ve yetkinin kullanılmasının yasaklanmasına karar verilir. Bu hak ve yetkilerden birinin kötüye kullanılması suretiyle işlenen suçlar dolayısıyla sadece adlî para cezasına mahkumiyet halinde, hükümde belirtilen gün sayısının yarısından bir katına kadar bu hak ve yetkinin kullanılmasının yasaklanmasına karar verilir. Hükmün kesinleşmesiyle icraya konan yasaklama ile ilgili süre, adlî para cezasının tamamen infazından itibaren işlemeye başlar.
(6) Belli bir meslek veya sanatın ya da trafik düzeninin gerektirdiği dikkat ve özen yükümlülüğüne aykırılık dolayısıyla işlenen taksirli suçtan mahkumiyet halinde, üç aydan az ve üç yıldan fazla olmamak üzere, bu meslek veya sanatın icrasının yasaklanmasına ya da sürücü belgesinin geri alınmasına karar verilebilir. Yasaklama ve geri alma hükmün kesinleşmesiyle yürürlüğe girer ve süre, cezanın tümüyle infazından itibaren işlemeye başlar.'''
        },
        {
          'no': '54',
          'baslik': 'Eşya müsaderesi',
          'icerik': '''(1) İyiniyetli üçüncü kişilere ait olmamak koşuluyla, kasıtlı bir suçun işlenmesinde kullanılan veya suçun işlenmesine tahsis edilen ya da suçtan meydana gelen eşyanın müsaderesine hükmolunur. Suçun işlenmesinde kullanılmak üzere hazırlanan eşya, kamu güvenliği, kamu sağlığı veya genel ahlak açısından tehlikeli olması durumunda müsadere edilir.
(2) Birinci fıkra kapsamına giren eşyanın, ortadan kaldırılması, elden çıkarılması, tüketilmesi veya müsaderesinin başka bir surette imkansız kılınması halinde; bu eşyanın değeri kadar para tutarının müsaderesine karar verilir.
(3) Suçta kullanılan eşyanın müsadere edilmesinin işlenen suça nazaran daha ağır sonuçlar doğuracağı ve bu nedenle hakkaniyete aykırı olacağı anlaşıldığında, müsaderesine hükmedilmeyebilir.
(4) Üretimi, bulundurulması, kullanılması, taşınması, alım ve satımı suç oluşturan eşya, müsadere edilir.
(5) Bir şeyin sadece bazı kısımlarının müsaderesi gerektiğinde, tümüne zarar verilmeksizin bu kısımlar ayrılabilir ise, sadece bu kısımların müsaderesine karar verilir; ayrılmasının mümkün olmaması halinde müsadere edilmeyip eşyanın mahzurlu kısımlarının ortadan kaldırılması veya eşyanın zararsız hale getirilmesi sağlanır.
(6) Müsadere kararı verilmesi için bir kimsenin suçtan dolayı mahkum edilmesi gerekli değildir.'''
        },
        {
          'no': '55',
          'baslik': 'Kazanç müsaderesi',
          'icerik': '''(1) Suçun işlenmesi ile elde edilen veya suçun konusunu oluşturan ya da suçun işlenmesi için sağlanan maddi menfaatler ile bunların değerlendirilmesi veya dönüştürülmesi sonucu ortaya çıkan ekonomik kazançların müsaderesine karar verilir. Bu fıkra hükmüne göre müsadere kararı verilebilmesi için maddi menfaatin suçun mağduruna iade edilememesi gerekir.
(2) Müsadere konusu eşya veya maddi menfaatlere el konulamadığı veya bunların merciine teslim edilmediği hallerde, bunların karşılığını oluşturan değerlerin müsaderesine hükmedilir.
(3) Bu madde kapsamına giren eşyanın müsadere edilebilmesi için, eşyayı sonradan iktisap eden kişinin 22/11/2001 tarihli ve 4721 sayılı Türk Medeni Kanununun iyiniyetin korunmasına ilişkin hükümlerinden yararlanamıyor olması gerekir.'''
        },
        {
          'no': '56',
          'baslik': 'Çocuklara özgü güvenlik tedbirleri',
          'icerik': '''(1) Fiili işlediği sırada oniki yaşını doldurmamış olan çocuklar ile oniki yaşını doldurmuş olup da onbeş yaşını doldurmamış olanlardan 31 inci maddenin ikinci fıkrası kapsamına girenler hakkında, çocuklara özgü güvenlik tedbirleri uygulanır.
(2) Çocuklara özgü güvenlik tedbirleri, 3/7/2005 tarihli ve 5395 sayılı Çocuk Koruma Kanununda gösterilen koruyucu ve destekleyici tedbirlerdir.'''
        },
        {
          'no': '57',
          'baslik': 'Akıl hastalarına özgü güvenlik tedbirleri',
          'icerik': '''(1) Fiili işlediği sırada akıl hastası olan kişi hakkında, koruma ve tedavi amaçlı olarak güvenlik tedbirine hükmedilir. Hakkında güvenlik tedbirine hükmedilen akıl hastaları, yüksek güvenlikli sağlık kurumlarında koruma ve tedavi altına alınırlar.
(2) Hakkında güvenlik tedbirine hükmedilmiş olan akıl hastası, yerleştirildiği kurumun sağlık kurulunca düzenlenen raporda toplum açısından tehlikeliliğinin ortadan kalktığının veya önemli ölçüde azaldığının belirtilmesi üzerine mahkeme veya hakim kararıyla serbest bırakılabilir.
(3) Serbest bırakılan akıl hastası, nüfus kaydının bulunduğu veya yerleşmek istediği yerdeki sağlık veya sosyal hizmet kuruluşlarına, kendisine ve başkalarına zarar vermemesi için gerekli tedbirlerin alınması amacıyla, Cumhuriyet başsavcılığı tarafından bildirilir.
(4) Toplum için tehlikeliliğinin yeniden ortaya çıkması halinde, tekrar koruma ve tedavi amaçlı olarak güvenlik tedbirine hükmedilir.
(5) Bu maddenin uygulanmasında, 16/6/2005 tarihli ve 5275 sayılı Ceza ve Güvenlik Tedbirlerinin İnfazı Hakkında Kanun ve 3/7/2005 tarihli ve 5395 sayılı Çocuk Koruma Kanunu hükümleri dikkate alınır.
(6) İşlediği fiille ilgili olarak hastalığı yüzünden davranışlarını yönlendirme yeteneği azalmış olan kişi hakkında birinci ve ikinci fıkra hükümlerine göre yerleştirildiği yüksek güvenlikli sağlık kuruluşunda düzenlenen kurul raporu üzerine, mahkum olduğu hapis cezası, süresi aynı kalmak koşuluyla, kısmen veya tamamen, mahkeme kararıyla akıl hastalarına özgü güvenlik tedbiri olarak da uygulanabilir.
(7) Suç işleyen alkol ya da uyuşturucu veya uyarıcı madde bağımlısı kişilerin, güvenlik tedbiri olarak, alkol ya da uyuşturucu veya uyarıcı madde bağımlılarına özgü sağlık kuruluşunda tedavi altına alınmasına karar verilir. Bu kişilerin tedavisi, alkol ya da uyuşturucu veya uyarıcı madde bağımlılığından kurtulmalarına kadar devam eder. Bu kişiler, yerleştirildiği kurumun sağlık kurulunca bu yönde düzenlenecek rapor üzerine mahkeme veya hakim kararıyla serbest bırakılır.'''
        },
        {
          'no': '58',
          'baslik': 'Suçta tekerrür ve özel tehlikeli suçlular',
          'icerik': '''(1) Önceden işlenen suçtan dolayı verilen hüküm kesinleştikten sonra yeni bir suçun işlenmesi halinde, tekerrür hükümleri uygulanır. Bunun için cezanın infaz edilmiş olması gerekmez.
(2) Tekerrür hükümleri, önceden işlenen suçtan dolayı;
a) Beş yıldan fazla süreyle hapis cezasına mahkumiyet halinde, bu cezanın infaz edildiği tarihten itibaren beş yıl,
b) Beş yıl veya daha az süreli hapis ya da adlî para cezasına mahkumiyet halinde, bu cezanın infaz edildiği tarihten itibaren üç yıl,
Geçtikten sonra işlenen suçlar dolayısıyla uygulanmaz.
(3) Tekerrür halinde, sonraki suça ilişkin kanun maddesinde seçimlik olarak hapis cezası ile adlî para cezası öngörülmüşse, hapis cezasına hükmolunur.
(4) Kasıtlı suçlarla taksirli suçlar ve sırf askeri suçlarla diğer suçlar arasında tekerrür hükümleri uygulanmaz. Kasten öldürme, kasten yaralama, yağma, dolandırıcılık, uyuşturucu veya uyarıcı madde imal ve ticareti ile parada veya kıymetli damgalarda sahtecilik suçları hariç olmak üzere; yabancı ülke mahkemelerinden verilen hükümler tekerrüre esas olmaz.
(5) Fiili işlediği sırada onsekiz yaşını doldurmamış olan kişilerin işlediği suçlar dolayısıyla tekerrür hükümleri uygulanmaz.
(6) Tekerrür halinde hükmolunan ceza, mükerrirlere özgü infaz rejimine göre çektirilir. Ayrıca, mükerrir hakkında cezanın infazından sonra denetimli serbestlik tedbiri uygulanır.
(7) Mahkumiyet kararında, hükümlü hakkında mükerrirlere özgü infaz rejiminin ve cezanın infazından sonra denetimli serbestlik tedbirinin uygulanacağı belirtilir.
(8) Mükerrirlerin mahkum olduğu cezanın infazı ile denetimli serbestlik tedbirinin uygulanması, kanunda gösterilen şekilde yapılır.
(9) Mükerrirlere özgü infaz rejiminin ve cezanın infazından sonra denetimli serbestlik tedbirinin, itiyadi suçlu, suçu meslek edinen kişi veya örgüt mensubu suçlu hakkında da uygulanmasına hükmedilir.'''
        },
        {
          'no': '59',
          'baslik': 'Takdiri indirim nedenleri',
          'icerik': '''(1) Failin geçmişi, sosyal ilişkileri, fiilden sonraki ve yargılama sürecindeki davranışları, cezanın failin geleceği üzerindeki olası etkileri gibi hususlar göz önünde bulundurularak, suçun işleniş biçimine göre temel ceza, belirlenen cezanın altıda birine kadar indirilebilir.
(2) Takdiri indirim nedeni olarak, kanuni indirim nedenlerinin kabul edilmesine esas alınan hallere ilişkin gerekçelere dayanılamaz.'''
        },
        {
          'no': '60',
          'baslik': 'Tüzel kişiler hakkında güvenlik tedbirleri',
          'icerik': '''(1) Bir kamu kurumunun verdiği izne dayalı olarak faaliyette bulunan özel hukuk tüzel kişisinin organ veya temsilcilerinin iştirakiyle ve bu iznin verdiği yetkinin kötüye kullanılması suretiyle tüzel kişi yararına işlenen kasıtlı suçlardan mahkumiyet halinde, iznin iptaline karar verilir.
(2) Müsadere hükümleri, yararına işlenen suçlarda özel hukuk tüzel kişileri hakkında da uygulanır.'''
        },
      ],
    },
    {
      'baslik': 'Dava & Ceza Düşmesi',
      'alt': 'Madde 66-75',
      'emoji': '⏰',
      'icon': Icons.event_busy,
      'color': const Color(0xFF3498DB),
      'maddeler': [
        {
          'no': '66',
          'baslik': 'Dava zamanaşımı',
          'icerik': '''(1) Kanunda başka türlü yazılmış olan haller dışında kamu davası;
a) Ağırlaştırılmış müebbet hapis cezasını gerektiren suçlarda otuz yıl,
b) Müebbet hapis cezasını gerektiren suçlarda yirmibeş yıl,
c) Yirmi yıldan aşağı olmamak üzere hapis cezasını gerektiren suçlarda yirmi yıl,
d) Beş yıldan fazla ve yirmi yıldan az hapis cezasını gerektiren suçlarda onbeş yıl,
e) Beş yıldan fazla olmamak üzere hapis veya adlî para cezasını gerektiren suçlarda sekiz yıl,
Geçmesiyle düşer.
(2) Fiili işlediği sırada oniki yaşını doldurmuş olup da onbeş yaşını doldurmamış olanlar hakkında, bu sürelerin yarısının; onbeş yaşını doldurmuş olup da onsekiz yaşını doldurmamış olan kişiler hakkında ise, üçte ikisinin geçmesiyle kamu davası düşer.
(3) Dava zamanaşımı süresinin belirlenmesinde dosyadaki mevcut deliller itibarıyla suçun daha ağır cezayı gerektiren nitelikli halleri de göz önünde bulundurulur.
(4) Yukarıdaki fıkralarda yer alan sürelerin belirlenmesinde suçun kanunda yer alan cezasının yukarı sınırı göz önünde bulundurulur; seçimlik cezaları gerektiren suçlarda zamanaşımı bakımından hapis cezası esas alınır.
(5) Aynı fiilden dolayı tekrar yargılamayı gerektiren hallerde, mahkumiyete ilişkin hükmün kesinleştiği tarihten itibaren fiilin gerektirdiği zamanaşımı süresi içinde yargılamanın yenilenmesi talebinde bulunulabilir.
(6) Zamanaşımı, tamamlanmış suçlarda suçun işlendiği günden, teşebbüs halinde kalan suçlarda son hareketin yapıldığı günden, kesintisiz suçlarda kesintinin gerçekleştiği ve zincirleme suçlarda son suçun işlendiği günden, çocuklara karşı üstsoy veya bunlar üzerinde hüküm ve nüfuzu olan kimseler tarafından işlenen suçlarda çocuğun onsekiz yaşını bitirdiği günden itibaren işlemeye başlar.
(7) Bu Kanunun İkinci Kitabının Dördüncü Kısmının Dördüncü, Beşinci, Altıncı ve Yedinci Bölümünde tanımlanan suçlar ile 220 nci maddede tanımlanan suç ve bu suçların bir örgütün faaliyeti çerçevesinde işlenmesi dolayısıyla zamanaşımı uygulanmaz.'''
        },
        {
          'no': '67',
          'baslik': 'Dava zamanaşımı süresinin durması veya kesilmesi',
          'icerik': '''(1) Soruşturma ve kovuşturma yapılmasının, izin veya karar alınması veya diğer bir merciden çözülmesi gereken bir meselenin sonucuna bağlı bulunduğu hallerde; izin veya kararın alınmasına veya meselenin çözümüne veya kanun gereğince hakkında kaçak olduğu hususunda karar verilmiş olan suç faili hakkında bu karar kaldırılıncaya kadar dava zamanaşımı durur.
(2) Bir suçla ilgili olarak;
a) Şüpheli veya sanıklardan birinin savcı huzurunda ifadesinin alınması veya sorguya çekilmesi,
b) Şüpheli veya sanıklardan biri hakkında tutuklama kararının verilmesi,
c) Suçla ilgili olarak iddianame düzenlenmesi,
d) Sanıklardan bir kısmı hakkında da olsa, mahkumiyet kararı verilmesi,
Halinde, dava zamanaşımı kesilir.
(3) Dava zamanaşımı kesildiğinde, zamanaşımı süresi yeniden işlemeye başlar. Ancak, dava zamanaşımı süresinin en fazla yarısına kadar uzayabilir.
(4) Kesilme halinde, zamanaşımı süresi ilgili suça ilişkin olarak Kanunda belirlenen sürenin en fazla yarısına kadar uzar. Ancak, uzama süresi olarak belirlenen bu süre, ayrıca zamanaşımını kesen işlemler nedeniyle tekrar uzamaz.'''
        },
        {
          'no': '68',
          'baslik': 'Ceza zamanaşımı',
          'icerik': '''(1) Bu maddede yazılı cezalar aşağıdaki sürelerin geçmesiyle infaz edilmez:
a) Ağırlaştırılmış müebbet hapis cezalarında kırk yıl.
b) Müebbet hapis cezalarında otuz yıl.
c) Yirmi yıl ve daha fazla süreli hapis cezalarında yirmidört yıl.
d) Beş yıldan fazla hapis cezalarında yirmi yıl.
e) Beş yıla kadar hapis ve adlî para cezalarında on yıl.
(2) Fiili işlediği sırada oniki yaşını doldurmuş olup da onbeş yaşını doldurmamış olanlar hakkında, bu sürelerin yarısının; onbeş yaşını doldurmuş olup da onsekiz yaşını doldurmamış olan kişiler hakkında ise, üçte ikisinin geçmesiyle ceza infaz edilmez.
(3) Bu Kanunun İkinci Kitabının Dördüncü Kısmının Dördüncü, Beşinci, Altıncı ve Yedinci Bölümünde tanımlanan suçlar ile 220 nci maddede tanımlanan suç ve bu suçların bir örgütün faaliyeti çerçevesinde işlenmesi dolayısıyla ceza zamanaşımı uygulanmaz.'''
        },
        {
          'no': '69',
          'baslik': 'Ceza zamanaşımı süresinin durması',
          'icerik': '''(1) Ceza zamanaşımı, hükümlünün kanun gereğince cezasının ertelenmesi, infazın herhangi bir suretle kesintiye uğraması veya cezasının infazı için hükümlü hakkında yakalama emri düzenlenmesi ile durur.'''
        },
        {
          'no': '70',
          'baslik': 'Mahsup',
          'icerik': '''(1) Tutukluluğun veya iki yıl veya daha az süreli hapis cezası ile adlî para cezasına mahkumiyetin öğrenilmediği veya bilinmediği ya da Cumhuriyet savcılığınca her ne suretle olursa olsun ihbar olunamadığı süre, ceza zamanaşımı süresine dahil edilmez.'''
        },
        {
          'no': '71',
          'baslik': 'Sanığın veya hükümlünün ölümü',
          'icerik': '''(1) Sanığın ölümü halinde kamu davasının düşürülmesine karar verilir. Ancak, niteliği itibarıyla müsadereye tabi eşya ve maddi menfaatler hakkında davaya devam olunarak bunların müsaderesine hükmolunabilir.
(2) Hükümlünün ölümü, hapis ve henüz infaz edilmemiş adlî para cezalarını ortadan kaldırır. Ancak, müsadereye ve yargılama giderlerine ilişkin olup ölümden önce kesinleşmiş bulunan hüküm, infaz olunur.'''
        },
        {
          'no': '72',
          'baslik': 'Af',
          'icerik': '''(1) Genel af halinde, kamu davası düşer, hükmolunan cezalar bütün neticeleri ile birlikte ortadan kalkar.
(2) Özel af ile hapis cezasının infaz kurumunda çektirilmesine son verilebilir veya infaz kurumunda çektirilecek süresi kısaltılabilir ya da adlî para cezasına çevrilebilir.
(3) Cezaya bağlı olan veya hükümde belirtilen hak yoksunlukları, özel affa rağmen etkisini devam ettirir.'''
        },
        {
          'no': '73',
          'baslik': 'Şikâyet',
          'icerik': '''(1) Soruşturulması ve kovuşturulması şikayete bağlı olan suç hakkında yetkili kimse altı ay içinde şikayette bulunmadığı takdirde soruşturma ve kovuşturma yapılamaz.
(2) Zamanaşımı süresini geçmemek koşuluyla bu süre, şikayet hakkı olan kişinin fiili ve failin kim olduğunu bildiği veya öğrendiği günden başlar.
(3) Şikayet hakkı olan birkaç kişiden birinin altı aylık süreyi geçirmesi, diğerlerinin haklarını düşürmez.
(4) Kovuşturma yapılabilmesi şikayete bağlı suçlarda kanunda aksi yazılı olmadıkça suçtan zarar gören kişinin şikayeti üzerine kovuşturma yapılır.
(5) İştirak halinde suç işlemiş sanıklardan biri hakkındaki şikayet, diğerlerini de kapsar.
(6) Şikayet, Cumhuriyet Başsavcılığına veya kolluk makamlarına yapılır.
(7) Veli, vasi veya kayyım, şikâyetten vazgeçerse, şikâyet hakkına sahip kişi, altı ay içinde şikâyet hakkını kullanabilir.
(8) Fiil, birden fazla kişi tarafından işlenmiş ise bunlardan birine karşı şikâyetten vazgeçme, diğerlerini de kapsar.'''
        },
        {
          'no': '74',
          'baslik': 'Şikâyetten vazgeçme',
          'icerik': '''(1) Kovuşturulması şikayete bağlı suç hakkında şikayetten vazgeçilirse, dava düşer.
(2) Hükmün kesinleşmesinden sonraki vazgeçme, cezanın infazına engel olmaz.
(3) Vazgeçme, onu kabul etmeyen sanığı etkilemez.
(4) Kamu davasının düşmesi, suçtan zarar gören kişinin şikayetten vazgeçmiş olmasından ileri gelmiş ve vazgeçtiği sırada şahsi haklarından da vazgeçtiğini ayrıca açıklamış ise artık hukuk mahkemesinde de dava açamaz.'''
        },
        {
          'no': '75',
          'baslik': 'Önödeme',
          'icerik': '''(1) Uzlaşma kapsamındaki suçlar hariç olmak üzere, yalnız adlî para cezasını gerektiren veya kanun maddesinde öngörülen hapis cezasının yukarı sınırı altı ayı aşmayan suçların faili;
a) Adlî para cezası maktu ise bu miktarı, değilse aşağı sınırını,
b) Hapis cezasının aşağı sınırının karşılığı olarak her gün için otuz Türk Lirası üzerinden bulunacak miktarı,
c) Hapis cezası ile birlikte adlî para cezası da öngörülmüş ise, hapis cezası için bu fıkranın (b) bendine göre belirlenecek miktar ile adlî para cezasının aşağı sınırını,
Soruşturma giderleri ile birlikte, Cumhuriyet savcılığınca yapılacak tebliğ üzerine on gün içinde ödediği takdirde hakkında kamu davası açılmaz.
(2) Öngörülen ceza, hapis cezasının yanı sıra adlî para cezasını da gerektiren durumlarda, sadece adlî para cezasını ödeyip hapis cezası hakkında kovuşturulma isteminde bulunulamaz.
(3) Cumhuriyet savcılığınca düzenlenen iddianamenin kabulünden sonra kovuşturma aşamasında birinci fıkrada belirtilen nitelikteki bir suçun varlığı halinde de önödeme uygulanır. Bu durumda masraflar da dahil olmak üzere birinci fıkra hükümlerine göre hesaplanacak miktarı hakim veya mahkeme belirler ve sanığa tebliğ eder. Tebliğden itibaren on gün içinde bu miktarın ödenmesi halinde, kamu davasının düşmesine karar verilir.
(4) Özel kanunlarda yer alan, uzlaşma ve önödeme kapsamı dışındaki suçlarla ilgili olarak, yaptırım türü ve miktarına bakılmaksızın önödeme geçerli olmaz.'''
        },
      ],
    },
    {
      'baslik': 'Uluslararası Suçlar',
      'alt': 'Madde 76-80',
      'emoji': '🌍',
      'icon': Icons.language,
      'color': const Color(0xFFE74C3C),
      'maddeler': [
        {
          'no': '76',
          'baslik': 'Soykırım',
          'icerik': '''(1) Bir planın icrası suretiyle, milli, etnik, ırki veya dini bir grubun tamamen veya kısmen yok edilmesi maksadıyla, bu grupların üyelerine karşı aşağıdaki fiillerden birinin işlenmesi, soykırım suçunu oluşturur:
a) Kasten öldürme.
b) Kişilerin bedensel veya ruhsal bütünlüklerine ağır zarar verme.
c) Grubun, tamamen veya kısmen yok edilmesi sonucunu doğuracak koşullarda yaşamaya zorlanması.
d) Grup içinde doğumlara engel olmaya yönelik tedbirlerin alınması.
e) Gruba ait çocukların bir başka gruba zorla nakledilmesi.
(2) Soykırım suçu failine ağırlaştırılmış müebbet hapis cezası verilir. Ancak, soykırım kapsamında işlenen kasten öldürme ve kasten yaralama suçları açısından, belirlenen mağdur sayısınca gerçek içtima hükümleri uygulanır.
(3) Bu suçlardan dolayı tüzel kişiler hakkında da güvenlik tedbirine hükmolunur.'''
        },
        {
          'no': '77',
          'baslik': 'İnsanlığa karşı suçlar',
          'icerik': '''(1) Aşağıdaki fiillerin, siyasal, felsefi, ırki veya dini saiklerle toplumun bir kesimine karşı bir plan doğrultusunda sistemli olarak işlenmesi, insanlığa karşı suç oluşturur:
a) Kasten öldürme.
b) Kasten yaralama.
c) İşkence, eziyet veya köleleştirme.
d) Kişi hürriyetinden yoksun kılma.
e) Bilimsel deneylere tabi kılma.
f) Cinsel saldırıda bulunma, çocukların cinsel istismarı.
g) Zorla hamile bırakma.
h) Zorla fuhşa sevketme.
(2) Birinci fıkranın (a) bendindeki fiilin işlenmesi halinde, fail hakkında ağırlaştırılmış müebbet hapis cezasına; diğer bentlerde tanımlanan fiillerin işlenmesi halinde ise, sekiz yıldan az olmamak üzere hapis cezasına hükmolunur. Ancak, birinci fıkranın (a) ve (b) bentleri kapsamında işlenen kasten öldürme ve kasten yaralama suçları açısından, belirlenen mağdur sayısınca gerçek içtima hükümleri uygulanır.
(3) Bu suçlardan dolayı tüzel kişiler hakkında da güvenlik tedbirine hükmolunur.'''
        },
        {
          'no': '78',
          'baslik': 'Örgüt',
          'icerik': '''(1) Bu Kısımda yazılı suçları işlemek maksadıyla örgüt kuran veya yöneten kişi, on yıldan onbeş yıla kadar hapis cezası ile cezalandırılır.
(2) Bu amaçla kurulmuş örgüte üye olanlara beş yıldan on yıla kadar hapis cezası verilir.'''
        },
        {
          'no': '79',
          'baslik': 'Göçmen kaçakçılığı',
          'icerik': '''(1) Doğrudan doğruya veya dolaylı olarak maddi menfaat elde etmek maksadıyla, yasal olmayan yollardan;
a) Bir yabancıyı ülkeye sokan veya ülkede kalmasına imkan sağlayan,
b) Türk vatandaşını veya yabancıyı yurt dışına çıkaran,
Kişi, üç yıldan sekiz yıla kadar hapis ve onbin güne kadar adlî para cezası ile cezalandırılır.
(2) Bu suçun, birden fazla kişi tarafından birlikte işlenmesi halinde verilecek ceza yarısına kadar, bir örgütün faaliyeti çerçevesinde işlenmesi halinde verilecek ceza yarısından bir katına kadar artırılır.
(3) Bu suçun bir tüzel kişinin faaliyeti çerçevesinde işlenmesi halinde, tüzel kişi hakkında bunlara özgü güvenlik tedbirlerine hükmolunur.
(4) Bu suç nedeniyle kovuşturma yapılması veya yargılama yetkisinin kullanılması, suçun mağduru olan kişilerin kayıtlı olduğu ülke dışında işlenmiş olmasını gerektirir.'''
        },
        {
          'no': '80',
          'baslik': 'İnsan ticareti',
          'icerik': '''(1) Zorla çalıştırmak, hizmet ettirmek, fuhuş yaptırmak veya esarete tâbi kılmak ya da vücut organlarının verilmesini sağlamak maksadıyla, tehdit, baskı, cebir veya şiddet uygulamak, nüfuzu kötüye kullanmak, kandırmak veya kişiler üzerindeki denetim olanaklarından veya çaresizliklerinden yararlanarak rızalarını elde etmek suretiyle kişileri ülkeye sokan, ülke dışına çıkaran, tedarik eden, kaçıran, bir yerden başka bir yere götüren veya sevk eden ya da barındıran kimseye sekiz yıldan oniki yıla kadar hapis ve onbin güne kadar adlî para cezası verilir.
(2) Birinci fıkrada belirtilen amaçlarla girişilen ve suçu oluşturan fiiller var olduğu takdirde, mağdurun rızası geçersizdir.
(3) Onsekiz yaşını doldurmamış olanların birinci fıkrada belirtilen maksatlarla tedarik edilmeleri, kaçırılmaları, bir yerden diğer bir yere götürülmeleri veya sevk edilmeleri ya da barındırılmaları hallerinde suça ait araç fiillerden hiçbirine başvurulmuş olmasa da faile birinci fıkrada belirtilen cezalar verilir.
(4) Bu suçlardan dolayı tüzel kişiler hakkında da güvenlik tedbirine hükmolunur.'''
        },
      ],
    },
    {
      'baslik': 'Hayata Karşı Suçlar',
      'alt': 'Madde 81-101',
      'emoji': '💔',
      'icon': Icons.favorite_border,
      'color': const Color(0xFFE91E63),
      'maddeler': [
        {
          'no': '81',
          'baslik': 'Kasten öldürme',
          'icerik': '''(1) Bir insanı kasten öldüren kişi, müebbet hapis cezası ile cezalandırılır.'''
        },
        {
          'no': '82',
          'baslik': 'Nitelikli haller',
          'icerik': '''(1) Kasten öldürme suçunun;
a) Tasarlayarak,
b) Canavarca hisle veya eziyet çektirerek,
c) Yangın, su baskını, tahrip, batırma veya bombalama ya da nükleer, biyolojik veya kimyasal silah kullanmak suretiyle,
d) Üstsoy veya altsoydan birine ya da eş veya kardeşe karşı,
e) Çocuğa ya da beden veya ruh bakımından kendisini savunamayacak durumda bulunan kişiye karşı,
f) Gebe olduğu bilinen kadına karşı,
g) Kişinin yerine getirdiği kamu görevi nedeniyle,
h) Bir suçu gizlemek, delillerini ortadan kaldırmak veya işlenmesini kolaylaştırmak ya da yakalanmamak amacıyla,
ı) Bir suçu işleyememekten dolayı duyduğu infialle,
j) Kan gütme saikiyle,
k) Töre saikiyle,
İşlenmesi halinde, kişi ağırlaştırılmış müebbet hapis cezası ile cezalandırılır.'''
        },
        {
          'no': '83',
          'baslik': 'Kasten öldürmenin ihmali davranışla işlenmesi',
          'icerik': '''(1) Kişinin yükümlü olduğu belli bir icrai davranışı gerçekleştirmemesi dolayısıyla meydana gelen ölüm neticesinden sorumlu tutulabilmesi için, bu neticenin oluşumuna sebebiyet veren yükümlülük ihmalinin icrai davranışa eşdeğer olması gerekir.
(2) İhmali ve icrai davranışın eşdeğer kabul edilebilmesi için, kişinin;
a) Belli bir icrai davranışta bulunmak hususunda kanuni düzenlemelerden veya sözleşmeden kaynaklanan bir yükümlülüğünün bulunması,
b) Önceden gerçekleştirdiği davranışın başkalarının hayatı ile ilgili olarak tehlikeli bir durum oluşturması,
Gerekir.
(3) Belli bir yükümlülüğün ihmali ile ölüme neden olan kişi hakkında, temel ceza olarak, ağırlaştırılmış müebbet hapis cezası yerine yirmi yıldan yirmibeş yıla kadar, müebbet hapis cezası yerine onbeş yıldan yirmi yıla kadar, diğer hallerde ise on yıldan onbeş yıla kadar hapis cezasına hükmolunabileceği gibi, cezada indirim de yapılmayabilir.'''
        },
        {
          'no': '84',
          'baslik': 'İntihara yönlendirme',
          'icerik': '''(1) Başkasını intihara azmettiren, teşvik eden, başkasının intihar kararını kuvvetlendiren ya da başkasının intiharına herhangi bir şekilde yardım eden kişi, iki yıldan beş yıla kadar hapis cezası ile cezalandırılır.
(2) İntiharın gerçekleşmesi durumunda, kişi dört yıldan on yıla kadar hapis cezası ile cezalandırılır.
(3) Başkalarını intihara alenen teşvik eden kişi, üç yıldan sekiz yıla kadar hapis cezası ile cezalandırılır. Bu fiilin basın ve yayın yolu ile işlenmesi halinde, kişi dört yıldan on yıla kadar hapis cezası ile cezalandırılır.
(4) İşlediği fiilin anlam ve sonuçlarını algılama yeteneği gelişmemiş olan veya ortadan kaldırılan kişileri intihara sevk edenlerle cebir veya tehdit kullanmak suretiyle kişileri intihara mecbur edenler, kasten öldürme suçundan sorumlu tutulurlar.'''
        },
        {
          'no': '85',
          'baslik': 'Taksirle öldürme',
          'icerik': '''(1) Taksirle bir insanın ölümüne neden olan kişi, iki yıldan altı yıla kadar hapis cezası ile cezalandırılır.
(2) Fiil, birden fazla insanın ölümüne ya da bir veya birden fazla kişinin ölümü ile birlikte bir veya birden fazla kişinin yaralanmasına neden olmuş ise, kişi iki yıldan onbeş yıla kadar hapis cezası ile cezalandırılır.'''
        },
        {
          'no': '86',
          'baslik': 'Kasten yaralama',
          'icerik': '''(1) Kasten başkasının vücuduna acı veren veya sağlığının ya da algılama yeteneğinin bozulmasına neden olan kişi, bir yıldan üç yıla kadar hapis cezası ile cezalandırılır.
(2) Kasten yaralama fiilinin kişi üzerindeki etkisinin basit bir tıbbî müdahaleyle giderilebilecek ölçüde hafif olması hâlinde, mağdurun şikâyeti üzerine, dört aydan bir yıla kadar hapis veya adlî para cezasına hükmolunur.
(3) Kasten yaralama suçunun;
a) Üstsoya, altsoya, eşe, boşandığı eşe veya kardeşe karşı,
b) Beden veya ruh bakımından kendisini savunamayacak durumda bulunan kişiye karşı,
c) Kişinin yerine getirdiği kamu görevi nedeniyle,
d) Kamu görevlisinin sahip bulunduğu nüfuz kötüye kullanılmak suretiyle,
e) Silahla,
f) Canavarca hisle,
İşlenmesi halinde, şikâyet aranmaksızın, verilecek ceza yarı oranında, (f) bendi bakımından ise bir kat artırılır.'''
        },
        {
          'no': '87',
          'baslik': 'Neticesi sebebiyle ağırlaşmış yaralama',
          'icerik': '''(1) Kasten yaralama fiili, mağdurun;
a) Duyularından veya organlarından birinin işlevinin sürekli zayıflamasına,
b) Konuşmasında sürekli zorluğa,
c) Yüzünde sabit ize,
d) Yaşamını tehlikeye sokan bir duruma,
e) Gebe bir kadına karşı işlenip de çocuğunun vaktinden önce doğmasına,
Neden olmuşsa, yukarıdaki maddeye göre belirlenen ceza, bir kat artırılır. Ancak, verilecek ceza, birinci fıkraya giren hallerde üç yıldan, üçüncü fıkraya giren hallerde beş yıldan az olamaz.
(2) Kasten yaralama fiili, mağdurun;
a) İyileşmesi olanağı bulunmayan bir hastalığa veya bitkisel hayata girmesine,
b) Duyularından veya organlarından birinin işlevinin yitirilmesine,
c) Konuşma ya da çocuk yapma yeteneklerinin kaybolmasına,
d) Yüzünün sürekli değişikliğine,
e) Gebe bir kadına karşı işlenip de çocuğunun düşmesine,
Neden olmuşsa, yukarıdaki maddeye göre belirlenen ceza, iki kat artırılır. Ancak, verilecek ceza, birinci fıkraya giren hallerde beş yıldan, üçüncü fıkraya giren hallerde sekiz yıldan az olamaz.
(3) Kasten yaralamanın vücutta kemik kırılmasına veya çıkığına neden olması halinde, yukarıdaki maddeye göre belirlenen ceza, kırık veya çıkığın hayat fonksiyonlarındaki etkisine göre, yarısına kadar artırılır.
(4) Kasten yaralama sonucunda ölüm meydana gelmişse, yukarıdaki maddenin birinci fıkrasına giren hallerde sekiz yıldan oniki yıla kadar, üçüncü fıkrasına giren hallerde ise oniki yıldan onsekiz yıla kadar hapis cezasına hükmolunur.'''
        },
        {
          'no': '88',
          'baslik': 'Kasten yaralamanın ihmali davranışla işlenmesi',
          'icerik': '''(1) Kasten yaralamanın ihmali davranışla işlenmesi halinde, verilecek ceza üçte ikisine kadar indirilebilir. Bu hükmün uygulanmasında kasten öldürmenin ihmali davranışla işlenmesine ilişkin koşullar göz önünde bulundurulur.'''
        },
        {
          'no': '89',
          'baslik': 'Taksirle yaralama',
          'icerik': '''(1) Taksirle başkasının vücuduna acı veren veya sağlığının ya da algılama yeteneğinin bozulmasına neden olan kişi, üç aydan bir yıla kadar hapis veya adlî para cezası ile cezalandırılır.
(2) Taksirle yaralama fiili, mağdurun;
a) Duyularından veya organlarından birinin işlevinin sürekli zayıflamasına,
b) Vücudunda kemik kırılmasına,
c) Konuşmasında sürekli zorluğa,
d) Yüzünde sabit ize,
e) Yaşamını tehlikeye sokan bir duruma,
f) Gebe bir kadının çocuğunun vaktinden önce doğmasına,
Neden olmuşsa, birinci fıkraya göre belirlenen ceza, yarısı oranında artırılır.
(3) Taksirle yaralama fiili, mağdurun;
a) İyileşmesi olanağı bulunmayan bir hastalığa veya bitkisel hayata girmesine,
b) Duyularından veya organlarından birinin işlevinin yitirilmesine,
c) Konuşma ya da çocuk yapma yeteneklerinin kaybolmasına,
d) Yüzünün sürekli değişikliğine,
e) Gebe bir kadının çocuğunun düşmesine,
Neden olmuşsa, birinci fıkraya göre belirlenen ceza, bir kat artırılır.
(4) Fiilin birden fazla kişinin yaralanmasına neden olması halinde, altı aydan üç yıla kadar hapis cezasına hükmolunur.
(5) Taksirle yaralama suçunun soruşturulması ve kovuşturulması şikayete bağlıdır. Ancak, birinci fıkra kapsamına giren yaralama hariç, suçun bilinçli taksirle işlenmesi halinde şikayet aranmaz.'''
        },
        {
          'no': '90',
          'baslik': 'İnsan üzerinde deney',
          'icerik': '''(1) İnsan üzerinde bilimsel bir deney yapan kişi, bir yıldan üç yıla kadar hapis cezası ile cezalandırılır.
(2) İnsan üzerinde yapılan rızaya dayalı bilimsel deneyin ceza sorumluluğunu gerektirmemesi için;
a) Deneyle ilgili olarak yetkili kurul veya makamlardan gerekli iznin alınmış olması,
b) Deneyin öncelikle insan dışı deney ortamında veya yeterli sayıda hayvan üzerinde yapılmış olması,
c) İnsan dışı deney ortamında veya hayvanlar üzerinde yapılan deneyler sonucunda ulaşılan bilimsel verilerin, varılmak istenen hedefe ulaşmak açısından bunların insan üzerinde de yapılmasını gerekli kılması,
d) Deneyin, insan sağlığı üzerinde öngörülebilir zararlı ve kalıcı bir etki bırakmaması,
e) Deney sırasında kişiye insan onuruyla bağdaşmayacak ölçüde acı verici yöntemlerin uygulanmaması,
f) Deneyle varılmak istenen amacın, bunun kişiye yüklediği külfete ve kişinin sağlığı üzerindeki tehlikeye göre daha ağır basması,
g) Deneyin mahiyet ve sonuçları hakkında yeterli bilgilendirmeye dayalı olarak açıklanan rızanın yazılı olması ve herhangi bir menfaat teminine bağlı bulunmaması,
Gerekir.
(3) Çocuklar üzerinde bilimsel deney hiçbir surette yapılamaz.
(4) Hasta olan insan üzerinde rıza olmaksızın tedavi amaçlı denemede bulunan kişi, bir yıla kadar hapis cezası ile cezalandırılır. Ancak, bilinen tıbbi müdahale yöntemlerinin uygulanmasının sonuç vermeyeceğinin anlaşılması üzerine, kişi üzerinde yapılan rızaya dayalı bilimsel yöntemlere uygun tedavi amaçlı deneme, ceza sorumluluğunu gerektirmez. Açıklanan rızanın, denemenin mahiyet ve sonuçları hakkında yeterli bilgilendirmeye dayalı olarak yazılı olması ve tedavinin uzman hekim tarafından bir hastane ortamında yapılması gerekir.
(5) Birinci fıkrada tanımlanan suçun işlenmesi sonucunda mağdurun yaralanması veya ölmesi halinde, kasten yaralama veya kasten öldürme suçuna ilişkin hükümler uygulanır.
(6) Bu maddede tanımlanan suçların bir tüzel kişinin faaliyeti çerçevesinde işlenmesi halinde, tüzel kişi hakkında bunlara özgü güvenlik tedbirlerine hükmolunur.'''
        },
        {
          'no': '91',
          'baslik': 'Organ veya doku ticareti',
          'icerik': '''(1) Hukuken geçerli rızaya dayalı olmaksızın, kişiden organ alan kimse, beş yıldan dokuz yıla kadar hapis cezası ile cezalandırılır. Suçun konusunun doku olması halinde, iki yıldan beş yıla kadar hapis cezasına hükmolunur.
(2) Hukuka aykırı olarak, ölüden organ veya doku alan kimse, bir yıla kadar hapis cezası ile cezalandırılır.
(3) Organ veya doku satın alan, satan, satılmasına aracılık eden kişi hakkında, birinci fıkrada belirtilen cezalara hükmolunur.
(4) Bir ve üçüncü fıkralarda tanımlanan suçların bir örgütün faaliyeti çerçevesinde işlenmesi halinde, sekiz yıldan onbeş yıla kadar hapis ve onbin güne kadar adlî para cezasına hükmolunur.
(5) Hukuka aykırı yollarla elde edilmiş olan organ veya dokuyu saklayan, nakleden veya aşılayan kişi, iki yıldan beş yıla kadar hapis cezası ile cezalandırılır.
(6) Belli bir çıkar karşılığında organ veya doku teminine yönelik olarak ilan veya reklam veren veya yayınlayan kişi, bir yıla kadar hapis cezası ile cezalandırılır.
(7) Bu maddede tanımlanan suçların bir tüzel kişinin faaliyeti çerçevesinde işlenmesi halinde, tüzel kişi hakkında bunlara özgü güvenlik tedbirlerine hükmolunur.
(8) Birinci fıkrada tanımlanan suçun işlenmesi sonucunda mağdurun ölmesi halinde, kasten öldürme suçuna ilişkin hükümler uygulanır.'''
        },
        {
          'no': '94',
          'baslik': 'İşkence',
          'icerik': '''(1) Bir kişiye karşı insan onuruyla bağdaşmayan ve bedensel veya ruhsal yönden acı çekmesine, algılama veya irade yeteneğinin etkilenmesine, aşağılanmasına yol açacak davranışları gerçekleştiren kamu görevlisi hakkında üç yıldan oniki yıla kadar hapis cezasına hükmolunur.
(2) Suçun;
a) Çocuğa, beden veya ruh bakımından kendisini savunamayacak durumda bulunan kişiye ya da gebe kadına karşı,
b) Avukata veya diğer kamu görevlisine karşı görevi dolayısıyla,
İşlenmesi halinde, sekiz yıldan onbeş yıla kadar hapis cezasına hükmolunur.
(3) Fiilin cinsel yönden taciz şeklinde gerçekleşmesi halinde, on yıldan onbeş yıla kadar hapis cezasına hükmolunur.
(4) Bu suçun işlenişine iştirak eden diğer kişiler de kamu görevlisi gibi cezalandırılır.
(5) Bu suçun ihmali davranışla işlenmesi halinde, verilecek cezada bu nedenle indirim yapılmaz.
(6) Bu suçtan dolayı zamanaşımı işlemez.'''
        },
        {
          'no': '95',
          'baslik': 'Neticesi sebebiyle ağırlaşmış işkence',
          'icerik': '''(1) İşkence fiilleri, mağdurun;
a) Duyularından veya organlarından birinin işlevinin sürekli zayıflamasına,
b) Konuşmasında sürekli zorluğa,
c) Yüzünde sabit ize,
d) Yaşamını tehlikeye sokan bir duruma,
e) Gebe bir kadına karşı işlenip de çocuğunun vaktinden önce doğmasına,
Neden olmuşsa, yukarıdaki maddeye göre belirlenen ceza, yarı oranında artırılır.
(2) İşkence fiilleri, mağdurun;
a) İyileşmesi olanağı bulunmayan bir hastalığa veya bitkisel hayata girmesine,
b) Duyularından veya organlarından birinin işlevinin yitirilmesine,
c) Konuşma ya da çocuk yapma yeteneklerinin kaybolmasına,
d) Yüzünün sürekli değişikliğine,
e) Gebe bir kadına karşı işlenip de çocuğunun düşmesine,
Neden olmuşsa, yukarıdaki maddeye göre belirlenen ceza, bir kat artırılır.
(3) İşkence fiillerinin vücutta kemik kırılmasına neden olması halinde, kırığın hayat fonksiyonlarındaki etkisine göre sekiz yıldan onbeş yıla kadar hapis cezasına hükmolunur.
(4) İşkence sonucunda ölüm meydana gelmişse, ağırlaştırılmış müebbet hapis cezasına hükmolunur.'''
        },
        {
          'no': '96',
          'baslik': 'Eziyet',
          'icerik': '''(1) Bir kimsenin eziyet çekmesine yol açacak davranışları gerçekleştiren kişi hakkında iki yıldan beş yıla kadar hapis cezasına hükmolunur.
(2) Yukarıdaki fıkra kapsamına giren fiillerin;
a) Çocuğa, beden veya ruh bakımından kendisini savunamayacak durumda bulunan kişiye ya da gebe kadına karşı,
b) Üstsoy veya altsoya, babalık veya analığa ya da eşe veya boşandığı eşe karşı,
İşlenmesi halinde, üç yıldan sekiz yıla kadar hapis cezasına hükmolunur.'''
        },
      ],
    },
    {
      'baslik': 'Cinsel Suçlar',
      'alt': 'Madde 102-105',
      'emoji': '🚫',
      'icon': Icons.block,
      'color': const Color(0xFFFF5722),
      'maddeler': [
        {
          'no': '102',
          'baslik': 'Cinsel saldırı',
          'icerik': '''(1) Cinsel davranışlarla bir kimsenin vücut dokunulmazlığını ihlâl eden kişi, mağdurun şikâyeti üzerine, beş yıldan on yıla kadar hapis cezası ile cezalandırılır. Cinsel davranışın sarkıntılık düzeyinde kalması hâlinde iki yıldan beş yıla kadar hapis cezası verilir.
(2) Fiilin vücuda organ veya sair bir cisim sokulması suretiyle gerçekleştirilmesi durumunda, on iki yıldan az olmamak üzere hapis cezasına hükmolunur. Bu fiilin eşe karşı işlenmesi hâlinde, soruşturma ve kovuşturmanın yapılması mağdurun şikâyetine bağlıdır.
(3) Suçun;
a) Beden veya ruh bakımından kendisini savunamayacak durumda bulunan kişiye karşı,
b) Kamu görevinin, vesayet veya hizmet ilişkisinin sağladığı nüfuz kötüye kullanılmak suretiyle,
c) Üçüncü derece dâhil kan veya kayın hısımlığı ilişkisi içinde bulunan bir kişiye karşı ya da üvey baba, üvey ana, üvey kardeş, evlat edinen veya evlatlık tarafından,
d) Silahla veya birden fazla kişi tarafından birlikte,
e) İnsanların toplu olarak bir arada yaşama zorunluluğunda bulunduğu ortamların sağladığı kolaylıktan faydalanmak suretiyle,
İşlenmesi hâlinde, yukarıdaki fıkralara göre verilen cezalar yarı oranında artırılır.
(4) Suçun işlenmesi sırasında mağdurun direncinin kırılmasını sağlayacak ölçünün ötesinde cebir kullanılması durumunda kişi ayrıca kasten yaralama suçundan dolayı cezalandırılır.
(5) Suç sonucu mağdurun bitkisel hayata girmesi veya ölümü hâlinde, ağırlaştırılmış müebbet hapis cezasına hükmolunur.'''
        },
        {
          'no': '103',
          'baslik': 'Çocukların cinsel istismarı',
          'icerik': '''(1) Çocuğu cinsel yönden istismar eden kişi, sekiz yıldan on beş yıla kadar hapis cezası ile cezalandırılır. Cinsel istismarın sarkıntılık düzeyinde kalması hâlinde üç yıldan sekiz yıla kadar hapis cezasına hükmolunur. Mağdurun on iki yaşını tamamlamamış olması hâlinde verilecek ceza, istismar durumunda on yıldan, sarkıntılık durumunda beş yıldan az olamaz. Sarkıntılık düzeyinde kalmış suçun failinin çocuk olması hâlinde soruşturma ve kovuşturma yapılması mağdurun, velisinin veya vasisinin şikâyetine bağlıdır.
(2) Cinsel istismarın vücuda organ veya sair bir cisim sokulması suretiyle gerçekleştirilmesi durumunda, on altı yıldan aşağı olmamak üzere hapis cezasına hükmolunur. Mağdurun on iki yaşını tamamlamamış olması hâlinde verilecek ceza on sekiz yıldan az olamaz.
(3) Suçun;
a) Birden fazla kişi tarafından birlikte,
b) İnsanların toplu olarak bir arada yaşama zorunluluğunda bulunduğu ortamların sağladığı kolaylıktan faydalanmak suretiyle,
c) Üçüncü derece dâhil kan veya kayın hısımlığı ilişkisi içinde bulunan bir kişiye karşı ya da üvey baba, üvey ana, üvey kardeş veya evlat edinen tarafından,
d) Vasi, eğitici, öğretici, bakıcı, koruyucu aile veya sağlık hizmeti veren ya da koruma, bakım veya gözetim yükümlülüğü bulunan kişiler tarafından,
e) Kamu görevinin veya hizmet ilişkisinin sağladığı nüfuz kötüye kullanılmak suretiyle,
İşlenmesi hâlinde, yukarıdaki fıkralara göre verilecek ceza yarı oranında artırılır.
(4) Cinsel istismarın, birinci fıkranın ikinci cümlesinde sayılan kişiler tarafından ya da silâhla veya birden fazla kişi tarafından birlikte gerçekleştirilmesi hâlinde, yukarıdaki fıkralara göre verilecek ceza yarı oranında artırılır.
(5) Cinsel istismar için başvurulan cebir ve şiddetin kasten yaralama suçunun ağır neticelerine neden olması hâlinde, ayrıca kasten yaralama suçuna ilişkin hükümler uygulanır.
(6) Suç sonucu mağdurun bitkisel hayata girmesi veya ölümü hâlinde, ağırlaştırılmış müebbet hapis cezasına hükmolunur.'''
        },
        {
          'no': '104',
          'baslik': 'Reşit olmayanla cinsel ilişki',
          'icerik': '''(1) Cebir, tehdit ve hile olmaksızın, onbeş yaşını bitirmiş olan çocukla cinsel ilişkide bulunan kişi, şikayet üzerine, iki yıldan beş yıla kadar hapis cezası ile cezalandırılır.
(2) Suçun mağdur ile arasında evlenme yasağı bulunan kişi tarafından işlenmesi hâlinde, şikâyet aranmaksızın, on yıldan on beş yıla kadar hapis cezasına hükmolunur.
(3) Suçun, evlat edineceği çocuğun evlat edinme öncesi bakımını üstlenen veya koruyucu aile ilişkisi çerçevesinde koruma, bakım ve gözetim yükümlülüğü bulunan kişi tarafından işlenmesi hâlinde, şikâyet aranmaksızın ikinci fıkraya göre cezaya hükmolunur.'''
        },
        {
          'no': '105',
          'baslik': 'Cinsel taciz',
          'icerik': '''(1) Bir kimseyi cinsel amaçlı olarak taciz eden kişi hakkında, mağdurun şikayeti üzerine, üç aydan iki yıla kadar hapis cezasına veya adlî para cezasına, fiilin çocuğa karşı işlenmesi hâlinde altı aydan üç yıla kadar hapis cezasına hükmolunur.
(2) Suçun;
a) Kamu görevinin veya hizmet ilişkisinin ya da aile içi ilişkinin sağladığı kolaylıktan faydalanmak suretiyle,
b) Vasi, eğitici, öğretici, bakıcı, koruyucu aile veya sağlık hizmeti veren ya da koruma, bakım veya gözetim yükümlülüğü bulunan kişiler tarafından,
c) Aynı işyerinde çalışmanın sağladığı kolaylıktan faydalanmak suretiyle,
d) Posta veya elektronik haberleşme araçlarının sağladığı kolaylıktan faydalanmak suretiyle,
e) Teşhir suretiyle,
İşlenmesi hâlinde yukarıdaki fıkraya göre verilecek ceza yarı oranında artırılır. Bu fiil nedeniyle mağdur; işi bırakmak, okuldan veya ailesinden ayrılmak zorunda kalmış ise verilecek ceza bir yıldan az olamaz.'''
        },
      ],
    },
    {
      'baslik': 'Hürriyet Suçları',
      'alt': 'Madde 106-124',
      'emoji': '⛓️',
      'icon': Icons.link_off,
      'color': const Color(0xFF2ECC71),
      'maddeler': [
        {
          'no': '106',
          'baslik': 'Tehdit',
          'icerik': '''(1) Bir başkasını, kendisinin veya yakınının hayatına, vücut veya cinsel dokunulmazlığına yönelik bir saldırı gerçekleştireceğinden bahisle tehdit eden kişi, altı aydan iki yıla kadar hapis cezası ile cezalandırılır. Malvarlığı itibarıyla büyük bir zarara uğratacağından veya sair bir kötülük edeceğinden bahisle tehditte ise, mağdurun şikayeti üzerine, altı aya kadar hapis veya adlî para cezasına hükmolunur.
(2) Tehdidin;
a) Silahla,
b) Kişinin kendisini tanınmayacak bir hale koyması suretiyle, imzasız mektupla veya özel işaretlerle,
c) Birden fazla kişi tarafından birlikte,
d) Var olan veya var sayılan suç örgütlerinin oluşturdukları korkutucu güçten yararlanılarak,
İşlenmesi halinde, fail hakkında iki yıldan beş yıla kadar hapis cezasına hükmolunur.
(3) Tehdit amacıyla kasten öldürme, kasten yaralama veya malvarlığına zarar verme suçunun işlenmesi halinde, ayrıca bu suçlardan dolayı ceza verilir.'''
        },
        {
          'no': '107',
          'baslik': 'Şantaj',
          'icerik': '''(1) Hakkı olan veya yükümlü olduğu bir şeyi yapacağından veya yapmayacağından bahisle, bir kimseyi kanuna aykırı veya yükümlü olmadığı bir şeyi yapmaya veya yapmamaya ya da haksız çıkar sağlamaya zorlayan kişi, bir yıldan üç yıla kadar hapis ve beşbin güne kadar adlî para cezası ile cezalandırılır.
(2) Kendisine veya başkasına yarar sağlamak maksadıyla bir kişinin şeref veya saygınlığına zarar verecek nitelikteki hususların açıklanacağı veya isnat edileceği tehdidinde bulunulması halinde de birinci fıkraya göre cezaya hükmolunur.'''
        },
        {
          'no': '108',
          'baslik': 'Cebir',
          'icerik': '''(1) Bir şeyi yapması veya yapmaması ya da kendisinin yapmasına müsaade etmesi için bir kişiye cebir kullanılması halinde, kasten yaralama suçundan verilecek ceza üçte birinden yarısına kadar artırılarak hükmolunur.'''
        },
        {
          'no': '109',
          'baslik': 'Kişiyi hürriyetinden yoksun kılma',
          'icerik': '''(1) Bir kimseyi hukuka aykırı olarak bir yere gitmek veya bir yerde kalmak hürriyetinden yoksun bırakan kişiye, bir yıldan beş yıla kadar hapis cezası verilir.
(2) Kişi, fiili işlemek için veya işlediği sırada cebir, tehdit veya hile kullanırsa, iki yıldan yedi yıla kadar hapis cezasına hükmolunur.
(3) Bu suçun;
a) Silahla,
b) Birden fazla kişi tarafından birlikte,
c) Kişinin yerine getirdiği kamu görevi nedeniyle,
d) Kamu görevinin sağladığı nüfuz kötüye kullanılmak suretiyle,
e) Üstsoy, altsoy veya eşe karşı,
f) Çocuğa ya da beden veya ruh bakımından kendini savunamayacak durumda bulunan kişiye karşı,
İşlenmesi halinde, yukarıdaki fıkralara göre verilecek ceza bir kat artırılır.
(4) Bu suçun mağdurun ekonomik bakımdan önemli bir kaybına neden olması halinde, ayrıca bin güne kadar adlî para cezasına hükmolunur.
(5) Suçun cinsel amaçla işlenmesi halinde, yukarıdaki fıkralara göre verilecek cezalar yarı oranında artırılır.
(6) Bu suçun işlenmesi amacıyla veya sırasında kasten yaralama suçunun neticesi sebebiyle ağırlaşmış hallerinin gerçekleşmesi durumunda, ayrıca kasten yaralama suçuna ilişkin hükümler uygulanır.'''
        },
        {
          'no': '112',
          'baslik': 'Eğitim ve öğretimin engellenmesi',
          'icerik': '''(1) Cebir veya tehdit kullanılarak ya da hukuka aykırı başka bir davranışla;
a) Devletçe kurulan veya kamu makamlarının verdiği izne dayalı olarak yürütülen her türlü eğitim ve öğretim faaliyetlerine,
b) Kişinin eğitim ve öğretim hakkının kullanmasına,
c) Öğrencilerin toplu olarak oturdukları binalara veya bunların eklentilerine girilmesine veya orada kalınmasına,
Engel olunması halinde, bir yıldan üç yıla kadar hapis cezasına hükmolunur.'''
        },
        {
          'no': '113',
          'baslik': 'Kamu hizmetlerinden yararlanma hakkının engellenmesi',
          'icerik': '''(1) Cebir veya tehdit kullanılarak ya da hukuka aykırı başka bir davranışla;
a) Bir kamu faaliyetinin yürütülmesine,
b) Kamu kurumlarında veya kamu kurumu niteliğindeki meslek kuruluşlarında verilen ya da kamu makamlarının verdiği izne dayalı olarak sunulan hizmetlerden yararlanılmasına,
Engel olunması halinde, iki yıldan beş yıla kadar hapis cezasına hükmolunur.'''
        },
        {
          'no': '114',
          'baslik': 'Siyasi hakların kullanılmasının engellenmesi',
          'icerik': '''(1) Bir kimseye karşı;
a) Bir siyasi partiye girmeye veya girmemeye, siyasi partiden veya siyasi parti yönetimindeki görevinden ayrılmaya,
b) Seçim yoluyla gelinen bir kamu görevine aday olmamaya veya seçildiği görevi kabul etmemeye veya bu görevden ayrılmaya,
Zorlamak amacıyla, cebir veya tehdit kullanan kişi, bir yıldan üç yıla kadar hapis cezası ile cezalandırılır.
(2) Cebir veya tehdit kullanarak ya da hukuka aykırı başka bir davranışla bir siyasi partinin faaliyetlerinin engellenmesi halinde, iki yıldan beş yıla kadar hapis cezasına hükmolunur.'''
        },
        {
          'no': '115',
          'baslik': 'İnanç, düşünce ve kanaat hürriyetinin kullanılmasını engelleme',
          'icerik': '''(1) Cebir veya tehdit kullanarak, bir kimseyi dini, siyasi, sosyal, felsefi inanç, düşünce ve kanaatlerini açıklamaya veya değiştirmeye zorlayan ya da bunları açıklamaktan, yaymaktan meneden kişi, bir yıldan üç yıla kadar hapis cezası ile cezalandırılır.
(2) Dini ibadet ve ayinlerin toplu olarak yapılmasının, cebir veya tehdit kullanılarak ya da hukuka aykırı başka bir davranışla engellenmesi halinde, yukarıdaki fıkraya göre ceza verilir.
(3) Cebir veya tehdit kullanarak ya da hukuka aykırı başka bir davranışla bir kimsenin inanç, düşünce veya kanaatlerinden kaynaklanan yaşam tarzına ilişkin tercihlerine müdahale eden veya bunları değiştirmeye zorlayan kişiye birinci fıkra hükmüne göre ceza verilir.'''
        },
        {
          'no': '116',
          'baslik': 'Konut dokunulmazlığının ihlali',
          'icerik': '''(1) Bir kimsenin konutuna, konutunun eklentilerine rızasına aykırı olarak giren veya rıza ile girdikten sonra buradan çıkmayan kişi, mağdurun şikayeti üzerine, altı aydan iki yıla kadar hapis cezası ile cezalandırılır.
(2) Birinci fıkra kapsamına giren fiillerin, açık bir rızaya gerek duyulmaksızın girilmesi mutat olan yerler dışında kalan işyerleri ve eklentileri hakkında işlenmesi hâlinde, mağdurun şikâyeti üzerine altı aydan bir yıla kadar hapis veya adlî para cezasına hükmolunur.
(3) Evlilik birliğinde aile bireylerinden ya da konutun veya işyerinin birden fazla kişi tarafından ortak kullanılması durumunda, bu kişilerden birinin rızası varsa, yukarıdaki fıkralar hükümleri uygulanmaz. Ancak bunun için rıza açıklamasının meşru bir amaca yönelik olması gerekir.
(4) Fiilin, cebir veya tehdit kullanılmak suretiyle ya da gece vakti işlenmesi halinde, bir yıldan üç yıla kadar hapis cezasına hükmolunur.'''
        },
        {
          'no': '117',
          'baslik': 'İş ve çalışma hürriyetinin ihlali',
          'icerik': '''(1) Cebir veya tehdit kullanarak ya da hukuka aykırı başka bir davranışla, iş ve çalışma hürriyetini ihlal eden kişiye, mağdurun şikayeti halinde, altı aydan iki yıla kadar hapis veya adlî para cezası verilir.
(2) Çaresizliğini, kimsesizliğini ve bağlılığını sömürmek suretiyle kişi veya kişileri ücretsiz olarak veya sağladığı hizmet ile açık bir şekilde orantısız düşük bir ücretle çalıştıran veya bu durumda bulunan kişiyi, insan onuru ile bağdaşmayacak çalışma ve konaklama koşullarına tabi kılan kimseye altı aydan üç yıla kadar hapis veya yüz günden az olmamak üzere adlî para cezası verilir.
(3) Yukarıdaki fıkrada belirtilen durumlara düşürülen kişiyi, insan onuru ile bağdaşmayacak çalışma ve konaklama koşullarına tabi kılan kimseye bir yıldan üç yıla kadar hapis cezası verilir.
(4) Cebir veya tehdit kullanarak, işçiyi veya işverenlerini ücretleri azaltmaya veya yükseltmeye ya da evvelce kabul edilenlerden başka koşullar altında anlaşmalar kabulüne zorlayan kimseye altı aydan üç yıla kadar hapis cezası verilir.'''
        },
        {
          'no': '118',
          'baslik': 'Sendikal hakların kullanılmasının engellenmesi',
          'icerik': '''(1) Bir kimseye karşı bir sendikaya üye olmaya veya olmamaya, sendikanın faaliyetlerine katılmaya veya katılmamaya, sendikadan veya sendika yönetimindeki görevinden ayrılmaya zorlamak amacıyla, cebir veya tehdit kullanan kişi, altı aydan iki yıla kadar hapis cezası ile cezalandırılır.
(2) Cebir veya tehdit kullanılarak ya da hukuka aykırı başka bir davranışla bir sendikanın faaliyetlerinin engellenmesi halinde, bir yıldan üç yıla kadar hapis cezasına hükmolunur.'''
        },
        {
          'no': '120',
          'baslik': 'Haksız arama',
          'icerik': '''(1) Hukuka aykırı olarak bir kimsenin üstünü veya eşyasını arayan kamu görevlisine üç aydan bir yıla kadar hapis cezası verilir.'''
        },
        {
          'no': '121',
          'baslik': 'Dilekçe hakkının kullanılmasının engellenmesi',
          'icerik': '''(1) Kişinin belli bir hakkı kullanmak için yetkili kamu makamlarına verdiği dilekçenin hukuki bir neden olmaksızın kabul edilmemesi halinde, fail hakkında altı aya kadar hapis cezasına hükmolunur.'''
        },
        {
          'no': '122',
          'baslik': 'Nefret ve ayrımcılık',
          'icerik': '''(1) Dil, ırk, milliyet, renk, cinsiyet, engellilik, siyasi düşünce, felsefi inanç, din veya mezhep farklılığından kaynaklanan nefret nedeniyle;
a) Bir kişiye kamuya arz edilmiş olan bir taşınır veya taşınmaz malın satılmasını, devrini veya kiraya verilmesini,
b) Bir kişinin kamuya arz edilmiş belli bir hizmetten yararlanmasını,
c) Bir kişinin işe alınmasını,
d) Bir kişinin olağan bir ekonomik etkinlikte bulunmasını,
Engelleyen kimse, bir yıldan üç yıla kadar hapis cezası ile cezalandırılır.'''
        },
        {
          'no': '123',
          'baslik': 'Kişilerin huzur ve sükununu bozma',
          'icerik': '''(1) Sırf huzur ve sükûnunu bozmak maksadıyla bir kimseye ısrarla; telefon edilmesi, gürültü yapılması ya da aynı maksatla hukuka aykırı başka bir davranışta bulunulması halinde, mağdurun şikayeti üzerine faile üç aydan bir yıla kadar hapis cezası verilir.'''
        },
        {
          'no': '124',
          'baslik': 'Haberleşmenin engellenmesi',
          'icerik': '''(1) Kişiler arasındaki haberleşmenin hukuka aykırı olarak engellenmesi halinde, altı aydan iki yıla kadar hapis veya adlî para cezasına hükmolunur.
(2) Kamu kurumları arasındaki haberleşmeyi hukuka aykırı olarak engelleyen kişi, bir yıldan beş yıla kadar hapis cezası ile cezalandırılır.
(3) Her türlü basın ve yayın organının yayınının hukuka aykırı bir şekilde engellenmesi halinde, ikinci fıkra hükmüne göre cezaya hükmolunur.'''
        },
      ],
    },
    {
      'baslik': 'Şerefe Karşı Suçlar',
      'alt': 'Madde 125-131',
      'emoji': '💬',
      'icon': Icons.chat_bubble_outline,
      'color': const Color(0xFF1ABC9C),
      'maddeler': [
        {
          'no': '125',
          'baslik': 'Hakaret',
          'icerik': '''(1) Bir kimseye onur, şeref ve saygınlığını rencide edebilecek nitelikte somut bir fiil veya olgu isnat eden veya sövmek suretiyle bir kimsenin onur, şeref ve saygınlığına saldıran kişi, üç aydan iki yıla kadar hapis veya adlî para cezası ile cezalandırılır. Mağdurun gıyabında hakaretin cezalandırılabilmesi için fiilin en az üç kişiyle ihtilat ederek işlenmesi gerekir.
(2) Fiilin, mağduru muhatap alan sesli, yazılı veya görüntülü bir iletiyle işlenmesi halinde, yukarıdaki fıkrada belirtilen cezaya hükmolunur.
(3) Hakaret suçunun;
a) Kamu görevlisine karşı görevinden dolayı,
b) Dini, siyasi, sosyal, felsefi inanç, düşünce ve kanaatlerini açıklamasından, değiştirmesinden, yaymaya çalışmasından, mensup olduğu dinin emir ve yasaklarına uygun davranmasından dolayı,
c) Kişinin mensup bulunduğu dine göre kutsal sayılan değerlerden bahisle,
İşlenmesi halinde, cezanın alt sınırı bir yıldan az olamaz.
(4) Hakaretin alenen işlenmesi halinde ceza altıda biri oranında artırılır.
(5) Kurul hâlinde çalışan kamu görevlilerine görevlerinden dolayı hakaret edilmesi hâlinde suç, kurulu oluşturan üyelere karşı işlenmiş sayılır. Ancak, bu durumda zincirleme suça ilişkin madde hükümleri uygulanır.'''
        },
        {
          'no': '126',
          'baslik': 'Mağdurun belirlenmesi',
          'icerik': '''(1) Hakaret suçunun işlenmesinde mağdurun ismi açıkça belirtilmemiş veya isnat üstü kapalı geçiştirilmiş olsa bile, eğer niteliğinde ve mağdurun şahsına yönelik bulunduğunda duraksanmayacak bir durum varsa, hem ismi belirtilmiş ve hem de hakaret açıklanmış sayılır.'''
        },
        {
          'no': '127',
          'baslik': 'İsnadın ispatı',
          'icerik': '''(1) İsnat edilen ve suç oluşturan fiilin ispat edilmiş olması halinde kişiye ceza verilmez. Bu suç nedeniyle hakaret edilen hakkında kesinleşmiş bir mahkumiyet kararı verilmesi halinde, isnat ispatlanmış sayılır. Bunun dışındaki hallerde isnadın ispat isteminin kabulü, ancak isnat olunan fiilin doğru olup olmadığının anlaşılmasında kamu yararı bulunmasına veya şikayetçinin ispata razı olmasına bağlıdır.
(2) İspat edilmiş fiilinden söz edilerek kişiye hakaret edilmesi halinde, cezaya hükmedilir.'''
        },
        {
          'no': '128',
          'baslik': 'İddia ve savunma dokunulmazlığı',
          'icerik': '''(1) Yargı mercileri veya idari makamlar nezdinde yapılan yazılı veya sözlü başvuru, iddia ve savunmalar kapsamında, kişilerle ilgili olarak somut isnadlarda ya da olumsuz değerlendirmelerde bulunulması halinde, ceza verilmez. Ancak, bunun için isnat ve değerlendirmelerin, gerçek ve somut vakıalara dayanması ve uyuşmazlıkla bağlantılı olması gerekir.'''
        },
        {
          'no': '129',
          'baslik': 'Haksız fiil nedeniyle veya karşılıklı hakaret',
          'icerik': '''(1) Hakaret suçunun haksız bir fiile tepki olarak işlenmesi halinde, verilecek ceza üçte birine kadar indirilebileceği gibi, ceza vermekten de vazgeçilebilir.
(2) Bu suçun, kasten yaralama suçuna tepki olarak işlenmesi halinde, kişiye ceza verilmez.
(3) Hakaret suçunun karşılıklı olarak işlenmesi halinde, olayın mahiyetine göre, taraflardan her ikisi veya biri hakkında verilecek ceza üçte birine kadar indirilebileceği gibi, ceza vermekten de vazgeçilebilir.'''
        },
        {
          'no': '130',
          'baslik': 'Kişinin hatırasına hakaret',
          'icerik': '''(1) Bir kimsenin öldükten sonra hatırasına en az üç kişiyle ihtilat ederek hakaret eden kişi, üç aydan iki yıla kadar hapis veya adlî para cezası ile cezalandırılır. Ceza, hakaretin alenen işlenmesi halinde, altıda biri oranında artırılır.
(2) Bir ölünün kısmen veya tamamen ceset veya kemiklerini alan veya ceset veya kemikler hakkında tahkir edici fiillerde bulunan kişi, üç aydan iki yıla kadar hapis cezası ile cezalandırılır.'''
        },
        {
          'no': '131',
          'baslik': 'Soruşturma ve kovuşturma koşulu',
          'icerik': '''(1) Kamu görevlisine karşı görevinden dolayı işlenen hariç; hakaret suçunun soruşturulması ve kovuşturulması, mağdurun şikayetine bağlıdır.
(2) Mağdur, şikayet etmeden önce ölürse, veya suç ölmüş olan kişinin hatırasına karşı işlenmiş ise; ölenin ikinci dereceye kadar üstsoy ve altsoyu, eş veya kardeşleri tarafından şikayette bulunulabilir.'''
        },
      ],
    },
    {
      'baslik': 'Özel Hayat & Kişisel Veriler',
      'alt': 'Madde 132-138',
      'emoji': '🔒',
      'icon': Icons.lock_person,
      'color': const Color(0xFF8E44AD),
      'maddeler': [
        {
          'no': '132',
          'baslik': 'Haberleşmenin gizliliğini ihlal',
          'icerik': '''(1) Kişiler arasındaki haberleşmenin gizliliğini ihlal eden kimse, bir yıldan üç yıla kadar hapis cezası ile cezalandırılır. Bu gizlilik ihlali haberleşme içeriklerinin kaydı suretiyle gerçekleşirse, verilecek ceza bir kat artırılır.
(2) Kişiler arasındaki haberleşme içeriklerini hukuka aykırı olarak ifşa eden kimse, iki yıldan beş yıla kadar hapis cezası ile cezalandırılır.
(3) Kendisiyle yapılan haberleşmelerin içeriğini diğer tarafın rızası olmaksızın hukuka aykırı olarak alenen ifşa eden kişi, bir yıldan üç yıla kadar hapis cezası ile cezalandırılır. İfşa edilen bu verilerin basın ve yayın yoluyla yayımlanması halinde de aynı cezaya hükmolunur.'''
        },
        {
          'no': '133',
          'baslik': 'Kişiler arasındaki konuşmaların dinlenmesi ve kayda alınması',
          'icerik': '''(1) Kişiler arasındaki aleni olmayan konuşmaları, taraflardan herhangi birinin rızası olmaksızın bir aletle dinleyen veya bunları bir ses alma cihazı ile kaydeden kişi, iki yıldan beş yıla kadar hapis cezası ile cezalandırılır.
(2) Katıldığı aleni olmayan bir söyleşiyi, diğer konuşanların rızası olmadan ses alma cihazı ile kayda alan kişi, altı aydan iki yıla kadar hapis veya adlî para cezası ile cezalandırılır.
(3) Kişiler arasındaki aleni olmayan konuşmaların kaydedilmesi suretiyle elde edilen verileri hukuka aykırı olarak ifşa eden kişi, iki yıldan beş yıla kadar hapis ve dörtbin güne kadar adlî para cezası ile cezalandırılır. İfşa edilen bu verilerin basın ve yayın yoluyla yayımlanması halinde de aynı cezaya hükmolunur.'''
        },
        {
          'no': '134',
          'baslik': 'Özel hayatın gizliliğini ihlal',
          'icerik': '''(1) Kişilerin özel hayatının gizliliğini ihlal eden kimse, bir yıldan üç yıla kadar hapis cezası ile cezalandırılır. Gizliliğin görüntü veya seslerin kayda alınması suretiyle ihlal edilmesi halinde, verilecek ceza bir kat artırılır.
(2) Kişilerin özel hayatına ilişkin görüntü veya sesleri hukuka aykırı olarak ifşa eden kimse iki yıldan beş yıla kadar hapis cezası ile cezalandırılır. İfşa edilen bu verilerin basın ve yayın yoluyla yayımlanması halinde de aynı cezaya hükmolunur.'''
        },
        {
          'no': '135',
          'baslik': 'Kişisel verilerin kaydedilmesi',
          'icerik': '''(1) Hukuka aykırı olarak kişisel verileri kaydeden kimseye bir yıldan üç yıla kadar hapis cezası verilir.
(2) Kişisel verinin, kişilerin siyasi, felsefi veya dini görüşlerine, ırki kökenlerine; hukuka aykırı olarak ahlaki eğilimlerine, cinsel yaşamlarına, sağlık durumlarına veya sendikal bağlantılarına ilişkin olması durumunda birinci fıkra uyarınca verilecek ceza yarı oranında artırılır.'''
        },
        {
          'no': '136',
          'baslik': 'Verileri hukuka aykırı olarak verme veya ele geçirme',
          'icerik': '''(1) Kişisel verileri, hukuka aykırı olarak bir başkasına veren, yayan veya ele geçiren kişi, iki yıldan dört yıla kadar hapis cezası ile cezalandırılır.
(2) Suçun konusunun, Ceza Muhakemesi Kanununun 236 ncı maddesinin beşinci ve altıncı fıkraları uyarınca kayda alınan beyan ve görüntüler olması durumunda verilecek ceza bir kat artırılır.'''
        },
        {
          'no': '137',
          'baslik': 'Nitelikli haller',
          'icerik': '''(1) Yukarıdaki maddelerde tanımlanan suçların;
a) Kamu görevlisi tarafından ve görevinin verdiği yetki kötüye kullanılmak suretiyle,
b) Belli bir meslek ve sanatın sağladığı kolaylıktan yararlanmak suretiyle,
İşlenmesi halinde, verilecek ceza yarı oranında artırılır.'''
        },
        {
          'no': '138',
          'baslik': 'Verileri yok etmeme',
          'icerik': '''(1) Kanunların belirlediği sürelerin geçmiş olmasına karşın verileri sistem içinde yok etmekle yükümlü olanlara bu görevlerini yerine getirmediklerinde bir yıldan iki yıla kadar hapis cezası verilir.
(2) Suçun konusunun, Ceza Muhakemesi Kanunu hükümlerine göre ortadan kaldırılması veya yok edilmesi gereken veri olması hâlinde verilecek ceza bir kat artırılır.'''
        },
      ],
    },
    {
      'baslik': 'Malvarlığına Karşı Suçlar',
      'alt': 'Madde 141-169',
      'emoji': '💰',
      'icon': Icons.attach_money,
      'color': const Color(0xFFF39C12),
      'maddeler': [
        {
          'no': '141',
          'baslik': 'Hırsızlık',
          'icerik': '''(1) Zilyedinin rızası olmadan başkasına ait taşınır bir malı, kendisine veya başkasına bir yarar sağlamak maksadıyla bulunduğu yerden alan kimseye bir yıldan üç yıla kadar hapis cezası verilir.'''
        },
        {
          'no': '142',
          'baslik': 'Nitelikli hırsızlık',
          'icerik': '''(1) Hırsızlık suçunun;
a) Kime ait olursa olsun kamu kurum ve kuruluşlarında veya ibadete ayrılmış yerlerde bulunan ya da kamu yararına veya hizmetine tahsis edilen eşya hakkında,
b) Halkın yararlanmasına sunulmuş ulaşım aracı içinde veya bunların belli varış veya kalkış yerlerinde bulunan eşya hakkında,
c) Bir afet veya genel bir felaketin meydana getirebileceği zararları önlemek veya hafifletmek maksadıyla hazırlanan eşya hakkında,
d) Adet veya tahsis veya kullanımları gereği açıkta bırakılmış eşya hakkında,
e) (Mülga : 2/7/2012 – 6352/82 md.)
İşlenmesi hâlinde, üç yıldan yedi yıla kadar hapis cezasına hükmolunur.
(2) Suçun;
a) Kişinin malını koruyamayacak durumda olmasından veya ölmesinden yararlanarak,
b) Elde veya üstte taşınan eşyayı çekip almak suretiyle ya da özel beceriyle,
c) Doğal bir afetin veya sosyal olayların meydana getirdiği korku veya kargaşadan yararlanarak,
d) Haksız yere elde bulundurulan veya taklit anahtarla ya da diğer bir aletle kilit açmak veya kilitlenmesini engellemek suretiyle,
e) Bilişim sistemlerinin kullanılması suretiyle,
f) Tanınmamak için tedbir alarak veya yetkisi olmadığı halde resmi sıfat takınarak,
g) Büyük veya küçük baş hayvan hakkında,
h) Herkesin girebileceği bir yerde bırakılmakla birlikte kilitlenmek suretiyle ya da bina veya eklentileri içinde muhafaza altına alınmış olan eşya hakkında,
İşlenmesi hâlinde, beş yıldan on yıla kadar hapis cezasına hükmolunur. Suçun, bu fıkranın (b) bendinde belirtilen surette, beden veya ruh bakımından kendisini savunamayacak durumda olan kimseye karşı işlenmesi halinde, verilecek ceza üçte biri oranına kadar artırılır.
(3) Suçun, sıvı veya gaz hâlindeki enerji hakkında ve bunların nakline, işlenmesine veya depolanmasına ait tesislerde işlenmesi halinde, beş yıldan oniki yıla kadar hapis cezasına hükmolunur. Bu fiilin bir örgütün faaliyeti çerçevesinde işlenmesi halinde, ceza yarı oranında artırılır ve onbin güne kadar adlî para cezasına hükmolunur.
(4) Hırsızlık suçunun işlenmesi amacıyla konut dokunulmazlığının ihlâli veya mala zarar verme suçunun işlenmesi halinde, bu suçlardan dolayı soruşturma ve kovuşturma yapılabilmesi için şikâyet aranmaz.
(5) Hırsızlık suçunun işlenmesi sonucunda haberleşme, enerji ya da demiryolu veya havayolu ulaşımı alanında kamu hizmetinin geçici de olsa aksaması hâlinde, yukarıdaki fıkralar hükümlerine göre verilecek ceza yarısından iki katına kadar artırılır.'''
        },
        {
          'no': '144',
          'baslik': 'Daha az cezayı gerektiren haller',
          'icerik': '''(1) Hırsızlık suçunun;
a) Paydaş veya elbirliği ile malik olunan mal üzerinde,
b) Bir hukuki ilişkiye dayanan alacağı tahsil amacıyla,
İşlenmesi halinde, şikayet üzerine, fail hakkında iki aydan bir yıla kadar hapis veya adlî para cezasına hükmolunur.'''
        },
        {
          'no': '145',
          'baslik': 'Malın değerinin az olması',
          'icerik': '''(1) Hırsızlık suçunun konusunu oluşturan malın değerinin azlığı nedeniyle, verilecek cezada indirim yapılabileceği gibi, suçun işleniş şekli ve özellikleri de göz önünde bulundurularak, ceza vermekten de vazgeçilebilir.'''
        },
        {
          'no': '146',
          'baslik': 'Kullanma hırsızlığı',
          'icerik': '''(1) Hırsızlık suçunun, malın geçici bir süre kullanılıp zilyedine iade edilmek üzere işlenmesi halinde, şikayet üzerine, verilecek ceza yarı oranına kadar indirilir. Ancak malın suç işlemek için kullanılmış olması halinde bu hüküm uygulanmaz.'''
        },
        {
          'no': '148',
          'baslik': 'Yağma',
          'icerik': '''(1) Bir başkasını, kendisinin veya yakınının hayatına, vücut veya cinsel dokunulmazlığına yönelik bir saldırı gerçekleştireceğinden ya da malvarlığı itibarıyla büyük bir zarara uğratacağından bahisle tehdit ederek veya cebir kullanarak, bir malı teslime veya malın alınmasına karşı koymamaya mecbur kılan kişi, altı yıldan on yıla kadar hapis cezası ile cezalandırılır.
(2) Cebir veya tehdit kullanılarak mağdurun, kendisini veya başkasını borç altına sokabilecek bir senedi veya var olan bir senedin hükümsüz kaldığını açıklayan bir vesikayı vermeye, böyle bir senedin alınmasına karşı koymamaya, ilerde böyle bir senet haline getirilebilecek bir kağıdı imzalamaya veya var olan bir senedi imha etmeye veya imhasına karşı koymamaya mecbur edilmesi halinde de aynı ceza verilir.
(3) Mağdurun, herhangi bir vasıta ile kendisini bilmeyecek ve savunamayacak hale getirilmesi de, yağma suçunda cebir sayılır.'''
        },
        {
          'no': '149',
          'baslik': 'Nitelikli yağma',
          'icerik': '''(1) Yağma suçunun;
a) Silahla,
b) Kişinin kendisini tanınmayacak bir hale koyması suretiyle,
c) Birden fazla kişi tarafından birlikte,
d) Yol kesmek suretiyle ya da konutta, işyerinde veya bunların eklentilerinde,
e) Beden veya ruh bakımından kendisini savunamayacak durumda bulunan kişiye karşı,
f) Var olan veya var sayılan suç örgütlerinin oluşturdukları korkutucu güçten yararlanılarak,
g) Suç örgütüne yarar sağlamak maksadıyla,
h) Gece vaktinde,
İşlenmesi halinde, fail hakkında on yıldan onbeş yıla kadar hapis cezasına hükmolunur.
(2) Yağma suçunun işlenmesi sırasında kasten yaralama suçunun neticesi sebebiyle ağırlaşmış hallerinin gerçekleşmesi durumunda, ayrıca kasten yaralama suçuna ilişkin hükümler uygulanır.'''
        },
        {
          'no': '151',
          'baslik': 'Mala zarar verme',
          'icerik': '''(1) Başkasının taşınır veya taşınmaz malını kısmen veya tamamen yıkan, tahrip eden, yok eden, bozan, kullanılamaz hale getiren veya kirleten kişi, mağdurun şikayeti üzerine, dört aydan üç yıla kadar hapis veya adlî para cezası ile cezalandırılır.
(2) Haklı bir neden olmaksızın, sahipli hayvanı öldüren, işe yaramayacak hale getiren veya değerinin azalmasına neden olan kişi hakkında yukarıdaki fıkra hükmü uygulanır.'''
        },
        {
          'no': '152',
          'baslik': 'Mala zarar vermenin nitelikli halleri',
          'icerik': '''(1) Mala zarar verme suçunun;
a) Kamu kurum ve kuruluşlarına ait, kamu hizmetine tahsis edilmiş veya kamunun yararlanmasına ayrılmış yer, bina, tesis veya diğer eşya hakkında,
b) Yangına, sel ve taşkına, kazaya ve diğer felaketlere karşı korunmaya tahsis edilmiş her türlü eşya veya tesis hakkında,
c) Devlet ormanı statüsündeki yerler hariç, nerede olursa olsun, her türlü dikili ağaç, fidan veya bağ çubuğu hakkında,
d) Sulamaya, içme sularının sağlanmasına veya taşkınlardan korumaya yarayan tesisler hakkında,
e) Grev veya lokavt hallerinde işverenlerin veya işçilerin veya işveren veya işçi sendika veya konfederasyonlarının maliki olduğu veya kullanımında olan bina, tesis veya eşya hakkında,
f) Siyasi partilerin, kamu kurumu niteliğindeki meslek kuruluşlarının ve üst kuruluşlarının maliki olduğu veya kullanımında olan bina, tesis veya eşya hakkında,
g) Sona ermiş olsa bile, görevinden ötürü öç almak amacıyla bir kamu görevlisinin zararına olarak,
İşlenmesi halinde, fail hakkında bir yıldan dört yıla kadar hapis cezasına hükmolunur.
(2) Mala zarar verme suçunun;
a) Yakarak, yakıcı veya patlayıcı madde kullanarak,
b) Toprak kaymasına, çığ düşmesine, sel veya taşkına neden olmak suretiyle,
c) Radyasyona maruz bırakarak, nükleer, biyolojik veya kimyasal silah kullanarak,
İşlenmesi halinde, fail hakkında bir yıldan altı yıla kadar hapis cezasına hükmolunur.
(3) Mala zarar verme suçunun işlenmesi sonucunda haberleşme, enerji ya da demiryolu veya havayolu ulaşımı alanında kamu hizmetinin geçici de olsa aksaması hâlinde, yukarıdaki fıkralar hükümlerine göre verilecek ceza yarısından iki katına kadar artırılır.'''
        },
        {
          'no': '154',
          'baslik': 'İbadethanelere ve mezarlıklara zarar verme',
          'icerik': '''(1) İbadethanelere, bunların eklentilerine, buralardaki eşyaya, mezarlıklara, bunların yapısal unsurlarına ve buralardaki ceset veya kemiklere zarar verenlere bir yıldan dört yıla kadar hapis cezası verilir.
(2) Birinci fıkradaki fiillerin, siyasal, felsefi, ırki veya dini saiklerle işlenmesi halinde, verilecek ceza üçte biri oranında artırılır.'''
        },
        {
          'no': '155',
          'baslik': 'Güveni kötüye kullanma',
          'icerik': '''(1) Başkasına ait olup da, muhafaza etmek veya belirli bir şekilde kullanmak üzere zilyedliği kendisine devredilmiş olan mal üzerinde, kendisinin veya başkasının yararına olarak, zilyedliğin devri amacı dışında tasarrufta bulunan veya bu devir olgusunu inkar eden kişi, şikayet üzerine, altı aydan iki yıla kadar hapis ve adlî para cezası ile cezalandırılır.
(2) Suçun, meslek ve sanat, ticaret veya hizmet ilişkisinin ya da hangi nedenden doğmuş olursa olsun, başkasının mallarını idare etmek yetkisinin gereği olarak tevdi ve teslim edilmiş eşya hakkında işlenmesi halinde, bir yıldan yedi yıla kadar hapis ve üçbin güne kadar adlî para cezasına hükmolunur.'''
        },
        {
          'no': '156',
          'baslik': 'Bedelsiz senedi kullanma',
          'icerik': '''(1) Bedelsiz kalmış bir senedi kullanan kimseye, şikayet üzerine, altı aydan iki yıla kadar hapis ve adlî para cezası verilir.'''
        },
        {
          'no': '157',
          'baslik': 'Dolandırıcılık',
          'icerik': '''(1) Hileli davranışlarla bir kimseyi aldatıp, onun veya başkasının zararına olarak, kendisine veya başkasına bir yarar sağlayan kişiye bir yıldan beş yıla kadar hapis ve beşbin güne kadar adlî para cezası verilir.'''
        },
        {
          'no': '158',
          'baslik': 'Nitelikli dolandırıcılık',
          'icerik': '''(1) Dolandırıcılık suçunun;
a) Dinî inanç ve duyguların istismar edilmesi suretiyle,
b) Kişinin içinde bulunduğu tehlikeli durum veya zor şartlardan yararlanmak suretiyle,
c) Kişinin algılama yeteneğinin zayıflığından yararlanmak suretiyle,
d) Kamu kurum ve kuruluşlarının, kamu meslek kuruluşlarının, siyasi parti, vakıf veya dernek tüzel kişiliklerinin araç olarak kullanılması suretiyle,
e) Kamu kurum ve kuruluşlarının zararına olarak,
f) Bilişim sistemlerinin, banka veya kredi kurumlarının araç olarak kullanılması suretiyle,
g) Basın ve yayın araçlarının sağladığı kolaylıktan yararlanmak suretiyle,
h) Tacir veya şirket yöneticisi olan ya da şirket adına hareket eden kişilerin ticari faaliyetleri sırasında; kooperatif yöneticilerinin kooperatifin faaliyeti kapsamında,
i) Serbest meslek sahibi kişiler tarafından, mesleklerinden dolayı kendilerine duyulan güvenin kötüye kullanılması suretiyle,
j) Banka veya diğer kredi kurumlarınca tahsis edilmemesi gereken bir kredinin açılmasını sağlamak maksadıyla,
k) Sigorta bedelini almak maksadıyla,
l) Kişinin, kendisini kamu görevlisi veya banka, sigorta ya da kredi kurumlarının çalışanı olarak tanıtması veya bu kurum ve kuruluşlarla ilişkili olduğunu söylemesi suretiyle,
İşlenmesi halinde, üç yıldan on yıla kadar hapis ve beşbin güne kadar adlî para cezasına hükmolunur. Ancak, (e), (f), (j), (k) ve (l) bentlerinde sayılan hâllerde hapis cezasının alt sınırı dört yıldan, adlî para cezasının miktarı suçtan elde edilen menfaatin iki katından az olamaz.
(2) Kamu görevlileriyle ilişkisinin olduğundan, onlar nezdinde hatırı sayıldığından bahisle ve belli bir işin gördürüleceği vaadiyle aldatarak, başkasından menfaat temin eden kişi, yukarıdaki fıkra hükmüne göre cezalandırılır.'''
        },
        {
          'no': '159',
          'baslik': 'Daha az cezayı gerektiren hal',
          'icerik': '''(1) Dolandırıcılığın, bir hukuki ilişkiye dayanan alacağı tahsil amacıyla işlenmesi halinde, şikayet üzerine, altı aydan bir yıla kadar hapis veya adlî para cezasına hükmolunur.'''
        },
        {
          'no': '160',
          'baslik': 'Kaybolmuş veya hata sonucu ele geçmiş eşya üzerinde tasarruf',
          'icerik': '''(1) Kaybedilmiş olması nedeniyle malikinin zilyetliğinden çıkmış olan ya da hata sonucu ele geçirilen eşya üzerinde, iade etmeksizin veya yetkili mercileri durumdan haberdar etmeksizin, malik gibi tasarrufta bulunan kişi, şikayet üzerine, bir yıla kadar hapis veya adlî para cezası ile cezalandırılır.'''
        },
        {
          'no': '161',
          'baslik': 'Hileli iflas',
          'icerik': '''(1) Malvarlığını eksiltmeye yönelik hileli tasarruflarda bulunan kişi, bu hileli tasarruflardan önce veya sonra iflasa karar verilmiş olması halinde, üç yıldan sekiz yıla kadar hapis cezası ile cezalandırılır.
(2) Hileli tasarruflarla;
a) Alacaklıların alacaklarının teminatı mahiyetinde olan malların kaçırılması, gizlenmesi veya değerinin azalmasına neden olunması,
b) Malvarlığını kaçırmaya yönelik hileli tasarruflarda bulunulması,
c) Alacaklılardan mal kaçırmak maksadıyla muvazaalı borçlar üstlenilmesi,
Kastedilmektedir.
(3) Birinci fıkrada sayılan hileli tasarrufların icra takibine başlandıktan sonra yapılması halinde, bu fiilleri işleyen kişi hakkında bir yıldan beş yıla kadar hapis cezasına hükmolunur.'''
        },
        {
          'no': '162',
          'baslik': 'Taksirli iflas',
          'icerik': '''(1) Tacir olmanın gerekli kıldığı dikkat ve özenin gösterilmemesi dolayısıyla iflasa sebebiyet veren kişi, iflasa karar verilmiş olması halinde, iki aydan bir yıla kadar hapis cezası ile cezalandırılır.'''
        },
        {
          'no': '163',
          'baslik': 'Karşılıksız yararlanma',
          'icerik': '''(1) Otomatlar aracılığı ile sunulan ve bedeli ödendiği takdirde yararlanılabilen bir hizmetten ödeme yapmadan yararlanan kişi, iki aydan altı aya kadar hapis veya adlî para cezası ile cezalandırılır.
(2) Telefon hatları ile frekanslarından veya elektromanyetik dalgalarla yapılan şifreli veya şifresiz yayınlardan sahibinin veya zilyedinin rızası olmadan yararlanan kişi, altı aydan iki yıla kadar hapis veya adlî para cezası ile cezalandırılır.
(3) Abonelik esasına göre yararlanılabilen elektrik enerjisinin, suyun veya doğal gazın sahibinin rızası olmaksızın ve tüketim miktarının belirlenmesini engelleyecek şekilde tüketilmesi halinde kişi hakkında bir yıldan üç yıla kadar hapis cezasına hükmolunur.'''
        },
        {
          'no': '164',
          'baslik': 'Şirket veya kooperatifler hakkında yanlış bilgi',
          'icerik': '''(1) Bir şirket veya kooperatifin kurucu, ortak, idareci, müdür veya temsilcileri veya yönetim veya denetim kurulu üyeleri veya tasfiye memuru sıfatını taşıyanlar, kamuya yaptıkları beyanlarda veya genel kurula sundukları raporlarda veya önerilerde ilgililerin zarara uğramasına neden olabilecek nitelikte gerçeğe aykırı önemli bilgiler verir veya verdirtir ise altı aydan üç yıla kadar hapis veya bin güne kadar adlî para cezası ile cezalandırılırlar.'''
        },
        {
          'no': '165',
          'baslik': 'Suç eşyasının satın alınması veya kabul edilmesi',
          'icerik': '''(1) Bir suçun işlenmesiyle elde edilen eşyayı veya diğer malvarlığı değerini, bu suçun işlenmesine iştirak etmeksizin, satan, devreden, satın alan veya kabul eden kişi, altı aydan üç yıla kadar hapis ve onbin güne kadar adlî para cezası ile cezalandırılır.'''
        },
        {
          'no': '166',
          'baslik': 'Bilgi vermeme',
          'icerik': '''(1) Bir hukuki uyuşmazlığa ilişkin olarak iddia ve savunmanın belirlenmesi amacıyla yapılacak değerlendirmede, gerçeğin ortaya çıkmasını engellemek amacıyla bilgi vermeyen kişi, altı aydan iki yıla kadar hapis cezası ile cezalandırılır.'''
        },
        {
          'no': '167',
          'baslik': 'Şahsi cezasızlık sebebi veya cezada indirim yapılmasını gerektiren şahsi sebep',
          'icerik': '''(1) Yağma ve nitelikli yağma hariç, bu bölümde yer alan suçların;
a) Haklarında ayrılık kararı verilmemiş eşlerden birinin,
b) Üstsoy veya altsoyunun veya bu derecede kayın hısımlarından birinin veya evlat edinen veya evlatlığın,
c) Aynı konutta beraber yaşayan kardeşlerden birinin,
Zararına olarak işlenmesi halinde, ilgili akraba hakkında cezaya hükmolunmaz.
(2) Bu suçların, haklarında ayrılık kararı verilmiş olan eşlerden birinin, aynı konutta beraber yaşamayan kardeşlerden birinin, aynı konutta beraber yaşamakta olan amca, dayı, hala, teyze, yeğen veya ikinci derecede kayın hısımlarının zararına olarak işlenmesi halinde; ilgili akraba hakkında şikayet üzerine verilecek ceza, yarısı oranında indirilir.'''
        },
        {
          'no': '168',
          'baslik': 'Etkin pişmanlık',
          'icerik': '''(1) Hırsızlık, mala zarar verme, güveni kötüye kullanma, dolandırıcılık, hileli iflâs, taksirli iflâs ve karşılıksız yararlanma suçları tamamlandıktan sonra ve fakat bu nedenle hakkında kovuşturma başlamadan önce, failin, azmettirenin veya yardım edenin bizzat pişmanlık göstererek mağdurun uğradığı zararı aynen geri verme veya tazmin suretiyle tamamen gidermesi halinde, verilecek cezanın üçte ikisine kadarı indirilir.
(2) Etkin pişmanlığın kovuşturma başladıktan sonra ve fakat hüküm verilmezden önce gösterilmesi halinde, verilecek cezanın yarısına kadarı indirilir.
(3) Yağma suçunda, birinci fıkra hükmüne göre verilecek cezanın yarısına kadarı indirilir. Yağma suçunda etkin pişmanlığın kovuşturma başladıktan sonra ve fakat hüküm verilmezden önce gösterilmesi halinde, verilecek cezanın üçte birine kadarı indirilir.
(4) Kısmen geri verme veya tazmin halinde etkin pişmanlık hükümlerinin uygulanabilmesi için, ayrıca mağdurun rızası aranır.
(5) Karşılıksız yararlanma suçunda, fail, azmettiren veya yardım edenin pişmanlık göstererek mağdurun, kamunun veya özel hukuk tüzel kişisinin uğradığı zararı, soruşturma tamamlanmadan önce tamamen tazmin etmesi halinde kamu davası açılmaz; zararın hüküm verilinceye kadar tamamen tazmin edilmesi halinde ise, verilecek ceza üçte birine kadar indirilir. Ancak kişi, bu fıkra hükmünden iki defadan fazla yararlanamaz.'''
        },
        {
          'no': '169',
          'baslik': 'Tüzel kişiler hakkında güvenlik tedbiri',
          'icerik': '''(1) Bu bölümde yer alan suçların işlenmesi suretiyle yararına haksız menfaat sağlanan tüzel kişiler hakkında bunlara özgü güvenlik tedbirlerine hükmolunur.'''
        },
      ],
    },
    {
      'baslik': 'Kamu Güvenliği Suçları',
      'alt': 'Madde 170-196',
      'icon': Icons.security,
      'color': const Color(0xFF34495E),
      'maddeler': [
        {
          'no': '170',
          'baslik': 'Genel güvenliğin kasten tehlikeye sokulması',
          'icerik': '''(1) Kişilerin hayatı, sağlığı veya malvarlığı bakımından tehlikeli olacak biçimde ya da kişilerde korku, kaygı veya panik yaratabilecek tarzda;
a) Yangın çıkaran,
b) Bina çökmesine, toprak kaymasına, çığ düşmesine, sel veya taşkına neden olan,
c) Silahla ateş eden veya patlayıcı madde kullanan,
Kişi, altı aydan üç yıla kadar hapis cezası ile cezalandırılır.
(2) Yangın çıkarmanın veya bina çökmesine, toprak kaymasına, çığ düşmesine, sel veya taşkına neden olmanın;
a) Orman veya dikili ağaç bulunan yerlerde veya ürünlerin henüz toplanmadığı alanlarda,
b) Yanıcı veya patlayıcı madde imal edilen veya depolanan yerlerde,
c) Maden ocaklarında,
d) Kısmen veya tamamen kamuya ait bina veya yapılarda,
İşlenmesi halinde, iki yıldan beş yıla kadar hapis cezasına hükmolunur.'''
        },
        {
          'no': '171',
          'baslik': 'Genel güvenliğin taksirle tehlikeye sokulması',
          'icerik': '''(1) Taksirle yangına neden olan veya bina çökmesine, toprak kaymasına, çığ düşmesine, sel veya taşkına neden olan kişi, fiilin başkalarının hayatı, sağlığı veya malvarlığı bakımından tehlikeli olması halinde, üç aydan bir yıla kadar hapis cezası ile cezalandırılır.'''
        },
        {
          'no': '172',
          'baslik': 'Radyasyon yayma',
          'icerik': '''(1) Bir nükleer tesis işleten ya da nükleer madde veya tehlikeli atık üreten, işleyen, kullanan, taşıyan veya depolayan kimse, gerekli güvenlik önlemlerini almaksızın radyasyon yayılmasına, nükleer tehlike oluşmasına veya atık dökülmesine neden olursa beş yıldan az olmamak üzere hapis cezası ile cezalandırılır.
(2) Bu fiilin taksirle işlenmesi halinde, iki yıldan beş yıla kadar hapis cezasına hükmolunur.'''
        },
        {
          'no': '174',
          'baslik': 'Tehlikeli maddelerin izinsiz bulundurulması veya el değiştirmesi',
          'icerik': '''(1) Yetkili makamlardan gerekli izni almaksızın, patlayıcı, yakıcı, aşındırıcı, yaralayıcı, boğucu, zehirleyici, sürekli hastalığa yol açıcı nükleer, radyoaktif, kimyasal, biyolojik maddeyi üreten, bulunduran, satan, satın alan, taşıyan veya başka bir ülkeye gönderen ya da bu maddeleri kullanan kişi, üç yıldan sekiz yıla kadar hapis ve beşbin güne kadar adlî para cezası ile cezalandırılır. Yetkili makamların belirlediği esaslara aykırı olarak izinsiz ya da gerçeğe aykırı beyanla boru hattı veya sistem geçirenlere ya da işletenlere de aynı ceza verilir.
(2) Bu fiillerin, sürekli bir faaliyet çerçevesinde bir suç örgütünün faaliyetleri çerçevesinde işlenmesi halinde, verilecek ceza bir kat artırılır.'''
        },
        {
          'no': '179',
          'baslik': 'Trafik güvenliğini tehlikeye sokma',
          'icerik': '''(1) Kara, deniz, hava veya demiryolu ulaşımının güven içinde akışını sağlamak için konulmuş her türlü işareti değiştirerek, kullanılamaz hale getirerek, konuldukları yerden kaldırarak, yanlış işaretler vererek, geçiş, varış, kalkış veya iniş yolları üzerine bir şey koyarak ya da yolu kapatarak, karada, gökyüzünde veya suda yapılan ulaşımı tehlikeye sokan kişiye bir yıldan altı yıla kadar hapis cezası verilir.
(2) Kara, deniz, hava veya demiryolu ulaşım araçlarını kişilerin hayat, sağlık veya malvarlığı açısından tehlikeli olabilecek şekilde sevk ve idare eden kişi, iki yıla kadar hapis cezası ile cezalandırılır.
(3) Alkol veya uyuşturucu madde etkisiyle ya da başka bir nedenle emniyetli bir şekilde araç sevk ve idare edemeyecek halde olmasına rağmen araç kullanan kişi yukarıdaki fıkra hükmüne göre cezalandırılır.'''
        },
        {
          'no': '180',
          'baslik': 'Çevrenin kasten kirletilmesi',
          'icerik': '''(1) İlgili kanunlarla belirlenen teknik usullere aykırı olarak ve çevreye zarar verecek şekilde, atık veya artıkları toprağa, suya veya havaya kasten veren kişi, altı aydan iki yıla kadar hapis cezası ile cezalandırılır.
(2) Atık veya artıkların, toprakta, suda veya havada kalıcı özellik göstermesi halinde, yukarıdaki fıkraya göre verilecek ceza iki katı kadar artırılır.
(3) Bir ve ikinci fıkralardaki fiillerin, insan veya hayvanlar açısından tedavisi zor hastalıkların ortaya çıkmasına, üreme yeteneğinin körelmesine, hayvanların veya bitkilerin doğal özelliklerini değiştirmeye neden olabilecek niteliklere sahip olan atık veya artıklarla ilgili olarak işlenmesi halinde, beş yıldan az olmamak üzere hapis cezasına ve bin güne kadar adlî para cezasına hükmolunur.
(4) Bu maddenin iki, üç ve dördüncü fıkrasındaki fiillerin, ayrı ayrı veya değişik sıvılar halinde kimyasal maddeler kulu kullanarak işlenmesi halinde, verilecek ceza iki katı artırılır.'''
        },
        {
          'no': '181',
          'baslik': 'Çevrenin taksirle kirletilmesi',
          'icerik': '''(1) Çevreye zarar verecek şekilde, atık veya artıkların toprağa, suya veya havaya verilmesine taksirle neden olan kişi, adlî para cezası ile cezalandırılır. Bu atık veya artıkların, toprakta, suda veya havada kalıcı etki bırakması halinde, iki aydan bir yıla kadar hapis cezasına hükmolunur.
(2) İnsan veya hayvanlar açısından tedavisi zor hastalıkların ortaya çıkmasına, üreme yeteneğinin körelmesine, hayvanların veya bitkilerin doğal özelliklerini değiştirmeye neden olabilecek niteliklere sahip olan atık veya artıkların toprağa, suya veya havaya taksirle verilmesine neden olan kişi, bir yıldan beş yıla kadar hapis cezası ile cezalandırılır.'''
        },
        {
          'no': '184',
          'baslik': 'İmar kirliliğine neden olma',
          'icerik': '''(1) Yapı ruhsatiyesi alınmadan veya ruhsata aykırı olarak bina yapan veya yaptıran kişi, bir yıldan beş yıla kadar hapis cezası ile cezalandırılır.
(2) Yapı ruhsatiyesi olmadan başlatılan inşaatlar dolayısıyla kurulan şantiyelere elektrik, su veya telefon bağlantısı yapılmasına müsaade eden kişi, yukarıdaki fıkra hükmüne göre cezalandırılır.
(3) Yapı kullanma izni alınmamış binalarda herhangi bir sınai faaliyetin icrasına müsaade eden kişi iki yıldan beş yıla kadar hapis cezası ile cezalandırılır.
(4) Üçüncü fıkra hariç, bu madde hükümleri ancak belediye sınırları içinde veya özel imar rejimine tabi yerlerde uygulanır.
(5) Kişinin, ruhsatsız ya da ruhsata aykırı olarak yaptığı veya yaptırdığı binayı imar planına ve ruhsatına uygun hale getirmesi halinde, bir ve ikinci fıkra hükümleri gereğince kamu davası açılmaz, açılmış olan kamu davası düşer, mahkum olunan ceza bütün sonuçlarıyla ortadan kalkar.
(6) İkinci ve üçüncü fıkra hükümleri, 12 nci maddenin ikinci fıkrası hükmüne göre uygulanır.'''
        },
        {
          'no': '188',
          'baslik': 'Uyuşturucu veya uyarıcı madde imal ve ticareti',
          'icerik': '''(1) Uyuşturucu veya uyarıcı maddeleri ruhsatsız veya ruhsata aykırı olarak imal, ithal veya ihraç eden kişi, yirmi yıldan otuz yıla kadar hapis ve ikibin günden yirmibin güne kadar adlî para cezası ile cezalandırılır.
(2) Uyuşturucu veya uyarıcı madde ihracı fiilinin diğer ülke açısından ithal olarak nitelendirilmesi dolayısıyla bu ülkede yapılan yargılama sonucunda hükmolunan cezanın infaz edilen kısmı, Türkiye'de uyuşturucu veya uyarıcı madde ihracı dolayısıyla yapılacak yargılama sonucunda hükmolunan cezadan mahsup edilir.
(3) Uyuşturucu veya uyarıcı maddeleri ruhsatsız veya ruhsata aykırı olarak ülke içinde satan, satışa arz eden, başkalarına veren, sevk eden, nakleden, depolayan, satın alan, kabul eden, bulunduran kişi, on yıldan az olmamak üzere hapis ve bin günden yirmibin güne kadar adlî para cezası ile cezalandırılır.
(4) Uyuşturucu veya uyarıcı maddenin eroin, kokain, morfin, sentetik kannabinoid ve türevleri veya bazmorfin olması,
a) Birinci fıkradaki fiiller bakımından ağırlaştırılmış müebbet hapis cezası ve beşbin günden elli bin güne kadar,
b) Üçüncü fıkradaki fiiller bakımından on beş yıldan az olmamak üzere hapis ve bin günden yirmibin güne kadar,
Adlî para cezası ile cezalandırılır.
(5) Yukarıdaki fıkralarda gösterilen suçların;
a) Okul, yurt, hastane, kışla veya ibadethane gibi tedavi, eğitim, askeri ve sosyal amaçla toplu bulunulan bina ve tesisler ile bunların varsa çevre duvarı, tel örgü veya benzeri engel veya işaretlerle belirlenen sınırlarına iki yüz metreden yakın mesafe içindeki umumi veya umuma açık yerlerde işlenmesi,
b) Üç veya daha fazla kişi tarafından birlikte işlenmesi,
c) Suç işlemek için teşkil edilmiş bir örgütün faaliyeti çerçevesinde işlenmesi,
d) Sağlık mesleği mensupları tarafından işlenmesi,
Hâlinde, verilecek ceza yarı oranında artırılır.
(6) Üretimi resmi makamların iznine veya satışı yetkili tabip tarafından düzenlenen reçeteye bağlı olan ve uyuşturucu veya uyarıcı madde etkisi doğuran her türlü madde açısından da yukarıdaki fıkralar hükümleri uygulanır. Ancak, verilecek ceza yarısına kadar indirilebilir.
(7) Uyuşturucu veya uyarıcı etki doğurmamakla birlikte, uyuşturucu veya uyarıcı madde üretiminde kullanılan ve ithal veya imali resmi makamların iznine bağlı olan maddeyi ülkeye ithal eden, imal eden, satan, satın alan, sevk eden, nakleden, depolayan veya ihraç eden kişi, sekiz yıldan az olmamak üzere hapis ve bin günden yirmibin güne kadar adlî para cezası ile cezalandırılır.
(8) Bu maddede tanımlanan suçların tabip, diş tabibi, eczacı, kimyager, veteriner, sağlık memuru, laborant, ebe, hemşire, diş teknisyeni, hastabakıcı, sağlık hizmeti veren, kimyacılıkla veya ecza ticareti ile iştigal eden kişi tarafından işlenmesi halinde, verilecek ceza yarı oranında artırılır.'''
        },
        {
          'no': '190',
          'baslik': 'Uyuşturucu veya uyarıcı madde kullanılmasını kolaylaştırma',
          'icerik': '''(1) Uyuşturucu veya uyarıcı madde kullanılmasını kolaylaştırmak için;
a) Özel yer, donanım veya malzeme sağlayan,
b) Kullananların yakalanmalarını zorlaştıracak önlemler alan,
c) Kullanma yöntemleri konusunda başkalarına bilgi veren,
Kişi, beş yıldan on yıla kadar hapis ve bin günden onbin güne kadar adlî para cezası ile cezalandırılır.
(2) Uyuşturucu veya uyarıcı madde kullanılmasını alenen özendiren veya bu nitelikte yayın yapan kişi, beş yıldan on yıla kadar hapis ve bin günden onbin güne kadar adlî para cezası ile cezalandırılır.
(3) Bu maddede tanımlanan suçların; tabip, diş tabibi, eczacı, kimyager, veteriner, sağlık memuru, laborant, ebe, hemşire, diş teknisyeni, hastabakıcı, sağlık hizmeti veren, kimyacılıkla veya ecza ticareti ile iştigal eden kişi tarafından işlenmesi halinde, verilecek ceza yarı oranında artırılır.'''
        },
        {
          'no': '191',
          'baslik': 'Kullanmak için uyuşturucu veya uyarıcı madde satın almak, kabul etmek veya bulundurmak ya da uyuşturucu veya uyarıcı madde kullanmak',
          'icerik': '''(1) Kullanmak için uyuşturucu veya uyarıcı madde satın alan, kabul eden veya bulunduran ya da uyuşturucu veya uyarıcı madde kullanan kişi, iki yıldan beş yıla kadar hapis cezası ile cezalandırılır.
(2) Bu suçtan dolayı başlatılan soruşturmada şüpheli hakkında 4/12/2004 tarihli ve 5271 sayılı Ceza Muhakemesi Kanununun 171 inci maddesindeki şartlar aranmaksızın, beş yıl süreyle kamu davasının açılmasının ertelenmesine karar verilir. Cumhuriyet savcısı, bu durumda şüpheliyi, erteleme süresi zarfında kendisine yüklenen yükümlülüklere uygun davranmadığı veya yasakları ihlal ettiği takdirde kendisi bakımından ortaya çıkabilecek sonuçlar konusunda uyarır.
(3) Erteleme süresi zarfında şüpheli hakkında asgari bir yıl süreyle denetimli serbestlik tedbiri uygulanır. Bu süre Cumhuriyet savcısının kararı ile üçer aylık sürelerle en fazla bir yıl daha uzatılabilir. Hakkında denetimli serbestlik tedbiri verilen kişi, gerek görülmesi hâlinde denetimli serbestlik süresi içinde tedaviye tabi tutulabilir.
(4) Kişinin, erteleme süresi zarfında;
a) Kendisine yüklenen yükümlülüklere veya uygulanan tedavinin gereklerine uygun davranmamakta ısrar etmesi,
b) Tekrar kullanmak için uyuşturucu veya uyarıcı madde satın alması, kabul etmesi veya bulundurması,
c) Uyuşturucu veya uyarıcı madde kullanması,
Hâlinde, hakkında kamu davası açılır.
(5) Erteleme süresi zarfında kişinin kullanmak için tekrar uyuşturucu veya uyarıcı madde satın alması, kabul etmesi veya bulundurması ya da uyuşturucu veya uyarıcı madde kullanması, dördüncü fıkra uyarınca ihlal nedeni sayılır ve ayrı bir soruşturma ve kovuşturma konusu yapılmaz.
(6) Erteleme süresinin kendisine yüklenen yükümlülüklere uygun olarak ve ihlal edilmeden geçirilmesi halinde, kovuşturmaya yer olmadığına dair karar verilir.'''
        },
      ],
    },
    {
      'baslik': 'Belgede Sahtecilik',
      'alt': 'Madde 197-212',
      'icon': Icons.description,
      'color': const Color(0xFF16A085),
      'maddeler': [
        {
          'no': '197',
          'baslik': 'Parada sahtecilik',
          'icerik': '''(1) Memlekette veya yabancı ülkelerde kanunen tedavülde bulunan parayı, sahte olarak üreten, ülkeye sokan, nakleden, muhafaza eden veya tedavüle koyan kişi, iki yıldan oniki yıla kadar hapis ve onbin güne kadar adlî para cezası ile cezalandırılır.
(2) Sahte parayı bilerek kabul eden kişi, bir yıldan üç yıla kadar hapis ve adlî para cezası ile cezalandırılır.
(3) Sahteliğini bilmeden kabul ettiği parayı bu niteliğini bilerek tedavüle koyan kişi, üç aydan bir yıla kadar hapis cezası ile cezalandırılır.'''
        },
        {
          'no': '199',
          'baslik': 'Kıymetli damgada sahtecilik',
          'icerik': '''(1) Kıymetli damgayı sahte olarak üreten, ülkeye sokan, nakleden, muhafaza eden veya tedavüle koyan kişi, iki yıldan sekiz yıla kadar hapis ve beşbin güne kadar adlî para cezası ile cezalandırılır.
(2) Sahte olarak üretilmiş kıymetli damgayı bilerek kabul eden kişi, altı aydan iki yıla kadar hapis ve adlî para cezası ile cezalandırılır.
(3) Sahteliğini bilmeden kabul edilen kıymetli damganın bu niteliğini bilerek tedavüle konulması halinde, bir aydan altı aya kadar hapis cezasına hükmolunur.'''
        },
        {
          'no': '202',
          'baslik': 'Mühürde sahtecilik',
          'icerik': '''(1) Cumhurbaşkanlığı, Türkiye Büyük Millet Meclisi Başkanlığı ve Başbakanlık tarafından kullanılan mührü sahte olarak üreten veya kullanan kişi, iki yıldan sekiz yıla kadar hapis cezası ile cezalandırılır.
(2) Kamu kurum ve kuruluşlarınca veya kamu kurumu niteliğindeki meslek kuruluşlarınca kullanılan onaylayıcı veya belgeleyici mührü sahte olarak üreten veya kullanan kişi, bir yıldan altı yıla kadar hapis cezası ile cezalandırılır.'''
        },
        {
          'no': '203',
          'baslik': 'Mühür bozma',
          'icerik': '''(1) Kanun veya yetkili makamların emri uyarınca bir şeyin saklanmasını veya varlığının aynen korunmasını sağlamak için konulan mührü kaldıran veya konuluş amacına aykırı hareket eden kişi, altı aydan üç yıla kadar hapis veya adlî para cezası ile cezalandırılır.'''
        },
        {
          'no': '204',
          'baslik': 'Resmi belgede sahtecilik',
          'icerik': '''(1) Bir resmi belgeyi sahte olarak düzenleyen, gerçek bir resmi belgeyi başkalarını aldatacak şekilde değiştiren veya sahte resmi belgeyi kullanan kişi, iki yıldan beş yıla kadar hapis cezası ile cezalandırılır.
(2) Görevi gereği düzenlemeye yetkili olduğu resmi bir belgeyi sahte olarak düzenleyen, gerçek bir belgeyi başkalarını aldatacak şekilde değiştiren, gerçeğe aykırı olarak belge düzenleyen veya sahte resmi belgeyi kullanan kamu görevlisi üç yıldan sekiz yıla kadar hapis cezası ile cezalandırılır.
(3) Resmi belgenin, kanun hükmü gereği sahteliği sabit oluncaya kadar geçerli olan belge niteliğinde olması halinde, verilecek ceza yarısı oranında artırılır.'''
        },
        {
          'no': '205',
          'baslik': 'Resmi belgeyi bozmak, yok etmek veya gizlemek',
          'icerik': '''(1) Gerçek bir resmi belgeyi bozan, yok eden veya gizleyen kişi, iki yıldan beş yıla kadar hapis cezası ile cezalandırılır. Suçun kamu görevlisi tarafından işlenmesi halinde, verilecek ceza yarı oranında artırılır.'''
        },
        {
          'no': '206',
          'baslik': 'Resmi belgenin düzenlenmesinde yalan beyan',
          'icerik': '''(1) Bir resmi belgeyi düzenlemek yetkisine sahip olan kamu görevlisine yalan beyanda bulunan kişi, üç aydan iki yıla kadar hapis veya adlî para cezası ile cezalandırılır.'''
        },
        {
          'no': '207',
          'baslik': 'Özel belgede sahtecilik',
          'icerik': '''(1) Bir özel belgeyi sahte olarak düzenleyen veya gerçek bir özel belgeyi başkalarını aldatacak şekilde değiştiren ve kullanan kişi, bir yıldan üç yıla kadar hapis cezası ile cezalandırılır.'''
        },
        {
          'no': '208',
          'baslik': 'Özel belgeyi bozmak, yok etmek veya gizlemek',
          'icerik': '''(1) Gerçek bir özel belgeyi bozan, yok eden veya gizleyen kişi, bir yıldan üç yıla kadar hapis cezası ile cezalandırılır.'''
        },
        {
          'no': '209',
          'baslik': 'Açığa imzanın kötüye kullanılması',
          'icerik': '''(1) Belirli bir tarzda doldurulup kullanılmak üzere kendisine teslim olunan imzalı ve kısmen veya tamamen boş bir kağıdı, verilme nedeninden farklı bir şekilde dolduran kişi, şikayet üzerine, üç aydan bir yıla kadar hapis cezası ile cezalandırılır.
(2) İmzalı ve kısmen veya tamamen boş bir kağıdı hukuka aykırı olarak ele geçirip veya elde bulundurup da hukuki sonuç doğuracak şekilde dolduran kişi, belgede sahtecilik hükümlerine göre cezalandırılır.'''
        },
        {
          'no': '210',
          'baslik': 'Resmi belge hükmünde belgeler',
          'icerik': '''(1) Özel belgede sahtecilik suçunun konusunun, emre veya hamile yazılı kambiyo senedi, emtiayı temsil eden belge, hisse senedi, tahvil veya vasiyetname olması halinde, resmi belgede sahtecilik suçuna ilişkin hükümler uygulanır.
(2) Gerçeğe aykırı belge düzenleyen tabip, diş tabibi, eczacı, ebe, hemşire veya diğer sağlık mesleği mensubu, üç aydan bir yıla kadar hapis cezası ile cezalandırılır. Düzenlenen belgenin kişiye haksız bir menfaat sağlaması ya da kamunun veya kişilerin zararına bir sonuç doğurucu nitelik taşıması halinde, resmi belgede sahtecilik hükümlerine göre cezaya hükmolunur.'''
        },
      ],
    },
    {
      'baslik': 'Kamu İdaresi Suçları',
      'alt': 'Madde 247-266',
      'icon': Icons.account_balance,
      'color': const Color(0xFF27AE60),
      'maddeler': [
        {
          'no': '247',
          'baslik': 'Zimmet',
          'icerik': '''(1) Görevi nedeniyle zilyedliği kendisine devredilmiş olan veya koruma ve gözetimiyle yükümlü olduğu mallar üzerinde kendisinin veya başkasının yararına olarak tasarrufta bulunan veya bu malları amacı dışında kullanan kamu görevlisi, beş yıldan oniki yıla kadar hapis cezası ile cezalandırılır.
(2) Suçun, zimmetin açığa çıkmamasını sağlamaya yönelik hileli davranışlarla işlenmesi halinde, verilecek ceza yarı oranında artırılır.
(3) Zimmet suçunun, malın geçici bir süre kullanıldıktan sonra iade edilmek üzere işlenmesi halinde, verilecek ceza yarı oranına kadar indirilebilir.'''
        },
        {
          'no': '250',
          'baslik': 'İrtikap',
          'icerik': '''(1) Görevinin sağladığı nüfuzu kötüye kullanmak suretiyle kendisine veya başkasına yarar sağlanmasına veya bu yolda vaatte bulunulmasına bir kimseyi icbar eden kamu görevlisi, beş yıldan on yıla kadar hapis cezası ile cezalandırılır.
(2) Görevinin sağladığı güveni kötüye kullanmak suretiyle gerçekleştirdiği hileli davranışlarla, kendisine veya başkasına yarar sağlanmasına veya bu yolda vaatte bulunulmasına bir kimseyi ikna eden kamu görevlisi, üç yıldan beş yıla kadar hapis cezası ile cezalandırılır.
(3) İkinci fıkrada tanımlanan suçun kişinin hatasından yararlanarak işlenmiş olması halinde, bir yıldan üç yıla kadar hapis cezasına hükmolunur.'''
        },
        {
          'no': '252',
          'baslik': 'Rüşvet',
          'icerik': '''(1) Görevinin ifasıyla ilgili bir işi yapması veya yapmaması için, doğrudan veya aracılar vasıtasıyla, bir kamu görevlisine veya göstereceği bir başka kişiye menfaat sağlayan kişi, dört yıldan oniki yıla kadar hapis cezası ile cezalandırılır.
(2) Görevinin ifasıyla ilgili bir işi yapması veya yapmaması için, doğrudan veya aracılar vasıtasıyla, kendisine veya göstereceği bir başka kişiye menfaat sağlayan kamu görevlisi de birinci fıkrada belirtilen ceza ile cezalandırılır.
(3) Rüşvet konusunda anlaşmaya varılması halinde, suç tamamlanmış gibi cezaya hükmolunur.
(4) Kamu görevlisinin rüşvet talebinde bulunması ve fakat bunun kişi tarafından kabul edilmemesi ya da kişinin kamu görevlisine menfaat temini konusunda teklif veya vaatte bulunması ve fakat bunun kamu görevlisi tarafından kabul edilmemesi hâllerinde fail hakkında, birinci ve ikinci fıkra hükümlerine göre verilecek ceza yarı oranında indirilir.
(5) Rüşvet teklif veya talebinin karşı tarafa iletilmesi, rüşvet anlaşmasının sağlanması veya rüşvetin temini hususlarında aracılık eden kişi, kamu görevlisi sıfatını taşıyıp taşımadığına bakılmaksızın, müşterek fail olarak cezalandırılır.
(6) Rüşvet ilişkisinde dolaylı olarak kendisine menfaat sağlanan üçüncü kişi veya tüzel kişinin yöneticisi ya da temsilcisi ya da ortağı, menfaatin sağlandığı sırada bunun rüşvet karşılığı olduğunu bilmesi koşuluyla, müşterek fail olarak cezalandırılır.
(7) Rüşvet alan veya talebinde bulunan ya da bu konuda anlaşmaya varan kişinin; yargı görevi yapan, hakem, bilirkişi, noter veya yeminli mali müşavir olması halinde, verilecek ceza üçte birden yarısına kadar artırılır.
(8) Bu madde hükümleri;
a) Kamu kurumu niteliğindeki meslek kuruluşları,
b) Kamu kurum veya kuruluşlarının ya da kamu kurumu niteliğindeki meslek kuruluşlarının iştirakiyle kurulmuş şirketler,
c) Kamu kurum veya kuruluşlarının ya da kamu kurumu niteliğindeki meslek kuruluşlarının bünyesinde faaliyet icra eden vakıflar,
d) Kamu yararına çalışan dernekler,
e) Kooperatifler,
f) Halka açık anonim şirketler,
Adına hareket eden kişilere, kamu görevlisi sıfatını taşıyıp taşımadıklarına bakılmaksızın, görevlerinin ifasıyla ilgili bir işin yapılması veya yapılmaması amacıyla menfaat temin, teklif veya vaat edilmesi; bu kişiler tarafından talep veya kabul edilmesi ya da bunlara aracılık edilmesi hallerinde de uygulanır.
(9) Bu madde hükümleri, yabancı kamu görevlilerine veya uluslararası mahkeme veya örgüt görevlilerine rüşvet verilmesi, vaat veya teklif edilmesi hallerinde de uygulanır.'''
        },
        {
          'no': '255',
          'baslik': 'Nüfuz ticareti',
          'icerik': '''(1) Kamu görevlisi üzerinde nüfuz sahibi olduğundan bahisle, haksız bir işin gördürülmesi amacıyla girişimde bulunması için, doğrudan veya aracılar vasıtasıyla, menfaat temin eden kişi, iki yıldan beş yıla kadar hapis cezası ile cezalandırılır.
(2) Kamu görevlisi üzerinde nüfuz sahibi olduğundan bahisle haksız bir işin gördürülmesi amacıyla girişimde bulunmak için, doğrudan veya aracılar vasıtasıyla, bir başkasından kendisi veya bir başkası için menfaat temin eden kişi, üç yıldan altı yıla kadar hapis cezası ile cezalandırılır.
(3) Nüfuz ticareti konusunda anlaşmaya varılması halinde dahi, suç tamamlanmış gibi cezaya hükmolunur.
(4) Menfaatin kamu görevlisi tarafından temin edilmesi halinde, verilecek ceza yarı oranında artırılır.'''
        },
        {
          'no': '256',
          'baslik': 'Zor kullanma yetkisine ilişkin sınırın aşılması',
          'icerik': '''(1) Zor kullanma yetkisine sahip kamu görevlisinin, görevini yaptığı sırada, kişilere karşı görevinin gerektirdiği ölçünün dışında kuvvet kullanması halinde, kasten yaralama suçuna ilişkin hükümler uygulanır.'''
        },
        {
          'no': '257',
          'baslik': 'Görevi kötüye kullanma',
          'icerik': '''(1) Kanunda ayrıca suç olarak tanımlanan haller dışında, görevinin gereklerine aykırı hareket etmek suretiyle, kişilerin mağduriyetine veya kamunun zararına neden olan ya da kişilere haksız bir menfaat sağlayan kamu görevlisi, altı aydan iki yıla kadar hapis cezası ile cezalandırılır.
(2) Kanunda ayrıca suç olarak tanımlanan haller dışında, görevinin gereklerini yapmakta ihmal veya gecikme göstererek, kişilerin mağduriyetine veya kamunun zararına neden olan ya da kişilere haksız bir menfaat sağlayan kamu görevlisi, üç aydan bir yıla kadar hapis cezası ile cezalandırılır.'''
        },
        {
          'no': '258',
          'baslik': 'Göreve ilişkin sırrın açıklanması',
          'icerik': '''(1) Görevi nedeniyle kendisine verilen veya aynı nedenle bilgi edindiği ve gizli kalması gereken belgeleri, kararları ve emirleri ve diğer tebligatı açıklayan veya yayınlayan veya ne suretle olursa olsun başkalarının bilgi edinmesini kolaylaştıran kamu görevlisine, bir yıldan dört yıla kadar hapis cezası verilir.
(2) Kamu görevlisi sıfatı sona erdikten sonra, birinci fıkrada yazılı fiilleri işleyen kimseye de aynı ceza verilir.'''
        },
        {
          'no': '265',
          'baslik': 'Görevi yaptırmamak için direnme',
          'icerik': '''(1) Kamu görevlisine karşı görevini yapmasını engellemek amacıyla, cebir veya tehdit kullanan kişi, altı aydan üç yıla kadar hapis cezası ile cezalandırılır.
(2) Suçun yargı görevi yapan kişilere karşı işlenmesi halinde, iki yıldan dört yıla kadar hapis cezasına hükmolunur.
(3) Suçun, kişinin kendisini tanınmayacak bir hale koyması suretiyle veya birden fazla kişi tarafından birlikte işlenmesi halinde, verilecek ceza üçte biri oranında artırılır.
(4) Suçun, silahla ya da var olan veya var sayılan suç örgütlerinin oluşturdukları korkutucu güçten yararlanılarak işlenmesi halinde, yukarıdaki fıkralara göre verilecek ceza yarı oranında artırılır.'''
        },
      ],
    },
    {
      'baslik': 'Adliyeye Karşı Suçlar',
      'alt': 'Madde 267-298',
      'icon': Icons.policy,
      'color': const Color(0xFF7F8C8D),
      'maddeler': [
        {
          'no': '267',
          'baslik': 'İftira',
          'icerik': '''(1) Yetkili makamlara ihbar veya şikayette bulunarak ya da basın ve yayın yoluyla, işlemediğini bildiği halde, hakkında soruşturma ve kovuşturma başlatılmasını ya da idari bir yaptırım uygulanmasını sağlamak için bir kimseye hukuka aykırı bir fiil isnat eden kişi, bir yıldan dört yıla kadar hapis cezası ile cezalandırılır.
(2) Fiilin maddi eser ve delillerini uydurarak iftirada bulunulması halinde, ceza yarı oranında artırılır.
(3) Yüklenen fiili işlemediğinden dolayı hakkında beraat kararı veya kovuşturmaya yer olmadığına dair karar verilmiş mağdurun aleyhine olarak bu fiil nedeniyle gözaltına alma ve tutuklama dışında başka bir koruma tedbiri uygulanmışsa, yukarıdaki fıkralara göre verilecek ceza yarı oranında artırılır.
(4) Yüklenen fiili işlemediğinden dolayı hakkında beraat kararı veya kovuşturmaya yer olmadığına dair karar verilmiş olan mağdurun bu fiil nedeniyle gözaltına alınması veya tutuklanması halinde; iftira eden, ayrıca kişiyi hürriyetinden yoksun kılma suçuna ilişkin hükümlere göre dolaylı fail olarak sorumlu tutulur.
(5) Mağdurun ağırlaştırılmış müebbet hapis veya müebbet hapis cezasına mahkumiyeti halinde, yirmi yıldan otuz yıla kadar hapis cezasına; hükmolunur.
(6) Mağdurun mahkum olduğu hapis cezasının infazına başlanmış ise, beşinci fıkraya göre verilecek ceza yarısı kadar artırılır.
(7) İftira sonucunda mağdur hakkında hapis cezası dışında adli veya idari bir yaptırım uygulanmışsa; iftira eden kişi, üç yıldan yedi yıla kadar hapis cezası ile cezalandırılır.
(8) İftira suçundan dolayı dava zamanaşımı, mağdurun fiili işlemediğinin sabit olduğu tarihten başlar.
(9) Basın ve yayın yoluyla işlenen iftira suçundan dolayı verilen mahkumiyet kararı, aynı veya eşdeğerde basın ve yayın organıyla ilan olunur. İlan masrafı, hükümlüden tahsil edilir.'''
        },
        {
          'no': '268',
          'baslik': 'Başkasına ait kimlik veya kimlik bilgilerinin kullanılması',
          'icerik': '''(1) İşlediği suç nedeniyle kendisi hakkında soruşturma ve kovuşturma yapılmasını engellemek amacıyla, başkasına ait kimliği veya kimlik bilgilerini kullanan kimse, iftira suçuna ilişkin hükümlere göre cezalandırılır.'''
        },
        {
          'no': '270',
          'baslik': 'Suç üstlenme',
          'icerik': '''(1) Yetkili makamlara, gerçeğe aykırı olarak, suçu işlediğini veya suça katıldığını bildiren kimseye iki yıla kadar hapis cezası verilir. Bu suçun, üstsoy, altsoy, eş veya kardeşi cezadan kurtarmak amacıyla işlenmesi halinde; verilecek cezanın dörtte üçü indirilebileceği gibi, tamamen de kaldırılabilir.'''
        },
        {
          'no': '271',
          'baslik': 'Suç uydurma',
          'icerik': '''(1) İşlenmediğini bildiği bir suçu, yetkili makamlara işlenmiş gibi ihbar eden ya da işlenmeyen bir suçun delil veya emarelerini soruşturma yapılmasını sağlayacak biçimde uyduran kimseye üç yıla kadar hapis cezası verilir.'''
        },
        {
          'no': '272',
          'baslik': 'Yalan tanıklık',
          'icerik': '''(1) Hukuka aykırı bir fiil nedeniyle başlatılan bir soruşturma kapsamında tanık dinlemeye yetkili kişi veya kurul önünde gerçeğe aykırı olarak tanıklık yapan kimseye, dört aydan bir yıla kadar hapis cezası verilir.
(2) Mahkeme huzurunda ya da yemin ettirerek tanık dinlemeye kanunen yetkili kişi veya kurul önünde gerçeğe aykırı olarak tanıklık yapan kimseye bir yıldan üç yıla kadar hapis cezası verilir.
(3) Üç yıldan fazla hapis cezasını gerektiren bir suçun soruşturma veya kovuşturması kapsamında yalan tanıklık yapan kişi hakkında iki yıldan dört yıla kadar hapis cezasına hükmolunur.
(4) Aleyhine tanıklıkta bulunulan kişi ile ilgili olarak gözaltına alma ve tutuklama dışında başka bir koruma tedbiri uygulanmışsa, yüklenen fiili işlemediğinden dolayı hakkında beraat kararı veya kovuşturmaya yer olmadığına dair karar verilmiş olması koşuluyla, yukarıdaki fıkralara göre verilecek ceza yarı oranında artırılır.
(5) Aleyhine tanıklıkta bulunulan kişinin gözaltına alınması veya tutuklanması halinde; yüklenen fiili işlemediğinden dolayı hakkında beraat kararı veya kovuşturmaya yer olmadığına dair karar verilmiş olması koşuluyla; yalan tanıklık yapan kişi, ayrıca kişiyi hürriyetinden yoksun kılma suçuna ilişkin hükümlere göre dolaylı fail olarak sorumlu tutulur.
(6) Aleyhine tanıklıkta bulunulan kimsenin ağırlaştırılmış müebbet hapis veya müebbet hapis cezasına mahkumiyeti halinde, yirmi yıldan otuz yıla kadar hapis cezasına hükmolunur.
(7) Aleyhine tanıklıkta bulunulan kimsenin mahkum olduğu hapis cezasının infazına başlanmış ise, altıncı fıkraya göre verilecek ceza yarısı kadar artırılır.
(8) Aleyhine tanıklıkta bulunulan kişi hakkında hapis cezası dışında adli veya idari bir yaptırım uygulanmışsa; yalan tanıklıkta bulunan kişi, üç yıldan yedi yıla kadar hapis cezası ile cezalandırılır.'''
        },
        {
          'no': '274',
          'baslik': 'Yalan yere yemin',
          'icerik': '''(1) Hukuk davalarında yalan yere yemin eden davacı veya davalıya bir yıldan beş yıla kadar hapis cezası verilir.
(2) Dava hakkında hüküm verilmeden önce gerçeğin söylenmesi halinde, cezaya hükmolunmaz.
(3) Hüküm verildikten sonra ve fakat hükme bağlı sonuçlar gerçekleşmeden önce gerçeğin söylenmesi halinde, verilecek cezanın yarısından dörtte üçüne kadarı indirilir.'''
        },
        {
          'no': '278',
          'baslik': 'Suçu bildirmeme',
          'icerik': '''(1) İşlenmekte olan bir suçu yetkili makamlara bildirmeyen kişi, bir yıla kadar hapis cezası ile cezalandırılır.
(2) İşlenmiş olmakla birlikte, sebebiyet verdiği neticelerin sınırlandırılması halen mümkün bulunan bir suçu yetkili makamlara bildirmeyen kişi, yukarıdaki fıkra hükmüne göre cezalandırılır.
(3) Mağdurun onbeş yaşını bitirmemiş bir çocuk, bedensel veya ruhsal bakımdan engelli olan ya da hamileliği nedeniyle kendisini savunamayacak durumda bulunan kimse olması halinde, yukarıdaki fıkralara göre verilecek ceza, yarı oranında artırılır.'''
        },
        {
          'no': '279',
          'baslik': 'Kamu görevlisinin suçu bildirmemesi',
          'icerik': '''(1) Kamu adına soruşturma ve kovuşturmayı gerektiren bir suçun işlendiğini göreviyle bağlantılı olarak öğrenip de yetkili makamlara bildirimde bulunmayı ihmal eden veya bu hususta gecikme gösteren kamu görevlisi, altı aydan iki yıla kadar hapis cezası ile cezalandırılır.
(2) Suçun, adli kolluk görevini yapan kişi tarafından işlenmesi halinde, yukarıdaki fıkraya göre verilecek ceza yarı oranında artırılır.'''
        },
        {
          'no': '281',
          'baslik': 'Suç delillerini yok etme, gizleme veya değiştirme',
          'icerik': '''(1) Gerçeğin meydana çıkmasını engellemek amacıyla, bir suçun delillerini yok eden, silen, gizleyen, değiştiren veya bozan kişi, altı aydan beş yıla kadar hapis cezası ile cezalandırılır. Kendi işlediği veya işlenişine iştirak ettiği suçla ilgili olarak kişiye bu fıkra hükmüne göre ceza verilmez.
(2) Bu suçun kamu görevlisi tarafından göreviyle bağlantılı olarak işlenmesi halinde, verilecek ceza yarı oranında artırılır.'''
        },
        {
          'no': '282',
          'baslik': 'Suçtan kaynaklanan malvarlığı değerlerini aklama',
          'icerik': '''(1) Alt sınırı altı ay veya daha fazla hapis cezasını gerektiren bir suçtan kaynaklanan malvarlığı değerlerini, yurt dışına çıkaran veya bunların gayrimeşru kaynağını gizlemek veya meşru bir yolla elde edildiği konusunda kanaat uyandırmak maksadıyla, çeşitli işlemlere tâbi tutan kişi, üç yıldan yedi yıla kadar hapis ve yirmibin güne kadar adlî para cezası ile cezalandırılır.
(2) Birinci fıkradaki suçun işlenmesine iştirak etmeksizin, bu suçun konusunu oluşturan malvarlığı değerlerini, bu özelliğini bilerek satın alan, kabul eden, bulunduran veya kullanan kişi iki yıldan beş yıla kadar hapis cezası ile cezalandırılır.
(3) Bu suçun, kamu görevlisi tarafından veya belli bir meslek sahibi kişi tarafından bu mesleğin icrası sırasında işlenmesi halinde, verilecek ceza yarı oranında artırılır.
(4) Bu suçun, suç işlemek için teşkil edilmiş bir örgütün faaliyeti çerçevesinde işlenmesi halinde, verilecek ceza bir kat artırılır.
(5) Bu suçun işlenmesi dolayısıyla tüzel kişiler hakkında bunlara özgü güvenlik tedbirlerine hükmolunur.
(6) Bu suç nedeniyle kovuşturma başlamadan önce suç konusu malvarlığı değerlerinin ele geçirilmesini sağlayan veya bunların bulunduğu yeri yetkili makamlara haber vererek ele geçirilmesini kolaylaştıran kişi hakkında bu maddede tanımlanan suç nedeniyle cezaya hükmolunmaz.'''
        },
        {
          'no': '283',
          'baslik': 'Suçluyu kayırma',
          'icerik': '''(1) Suç işleyen bir kişiye araştırma, yakalanma, tutuklanma veya hükmün infazından kurtulması için imkan sağlayan kimse, altı aydan beş yıla kadar hapis cezası ile cezalandırılır.
(2) Bu suçun kamu görevlisi tarafından göreviyle bağlantılı olarak işlenmesi halinde, verilecek ceza yarı oranında artırılır.
(3) Suçu, üstsoy, altsoy, eş, kardeş veya diğer suç ortağı kayırmak amacıyla işleyen kimseye ceza verilmez.'''
        },
        {
          'no': '285',
          'baslik': 'Soruşturmanın gizliliğini ihlal',
          'icerik': '''(1) Soruşturmanın gizliliğini alenen ihlal eden kişi, bir yıldan üç yıla kadar hapis veya adli para cezası ile cezalandırılır. Ancak, soruşturma aşamasında alınan ve kanun gereği gizli tutulması gereken kararların ve bunların gereği olarak yapılan işlemlerin gizliliğinin ihlali hâlinde verilecek ceza alt sınırı iki yıldan az olamaz.
(2) Soruşturma evresinde alınan savunma ile bağlantılı bilgi ve belgelerin gizliliğini ihlal eden kişi, bir yıldan üç yıla kadar hapis cezası ile cezalandırılır.'''
        },
        {
          'no': '288',
          'baslik': 'Adil yargılamayı etkilemeye teşebbüs',
          'icerik': '''(1) Görülmekte olan bir davada veya yapılmakta olan bir soruşturmada, gerçeğin ortaya çıkmasını engellemek veya bir haksızlık oluşturmak amacıyla, davanın taraflarını, katılanı, şüpheliyi, sanığı, müdafii veya vekili, tanığı, bilirkişiyi veya tercümanı hukuka aykırı olarak etkilemeye teşebbüs eden kişi, iki yıldan dört yıla kadar hapis cezası ile cezalandırılır. Teşebbüs iltimas derecesinde kalmış ise, verilecek ceza yarı oranında indirilir.'''
        },
        {
          'no': '292',
          'baslik': 'Hükümlü veya tutuklunun kaçması',
          'icerik': '''(1) Tutukevinden, ceza infaz kurumundan veya gözetimi altında bulunduğu görevlilerin elinden kaçan tutuklu veya hükümlü hakkında altı aydan bir yıla kadar hapis cezasına hükmolunur.
(2) Bu suçun, cebir veya tehdit kullanılarak işlenmesi halinde, bir yıldan üç yıla kadar hapis cezasına hükmolunur.
(3) Bu suçun, silahlı olarak ya da birden çok tutuklu veya hükümlü tarafından birlikte işlenmesi halinde, yukarıdaki fıkralara göre verilecek ceza bir katına kadar artırılır.
(4) Bu suçun işlenmesi sırasında kasten yaralama suçunun neticesi sebebiyle ağırlaşmış hallerinin veya kasten öldürme suçunun gerçekleşmesi ya da eşyaya zarar verilmesi durumunda, ayrıca bu suçlara ilişkin hükümlere göre cezaya hükmolunur.
(5) Bu maddede tanımlanan suçların konusunu oluşturan kaçma eyleminin başka suçlarla bağlantılı olarak gerçekleştirilmesi halinde, bu suç nedeniyle verilecek ceza yarısına kadar indirilebilir.'''
        },
        {
          'no': '297',
          'baslik': 'İnfaz kurumuna veya tutukevine yasak eşya sokmak',
          'icerik': '''(1) İnfaz kurumuna veya tutukevine silah, uyuşturucu veya uyarıcı madde veya elektronik haberleşme aracı sokan veya bulunduran kişi, dört yıldan altı yıla kadar hapis cezası ile cezalandırılır. Bu suçun hükümlü veya tutuklu tarafından işlenmesi halinde iki yıldan dört yıla kadar hapis cezasına hükmolunur.
(2) Birinci fıkra kapsamı dışında kalan;
a) Firarı kolaylaştırıcı her türlü alet ve malzemeyi,
b) Her türlü saldırı ve savunma araçları ile yangın çıkarmaya yarayan malzemeyi,
c) Alkol içeren her türlü içeceği,
d) Kumar oynanmasına olanak sağlayan eşya ve malzemeyi,
e) 188 inci maddede tanımlanan suçlar saklı kalmak üzere, yeşil reçeteye tabi ilaçları,
f) Kurum idaresince bulundurulmasına izin verilmeyen her türlü eşya veya maddeyi,
Ceza infaz kurumuna veya tutukevine sokan, buralarda bulunduran veya kullanan kişi bir yıldan üç yıla kadar hapis cezası ile cezalandırılır. Bu suçun hükümlü veya tutuklu tarafından işlenmesi halinde altı aydan iki yıla kadar hapis cezasına hükmolunur.'''
        },
      ],
    },
  ];


  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredMaddeler {
    if (_searchQuery.isEmpty) return [];
    
    List<Map<String, dynamic>> results = [];
    for (var kisim in _kisimlar) {
      for (var madde in kisim['maddeler']) {
        if (madde['no'].toString().contains(_searchQuery) ||
            madde['baslik'].toString().toLowerCase().contains(_searchQuery.toLowerCase())) {
          results.add({
            ...madde,
            'kisim': kisim['baslik'],
            'color': kisim['color'],
          });
        }
      }
    }
    return results;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      body: Stack(
        children: [
          // Arka plan resmi
          Positioned.fill(
            child: Opacity(
              opacity: 0.12,
              child: Image.asset(
                'assets/images/estor.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Gradient overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF0A0E21).withOpacity(0.3),
                    const Color(0xFF0A0E21).withOpacity(0.9),
                  ],
                ),
              ),
            ),
          ),
          // İçerik
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: _selectedKisimIndex != null
                      ? _buildMaddelerView()
                      : _searchQuery.isNotEmpty
                          ? _buildSearchResults()
                          : _buildKisimlarGrid(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      child: Column(
        children: [
          // Üst bar
          Row(
            children: [
              // Geri butonu
              _buildGlowingIconButton(
                icon: _selectedKisimIndex != null ? Icons.arrow_back_ios_new : Icons.close,
                onTap: () {
                  if (_selectedKisimIndex != null) {
                    setState(() => _selectedKisimIndex = null);
                  } else {
                    Navigator.of(context).pop();
                  }
                },
              ),
              const SizedBox(width: 16),
              // Başlık
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                      ).createShader(bounds),
                      child: Text(
                        _selectedKisimIndex != null
                            ? _kisimlar[_selectedKisimIndex!]['baslik']
                            : 'TÜRK CEZA KANUNU',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _selectedKisimIndex != null
                          ? _kisimlar[_selectedKisimIndex!]['alt']
                          : '5237 Sayılı Kanun',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.5),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              // Logo
              AnimatedBuilder(
                animation: _glowController,
                builder: (context, child) {
                  return Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFFD700).withOpacity(0.3 + _glowController.value * 0.3),
                          blurRadius: 15 + _glowController.value * 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.balance, color: Colors.white, size: 24),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Arama çubuğu
          if (_selectedKisimIndex == null)
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.1),
                    Colors.white.withOpacity(0.05),
                  ],
                ),
                border: Border.all(
                  color: const Color(0xFFFFD700).withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(color: Colors.white, fontSize: 15),
                decoration: InputDecoration(
                  hintText: 'Madde ara... (örn: 125, hakaret)',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                  prefixIcon: Icon(Icons.search, color: const Color(0xFFFFD700).withOpacity(0.7)),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear, color: Colors.white.withOpacity(0.5)),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                ),
                onChanged: (value) => setState(() => _searchQuery = value),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildGlowingIconButton({required IconData icon, required VoidCallback onTap}) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      ),
    );
  }

  Widget _buildKisimlarGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 1.1,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: _kisimlar.length,
      itemBuilder: (context, index) {
        return FadeInUp(
          delay: Duration(milliseconds: index * 50),
          child: _buildKisimCard(index),
        );
      },
    );
  }

  Widget _buildKisimCard(int index) {
    final kisim = _kisimlar[index];
    final color = kisim['color'] as Color;
    
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  LegalCategoryDetailScreen(
                categoryName: kisim['baslik'],
              ),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(1, 0),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCubic,
                    )),
                    child: child,
                  ),
                );
              },
              transitionDuration: const Duration(milliseconds: 400),
            ),
          );
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withOpacity(0.3),
                color.withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withOpacity(0.5), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.2),
                blurRadius: 15,
                spreadRadius: 0,
              ),
            ],
          ),
          child: Stack(
            children: [
              // Glow effect
              Positioned(
                top: -20,
                right: -20,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        color.withOpacity(0.3),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              // Content
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              color,
                              color.withOpacity(0.7),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: color.withOpacity(0.5),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Center(
                          child: kisim['emoji'] != null
                              ? Text(
                                  kisim['emoji'],
                                  style: const TextStyle(fontSize: 42),
                                  textAlign: TextAlign.center,
                                )
                              : Icon(kisim['icon'], color: Colors.white, size: 36),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        kisim['baslik'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        kisim['alt'],
                        style: TextStyle(
                          color: color,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMaddelerView() {
    final kisim = _kisimlar[_selectedKisimIndex!];
    final maddeler = kisim['maddeler'] as List;
    final color = kisim['color'] as Color;
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: maddeler.length,
      itemBuilder: (context, index) {
        final madde = maddeler[index];
        return FadeInLeft(
          delay: Duration(milliseconds: index * 30),
          child: _buildMaddeCard(madde, color),
        );
      },
    );
  }

  Widget _buildMaddeCard(Map<String, dynamic> madde, Color color) {
    return GestureDetector(
      onTap: () => _showMaddeDetail(madde, color),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white.withOpacity(0.08),
              Colors.white.withOpacity(0.03),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            // Madde numarası
            Container(
              width: 55,
              height: 55,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color, color.withOpacity(0.7)],
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.4),
                    blurRadius: 10,
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'M.',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      madde['no'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Başlık
            Expanded(
              child: Text(
                madde['baslik'],
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: color.withOpacity(0.5), size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    final results = _filteredMaddeler;
    
    if (results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.white.withOpacity(0.2)),
            const SizedBox(height: 16),
            Text(
              'Sonuç bulunamadı',
              style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 16),
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final madde = results[index];
        final color = madde['color'] as Color;
        return FadeInUp(
          delay: Duration(milliseconds: index * 30),
          child: _buildMaddeCard(madde, color),
        );
      },
    );
  }

  void _printMadde(Map<String, dynamic> madde, Color color) {
    final String icerik = madde['icerik'] ?? 'Madde içeriği bulunamadı.';
    final String baslik = madde['baslik'] ?? '';
    final String no = madde['no'] ?? '';
    
    // Yazdırma dialogu göster
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF1A1F3C),
                const Color(0xFF0A0E21),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withOpacity(0.5), width: 2),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.print, color: color, size: 48),
              const SizedBox(height: 16),
              Text(
                'Yazdırma Önizleme',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Madde $no - $baslik',
                style: TextStyle(
                  color: color,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.white.withOpacity(0.5), size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Metni kopyalayıp yazdırabilirsiniz',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        // Metni panoya kopyala
                        final text = 'TÜRK CEZA KANUNU\nMadde $no - $baslik\n\n$icerik';
                        await Clipboard.setData(ClipboardData(text: text));
                        Navigator.pop(context);
                        ScaffoldMessenger.of(this.context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                Icon(Icons.check_circle, color: Colors.white),
                                const SizedBox(width: 8),
                                Text('Madde metni panoya kopyalandı'),
                              ],
                            ),
                            backgroundColor: color,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.white.withOpacity(0.2)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.copy, color: Colors.white, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              'Kopyala',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [color, color.withOpacity(0.7)]),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.close, color: Colors.white, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              'Kapat',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showMaddeDetail(Map<String, dynamic> madde, Color color) {
    final String icerik = madde['icerik'] ?? 'Madde içeriği bulunamadı.';
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: 700,
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF1A1F3C),
                const Color(0xFF0A0E21),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: color.withOpacity(0.5), width: 2),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [color, color.withOpacity(0.7)]),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Text(
                        'M.${madde['no']}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Madde ${madde['no']}',
                          style: TextStyle(
                            color: color,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          madde['baslik'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Yazıcı butonu
                  IconButton(
                    onPressed: () => _printMadde(madde, color),
                    tooltip: 'Yazdır',
                    icon: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.print, color: color, size: 18),
                    ),
                  ),
                  const SizedBox(width: 4),
                  // Kapat butonu
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.close, color: Colors.white.withOpacity(0.7), size: 20),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Divider
              Container(
                height: 1,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      color.withOpacity(0.5),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Content - Scrollable
              Flexible(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.03),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: color.withOpacity(0.1)),
                  ),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: SelectableText(
                      icerik,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 15,
                        height: 1.8,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Footer
              Row(
                children: [
                  // Info
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.info_outline, color: color, size: 16),
                          const SizedBox(width: 8),
                          Text(
                            'Türk Ceza Kanunu',
                            style: TextStyle(
                              color: color,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Close Button
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [color, color.withOpacity(0.7)]),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: color.withOpacity(0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check, color: Colors.white, size: 18),
                          SizedBox(width: 8),
                          Text(
                            'Kapat',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
