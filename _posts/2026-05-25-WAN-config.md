---
layout: post
title: 四埠 WAN 備援路由架構 IP 規劃 VLAN 分段與遠端工作站設計
subtitle: BFD and IP SLA 切換 OOB 管理平面 vMLX 推理叢集 Port Forwarding
cover-img: /assets/img/header/2026-05-14/CEREBRAS.jpeg
thumbnail-img: /assets/img/thumb.png
share-img: /assets/img/header/2026-05-14/CEREBRAS.jpeg
published: true
pinned: false
mathjax: true
tags: [draft, WAN]
---


# 架構概述

本文記錄一套以四埠 WAN 路由器為核心的備援網路設計，涵蓋 IP 位址規劃、VLAN 分段策略、Mac M5 Pro vMLX 推理叢集的 Port Forwarding，以及透過 WireGuard VPN 實現遠端工作站接入同一 VLAN 的方案。

整體架構分為兩個獨立的 WAN segment：

Server Farm segment：WAN1（ISP 光纖 10G，主路徑）+ WAN2（5G 行動網路 1G，備援）
Generic Internet segment：WAN3（ISP 光纖 10G，主路徑）+ WAN4（5G 行動網路 1G，備援）
每個 segment 各自使用 BFD + IP SLA 做健康偵測，觸發 Active/Standby 切換。管理平面（OOB）與資料平面完全物理隔離。

## 拓撲圖

下圖為完整拓撲，包含 WAN 備援、OOB 管理平面、L3 switch 至 Cluster Servers（100G）、Access Switch 至 Super-WS（100G 保留埠）。
WAN 備援拓撲圖

![wan_router_oob_superws-diagram](/assets/img/header/2026-05-25/wan_router_oob_superws.svg)

圖：四埠 WAN 路由器備援拓撲（BFD + IP SLA / OOB management / Super-WS 100G）

VLAN 規劃

VLAN	名稱	子網路	閘道	主機數	用途
10	mgmt	10.0.10.0/24	10.0.10.1	254	OOB 管理：路由器、交換器、IPMI/BMC
20	server-farm	10.0.20.0/23	10.0.20.1	510	一般應用伺服器、容器
30	model-srv	10.0.30.0/24	10.0.30.1	254	Mac M5 Pro vMLX 推理叢集
40	storage	10.0.40.0/24	10.0.40.1	254	NAS、pgvector DB、備份目標
50	workstation	10.0.50.0/23	10.0.50.1	510	辦公室工作站（10G 埠）
60	super-ws	10.0.60.0/24	10.0.60.1	254	高效能工作站（100G 保留埠）
70	remote-ws	10.0.70.0/24	10.0.70.1	254	遠端工作站（WireGuard VPN 接入）
80	5g-mobile	10.0.80.0/24	10.0.80.1	254	5G Phone Gateway NAT 客戶端
99	transit-L3	10.0.99.0/30	—	p2p	路由器 ↔ L3 switch 點對點
100	transit-ACC	10.0.99.4/30	—	p2p	路由器 ↔ Access switch 點對點
VLAN Trunk / Access 埠分配

L3 switch（Server Farm 側）

埠	模式	所屬 VLAN
上行 → 路由器（10G）	Trunk	10, 20, 30, 40，native 99
Mac M5 Pro Node 0–2	Access	30
應用伺服器	Access	20
NAS / pgvector	Access	40
OOB mgmt 上行	Access	10
Access switch（Generic Internet 側）

埠	模式	所屬 VLAN
上行 → 路由器（10G）	Trunk	10, 50, 60, 70, 80，native 100
標準工作站（10G）	Access	50
Super-WS（100G 保留）	Access	60
5G Phone Gateway 客戶端	Access	80
OOB mgmt 上行	Access	10
IP 位址規劃

網路設備

