module Page.Dashboard exposing (Model, Msg(..), view)

import Bulma.Elements as Elements exposing (TitleSize(..))
import Bulma.Layout exposing (container, hero, heroBody)
import Bulma.Modifiers
    exposing
        ( Color(..)
        , Size(..)
        )
import Html exposing (..)
import Html.Attributes exposing (..)


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
                [ Elements.title H1 [] [ text "o-∫)= r a p i e r >" ]
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
