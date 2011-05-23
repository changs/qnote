helpers do
  def n_id(name)
    User.first(:name => name).id
  end
  def authorization!
    halt 401 unless session[:loged] == true
  end
  def link_to(url,text=url,opts={})
    attributes = ""
    opts.each { |key,value| attributes << key.to_s << "=\"" << value << "\" "}
    "<a href=\"#{url}\" #{attributes}>#{text}</a>"
  end
  def user_name
    session[:login]
  end
  # change newline to <br>
  def nl2br text
    text.gsub(/\n/, '<br/>')
  end
  def get_tags_by_user
    user_tags  = TagsToUser.all(:fields => [:id_t], :conditions => {:id_u => n_id(session[:login])})
    tags = []
    user_tags.each do |tag| 
      tags.push(Tag.get(tag.id_t))
    end
    tags
  end

  def get_tags_by_note(note_id)
    note_tags  = TagsToNote.all(:fields => [:id_t], :conditions => {:id_n => note_id})
    tags_note = []
    note_tags.each do |tag| 
      tags_note.push(Tag.get(tag.id_t))
    end
    tags_note
  end

  # return array of notes 
  def get_notes_by_tag(tag_name)
    notes = []
    tag = Tag.first(:name => tag_name)
    all_idn = TagsToNote.all(:conditions => {:id_t => tag.id})
    all_idn.each do |idn|
      tmp_note = Note.get(idn.id_n)
      if tmp_note.id_u == n_id(session[:login])
        notes.push(tmp_note)
      end
    end
    notes
  end

  def get_notes_by_tag_id(id)
    notes = []
    all_idn = TagsToNote.all(:conditions => {:id_t => id})
    all_idn.each do |idn|
      tmp_note = Note.get(idn.id_n)
      if tmp_note.id_u == n_id(session[:login])
        notes.push(tmp_note)
      end
    end
    notes
  end
  
  def note_by_id(id)
    Note.get(id)
  end
end
