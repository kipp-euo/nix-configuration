{ ... }:
let
	LISTS = "${CONFIG_DIR}/modules/system/zapret/lists/";
	BIN = "${CONFIG_DIR}/modules/system/zapret/bin/";
	LIST_BASIC = "${LISTS}list-basic.txt";
in
{
	services.zapret = {
		enable = true;
		httpMode = "full";
		httpSupport = true;
		udpSupport = true;
		udpPorts = [
			"443"
			"19294:19344"
			"50000:50100"
		];	
		configureFirewall = true;
		params = [
			"--filter-udp=443"
			"--hostlist=${LIST_BASIC}"
			"--dpi-desync=fake"
			"--dpi-desync-repeats=11"
			"--dpi-desync-fake-quic=\"${BIN}/quic_initial_www_google_com.bin\""
			"--new"

			"--filter-udp=19294-19344,50000-50100"
			"--filter-l7=discord,stun"
			"--dpi-desync=fake"
			"--dpi-desync-fake-discord=\"${BIN}/quic_initial_www_google_com.bin\""
			"--dpi-desync-fake-stun=\"${BIN}/quic_initial_www_google_com.bin\""
			"--dpi-desync-repeats=6"
			"--new"

			"--filter-tcp=2053,2083,2087,2096,8443"
			"--hostlist-domains=discord.media"
			"--dpi-desync=fake,multisplit"
			"--dpi-desync-split-seqovl=654"
			"--dpi-desync-split-pos=1"
			"--dpi-desync-fooling=ts"
			"--dpi-desync-repeats=8"
			"--dpi-desync-split-seqovl-pattern=\"${BIN}/tls_clienthello_max_ru.bin\""
			"--dpi-desync-fake-tls=\"${BIN}/tls_clienthello_max_ru.bin\""
			"--new"

			"--filter-tcp=443"
			"--hostlist=${LIST_BASIC}"
			"--ip-id=zero"
			"--dpi-desync=fake,multisplit"
			"--dpi-desync-split-seqovl=681"
			"--dpi-desync-split-pos=1"
			"--dpi-desync-fooling=ts"
			"--dpi-desync-repeats=8"
			"--dpi-desync-split-seqovl-pattern=\"${BIN}/tls_clienthello_www_google_com.bin\""
			"--dpi-desync-fake-tls=\"${BIN}/tls_clienthello_www_google_com.bin\""
			"--new"

			"--filter-tcp=80,443"
			"--hostlist=${LIST_BASIC}"
			"--dpi-desync=fake,multisplit"
			"--dpi-desync-split-seqovl=654"
			"--dpi-desync-split-pos=1"
			"--dpi-desync-fooling=ts"
			"--dpi-desync-repeats=8"
			"--dpi-desync-split-seqovl-pattern=\"${BIN}/tls_clienthello_max_ru.bin\""
			"--dpi-desync-fake-tls=\"${BIN}/tls_clienthello_max_ru.bin\""
			"--new"

			"--filter-udp=443"
			"--dpi-desync=fake"
			"--dpi-desync-repeats=11"
			"--dpi-desync-fake-quic=\"${BIN}/quic_initial_www_google_com.bin\""
			"--new"
		];
	};
}
