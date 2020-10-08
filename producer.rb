# frozen_string_literal: true

require "kafka"
require "faker"
require "tempfile"
require "securerandom"

class Producer
  class << self
    def produce
      # topic = "#{ENV['KAFKA_PREFIX']}#{ENV['KAFKA_TOPIC']}"
      topic = "#{ENV['CLOUDKARAFKA_PREFIX']}#{ENV['KAFKA_TOPIC']}"
      message = order
      pp message

      kafka_client.deliver_message(message.to_json, topic: topic)
    end

    private

    def kafka_client
      tmp_ca_file = Tempfile.new("ca_certs")
      tmp_ca_file.write(ENV.fetch("KAFKA_TRUSTED_CERT"))
      tmp_ca_file.close

      # Heroku
      # @kafka_client ||= Kafka.new(
      #   seed_brokers: ENV.fetch("KAFKA_URL"),
      #   ssl_ca_cert_file_path: tmp_ca_file.path,
      #   ssl_client_cert: ENV.fetch("KAFKA_CLIENT_CERT"),
      #   ssl_client_cert_key: ENV.fetch("KAFKA_CLIENT_CERT_KEY"),
      #   ssl_verify_hostname: false
      # )

      # Karafka
      @kafka_client ||= Kafka.new(
        # seed_brokers: ENV['CLOUDKARAFKA_BROKERS'],
        # sasl_scram_username: ENV['CLOUDKARAFKA_USERNAME'],
        # sasl_scram_password: ENV['CLOUDKARAFKA_PASSWORD'],
        # sasl_scram_mechanism: 'sha256'

        seed_brokers: ENV['CLOUDKARAFKA_BROKERS']&.split(",")&.map { |b| "kafka://#{b}" },
        sasl_scram_username: ENV['CLOUDKARAFKA_USERNAME'],
        sasl_scram_password: ENV['CLOUDKARAFKA_PASSWORD'],
        sasl_scram_mechanism: "sha256",
        ssl_ca_certs_from_system: true,
      )
    end

    # rubocop:disable Metrics/MethodLength
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
    # rubocop:enable Metrics/MethodLength

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
