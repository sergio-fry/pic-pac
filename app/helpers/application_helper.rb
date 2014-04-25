module ApplicationHelper
  def metric_graph(metric, title=nil)
    if metric.blank? || metric.data_set.blank?
      "Нет данных"
    else
      content_tag :div do
        concat content_tag(:div, nil, :id => "metric_graph_#{metric.id}", :style => "width: 100%", :class => "dygraph_container")

        concat javascript_tag <<-JS
        var container_id = "metric_graph_#{metric.id}";
        g = new Dygraph(

          // containing div
          document.getElementById(container_id),

          // CSV or path to a CSV file.
          "Date,#{title || metric.title}\\n" +

          #{raw metric.data_set.sort_by{ |d| d[:date] }.map{ |d| "\"#{d[:date].strftime("%Y-%m-%d %H:%M")},#{d[:value]}\\n\"" }.join(" + ")}
        );

        $("#" + container_id).data("dygraph", g);
        JS
      end
    end
  end
end
