class Story < ActiveRecord::Base
  validates :url, presence: true, uniqueness: true
  validates :title, presence: true

  belongs_to :user
  has_many :votes

  def self.sorted_by_votes
    order('votes_count DESC')
  end

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
