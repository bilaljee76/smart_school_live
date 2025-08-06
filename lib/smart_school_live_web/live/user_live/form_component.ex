defmodule SmartSchoolLiveWeb.UserLive.FormComponent do
  use SmartSchoolLiveWeb, :live_component

  alias SmartSchoolLive.Accounts

  @impl true
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
        <.input field={@form[:name]} type="text" label="Name" />
        <.input field={@form[:email]} type="text" label="email" />
        <.input field={@form[:password]} type="password" label="password" />
        <.input field={@form[:age]} type="number" label="Age" />
        <.input field={@form[:cnic]} type="text" label="Cnic" />
        <:actions>
          <.button phx-disable-with="Saving...">Save User</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  # @impl true
  # def update(%{user: user} = assigns, socket) do
  #   {:ok,
  #    socket
  #    |> assign(assigns)
  #    |> assign_new(:form, fn ->
  #      to_form(Accounts.change_user(user))
  #    end)}
  # end

  @impl true
def update(%{user: user} = assigns, socket) do
  form = Accounts.change_user(user)

  {:ok,
   socket
   |> assign(assigns)
   |> assign_new(:form, fn -> to_form(form) end)
   |> assign_new(:admin_form, fn -> false end)}  # ✅ ensures admin_form is always present
end


  @impl true
  def handle_event("validate", %{"user" => user_params}, socket) do
    changeset = Accounts.change_user(socket.assigns.user, user_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"user" => user_params}, socket) do
    save_user(socket, socket.assigns.action, user_params)
  end

  defp save_user(socket, :edit, user_params) do
    case Accounts.update_user(socket.assigns.user, user_params) do
      {:ok, user} ->
        notify_parent({:saved, user})

        {:noreply,
         socket
         |> put_flash(:info, "User updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  # defp save_user(socket, :new, user_params) do
  #   case Accounts.register_user(user_params) do
  #     {:ok, user} ->
  #       notify_parent({:saved, user})

  #       {:noreply,
  #        socket
  #        |> put_flash(:info, "User created successfully")
  #        |> push_patch(to: socket.assigns.patch)}

  #     {:error, %Ecto.Changeset{} = changeset} ->
  #       {:noreply, assign(socket, form: to_form(changeset))}
  #   end
  # end

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
  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
