#!/usr/bin/env bash

deploy_challenge() {
  local DOMAIN="${1}" TOKEN_FILENAME="${2}" TOKEN_VALUE="${3}"
  
  # このフックは、検証が必要な各ドメインに対して一度呼び出されます。
  # これには、リストされたすべての代替名も含まれます。
  #
  # パラメーター:
  # - DOMAIN
  #   検証されているドメイン名（CNまたはサブジェクト代替名）です。
  # - TOKEN_FILENAME
  #   HTTP検証用に提供されるトークンが含まれるファイルの名前です。
  #   ウェブサーバーによって /.well-known/acme-challenge/${TOKEN_FILENAME} として提供されるべきです。
  # - TOKEN_VALUE
  #   検証用に提供されるべきトークンの値です。DNS検証の場合、これは
  #   _acme-challenge TXTレコードに置くべき値です。HTTP検証の場合、これは
  #   $TOKEN_FILENAME ファイル内で見つけられると期待される値です。
  
  # シンプルな例: ローカルのnamedを使ってnsupdateを使用
  # printf 'server 127.0.0.1\nupdate add _acme-challenge.%s 300 IN TXT "%s"\nsend\n' "${DOMAIN}" "${TOKEN_VALUE}" | nsupdate -k /var/run/named/session.key
}

clean_challenge() {
  local DOMAIN="${1}" TOKEN_FILENAME="${2}" TOKEN_VALUE="${3}"
  
  # このフックは、各ドメインの検証を試みた後、検証の成否に関わらず呼び出されます。
  # ここで、もはや必要ないファイルやDNSレコードを削除できます。
  #
  # パラメーターはdeploy_challengeと同じです。
  
  # シンプルな例: ローカルのnamedを使ってnsupdateを使用
  # printf 'server 127.0.0.1\nupdate delete _acme-challenge.%s TXT "%s"\nsend\n' "${DOMAIN}" "${TOKEN_VALUE}" | nsupdate -k /var/run/named/session.key
}

sync_cert() {
  local KEYFILE="${1}" CERTFILE="${2}" FULLCHAINFILE="${3}" CHAINFILE="${4}" REQUESTFILE="${5}"
  
  # このフックは、証明書が作成された後、しかしシンボリックリンクが作成される前に呼び出されます。
  # これにより、ファイルをディスクに同期し、予期せぬシステムクラッシュによって空のファイルへのシンボリックリンクが
  # 作成されるのを防ぐことができます。
  #
  # このフックは、証明書ファイルのさらなる処理のためには意図されていません。そのためにはdeploy_certを参照してください。
  #
  # パラメーター:
  # - KEYFILE
  #   私有キーを含むファイルのパスです。
  # - CERTFILE
  #   署名された証明書を含むファイルのパスです。
  # - FULLCHAINFILE
  #   完全な証明書チェーンを含むファイルのパスです。
  # - CHAINFILE
  #   中間証明書を含むファイルのパスです。
  # - REQUESTFILE
  #   証明書署名要求を含むファイルのパスです。
  
  # シンプルな例: ファイルをシンボリックリンクする前に同期
  # sync "${KEYFILE}" "${CERTFILE}" "${FULLCHAINFILE}" "${CHAINFILE}" "${REQUESTFILE}"
}

deploy_cert() {
  local DOMAIN="${1}" KEYFILE="${2}" CERTFILE="${3}" FULLCHAINFILE="${4}" CHAINFILE="${5}" TIMESTAMP="${6}"
  
  # このフックは、生成された各証明書に対して一度呼び出されます。
  # ここでは例えば、新しい証明書をサービス固有の場所にコピーして、サービスをリロードすることができます。
  #
  # パラメーター:
  # - DOMAIN
  #   主要なドメイン名、つまり証明書のコモンネーム (CN) です。
  # - KEYFILE
  #   私有キーを含むファイルのパスです。
  # - CERTFILE
  #   署名された証明書を含むファイルのパスです。
  # - FULLCHAINFILE
  #   完全な証明書チェーンを含むファイルのパスです。
  # - CHAINFILE
  #   中間証明書を含むファイルのパスです。
  # - TIMESTAMP
  #   指定された証明書が作成されたタイムスタンプです。
  
  # シンプルな例: ファイルをnginx設定にコピー
  # cp "${KEYFILE}" "${FULLCHAINFILE}" /etc/nginx/ssl/; chown -R nginx: /etc/nginx/ssl
  # systemctl reload nginx
}

deploy_ocsp() {
  local DOMAIN="${1}" OCSPFILE="${2}" TIMESTAMP="${3}"
  
  # このフックは、更新された各OCSPステープリングファイルが生成された後に一度呼び出されます。
  # ここでは例えば、新しいOCSPステープリングファイルをサービス固有の場所にコピーして、サービスをリロードすることができます。
  #
  # パラメーター:
  # - DOMAIN
  #   主要なドメイン名、つまり証明書のコモンネーム (CN) です。
  # - OCSPFILE
  #   OCSPステープリングファイルのパスです。
  # - TIMESTAMP
  #   指定されたOCSPステープリングファイルが作成されたタイムスタンプです。
  
  # シンプルな例: ファイルをnginx設定にコピー
  # cp "${OCSPFILE}" /etc/nginx/ssl/; chown -R nginx: /etc/nginx/ssl
  # systemctl reload nginx
}

# 以下のフックについても同様に、それぞれの目的とパラメータについて翻訳を行います。
# - unchanged_cert
# - invalid_challenge
# - request_failure
# - generate_csr
# - startup_hook
# - exit_hook

HANDLER="$1"; shift
if [[ "${HANDLER}" =~ ^(deploy_challenge|clean_challenge|sync_cert|deploy_cert|deploy_ocsp|unchanged_cert|invalid_challenge|request_failure|generate_csr|startup_hook|exit_hook)$ ]]; then
  "$HANDLER" "$@"
fi
