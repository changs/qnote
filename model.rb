require 'data_mapper'

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
  property :id, Serial, :field => 'id_tn'
  belongs_to :note, :child_key => [ :id_n ]
  belongs_to :tag, :child_key => [ :id_t ]
end

class TagsToUser
  include DataMapper::Resource
  storage_names[:default] = 'TagstsUser'
  property :id, Serial, :field => 'id_tu'
  belongs_to :user, :child_key => [ :id_u ]
  belongs_to :tag, :child_key => [ :id_t ]
end

DataMapper.finalize
DataMapper.auto_upgrade!
