require 'rubygems'
require 'sinatra'
require 'nokogiri'
require 'open-uri'
require 'data_mapper'

DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/app.db")

class FootballPlayer
	include DataMapper::Resource

	property :id, Serial
	property :nfl_team, String
	property :position, String
	property :name, String
	property :url, Text
	property :passingyards, Integer
	property :rushingyards, Integer
	property :receivingyardsrb, Integer
	property :receivingyardswr, Integer
	property :created_at, DateTime
	property :updated_at, DateTime
	def getdata
		espn_url = self.url
		@doc = Nokogiri::HTML(open("#{espn_url}"))

		@doc.css('.mod-content h1').each do |data|
 			self.name = data.content
 		end

		@doc.css('.general-info .first').each do |data|
 			text = data.content.split(" ")
 			self.position = text[1]
 		end

		@doc.css('.general-info .last a').each do |data|
 			self.nfl_team = data.content
 		end

	end
	
	def getpassingyards
		self.getdata

		@doc.css('tr.oddrow:nth-child(2) td:nth-child(4)').each do |data|
 			@passingyards = data.content 
 		end
 		self.save(:passingyards => @passingyards)
 		self.updated_at = Time.now
	end

	def getrushyards
		self.getdata

		@doc.css('tr.oddrow:nth-child(2) td:nth-child(3)').each do |data|
 			@rushingyards = data.content 
 		end
 		self.save(:rushingyards => @rushingyards)
 		self.updated_at = Time.now
	end


	def getreceivingyardsrb
		self.getdata

		@doc.css('tr.oddrow:nth-child(2) td:nth-child(9)').each do |data|
 			@receivingyardsrb = data.content 
 		end
 		self.save(:receivingyardsrb => @receivingyardsrb)
		self.updated_at = Time.now
	end


	def getreceivingyardswr
		self.getdata

		@doc.css('tr.oddrow:nth-child(2) td:nth-child(4)').each do |data|
 			@receivingyardswr = data.content 
 		end
 		self.save(:receivingyardswr => @receivingyardswr)
 		self.updated_at = Time.now
	end	
end

class FootballTeam
	#	@@allplayers = []

	include DataMapper::Resource
	property :id, Serial
	property :name, String
	property :url, Text
	property :players, Text
	property :created_at, DateTime
	property :updated_at, DateTime


		def getplayers
		team_url = self.url
		@doc = Nokogiri::HTML(open("#{team_url}"))
		
		
		@players = []
		
		@doc.css('.mod-content tr td:nth-child(2)').each do |data|
		#puts data
			playerurl = data.css("a")[0]["href"]
			playername = data.content

			
			if playername != "NAME"
				newfootballplayer = FootballPlayer.first(:name => playername)
				newfootballplayer.name = playername
				newfootballplayer.url = playerurl
				newfootballplayer.getdata
				newfootballplayer.created_at = Time.now
				newfootballplayer.updated_at = Time.now
				newfootballplayer.save
				#puts newfootballplayer.name
				#puts newfootballplayer.position
				#puts newfootballplayer.nfl_team
				@players << newfootballplayer
			#	@@allplayers << newfootballplayer
			end
		end
	end

end

class Application

	include DataMapper::Resource
	property :id, Serial
	property :teams, Text
	property :players, Text
	property :created_at, DateTime
	property :updated_at, DateTime



	@@teamlinks =  [ "http://espn.go.com/nfl/team/roster/_/name/det/detroit-lions", "http://espn.go.com/nfl/team/roster/_/name/gb/green-bay-packers", "http://espn.go.com/nfl/team/roster/_/name/min/minnesota-vikings", 
"http://espn.go.com/nfl/team/roster/_/name/bal/baltimore-ravens", "http://espn.go.com/nfl/team/roster/_/name/cin/cincinnati-bengals", 
"http://espn.go.com/nfl/team/roster/_/name/cle/cleveland-browns", "http://espn.go.com/nfl/team/roster/_/name/pit/pittsburgh-steelers",
"http://espn.go.com/nfl/team/roster/_/name/atl/atlanta-falcons", "http://espn.go.com/nfl/team/roster/_/name/car/carolina-panthers", 
"http://espn.go.com/nfl/team/roster/_/name/no/new-orleans-saints", "http://espn.go.com/nfl/team/roster/_/name/tb/tampa-bay-buccaneers", 
"http://espn.go.com/nfl/team/roster/_/name/hou/houston-texans", "http://espn.go.com/nfl/team/roster/_/name/ind/indianapolis-colts", 
"http://espn.go.com/nfl/team/roster/_/name/jac/jacksonville-jaguars", "http://espn.go.com/nfl/team/roster/_/name/ten/tennessee-titans" ]


	def getallteams	
			@teams = Array.new

		@@teamlinks.each do |team_url|

			newfootballteam = FootballTeam.new
			newfootballteam.url = team_url
			teamp1 = team_url.split("name/")[1]
			#min/minnesota-vikings
			teamp2 = teamp1.slice(0..3)
			#min/
			newfootballteam.name = teamp1.gsub(teamp2, "").gsub("-", " ")
			newfootballteam.created_at = Time.now
			newfootballteam.updated_at = Time.now
			newfootballteam.getplayers
			@teams << newfootballteam
			newfootballteam.save

		end		
	end
end

DataMapper.auto_upgrade!

#fantasyfootball = Application.new
#fantasyfootball.teams = @teams
#fantasyfootball.getallteams
#fantasyfootball.created_at = Time.now
#fantasyfootball.updated_at = Time.now
#fantasyfootball.save


get '/' do
	erb :home
end

get '/myteam/:username' do
	'this is where #{params[:username]} team is'
end

get '/scoring' do
	"this is the scoring page"
end

get '/profile' do
	@allapps = Application.all
	@players = FootballPlayer.all
	erb :profile
end
get '/profile/:name' do
	name = params[:name].gsub("-", " ").split(' ').map {|w| w.capitalize }.join(' ')

	@player = FootballPlayer.first(:name => name)

if @player.position == "QB"
	@player.getpassingyards

	puts "he has #{@passingyards}"
else
	puts "he is not a quaterback"
end

if @player.position == "RB"
	@player.getrushyards

	puts "he has #{@rushingyards}"
	@player.getreceivingyardsrb

	puts "he has #{@receivingyardsrb}"
else
	puts "he is not a running back"
end

if @player.position == "WR"
	@player.getreceivingyardswr

	puts "he has #{@receivingyardsrb}"
else
	puts "he is not a wide receiver"
end
@player.save

	erb :playerprofile
end
