裝置	介面 / SVI	IP 位址	備註
WAN 路由器	WAN1（ISP 光纖）	ISP 指派	主路徑；BFD probe 目標為 ISP GW
WAN2（5G GW）	192.168.1.1/24	備援；IP SLA 健康探測
Transit → L3 switch	10.0.99.1/30	VLAN 99 native
Transit → Access switch	10.0.99.5/30	VLAN 100 native
OOB mgmt 埠	10.0.10.1/24	VLAN 10 閘道
L3 switch	Uplink → 路由器	10.0.99.2/30	Transit VLAN 99
SVI VLAN 20	10.0.20.1	Server farm 閘道
SVI VLAN 30	10.0.30.1	Model server 閘道
SVI VLAN 40	10.0.40.1	Storage 閘道
OOB mgmt	10.0.10.11/24	VLAN 10 管理
Access switch	Uplink → 路由器	10.0.99.6/30	Transit VLAN 100
SVI VLAN 50	10.0.50.1	工作站閘道
SVI VLAN 60	10.0.60.1	Super-WS 閘道
SVI VLAN 70	10.0.70.1	Remote-WS VPN 閘道
OOB mgmt	10.0.10.12/24	VLAN 10 管理
OOB mgmt switch	Mgmt	10.0.10.3/24	僅 VLAN 10，完全隔離
NMS / Admin host	eth0	10.0.10.254/24	Jump host、Prometheus、Grafana、Unbound DNS
Mac M5 Pro vMLX 推理叢集（VLAN 30）

三台 Mac M5 Pro 組成 vMLX cluster，以靜態 IP 固定於 VLAN 30。節點間透過 SSH tunnel 傳遞推理請求，僅 Node 0（Aggregator）對 WAN 暴露。

Node 0 — Aggregator + Cloud Agents（10.0.30.11）

Port	協定	服務	WAN 暴露
22	TCP	SSH 管理	否（OOB jump host 限定）
8080	TCP	vMLX HTTP API（主端點）	是 → WAN:443（TLS）
8765	TCP/WS	vMLX Aggregator WebSocket	是 → WAN:8765
8800	TCP	SSH tunnel → Node 1 :8765（RAG）	否（內部）
8801	TCP	SSH tunnel → Node 2 :8765（Reasoning）	否（內部）
9090	TCP	Prometheus metrics	否（NMS pull 限定）
Node 1 — Local RAG（10.0.30.12）

Port	協定	服務	WAN 暴露
22	TCP	SSH 管理	否
8765	TCP/WS	vMLX node API（Qwen3-8B-4bit）	否（經 Node 0 :8800 tunnel）
5432	TCP	PostgreSQL / pgvector 混合 ANN	否（VLAN 30 內部）
9090	TCP	Prometheus metrics	否
Node 2 — Specialist Reasoning（10.0.30.13）

Port	協定	服務	WAN 暴露
22	TCP	SSH 管理	否
8765	TCP/WS	vMLX node API（Qwen3-8B-4bit）	否（經 Node 0 :8801 tunnel）
8080	TCP	Specialist HTTP API（Agent 2 / STEP 5）	否（VLAN 30 內部）
9090	TCP	Prometheus metrics	否
VLAN 30 IP 池

範圍	用途
10.0.30.1	L3 switch SVI — 閘道
10.0.30.11 – 10.0.30.13	Mac M5 Pro Node 0, 1, 2（現有叢集）
10.0.30.14 – 10.0.30.19	保留 — 未來 M5 Pro 擴充節點
10.0.30.20 – 10.0.30.99	保留 — 推理 scale-out 節點池
10.0.30.254	Load-balancer VIP（Keepalived / HAProxy）
WAN Port Forwarding（DNAT 規則）

WAN1 主要 public IP 套用以下規則。IP SLA 追蹤觸發 failover 時，同一規則自動套用於 WAN2（5G）。

WAN 外部埠	協定	DNAT 目標	服務	備註
443	TCP	10.0.30.11:8080	vMLX HTTPS API	需 Auth token；rate-limit 100 req/s
8765	TCP	10.0.30.11:8765	vMLX WebSocket Aggregator	Bearer token；建議白名單 IP
51820	UDP	10.0.70.1:51820	WireGuard VPN（remote-ws）	Pre-shared key per peer
22100	TCP	10.0.10.254:22	NMS jump host SSH	僅白名單管理員 IP
遠端工作站（VLAN 70）接入設計

遠端工作站透過 WireGuard VPN 接入路由器，被分配至 VLAN 70（10.0.70.0/24），在 L3 層面視為本地 VLAN 70 主機，再由 ACL 控制跨 VLAN 存取權限。

參數	值
VPN 端點	<WAN1-public-IP>:51820 UDP / WireGuard
Tunnel 子網路	10.0.70.0/24
客戶端 IP 池	10.0.70.10 – 10.0.70.200
Split tunnel 路由	10.0.0.0/8 走 VPN；其餘 internet 流量保持本地
推送 DNS	10.0.10.254（NMS host 執行 Unbound）
允許存取 VLAN 50	辦公室工作站協作
允許存取 VLAN 20	應用伺服器
封鎖 VLAN 30	Model server（預設拒絕；需逐 host 明確允許）
封鎖 VLAN 10	OOB 管理平面（永遠拒絕）
Failover 行為	WireGuard 自動重連 WAN2（5G）；DDNS 保持 endpoint hostname 穩定
附錄：WireGuard Peer Config 範本

