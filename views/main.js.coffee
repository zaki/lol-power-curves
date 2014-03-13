#{{{ - Champion
class Champion
  properties = [
    "name"
    "attackdamage"
    "attackdamageperlevel"
    "attackspeed"
    "attackspeedperlevel"
    "mpperlevel"
    "mp"
    "mpregen"
    "mpregenperlevel"
    "hp"
    "hpperlevel"
    "hpregen"
    "hpregenperlevel"
    "armor"
    "armorperlevel"
    "spellblock"
    "spellblockperlevel"
    "attackrange"
    "movespeed"

    "q_cd"
    "w_cd"
    "e_cd"
    "r_cd"
  ]

  charts = ["ad", "hp", "mp", "arm", "hp5", "mp5", "as", "dps"]

  initialize: () ->
    @ready = false

  _ad: (level) ->
    @attackdamage + @attackdamageperlevel * level

  _hp: (level) ->
    @hp + @hpperlevel * level

  _hp5: (level) ->
    @hpregen + @hpregenperlevel * level

  _as: (level) ->
    @attackspeed * Math.pow((100 + @attackspeedperlevel) / 100, level)

  _dps: (level) ->
    this._ad(level) * this._as(level)

  _mp: (level) ->
    @mp + @mpperlevel * level

  _mp5: (level) ->
    @mpregen + @mpregenperlevel * level

  _arm: (level) ->
    @armor + @armorperlevel * level

  update: (idx, name) =>
    @name = name
    $.getJSON "/champion", { "name": name }, (champion, status, jqXHR) =>

      for property in properties
        this.updateProperty property, champion, idx

      @ready = true
      this.updateCharts()

  wikiLink: (name) ->
    "
    #{name} wiki 
    <a href='http://leagueoflegends.wikia.com/wiki/#{name}' target='_blank'>EN</a>
    <a href='http://loljp-wiki.tk/wiki/index.php?Champion%2F#{name}' target='_blank'>JA</a>
    "

  updateProperty: (property, data, idx) ->
    @[property] = data[property]
    prop = if property == "name" then this.wikiLink(@[property]) else @[property]
    $("#champion#{idx}_#{property}").html(prop)

  updateCharts: () ->
    for chart in charts
      ctx = document.getElementById(chart+"_chart").getContext("2d")
      data1 = []
      data2 = []

      for i in [1..18]
        data1.push(window.champions[1]["_#{chart}"](i))
        data2.push(window.champions[2]["_#{chart}"](i))

      options =
        labels:
          [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18]
        datasets:
          [
            { strokeColor: "rgba(255, 0, 0,   0.5)", data: data1 },
            { strokeColor: "rgba(0,   0, 255, 0.5)", data: data2 }
          ]

      new Chart(ctx).Line(options, { animation: false, datasetFill: false, bezierCurve: false })
#}}}

$(document).ready ->
  window.champions = [ null, new Champion, new Champion ]

  updateChampion = (idx) ->
    name = $("#champion#{idx} option:selected").val()

    window.champions[idx].update idx, name if name

  $("#champion1").change () ->
    updateChampion(1)
  $("#champion2").change () ->
    updateChampion(2)

  $("#charts a").tab()
  $("#charts a:first").tab("show")

  updateChampion(1)
  updateChampion(2)
