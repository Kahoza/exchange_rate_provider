module Api
  module V1
    class ExchangeRatesController < ApplicationController
      before_action :fetch_exchange_rates

      def index
        if @rates.nil? || @rates.empty?
          respond_to do |format|
            format.html { render plain: "Sorry, no exchange rates are available", status: :not_found }
            format.json { render json: { error: "Sorry, no exchange rates are available" }, status: :not_found }
          end
        else
          respond_to do |format|
            format.html
            format.json { render json: @rates, status: :ok }
          end
        end
      rescue StandardError => e
        Rails.logger.error("Exchange rates fetch failed: #{e.message}")

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
