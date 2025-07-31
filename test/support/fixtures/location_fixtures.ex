defmodule SmartSchoolLive.LocationFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `SmartSchoolLive.Location` context.
  """

  @doc """
  Generate a country.
  """
  def country_fixture(attrs \\ %{}) do
    {:ok, country} =
      attrs
      |> Enum.into(%{
        code: "some code",
        name: "some name"
      })
      |> SmartSchoolLive.Location.create_country()

    country
  end

  @doc """
  Generate a city.
  """
  def city_fixture(attrs \\ %{}) do
    {:ok, city} =
      attrs
      |> Enum.into(%{
        name: "some name"
      })
      |> SmartSchoolLive.Location.create_city()

    city
  end
end
