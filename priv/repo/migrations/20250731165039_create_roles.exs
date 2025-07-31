defmodule SmartSchoolLive.Repo.Migrations.CreateRoles do
  use Ecto.Migration

  def change do
    create table(:roles) do
      add :name, :string
      add :description, :string

      timestamps(type: :utc_datetime)
    end
  end
end
