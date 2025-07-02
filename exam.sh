#!/bin/bash
# Универсальный скрипт для выполнения экзаменационных заданий
# Можно запускать многократно и выбирать нужные пункты

set -e

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m'

# Файл для сохранения состояния
STATE_FILE="$HOME/.exam_state"

# Функции для красивого вывода
print_header() {
    echo -e "\n${BLUE}╔══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${NC}  ${CYAN}$1${NC}"
    echo -e "${BLUE}╚══════════════════════════════════════════════════════════╝${NC}\n"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_command() {
    echo -e "${MAGENTA}КОМАНДА:${NC} ${YELLOW}$1${NC}"
}

print_instruction() {
    echo -e "${CYAN}→ $1${NC}"
}

wait_for_user() {
    echo -e "\n${YELLOW}Нажмите Enter после выполнения действий...${NC}"
    read -r
}

# Функция для выполнения команд с отображением
execute_command() {
    local cmd="$1"
    print_command "$cmd"
    eval "$cmd"
}

# Функция для сохранения состояния
save_state() {
    echo "$1" >> "$STATE_FILE"
}

check_state() {
    if [ -f "$STATE_FILE" ]; then
        grep -q "^$1$" "$STATE_FILE" && return 0 || return 1
    fi
    return 1
}

# =============================================
# ЗАДАНИЕ 1: Обновление системы и базовое ПО
# =============================================
task_1_system_update() {
    print_header "1. ОБНОВЛЕНИЕ СИСТЕМЫ И УСТАНОВКА БАЗОВОГО ПО"

    if check_state "task_1_complete"; then
        print_success "Задание уже выполнено"
        return
    fi

    echo "Обновление системы..."
    execute_command "sudo apt update && sudo apt upgrade -y"

    echo -e "\nУстановка базового ПО..."
    execute_command "sudo apt install -y firefox chromium-browser libreoffice gimp inkscape vlc mpv git wget curl htop neofetch mc ranger zip unzip p7zip-full ntfs-3g dosfstools"

    save_state "task_1_complete"
    print_success "Система обновлена и базовое ПО установлено"
    wait_for_user
}

# =============================================
# ЗАДАНИЕ 2: Виртуальный принтер CUPS
# =============================================
task_2_virtual_printer() {
    print_header "2. НАСТРОЙКА ВИРТУАЛЬНОГО ПРИНТЕРА CUPS-PDF"

    if check_state "task_2_complete"; then
        print_success "Задание уже выполнено"
        return
    fi

    echo "Установка компонентов печати..."
    execute_command "sudo apt install -y cups cups-pdf ghostscript"

    echo -e "\nЗапуск служб печати..."
    execute_command "sudo systemctl enable cups.service"
    execute_command "sudo systemctl start cups.service"

    echo -e "\nСоздание папки для PDF файлов..."
    execute_command "mkdir -p ~/PDF"

    echo -e "\nНастройка пути сохранения PDF..."
    execute_command "sudo sed -i 's|#Out /var/spool/cups-pdf/${USER}|Out /home/$USER/PDF|' /etc/cups/cups-pdf.conf"
    execute_command "sudo systemctl restart cups.service"

    print_instruction "Теперь настройте принтер через веб-интерфейс:"
    print_instruction "1. Откройте браузер и перейдите по адресу: http://localhost:631"
    print_instruction "2. Нажмите 'Administration' → 'Add Printer'"
    print_instruction "3. Введите логин: $USER и ваш пароль"
    print_instruction "4. Выберите 'CUPS-PDF (Virtual PDF Printer)'"
    print_instruction "5. Задайте имя принтера: PDF"
    print_instruction "6. Поставьте галочку 'Share This Printer'"
    print_instruction "7. Выберите Make: Generic"
    print_instruction "8. Выберите Model: Generic CUPS-PDF Printer"
    print_instruction "9. Нажмите 'Add Printer'"
    print_instruction "10. Протестируйте: Printers → PDF → Print Test Page"

    echo -e "\n${GREEN}PDF файлы будут сохраняться в: ~/PDF${NC}"

    save_state "task_2_complete"
    wait_for_user
}

# =============================================
# ЗАДАНИЕ 3: SSH сервер
# =============================================
task_3_ssh_setup() {
    print_header "3. НАСТРОЙКА SSH СЕРВЕРА"

    if check_state "task_3_complete"; then
        print_success "Задание уже выполнено"
        return
    fi

    echo "Установка и запуск SSH..."
    execute_command "sudo apt install -y openssh-server"
    execute_command "sudo systemctl enable ssh"
    execute_command "sudo systemctl start ssh"

    # Генерация SSH ключей
    if [ ! -f ~/.ssh/id_rsa ]; then
        echo -e "\nГенерация SSH ключей..."
        execute_command "ssh-keygen -t rsa -b 2048 -N '' -f ~/.ssh/id_rsa"
    fi

    MY_IP=$(hostname -I | awk '{print $1}')

    print_success "SSH сервер запущен!"
    echo -e "\n${GREEN}Для проверки SSH подключения:${NC}"
    print_instruction "1. Откройте ВТОРОЙ терминал"
    print_instruction "2. Выполните команду:"
    print_command "ssh $USER@$MY_IP"
    print_instruction "3. Введите пароль: (ваш текущий пароль)"
    print_instruction "4. После успешного подключения введите: exit"

    save_state "task_3_complete"
    wait_for_user
}

# =============================================
# ЗАДАНИЕ 4: Общая папка VirtualBox
# =============================================
task_4_shared_folder() {
    print_header "4. НАСТРОЙКА ОБЩЕЙ ПАПКИ VIRTUALBOX"

    echo "Установка Guest Additions..."
    execute_command "sudo apt install -y virtualbox-guest-utils"
    execute_command "sudo usermod -aG vboxsf $USER"

    echo -e "\nСоздание точки монтирования..."
    execute_command "mkdir -p ~/shared_exam"

    print_instruction "ВАЖНО! Настройка общей папки в VirtualBox:"
    echo -e "${YELLOW}════════════════════════════════════════════════════════════${NC}"
    print_instruction "1. ВЫКЛЮЧИТЕ виртуальную машину (команда: sudo poweroff)"
    print_instruction "2. В VirtualBox откройте настройки этой VM"
    print_instruction "3. Перейдите в раздел 'Общие папки'"
    print_instruction "4. Нажмите на '+' (добавить общую папку)"
    print_instruction "5. В поле 'Путь к папке' выберите папку на основной системе"
    print_instruction "6. В поле 'Имя папки' введите: exam_share"
    print_instruction "7. Поставьте галочки:"
    print_instruction "   ✓ Авто-подключение"
    print_instruction "   ✓ Создать постоянную папку"
    print_instruction "8. Нажмите OK и запустите VM"
    echo -e "${YELLOW}════════════════════════════════════════════════════════════${NC}"

    echo -e "\n${GREEN}После перезагрузки выполните:${NC}"
    print_command "sudo mount -t vboxsf exam_share ~/shared_exam"

    echo -e "\n${GREEN}Для автоматического монтирования добавьте в /etc/fstab:${NC}"
    echo -e "${YELLOW}exam_share /home/$USER/shared_exam vboxsf defaults,uid=1000,gid=1000 0 0${NC}"

    wait_for_user
}

# =============================================
# ЗАДАНИЕ 5: Пользователи и группы
# =============================================
task_5_users_groups() {
    print_header "5. СОЗДАНИЕ ПОЛЬЗОВАТЕЛЕЙ И ГРУПП"

    if check_state "task_5_complete"; then
        print_success "Задание уже выполнено"
        return
    fi

    echo "Создание групп..."
    execute_command "sudo groupadd -f students"
    execute_command "sudo groupadd -f developers"
    execute_command "sudo groupadd -f managers"

    echo -e "\nСоздание пользователей..."
    execute_command "sudo useradd -m -G students -s /bin/bash student1 || echo 'Пользователь student1 уже существует'"
    execute_command "sudo useradd -m -G developers,sudo -s /bin/bash dev1 || echo 'Пользователь dev1 уже существует'"
    execute_command "sudo useradd -m -G managers -s /bin/bash manager1 || echo 'Пользователь manager1 уже существует'"

    echo -e "\nУстановка паролей..."
    execute_command "echo 'student1:exam123' | sudo chpasswd"
    execute_command "echo 'dev1:exam123' | sudo chpasswd"
    execute_command "echo 'manager1:exam123' | sudo chpasswd"

    echo -e "\nСоздание общих директорий..."
    execute_command "sudo mkdir -p /opt/shared/{public,developers,managers}"

    echo -e "\nНастройка прав доступа..."
    execute_command "sudo chown -R :developers /opt/shared/developers"
    execute_command "sudo chown -R :managers /opt/shared/managers"
    execute_command "sudo chmod 770 /opt/shared/developers"
    execute_command "sudo chmod 770 /opt/shared/managers"
    execute_command "sudo chmod 777 /opt/shared/public"

    echo -e "\n${GREEN}Созданные пользователи:${NC}"
    echo "  • student1 (пароль: exam123) - группа students, без sudo"
    echo "  • dev1 (пароль: exam123) - группы developers и sudo, с sudo"
    echo "  • manager1 (пароль: exam123) - группа managers, без sudo"

    echo -e "\n${GREEN}Проверка прав sudo:${NC}"
    execute_command "sudo -u student1 sudo ls 2>&1 | grep -E 'not in the sudoers|не входит' || echo 'Ошибка проверки'"

    save_state "task_5_complete"
    wait_for_user
}

# =============================================
# ЗАДАНИЕ 6: Резервное копирование Timeshift
# =============================================
task_6_timeshift() {
    print_header "6. СОЗДАНИЕ ТОЧКИ ВОССТАНОВЛЕНИЯ TIMESHIFT"

    if check_state "task_6_complete"; then
        print_success "Задание уже выполнено"
        return
    fi

    echo "Установка Timeshift..."
    execute_command "sudo apt install -y timeshift || sudo snap install timeshift"

    echo -e "\n${GREEN}Создание снимка системы:${NC}"

    # Попытка создать в CLI
    if sudo timeshift --create --comments 'Экзамен - контрольная точка' --tags D 2>/dev/null; then
        print_success "Снимок создан успешно!"
    else
        print_instruction "Timeshift требует настройки через GUI:"
        print_instruction "1. Запустите: sudo timeshift-gtk"
        print_instruction "2. Выберите тип снимков: RSYNC"
        print_instruction "3. Выберите диск для снимков (обычно /)"
        print_instruction "4. Нажмите Next → Next → Finish"
        print_instruction "5. Нажмите кнопку 'Create' для создания снимка"
        print_instruction "6. Введите комментарий: Экзамен - контрольная точка"

        echo -e "\n${YELLOW}Команда для запуска GUI:${NC}"
        print_command "sudo timeshift-gtk"
    fi

    echo -e "\n${GREEN}Команды для работы с Timeshift:${NC}"
    print_command "sudo timeshift --list"
    print_command "sudo timeshift --create --comments 'Описание' --tags D"
    print_command "sudo timeshift --restore"

    save_state "task_6_complete"
    wait_for_user
}

# =============================================
# ЗАДАНИЕ 7: Резервное копирование Borg
# =============================================
task_7_borg_backup() {
    print_header "7. РЕЗЕРВНОЕ КОПИРОВАНИЕ BORG"

    if check_state "task_7_complete"; then
        print_success "Задание уже выполнено"
        return
    fi

    echo "Установка Borg и Vorta..."
    execute_command "sudo apt install -y borgbackup vorta || sudo snap install borgbackup vorta"

    BORG_REPO="$HOME/backup-exam"

    echo -e "\nСоздание репозитория Borg..."
    execute_command "mkdir -p $BORG_REPO"
    execute_command "borg init --encryption=none $BORG_REPO"

    echo -e "\nСоздание тестовых файлов..."
    execute_command "mkdir -p ~/Documents/exam"
    execute_command "echo 'Экзаменационный документ' > ~/Documents/exam/test.txt"
    execute_command "echo 'Настройки системы' > ~/Documents/exam/config.txt"
    execute_command "echo 'Важные данные для резервного копирования' > ~/Documents/exam/important.txt"

    echo -e "\nСоздание резервной копии..."
    execute_command "borg create $BORG_REPO::exam-$(date +%Y%m%d-%H%M%S) ~/Documents"

    echo -e "\nПросмотр архивов..."
    execute_command "borg list $BORG_REPO"

    echo -e "\n${GREEN}Команды Borg для справки:${NC}"
    print_command "borg create ~/backup-exam::backup-{now} ~/Documents"
    print_command "borg list ~/backup-exam"
    print_command "borg extract ~/backup-exam::имя-архива"

    echo -e "\n${GREEN}Для GUI используйте Vorta:${NC}"
    print_command "vorta"

    save_state "task_7_complete"
    wait_for_user
}

# =============================================
# ЗАДАНИЕ 8: Создание ISO образа
# =============================================
task_8_create_iso() {
    print_header "8. СОЗДАНИЕ ISO ОБРАЗА СИСТЕМЫ"

    echo "Установка genisoimage (mkisofs)..."
    execute_command "sudo apt install -y genisoimage"

    echo -e "\nПодготовка конфигурации..."
    execute_command "mkdir -p ~/iso-exam"
    execute_command "cp -r ~/Documents/exam/* ~/iso-exam/ || echo 'Нет файлов для копирования'"

    print_instruction "ISO образ будет создаваться в общую папку"
    print_instruction "Убедитесь, что общая папка настроена и примонтирована!"

    echo -e "\n${YELLOW}Процесс создания ISO (пример):${NC}"
    print_command "cd ~/iso-exам"
    print_command "mkisofs -o ~/shared_exam/exam.iso -V EXAM_ISO ."

    echo -e "\n${GREEN}Запускаем создание ISO...${NC}"
    cd ~/iso-exам

    if [ -d ~/shared_exam ] && mountpoint -q ~/shared_exam; then
        execute_command "mkisofs -o ~/shared_exam/exam.iso -V EXAM_ISO ."
        print_success "ISO образ создан в общей папке!"
    else
        print_error "Общая папка не примонтирована!"
        print_instruction "Сначала настройте общую папку (пункт 4)"
        print_instruction "После настройки выполните команды выше вручную"
    fi

    wait_for_user
}

# =============================================
# ЗАДАНИЕ 10: Полезная информация
# =============================================
task_10_system_info() {
    print_header "10. СИСТЕМНАЯ ИНФОРМАЦИЯ И КОМАНДЫ"

    MY_IP=$(hostname -I | awk '{print $1}')
    OS_NAME=$(lsb_release -d 2>/dev/null | cut -f2-)
    if [ -z "$OS_NAME" ]; then
        OS_NAME=$(grep PRETTY_NAME /etc/os-release | cut -d'=' -f2 | tr -d '"')
    fi

    echo -e "${GREEN}Информация о системе:${NC}"
    echo "  • Пользователь: $USER"
    echo "  • Домашняя директория: $HOME"
    echo "  • IP адрес: $MY_IP"
    echo "  • Ядро: $(uname -r)"
    echo "  • Дистрибутив: $OS_NAME"

    echo -e "\n${GREEN}Важные пути:${NC}"
    echo "  • PDF принтер: ~/PDF"
    echo "  • Резервные копии Borg: ~/backup-exam"
    echo "  • ISO образ: ~/shared_exam/"
    echo "  • Общие папки: /opt/shared/"
    echo "  • Журналы: journalctl"

    echo -e "\n${GREEN}Учетные записи:${NC}"
    echo "  • student1 (пароль: exam123)"
    echo "  • dev1 (пароль: exam123)"
    echo "  • manager1 (пароль: exam123)"

    echo -e "\n${GREEN}Сетевые службы:${NC}"
    echo "  • SSH: ssh $USER@$MY_IP"
    echo "  • CUPS: http://localhost:631"

    echo -e "\n${GREEN}Команды для проверки:${NC}"
    print_command "systemctl status ssh"
    print_command "systemctl status cups"
    print_command "groups student1 dev1 manager1"
    print_command "ls -la /opt/shared/"

    wait_for_user
}

# =============================================
# ЗАДАНИЕ 9: Мониторинг и журналы
# =============================================
task_9_monitoring() {
    print_header "9. ПРОВЕРКА ЖУРНАЛОВ МОНИТОРИНГА"

    echo "Проверка systemd-journald..."
    execute_command "systemctl status systemd-journald --no-pager"

    echo -e "\n${GREEN}Полезные команды для работы с журналами:${NC}"

    echo -e "\nПросмотр логов текущей загрузки:"
    print_command "journalctl -b"

    echo -e "\nПросмотр логов за последний час:"
    print_command "journalctl --since '1 hour ago'"

    echo -e "\nПросмотр логов конкретной службы:"
    print_command "journalctl -u ssh"
    print_command "journalctl -u cups"

    echo -e "\nПросмотр критических ошибок:"
    print_command "journalctl -p err"

    echo -e "\nНепрерывный просмотр логов:"
    print_command "journalctl -f"

    echo -e "\n${GREEN}Примеры использования:${NC}"
    execute_command "journalctl -u ssh -n 5 --no-pager"

    wait_for_user
}

# =============================================
# ГЛАВНОЕ МЕНЮ
# =============================================
show_menu() {
    clear
    echo -e "${BLUE}╔══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${NC}         ${CYAN}ЭКЗАМЕНАЦИОННЫЕ ЗАДАНИЯ - UBUNTU${NC}              ${BLUE}║${NC}"
    echo -e "${BLUE}╠══════════════════════════════════════════════════════════╣${NC}"
    echo -e "${BLUE}║${NC} ${GREEN}1)${NC} Обновление системы и установка базового ПО           ${BLUE}║${NC}"
    echo -e "${BLUE}║${NC} ${GREEN}2)${NC} Настройка виртуального принтера CUPS-PDF            ${BLUE}║${NC}"
    echo -e "${BLUE}║${NC} ${GREEN}3)${NC} Настройка SSH сервера                               ${BLUE}║${NC}"
    echo -e "${BLUE}║${NC} ${GREEN}4)${NC} Настройка общей папки VirtualBox                   ${BLUE}║${NC}"
    echo -e "${BLUE}║${NC} ${GREEN}5)${NC} Создание пользователей и групп                      ${BLUE}║${NC}"
    echo -e "${BLUE}║${NC} ${GREEN}6)${NC} Создание точки восстановления Timeshift            ${BLUE}║${NC}"
    echo -e "${BLUE}║${NC} ${GREEN}7)${NC} Резервное копирование Borg                         ${BLUE}║${NC}"
    echo -e "${BLUE}║${NC} ${GREEN}8)${NC} Создание ISO образа системы                        ${BLUE}║${NC}"
    echo -e "${BLUE}║${NC} ${GREEN}9)${NC} Проверка журналов мониторинга                      ${BLUE}║${NC}"
    echo -e "${BLUE}║${NC} ${GREEN}10)${NC} Системная информация и команды                    ${BLUE}║${NC}"
    echo -e "${BLUE}║${NC}                                                          ${BLUE}║${NC}"
    echo -e "${BLUE}║${NC} ${YELLOW}A)${NC} Выполнить ВСЕ задания автоматически                ${BLUE}║${NC}"
    echo -e "${BLUE}║${NC} ${YELLOW}S)${NC} Показать статус выполненных заданий                ${BLUE}║${NC}"
    echo -e "${BLUE}║${NC} ${YELLOW}R)${NC} Сбросить статус (начать заново)                    ${BLUE}║${NC}"
    echo -e "${BLUE}║${NC} ${RED}Q)${NC} Выход                                               ${BLUE}║${NC}"
    echo -e "${BLUE}╚══════════════════════════════════════════════════════════╝${NC}"
    echo -e "\n${CYAN}Выберите задание:${NC} "
}

show_status() {
    print_header "СТАТУС ВЫПОЛНЕНИЯ ЗАДАНИЙ"

    tasks=("task_1_complete" "task_2_complete" "task_3_complete" "task_4_complete"
           "task_5_complete" "task_6_complete" "task_7_complete" "task_8_complete")
    names=("Система и базовое ПО" "Виртуальный принтер" "SSH сервер" "Общая папка"
           "Пользователи и группы" "Timeshift" "Borg backup" "ISO образ")

    for i in "${!tasks[@]}"; do
        if check_state "${tasks[$i]}"; then
            echo -e "${GREEN}✓${NC} $((i+1)). ${names[$i]}"
        else
            echo -e "${RED}✗${NC} $((i+1)). ${names[$i]}"
        fi
    done

    wait_for_user
}

run_all_tasks() {
    print_header "ВЫПОЛНЕНИЕ ВСЕХ ЗАДАНИЙ"

    tasks=(task_1_system_update task_2_virtual_printer task_3_ssh_setup
           task_4_shared_folder task_5_users_groups task_6_timeshift
           task_7_borg_backup task_8_create_iso task_9_monitoring)

    for task in "${tasks[@]}"; do
        $task
    done

    print_header "ВСЕ ЗАДАНИЯ ВЫПОЛНЕНЫ!"
}

# Основной цикл
while true; do
    show_menu
    read -r choice

    case $choice in
        1) task_1_system_update ;;
        2) task_2_virtual_printer ;;
        3) task_3_ssh_setup ;;
        4) task_4_shared_folder ;;
        5) task_5_users_groups ;;
        6) task_6_timeshift ;;
        7) task_7_borg_backup ;;
        8) task_8_create_iso ;;
        9) task_9_monitoring ;;
        10) task_10_system_info ;;
        [Aa]) run_all_tasks ;;
        [Ss]) show_status ;;
        [Rr])
            rm -f "$STATE_FILE"
            print_success "Статус сброшен"
            sleep 2
            ;;
        [Qq])
            echo -e "\n${GREEN}До свидания!${NC}"
            exit 0
            ;;
        *)
            print_error "Неверный выбор"
            sleep 2
            ;;
    esac
done