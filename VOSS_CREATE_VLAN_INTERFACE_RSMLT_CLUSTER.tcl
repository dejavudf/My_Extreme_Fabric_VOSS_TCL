
#@MetaDataStart
#@DetailDescriptionStart
#Script para criação de interfaces de VLAN (L3) com redundância RSMLT ativadas nos Spines.
#@DetailDescriptionEnd
#@SectionStart (description = "Atenção: Este script não valida totalmente os dados digitados.")
#@SectionEnd
#@SectionStart (description = "Digite os dados da interfaces de VLANs a serem criadas:")
set ISID_ID_30 11000
set ISID_ID_20 1100
set ISID_ID_10 110
set ISID_ID_00 11
#@VariableFieldLabel (description ="ID da VLAN (local):", scope = global)
set var VLAN_ID ""
#@VariableFieldLabel (description ="i-SID (Global)", scope = global)
set var ISID_ID ""
#@VariableFieldLabel (description ="IP da VLAN do SPINE 01:", scope = global)
set var IP_SPINE01 ""
#@VariableFieldLabel (description ="IP da VLAN do SPINE 02:", scope = global)
set var IP_SPINE02 ""
#@VariableFieldLabel (description ="Máscara de Rede da VLAN:", scope = global,
#   required    = yes,
#   validValues = [128.0.0.0, 192.0.0.0, 224.0.0.0, 240.0.0.0, 248.0.0.0, 252.0.0.0, 254.0.0.0, 255.0.0.0,255.128.0.0, 255.192.0.0, 255.224.0.0, 255.240.0.0, 255.248.0.0, 255.252.0.0, 255.254.0.0, 255.255.0.0,255.255.128.0, 255.255.192.0, 255.255.224.0, 255.255.240.0, 255.255.248.0, 255.255.252.0,  255.255.254.0, 255.255.255.0,255.255.255.128, 255.255.255.192, 255.255.255.224, 255.255.255.240, 255.255.255.248, 255.255.255.252, 255.255.255.254, 255.255.255.255])
set var IP_MASK "255.255.255.0"
#@VariableFieldLabel (description ="Nome da VLAN:", scope = global,
set var VLAN_NAME ""
#@VariableFieldLabel (description ="Ativar DHCP Relay?", scope = global,
#   required    = yes,
#   validValues = [Sim,Nao])
set var DHCP_RELAY Sim
#@SectionEnd
#@SectionStart (description = "Confirme os IPs de gerência dos Spines onde as interfaces de VLAN serão criadas:")
#@VariableFieldLabel (description ="IP de Gerência do Spine 01:", scope = global,
set var IP_MGMT_SPINE01 ""
#@VariableFieldLabel (description ="IP de Gerência do Spine 02:", scope = global,
set var IP_MGMT_SPINE02 ""
#@SectionStart (description = "Dupla de Switches selecionados:")
#@VariableFieldLabel (description ="Selecionados:", scope = local,
set var SELECIONADOS "Sim"
#@MetaDataend
#@SectionEnd

if {$VLAN_ID < 10} {
        set ISID_CHECK $ISID_ID_30$VLAN_ID      
} elseif {$VLAN_ID < 100} {
        set ISID_CHECK $ISID_ID_20$VLAN_ID
} elseif {$VLAN_ID < 1000} {
        set ISID_CHECK $ISID_ID_10$VLAN_ID
} else {
        set ISID_CHECK $ISID_ID_00$VLAN_ID
}  

if {$ISID_ID != $ISID_CHECK} {
        exit
}
if {$VLAN_ID > 4059} {
        exit
}

CLI enable
CLI config t
CLI terminal more disable
CLI vlan create $VLAN_ID type port-mstprstp 0
CLI vlan i-sid $VLAN_ID $ISID_ID
CLI vlan name $VLAN_ID $VLAN_NAME
CLI int vlan $VLAN_ID
if { $deviceIP eq "$IP_MGMT_SPINE01" } {
CLI ip address $IP_SPINE01 $IP_MASK
if { $DHCP_RELAY eq "Sim" } {
CLI ip rsmlt
CLI ip rsmlt holdup-timer 9999
CLI ip dhcp-relay
CLI exit
CLI ip dhcp-relay fwd-path $IP_SPINE01 10.1.1.1
CLI ip dhcp-relay fwd-path $IP_SPINE01 10.1.1.1  enable
CLI ip dhcp-relay fwd-path $IP_SPINE01 10.1.1.1  mode bootp_dhcp
}
} elseif { $deviceIP eq "$IP_MGMT_SPINE02" } {
CLI ip address $IP_SPINE02 $IP_MASK
if { $DHCP_RELAY eq "Sim" } {
CLI ip dhcp-relay
CLI exit
CLI ip dhcp-relay fwd-path $IP_SPINE02 10.1.1.1
CLI ip dhcp-relay fwd-path $IP_SPINE02 10.1.1.1  enable
CLI ip dhcp-relay fwd-path $IP_SPINE02 10.1.1.1 mode bootp_dhcp
}
}

CLI save config
exit
