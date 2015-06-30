class Story < ActiveRecord::Base
  validates :url, presence: true, uniqueness: true
  validates :title, presence: true

  belongs_to :user
  has_many :votes

  scope :sorted_by_votes, -> { order('votes_count DESC') }
  scope :sorted_by_recent, -> { order('created_at DESC') }

  def attributes
    super.merge(score: self.score)
  end

  def score
    total_score = 0
    votes_scores = self.votes.map {|vote| vote.value}
    votes_scores.each { |vote_score| total_score += vote_score }
    total_score
  end
end
