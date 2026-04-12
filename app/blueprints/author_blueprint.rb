# app/blueprints/author_blueprint.rb
class AuthorBlueprint < BaseBlueprint
  identifier :id
  fields :email, :role
end