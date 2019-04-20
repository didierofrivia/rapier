port module Page.Settings exposing (Model, Msg(..), Status(..), getSettings, init, initialModel, subscriptions, update, view)

import Browser
import Browser.Navigation as Nav
import Bulma.Columns exposing (..)
import Bulma.Components as Components exposing (..)
import Bulma.Elements as Elements exposing (content, title)
import Bulma.Form as Form exposing (controlInput, controlInputModifiers, controlModifiers, controlText, field, help, label)
import Bulma.Layout as Layout exposing (..)
import Bulma.Modifiers exposing (Color(..), Size(..), Width(..))
import Debug exposing (log, toString)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Json.Decode as Decode exposing (Decoder, Value, decodeValue, field, int, string)
import Json.Decode.Pipeline exposing (hardcoded, optional, required, requiredAt)
import Json.Encode as E
import Router exposing (Section(..))
import Session exposing (..)



-- MODEL


type alias Settings =
    { name : String
    , description : String
    , globalSettings : Value
    , routeSettings : Value
    }


type Status
    = Failure
    | Loading
    | Success


type alias Model =
    { status : Status
    , schema : Maybe Settings
    , section : Section
    }


initialModel =
    { section = Init, status = Loading, schema = Nothing }


init : Section -> Model -> ( Model, Cmd Msg )
init section model =
    case section of
        Init ->
            ( model
            , getSettings
            )

        _ ->
            ( { model | section = section }, cmdRenderFormWithSettings model.schema section )



-- UPDATE


type Msg
    = GetSettings
    | GotSettings (Result Http.Error Settings)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GetSettings ->
            ( { model | status = Loading }, getSettings )

        GotSettings result ->
            case result of
                Ok settings ->
                    ( { model | status = Success, schema = Just settings }, renderForm settings.globalSettings )

                Err error ->
                    ( { model | status = Failure }, logThisShit (toString error) )


cmdRenderFormWithSettings : Maybe Settings -> Section -> Cmd Msg
cmdRenderFormWithSettings schema section =
    case ( section, schema ) of
        ( Global, Just settings ) ->
            renderForm settings.globalSettings

        ( Routes, Just settings ) ->
            renderForm settings.routeSettings

        ( _, _ ) ->
            Cmd.none



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- PORTS


port renderForm : E.Value -> Cmd msg


port logThisShit : String -> Cmd msg



-- VIEW


view : Model -> Html Msg
view model =
    content Large
        []
        [ container []
            [ columns columnsModifiers
                []
                [ column columnModifiers
                    []
                    [ columns columnsModifiers
                        []
                        [ column settingsMenuColumnModifier
                            []
                            [ settingsMenu model.section ]
                        , column columnModifiers
                            []
                            [ viewFormContainer
                            ]
                        ]
                    , viewSettings model
                    ]
                ]
            ]
        ]


viewFormContainer : Html Msg
viewFormContainer =
    div [ id "SettingsForm" ] []


viewSettings : Model -> Html Msg
viewSettings model =
    case model.status of
        Failure ->
            div []
                [ text "I could not load apicast settings for some reason. "
                , button [ onClick GetSettings ] [ text "Get Settings!" ]
                ]

        Loading ->
            text "Loading..."

        Success ->
            globalSettingsView


settingsMenuColumnModifier =
    { columnModifiers
        | widths =
            { mobile = Just Auto
            , tablet = Just Width3
            , desktop = Just Width3
            , widescreen = Just Width3
            , fullHD = Just Width3
            }
    }


globalSettingsView : Html msg
globalSettingsView =
    div [ style "margin-top" "0.5em" ] [ div [] [] ]


settingsMenu : Section -> Html msg
settingsMenu section =
    Components.menu []
        [ menuList []
            [ menuListItemLink (section == Global || section == Init) [ href "settings#global" ] [ text "Global" ]
            , menuListItemLink (section == Routes) [ href "settings#routes" ] [ text "Routes" ]
            ]
        ]



-- HTTP


getSettings : Cmd Msg
getSettings =
    Http.get
        { -- TODO: get this url from config
          url = "http://localhost:3000/schema"
        , expect = Http.expectJson GotSettings settingsDecoder
        }


settingsDecoder : Decoder Settings
settingsDecoder =
    Decode.succeed Settings
        |> required "name" string
        |> required "description" string
        |> requiredAt [ "properties", "global" ] Decode.value
        |> requiredAt [ "properties", "routes" ] Decode.value
