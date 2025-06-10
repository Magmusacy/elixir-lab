defmodule PollutiondbWeb.StationLive do
  use PollutiondbWeb, :live_view

  alias Pollutiondb.Station

  def mount(_params, _session, socket) do
    socket = assign(socket, stations: Station.get_all(), name: "", lat: "", lon: "", query: "")
    {:ok, socket}
  end

  defp to_float(string_num, default) do
    case Float.parse(string_num) do
      :error -> default
      {float, _} -> float
    end
  end

  def handle_event("insert", %{"name" => name, "lat" => lat, "lon" => lon}, socket) do
    Station.add(%Station{name: name, lat: to_float(lat, 0.0), lon: to_float(lon, 0.0)})
    socket = assign(socket, stations: Station.get_all(), name: name, lat: lat, lon: lon)
    {:noreply, socket}
  end

  def handle_event("query", %{"query" => query}, socket) do
    stations = case String.trim(query) do
      "" -> Station.get_all()
      search_term ->
        case Station.find_by_name(query) do
          [] -> []
          station -> station
        end
    end
    socket = assign(socket, stations: stations, query: query)
    {:noreply, socket}
  end

  def render(assigns) do
    ~H"""
    Create new station
      <form phx-submit="insert">
        Name: <input type="text" name="name" value={@name} /><br/>
        Lat: <input type="number" name="lat" step="0.1" value={@lat} /><br/>
        Lon: <input type="number" name="lon" step="0.1" value={@lon} /><br/>
        <input type="submit" />
     </form>

      <form phx-change="query">
        Name: <input type="text" name="query" value={@query} />
      </form>

      <table>
      <tr>
        <th>Name</th><th>Longitude</th><th>Latitude</th>
              </tr>
              <%= for station <- @stations do %>
                <tr>
          <td><%= station.name %></td>
          <td><%= station.lon %></td>
          <td><%= station.lat %></td>
        </tr>
      <% end %>
    </table>
    """
end
end
