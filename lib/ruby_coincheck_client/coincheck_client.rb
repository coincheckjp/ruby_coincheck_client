require 'net/http'
require 'uri'
require 'openssl'

class CoincheckClient
  BASE_URL = "https://coincheck.jp/"
  def read_balance(key, secret)
    uri = URI.parse BASE_URL + "api/accounts/balance"
    headers = get_signature(uri, key, secret)
    request_for_get(uri, headers)
  end

  def read_accounts(key, secret)
    uri = URI.parse BASE_URL + "api/accounts"
    headers = get_signature(uri, key, secret)
    request_for_get(uri, headers)
  end

  def read_transactions(key, secret)
    uri = URI.parse BASE_URL + "api/exchange/orders/transactions"
    headers = get_signature(uri, key, secret)
    request_for_get(uri, headers)
  end

  def read_orders(key, secret)
    uri = URI.parse BASE_URL + "api/exchange/orders/opens"
    headers = get_signature(uri, key, secret)
    request_for_get(uri, headers)
  end

  private
    def request_for_get(uri, headers)
      https = Net::HTTP.new(uri.host, uri.port)
      https.use_ssl = true
      response = https.start {
        https.get(uri.request_uri, headers)
      }
      puts response.body
    end

    def get_signature(uri, key, secret)
      nonce = Time.now.to_i.to_s
      message = nonce + uri.to_s
      signature = OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new("sha256"), secret, message)
      headers = {
        "ACCESS-KEY" => key,
        "ACCESS-NONCE" => nonce,
        "ACCESS-SIGNATURE" => signature
      }
    end
end
