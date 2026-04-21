# app/controllers/api/v1/tank_tech_specs_controller.rb
module Api
  module V1
    class TankTechSpecsController < BaseController
      def index
        scope = TankTechSpec.includes(:game)

        # Поддержка вложенных маршрутов: /games/:slug/tank_tech_specs
        if params[:game_slug].present?
          scope = scope.joins(:game).where(games: {slug: params[:game_slug]})
        end

        # Фильтры из query-параметров
        scope = scope.where(tank_class: params[:class]) if params[:class].present?
        scope = scope.where(tier: params[:tier]) if params[:tier].present?
        scope = scope.where("name ILIKE ?", "%#{params[:name]}%") if params[:name].present?

        scope = scope.order(tier: :asc, name: :asc)

        render_paginated(scope, blueprint: TankTechSpecBlueprint)
      end

      def show
        spec = TankTechSpec.includes(:game).find(params[:id])
        render json: TankTechSpecBlueprint.render(spec, view: :detailed)
      end

      def compare
        # Ожидаем параметры типа ?ids=1,3
        ids = params[:ids].to_s.split(',')
        specs = TankTechSpec.where(id: ids)

        render json: TankTechSpecBlueprint.render(specs)
      end
    end
  end
end
