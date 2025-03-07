require "net/http"
require "nokogiri"
require "open-uri"
require "logger"

class FetchCnbExchangeRates
  CNB_URL = ENV.fetch("CNB_EXCHANGE_RATES_URL", "https://www.cnb.cz/en/financial_markets/foreign_exchange_market/exchange_rate_fixing/daily.txt")
  LOGGER = Logger.new($stdout)

  def self.call
    new.fetch_exchange_rates
  end

  def fetch_exchange_rates
    response = fetch_data
    return [] if response.nil?

    parse_data(response)
  rescue StandardError => e
    LOGGER.error("Failed to fetch exchange rates: #{e.message}")
    []
  end

  private

  def fetch_data
    uri = URI(CNB_URL)
    response = Net::HTTP.get_response(uri)

    if response.is_a?(Net::HTTPSuccess)
      response.body.force_encoding("UTF-8")
    else
      LOGGER.error("Error fetching data from CNB: #{response.code} - #{response.message}")
      nil
    end
  rescue StandardError => e
    LOGGER.error("Network error: #{e.message}")
    nil
  end

  def parse_data(data)
    lines = data.split("\n")
    return [] if lines.size < 3

    headers = lines[1].split("|").map(&:strip)
    exchange_rates = []

    lines[2..].each do |line|
      values = line.split("|").map(&:strip)
      next if values.size < 5 # Ensure the line has all necessary values

      exchange_rates << {
        country: values[0],
        currency: values[1],
        amount: values[2].to_f,
        code: values[3],
        rate: values[4].to_f
      }
    end

    exchange_rates
  rescue StandardError => e
    LOGGER.error("Failed to parse exchange rates: #{e.message}")
    []
  end
end
