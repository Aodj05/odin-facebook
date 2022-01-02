class User < ApplicationRecord
  has_many :friend_sent, class_name: 'Friendship', foreign_key: 'sent_by_id', inverse_of: 'sent_by', dependent: :destroy
  has_many :friend_request, class_name: 'Friendship', foreign_key: 'sent_to_id', inverse_of: 'sent_to', dependent: :destroy
  has_many :friends, -> { merge(Friendship.friends) }, through: :friend_sent, source: :sent_to
  has_many :pending_requests, -> { merge(Friendship.not_friends) }, through: :friend_sent, source: :sent_to
  has_many :recieved_requests, -> { merge(Friendship.not_friends) }, through: :friend_request, source: :sent_by
  has_many :notifications, dependent: :destroy
  has_many :posts
  has_many :likes, dependent: :destroy
  has_many :comments, dependent: :destroy
  mount_uploader :image, ImageUploader
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :omniauthable, omniauth_providers: %i[facebook]
  validates :fname, length: { in: 3..15 }, presence: true
  validates :lname, length: { in: 3..15 }, presence: true
  validate :picture_size

  def full_name
    "#{fname} #{lname}"
  end

  def friends_and_own_posts
    myfriends = friends
    our_posts = []
    myfriends.each do |f|
      f.posts.each do |p|
        our_posts << p
      end
    end

    posts.each do |p|
      our_posts << p
    end

    our_posts
  end

  def  self.from_omniauth(auth)
    where(provider: auth.provider,uid: auth.uid).first_or_create do |user|
      user.email = auth.info.email
      user.password = Devise.friendly_token[0, 20]
      user.fname =  auth.info.first_name
      user.lnam = auth.info.last_name
      user.image = auth.info.image
    end
  end

  def self.new_with_session(params, session)
    super.tap do |user|
      if (data = session['devise.facebook_data'] && session['devise.facebook_data']['extra']['raw_info'])
        user.email = data['email'] if user.email.blank?
      end
    end
  end

  private

  def picture_size
    errors.add(:image, 'should be no more than 1MB') if image.size > 1.megabytes
  end
end