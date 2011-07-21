class Post
  include DataMapper::Resource

  property :id, Serial
  property :slug, String, :length => 50, :required => true, :unique => true
  property :title, String, :length => 100, :required => true
  property :description, String, :length => 255
  property :content, Text, :required => true
  property :created_at, DateTime, :required => true
  property :kind, String, :length => 5, :required => true

  has n, :comments
end
