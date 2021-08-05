defmodule Rockelivery.ViaCep.ClientTest do
  use ExUnit.Case, async: true

  alias Rockelivery.Error
  alias Rockelivery.ViaCep.Client, as: ViaCepClient

  defp endpoint_url(port), do: "http://localhost:#{port}/"

  describe "get_cep_info/2" do
    setup do
      bypass = Bypass.open()

      {:ok, bypass: bypass}
    end

    test "when cep is valid, it returns a cep info", %{bypass: bypass} do
      cep = "01001000"
      body = ~s[
        {
          "cep": "01001-000",
          "logradouro": "Praça da Sé",
          "complemento": "lado ímpar",
          "bairro": "Sé",
          "localidade": "São Paulo",
          "uf": "SP",
          "ibge": "3550308",
          "gia": "1004",
          "ddd": "11",
          "siafi": "7107"
        }
      ]
      url = endpoint_url(bypass.port)

      Bypass.expect(bypass, "GET", "#{cep}/json/", fn conn ->
        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.resp(200, body)
      end)

      response = ViaCepClient.get_cep_info(url, cep)

      assert response == {
        :ok,
        %{
          "bairro" => "Sé",
          "cep" => "01001-000",
          "complemento" => "lado ímpar",
          "ddd" => "11",
          "gia" => "1004",
          "ibge" => "3550308",
          "localidade" => "São Paulo",
          "logradouro" => "Praça da Sé",
          "siafi" => "7107",
          "uf" => "SP"
        }
      }
    end

    test "when cep is invalid, it returns an error", %{bypass: bypass} do
      cep = "123"
      url = endpoint_url(bypass.port)

      Bypass.expect(bypass, "GET", "#{cep}/json/", fn conn ->
        Plug.Conn.resp(conn, 400, "")
      end)

      response = ViaCepClient.get_cep_info(url, cep)

      assert response == {
        :error,
        %Error{
          result: "Invalid CEP",
          status: :bad_request
        }
      }
    end

    test "when cep is not found, it returns an error", %{bypass: bypass} do
      cep = "12345-678"
      body = ~s[{"erro": true}]
      url = endpoint_url(bypass.port)

      Bypass.expect(bypass, "GET", "#{cep}/json/", fn conn ->
        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.resp(200, body)
      end)

      response = ViaCepClient.get_cep_info(url, cep)

      assert response == {
        :error,
        %Error{
          result: "CEP not found",
          status: :not_found
        }
      }
    end

    test "requisition timeout", %{bypass: bypass} do
      cep = "09876543"
      url = endpoint_url(bypass.port)
      Bypass.down(bypass)

      response = ViaCepClient.get_cep_info(url, cep)

      assert response == {
        :error,
        %Error{
          result: :econnrefused,
          status: :bad_request
        }
      }
    end
  end
end
