defmodule Pollutiondb.Reading do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  schema "readings" do
    field :date, :date
    field :time, :time
    field :type, :string
    field :value, :float

    belongs_to :station, Pollutiondb.Station
  end

  def add_now(station, type, value) do
    Pollutiondb.Repo.insert(%Pollutiondb.Reading{
      date: Date.utc_today,
      time: Time.truncate(Time.utc_now, :second),
      type: type,
      value: value,
      station_id: station
    })
  end

  def add(station, date, time, type ,value) do
    Pollutiondb.Repo.insert(%Pollutiondb.Reading{
      date: date,
      time: time,
      type: type,
      value: value,
      station_id: station
    })
  end

  def find_by_date(date) do
    Pollutiondb.Repo.all(
      Ecto.Query.where(Pollutiondb.Reading, date: ^date)
    )
  end

  def changeset(reading, attrs) do
    reading
    |> cast(attrs, [:date, :time, :type, :value, :station_id])
    |> validate_required([:date, :time, :type, :value, :station_id])
    |> validate_number(:value, greater_than: 0)
  end
end