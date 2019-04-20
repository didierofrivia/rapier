module Page.NotFound exposing (Model, Msg(..), view)

import Bulma.Elements as Elements exposing (TitleSize(..), title)
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
                [ Elements.title H1 [] [ text "Oops! You got yourself in a pickle!" ]
                , Elements.title H2
                    []
                    [ a [ href "/" ] [ text "o-_)==> take me home <==(_-o" ]
                    ]
                ]
            ]
        ]


myHeroModifiers =
    { bold = True
    , size = Standard
    , color = Warning
    }
