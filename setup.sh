#!/bin/bash
# Настройка системы после первой загрузки

echo "======================================="
echo "    НАСТРОЙКА СИСТЕМЫ"
echo "======================================="

# Проверка, что запущено от user1
if [ "$USER" != "user1" ]; then
    echo "Запустите скрипт от пользователя user1!"
    exit 1
fi

# Обновление системы
echo "Обновление системы..."
sudo pacman -Syu --noconfirm

# Установка дополнительных пакетов
echo "Установка дополнительных пакетов..."
yay -S --noconfirm --needed \
    vorta borg \
    timeshift \
    cups cups-pdf ghostscript \
    htop neofetch \
    mc ranger

# Настройка SSH
echo "Настройка SSH..."
if [ ! -f ~/.ssh/id_rsa ]; then
    ssh-keygen -t rsa -N "" -f ~/.ssh/id_rsa
fi

# Создание директорий
mkdir -p ~/Documents ~/Downloads ~/Desktop ~/shared ~/PDF

# Настройка CUPS
echo "Настройка виртуального принтера..."
sudo systemctl enable cups
sudo systemctl start cups
sudo sed -i "s|#Out /var/spool/cups-pdf/\${USER}|Out /home/user1/PDF|" /etc/cups/cups-pdf.conf
sudo systemctl restart cups

# Создание второго пользователя для тестов
echo "Создание тестового пользователя..."
sudo useradd -m -s /bin/bash user2 || true
echo "user2:123" | sudo chpasswd
sudo groupadd students || true
sudo usermod -aG students user2

# Информация о системе
echo ""
echo "======================================="
echo "    СИСТЕМА ГОТОВА!"
echo "======================================="
echo "IP адрес: $(ip addr show | grep 'inet ' | grep -v '127.0.0.1' | awk '{print $2}' | cut -d/ -f1 | head -n1)"
echo "SSH: ssh user1@$(ip addr show | grep 'inet ' | grep -v '127.0.0.1' | awk '{print $2}' | cut -d/ -f1 | head -n1)"
echo "CUPS: http://localhost:631"
echo ""
echo "Для выполнения заданий запустите: ./tasks.sh"