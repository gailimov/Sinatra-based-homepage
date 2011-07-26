# coding: utf-8

require 'dm-validations'

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
  property :approved, Integer, :default => 1

  belongs_to :post

  def self.approved
    all(:approved => 1)
  end

  validates_presence_of :author, :message => 'Представьтесь, пожалуйста'
  validates_presence_of :email, :message => 'Введите email, пожалуйста'
  validates_presence_of :content, :message => 'Введите комментарий, пожалуйста'

  before :save do
    [self.author, self.email, self.url, self.content].each do |param|
      param.strip!
    end
  end
end
