# db/seeds.rb
Rails.logger.debug "Seeding database..."

# 1. Пользователи
User.find_or_create_by!(email: "admin@gameportal.dev") do |u|
  u.password = "AdminPass123!"
  u.password_confirmation = "AdminPass123!"
  u.role = :admin
end

author = User.find_or_create_by!(email: "author@gameportal.dev") do |u|
  u.password = "AuthorPass123!"
  u.password_confirmation = "AuthorPass123!"
  u.role = :member
end
Rails.logger.debug { "Users: #{User.count}" }

# 2. Игра
wot = Game.find_or_create_by!(slug: "wot") do |g|
  g.title = "World of Tanks"
  g.is_active = true
end
Rails.logger.debug { "Game: #{wot.title}" }

# 3. Категории
categories_data = [
  { name: "Гайды", slug: "guides" },
  { name: "Обзоры", slug: "reviews" },
  { name: "Новости", slug: "news" },
  { name: "Киберспорт", slug: "esports" }
]

categories_data.each do |cat|
  Category.find_or_create_by!(slug: cat[:slug], categorizable: wot) do |c|
    c.name = cat[:name]
  end
end
Rails.logger.debug { "Categories: #{Category.count}" }

# 4. Статьи
5.times do |i|
  Article.find_or_create_by!(slug: "wot-guide-#{i + 1}", game: wot) do |a|
    a.title = "Гайд по танкам ##{i + 1}"
    a.body = "Подробный разбор характеристик, брони, урона и тактики применения. " * (i + 1)
    a.author = author
    a.status = :published
    a.published_at = (i + 1).days.ago
  end
end
Rails.logger.debug { "Articles: #{Article.count}" }

# 5. ТТХ танков
tanks = [
  { name: "Т-34-85", class: :medium, tier: 6, hp: 1200, damage: 220, speed: 55.0, armor: { front: 90, side: 45, rear: 40 } },
  { name: "IS-3", class: :heavy, tier: 8, hp: 1750, damage: 390, speed: 35.0, armor: { front: 110, side: 90, rear: 60 } },
  { name: "SU-100", class: :td, tier: 6, hp: 980, damage: 325, speed: 48.0, armor: { front: 75, side: 50, rear: 30 } }
]

tanks.each do |t|
  TankTechSpec.find_or_create_by!(name: t[:name], game: wot) do |spec|
    spec.tank_class = t[:class]
    spec.tier = t[:tier]
    spec.hp = t[:hp]
    spec.damage = t[:damage]
    spec.speed = t[:speed]
    spec.armor = t[:armor]
  end
end
Rails.logger.debug { "TankTechSpecs: #{TankTechSpec.count}" }

Rails.logger.debug "Seeding complete!"
