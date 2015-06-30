class Story < ActiveRecord::Base
  before_save :update_board

  validates :url, presence: true, uniqueness: true
  validates_presence_of :title, :user_id, :board_id

  belongs_to :board, touch: true
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

  private

  def update_board
    self.board.touch
  end
end
