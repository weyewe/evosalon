class ServiceRole < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :service  
end
