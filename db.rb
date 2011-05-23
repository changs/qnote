require 'rubygems' if RUBY_VERSION < '1.9'
require 'sinatra'
require 'data_mapper'
require 'dm-migrations'
require 'date'
require 'logger'

DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite3://#{Dir.pwd}/development.db")
DataMapper::Property.auto_validation(true)
DataMapper::Property::Boolean.allow_nil(false)
DataMapper::Property::String.length(255)

class User
  include DataMapper::Resource
  storage_names[:default] = 'User'
  property :id, Serial, :field => 'id_u'
  property :name, String
  property :pass, String
end

class Note
  include DataMapper::Resource
  storage_names[:default] = 'Note_db'
  property :id,  Serial, :field => 'id_n'
  property :title, String
  property :date, DateTime, :field => 'data'
  property :type, String
  property :content, Text
  belongs_to :user, :child_key => [ :id_u ]
end

class Tag 
  include DataMapper::Resource
  storage_names[:default] = 'Tag'
  property :id, Serial, :field => 'id_t'
  property :name, String
end

class TagsToNote
  include DataMapper::Resource
  storage_names[:default] = 'TagstoNote'
  property :id_tn, Serial
  belongs_to :note, :child_key => [ :id_n ]
  belongs_to :tag, :child_key => [ :id_t ]
end

class TagsToUser
  include DataMapper::Resource
  storage_names[:default] = 'Tagstouser'
  property :id_tu, Serial
  belongs_to :tag, :child_key => [ :id_t ]
  belongs_to :user, :child_key => [ :id_u ]
end

DataMapper.finalize
DataMapper.auto_migrate!
