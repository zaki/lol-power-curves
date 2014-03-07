$(document).ready(function() {
  window.champions = [];

  var baseProperties = [
       "name",
       "attackdamage", "attackdamageperlevel",
       "attackspeed", "attackspeedperlevel",
       "mpperlevel", "mp", "mpregen", "mpregenperlevel",
       "hp", "hpperlevel","hpregen", "hpregenperlevel",
       "armor", "armorperlevel",
       "spellblockperlevel", "spellblock",
       "attackrange",
       "movespeed"];
  var extendedProperties = [
       "q_cd", "w_cd", "e_cd", "r_cd"];
  var allProperties = baseProperties.concat(extendedProperties);

  var charts = ["attackdamage", "hp", "mp", "armor", "hpregen", "mpregen", "attackspeed", "dps"];

  function updateChampion(idx) {
    var i;
    var name = $("#champion"+ idx +" option:selected").val();
    if (typeof(name) === "undefined" || name === "") { return; }

    $.getJSON("/champion", { "name": name }, function(champion, status, jqXHR) {
      window.champions[idx] = champion;
      for (i in allProperties)
      {
        $("#champion" + idx + "_" + allProperties[i]).text(champion[allProperties[i]]);
      }
      if (idx === 2)
      {
        updateClasses();
        updateCharts();
      }
    });
  }

  function updateClasses()
  {
      for (i in baseProperties)
      {
        $("#prop_" + baseProperties[i]).removeClass();

        if (window.champions[1][baseProperties[i]] > window.champions[2][baseProperties[i]])
        {
          $("#prop_" + baseProperties[i]).addClass("champion1");
        }
        else if (window.champions[1][baseProperties[i]] < window.champions[2][baseProperties[i]])
        {
          $("#prop_" + baseProperties[i]).addClass("champion2");
        }
      }
  }

  function onChange()
  {
    var i;
    updateChampion(1);
    updateChampion(2);
  }

  function updateCharts()
  {
    var j;
    for (j in charts)
    {
      chart = charts[j];
      var ctx = document.getElementById(chart).getContext("2d");
      var data1 = [], data2 = [];

      for (i = 0; i < 18; i++)
      {
        if (chart === "attackspeed")
        {
          var as1 = window.champions[1]["attackspeed"] + Math.pow((100 + window.champions[1]["attackspeedperlevel"])/100, i);
          var as2 = window.champions[2]["attackspeed"] + Math.pow((100 + window.champions[2]["attackspeedperlevel"])/100, i);

          data1.push(as1);
          data2.push(as2);
        }
        else if (chart === "dps")
        {
          var ad1 = window.champions[1]["attackdamage"] + i * window.champions[1]["attackdamageperlevel"];
          var ad2 = window.champions[2]["attackdamage"] + i * window.champions[2]["attackdamageperlevel"];

          var as1 = window.champions[1]["attackspeed"] + Math.pow((100 + window.champions[1]["attackspeedperlevel"])/100, i);
          var as2 = window.champions[2]["attackspeed"] + Math.pow((100 + window.champions[2]["attackspeedperlevel"])/100, i);

          data1.push(ad1 * as1);
          data2.push(ad2 * as2);
        }
        else
        {
          data1.push(window.champions[1][chart] + i * window.champions[1][chart+"perlevel"]);
          data2.push(window.champions[2][chart] + i * window.champions[2][chart+"perlevel"]);
        }
      }
      new Chart(ctx).Line(
          {
            labels: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18],
            datasets: [
              { strokeColor: "rgba(255, 0, 0,   0.5)", data: data1 },
              { strokeColor: "rgba(0,   0, 255, 0.5)", data: data2 }
            ],
          }, { animation: false, datasetFill: false, bezierCurve: false });
    }
  }

  $("#champion1").change(onChange);
  $("#champion2").change(onChange);

  onChange();
});
