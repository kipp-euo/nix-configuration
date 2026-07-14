#!/bin/bash


LOG_FILE=~/.config/mako/log.txt
NOTIFICATION_ID_PREFIX="Notification $1: "
ENTRY_PREFIX="Desktop entry: "

echo "---" >> $LOG_FILE
echo "Запущен скрипт для ID: $id" >> $LOG_FILE

NOTIFICATION_ENTRY=$(makoctl list | grep "$NOTIFICATION_ID_PREFIX" -A 3)

if [ -z "$NOTIFICATION_ENTRY" ]; then
    echo "Не найдена запись для $NOTIFICATION_ID_PREFIX" >> $LOG_FILE
    makoctl invoke -n "$id"
    exit 0
fi

 CLASS=$(echo $NOTIFICATION_ENTRY | sed "s/.*${ENTRY_PREFIX}//" | tr [:upper:] [:lower:] | awk '{print $1}')

if [ -z "$CLASS" ]; then
    echo "Не удалось извлечь класс из: $NOTIFICATION_ENTRY" >> $LOG_FILE
else
    echo "Найден класс: $CLASS" >> $LOG_FILE

    WINDOW_ADDRESS=$(hyprctl clients -j | jq -r --arg class "$CLASS" \
        '.[] | select(.class | ascii_downcase == $class) | .address')

    if [ -n "$WINDOW_ADDRESS" ]; then
        echo "Найдено окно: $WINDOW_ADDRESS. Фокусируемся..." >> $LOG_FILE
        hyprctl dispatch focuswindow address:"$WINDOW_ADDRESS"
    else
        echo "Окно с классом '$CLASS' не найдено" >> $LOG_FILE
    fi
fi

makoctl invoke -n "$id"
