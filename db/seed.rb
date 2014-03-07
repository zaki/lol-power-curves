require 'json'

class Seed
  def self.load
    seed_root = File.dirname(__FILE__)

    seed_file = File.join(seed_root, "champions_full.json")
    champions = JSON.parse(File.read(seed_file))

    champions["data"].keys.each do |name|
      champion = Champion.first_or_create(name: name)
      data     = champions["data"][name]

      ["attackdamage", "attackdamageperlevel",
       "attackspeedperlevel",
       "mpperlevel", "mp", "mpregen", "mpregenperlevel",
       "hp", "hpperlevel","hpregen", "hpregenperlevel",
       "armor", "armorperlevel",
       "spellblockperlevel", "spellblock",
       "attackrange",
       "movespeed",].each do |property|
        champion.send(:"#{property}=", data["stats"][property].to_f)
      end
      champion.attackspeed = (0.625 / (1 + data["stats"]["attackspeedoffset"].to_f)).round(3)

      spells, current = %w(q w e r), 0
      data["spells"].each do |spell|
        champion.send(:"#{spells[current]}_cd=", spell["cooldownBurn"])
        current+=1
      end

      champion.save
    end

    champions["version"]
  end
end

