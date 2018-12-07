module Main exposing (Model, Msg(..), init, main, subscriptions, update, view, viewLink)

import Browser
import Browser.Navigation as Nav
import Html exposing (..)
import Html.Attributes exposing (..)
import Url
import Url.Parser exposing ((</>), Parser, int, map, oneOf, s, string, top)



-- MAIN


main : Program () Model Msg
main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        , onUrlChange = UrlChanged
        , onUrlRequest = LinkClicked
        }



-- MODEL


type alias Model =
    { key : Nav.Key
    , url : Url.Url
    , route : Route
    }


type Route
    = Dashboard
    | Settings
    | NotFound


type alias Page msg =
    { title : String
    , body : List (Html msg)
    }


init : () -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init flags url key =
    ( Model key url Dashboard, Cmd.none )



-- UPDATE


type Msg
    = LinkClicked Browser.UrlRequest
    | UrlChanged Url.Url


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        LinkClicked urlRequest ->
            case urlRequest of
                Browser.Internal url ->
                    ( model, Nav.pushUrl model.key (Url.toString url) )

                Browser.External href ->
                    ( model, Nav.load href )

        UrlChanged url ->
            ( { model | route = fromUrl url }
            , Cmd.none
            )


routeParser : Parser (Route -> a) a
routeParser =
    oneOf
        [ map Dashboard top
        , map Settings (s "settings")
        ]


fromUrl : Url.Url -> Route
fromUrl url =
    Maybe.withDefault NotFound (Url.Parser.parse routeParser url)



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



-- VIEW


view : Model -> Browser.Document Msg
view model =
    case model.route of
        Dashboard ->
            viewDashboardPage model

        Settings ->
            viewDashboardPage model

        NotFound ->
            viewNotFound model


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


viewDashboardPage : Model -> Page msg
viewDashboardPage model =
    buildPage "Dashboard Page"
        (template
            (div []
                [ p [] [ text "Dashboard" ] ]
            )
        )


viewNotFound : Model -> Page msg
viewNotFound model =
    buildPage "Not Found"
        (template
            (div []
                [ p [] [ text "Not Found" ] ]
            )
        )


viewLink : String -> String -> Html msg
viewLink path humanName =
    li [] [ a [ href path ] [ text humanName ] ]
