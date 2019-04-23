port module Page.Settings exposing (Model, Msg(..), Status(..), getSchema, init, initialModel, subscriptions, update, view)

import Api
import Api.Endpoint as Endpoint exposing (Endpoint)
import Bulma.Columns exposing (..)
import Bulma.Components as Components exposing (..)
import Bulma.Elements exposing (content)
import Bulma.Layout exposing (..)
import Bulma.Modifiers exposing (Color(..), Size(..), Width(..))
import Debug exposing (toString)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Json.Decode as Decode exposing (Decoder, Value, string)
import Json.Decode.Pipeline exposing (required, requiredAt)
import Json.Encode as E
import Router exposing (Section(..))
import Task exposing (Task)



-- MODEL


type alias Schema =
    { name : String
    , description : String
    , globalSettings : Value
    , routeSettings : Value
    }


type alias Config =
    Value


type alias Settings =
    { schema : Schema
    , config : Config
    }


type Status
    = Failure
    | Loading
    | Success


type alias Model =
    { status : Status
    , settings : Maybe Settings
    , section : Section
    }


initialModel =
    { section = Init, status = Loading, settings = Nothing }


init : Section -> Model -> ( Model, Cmd Msg )
init section model =
    case section of
        Init ->
            ( model
            , Task.attempt GotSettings getSettings
            )

        _ ->
            ( { model | section = section }, cmdRenderFormWithSettings model.settings section )



-- UPDATE


type Msg
    = GetSettings
    | GotSettings (Result Http.Error Settings)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GetSettings ->
            ( { model | status = Loading }
            , Task.attempt GotSettings getSettings
            )

        GotSettings result ->
            case result of
                Ok settings ->
                    ( { model | status = Success, settings = Just settings }, cmdRenderFormWithSettings (Just settings) model.section )

                Err error ->
                    ( { model | status = Failure }, logThisShit (toString error) )


getSettings : Task Http.Error Settings
getSettings =
    let
        settings schema config =
            { schema = schema, config = config }
    in
    getSchema
        |> Task.andThen
            (\schema -> Task.succeed (settings schema))
        |> Task.andThen
            (\settingsWithSchema -> getConfig |> Task.andThen (\config -> Task.succeed (settingsWithSchema config)))


cmdRenderFormWithSettings : Maybe Settings -> Section -> Cmd Msg
cmdRenderFormWithSettings maybeSettings section =
    case ( section, maybeSettings ) of
        ( Init, Just settings ) ->
            renderForm settings.schema.globalSettings

        ( Global, Just settings ) ->
            renderForm settings.schema.globalSettings

        ( Routes, Just settings ) ->
            renderForm settings.schema.routeSettings

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


getSchema : Task Http.Error Schema
getSchema =
    Api.get Endpoint.schema schemaDecoder


getConfig : Task Http.Error Config
getConfig =
    Api.get Endpoint.config configDecoder


schemaDecoder : Decoder Schema
schemaDecoder =
    Decode.succeed Schema
        |> required "name" string
        |> required "description" string
        |> requiredAt [ "properties", "global" ] Decode.value
        |> requiredAt [ "properties", "routes" ] Decode.value


configDecoder : Decoder Config
configDecoder =
    Decode.value
