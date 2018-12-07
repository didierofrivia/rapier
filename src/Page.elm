module Page exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Pages.Dashboard exposing (..)
import Pages.NotFound exposing (..)
import Pages.Settings exposing (view)
import Router exposing (Route(..))


type alias Page msg =
    { title : String
    , body : List (Html msg)
    }


type alias Model =
    { route : Route
    }



-- UPDATE


type Msg
    = LoadPage Route
    | Noop


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        LoadPage route ->
            ( { model | route = route }, Cmd.none )

        Noop ->
            ( model
            , Cmd.none
            )



-- VIEW


view : Model -> Page msg
view model =
    buildPage "Rapier"
        (template
            (div []
                [ p [] [ viewPage model ] ]
            )
        )


viewPage : Model -> Html msg
viewPage model =
    case model.route of
        Dashboard ->
            Pages.Dashboard.view {}

        Settings ->
            Pages.Settings.view {}

        NotFound ->
            Pages.NotFound.view {}


buildPage : String -> List (Html msg) -> Page msg
buildPage title body =
    { title = title
    , body = body
    }


header : Html msg
header =
    div []
        [ p [] [ text "Header" ]
        , ul []
            [ viewLink "/" "Dashboard"
            , viewLink "/settings" "Settings"
            , viewLink "/asdasd" "asdsad"
            ]
        ]


footer : Html msg
footer =
    div []
        [ p [] [ text "Footer" ]
        ]


template : Html msg -> List (Html msg)
template content =
    [ header
    , content
    , footer
    ]


viewLink : String -> String -> Html msg
viewLink path humanName =
    li [] [ a [ href path ] [ text humanName ] ]
