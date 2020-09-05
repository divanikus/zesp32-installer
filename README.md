# zesp32-installer
Zesp32 installer

```
echo -e "GET /divanikus/zesp32-installer/master/install.sh HTTP/1.0\nHost: raw.githubusercontent.com\n" | openssl s_client -quiet -connect raw.githubusercontent.com:443 2>/dev/null | sed '1,/^\r$/d' | bash
```