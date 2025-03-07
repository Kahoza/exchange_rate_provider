require 'rails_helper'

RSpec.describe FetchCnbExchangeRates, type: :service do
  describe '.call' do
    let(:sample_data) do
      <<~DATA
        Date|Country|Currency|Amount|Code|Rate
        07 Mar 2025
        Australia|dollar|1|AUD|16.123
        Brazil|real|1|BRL|4.567
      DATA
    end

    before do
      allow(Net::HTTP).to receive(:get).and_return(sample_data)
    end

    it 'fetches and parses exchange rates correctly' do
      rates = FetchCnbExchangeRates.call

      expect(rates).to be_an(Array)
      expect(rates.size).to eq(31)

      expect(rates[0]).to include(
        country: 'Australia',
        currency: 'dollar',
        amount: 1.0,
        code: 'AUD',
      )

      expect(rates[1]).to include(
        country: 'Brazil',
        currency: 'real',
        amount: 1.0,
        code: 'BRL',
      )

      expect(rates[4]).to include(
        country: 'China',
        currency: 'renminbi',
        amount: 1.0,
        code: 'CNY',
      )
    end
  end
end
