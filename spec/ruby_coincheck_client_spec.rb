require 'spec_helper'
require 'json'
require_relative '../lib/ruby_coincheck_client/coincheck_client.rb'

describe RubyCoincheckClient do

  it 'has a version number' do
    expect(RubyCoincheckClient::VERSION).not_to be nil
  end

  describe "#read_ticker" do
    let(:cc) { CoincheckClient.new("","") }
    let(:res) { cc.read_ticker }
    let(:body) { JSON.parse(res.body) }
    let(:response_keys) { ["last","bid","ask","high","low","volume","timestamp"].sort }

    it 'return status code 200' do
      expect(res.code).to eq("200")
    end

    it 'should matche keys and keys in the official document' do
      keys = body.keys.sort
      keys.zip(response_keys).each do | got_keys, assumed_keys |
        expect(got_keys == assumed_keys).to eq(true)
      end
    end

    example 'The value corresponding to the key is not null' do
      body.each do | key , val |
        expect(val).not_to eq(nil)
      end
    end
  end

  describe '#read_trades' do
    let(:cc) { CoincheckClient.new("","") }
    let(:res) { cc.read_trades }
    let(:body) { JSON.parse(res.body) }
    let(:response_keys) { ["id","amount","rate","order_type","created_at"].sort }

    it 'return status code 200' do
      expect(res.code).to eq("200")
    end

    it 'should matche keys and keys in the official document' do
      keys = body.first.keys.sort
      keys.zip(response_keys).each do | got_keys, assumed_keys |
        expect(got_keys == assumed_keys).to eq(true)
      end
    end

    example 'The value corresponding to the key is not null' do
      body.first.each do | key , val |
        expect(val).not_to eq(nil)
      end
    end
  end

  describe '#order_books' do
    let(:cc) { CoincheckClient.new("","") }
    let(:res) { cc.read_order_books }
    let(:body) { JSON.parse(res.body) }
    let(:response_keys) { ["asks", "bids"].sort }

    it 'return status code 200' do
      expect(res.code).to eq("200")
    end

    it 'should matche keys and keys in the official document' do
      keys = body.keys.sort
      keys.zip(response_keys).each do | got_keys, assumed_keys |
        expect(got_keys == assumed_keys).to eq(true)
      end
    end

    it 'have selling and buying orders price and value' do
      asks = body["asks"]
      asks.each do | ask |
        expect(ask.count == 2).to eq(true)
        ask.each do | order_or_val |
          expect(order_or_val.empty?).to eq(false)
        end
      end

      bids = body["bids"]
      bids.each do | bid |
        expect(bid.count == 2).to eq(true)
        bid.each do | order_or_val |
          expect(order_or_val.empty?).to eq(false)
        end
      end
    end
  end

  describe '#read_rate' do
    let(:cc) { CoincheckClient.new("","") }
    let(:res) { cc.read_rate }
    let(:body) { JSON.parse(res.body) }
    let(:response_keys) { ["rate"].sort }

    it 'return status code 200' do
      expect(res.code).to eq("200")
    end

    it 'should have rate is not empty' do
      expect(body["rate"].empty?).to eq(false)
    end
  end
end
