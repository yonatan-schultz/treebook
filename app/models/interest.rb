class Interest < ActiveRecord::Base
  belongs_to :user
  attr_accessible :interest_name
end
