# app/blueprints/tank_tech_spec_blueprint.rb
class TankTechSpecBlueprint < BaseBlueprint
  identifier :id
  fields :name, :tier

  field :class do |spec, _options|
    spec.tank_class || TankTechSpec.tank_classes.key(spec.read_attribute(:tank_class))
  end

  field :specs do |spec, _options|
    {
      hp: spec.hp,
      damage: spec.damage,
      speed: spec.speed.to_f,
      armor: spec.armor
    }
  end

  view :detailed do
    field :additional_specs
    association :game, blueprint: GameBlueprint
  end
end
