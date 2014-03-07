require "sinatra"
require "data_mapper"
require 'json'
require './db/seed'

#{{{ - Resources
class Champion
  include DataMapper::Resource

  property :name,  String, key: true

  property :attackdamage         , Float
  property :attackdamageperlevel , Float
  property :attackspeed          , Float
  property :attackspeedperlevel  , Float
  property :mp                   , Float
  property :mpperlevel           , Float
  property :mpregen              , Float
  property :mpregenperlevel      , Float
  property :hp                   , Float
  property :hpperlevel           , Float
  property :hpregen              , Float
  property :hpregenperlevel      , Float
  property :armor                , Float
  property :armorperlevel        , Float
  property :spellblock           , Float
  property :spellblockperlevel   , Float
  property :attackrange          , Float
  property :movespeed            , Float

  property :q_cd                 , String
  property :w_cd                 , String
  property :e_cd                 , String
  property :r_cd                 , String
end
#}}}

configure do
  db = ENV["DATABASE_URL"] || "sqlite3::memory"

  DataMapper.setup(:default, db)
  Champion.auto_migrate!

  set :public_folder, File.join(File.dirname(__FILE__), "public")
  patch = Seed.load

  set :patch, patch
end

#{{{ - Routes
get "/" do
  @champions = Champion.all
  @properties = [
    ["name"                 , "", false],
    ["attackdamage"         , "AD", true],
    ["attackspeed"          , "AS", true],
    ["mp"                   , "MP", true],
    ["mpregen"              , "MP5", true],
    ["hp"                   , "HP", true],
    ["hpregen"              , "HP5", true],
    ["armor"                , "ARM", true],
    ["spellblock"           , "MR", true],
    ["attackrange"          , "Range", false],
    ["movespeed"            , "MS", false],

    ["q_cd"                 , "Q CD", false],
    ["w_cd"                 , "W CD", false],
    ["e_cd"                 , "E CD", false],
    ["r_cd"                 , "R CD", false],
  ]
  @charts = [
    ["attackdamage", "AD"],
    ["attackspeed", "AS"],
    ["dps", "DPS"],
    ["mp", "MP"],
    ["mpregen", "MP5"],
    ["hp", "HP"],
    ["hpregen", "HP5"],
    ["armor", "ARM"],
  ]

  @patch = settings.patch
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
