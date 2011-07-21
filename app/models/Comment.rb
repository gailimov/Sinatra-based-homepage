class Comment
  include DataMapper::Resource

  property :id, Serial
  property :author, String, :length => 50, :required => true
  property :email, String, :length => 50, :required => true
  property :url, String, :length => 50
  property :content, Text, :required => true
  property :created_at, DateTime, :required => true
  property :ip, Integer
  property :user_agent, String, :length => 100
  property :approved, Boolean, :default => 1

  belongs_to :post
end
