module Example01BasicQuery exposing (main)

import Browser
import Graphql.Document as Document
import Graphql.Field as Field
import Graphql.Http
import Graphql.Operation exposing (RootQuery)
import Graphql.SelectionSet as SelectionSet exposing (SelectionSet, fieldSelection, hardcoded, with, withFragment)
import Helpers.Main
import RemoteData exposing (RemoteData)
import Swapi.Interface
import Swapi.Interface.Character as Character
import Swapi.Object
import Swapi.Query as Query
import Swapi.Scalar



{-

   The `query` definition in our Elm code
   is using our `characterInfoSelection` `SelectionSet`
   that we define lower down in our Elm code.
   The equivalent raw GraphQL would look like this:


   query {
     hero {
       ...characterInfo
     }
   }

-}


type alias Response =
    { hero : Character
    }



{- Check out this page to learn more about how Record Constructor Functions
   like `Response` in this example are used as the first argument to `selection`s:
   https://dillonkearns.gitbooks.io/elm-graphql/content/selection-sets.html
-}


query : SelectionSet Response RootQuery
query =
    Query.selection Response
        -- We use `identity` to say that we aren't giving any
        -- optional arguments to `hero`. Read this blog post for more:
        -- https://medium.com/@zenitram.oiram/graphqelm-optional-arguments-in-a-language-without-optional-arguments-d8074ca3cf74
        |> with (Query.hero identity characterInfoSelection)



{-

   `characterInfoSelection` below is equivalent to defining
   a fragment like this in raw GraphQL:


    fragment characterInfo on Character {
      name
      id
      friends {
        name
      }
    }

-}


type alias Character =
    { name : String
    , id : Swapi.Scalar.Id
    , friends : List String
    }


characterInfoSelection : SelectionSet Character Swapi.Interface.Character
characterInfoSelection =
    Character.selection Character
        |> with Character.name
        |> with Character.id
        |> with (Character.friends (fieldSelection Character.name))


makeRequest : Cmd Msg
makeRequest =
    query
        |> Graphql.Http.queryRequest "https://elm-graphql.herokuapp.com"
        |> Graphql.Http.withCredentials
        |> Graphql.Http.send (RemoteData.fromResult >> GotResponse)



-- Elm Architecture Setup


type Msg
    = GotResponse Model


type alias Model =
    RemoteData (Graphql.Http.Error Response) Response


type alias Flags =
    ()


init : Flags -> ( Model, Cmd Msg )
init _ =
    ( RemoteData.Loading, makeRequest )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotResponse response ->
            ( response, Cmd.none )


main : Program Flags Model Msg
main =
    Browser.document
        { init = init
        , update = update
        , subscriptions = \_ -> Sub.none
        , view = Helpers.Main.view (Document.serializeQuery query)
        }