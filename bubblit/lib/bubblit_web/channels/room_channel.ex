defmodule BubblitWeb.RoomChannel do
  use Phoenix.Channel
  alias BubblitWeb.Presence

  require Logger

  def join("room:" <> room_id, _params, socket) do
    Logger.info("lobby room joined #{room_id} #{inspect(socket)}")

    case Integer.parse(room_id) do
      {room_id, _remainer} ->
        room_record = Bubblit.Db.get_or_create_room(room_id, socket.assigns.user_id)
        Bubblit.Room.DynamicSupervisor.start_child(room_id)
        send(self(), :after_join)

        socket =
          assign(socket, :room_record, room_record) |> assign(:id, inspect(socket.transport_pid))

        Logger.info("user id #{socket.assigns.user_id} joined to room id #{room_id}.")

        {:ok, %{body: "어서와"}, socket}

      :error ->
        {:error, %{reason: "invalid channel name"}}
    end
  end

  def handle_info(:after_join, socket) do
    Logger.info(
      "user id #{socket.assigns.user_id} after join to room id #{socket.assigns.room_record.id}."
    )

    {:ok, _} =
      Presence.track(socket, socket.assigns.user_id, %{
        online_at: inspect(System.system_time(:second))
      })

    push(socket, "presence_state", Presence.list(socket))

    bubble_history = Bubblit.Room.Monitor.get_messages(socket.assigns.room_record.id)

    push(socket, "bubble_history", %{history: bubble_history})

    {:noreply, socket}
  end

  # 그냥 메세지 브로드캐스트할때 닉네임 추가했음.
  def handle_in("new_msg", %{"body" => body}, socket) do
    Bubblit.Room.Monitor.add_message(socket.assigns.room_record.id, socket.assigns.user_id, body)

    broadcast!(socket, "new_msg", %{body: body, user_id: socket.assigns.user_id})

    {:noreply, socket}
  end

  def handle_in("img_link", %{"body" => body}, socket) do
    # 특정 유저가 이미지 링크를 업로드, 해당 이미지 링크를 타 유저들에게 브로드캐스트해주는 함수.
    broadcast!(socket, "img_link", %{body: body, user_id: socket.assigns.user_id})

    {:noreply, socket}
  end

  def handle_in("youtube_link", %{"body" => body}, socket) do
    # 특정 유저가 유튜브 링크를 업로드, 해당 이미지 링크를 타 유저들에게 브로드캐스트해주는 함수.
    # 유튜브 링크 손질하는 건 프론트에서 할지, 백에서 할지?
    broadcast!(socket, "youtube_link", %{body: body, user_id: socket.assigns.user_id})

    {:noreply, socket}
  end

  # def handle_in("update_step", %{"body" => body}, socket) do
  #   Logger.info("update_step을 받음. 근데 길이가 #{String.length(body)}")
  #   id = socket.assigns.record.id
  #   new_record = Monitor.step_record_update(id, body)
  #   broadcast(socket, "update_step", %{body: new_record[id].step_record})
  #   {:noreply, socket}
  # end

  # def handle_in("click", %{"body" => index}, socket) do
  #   Logger.info("socket #{inspect(socket)} send click #{index}")
  #   broadcast(socket, "click", %{body: index, id: socket.assigns.id})
  #   {:noreply, socket}
  # end
end
