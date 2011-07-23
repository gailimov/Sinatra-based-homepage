class Tagging
  include DataMapper::Resource

  belongs_to :tag, :key => true
  belongs_to :post, :key => true
end
