#!/data/data/com.termux/files/usr/bin/bash

# Kontrol edilecek gerekli paketlerin listesi
PAKETLER=("termux-x11-nightly" "xfce4" "xfce4-goodies" "dbus")
EKSIK_PAKET=0

echo "🔍 Paket kontrolleri yapılıyor..."

# X11 reposunun ekli olduğundan emin olalım
if [ ! -f "$PREFIX/etc/apt/sources.list.d/x11.list" ]; then
    echo "📦 X11 deposu sisteme ekleniyor..."
    pkg install x11-repo -y
fi

# Paketlerin kurulu olup olmadığını tek tek kontrol et
for pkg in "${PAKETLER[@]}"; do
    if ! dpkg -s "$pkg" >/dev/null 2>&1; then
        echo "❌ Eksik paket tespit edildi: $pkg"
        EKSIK_PAKET=1
    fi
done

# Eğer eksik paket varsa kurulumu başlat
if [ $EKSIK_PAKET -eq 1 ]; then
    echo "🔄 Eksik paketler internetten indiriliyor ve kuruluyor (Bu işlem biraz sürebilir)..."
    pkg update -y
    pkg install "${PAKETLER[@]}" -y
    echo "✅ Tüm paketlerin kurulumu tamamlandı!"
else
    echo "✅ Harika! Tüm gerekli paketler sistemde zaten kurulu."
fi

echo "---"
echo "🔄 Termux-X11 sunucusu başlatılıyor..."
# X11 sunucusunu arka planda başlat
termux-x11 :1 &

# Sunucunun hazır olması için kısa bir süre bekle
sleep 2

echo "🚀 XFCE4 Masaüstü ortamı yükleniyor..."
# Masaüstünü başlat
env DISPLAY=:1 dbus-launch --exit-with-session xfce4-session
