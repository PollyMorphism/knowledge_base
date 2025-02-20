# frozen_string_literal: true

module SomeIntegration
  module Action
    class Sync < Core::Service::Base
      UPDATE_KEYS = [
        :name,
        :breed,
        :color
      ]

      def call(company_uid)
        response = SomeIntegration::Api::Client.cats(company_uid)

        data = []

        response.dig("data")&.each do |cat|
          cat_info = {
            cat_uid: cat["id"]
            name: cat["name"],
            breed: cat["breed"],
            color: cat["color"]
          }

          data << cat_info
        end

        imported_cat_ids = ::Cat.import(
          data,
          on_duplicate_key_update:
            {
              conflict_target: [:cat_uid],
              columns: UPDATE_KEYS
            }
        ).ids

        success(imported_cat_ids)
      rescue SomeIntegration::Api::ServerError
        failure(SomeIntegration::Api::INTERATION_API_UNAVAILABLE_ERROR)
      rescue SomeIntegration::Api::RequestTimoutError
        failure(SomeIntegration::Api::INTEGRATION_API_TIMEOUT_ERROR)
      rescue SomeIntegration::Api::BadRequestError, SomeIntegration::Api::NotFoundError => e
        failure(e.parse_response_body["meta"]["message"])
      end
    end
  end
end
