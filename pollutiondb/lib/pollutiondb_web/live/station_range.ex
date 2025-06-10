defmodule PollutiondbWeb.StationRangeLive do
  use PollutiondbWeb, :live_view

  alias Pollutiondb.Station

  def mount(_params, _session, socket) do
    socket = assign(socket,
      stations: Station.get_all(),
      lat_min: 0,
      lat_max: 100,
      lon_min: 0,
      lon_max: 100)
    {:ok, socket}
  end

  defp to_int(string_num, default) do
    case Integer.parse(string_num) do
      {num, _} -> num
      :error -> default
    end
  end

  def handle_event("update", %{"lat_min" => lat_min, "lat_max" => lat_max, "lon_min" => lon_min, "lon_max" => lon_max}, socket) do
    stations = Station.find_by_location_range(to_int(lon_min, 0), to_int(lon_max, 100), to_int(lat_min, 0), to_int(lat_max, 100))
    socket = assign(socket, stations: stations, lat_min: lat_min, lat_max: lat_max, lon_min: lon_min, lon_max: lon_max)
    {:noreply, socket}
  end

  def render(assigns) do
    ~H"""
      <form phx-change="update">
      Lat min
      <input type="range" min="0" max="100" name="lat_min" value={@lat_min}/><br/>
      Lat max
      <input type="range" min="0" max="100" name="lat_max" value={@lat_max}/><br/>
      Lon min
      <input type="range" min="0" max="100" name="lon_min" value={@lon_min}/><br/>
      Lon max
      <input type="range" min="0" max="100" name="lon_max" value={@lon_max}/><br/>
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