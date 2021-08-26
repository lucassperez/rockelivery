defmodule Rockelivery.Orders.ReportRunner do
  use GenServer

  require Logger

  alias Rockelivery.Orders.Report

  # 5 hours
  @generate_interval 1000 * 60 * 60 * 5
  # 1 minute
  # @generate_interval 1000 * 60
  # 5 seconds
  # @generate_interval 1000 * 5

  def start_link(initial_state \\ %{})

  def start_link(initial_state),
    do: GenServer.start_link(__MODULE__, initial_state)

  @impl true
  def init(state) do
    Logger.info("Report Runner has started")
    schedule_report_generation()
    {:ok, state}
  end

  @impl true # recebe qualquer tipo de mensagem
  def handle_info(:generate, state) do
    Mix.env() == :prod && Logger.info("Generating report")
    Report.create()
    schedule_report_generation()
    {:noreply, state}
  end

  def schedule_report_generation(interval \\ @generate_interval) do
    Process.send_after(self(), :generate, interval)
  end
end
