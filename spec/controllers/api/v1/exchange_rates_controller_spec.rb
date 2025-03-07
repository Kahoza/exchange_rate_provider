require 'rails_helper'

RSpec.describe Api::V1::ExchangeRatesController, type: :controller do
  describe 'GET #index' do
    context 'When exchange rates are returned by the bank' do
      before do
        allow(FetchCnbExchangeRates).to receive(:call).and_return([
          { code: 'MXN', rate: 1.137, amount: 1.0 },
          { code: 'EUR', rate: 25.045, amount: 1.0 }
        ])
      end

      it 'returns http success for HTML format' do
        get :index, format: :html
        expect(response).to have_http_status(:success)
        expect(response.content_type).to eq 'text/html; charset=utf-8'
      end

      it 'returns http success for JSON format' do
        get :index, format: :json
        expect(response).to have_http_status(:success)
        expect(response.content_type).to eq 'application/json; charset=utf-8'
        expect(JSON.parse(response.body)).to eq([
          { 'code' => 'MXN', 'rate' => 1.137, 'amount' => 1.0 },
          { 'code' => 'EUR', 'rate' => 25.045, 'amount' => 1.0 }
        ])
      end
    end

    context 'When no exchange rates are returned by the bank' do
      before do
        allow(FetchCnbExchangeRates).to receive(:call).and_return([])
      end

      it 'returns http not found for HTML format' do
        get :index, format: :html
        expect(response).to have_http_status(:not_found)
        expect(response.body).to include('No exchange rates are available')
      end

      it 'returns http not found for JSON format' do
        get :index, format: :json
        expect(response).to have_http_status(:not_found)
        expect(response.content_type).to eq 'application/json; charset=utf-8'
        expect(JSON.parse(response.body)).to eq({ 'error' => 'No exchange rates are available' })
      end
    end

    context 'When there is an error fetching the exchange rates' do
      before do
        allow(FetchCnbExchangeRates).to receive(:call).and_raise(StandardError, 'API error')
      end

      it 'returns internal server error for HTML format' do
        get :index, format: :html
        expect(response).to have_http_status(:internal_server_error)
        expect(response.body).to include('Something went wrong, please try again later.')
      end

      it 'returns internal server error for JSON format' do
        get :index, format: :json
        expect(response).to have_http_status(:internal_server_error)
        expect(response.content_type).to eq 'application/json; charset=utf-8'
        expect(JSON.parse(response.body)).to eq({ 'error' => 'Something went wrong, please try again later.' })
      end
    end
  end

  describe 'GET #show' do
    before do
      allow(FetchCnbExchangeRates).to receive(:call).and_return([
        { code: 'NZD', rate: 13.312, amount: 1.0, country: 'New Zealand', currency: 'dollar' },
        { code: 'PLN', rate: 6.001, amount: 1.0, country: 'Eurozone', currency: 'euro' }
      ])
      @rates = FetchCnbExchangeRates.call
    end

    context 'When a a valid currency code is selected' do
      it 'returns http success and the correct rate for HTML format' do
        get :show, params: { id: 'NZD' }, format: :html
        expect(response).to have_http_status(:success)
        expect(assigns(:rate)).to include(
          code: 'NZD',
          rate: 13.312,
          amount: 1.0,
          country: 'New Zealand',
          currency: 'dollar'
        )
      end

      it 'returns http success and the correct rate for JSON format' do
        get :show, params: { id: 'NZD' }, format: :json
        expect(response).to have_http_status(:success)
        expect(response.content_type).to eq 'application/json; charset=utf-8'
        expect(JSON.parse(response.body)).to include(
          'code' => 'NZD',
          'rate' => 13.312,
          'amount' => 1.0,
          'country' => 'New Zealand',
          'currency' => 'dollar'
        )
      end
    end

    # TODO;
    # Think about this testing case, since the user selects
    # a currency code from the dropdown and list is provided
    # by the bank, can this happen in a cached data?
    context 'When a currency code is not found or invalid on the bank' do
      it 'returns http not found for HTML format' do
        get :show, params: { id: 'DJF' }, format: :html
        expect(response).to have_http_status(:not_found)
        expect(response.body).to include('Currency not found')
      end

      it 'returns http not found for JSON format' do
        get :show, params: { id: 'INVALID' }, format: :json
        expect(response).to have_http_status(:not_found)
        expect(response.content_type).to eq 'application/json; charset=utf-8'
        expect(JSON.parse(response.body)).to include('error' => 'Currency not found')
      end
    end

    context 'When there is an error fetching exchange rates for a specific currency' do
      before do
        allow(FetchCnbExchangeRates).to receive(:call).and_raise(StandardError, 'API error')
      end

      it 'returns internal server error for HTML format' do
        get :show, params: { id: 'NZD' }, format: :html
        expect(response).to have_http_status(:internal_server_error)
        expect(response.body).to include('Something went wrong, please try again later.')
      end

      it 'returns internal server error for JSON format' do
        get :show, params: { id: 'NZD' }, format: :json
        expect(response).to have_http_status(:internal_server_error)
        expect(response.content_type).to eq 'application/json; charset=utf-8'
        expect(JSON.parse(response.body)).to include('error' => 'Something went wrong, please try again later.')
      end
    end
  end

  describe 'POST #convert' do
    let(:rates) do
      [
        { code: 'USD', rate: 1.23, amount: 1.0, country: 'United States', currency: 'dollar' },
        { code: 'HUF', rate: 6.264, amount: 100.0, country: 'Hungary', currency: 'forint' },
        { code: 'PLN', rate: 6.001, amount: 1.0, country: 'Poland', currency: 'zloty' }
      ]
    end

    before do
      allow(FetchCnbExchangeRates).to receive(:call).and_return(rates)
      @rates = FetchCnbExchangeRates.call
    end

    context 'When currency and amount are provided and are valid' do
      it 'converts the amount and returns a response in HTML' do
        post :convert, params: { amount: 200, currency: 'PLN' }, format: :html

        expect(response).to have_http_status(:success)
        expect(assigns(:converted_amount)).to eq(1200.2)
      end

      it 'converts the amount and returns a response in JSON' do
        post :convert, params: { amount: 300, currency: 'HUF' }, format: :json

        expect(response).to have_http_status(:success)
        expect(response.content_type).to eq('application/json; charset=utf-8')
        expect(JSON.parse(response.body)['converted_amount']).to eq(1879.2)
      end
    end

    context 'When the currency is not found' do
      it 'handles currency not found error for HTML format' do
        post :convert, params: { amount: 100, currency: 'INR' }

        expect(response).to have_http_status(:not_found)
        expect(response.body).to include('Currency not found')
      end

      it 'handles currency not found error for JSON format' do
        post :convert, params: { amount: 30, currency: 'DJB' }, format: :json

        expect(response).to have_http_status(:not_found)
        expect(response.content_type).to eq('application/json; charset=utf-8')
        expect(JSON.parse(response.body)['error']).to eq('Currency not found')
      end
    end

    context 'When the amount provided is invalid' do
      it 'handles invalid amount for JSON format' do
        post :convert, params: { amount: 0, currency: 'PLN' }, format: :json

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to eq('application/json; charset=utf-8')
        expect(JSON.parse(response.body)['error']).to eq('Please enter a valid amount.')
      end
    end
  end
end
