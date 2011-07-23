class Tag
  include DataMapper::Resource

  property :id, Serial
  property :slug, String, :length => 40, :required => true, :unique => true
  property :tag, String, :length => 40, :required => true

  has n, :taggings
  has n, :posts, :through => :taggings
end
