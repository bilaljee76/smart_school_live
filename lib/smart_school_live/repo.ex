defmodule SmartSchoolLive.Repo do
  use Ecto.Repo,
    otp_app: :smart_school_live,
    adapter: Ecto.Adapters.Postgres
end
