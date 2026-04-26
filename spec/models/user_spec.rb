require "rails_helper"

RSpec.describe User, type: :model do
  describe "associations" do
    it { should have_many(:articles).with_foreign_key(:author_id) }
    it { should have_many(:ratings).dependent(:destroy) }
  end

  describe "validations" do
    subject { build(:user) }

    it { should validate_presence_of(:email) }
    it { should validate_uniqueness_of(:email) }

    it "accepts a valid email" do
      expect(build(:user, email: "valid@example.com")).to be_valid
    end

    it "rejects an invalid email format" do
      user = build(:user, email: "not-an-email")
      expect(user).not_to be_valid
      expect(user.errors[:email]).to be_present
    end

    it "requires a password on create" do
      user = build(:user, password: nil, password_confirmation: nil)
      expect(user).not_to be_valid
    end
  end

  describe "role enum" do
    it "defaults to member" do
      user = create(:user)
      expect(user.role).to eq("member")
      expect(user.role_member?).to be true
    end

    it "supports moderator role" do
      user = create(:user, :moderator)
      expect(user.role_moderator?).to be true
      expect(user.role_admin?).to be false
    end

    it "supports admin role" do
      user = create(:user, :admin)
      expect(user.role_admin?).to be true
      expect(user.role_member?).to be false
    end
  end

  describe "scopes" do
    describe ".active" do
      it "includes active users and excludes inactive" do
        active = create(:user)
        inactive = create(:user, :inactive)
        expect(User.active).to include(active)
        expect(User.active).not_to include(inactive)
      end
    end

    describe ".with_role" do
      it "filters by role" do
        admin = create(:user, :admin)
        member = create(:user)
        expect(User.with_role(:admin)).to include(admin)
        expect(User.with_role(:admin)).not_to include(member)
      end
    end
  end

  describe "email normalization" do
    it "downcases email before save" do
      user = create(:user, email: "User@Example.COM")
      expect(user.email).to eq("user@example.com")
    end
  end

  describe "#as_api_json" do
    it "returns id, email, role, created_at" do
      user = create(:user)
      json = user.as_api_json
      expect(json).to include(:id, :email, :role, :created_at)
      expect(json[:email]).to eq(user.email)
      expect(json[:role]).to eq("member")
    end
  end
end
