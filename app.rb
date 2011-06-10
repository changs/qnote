require 'rubygems' if RUBY_VERSION < '1.9'
require 'sinatra'
require 'date'
require 'logger'

require './model.rb' # DataMapper model
require './helpers/def.rb' # Helpers

configure do
  enable :sessions
  set :static, true
  set :public, File.dirname(__FILE__) + '/static'
  User.first_or_create(:name => "Bartek", :pass => "test")
  User.first_or_create(:name => "Paulina", :pass => "test")
  #Note.first_or_create(:title => "Test", :date => Time.now, :type => "text", :content => "LALALAL", :id_u => 1)
  #TagsToNote.first_or_create(:id_n => 1, :id_t => 1)
  #TagsToUser.first_or_create(:id_t => 1, :id_u => 1)
  #TagsToNote.first_or_create(:id_n => 1, :id_t => 2)
  #TagsToUser.first_or_create(:id_t => 2, :id_u => 1)
  #Tag.first_or_create(name: 'test')
  #Tag.first_or_create(name: 'drugi')
end

get '/' do
  redirect to('/showall') if session[:loged]
  erb :login, layout: :'default'
end

get '/edit/:id' do
  authorization!
  erb :edit, :locals => { from: 'New', id: params[:id] }
end


get '/login' do
  erb :login, :layout => :'default'
end

get '/showall' do
  authorization!
  @notes = Note.all(:id_u => n_id(session[:login]), :order => [ :date.desc ])
  erb :all, :locals => { :from => 'All' }
end

get '/logout' do
  session[:loged] = false
  redirect to('/')
end

get '/note/:id' do
  authorization!
  @note = Note.get(params[:id])
  halt 404 if @note == nil
  erb :note
end

get '/tag/:tag' do
  authorization!
  tags = get_tags_by_user
  halt 404 if tags == nil
  @notes = get_notes_by_tag(params[:tag])
  erb :all, :locals => { :from =>  params[:tag] } 
end

get '/delete/:id' do
  authorization!
  n = Note.get(params[:id])
  t = TagsToNote.all(:id_n => n.id)
  t.each do |tag|
    notes = get_notes_by_tag_id(tag.id_t)
    if notes.length == 1
      ttu = TagsToUser.first(:conditions => {id_u: n_id(session[:login]), id_t: tag.id_t })
      tg = TagsToUser.all(id_t: tag.id_t)
      if tg.length == 1
        Tag.get(tag.id_t).destroy
      end
      ttu.destroy
    end
  end
  t.destroy
  n.destroy
  msg =  "Note deleted."
  erb :redirect, layout: false, locals: {delay: 3, to: '/', msg: msg, type: 'error'}
end

#### POST HANDLERS

post '/new_note' do
  authorization!
  note = Note.create(:title => params[:title] ,:type => 'text', :content => params[:note],
                  :date => DateTime.now, :id_u => n_id(session[:login]) )
  params[:tags].split.each do |nm|
    tag = Tag.first_or_create(name: nm)
    TagsToUser.first_or_create(id_t: tag.id, id_u: n_id(session[:login]))
    TagsToNote.first_or_create(id_t: tag.id, id_n: note.id)
  end
  if note.save
    status 201
    msg =  "Note has been added."
    erb :redirect, layout: false, locals: {delay: 3, to: '/', msg: msg, type: 'info'}
  else
    status 411
    msg =  "Note add failed."
    erb :redirect, layout: false, locals: {delay: 3, to: '/', msg: msg, type: 'error'}
  end
end

post '/edit' do
  authorization!
  note = note_by_id(params[:id_n])
  halt 401 if note.id_u != n_id(session[:login])
  note.content = params[:note]
  note.title = params[:title]
  note.date = DateTime.now
  if note.save
    status 201
    msg = "Note has been updated."
    erb :redirect, layout: false, locals: {delay: 3, to: '/', msg: msg, type: 'info'}
  else
    status 412
    "Note failed"
  end
end

post '/sign_up' do
  if ( (User.first(:name => params[:login])) != nil )
    session[:loged] = true
    session[:login] = params[:login]
    redirect to('/')
  else
    session[:loged] = false
    "Wrong login or password"
  end
end

post '/new_user' do
  if User.first(name: params[:login]) != nil
    msg = "User exist."
    erb :redirect, layout: false, locals: {delay: 3, to: '/', msg: msg, type: 'error'}
  else
    User.create(name: params[:login], pass: params[:password])
    msg = "User has ben created."
    erb :redirect, layout: false, locals: {delay: 3, to: '/', msg: msg, type: 'info'}
  end
end

post '/search' do
  authorization!
  @notes = Note.all(:conditions => {:id_u => n_id(session[:login]), :title.like => "%#{params[:title]}%"},  :order => [ :date.desc ])
  erb :all, :locals => { :from => params[:title]}
end


#### ERROR PAGE REQUESTS

error 401 do
  link_to '/login', 'You must log in first'
end

error 404 do
  "Requested page does not exist."
end



