{ inputs, ... }:
{
  imports = [
    inputs.zapret-discord-youtube.nixosModules.withTestTools
  ];
  services.zapret-discord-youtube = {
    enable = true;
    configName = "general(ALT9)";
    # configName = "general (ALT12)";
    # configName = "general (FAKE_TLS_AUTO_ALT3)";

    # Game Filter: "null" (отключен), "all" (TCP+UDP), "tcp" (только TCP), "udp" (только UDP)
    gameFilter = "null";  # или "all", "tcp", "udp"

    # Добавляем кастомные домены в list-general-user.txt
    listGeneral = [
      "cache.nixos.org"
      "dl.flathub.org"
      "cdngc.net"
      "cdngs.net"
      "edgecastcdn.net"
      "footprint.net"
      "g-cdn.net"
      "gcdn.co"
      "hwcdn.net"
      "llnwd.net"
      "rblx.com"
      "rbx.com"
      "rbxcdn.biz"
      "rbxcdn.cc"
      "rbxcdn.co"
      "rbxcdn.com"
      "rbxcdn.dev"
      "rbxcdn.fun"
      "rbxcdn.gg"
      "rbxcdn.io"
      "rbxcdn.me"
      "rbxcdn.net"
      "rbxcdn.one"
      "rbxcdn.online"
      "rbxcdn.org"
      "rbxcdn.services"
      "rbxcdn.site"
      "rbxcdn.space"
      "rbxcdn.store"
      "rbxcdn.tech"
      "rbxcdn.today"
      "rbxcdn.tv"
      "rbxcdn.us"
      "rbxcdn.work"
      "rbxcdn.world"
      "rbxcdn.xyz"
      "rbxlabs.com"
      "roblox.cn"
      "roblox.com"
      "roblox.qq.com"
      "robloxapp.com"
      "robloxgames.com"
      "robloxlabs.com"
      "secure.footprint.net"
      "secure.llnwd.net"
      "tr.rbxcdn.com"
      "vrchat.com"
      "vrchat.net"
      "api.vrchat.cloud"
      "status.vrchat.com"
      "vrchat.cloud"
      "pipeline.vrchat.cloud"
      "assets.vrchat.com"
      "creators.vrchat.com"
      "docs.vrchat.com"
      "wiki.vrchat.com"
      "vrchat.community"
      "vrchatassets.com"
      "vrcdn.live"
      "vrcdn.video"
      "vrcdn.cloud"
      "files.vrchat.cloud"
      "cdn.vrchat.com"
      "vrchat.cloudwww.quora.com"
      "vrcpm.vrchat.cloud"
      "obsidian.md"
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
      "18.65.39.105"
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
