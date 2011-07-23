# coding: utf-8

require 'sinatra'
require 'data_mapper'
require 'digest/md5'
require 'russian'
require 'ipaddr'

configure do
  enable :sessions

  set :views, File.dirname(__FILE__) + '/app/views'

  DataMapper.setup(:default, "sqlite://#{Dir.pwd}/data/blog.db")

  # Load the models
  Dir['app/models/*.rb'].each { |x| load x }

  # Automatically create the tables
  Post.auto_migrate! unless Post.storage_exists?
  Setting.auto_migrate! unless Setting.storage_exists?
  Comment.auto_migrate! unless Comment.storage_exists?
  Tag.auto_migrate! unless Tag.storage_exists?
  Tagging.auto_migrate! unless Tagging.storage_exists?

  # Raise exceptions
  #DataMapper::Model.raise_on_save_failure = true
end

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

  # Cut text
  #
  # Param: (string) text - Text
  # Return: (string) - Cutted text
  def cut(text)
    text.gsub!('<p><!-- pagebreak --></p>', '<!-- pagebreak -->')
    text = text.split('<!-- pagebreak -->')
    return text[0]
  end

  # Remove cut tag
  #
  # Param: (string) text - Text
  # Return: (string) Text without cut tag
  def remove_cut_tag(text)
    if text.include?('<!-- pagebreak -->')
      text.gsub!('<p><!-- pagebreak --></p>', '')
      text.gsub!('<!-- pagebreak -->', '')
    end
  end

  # Show gravatar
  #
  # Param: (string) email - Email
  # Param: (string) default - Default gravatar
  # Param: (int) size - Size
  # Param: (string) rating - Rating
  # Return: string - Gravatar's URI
  def gravatar(email, default = 'identicon', size = 50, rating = 'pg')
    "http://www.gravatar.com/avatar/#{Digest::MD5.hexdigest(email.downcase)}?s=#{size}&amp;d=#{default}&amp;=#{rating}"
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
  @page = Post.first('slug' => params[:slug], 'kind' => 'page')
  @title = @page.title + ' :: ' + @title
  @description = @page.description
  erb :page
end

get '/blog/:slug' do
  @post = Post.first('slug' => params[:slug], 'kind' => 'post')
  @title = @post.title + ' :: ' + @title
  @description = @post.description
  @errors = session[:errors]
  session.clear
  erb :'blog/post'
end

post '/blog/:slug/*' do
  post = Post.first(:slug => params[:slug])

  ip = IPAddr.new(request.ip)
  params['comment']['ip'] = ip
  params['comment']['user_agent'] = request.user_agent
  params['comment']['post_id'] = post.id

  comment = post.comments.new(params['comment'])

  # Validation
  # If validation passed and comment has been saved - redirect back to post page
  if comment.save
    redirect "#{@settings.url}/blog/#{params[:slug]}"
  else
    # ... else save errors into session and redirect to GET route
    errors = ''
    comment.errors.each do |key, value|
      errors << "<li>#{value}</li>\n"
    end
    session[:errors] = errors
    redirect "#{@settings.url}/blog/#{params[:slug]}"
  end
end
