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
  @limit = 10
  @total = ((Post.count(:kind => 'post') - 1) / @limit) + 1
end

get '/' do
  erb :index
end

get '/blog' do
  @posts = Post.all(:kind => 'post', :order => [ :created_at.desc, :id.desc ], :offset => 0, :limit => @limit)
  @title = 'Blog :: ' + @title
  @description = 'Blog ' + @description
  @next_page = 2
  @prev_page = 0
  erb :'blog/index'
end

# TODO: create helper for pagination
get %r{/blog/page/([\d]+)} do |page|
  page = 1 if page.empty? || page.to_i <= 0
  page = @total if page.to_i > @total
  offset = (page.to_i - 1) * @limit
  @posts = Post.all(:kind => 'post', :order => [ :created_at.desc, :id.desc ], :offset => offset, :limit => @limit)
  @title = 'Blog :: ' + @title
  @description = 'Blog ' + @description
  @next_page = page.to_i + 1
  @prev_page = @next_page - 2
  erb :'blog/index'
end

get '/:slug' do
  @page = Post.first('slug' => params[:slug])
  @title = @page.title + ' :: ' + @title
  @description = @page.description
  erb :page
end

get '/blog/:slug' do
  @post = Post.first('slug' => params[:slug])
  @title = @post.title + ' :: ' + @title
  @description = @post.description
  erb :'blog/post'
end
