defmodule PollutiondbWeb.ReadingLive do
  use PollutiondbWeb, :live_view
  import Ecto.Query

  alias Pollutiondb.Reading

  def mount(_params, _session, socket) do
    date = parse_date("2024-2-14")
    socket = assign(socket, readings: ten_latest(), date: "")
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

  def render(assigns) do
    ~H"""
      <form phx-change="date-change">
        <input type="date" name="date" value={@date} />
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