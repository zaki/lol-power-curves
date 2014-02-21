require 'csv'

class Seed
  def self.load
    seed_root = File.dirname(__FILE__)

    seed_file = File.join(seed_root, "champions.csv")
    champions = CSV.read(seed_file, headers: true)

    champions.each do |champion_data|
      champion = Champion.first_or_create(name: champion_data["name"])

      %w(hp hpp hp5 hp5p mp mpp mp5 mp5p ad adp as asp ar arp mr mrp ms range).each do |property|
        champion.send(:"#{property}=", champion_data[property].to_f)
      end

      champion.save
    end
  end
end

