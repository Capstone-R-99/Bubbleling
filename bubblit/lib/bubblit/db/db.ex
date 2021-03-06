defmodule Bubblit.Db do
  # db관련 래핑 함수. 쿼리 직접 조작하는 것은 Generate 된 곳에 만든다.
  # 여기에는 쿼리를 직접 작성하지 말자.

  def create_room(title, host_user_id, is_private) do
    attrs = %{
      title: title,
      host_user_id: host_user_id,
      config_value: "",
      users: [host_user_id],
      is_private: is_private,
      room_password: make_room_password()
    }

    {:ok, room_record} = Bubblit.BubbleRooms.create_room(attrs)

    room_record |> convert_room_users()
  end

  def get_room(id) do
    Bubblit.BubbleRooms.get_room(id) |> convert_room_users
  end

  defp make_room_password(length \\ 8) do
    :crypto.strong_rand_bytes(length)
    |> Base.encode64()
    |> binary_part(0, length)
    |> String.upcase()
  end

  def update_room(room, attrs) do
    {:ok, room_record} = Bubblit.BubbleRooms.update_room(room, attrs)
    room_record |> convert_room_users()
  end

  def list_rooms() do
    Bubblit.BubbleRooms.list_rooms() |> Enum.map(fn x -> convert_room_users(x) end)
  end

  def get_room!(id) do
    Bubblit.BubbleRooms.get_room!(id) |> convert_room_users()
  end

  def delete_room(room) do
    {:ok, room} = Bubblit.BubbleRooms.delete_room(room)
    Bubblit.Room.DynamicSupervisor.terminate_child(room.id)
    Ets.unset_room_control_restricted(room.id)
  end

  def convert_room_users(room_record) do
    if room_record do
      user_list = Bubblit.BubbleRooms.Room.room_user_to_list(room_record.users)
      put_in(room_record.users, user_list)
    else
      room_record
    end
  end

  def change_room_config(room_record, config_value) do
    # 일단 Default 세팅으로 가보자.
    attrs = %{config_value: config_value}
    {:ok, new_room_record} = Bubblit.BubbleRooms.change_room(room_record, attrs)

    new_room_record
  end

  def read_bubble_log(room_id) do
    Bubblit.BubbleRooms.list_bubble_logs(room_id)
  end

  def create_bubble_log(room_id, user_id, content) do
    # 방이 히스토리를 지원하는 config인지 확인해야함
    # config도 장기적으로는 db에 집어넣어서, 가져올것임.
    attrs = %{room_id: room_id, user_id: user_id, content: content}
    {:ok, _bubble_log} = Bubblit.BubbleRooms.create_bubble_log(attrs)
  end

  def create_user(name) do
    attrs = %{name: name}
    {:ok, user} = Bubblit.Accounts.create_user(attrs)

    user
  end

  def create_room_action(room_id, user_id, type, param \\ "") do
    {:ok, room_action} =
      Bubblit.BubbleRooms.create_room_action(%{
        room_id: room_id,
        user_id: user_id,
        type: type,
        param: "#{param}"
      })

    room_action
  end

  def get_room_actions(room_id) do
    Bubblit.BubbleRooms.list_room_actions(room_id)
  end
end
