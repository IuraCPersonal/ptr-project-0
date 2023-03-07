defmodule Week5.Main.RESTAPI do
  # A DSL to define a routing algorithm that works with Plug.
  use Plug.Router

  # Using Plug.Logger for logging request information.
  plug(Plug.Logger)

  # Responsible for matching routes.
  plug(:match)

  # Responsible for dispatching responses.
  plug(:dispatch)

  def start_server() do
    # Create new database.
    :ets.new(:database, [:named_table, :set, :public])

    # Populate the database with information.
    :ets.insert(:database, [
      {1,
       %{
         title: "Star Wars : Episode IV - A New Hope",
         release_year: 1977,
         director: "George Lucas"
       }},
      {2,
       %{
         title: " Star Wars : Episode V - The Empire Strikes Back",
         release_year: 1980,
         director: "Irvin Kershner"
       }},
      {3,
       %{
         title: "Star Wars : Episode VI - Return of the Jedi",
         release_year: 1983,
         director: "Richard Marquand"
       }},
      {4,
       %{
         title: "Star Wars : Episode I - The Phantom Menace",
         release_year: 1999,
         director: "George Lucas"
       }},
      {5,
       %{
         title: "Star Wars : Episode II - Attack of the Clones ",
         release_year: 2002,
         director: "George Lucas"
       }},
      {6,
       %{
         title: "Star Wars : Episode III - Revenge of the Sith",
         release_year: 2005,
         director: "George Lucas"
       }},
      {7,
       %{
         title: "Star Wars : The Force Awakens",
         release_year: 2015,
         director: "J.J. Abrams"
       }},
      {8,
       %{
         title: "Rogue One : A Star Wars Story",
         release_year: 2016,
         director: "Gareth Edwards"
       }},
      {9,
       %{
         title: "Star Wars : The Last Jedi",
         release_year: 2017,
         director: "Rian Johnson"
       }},
      {10,
       %{
         title: "Solo : A Star Wars Story",
         release_year: 2018,
         director: "Ron Howard"
       }},
      {11,
       %{
         title: "Star Wars : The Rise of Skywalker",
         release_year: 2019,
         director: "J.J. Abrams"
       }}
    ])

    # Runs cowboy under http.
    Plug.Cowboy.http(Week5.Main.RESTAPI, [], port: 8080)
  end

  # Getting all the movies.
  get "/movies" do
    response =
      :ets.tab2list(:database)
      |> Enum.sort()
      |> Enum.map(fn
        {id,
         %{
           title: title,
           release_year: release_year,
           director: director
         }} ->
          %{
            "id" => id,
            "title" => title,
            "release_year" => release_year,
            "director" => director
          }
      end)

    handle_response(conn, 200, response)
  end

  get "/movies/:id" do
    id = String.to_integer(id)

    movie =
      :ets.tab2list(:database)
      |> Enum.sort()
      |> Enum.map(fn {id, data} ->
        %{
          "id" => id,
          "title" => data[:title],
          "release_year" => data[:release_year],
          "director" => data[:director]
        }
      end)
      |> Enum.find(fn m -> m["id"] == id end)

    handle_response(conn, 200, movie)
  end

  post "/movies" do
    # Reads the request body.
    {:ok, body, conn} = Plug.Conn.read_body(conn)

    # DEBUG:
    # IO.inspect(body)

    {:ok,
     %{
       "title" => title,
       "release_year" => release_year,
       "director" => director
     }} = body |> Poison.decode()

    id = :ets.info(:database)[:size] + 1

    :ets.insert(
      :database,
      {
        id,
        %{
          title: title,
          release_year: release_year,
          director: director
        }
      }
    )

    handle_response(conn, 200, %{
      "id" => id,
      "title" => title,
      "release_year" => release_year,
      "director" => director
    })
  end

  put "/movies/:id" do
    id = String.to_integer(id)

    # Reads the request body.
    {:ok, body, conn} = Plug.Conn.read_body(conn)

    {:ok,
     %{
       "title" => title,
       "release_year" => release_year,
       "director" => director
     }} = body |> Poison.decode()

    :ets.insert(
      :database,
      {
        id,
        %{
          title: title,
          release_year: release_year,
          director: director
        }
      }
    )

    handle_response(conn, 200, %{
      "id" => id,
      "title" => title,
      "release_year" => release_year,
      "director" => director
    })
  end

  delete "/movies/:id" do
    :ets.delete(:database, id |> String.to_integer())

    handle_response(conn, 200, "SUCCESS")
  end

  # Sets the value of the "content-type" response header taking into account the charset
  # Sends a response to the client.
  # Encode a value to JSON.
  defp handle_response(conn, code, data) do
    conn
    |> Plug.Conn.put_resp_content_type("application/json")
    |> send_resp(code, Poison.encode!(data))
  end
end