伺服器端（WAN 路由器或 Linux gateway，10.0.70.1）

# /etc/wireguard/wg-remote-ws.conf
[Interface]
Address    = 10.0.70.1/24
ListenPort = 51820
PrivateKey = <SERVER_PRIVATE_KEY>

# 路由：將 10.0.0.0/8 往內部推；PostUp/Down 處理 iptables NAT
PostUp   = iptables -A FORWARD -i wg-remote-ws -j ACCEPT; \
           iptables -A FORWARD -o wg-remote-ws -j ACCEPT; \
           iptables -t nat -A POSTROUTING -s 10.0.70.0/24 -j MASQUERADE
PostDown = iptables -D FORWARD -i wg-remote-ws -j ACCEPT; \
           iptables -D FORWARD -o wg-remote-ws -j ACCEPT; \
           iptables -t nat -D POSTROUTING -s 10.0.70.0/24 -j MASQUERADE

# ── Peer：Remote-WS-01 ──────────────────────────────────
[Peer]
# 遠端工作站 1
PublicKey           = <PEER_01_PUBLIC_KEY>
PresharedKey        = <PEER_01_PRESHARED_KEY>
AllowedIPs          = 10.0.70.10/32
PersistentKeepalive = 25

# ── Peer：Remote-WS-02 ──────────────────────────────────
[Peer]
# 遠端工作站 2
PublicKey           = <PEER_02_PUBLIC_KEY>
PresharedKey        = <PEER_02_PRESHARED_KEY>
AllowedIPs          = 10.0.70.11/32
PersistentKeepalive = 25

# ── Peer：Remote-WS-03（Super-WS 遠端接入）──────────────
[Peer]
PublicKey           = <PEER_03_PUBLIC_KEY>
PresharedKey        = <PEER_03_PRESHARED_KEY>
AllowedIPs          = 10.0.70.12/32
PersistentKeepalive = 25
客戶端（遠端工作站，以 Remote-WS-01 為例）

# /etc/wireguard/wg0.conf  （macOS 或 Linux 客戶端）
[Interface]
Address    = 10.0.70.10/24
PrivateKey = <PEER_01_PRIVATE_KEY>
DNS        = 10.0.10.254          # NMS host Unbound resolver

[Peer]
PublicKey           = <SERVER_PUBLIC_KEY>
PresharedKey        = <PEER_01_PRESHARED_KEY>
Endpoint            = <WAN1-DDNS-HOSTNAME>:51820
# Split tunnel：只有內部 10.0.0.0/8 走 VPN
AllowedIPs          = 10.0.0.0/8
PersistentKeepalive = 25
金鑰產生指令

# 在每台機器上各自產生一對金鑰
wg genkey | tee privatekey | wg pubkey > publickey

# 產生 Pre-shared key（每組 peer 一把）
wg genpsk > presharedkey

# 啟動 / 停止 WireGuard interface
sudo wg-quick up   wg-remote-ws   # 伺服器端
sudo wg-quick down wg-remote-ws

# 查看目前連線狀態
sudo wg show wg-remote-ws
ACL 規則（iptables，於 PostUp 後補充）

# 允許 VLAN 70 → VLAN 50（辦公室工作站）
iptables -I FORWARD -s 10.0.70.0/24 -d 10.0.50.0/23 -j ACCEPT

# 允許 VLAN 70 → VLAN 20（應用伺服器）
iptables -I FORWARD -s 10.0.70.0/24 -d 10.0.20.0/23 -j ACCEPT

# 封鎖 VLAN 70 → VLAN 30（Model server，預設拒絕）
iptables -I FORWARD -s 10.0.70.0/24 -d 10.0.30.0/24 -j DROP

# 封鎖 VLAN 70 → VLAN 10（OOB 管理，永遠拒絕）
iptables -I FORWARD -s 10.0.70.0/24 -d 10.0.10.0/24 -j DROP
注意：若路由器使用 nftables 而非 iptables，規則語法需對應轉換。建議將所有規則寫入 nftables.conf 的 forward chain，並以 iifname / oifname 搭配 ip saddr 做精確比對。
本文為內部網路設計紀錄，拓撲圖以 SVG 格式存放於 /assets/svg/wan-redundancy-topology.svg。