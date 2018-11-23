#encoding: utf-8
require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'sqlite3'

def init_db
	@db = SQLite3::Database.new 'leprosorium.db'
	@db.results_as_hash = true
end

before do
	init_db
end

configure do
	init_db
	@db.execute 'CREATE TABLE IF NOT EXISTS Posts (
	    id           INTEGER PRIMARY KEY AUTOINCREMENT,
	    created_date DATE,
	    content      TEXT
	);'
	@db.execute 'CREATE TABLE IF NOT EXISTS Comments (
	    id           INTEGER PRIMARY KEY AUTOINCREMENT,
	    created_date DATE,
	    content      TEXT
	);'

end

get '/' do
	# выбор списк постов из db
	@results = @db.execute 'select * from Posts order by id desc'

	erb :index
end

get '/new' do
	erb :new
end

post '/new' do
	# получаем переменную из post
	content = params[:content]
	if content.length <= 0
		@error = 'Type post text'
		return erb :new
	end

	# запись в db
	@db.execute 'insert into Posts (content, created_date) values (?, datetime())', [content]
	redirect to '/'
end

# вывод инфо о посте
get '/details/:id' do
	post_id = params[:id]

	results = @db.execute 'select * from Posts where id = ?', [post_id]
	@row = results[0]

	erb :details

end

post '/details/:id' do
	post_id = params[:id]
	content = params[:content]

	erb "You typed #{content} for post #{post_id}"
end