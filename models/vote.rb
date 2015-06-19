class Vote < ActiveRecord::Base
  attr_accessor :new_value, :current_value

  belongs_to :story
  belongs_to :user

  validate :can_still_vote?

  def can_still_vote?
    if self.current_value == self.new_value
      errors.add(:error, 'You have only one vote (up or down).')
    end
  end
end
