$(document).ready(function() {
  window.champions = [];
  var properties = ["hp", "hpp", "hp5", "hp5p", "mp", "mpp", "mp5", "mp5p", "ad", "adp", "as", "asp", "ar", "arp", "mr", "mrp", "ms", "range"];
  var charts = ["ad", "hp", "mp", "ar", "hp5", "mp5"];

  function updateChampion(idx) {
    var i;
    var name = $("#champion"+ idx +" option:selected").val();
    $.getJSON("/champion", { "name": name }, function(champion, status, jqXHR) {
      window.champions[idx] = champion;
      for (i in properties)
      {
        $("#champion" + idx + "_" + properties[i]).text(champion[properties[i]]);
      }
      if (idx === 2)
      {
        updateCharts();
      }
    });
  }

  function onChange()
  {
    var i;
    for (i = 1; i < 3; i++)
    {
      updateChampion(i);
    }
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
        data1.push(parseFloat(window.champions[1][chart]) + i * parseFloat(window.champions[1][chart+"p"]));
        data2.push(parseFloat(window.champions[2][chart]) + i * parseFloat(window.champions[2][chart+"p"]));
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
