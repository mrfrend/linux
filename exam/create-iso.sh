#!/bin/bash
# Создание образа системы

echo "Создание ISO образа системы..."

# Установка archiso если нет
sudo pacman -S --needed archiso

# Копирование конфигурации
cp -r /usr/share/archiso/configs/releng ~/archiso-exam
cd ~/archiso-exam

# Создание образа
sudo mkarchiso -v -w ./work -o ./out ./

echo "ISO образ создан в: ~/archiso-exam/out/"