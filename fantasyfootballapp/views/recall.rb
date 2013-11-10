require 'rubygems'
require 'sinatra'
require 'datamapper'

DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/recall.db")

class note
	include DataMapper::Resource
	property :id, Serial
	property :content, Text, :required => true
	property :complete, Boolean, :required => true :default => false
	property :created_at, DateTime
	property :updated_at, DateTime
end

DataMapper.finalize.auto_upgrade!

get '/' do 
	@notes = Note.all :order => :id.desc
	@title = 'All Notes'
	erb :home
end

<section id="add">
<form action="/" method="post">
<textarea name="content" placeholder="Your note&hellip;"></textarea>
<input type="submit" value="Take Note!">
</form>
</section>

<% # display notes %>
