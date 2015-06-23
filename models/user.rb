class User < ActiveRecord::Base
  has_secure_password

  validates :username, presence: true, uniqueness: true
  validates :password, presence: true, length: { minimum: 6 }

  has_many :votes
  has_many :stories

  def voted_on_story?(story_id)
    self.votes.find_by(story_id: story_id).nil? ? false : true
  end
end
