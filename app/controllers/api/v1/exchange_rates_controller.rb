module Api
  module V1
    class ExchangeRatesController < ApplicationController
      before_action :fetch_exchange_rates

      def index
        if @rates.nil? || @rates.empty?
          handle_not_found("No exchange rates are available")
        else
          respond_to do |format|
            format.html
            format.json { render json: @rates, status: :ok }
          end
        end
      rescue StandardError => e
        Rails.logger.error("Exchange rates fetch failed: #{e.message}")
        handle_internal_error
      end

      def show
        currency_code = params[:id].upcase
        @rate = @rates.find { |rate| rate[:code] == currency_code }

        if @rate
          respond_to do |format|
            format.html
            format.json { render json: @rate, status: :ok }
          end
        else
          handle_not_found("Currency not found")
        end
      rescue StandardError => e
        Rails.logger.error("Failed to fetch exchange rate for #{currency_code}: #{e.message}")
        handle_internal_error("Something went wrong, please try again later.")
      end

      private

      def handle_not_found(message)
        respond_to do |format|
          format.html { render plain: "#{messasge}", status: :not_found }
          format.json { render json: { error: "#{messasge}" }, status: :not_found }
        end
      end

      def handle_internal_error
        respond_to do |format|
          format.html { render plain: "Something went wrong, please try again later.", status: :internal_server_error }
          format.json { render json: { error: "Something went wrong, please try again later." }, status: :internal_server_error }
        end
      end


      private

      def fetch_exchange_rates
        @rates = Rails.cache.fetch("exchange_rates", expires_in: 24.hours) do
          FetchCnbExchangeRates.call
        end
      end
    end
  end
end
