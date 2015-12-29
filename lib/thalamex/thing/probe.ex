defmodule Thalamex.Thing.Probe do
  use Thalamex.Thing.Runner

  def start_link(tty, baudrate, owner, opts \\ []) do
    GenServer.start_link(__MODULE__, [tty, baudrate, owner], opts)
  end

  def init([tty, baudrate, owner]) do
    {:ok, serial} = Serial.start_link
    {:ok, board} = Board.start_link
    Serial.open(serial, tty)
    Serial.set_speed(serial, baudrate)
    Serial.connect(serial)
    {:ok, {board, serial, tty, owner}}
  end

  def handle_info({:firmata, {:version, _major, _minor}}, state) do
    {:noreply, state}
  end

  def handle_info({:firmata, {:firmware_name, name}}, {_board, _serial, tty, owner} = state) do
    send(owner, {:identified, tty, name})
    {:noreply, state}
  end

  def handle_info({:firmata, {:pin_map, _pin_map}}, state) do
    {:noreply, state}
  end
end