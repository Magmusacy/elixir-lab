defmodule PollutiondbWeb.ReadingLive do
  use PollutiondbWeb, :live_view
  import Ecto.Query

  alias Pollutiondb.Reading

  def mount(_params, _session, socket) do
    date = parse_date("2024-2-14")
    socket = assign(socket, readings: ten_latest(), type: "", value: "", date: "", station_id: "", stations: Pollutiondb.Station.get_all())
    {:ok, socket}
  end

  defp ten_latest() do
    Ecto.Query.from(r in Reading,
      limit: 10, order_by: [desc: r.date, desc: r.time])
    |> Pollutiondb.Repo.all()
    |> Pollutiondb.Repo.preload(:station)
#    |> tap(&IO.inspect(&1, label: "Readings"))
  end

  defp ten_latest_by_date(date) do
    Ecto.Query.from(r in Reading,
      where: r.date == ^date, limit: 10, order_by: [desc: r.date, desc: r.time])
    |> Pollutiondb.Repo.all()
    |> Pollutiondb.Repo.preload(:station)
  end

  defp to_int(string_num, default) do
    case Integer.parse(string_num) do
      {num, _} -> num
      :error -> default
    end
  end

  defp to_float(string_num, default) do
    case Float.parse(string_num) do
      :error -> default
      {float, _} -> float
    end
  end

  defp parse_date(date_string) do
    date_string
    |> String.split("-")
    |> Enum.map(& to_int(&1, 0))
    |> List.to_tuple()
    |> Date.from_erl()
    |> elem(1)
  end

  def handle_event("date-change", %{"date" => date}, socket) do
    date = case date do
      "" -> ""
      _ -> parse_date(date)
    end

    readings = case date do
      "" -> ten_latest()
      _ -> ten_latest_by_date(date)
    end

    socket = assign(socket, date: date, readings: readings)
    {:noreply, socket}
  end

  def handle_event("add-reading", %{"station_id" => station_id, "type" => type, "value" => value}, socket) do
     Pollutiondb.Reading.add_now(to_int(station_id, 1), type, to_float(value, 0.0))
    date = socket.assigns.date
     readings = case date do
      "" -> ten_latest()
      _ -> ten_latest_by_date(date)
    end
   socket = assign(socket, readings: readings, type: type, value: value, station_id: station_id)
    {:noreply, socket}
  end

  def render(assigns) do
    ~H"""
      <form phx-change="date-change">
        <input type="date" name="date" value={@date} />
      </form>

      <form phx-submit="add-reading">
        <select name="station_id">
          <%= for station <- @stations do %>
            <option label={station.name} value={station.id} selected={station.id == @station_id}/>
          <% end %>
        </select>

        Type: <input type="text" name="type" value={@type} /><br/>
        Value: <input type="text" name="value" value={@value} /><br/>
        <input type="submit" />
      </form>

      <table>
        <tr>
          <th>Station name</th><th>date</th><th>time</th><th>Type</th><th>Value</th>
            </tr>
            <%= for reading <- @readings do %>
            <tr>
            <td><%= reading.station.name %></td>
            <td><%= reading.date %></td>
            <td><%= reading.time %></td>
            <td><%= reading.type %></td>
            <td><%= reading.value %></td>
          </tr>
        <% end %>
      </table>
    """
  end
end