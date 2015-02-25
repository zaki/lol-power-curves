require 'json'

class Seed
  def self.get_image(category, filename)
    unless File.exist?("public/img/#{category}/#{filename}")
      %x(wget --quiet -O public/img/#{category}/#{filename} http://ddragon.leagueoflegends.com/cdn/#{@version}/img/#{category}/#{filename})
    end
  end

  def self.parse_vars(vars)
    mappings = {
      "spelldamage"       => "AP",
      "attackdamage"      => "AD",
      "bonusattackdamage" => "+AD",
      "mana"              => "MP",
      "@stacks"           => "Stacks",
      "@cooldownchampion" => "CDR",
      "health"            => "HP",
      "bonushealth"       => "+HP",
      "armor"             => "ARM",
      "bonusarmor"        => "+ARM",
      "bonusspellblock"   => "+MR",
    }

    return "" unless vars
    vars.map do |var|
      if (mapping = mappings[var["link"]])
        var["coeff"].join(",") + " " + mapping
      else
        ""
      end
    end.join(" / ")
  end

  def self.load
    seed_root = File.dirname(__FILE__)

    seed_file = File.join(seed_root, "champions.json")
    champions = JSON.parse(File.read(seed_file))

    @version = champions["version"]

    champions["data"].keys.each do |name|
      champion = Champion.first_or_create(name: champions["data"][name]["name"])
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
      champion.image = data["image"]["full"]

      get_image("champion", data["image"]["full"])

      spells, current = %w(q w e r), 0
      data["spells"].each do |spell|
        next if current > 3
        champion.send(:"#{spells[current]}_img=", spell["image"]["full"])
        champion.send(:"#{spells[current]}_cd=",  spell["cooldownBurn"])
        champion.send(:"#{spells[current]}_sc=",  parse_vars(spell["vars"]))

        get_image("spell", spell["image"]["full"])

        current+=1
      end

      champion.save
    end

    @version
  end
end

