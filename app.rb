require 'sinatra'
require 'data_mapper'

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
  @limit = 2
end

helpers do
  # Prepare pagination
  #
  # Param: (int) page - Page
  # Return: (hash) pager - Hash of pagination data
  def paginate(page = 1)
    pager = {}
    pager['total'] = ((Post.count(:kind => 'post') - 1) / @limit) + 1

    if page.to_i <= 0
      pager['page'] = 1
    elsif page.to_i > pager['total']
      pager['page'] = pager['total']
    else
      pager['page'] = page.to_i
    end

    pager['offset'] = (pager['page'] - 1) * @limit
    pager['next_page'] = pager['page'] + 1
    pager['prev_page'] = pager['next_page'] - 2

    return pager
  end
end

get '/' do
  erb :index
end

get '/blog' do
  @posts = Post.all(:kind => 'post', :order => [ :created_at.desc, :id.desc ], :offset => 0, :limit => @limit)
  @title = 'Blog :: ' + @title
  @description = 'Blog ' + @description
  @pager = paginate
  erb :'blog/index'
end

get %r{/blog/page/([\d]+)} do |page|
  @pager = paginate(page)
  @posts = Post.all(:kind => 'post', :order => [ :created_at.desc, :id.desc ], :offset => @pager['offset'], :limit => @limit)
  @title = 'Blog :: ' + @title
  @description = 'Blog ' + @description
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
