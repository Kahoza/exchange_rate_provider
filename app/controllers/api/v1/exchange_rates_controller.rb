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

      def convert
        @selected_currency = nil
        @input_amount = nil
        @converted_amount = nil

        if request.post?
          @input_amount = params[:amount].to_f || "EUR"
          @selected_currency = params[:currency].to_s.upcase || "EUR"
          @rate = @rates.find { |r| r[:code] == @selected_currency }
          if @rate.nil?
            return handle_not_found("Currency not found")
          elsif @input_amount <= 0
            return handle_invalid_amount
          end

          @converted_amount = (@input_amount * @rate[:rate]).round(2)
          respond_to do |format|
            format.html { render :convert }
            format.json { render json: { converted_amount: @converted_amount }, status: :ok }
          end
        end
      rescue StandardError => e
        Rails.logger.error("Currency conversion failed: #{e.message}")
        handle_internal_error
      end

      private

      def handle_not_found(message)
        respond_to do |format|
          format.html { render plain: "#{message}", status: :not_found }
          format.json { render json: { error: "#{message}" }, status: :not_found }
        end
      end

      def handle_internal_error
        respond_to do |format|
          format.html { render plain: "Something went wrong, please try again later.", status: :internal_server_error }
          format.json { render json: { error: "Something went wrong, please try again later." }, status: :internal_server_error }
        end
      end

      def handle_invalid_amount
        flash.now[:alert] = "Please enter a valid amount."
        respond_to do |format|
          format.html { render :convert, status: :unprocessable_entity }
          format.json { render json: { error: "Please enter a valid amount." }, status: :unprocessable_entity }
        end
      end

      def fetch_exchange_rates
        begin
          @rates = Rails.cache.fetch("exchange_rates", expires_in: 24.hours) do
            FetchCnbExchangeRates.call
          end
        rescue StandardError => e
          Rails.logger.error("Error fetching exchange rates: #{e.message}")
          handle_internal_error
        end
      end

      # def fetch_exchange_rates
      #   @rates = Rails.cache.fetch("exchange_rates", expires_in: 24.hours) do
      #     FetchCnbExchangeRates.call
      #   end
      # end
    end
  end
end
