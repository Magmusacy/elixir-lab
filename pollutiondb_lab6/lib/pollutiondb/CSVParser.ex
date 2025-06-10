defmodule Pollutiondb.CSVParser do
  def parse_lines(lines) do
    for line <- lines do
      parsed_line = Pollutiondb.CSVParser.parse_line(line)
    end
  end

  def parse_line(line) do
    [datetime, type, value, id, name, coords] = line |> String.split(";")
    [date, time] = datetime |> String.split("T")
    time = time |> String.slice(0, 8)
    %{:id => id,
      pollutionLevel: value |> String.to_float(),
      coords: coords
              |> String.split(",")
              |> Enum.map(&String.to_float/1)
              |> List.to_tuple(),
      pollutionType: type,
      stationName: name,
      datetime: {
        date |> String.split("-") |> Enum.map(&String.to_integer/1) |> List.to_tuple(),
        time |> String.split(":") |> Enum.map(&String.to_integer/1) |> List.to_tuple()
      }
    }
  end

  def start_parsing() do
    all_stations = File.read!("C:\\Users\\xpfk0\\studia\\AirlyData-ALL-50k.csv")
                   |> String.split("\n")
                   |> Enum.map(&Pollutiondb.CSVParser.parse_line/1)
    unique_stations = all_stations |> Enum.uniq_by(& &1.id)

    IO.inspect(unique_stations)

    for station <- unique_stations do
      {lon, lat} = station.coords
      Pollutiondb.Station.add(station.stationName, lon, lat)
    end

    for station <- all_stations do
      {{year, month, day}, {hour, minute, second}} = station.datetime
      {_, time} = Time.new(hour, minute, second)
      {_, date} = Date.new(year, month, day)
      correct_station = Pollutiondb.Station.find_by_name(station.stationName)
      Pollutiondb.Reading.add(List.first(correct_station).id, date, time, station.pollutionType, station.pollutionLevel)
    end
  end
end