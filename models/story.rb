class Story < ActiveRecord::Base
  validates :url, presence: true, uniqueness: true
  validates :title, presence: true

  has_many :votes
end
