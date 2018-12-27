module Page exposing (view)

import Browser exposing (Document)
import Bulma.CDN exposing (..)
import Bulma.Columns exposing (..)
import Bulma.Components exposing (..)
import Bulma.Elements as Elements exposing (..)
import Bulma.Form exposing (..)
import Bulma.Layout as Layout exposing (SectionSpacing(..), container, section)
import Bulma.Modifiers exposing (..)
import Bulma.Modifiers.Typography exposing (textCentered)
import Html exposing (..)
import Html.Attributes exposing (..)
import Router exposing (Route(..))



-- VIEW
--view : Html msg -> Document msg


view page route =
    { title = "Rapier"
    , body =
        template
            page
            route
    }


headerNavbar : Route -> Html msg
headerNavbar route =
    let
        isLinkSelectedWithRoute =
            isLinkSelected route
    in
    fixedNavbar Top
        navbarModifiers
        []
        [ navbarBrand []
            (navbarBurger False
                []
                [ span [] []
                , span [] []
                , span [] []
                ]
            )
            [ navbarItemLink False
                [ href "/" ]
                [ text "o-_)=rapier>" ]
            ]
        , navbarMenu False
            []
            [ navbarStart []
                [ navbarItemLink (isLinkSelectedWithRoute Dashboard) [ href "/" ] [ text "Dashboard" ]
                , navbarItemLink (isLinkSelectedWithRoute Settings) [ href "/settings" ] [ text "Settings" ]
                ]
            ]
        ]


isLinkSelected : Route -> Route -> Bool
isLinkSelected route linkRoute =
    route == linkRoute


navbarModifiers =
    { color = Dark
    , transparent = False
    }


footer : Html msg
footer =
    Layout.footer []
        [ container []
            [ content Small
                [ textCentered ]
                [ p []
                    [ a [ href "https://github.com/didierofrivia/rapier" ] [ text "o-_)=rapier>" ]
                    , text " is an Open Source project, crafted with loads of <3 and c[_]"
                    ]
                ]
            ]
        ]


template : Html msg -> Route -> List (Html msg)
template content route =
    [ stylesheet
    , headerNavbar route
    , content
    , footer
    ]
