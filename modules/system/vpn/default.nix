{ pkgs, ... }:
{
  programs.clash-verge = {
    enable = true;
    package = pkgs.clash-verge-rev; # Использует clash-verge-rev по умолчанию
    serviceMode = true;             # Включает системную службу для работы TUN-режима
    tunMode = true;                 # Настраивает capabilities/rpfilter для TUN-интерфейса
    autoStart = true;               # Автозапуск приложения (опционально)
    group = "users";                # Группа доступа к сокету службы
  };
}

