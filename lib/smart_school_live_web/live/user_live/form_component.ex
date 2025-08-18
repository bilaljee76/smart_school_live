defmodule SmartSchoolLiveWeb.UserLive.FormComponent do
  use SmartSchoolLiveWeb, :live_component

  alias SmartSchoolLive.Accounts
@impl true
  def update(%{user: user} = assigns, socket) do
    changeset = Accounts.change_user(user)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:form, to_form(changeset))
     |> allow_upload(:avatar, accept: ~w(.jpg .png .jpeg), max_entries: 1)}
  end


  @impl true
  @spec render(any()) :: Phoenix.LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        {@title}
        <:subtitle>Use this form to manage user records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="user-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.live_file_input upload={@uploads.avatar} />
        <.input field={@form[:name]} type="text" label="Name" />
        <.input field={@form[:email]} type="text" label="email" />
        <.input field={@form[:password]} type="password" label="password" />
        <.input field={@form[:age]} type="number" label="Age" />
        <.input field={@form[:user_id]} type="text" label="Cnic" />
        <:actions>
          <.button phx-disable-with="Saving...">Save User</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end



  @impl true
  def handle_event("validate", %{"user" => user_params}, socket) do
    changeset = Accounts.change_user(socket.assigns.user, user_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  @impl true
  def handle_event("save", %{"user" => user_params}, socket) do
    uploaded_files =
      consume_uploaded_entries(socket, :avatar, fn %{path: path}, _entry ->
        dest =
          Path.join(
            Application.app_dir(:smart_school_live, "priv/static/uploads"),
            Path.basename(path)
          )

        File.cp!(path, dest)
        {:ok, "/uploads/#{Path.basename(dest)}"}
      end)

    user_params =
      case uploaded_files do
        [avatar_url | _] -> Map.put(user_params, "avatar", avatar_url)
        _ -> user_params
      end

    save_user(socket, socket.assigns.action, user_params)
  end

  # SAVE USER FUNCTION (3 ARGS)
  defp save_user(socket, :edit, user_params) do
    case Accounts.update_user(socket.assigns.user, user_params) do
      {:ok, user} ->
        notify_parent({:saved, user})

        {:noreply,
         socket
         |> put_flash(:info, "User updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :form, to_form(changeset))}
    end
  end

  defp save_user(socket, :new, user_params) do
    if socket.assigns[:admin_form] == true do
      case SmartSchoolLive.Accounts.add_new_user(user_params) do
        {:ok, user} ->
          notify_parent({:saved, user})

          {:noreply,
           socket
           |> put_flash(:info, "User created successfully")
           |> push_patch(to: socket.assigns.patch)}

        {:error, %Ecto.Changeset{} = changeset} ->
          {:noreply, assign(socket, form: to_form(changeset))}
      end
    else
      case Accounts.register_user(user_params) do
        {:ok, user} ->
          notify_parent({:saved, user})

          {:noreply,
           socket
           |> put_flash(:info, "User registered successfully")
           |> push_patch(to: socket.assigns.patch)}

        {:error, %Ecto.Changeset{} = changeset} ->
          {:noreply, assign(socket, form: to_form(changeset))}
      end
    end
  end

  # defp save_user(socket, :new, user_params, avatar_filename) do
  #   # IO.inspect(user_params, label: "🔽 user_params in save_user")
  #   # IO.inspect(socket.assigns.admin_form, label: "👀 Admin form?")

  #   uploaded_files =
  #     consume_uploaded_entries(socket, :avatar, fn %{path: path}, _entry ->
  #       dest = Path.join("priv/static/uploads", Path.basename(path))
  #       File.cp!(path, dest)
  #       {:ok, "/uploads/#{Path.basename(path)}"}
  #     end)

  #   user_params =
  #     case uploaded_files do
  #       [file_path | _] -> Map.put(user_params, "avatar", file_path)
  #       _ -> user_params
  #     end

  #   if socket.assigns[:admin_form] == false do
  #     case SmartSchoolLive.Accounts.add_new_user(user_params) do
  #       {:ok, user} ->
  #         notify_parent({:saved, user})

  #         {:noreply,
  #          socket
  #          |> put_flash(:info, "User created successfully")
  #          |> push_patch(to: socket.assigns.patch)}

  #       {:error, %Ecto.Changeset{} = changeset} ->
  #         {:noreply, assign(socket, form: to_form(changeset))}
  #     end
  #   else
  #     case Accounts.register_user(user_params) do
  #       {:ok, user} ->
  #         notify_parent({:saved, user})

  #         {:noreply,
  #          socket
  #          |> put_flash(:info, "User registered successfully")
  #          |> push_patch(to: socket.assigns.patch)}

  #       {:error, %Ecto.Changeset{} = changeset} ->
  #         {:noreply, assign(socket, form: to_form(changeset))}
  #     end
  #   end
  # end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
