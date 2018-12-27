module Page.Dashboard exposing (Model, Msg(..), view)

import Bulma.Elements as Elements exposing (TitleSize(..), title)
import Bulma.Layout exposing (container, hero, heroBody)
import Bulma.Modifiers
    exposing
        ( Color(..)
        , Size(..)
        )
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Session exposing (..)


type alias Model =
    {}


type Msg
    = Noop


view : Model -> Html Msg
view model =
    hero myHeroModifiers
        []
        [ heroBody []
            [ container []
                [ Elements.title H1 [] [ text "o-_)=rapier>" ]
                , Elements.title H2
                    []
                    [ text "An "
                    , a [ href "https://github.com/3scale/apicast" ] [ text "APIcast" ]
                    , text " UI MGMT tool."
                    ]
                ]
            ]
        ]


myHeroModifiers =
    { bold = True
    , size = Standard
    , color = Dark
    }
