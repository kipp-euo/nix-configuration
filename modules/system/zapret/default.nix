{ inputs, ... }:
{
  imports = [
    inputs.zapret-discord-youtube.nixosModules.withTestTools
  ];
  services.zapret-discord-youtube = {
    enable = true;
    configName = "general (ALT12)";

    # Game Filter: "null" (отключен), "all" (TCP+UDP), "tcp" (только TCP), "udp" (только UDP)
    gameFilter = "null";  # или "all", "tcp", "udp"

    # Добавляем кастомные домены в list-general-user.txt
    listGeneral = [
      "cache.nixos.org"
      "dl.flathub.org"
      "roblox.com"
      "rbxcdn.com"
      "rblx.com"
      "robloxapp.com"
      "robloxgames.com"
      "robloxlabs.com"
      "rbx.com"
      "rbxlabs.com"
      "rbxcdn.xyz"
      "rbxcdn.site"
      "rbxcdn.tech"
      "rbxcdn.one"
      "rbxcdn.today"
      "rbxcdn.world"
      "rbxcdn.services"
      "rbxcdn.work"
      "rbxcdn.space"
      "rbxcdn.online"
      "rbxcdn.store"
      "rbxcdn.fun"
      "rbxcdn.biz"
      "rbxcdn.us"
      "rbxcdn.org"
      "rbxcdn.net"
      "rbxcdn.co"
      "rbxcdn.me"
      "rbxcdn.tv"
      "rbxcdn.cc"
      "rbxcdn.gg"
      "rbxcdn.dev"
      "rbxcdn.io"
      "edgecastcdn.net"
      "footprint.net"
      "llnwd.net"
      "hwcdn.net"
      "gcdn.co"
      "g-cdn.net"
      "cdngc.net"
      "cdngs.net"
      "secure.footprint.net"
      "secure.llnwd.net"
      "roblox.qq.com"
      "roblox.cn"
    ];
    # Добавляем домены в list-exclude-user.txt (исключения)
    listExclude = [
      "ubisoft.com"
      "origin.com"
    ];
    # Добавляем IP адреса в ipset-all.txt
    ipsetAll = [
      "192.168.1.0/24"
      "10.0.0.1"
    ];
    # Добавляем IP адреса в ipset-exclude-user.txt (исключения)
    ipsetExclude = [
      "203.0.113.0/24"
    ];

    # Необязательно: пользовательские hostlists и конфиги.
    # extraHostlists может содержать несколько файлов.
    # Если нужен пример для GitHub, раскомментируйте блок ниже
    # и оставьте в configName выбранный вами готовый конфиг.
    #
    # extraHostlists."list-github.txt" = [
    #   "github.com"
    #   "api.github.com"
    #   "raw.githubusercontent.com"
    #   "objects.githubusercontent.com"
    #   "githubusercontent.com"
    #   "githubassets.com"
    # ];
    #
    # extraHostlists."list-custom.txt" = [
    #   "example.com"
    #   "example.org"
    # ];
    #
    # nfqwsAppend = [
    #   ''--filter-tcp=443 --hostlist="/opt/zapret/hostlists/list-github.txt" --dpi-desync=multisplit --dpi-desync-split-pos=2''
    # ];
    #
    # Для полностью ручного конфига можно создать отдельный файл:
    # extraConfigs."my-custom-config" = ''
    #   NFQWS_ENABLE=1
    #   NFQWS_OPT="
    #   --filter-tcp=443 --hostlist="/opt/zapret/hostlists/list-github.txt" --dpi-desync=multisplit --dpi-desync-split-pos=2
    #   "
    # '';
  };
}
