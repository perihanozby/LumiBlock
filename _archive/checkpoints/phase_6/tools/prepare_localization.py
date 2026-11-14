"""English source plus Phase 6 navigation drafts; remaining translations are Phase 8."""
from pathlib import Path
import csv
import re

root = Path(__file__).resolve().parents[1]
prompt = (root / 'docs/MASTER_IMPLEMENTATION_PROMPT.md').read_text(encoding='utf-8-sig')
section = prompt.split('### 10.5 English source strings')[1].split('## 11.')[0]
strings = {}
for line in section.splitlines():
    matches = list(re.finditer(r'(?<!\S)([a-z][a-z0-9_.]*)=', line))
    for index, match in enumerate(matches):
        end = matches[index+1].start() if index+1 < len(matches) else len(line)
        strings[match.group(1)] = line[match.end():end].strip()
for i, month in enumerate(('January February March April May June July August September October November December').split(), 1):
    strings[f'month.{i}'] = month
strings['date.pattern']='{d} {month} {y}'
locales = ['en','tr','es','pt-BR','fr','de','it','ja','ko','zh-CN','ar','hi','id','vi','ru','th']
drafts = {
 'home.play':['Play','Oyna','Jugar','Jogar','Jouer','Spielen','Gioca','プレイ','플레이','开始','العب','खेलें','Main','Chơi','Играть','เล่น'],
 'home.continue':['Continue','Devam et','Continuar','Continuar','Continuer','Fortsetzen','Continua','続ける','계속','继续','متابعة','जारी रखें','Lanjutkan','Tiếp tục','Продолжить','เล่นต่อ'],
 'home.settings':['Settings','Ayarlar','Ajustes','Configurações','Paramètres','Einstellungen','Impostazioni','設定','설정','设置','الإعدادات','सेटिंग्स','Pengaturan','Cài đặt','Настройки','การตั้งค่า'],
 'home.stats':['Statistics','İstatistikler','Estadísticas','Estatísticas','Statistiques','Statistik','Statistiche','統計','통계','统计','الإحصاءات','आँकड़े','Statistik','Thống kê','Статистика','สถิติ'],
 'home.daily':['Daily challenge','Günlük bulmaca','Desafío diario','Desafio diário','Défi du jour','Tagesaufgabe','Sfida giornaliera','デイリーチャレンジ','일일 도전','每日挑战','التحدي اليومي','दैनिक चुनौती','Tantangan harian','Thử thách hằng ngày','Задание дня','ภารกิจรายวัน'],
 'common.back':['Back','Geri','Atrás','Voltar','Retour','Zurück','Indietro','戻る','뒤로','返回','رجوع','वापस','Kembali','Quay lại','Назад','กลับ'],
 'common.cancel':['Cancel','İptal','Cancelar','Cancelar','Annuler','Abbrechen','Annulla','キャンセル','취소','取消','إلغاء','रद्द करें','Batal','Hủy','Отмена','ยกเลิก'],
 'common.confirm':['Confirm','Onayla','Confirmar','Confirmar','Confirmer','Bestätigen','Conferma','確認','확인','确认','تأكيد','पुष्टि करें','Konfirmasi','Xác nhận','Подтвердить','ยืนยัน'],
}
drafts['settings.title']=drafts['home.settings']
drafts['stats.title']=drafts['home.stats']
drafts['daily.title']=drafts['home.daily']
with (root/'localization/strings.csv').open('w',encoding='utf-8',newline='') as f:
    writer = csv.writer(f)
    writer.writerow(['keys']+locales)
    for key, value in strings.items():
        writer.writerow([key]+drafts.get(key,[value]*len(locales)))
print(f'{len(strings)} source keys; 16 locale columns (English placeholders outside en until Phase 8)')
