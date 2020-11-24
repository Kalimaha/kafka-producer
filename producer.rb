# frozen_string_literal: true

require "kafka"
require "faker"
require "tempfile"
require "securerandom"

class Producer
  class << self
    def produce
      topic = "#{ENV.fetch('KAFKA_PREFIX')}au-dev-bigcommerce-products"
      message = order
      pp message

      kafka_client.deliver_message(message.to_json, topic: topic)
    end

    private

    def kafka_client
      @kafka_client ||= Kafka.new(
        seed_brokers: ENV.fetch('KAFKA_BROKERS')&.split(",")&.map { |b| "kafka://#{b}" },
        sasl_scram_username: ENV.fetch('KAFKA_USERNAME'),
        sasl_scram_password: ENV.fetch('KAFKA_PASSWORD'),
        sasl_scram_mechanism: "sha256",
        ssl_ca_certs_from_system: true,
      )
    end

    def order
      line_items = items

      {
        "key": SecureRandom.uuid,
        "value": {
          "status": "in_progress",
          "centsPrice": line_items.map { |li| li[:centsPrice] }.sum,
          "currency": "AUD",
          "lineItems": line_items,
          "createdAt": Time.now.utc,
          "updatedAt": Time.now.utc,
          "customerName": Faker::Name.name,
          "customerAddress": Faker::Address.street_address,
          "customerSuburb": ["Richmond", "South Yarra", "Bundoora"].sample,
          "customerPostcode": %w[3121 3141 3121].sample,
          "customerState": %w[VIC TAS NSW ACT NT WA QLD].sample,
          "customerEmail": Faker::Internet.email,
          "customerPhone": Faker::PhoneNumber.phone_number
        }
      }
    end

    def items
      Array.new(rand(1..5)).map do |_i|
        {
          "itemId": SecureRandom.uuid,
          "name": Faker::Food.dish,
          "quantity": rand(1..3),
          "centsPrice": rand(100..3000),
          "currency": "AUD"
        }
      end
    end
  end
end
