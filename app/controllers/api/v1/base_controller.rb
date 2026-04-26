# app/controllers/api/v1/base_controller.rb
module Api
  module V1
    class BaseController < ApplicationController
      include Pagy::Method

      rescue_from ActiveRecord::RecordNotFound, with: :not_found

      private

      def not_found
        render json: { error: "Resource not found" }, status: :not_found
      end

      # Метод для рендера с пагинацией (использует Pagy)
      def render_paginated(collection, blueprint:, view: :default, extra: {})
        pagy, records = pagy(collection, limit: params[:per_page]&.to_i || 20)

        headers.merge!(
          "X-Total-Pages" => pagy.pages.to_s,
          "X-Current-Page" => pagy.page.to_s,
          "X-Per-Page" => pagy.limit.to_s
        )

        data_array = blueprint.render_as_hash(records, view: view, **extra)

        next_page = (pagy.page < pagy.pages) ? pagy.page + 1 : nil
        prev_page = (pagy.page > 1) ? pagy.page - 1 : nil

        render json: {
          data: data_array,
          meta: {
            current_page: pagy.page,
            next_page: next_page,
            prev_page: prev_page,
            total_pages: pagy.pages,
            total_count: pagy.count
          }
        }
      end
    end
  end
end
