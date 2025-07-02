```markdown
# Ansible: Установка и проверка подключения (Ping)

## 1. Установка Ansible на Ubuntu
```bash
sudo apt update
sudo apt install -y ansible
```

## 2. Создание инвентарного файла
Создаем `inventory.ini` в текущей директории:
```ini
[web_servers]
server1 ansible_host=192.168.1.100  # Замените на реальный IP

[all:vars]
ansible_user=ubuntu                 # Пользователь для подключения
ansible_ssh_private_key_file=~/.ssh/id_rsa  # Путь к SSH-ключу
```

## 3. Проверка подключения (Ping)
```bash
ansible web_servers -i inventory.ini -m ping
```

## 4. Ожидаемый вывод при успехе
```json
server1 | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
```

## Дополнительно
- Для подключения по паролю добавьте в `inventory.ini`:
  ```ini
  ansible_ssh_pass=your_password
  ansible_become_pass=your_sudo_password  # Если нужен sudo
  ```
- Для проверки конкретного сервера:
  ```bash
  ansible server1 -i inventory.ini -m ping
  ```
```

### Примечания:
1. Убедитесь, что:
   - SSH-ключ скопирован на целевой сервер (`ssh-copy-id user@server1`)
   - Указан правильный IP и пользователь в `inventory.ini`
2. Если используется облачный сервис (AWS, DigitalOcean), замените `ansible_host` на публичный IP.


### **Подбор ПО для VR/AR-разработки (быстрая настройка)**  

Для выполнения задачи нужно установить:  
1. **Игровой движок** (с поддержкой C#/C++ и VR/AR).  
2. **IDE** (среда разработки).  
3. **SDK для шлемов** (Oculus, HTC Vive, HoloLens).  
4. **3D-редакторы** (для моделей/анимаций).  
5. **Инструменты анализа пользовательского опыта**.  
6. **Защита данных** (VPN, шифрование).  

---

## **1. Игровой движок + IDE**  
### **🔹 Unity + Visual Studio (самый простой вариант)**  
- **Почему Unity?**  
  - Поддержка C# (проще для новичков).  
  - Готовые VR/AR-пакеты (Oculus, OpenXR).  
  - Кроссплатформенность.  
- **Установка:**  
  ```bash
  # Unity Hub (менеджер проектов):
  wget https://public-cdn.cloud.unity3d.com/hub/prod/UnityHub.AppImage
  chmod +x UnityHub.AppImage && ./UnityHub.AppImage

  # Visual Studio Code (или полноценная Visual Studio):
  sudo apt install code
  ```
- **Быстрая настройка VR:**  
  - В Unity Hub установите версию с поддержкой **XR Plugin Management**.  
  - В проекте: `Window → XR Plugin Management` → включите Oculus/OpenXR.  

---

## **2. SDK для шлемов**  
| **Устройство** | **SDK**                          | **Установка**                                                                 |
|----------------|----------------------------------|------------------------------------------------------------------------------|
| **Oculus**     | Oculus Integration (через Unity) | Скачать с [Asset Store](https://assetstore.unity.com/packages/tools/integration/oculus-integration-82022) |
| **HTC Vive**   | SteamVR                         | `sudo apt install steam` + установка через Steam                            |
| **HoloLens**   | Mixed Reality Toolkit (MRTK)    | Через Unity Package Manager                                                |

**Для всех:**  
- Установите **драйверы** с официальных сайтов:  
  - [Oculus PC SDK](https://developer.oculus.com/downloads/)  
  - [SteamVR](https://store.steampowered.com/steamvr)  

---

## **3. 3D-редакторы**  
### **🔹 Blender (бесплатно, быстро)**  
```bash
sudo apt install blender
```
- **Для чего:** моделирование, текстуры, анимация.  
- **Экспорт в Unity:** FBX/GLTF.  

### **🔹 Substance Painter (если есть лицензия)**  
- Текстурирование (необходим Windows/Mac).  

---

## **4. Анализ пользовательского опыта**  
### **🔹 Oculus Debug Tool / SteamVR Performance Test**  
- Встроены в SDK.  
- Анализ FPS, задержек.  

### **🔹 UX-тестирование: Lookback (для Oculus)**  
- Запись сессий пользователей.  

---

## **5. Защита данных**  
### **🔹 VPN (WireGuard)**  
```bash
sudo apt install wireguard
```
- Шифрование трафика между шлемом и ПК.  

### **🔹 HTTPS для API (если есть облачные сервисы)**  
- Используйте **Certbot** для сертификатов:  
  ```bash
  sudo apt install certbot
  sudo certbot certonly --standalone -d ваш-домен.com
  ```

---

## **6. Документ «Руководство пользователя» (по ГОСТ Р 59795–2021)**  
**Структура:**  
1. **Введение** (назначение SDK).  
2. **Системные требования** (ОС, железо).  
3. **Установка** (пошагово, со скриншотами).  
4. **Настройка** (подключение шлема, калибровка).  
5. **Пример проекта** (Hello World на C#).  
6. **Безопасность** (как защитить данные).  

**Пример для Oculus SDK:**  
```markdown
# Руководство пользователя Oculus SDK  
## 1. Установка  
1. Скачайте Oculus PC SDK с [официального сайта](https://developer.oculus.com/).  
2. Запустите `OculusSetup.exe` (Windows) или `.deb` (Ubuntu).  
3. В Unity: `Assets → Import Package → Custom Package → выберите OculusIntegration.unitypackage`.  
...

## 4. Калибровка  
1. Подключите шлем к ПК.  
2. В Unity: `Window → XR Plugin Management → Oculus`.  
3. Нажмите **Play** для теста.  
```

---

## **Итоговая таблица ПО**  
| **Категория**       | **Программа**              | **Ссылка**                                  |  
|----------------------|----------------------------|--------------------------------------------|  
| Движок               | Unity + Visual Studio      | [unity.com](https://unity.com)             |  
| SDK                  | Oculus/SteamVR/MRTK        | См. выше                                   |  
| 3D-редактор          | Blender                    | [blender.org](https://blender.org)         |  
| Анализ UX            | Oculus Debug Tool          | Встроено в SDK                             |  
| Защита               | WireGuard                  | [wireguard.com](https://wireguard.com)     |  

**Результат:**  
- Готовый к работе VR/AR-стек за 1-2 часа.  
- Все компоненты бесплатны (кроме Substance Painter).  
- Совместимость с Ubuntu/Windows.  

Для демонстрации можно записать видео:  
1. Запуск Unity.  
2. Импорт Oculus SDK.  
3. Запуск тестовой сцены в шлеме.