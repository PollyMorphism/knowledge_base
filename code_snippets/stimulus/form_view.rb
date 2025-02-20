# typed: true
# frozen_string_literal: true

module Admin
  module Script
    class FormView < Admin::ApplicationView
      include Phlex::Rails::Helpers::FormTag
      include Phlex::Rails::Helpers::Flash
      include FlashHelper

      sig do
        params(
          entity: Entity,
          current_user: AdminUser,
          method: String,
          path: String
        ).void
      end
      def initialize(entity:, current_user:, method:, path:)
        @entity = entity
        @method = method
        @path = path
        @current_user = current_user
      end

      sig { params(block: T.nilable(T.proc.params(x: Phlex::HTML).returns(T.nilable(String)))).void }
      def view_template(&block)
        turbo_frame_tag("script_frame") {
          div(
            id: "entity-script",
            class: %w[card w-100 p-5 bg-white rounded mh-800px overflow-y-scroll],
            data: {controller: "script"}
          ) do
            div(class: "text-blue-700") do
              h3 { "Script" }
              div(class: "mt-3") do
                render_flash(flash)
              end
            end

            form_tag(@path, method: @method, data: {turbo_stream: true}) do
              div(class: "mt-5") do
                span { "Thank you for calling CompanyName, my name is #{@current_user.first_name}. Tell me your name." }

                div(class: "mt-2") do
                  first_name_field
                end

                div(class: "mt-2") do
                  # last_name_field
                end
              end

              div(class: "mt-5") do
                span { "Hello " }
                span(class: "first_name_span", data: {target: "script.firstNameSpans"}) { "<First Name>" }
                span { ", it's a pleasure to meet you. Tell me your phone number" }

                div(class: "mt-2") do
                  # phone_number_field
                end
              end

              div(class: "mt-5") do
                span { "Tell me desired date, " }
                span(class: "first_name_span", data: {target: "script.firstNameSpans"}) { "<First Name>" }

                div(class: "mt-2") do
                  desired_move_in_date_field
                end
              end

              div(class: "mt-5") do
                span { "Based on what you told me " }
                span(class: "first_name_span", data: {target: "script.firstNameSpans"}) { "<First Name>" }
                span { " , you will need..." }

                div(class: "mt-2") do
                  # another field
                end
              end

              div(class: "mt-5") do
                span { "Will that work for you?" }
              end

              div(class: "mt-5") do
                span { "(If YES). Say something..." }
              end

              div(class: "mt-5") do
                span { "(If NO) Confirm... " }
                span(class: "move_in_date_span", data: {target: "script.moveInDateSpan"}) { "<some date>" }
                span { ". And say..." }
              end


              div(class: "mt-5") do
                # save button
              end
            end
          end
        }
      end

      private

      sig { void }
      def first_name_field
        render_phlex(Admin::UI::Input.new(
          id: "first_name_field",
          type: Admin::UI::Input::Type::TEXT,
          name: "entity[first_name]",
          placeholder: "First Name",
          value: @entity.first_name,
          required: true,
          data: {target: "script.firstName", action: "input->script#updateFirstName"}
        ))
      end

      sig { void }
      def desired_move_in_date_field
        render_phlex(Admin::UI::Input.new(
          type: Admin::UI::Input::Type::DATE,
          name: "entity[desired_move_in_date]",
          placeholder: "Desired move in date",
          value: @entity.desired_move_in_date.to_s,
          required: true,
          data: {target: "script.moveInDate", action: "input->script#updateMoveInDate"}
        ))
      end
    end
  end
end
