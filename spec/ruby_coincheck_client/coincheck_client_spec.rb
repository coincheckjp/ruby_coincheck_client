require 'spec_helper'

describe CoincheckClient do
  describe '#read_balance' do
    it 'return status code 200' do
      stub_request(
        :get, "https://coincheck.com/api/accounts/balance"
      ).to_return(
        body: {
          "success": true,
          "jpy": "0.8401",
          "btc": "7.75052654",
          "jpy_reserved": "3000.0",
          "btc_reserved": "3.5002",
          "jpy_lend_in_use": "0",
          "btc_lend_in_use": "0.3",
          "jpy_lent": "0",
          "btc_lent": "1.2",
          "jpy_debt": "0",
          "btc_debt": "0"
        }.to_json,
        status: 200
      )

      cc = CoincheckClient.new('api_key', 'secret_key')
      res = cc.read_balance
      expect(res.code).to eq '200'
      expect(JSON.parse(res.body)['success']).to eq true
      expect(JSON.parse(res.body)['btc']).to eq "7.75052654"
    end
  end

  describe '#read_positions' do
    it 'return status code 200' do
      stub_request(
        :get, "https://coincheck.com/api/exchange/leverage/positions?status=open"
      ).to_return(
        body: {
          "success": true,
          "pagination":{
            "limit": 10,
            "order": "desc",
            "starting_after": nil,
            "ending_before": nil
          },
          "data":[
            {
              "id": 202835,
              "order_type": "buy",
              "rate": 26890,
              "pair": "btc_jpy",
              "pending_amount": "0.5527",
              "pending_market_buy_amount": nil,
              "stop_loss_rate": nil,
              "created_at": "2015-01-10T05:55:38.000Z"
            }
          ]
        }.to_json,
        status: 200
      )

      cc = CoincheckClient.new('api_key', 'secret_key')
      res = cc.read_positions(status: 'open')
      expect(res.code).to eq '200'
      expect(JSON.parse(res.body)['success']).to eq true
      expect(JSON.parse(res.body)['data'][0]['id']).to eq 202835
    end
  end

  describe '#get_signature' do
  end
end
