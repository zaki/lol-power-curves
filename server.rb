require "sinatra"
require "data_mapper"
require 'json'
require './db/seed'

#{{{ - Resources
class Champion
  include DataMapper::Resource

  property :name,  String, key: true

  property :hp,    Float
  property :hpp,   Float
  property :hp5,   Float
  property :hp5p,  Float
  property :mp,    Float
  property :mpp,   Float
  property :mp5,   Float
  property :mp5p,  Float
  property :ad,    Float
  property :adp,   Float
  property :as,    Float
  property :asp,   Float
  property :ar,    Float
  property :arp,   Float
  property :mr,    Float
  property :mrp,   Float
  property :ms,    Float
  property :range, Float
end
#}}}

configure do
  db = ENV["DATABASE_URL"] || "sqlite3::memory"

  DataMapper.setup(:default, db)
  Champion.auto_migrate!

  set :public_folder, File.join(File.dirname(__FILE__), "public")
  Seed.load
end

#{{{ - Routes
get "/" do
  @champions = Champion.all
  erb :index
end

get "/list" do
  Champion.all.map {|champion| champion.name}.join(",")
end

get "/champion", provides: :json do
  name = params[:name]
  champion = Champion.get(name)

  champion.to_json
end
#}}}
