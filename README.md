# Opemdkim
Dockerized opendkim image with custom keys setup

### Keys
First of all, generate keys with command:
```
opendkim-genkey -D /etc/dkim/example.ru/ -d example.ru -s mail
```

### ENV
- `OPENDKIM_SIGNINGTABLE` - path to signing table file. 
  If set, it will template throug `gomplate` and write result to
  `/etc/dkim/signingtable` with owner `opendkim:opendkim` and `600` chmod.
  
  Example signing table file
  ```
  example.ru mail._domainkey.example.ru
  ```
- `OPENDKIM_KEYTABLE` - path to keytable file.
  If set, it will template throug `gomplate` and write result to
  `/etc/dkim/keytable` with owner `opendkim:opendkim` and `600` chmod.
  Example keytable file
  ```
  mail._domainkey.example.ru example.ru:mail:/etc/postfix/dkim/example.ru/mail.private
  ```
- `OPENDKIM_KEYS` - folder with keys for encryption dkim. Example structure
  ```
  example.ru/mail.private
  example.ru/mail.txt
  ```
  For example, if `OPENDKIM_KEYS=/tmp/postfix/dkim`, container will copy
  ```
  /tmp/postfix/dkim/example.ru/mail.private -> /etc/postfix/dkim/example.ru/mail.private
  /tmp/postfix/dkim/example.ru/mail.txt -> /etc/postfix/dkim/example.ru/mail.txt
  ```
  and set owner `opendkim:opendkim` with chmode `750`
  
