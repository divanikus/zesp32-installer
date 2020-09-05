# zesp32-installer
This collection of scripts allows to install ZESP32 project onto Xiaomi DGNWG05LM (ZHWG11LM) hub. 

## Steps to install
1. Gain root. Usually requires soldering.
2. Start dropbear (`/etc/init.d/dropbear start`)
3. Log into box using ssh (using password you've set while rooting)
4. Issue the following command in the command line.

```
echo -e "GET /divanikus/zesp32-installer/master/install.sh HTTP/1.0\nHost: raw.githubusercontent.com\n" | openssl s_client -quiet -connect raw.githubusercontent.com:443 2>/dev/null | sed '1,/^\r$/d' | bash
```

## Fallback AP
If hub is blinking yellow after sometime, it means that it cannot connect to your WiFi router. Then you need to connect to hub's access point (`lumi-gateway-aqcn01_miapXXX`) and manually edit `/lumi/conf/wifi.conf`.
