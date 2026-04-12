# app/blueprints/game_blueprint.rb
class GameBlueprint < BaseBlueprint
  identifier :id
  fields :title, :slug, :is_active
end
