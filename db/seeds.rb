# db/seeds.rb
puts "Seeding database..."

# 1. Пользователи
admin = User.find_or_create_by!(email: 'admin@gameportal.dev') do |u|
  u.password = 'AdminPass123!'
  u.password_confirmation = 'AdminPass123!'
  u.role = :admin
end

author = User.find_or_create_by!(email: 'author@gameportal.dev') do |u|
  u.password = 'AuthorPass123!'
  u.password_confirmation = 'AuthorPass123!'
  u.role = :member
end
puts "Users: #{User.count}"

# 2. Игра
wot = Game.find_or_create_by!(slug: 'wot') do |g|
  g.title = 'World of Tanks'
  g.is_active = true
end
puts "Game: #{wot.title}"

# 3. Категории
%w[Гайды Обзоры Новости Киберспорт].each do |name|
  Category.find_or_create_by!(name: name, slug: name.parameterize, categorizable: wot)
end
puts "Categories: #{Category.count}"

# 4. Статьи
5.times do |i|
  Article.find_or_create_by!(slug: "wot-guide-#{i+1}", game: wot) do |a|
    a.title = "Гайд по танкам ##{i+1}"
    a.body = "Подробный разбор характеристик, брони, урона и тактики применения. Контент статьи..."
    a.author = author
    a.status = :published
    a.published_at = (i + 1).days.ago
  end
end
puts "Articles: #{Article.count}"

# 5. ТТХ танков
tanks = [
  { name: 'Т-34-85', class: :medium, tier: 6, hp: 1200, damage: 220, speed: 55.0, armor: { front: 90, side: 45, rear: 40 } },
  { name: 'IS-3', class: :heavy, tier: 8, hp: 1750, damage: 390, speed: 35.0, armor: { front: 110, side: 90, rear: 60 } },
  { name: 'SU-100', class: :td, tier: 6, hp: 980, damage: 325, speed: 48.0, armor: { front: 75, side: 50, rear: 30 } }
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
puts "TankTechSpecs: #{TankTechSpec.count}"
puts "Seeding complete!"