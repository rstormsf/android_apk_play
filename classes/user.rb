class User < ActiveRecord::Base
  has_many :reviews
  self.table_name = 'users'
end

class Review < ActiveRecord::Base
  belongs_to :user
  self.table_name = 'reviews'

end