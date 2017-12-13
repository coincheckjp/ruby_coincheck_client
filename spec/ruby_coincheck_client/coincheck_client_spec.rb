require 'spec_helper'

describe CoincheckClient do
  describe '#read_trades' do
    let(:cc) { CoincheckClient.new }
    let(:res) { cc.read_trades }
    let(:body) { JSON.parse(res.body) }

    it 'return status code 200' do
      stub_request(
        :get, "https://coincheck.com/api/trades"
      ).to_return(
        body: [
          {
            "id": 82,
            "amount": "0.28391",
            "rate": 35400,
            "order_type": "sell",
            "created_at": "2015-01-10T05:55:38.000Z"
          },
          {
            "id": 81,
            "amount": "0.1",
            "rate": 36120,
            "order_type": "buy",
            "created_at": "2015-01-09T15:25:13.000Z"
          }
        ].to_json,
        status: 200
      )

      expect(res.code).to eq '200'
      expect(body[0]['id']).to eq 82
      expect(body[0]['amount']).to eq "0.28391"
    end
  end

  describe '#order_books' do
    let(:cc) { CoincheckClient.new }
    let(:res) { cc.read_order_books }
    let(:body) { JSON.parse(res.body) }

    it 'return status code 200' do
      stub_request(
        :get, "https://coincheck.com/api/order_books"
      ).to_return(
        body: {
          "asks": [
            [ 27330, "2.25" ],
            [ 27340, "0.45" ]
          ],
          "bids": [
            [ 27240, "1.1543" ],
            [ 26800, "1.2226" ]
          ]
        }.to_json,
        status: 200
      )

      expect(res.code).to eq '200'
      expect(body['asks'][0][0]).to eq 27330
      expect(body['asks'][0][1]).to eq "2.25"
    end
  end

  describe '#read_rate' do
    let(:cc) { CoincheckClient.new }
    let(:res) { cc.read_rate }
    let(:body) { JSON.parse(res.body) }

    it 'return status code 200' do
      stub_request(
        :get, "https://coincheck.com/api/rate/#{CoincheckClient::Pair::BTC_JPY}"
      ).to_return(
        body: {
          "success": true,
          "rate": 60000,
          "price": 70000,
          "amount": 1
        }.to_json,
        status: 200
      )

      expect(res.code).to eq '200'
      expect(body['success']).to eq true
      expect(body['rate']).to eq 60000
      expect(body['price']).to eq 70000
    end
  end

  describe '#read_balance' do
    let(:cc) { CoincheckClient.new('api_key', 'secret_key') }
    let(:res) { cc.read_balance }
    let(:body) { JSON.parse(res.body) }

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

      expect(res.code).to eq '200'
      expect(body['success']).to eq true
      expect(body['btc']).to eq "7.75052654"
    end
  end

  describe '#read_positions' do
    let(:cc) { CoincheckClient.new('api_key', 'secret_key') }
    let(:res) { cc.read_positions(status: 'open') }
    let(:body) { JSON.parse(res.body) }

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

      expect(res.code).to eq '200'
      expect(body['success']).to eq true
      expect(body['data'][0]['id']).to eq 202835
    end
  end

  describe '#get_signature' do
  end
end
