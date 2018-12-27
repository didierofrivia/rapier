module Main exposing (Model, Msg(..), init, main, subscriptions, update, view)

import Browser exposing (..)
import Browser.Navigation as Nav
import Html exposing (..)
import Html.Attributes exposing (..)
import Page exposing (..)
import Page.Dashboard as Dashboard exposing (..)
import Page.NotFound as NotFound exposing (..)
import Page.Settings as Settings exposing (..)
import Router exposing (Route(..), fromUrl, parser)
import Session exposing (..)
import Url



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
    { page : Page
    , session : Session
    }


type Page
    = Dashboard Dashboard.Model
    | Settings Settings.Model
    | NotFound NotFound.Model


init : () -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init flags url key =
    loadPage (Router.fromUrl url) { page = Dashboard {}, session = Session key }



-- UPDATE


type Msg
    = LinkClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | GotSettingsMsg Settings.Msg
    | GotDashboardMsg Dashboard.Msg
    | GotNotFoundMsg NotFound.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        LinkClicked urlRequest ->
            case urlRequest of
                Browser.Internal url ->
                    ( model, Nav.pushUrl model.session.key (Url.toString url) )

                Browser.External href ->
                    ( model, Nav.load href )

        UrlChanged url ->
            loadPage (fromUrl url) model

        GotDashboardMsg subMsg ->
            ( model, Cmd.none )

        GotSettingsMsg subMsg ->
            case model.page of
                Settings modelSettings ->
                    Settings.update subMsg modelSettings
                        |> updateWith Settings GotSettingsMsg model

                _ ->
                    ( model, Cmd.none )

        GotNotFoundMsg subMsg ->
            ( model, Cmd.none )



-- This aims to craft the right Model, Msg and Cmd from submodules


updateWith : (subModel -> Page) -> (subMsg -> Msg) -> Model -> ( subModel, Cmd subMsg ) -> ( Model, Cmd Msg )
updateWith toModel toMsg model ( subModel, subCmd ) =
    ( { model | page = toModel subModel }
    , Cmd.map toMsg subCmd
    )


loadPage : Route -> Model -> ( Model, Cmd Msg )
loadPage route model =
    case route of
        Router.NotFound ->
            ( { model | page = NotFound {} }, Cmd.none )

        Router.Dashboard ->
            ( { model | page = Dashboard {} }, Cmd.none )

        Router.Settings ->
            updateWith Settings GotSettingsMsg model ( { status = Settings.Loading }, Settings.getSettings )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



-- VIEW


view : Model -> Document Msg
view model =
    -- All this is just to create the right type! Because Document msg != Document Msg
    -- It was returning from the Pages, Html Pages.Settings.Msg and the view needed Main.Msg
    let
        viewPage toMsg page =
            let
                { title, body } =
                    Page.view page
            in
            { title = title
            , body = List.map (Html.map toMsg) body
            }
    in
    case model.page of
        Dashboard submodule ->
            viewPage GotDashboardMsg (Dashboard.view submodule)

        Settings submodule ->
            viewPage GotSettingsMsg (Settings.view submodule)

        NotFound submodule ->
            viewPage GotNotFoundMsg (NotFound.view submodule)
