require 'sinatra'
require 'data_mapper'
require 'erb'

set :views, File.dirname(__FILE__) + '/app/views'

DataMapper.setup(:default, "sqlite://#{Dir.pwd}/data/blog.db")

# Load the models
Dir['app/models/*.rb'].each { |x| load x }

# Automatically create the tables
Post.auto_migrate! unless Post.storage_exists?
Setting.auto_migrate! unless Setting.storage_exists?

before do
  @uri = request.path_info
  @settings = Setting.get(1)
  @title = @settings.title
  @description = @settings.description
  @pages = Post.all(:kind => 'page')
end

get '/' do
  erb :index
end

get '/blog' do
  @posts = Post.all(:kind => 'post', :order => [ :created_at.desc, :id.desc ])
  @title = 'Blog :: ' + @title
  @description = 'Blog ' + @description
  erb :'blog/index'
end
