defmodule Bubblit.BubbleRooms.BubbleLog do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder, only: [:id, :content, :room_id, :user_id, :inserted_at]}
  schema "bubble_logs" do
    field :content, :string

    belongs_to :room, Bubblit.BubbleRooms.Room
    belongs_to :user, Bubblit.Accounts.User

    timestamps()
  end

  @doc false
  def changeset(bubble_log, attrs) do
    bubble_log
    |> cast(attrs, [:room_id, :user_id, :content])
    |> validate_required([:room_id, :user_id, :content])
  end
end
