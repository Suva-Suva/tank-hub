# spec/models/article_spec.rb
require 'rails_helper'

RSpec.describe Article, type: :model do
  describe 'associations' do
    it { should belong_to(:game) }
    it { should belong_to(:author).class_name('User').optional }
    it { should have_many(:article_categories).dependent(:destroy) }
    it { should have_many(:categories).through(:article_categories) }
    it { should have_many(:ratings).dependent(:destroy) }
  end

  describe 'validations' do
    it { should validate_presence_of(:title) }
    it { should validate_length_of(:title).is_at_most(255) }
    it { should validate_presence_of(:slug) }

    it 'validates uniqueness of slug scoped to game_id' do
      game = create(:game)
      create(:article, game: game, slug: 'unique-slug')

      duplicate = build(:article, game: game, slug: 'unique-slug')
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:slug]).to include('has already been taken')

      different_game = build(:article, game: create(:game), slug: 'unique-slug')
      expect(different_game).to be_valid
    end

    context 'when status is published' do
      it 'validates presence of body' do
        article = build(:article, :published, body: nil)
        expect(article).not_to be_valid
        expect(article.errors[:body]).to include("can't be blank")
      end

      it 'validates presence of published_at' do
        article = build(:article, :published, published_at: nil)
        expect(article).not_to be_valid
        expect(article.errors[:published_at]).to include("can't be blank")
      end
    end
  end

  describe 'scopes' do
    let(:game) { create(:game) }

    describe '.published' do
      it 'returns only published articles with past published_at' do
        published = create(:article, :published, game: game)
        draft     = create(:article, :draft, game: game)
        future    = create(:article, :published, game: game, published_at: 1.day.from_now)

        expect(Article.published).to include(published)
        expect(Article.published).not_to include(draft, future)
      end
    end
  end

  describe '#generate_slug' do
    it 'parameterizes title when slug is blank' do
      article = build(:article, title: 'T-34-85 Tank Guide', slug: nil)
      article.valid?
      expect(article.slug).to eq('t-34-85-tank-guide')
    end

    it 'does not overwrite existing slug' do
      article = build(:article, title: 'Новый заголовок', slug: 'custom-slug')
      article.valid?
      expect(article.slug).to eq('custom-slug')
    end
  end

  describe '#as_api_json' do
    let(:article) { create(:article, :published) }

    it 'returns expected JSON structure' do
      json = article.as_api_json
      expect(json).to include(
        id: article.id,
        title: article.title,
        slug: article.slug,
        status: article.status,
        game_id: article.game_id
      )
      expect(json[:published_at]).to be_a(String)
    end

    it 'includes author when requested' do
      json = article.as_api_json(include_author: true)
      expect(json[:author]).to be_a(Hash)
      expect(json[:author]).to include(:id, :email, :role)
    end
  end
end