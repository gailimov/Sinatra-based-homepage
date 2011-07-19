class Setting
  include DataMapper::Resource

  property :id,                 Serial
  property :url,                String,  :length => 50,  :required => true
  property :title,              String,  :length => 100, :required => true
  property :description,        String,  :length => 255
  property :username,           String,  :length => 50,  :required => true
  property :email,              String,  :length => 50,  :required => true
  property :password,           String,  :length => 32,  :required => true
  property :salt,               String,  :length => 32,  :required => true
  property :comments_moderated, Boolean, :default => 0
end
