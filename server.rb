require "sinatra"
require "data_mapper"
require 'json'
require 'coffee-script'
require './db/seed'

#{{{ - Resources
class Champion
  include DataMapper::Resource

  property :name,  String, key: true, length: 128
  property :image, String, length: 255

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

  property :q_img                , String, length: 255
  property :w_img                , String, length: 255
  property :e_img                , String, length: 255
  property :r_img                , String, length: 255

  property :q_cd                 , String, length: 255
  property :w_cd                 , String, length: 255
  property :e_cd                 , String, length: 255
  property :r_cd                 , String, length: 255

  property :q_sc                 , String, length: 255
  property :w_sc                 , String, length: 255
  property :e_sc                 , String, length: 255
  property :r_sc                 , String, length: 255
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

    ["q_sc"                 , "Q Scaling", false],
    ["w_sc"                 , "W Scaling", false],
    ["e_sc"                 , "E Scaling", false],
    ["r_sc"                 , "R Scaling", false],
  ]
  @charts = {
    "AD"  => [ ["attackdamage", "AD"], ["attackspeed", "AS"], ["dps", "DPS"], ],
    "MP"  => [ ["mp", "MP"], ["mpregen", "MP5"], ],
    "HP"  => [ ["hp", "HP"], ["hpregen", "HP5"], ],
    "ARM" => [ ["armor", "ARM"], ]
  }

  @patch = settings.patch
  erb :index
end

get "/list" do
  Champion.all.map {|champion| champion.name}.join(",")
end

get "/main.js" do
  coffee :"main.js"
end

get "/champion", provides: :json do
  name = params[:name]
  champion = Champion.get(name)

  champion.to_json
end
#}}}
