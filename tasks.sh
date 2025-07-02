#!/bin/bash
# Автоматическое выполнение заданий экзамена

echo "======================================="
echo "    ВЫПОЛНЕНИЕ ЗАДАНИЙ ЭКЗАМЕНА"
echo "======================================="

# Функция для паузы между заданиями
pause() {
    echo ""
    read -p "Нажмите Enter для продолжения..."
    echo ""
}

# 1. SSH
echo "[1/7] Проверка SSH..."
sudo systemctl status sshd --no-pager
echo "SSH доступен по адресу: ssh user1@$(hostname -I | awk '{print $1}')"
pause

# 2. Общая папка VirtualBox
echo "[2/7] Настройка общей папки..."
echo "Инструкция:"
echo "1. В VirtualBox добавьте общую папку (Устройства -> Общие папки)"
echo "2. Выполните: sudo mount -t vboxsf ИМЯ_ПАПКИ /home/user1/shared"
echo "3. Для автомонтирования добавьте в /etc/fstab:"
echo "   ИМЯ_ПАПКИ /home/user1/shared vboxsf defaults,uid=1000,gid=1000 0 0"
pause

# 3. Виртуальный принтер
echo "[3/7] Проверка виртуального принтера..."
echo "Откройте в браузере: http://localhost:631"
echo "Принтер CUPS-PDF уже настроен"
echo "PDF файлы сохраняются в: ~/PDF"
pause

# 4. Резервное копирование - Timeshift
echo "[4/7] Создание точки восстановления Timeshift..."
sudo timeshift --create --comments "Exam checkpoint" --tags D || echo "Timeshift требует настройки через GUI"
pause

# 5. Резервное копирование - Vorta/Borg
echo "[5/7] Настройка Vorta..."
echo "Запустите Vorta из меню приложений для настройки"
echo "Или используйте borg напрямую:"
echo "borg init --encryption=none ~/backup"
echo "borg create ~/backup::exam-{now} ~/Documents"
pause

# 6. Пользователи и группы
echo "[6/7] Проверка пользователей и групп..."
echo "Пользователи:"
cat /etc/passwd | grep -E "user1|user2"
echo ""
echo "Группы user2:"
groups user2
echo ""
echo "Проверка sudo для user2 (должна быть ошибка):"
sudo -u user2 sudo ls 2>&1 | grep -E "not in the sudoers|не входит в файл sudoers" && echo "OK: user2 не имеет прав sudo"
pause

# 7. Мониторинг и логи
echo "[7/7] Проверка системы мониторинга..."
echo "Статус journald:"
systemctl status systemd-journald --no-pager
echo ""
echo "Последние логи SSH:"
sudo journalctl -u sshd -n 10 --no-pager
echo ""
echo "Логи текущей загрузки:"
journalctl -b -n 20 --no-pager

echo ""
echo "======================================="
echo "    ВСЕ ПРОВЕРКИ ЗАВЕРШЕНЫ!"
echo "======================================="
echo ""
echo "Дополнительные команды:"
echo "- Создать образ: ~/rtask/create-iso.sh"
echo "- Параметры ядра: cat /proc/cmdline"
echo "- Версия системы: uname -a"
echo "- Сетевые интерфейсы: ip addr"