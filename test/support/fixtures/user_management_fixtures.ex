defmodule SmartSchoolLive.UserManagementFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `SmartSchoolLive.UserManagement` context.
  """

  @doc """
  Generate a role.
  """
  def role_fixture(attrs \\ %{}) do
    {:ok, role} =
      attrs
      |> Enum.into(%{
        name: "some name"
      })
      |> SmartSchoolLive.UserManagement.create_role()

    role
  end
end
